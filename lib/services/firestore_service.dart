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
final userProfileStreamProvider = StreamProvider.family<FirestoreUserModel?, String>((ref, uid) {
  return ref.watch(firestoreServiceProvider).streamUser(uid);
});

/// Reactive stream of the current user's study progress from Firestore
final userStudyProgressStreamProvider = StreamProvider.family<FirestoreStudyProgressModel?, String>((ref, uid) {
  return ref.watch(firestoreServiceProvider).streamStudyProgress(uid);
});

/// Reactive stream of all documents uploaded by the user to Firestore
final userDocumentsStreamProvider = StreamProvider.family<List<FirestoreDocumentModel>, String>((ref, uid) {
  return ref.watch(firestoreServiceProvider).streamUserDocuments(uid);
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

  // ── 1. Users Collection (/users/{uid}) ──────────────────────────────────────

  /// Get user document from Firestore by UID
  Future<FirestoreUserModel?> getUser(String uid) async {
    try {
      final doc = await _usersCol.doc(uid).get();
      if (!doc.exists || doc.data() == null) return null;
      return FirestoreUserModel.fromMap(doc.data()!, doc.id);
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

  /// Create a new document in Firestore and increment the user's documentsUploaded count
  Future<String> createDocument({
    required String ownerId,
    required String title,
    required String fileName,
    required String fileUrl,
    String subject = 'General',
    int conceptCount = 0,
    int quizCount = 0,
    int flashcardCount = 0,
  }) async {
    try {
      final now = DateTime.now();
      final newDocRef = _docsCol.doc();
      final userDocRef = _usersCol.doc(ownerId);

      final batch = _firestore.batch();

      final docModel = FirestoreDocumentModel(
        id: newDocRef.id,
        ownerId: ownerId,
        title: title,
        subject: subject,
        fileName: fileName,
        fileUrl: fileUrl,
        uploadedAt: now,
        lastOpened: now,
        conceptCount: conceptCount,
        quizCount: quizCount,
        flashcardCount: flashcardCount,
      );

      batch.set(newDocRef, docModel.toMap());

      // Atomically increment documentsUploaded in users collection
      batch.set(
        userDocRef,
        {
          'documentsUploaded': FieldValue.increment(1),
          'lastLogin': Timestamp.fromDate(now),
        },
        SetOptions(merge: true),
      );

      await batch.commit();
      return newDocRef.id;
    } catch (e) {
      debugPrint('FirestoreService.createDocument error: $e');
      rethrow;
    }
  }

  /// Update document metadata (e.g. concept/quiz/flashcard count)
  Future<void> updateDocumentMetadata(
    String documentId, {
    int? conceptCount,
    int? quizCount,
    int? flashcardCount,
    DateTime? lastOpened,
    String? fileUrl,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (conceptCount != null) updates['conceptCount'] = conceptCount;
      if (quizCount != null) updates['quizCount'] = quizCount;
      if (flashcardCount != null) updates['flashcardCount'] = flashcardCount;
      if (lastOpened != null) {
        updates['lastOpened'] = Timestamp.fromDate(lastOpened);
      }
      if (fileUrl != null && fileUrl.isNotEmpty) updates['fileUrl'] = fileUrl;

      if (updates.isNotEmpty) {
        await _docsCol.doc(documentId).update(updates);
      }
    } catch (e) {
      debugPrint('FirestoreService.updateDocumentMetadata error: $e');
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
      Query<Map<String, dynamic>> query = _chatSessionsCol
          .where('ownerId', isEqualTo: ownerId);

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
  Stream<List<FirestoreChatMessageModel>> streamSessionMessages(String sessionId) {
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

  /// Get study progress by UID
  Future<FirestoreStudyProgressModel?> getStudyProgress(String uid) async {
    try {
      final doc = await _studyProgressCol.doc(uid).get();
      if (!doc.exists || doc.data() == null) return null;
      return FirestoreStudyProgressModel.fromMap(doc.data()!, doc.id);
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
