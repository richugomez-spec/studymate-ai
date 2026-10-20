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

final userSubjectsStreamProvider =
    StreamProvider.family<List<Map<String, dynamic>>, String>((ref, uid) {
  return ref.watch(firestoreServiceProvider).streamSubjects(uid);
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

  CollectionReference<Map<String, dynamic>> get _subjectsCol =>
      _firestore.collection('subjects');

  /// Subjects are user-owned workspace roots. Legacy text-only subject names
  /// remain readable while new uploads use stable subject IDs.
  Stream<List<Map<String, dynamic>>> streamSubjects(String ownerId) =>
      _subjectsCol.where('ownerId', isEqualTo: ownerId).snapshots().map(
            (snapshot) =>
                snapshot.docs.map((d) => {'id': d.id, ...d.data()}).toList(),
          );

  Future<String> createSubject(String name) async {
    final uid = currentUserId;
    final clean = name.trim();
    if (uid == null) throw StateError('Sign in to create a subject.');
    if (clean.isEmpty) throw ArgumentError('Subject name is required.');
    final ref = await _subjectsCol.add({
      'ownerId': uid,
      'name': clean,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    // Adopt legacy items that predate subject IDs when the user creates a
    // subject with the same name.
    final legacyItems = await Future.wait([
      _docsCol.where('ownerId', isEqualTo: uid).get(),
      _knowledgeCol.where('ownerId', isEqualTo: uid).get(),
    ]);
    final updates = <Future<void>>[
      ...legacyItems[0]
          .docs
          .where((d) =>
              d.data()['subjectId'] == null &&
              (d.data()['subject'] as String? ?? '').toLowerCase() ==
                  clean.toLowerCase())
          .map((d) => d.reference.update({'subjectId': ref.id})),
      ...legacyItems[1]
          .docs
          .where((d) =>
              d.data()['subjectId'] == null &&
              (d.data()['subject'] as String? ?? '').toLowerCase() ==
                  clean.toLowerCase())
          .map((d) => d.reference.update({'subjectId': ref.id})),
    ];
    await Future.wait(updates);
    return ref.id;
  }

  Future<String> getOrCreateSubject(String name) async {
    final uid = currentUserId;
    final clean = name.trim().isEmpty ? 'General' : name.trim();
    if (uid == null) throw StateError('Sign in to select a subject.');
    final existing = await _subjectsCol.where('ownerId', isEqualTo: uid).get();
    for (final subject in existing.docs) {
      if ((subject.data()['name'] as String? ?? '').toLowerCase() ==
          clean.toLowerCase()) {
        return subject.id;
      }
    }
    return createSubject(clean);
  }

  Future<String?> getActiveSubjectId() async {
    final uid = currentUserId;
    if (uid == null) return null;
    final snapshot = await _usersCol.doc(uid).get();
    return snapshot.data()?['activeSubjectId'] as String?;
  }

  Future<void> setActiveSubjectId(String? subjectId) async {
    final uid = currentUserId;
    if (uid == null) return;
    await _usersCol.doc(uid).set({
      'activeSubjectId': subjectId ?? '',
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> renameSubject(String subjectId, String name) async {
    final clean = name.trim();
    if (clean.isEmpty) throw ArgumentError('Subject name is required.');
    final uid = currentUserId;
    if (uid == null) throw StateError('Sign in to rename a subject.');
    final subjectRef = _subjectsCol.doc(subjectId);
    final subject = await subjectRef.get();
    if (subject.data()?['ownerId'] != uid) {
      throw StateError('Subject is not available.');
    }
    await subjectRef.update({
      'name': clean,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await Future.wait([
      _docsCol
          .where('ownerId', isEqualTo: uid)
          .where('subjectId', isEqualTo: subjectId)
          .get()
          .then((s) => Future.wait(
              s.docs.map((d) => d.reference.update({'subject': clean})))),
      _knowledgeCol
          .where('ownerId', isEqualTo: uid)
          .where('subjectId', isEqualTo: subjectId)
          .get()
          .then((s) => Future.wait(
              s.docs.map((d) => d.reference.update({'subject': clean})))),
    ]);
  }

  Future<void> deleteSubject(String subjectId) async {
    final uid = currentUserId;
    if (uid == null) throw StateError('Sign in to delete a subject.');
    final subjectRef = _subjectsCol.doc(subjectId);
    final subject = await subjectRef.get();
    if (subject.data()?['ownerId'] != uid) {
      throw StateError('Subject is not available.');
    }
    // Keep documents and notes intact, but detach them from the removed root.
    await Future.wait([
      _docsCol
          .where('ownerId', isEqualTo: uid)
          .where('subjectId', isEqualTo: subjectId)
          .get()
          .then((s) => Future.wait(s.docs.map((d) => d.reference.update({
                'subjectId': '',
                'subject': 'General',
              })))),
      _knowledgeCol
          .where('ownerId', isEqualTo: uid)
          .where('subjectId', isEqualTo: subjectId)
          .get()
          .then((s) => Future.wait(s.docs.map((d) => d.reference.update({
                'subjectId': '',
                'subject': 'General',
              })))),
    ]);
    final sessions = await _chatSessionsCol
        .where('ownerId', isEqualTo: uid)
        .where('subjectId', isEqualTo: subjectId)
        .get();
    for (final session in sessions.docs) {
      await _deleteCollection(session.reference.collection('messages'));
      await session.reference.delete();
    }
    await subjectRef.delete();
  }

  Future<List<Map<String, dynamic>>> loadKnowledge({
    String? ownerId,
    String? subjectId,
    List<String> sourceIds = const [],
  }) async {
    final uid = ownerId ?? currentUserId;
    if (uid == null) return const [];
    late final List<Map<String, dynamic>> documents;
    late final List<Map<String, dynamic>> notes;
    if (sourceIds.isEmpty) {
      final snapshots = await Future.wait([
        _docsCol.where('ownerId', isEqualTo: uid).get(),
        _knowledgeCol.where('ownerId', isEqualTo: uid).get(),
      ]);
      documents =
          snapshots[0].docs.map((d) => {'id': d.id, ...d.data()}).toList();
      notes = snapshots[1].docs.map((d) => {'id': d.id, ...d.data()}).toList();
    } else {
      final selected = await Future.wait(sourceIds.map((id) async => [
            await _docsCol.doc(id).get(),
            await _knowledgeCol.doc(id).get(),
          ]));
      documents = [];
      notes = [];
      for (final pair in selected) {
        final document = pair[0];
        final note = pair[1];
        if (document.exists && document.data()?['ownerId'] == uid) {
          documents.add({'id': document.id, ...document.data()!});
        }
        if (note.exists && note.data()?['ownerId'] == uid) {
          notes.add({'id': note.id, ...note.data()!});
        }
      }
    }
    bool inScope(Map<String, dynamic> data, String id) {
      if (subjectId != null && subjectId.isNotEmpty) {
        return data['subjectId'] == subjectId ||
            (data['subjectId'] == null && data['subject'] == subjectId);
      }
      return true;
    }

    final items = <Map<String, dynamic>>[
      ...notes
          .where((d) => d['kind'] != 'folder' && inScope(d, d['id'] as String))
          .map((d) => {...d, 'kind': 'note'}),
    ];
    for (final note in notes.where((d) => inScope(d, d['id'] as String))) {
      final noteId = note['id'] as String;
      final indexed = note['structuredKnowledge'];
      if (indexed is Map && indexed['concepts'] is List) {
        for (final concept in indexed['concepts'] as List) {
          if (concept is Map)
            items.add({
              'id': '${noteId}_${concept['id'] ?? items.length}',
              'sourceId': noteId,
              'title': concept['name'] ?? concept['title'] ?? note['title'],
              'content': jsonEncode(concept),
              'subject': note['subject'],
              'topic': note['topic'],
              'kind': 'concept',
              'updatedAt': note['indexedAt']
            });
        }
      }
    }
    for (final data in documents.where((d) => inScope(d, d['id'] as String))) {
      final documentId = data['id'] as String;
      final customNotes = (data['notes'] ?? '').toString().trim();
      if (customNotes.isNotEmpty)
        items.add({
          'id': '${documentId}_notes',
          'title': '${data['title'] ?? data['fileName']} notes',
          'sourceId': documentId,
          'content': customNotes,
          'subject': data['subject'],
          'topic': data['topic'],
          'kind': 'note',
          'updatedAt': data['uploadedAt'],
        });
      items.add({...data, 'kind': 'document'});
      final indexed = data['structuredKnowledge'];
      if (indexed is Map && indexed['concepts'] is List) {
        for (final concept in indexed['concepts'] as List) {
          if (concept is Map)
            items.add({
              'id': '${documentId}_${concept['id'] ?? items.length}',
              'sourceId': documentId,
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
      String subjectId = '',
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
      'subjectId': subjectId,
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
      {required String name,
      String parentId = '',
      String subject = '',
      String subjectId = ''}) async {
    final uid = currentUserId;
    if (uid == null) throw StateError('Sign in to create a workspace folder.');
    final ref = await _knowledgeCol.add({
      'ownerId': uid,
      'kind': 'folder',
      'title': name,
      'parentId': parentId,
      'subject': subject,
      'subjectId': subjectId,
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
      {required String sourceText,
      String sourceKind = 'document',
      String subjectId = ''}) async {
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
      if (subjectId.isNotEmpty) 'subjectId': subjectId,
      if (sourceKind == 'document') ...{
        'conceptCount': (index['concepts'] as List?)?.length ?? 0,
        if (index['flashcards'] is List)
          'flashcardCount': (index['flashcards'] as List).length,
        if (index['quizzes'] is List)
          'quizCount': (index['quizzes'] as List).length,
      },
    });
  }

  Future<void> setDocumentStatus(String documentId, String status) =>
      _docsCol.doc(documentId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });

  Future<void> updateDocumentCounts(String documentId,
      {int? concepts, int? flashcards, int? quizzes}) async {
    try {
      await _docsCol.doc(documentId).update({
        if (concepts != null) 'conceptCount': concepts,
        if (flashcards != null) 'flashcardCount': flashcards,
        if (quizzes != null) 'quizCount': quizzes,
      });
    } catch (error) {
      debugPrint('Study asset counters could not be updated.');
    }
  }

  Future<void> renameDocument(String documentId, String title) async {
    await _docsCol.doc(documentId).update({
      'title': title,
      'updatedAt': FieldValue.serverTimestamp(),
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
      final relatedSessions = await _chatSessionsCol
          .where('ownerId', isEqualTo: ownerId)
          .where('documentId', isEqualTo: documentId)
          .get();
      for (final session in relatedSessions.docs) {
        await _deleteCollection(session.reference.collection('messages'));
        await session.reference.delete();
      }
      final relatedNotes = await _knowledgeCol
          .where('ownerId', isEqualTo: ownerId)
          .where('sourceId', isEqualTo: documentId)
          .get();
      await _deleteDocuments(
          relatedNotes.docs.map((d) => d.reference).toList());
      final cache =
          await _usersCol.doc(ownerId).collection('generation_cache').get();
      final staleCache = cache.docs.where((d) {
        final result = d.data()['result'];
        if (result is! Map || result['sources'] is! List) return false;
        return (result['sources'] as List)
            .any((s) => s is Map && s['id'] == documentId);
      });
      await _deleteDocuments(staleCache.map((d) => d.reference).toList());
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
        .snapshots()
        .map((snapshot) {
      final documents = snapshot.docs
          .map((doc) => FirestoreDocumentModel.fromMap(doc.data(), doc.id))
          .toList();
      documents.sort((a, b) => b.uploadedAt.compareTo(a.uploadedAt));
      return documents;
    }).handleError((e) {
      debugPrint('FirestoreService.streamUserDocuments error: $e');
    });
  }

  // ── 3. Chat Sessions & Messages ────────────────────────────────────────────

  /// Find or create a chat session for a user & optional documentId
  Future<FirestoreChatSessionModel> getOrCreateChatSession({
    required String ownerId,
    String? documentId,
    String? subjectId,
  }) async {
    try {
      Query<Map<String, dynamic>> query =
          _chatSessionsCol.where('ownerId', isEqualTo: ownerId);
      if (subjectId != null && subjectId.isNotEmpty) {
        query = query.where('subjectId', isEqualTo: subjectId);
      }

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
        subjectId: subjectId ?? '',
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

  Future<void> _deleteCollection(
      CollectionReference<Map<String, dynamic>> collection) async {
    final snapshot = await collection.get();
    await _deleteDocuments(snapshot.docs.map((d) => d.reference).toList());
  }

  Future<void> _deleteDocuments(
      List<DocumentReference<Map<String, dynamic>>> refs) async {
    for (var i = 0; i < refs.length; i += 450) {
      final batch = _firestore.batch();
      for (final ref in refs.skip(i).take(450)) {
        batch.delete(ref);
      }
      await batch.commit();
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
