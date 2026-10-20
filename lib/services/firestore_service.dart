import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'firestore_models.dart';

/// Provider for FirestoreService
final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

/// Reactive stream of the current user's profile from Firestore
final userProfileStreamProvider =
    StreamProvider.family<FirestoreUserModel?, String>((ref, uid) {
  return ref.watch(firestoreServiceProvider).streamUser(uid);
});

/// Reactive stream of the current user's study progress from Firestore
final userStudyProgressStreamProvider =
    StreamProvider.family<FirestoreStudyProgressModel?, String>((ref, uid) {
  return ref.watch(firestoreServiceProvider).streamStudyProgress(uid);
});

/// Reactive stream of all documents uploaded by the user to Firestore
final userDocumentsStreamProvider =
    StreamProvider.family<List<FirestoreDocumentModel>, String>((ref, uid) {
  return ref.watch(firestoreServiceProvider).streamUserDocuments(uid);
});

final userKnowledgeStreamProvider =
    StreamProvider.family<List<Map<String, dynamic>>, String>((ref, uid) {
  return ref.watch(firestoreServiceProvider).streamWorkspaceItems(uid);
});

/// Production Firestore Service Layer
///
/// Encapsulates all Firestore CRUD operations and data synchronization:
/// - Users (/users)
/// - Documents (/documents)
/// - Chat Sessions & Messages (/chat_sessions/{sessionId}/messages)
/// - Study Progress (/study_progress)
class FirestoreService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  // In-memory cache to prevent duplicate Firestore reads across page navigations
  static final Map<String, (FirestoreUserModel?, DateTime)> _userCache = {};
  static final Map<String, (FirestoreStudyProgressModel?, DateTime)>
      _progressCache = {};
  static const Duration _cacheTtl = Duration(minutes: 5);

  FirestoreService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  // ── Collection References ──────────────────────────────────────────────────

  CollectionReference<Map<String, dynamic>> get _usersCol =>
      _firestore.collection('users');

  CollectionReference<Map<String, dynamic>> get _docsCol =>
      _firestore.collection('documents');

  CollectionReference<Map<String, dynamic>> get _chatSessionsCol =>
      _firestore.collection('chat_sessions');

  CollectionReference<Map<String, dynamic>> get _studyProgressCol =>
      _firestore.collection('study_progress');

  CollectionReference<Map<String, dynamic>> get _knowledgeCol =>
      _firestore.collection('knowledge_items');

  Future<List<Map<String, dynamic>>> loadKnowledge({String? ownerId}) async {
    final uid = ownerId ?? currentUserId;
    if (uid == null) return const [];
    final snapshot = await _docsCol.where('ownerId', isEqualTo: uid).get();
    final notes = await _knowledgeCol.where('ownerId', isEqualTo: uid).get();
    final items = <Map<String, dynamic>>[
      ...notes.docs
          .where((d) => d.data()['kind'] != 'folder')
          .map((d) => {'id': d.id, ...d.data(), 'kind': 'note'}),
    ];
    for (final note in notes.docs) {
      final indexed = note.data()['structuredKnowledge'];
      if (indexed is Map && indexed['concepts'] is List) {
        for (final concept in indexed['concepts'] as List) {
          if (concept is Map)
            items.add({
              'id': '${note.id}_${concept['id'] ?? items.length}',
              'sourceId': note.id,
              'title':
                  concept['name'] ?? concept['title'] ?? note.data()['title'],
              'content': jsonEncode(concept),
              'subject': note.data()['subject'],
              'topic': note.data()['topic'],
              'kind': 'concept',
              'updatedAt': note.data()['indexedAt']
            });
        }
      }
    }
    for (final doc in snapshot.docs) {
      final data = doc.data();
      final customNotes = (data['notes'] ?? '').toString().trim();
      if (customNotes.isNotEmpty)
        items.add({
          'id': '${doc.id}_notes',
          'title': '${data['title'] ?? data['fileName']} notes',
          'sourceId': doc.id,
          'content': customNotes,
          'subject': data['subject'],
          'topic': data['topic'],
          'kind': 'note',
          'updatedAt': data['uploadedAt'],
        });
      items.add({'id': doc.id, ...data, 'kind': 'document'});
      final indexed = data['structuredKnowledge'];
      if (indexed is Map && indexed['concepts'] is List) {
        for (final concept in indexed['concepts'] as List) {
          if (concept is Map)
            items.add({
              'id': '${doc.id}_${concept['id'] ?? items.length}',
              'sourceId': doc.id,
              'title': concept['name'] ?? concept['title'] ?? data['title'],
              'content': jsonEncode(concept),
              'subject': data['subject'],
              'topic': data['topic'],
              'kind': 'concept',
              'updatedAt': data['indexedAt'],
            });
        }
      }
    }
    return items;
  }

  Future<String> saveKnowledgeNote(
      {required String title,
      required String content,
      String subject = '',
      String topic = '',
      String subtopic = '',
      String notes = '',
      String folderId = '',
      List<String> tags = const []}) async {
    final uid = currentUserId;
    if (uid == null) throw StateError('Sign in to save knowledge.');
    final ref = await _knowledgeCol.add({
      'ownerId': uid,
      'title': title,
      'content': content,
      'subject': subject,
      'topic': topic,
      'subtopic': subtopic,
      'notes': notes,
      'folderId': folderId,
      'tags': tags,
      'kind': 'note',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  Future<String> createWorkspaceFolder(
      {required String name, String parentId = '', String subject = ''}) async {
    final uid = currentUserId;
    if (uid == null) throw StateError('Sign in to create a workspace folder.');
    final ref = await _knowledgeCol.add({
      'ownerId': uid,
      'kind': 'folder',
      'title': name,
      'parentId': parentId,
      'subject': subject,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp()
    });
    return ref.id;
  }

  Stream<List<Map<String, dynamic>>> streamWorkspaceItems(String ownerId) =>
      _knowledgeCol.where('ownerId', isEqualTo: ownerId).snapshots().map(
          (snapshot) =>
              snapshot.docs.map((d) => {'id': d.id, ...d.data()}).toList());

  Future<void> saveKnowledgeIndex(String documentId, Map<String, dynamic> index,
      {required String sourceText, String sourceKind = 'document'}) async {
    final target = sourceKind == 'note'
        ? _knowledgeCol.doc(documentId)
        : _docsCol.doc(documentId);
    await target.update({
      'structuredKnowledge': index,
      'extractedText': sourceText.length > 100000
          ? sourceText.substring(0, 100000)
          : sourceText,
      'indexedAt': FieldValue.serverTimestamp(),
      'status': 'indexed',
    });
  }

  Future<void> setDocumentIndexError(String documentId, String error) async {
    await _docsCol.doc(documentId).set({
      'status': 'index_error',
      'indexError': error,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> cacheGeneration(String key, Map<String, dynamic> result) async {
    final uid = currentUserId;
    if (uid == null) return;
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('generation_cache')
        .doc(key)
        .set({'result': result, 'updatedAt': FieldValue.serverTimestamp()});
  }

  Future<Map<String, dynamic>?> getGenerationCache(String key) async {
    final uid = currentUserId;
    if (uid == null) return null;
    final doc = await _firestore
        .collection('users')
        .doc(uid)
        .collection('generation_cache')
        .doc(key)
        .get();
    final result = doc.data()?['result'];
    return result is Map ? Map<String, dynamic>.from(result) : null;
  }

  // ── 1. Users Collection (/users/{uid}) ──────────────────────────────────────

  /// Get user document from Firestore by UID with memory caching
  Future<FirestoreUserModel?> getUser(String uid) async {
    final cached = _userCache[uid];
    if (cached != null && DateTime.now().difference(cached.$2) < _cacheTtl) {
      return cached.$1;
    }
    try {
      final doc = await _usersCol.doc(uid).get();
      if (!doc.exists || doc.data() == null) {
        _userCache[uid] = (null, DateTime.now());
        return null;
      }
      final user = FirestoreUserModel.fromMap(doc.data()!, doc.id);
      _userCache[uid] = (user, DateTime.now());
      return user;
    } catch (e) {
      debugPrint('FirestoreService.getUser error: $e');
      return null;
    }
  }

  /// Stream of user document by UID
  Stream<FirestoreUserModel?> streamUser(String uid) {
    return _usersCol.doc(uid).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return FirestoreUserModel.fromMap(doc.data()!, doc.id);
    }).handleError((e) {
      debugPrint('FirestoreService.streamUser error: $e');
    });
  }

  /// Create or update user profile on login/registration
  Future<void> syncUserOnAuth({
    required String uid,
    required String email,
    String? name,
    String? photoUrl,
  }) async {
    try {
      final userDocRef = _usersCol.doc(uid);
      final docSnapshot = await userDocRef.get();

      final now = DateTime.now();
      if (!docSnapshot.exists) {
        // Initialize new user and initial study progress in a batch
        final batch = _firestore.batch();
        final newUser = FirestoreUserModel(
          uid: uid,
          name: name?.isNotEmpty == true
              ? name!
              : (email.contains('@') ? email.split('@').first : 'Student'),
          email: email,
          photoUrl: photoUrl,
          createdAt: now,
          lastLogin: now,
          streak: 1,
        );
        batch.set(userDocRef, newUser.toMap());

        final progressDocRef = _studyProgressCol.doc(uid);
        final initialProgress = FirestoreStudyProgressModel(
          uid: uid,
          currentStreak: 1,
          lastStudyDate: now,
        );
        batch.set(progressDocRef, initialProgress.toMap());

        await batch.commit();
      } else {
        // Update last login
        await userDocRef.update({
          'lastLogin': Timestamp.fromDate(now),
          if (name != null && name.isNotEmpty) 'name': name,
          if (photoUrl != null && photoUrl.isNotEmpty) 'photoUrl': photoUrl,
        });
      }
    } catch (e) {
      debugPrint('FirestoreService.syncUserOnAuth error: $e');
    }
  }

  // ── 2. Documents Collection (/documents/{docId}) ───────────────────────────

  /// Permanently delete a document from Firestore and decrement user's count
  Future<void> deleteDocument({
    required String documentId,
    required String ownerId,
  }) async {
    try {
      final batch = _firestore.batch();
      batch.delete(_docsCol.doc(documentId));
      batch.set(
        _usersCol.doc(ownerId),
        {'documentsUploaded': FieldValue.increment(-1)},
        SetOptions(merge: true),
      );
      await batch.commit();
    } catch (e) {
      debugPrint('FirestoreService.deleteDocument error: $e');
    }
  }

  /// Update the lastOpened timestamp on a document
  Future<void> updateLastOpened(String documentId) async {
    try {
      await _docsCol.doc(documentId).update({
        'lastOpened': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      debugPrint('FirestoreService.updateLastOpened error: $e');
    }
  }

  /// Stream of user's uploaded documents
  Stream<List<FirestoreDocumentModel>> streamUserDocuments(String ownerId) {
    return _docsCol
        .where('ownerId', isEqualTo: ownerId)
        .orderBy('uploadedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => FirestoreDocumentModel.fromMap(doc.data(), doc.id))
          .toList();
    }).handleError((e) {
      debugPrint('FirestoreService.streamUserDocuments error: $e');
    });
  }

  // ── 3. Chat Sessions & Messages ────────────────────────────────────────────

  /// Find or create a chat session for a user & optional documentId
  Future<FirestoreChatSessionModel> getOrCreateChatSession({
    required String ownerId,
    String? documentId,
  }) async {
    try {
      Query<Map<String, dynamic>> query =
          _chatSessionsCol.where('ownerId', isEqualTo: ownerId);

      if (documentId != null && documentId.isNotEmpty) {
        query = query.where('documentId', isEqualTo: documentId);
      }

      final existing = await query.limit(1).get();
      if (existing.docs.isNotEmpty) {
        final doc = existing.docs.first;
        return FirestoreChatSessionModel.fromMap(doc.data(), doc.id);
      }

      // Create new session
      final now = DateTime.now();
      final newSessionRef = _chatSessionsCol.doc();
      final session = FirestoreChatSessionModel(
        id: newSessionRef.id,
        ownerId: ownerId,
        documentId: documentId,
        createdAt: now,
        updatedAt: now,
      );

      await newSessionRef.set(session.toMap());
      return session;
    } catch (e) {
      debugPrint('FirestoreService.getOrCreateChatSession error: $e');
      rethrow;
    }
  }

  /// Save a chat message to a session and touch the session updatedAt timestamp
  Future<void> saveChatMessage({
    required String sessionId,
    required String role,
    required String content,
    DateTime? timestamp,
  }) async {
    try {
      final now = timestamp ?? DateTime.now();
      final sessionRef = _chatSessionsCol.doc(sessionId);
      final messageRef = sessionRef.collection('messages').doc();

      final batch = _firestore.batch();

      final messageModel = FirestoreChatMessageModel(
        id: messageRef.id,
        role: role,
        content: content,
        timestamp: now,
      );

      batch.set(messageRef, messageModel.toMap());
      batch.update(sessionRef, {
        'updatedAt': Timestamp.fromDate(now),
      });

      await batch.commit();
    } catch (e) {
      debugPrint('FirestoreService.saveChatMessage error: $e');
    }
  }

  /// Stream messages in a chat session in chronological order
  Stream<List<FirestoreChatMessageModel>> streamSessionMessages(
      String sessionId) {
    return _chatSessionsCol
        .doc(sessionId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => FirestoreChatMessageModel.fromMap(doc.data(), doc.id))
          .toList();
    }).handleError((e) {
      debugPrint('FirestoreService.streamSessionMessages error: $e');
    });
  }

  // ── 4. Study Progress Collection (/study_progress/{uid}) ───────────────────

  /// Get study progress by UID with memory caching
  Future<FirestoreStudyProgressModel?> getStudyProgress(String uid) async {
    final cached = _progressCache[uid];
    if (cached != null && DateTime.now().difference(cached.$2) < _cacheTtl) {
      return cached.$1;
    }
    try {
      final doc = await _studyProgressCol.doc(uid).get();
      if (!doc.exists || doc.data() == null) {
        _progressCache[uid] = (null, DateTime.now());
        return null;
      }
      final progress = FirestoreStudyProgressModel.fromMap(doc.data()!, doc.id);
      _progressCache[uid] = (progress, DateTime.now());
      return progress;
    } catch (e) {
      debugPrint('FirestoreService.getStudyProgress error: $e');
      return null;
    }
  }

  /// Stream study progress by UID
  Stream<FirestoreStudyProgressModel?> streamStudyProgress(String uid) {
    return _studyProgressCol.doc(uid).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return FirestoreStudyProgressModel.fromMap(doc.data()!, doc.id);
    }).handleError((e) {
      debugPrint('FirestoreService.streamStudyProgress error: $e');
    });
  }

  /// Increment quizzes completed
  Future<void> incrementQuizzesCompleted(String uid) async {
    try {
      final now = DateTime.now();
      await _studyProgressCol.doc(uid).set({
        'quizzesCompleted': FieldValue.increment(1),
        'lastStudyDate': Timestamp.fromDate(now),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('FirestoreService.incrementQuizzesCompleted error: $e');
    }
  }

  /// Increment flashcards reviewed
  Future<void> incrementFlashcardsReviewed(String uid, {int count = 1}) async {
    try {
      final now = DateTime.now();
      await _studyProgressCol.doc(uid).set({
        'flashcardsReviewed': FieldValue.increment(count),
        'lastStudyDate': Timestamp.fromDate(now),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('FirestoreService.incrementFlashcardsReviewed error: $e');
    }
  }

  /// Increment concepts learned
  Future<void> incrementConceptsLearned(String uid, {int count = 1}) async {
    try {
      final now = DateTime.now();
      await _studyProgressCol.doc(uid).set({
        'conceptsLearned': FieldValue.increment(count),
        'lastStudyDate': Timestamp.fromDate(now),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('FirestoreService.incrementConceptsLearned error: $e');
    }
  }

  /// Record completed study time from timer / focus session
  Future<void> recordStudySessionTime(String uid, int minutes) async {
    if (minutes <= 0) return;
    try {
      final now = DateTime.now();
      final batch = _firestore.batch();

      final progressRef = _studyProgressCol.doc(uid);
      final userRef = _usersCol.doc(uid);

      batch.set(
        progressRef,
        {
          'totalMinutes': FieldValue.increment(minutes),
          'lastStudyDate': Timestamp.fromDate(now),
        },
        SetOptions(merge: true),
      );

      batch.set(
        userRef,
        {
          'totalStudyMinutes': FieldValue.increment(minutes),
          'lastLogin': Timestamp.fromDate(now),
        },
        SetOptions(merge: true),
      );

      await batch.commit();
    } catch (e) {
      debugPrint('FirestoreService.recordStudySessionTime error: $e');
    }
  }
}
