import 'dart:async';
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

final userChatSessionsStreamProvider =
    StreamProvider.family<List<FirestoreChatSessionModel>, String>((ref, uid) {
  return ref.watch(firestoreServiceProvider).streamUserChatSessions(uid);
});

/// Production Firestore Service Layer
///
/// Encapsulates all Firestore CRUD operations and data synchronization:
/// - Users (/users)
/// - Subject documents (/subjects/{subjectId}/documents/{documentId})
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

  CollectionReference<Map<String, dynamic>> get _chatSessionsCol =>
      _firestore.collection('chat_sessions');

  CollectionReference<Map<String, dynamic>> get _studyProgressCol =>
      _firestore.collection('study_progress');

  CollectionReference<Map<String, dynamic>> get _knowledgeCol =>
      _firestore.collection('knowledge_items');

  CollectionReference<Map<String, dynamic>> get _subjectsCol =>
      _firestore.collection('subjects');

  CollectionReference<Map<String, dynamic>> _deleteQueueCol(String ownerId) =>
      _usersCol.doc(ownerId).collection('firestore_delete_queue');

  CollectionReference<Map<String, dynamic>> _storageDeleteQueueCol(
          String ownerId) =>
      _usersCol.doc(ownerId).collection('storage_delete_queue');

  Future<List<Map<String, dynamic>>> getPendingStorageDeletes(
      {int limit = 50}) async {
    final uid = currentUserId;
    if (uid == null) return const [];
    final snapshot = await _storageDeleteQueueCol(uid)
        .orderBy('createdAt')
        .limit(limit)
        .get();
    return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
  }

  Future<String> enqueueStorageDelete({
    required String storagePath,
    required String operationId,
    String? subjectId,
    String? documentId,
    String reason = 'compensation',
  }) async {
    final uid = currentUserId;
    if (uid == null) throw StateError('Sign in to queue storage cleanup.');
    final task = _storageDeleteQueueCol(uid).doc();
    await task.set({
      'storagePath': storagePath,
      'operationId': operationId,
      if (subjectId != null) 'subjectId': subjectId,
      if (documentId != null) 'documentId': documentId,
      'reason': reason,
      'attempts': 0,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return task.id;
  }

  Future<void> completeStorageDelete(String taskId) async {
    final uid = currentUserId;
    if (uid == null) throw StateError('Sign in to complete storage cleanup.');
    await _storageDeleteQueueCol(uid).doc(taskId).delete();
  }

  Future<void> recordStorageDeleteFailure(String taskId, Object error) async {
    final uid = currentUserId;
    if (uid == null) throw StateError('Sign in to update storage cleanup.');
    await _storageDeleteQueueCol(uid).doc(taskId).set({
      'attempts': FieldValue.increment(1),
      'lastError': error.toString(),
      'lastAttemptAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  CollectionReference<Map<String, dynamic>> _subjectDocumentsCol(
          String subjectId) =>
      _subjectsCol.doc(subjectId).collection('documents');

  DocumentReference<Map<String, dynamic>> _subjectDocumentRef(
          String subjectId, String documentId) =>
      _subjectDocumentsCol(subjectId).doc(documentId);

  CollectionReference<Map<String, dynamic>> _subjectTopicsCol(
          String subjectId) =>
      _subjectsCol.doc(subjectId).collection('topics');

  DocumentReference<Map<String, dynamic>> _topicRef(
          String subjectId, String topicId) =>
      _subjectTopicsCol(subjectId).doc(topicId);

  CollectionReference<Map<String, dynamic>> _topicSubtopicsCol(
          String subjectId, String topicId) =>
      _topicRef(subjectId, topicId).collection('subtopics');

  DocumentReference<Map<String, dynamic>> _subtopicRef(
          String subjectId, String topicId, String subtopicId) =>
      _topicSubtopicsCol(subjectId, topicId).doc(subtopicId);

  /// Subjects are user-owned workspace roots.
  Stream<List<Map<String, dynamic>>> streamSubjects(String ownerId) =>
      _subjectsCol.where('ownerId', isEqualTo: ownerId).snapshots().map(
            (snapshot) =>
                snapshot.docs.map((d) => {'id': d.id, ...d.data()}).toList(),
          );

  Stream<List<FirestoreChatSessionModel>> streamUserChatSessions(
          String ownerId) =>
      _chatSessionsCol.where('ownerId', isEqualTo: ownerId).snapshots().map(
            (snapshot) => snapshot.docs
                .map((doc) =>
                    FirestoreChatSessionModel.fromMap(doc.data(), doc.id))
                .toList(),
          );

  Future<String> createSubject(String name) async {
    final uid = currentUserId;
    final clean = name.trim();
    if (uid == null) throw StateError('Sign in to create a subject.');
    if (clean.isEmpty) throw ArgumentError('Subject name is required.');
    final existing = await _subjectsCol.where('ownerId', isEqualTo: uid).get();
    for (final subject in existing.docs) {
      if ((subject.data()['name'] as String? ?? '').trim().toLowerCase() ==
          clean.toLowerCase()) {
        return subject.id;
      }
    }
    final ref = await _subjectsCol.add({
      'ownerId': uid,
      'name': clean,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
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

  String newSubjectDocumentId(String subjectId) =>
      _subjectDocumentsCol(subjectId).doc().id;

  Future<void> createDocumentRecord({
    required String documentId,
    required String subjectId,
    required String title,
    required String fileType,
    required int byteSize,
    required String storagePath,
    required String subject,
    String? operationId,
    String folderId = '',
    String topicId = '',
    String subtopicId = '',
    String topic = '',
    String subtopic = '',
    String notes = '',
    List<String> tags = const [],
  }) async {
    final uid = currentUserId;
    if (uid == null) throw StateError('Sign in to upload sources.');
    if (subjectId.trim().isEmpty) {
      throw ArgumentError('Choose a subject before uploading.');
    }
    debugPrint('UPLOAD FIRESTORE SUBJECT READ START: subject=$subjectId');
    final subjectSnapshot = await _subjectsCol
        .doc(subjectId)
        .get(const GetOptions(source: Source.server));
    debugPrint('UPLOAD FIRESTORE SUBJECT READ COMPLETE: subject=$subjectId');
    if (subjectSnapshot.data()?['ownerId'] != uid) {
      throw StateError('The selected subject is not available.');
    }
    if (subtopicId.isNotEmpty && topicId.isEmpty) {
      throw ArgumentError('A subtopic must belong to a selected topic.');
    }
    if (topicId.isNotEmpty) {
      final topic = await _topicRef(subjectId, topicId)
          .get(const GetOptions(source: Source.server));
      if (!topic.exists)
        throw StateError('The selected topic is not available.');
      if (subtopicId.isNotEmpty) {
        final subtopic = await _subtopicRef(subjectId, topicId, subtopicId)
            .get(const GetOptions(source: Source.server));
        if (!subtopic.exists) {
          throw StateError('The selected subtopic is not available.');
        }
      }
    }
    if (folderId.isNotEmpty) {
      debugPrint('UPLOAD FIRESTORE FOLDER READ START: folder=$folderId');
      final folder = await _knowledgeCol
          .doc(folderId)
          .get(const GetOptions(source: Source.server));
      debugPrint('UPLOAD FIRESTORE FOLDER READ COMPLETE: folder=$folderId');
      final folderData = folder.data();
      if (folderData?['ownerId'] != uid ||
          folderData?['kind'] != 'folder' ||
          folderData?['subjectId'] != subjectId) {
        throw StateError('The selected folder is not in this subject.');
      }
    }
    final subjectName = subjectSnapshot.data()?['name']?.toString() ?? subject;
    final now = FieldValue.serverTimestamp();
    final documentRef = _subjectDocumentRef(subjectId, documentId);
    final batch = _firestore.batch();
    batch.set(documentRef, {
      'title': title,
      'ownerId': uid,
      'fileName': title,
      'fileType': fileType,
      'byteSize': byteSize,
      'storagePath': storagePath,
      'downloadUrl': '',
      'uploadedAt': now,
      'status': 'queued',
      'uploadStatus': 'queued',
      'subject': subjectName,
      'subjectId': subjectId,
      if (operationId != null) 'operationId': operationId,
      'folderId': folderId,
      'topicId': topicId,
      'subtopicId': subtopicId,
      'topic': topic,
      'subtopic': subtopic,
      'notes': notes,
      'tags': tags,
      'indexedAt': null,
      'createdAt': now,
      'updatedAt': now,
    });
    batch.set(
        _usersCol.doc(uid),
        {
          'documentsUploaded': FieldValue.increment(1),
          'lastLogin': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true));
    debugPrint(
        'UPLOAD FIRESTORE DOCUMENT CREATE START: subject=$subjectId document=$documentId');
    await batch.commit();
    debugPrint(
        'UPLOAD FIRESTORE DOCUMENT CREATE COMPLETE: subject=$subjectId document=$documentId');
  }

  Future<FirestoreDocumentModel?> getSubjectDocument(
      String subjectId, String documentId) async {
    final uid = currentUserId;
    if (uid == null) return null;
    final subject = await _subjectsCol.doc(subjectId).get();
    if (subject.data()?['ownerId'] != uid) return null;
    final snapshot = await _subjectDocumentRef(subjectId, documentId).get();
    final data = snapshot.data();
    if (data == null || (data['ownerId'] != null && data['ownerId'] != uid)) {
      return null;
    }
    return FirestoreDocumentModel.fromMap({
      ...data,
      'ownerId': data['ownerId'] ?? uid,
      'subjectId': subjectId,
    }, snapshot.id);
  }

  Future<void> updateDocumentPipelineState({
    required String subjectId,
    required String documentId,
    required String status,
    String? operationId,
    String? uploadStatus,
    String? downloadUrl,
    String? error,
  }) async {
    debugPrint(
        'UPLOAD FIRESTORE STATE UPDATE START: subject=$subjectId document=$documentId status=$status');
    await _transitionDocumentState(
      _subjectDocumentRef(subjectId, documentId),
      status,
      {
        'status': status,
        if (operationId != null) 'operationId': operationId,
        if (uploadStatus != null) 'uploadStatus': uploadStatus,
        if (downloadUrl != null) ...{
          'downloadUrl': downloadUrl,
          'fileUrl': downloadUrl,
        },
        if (error != null) ...{'error': error, 'indexError': error},
        'updatedAt': FieldValue.serverTimestamp(),
      },
    );
    debugPrint(
        'UPLOAD FIRESTORE STATE UPDATE COMPLETE: subject=$subjectId document=$documentId status=$status');
  }

  String _normalizedDocumentState(Object? value) {
    switch (value?.toString()) {
      case 'queued':
      case 'pending':
        return 'pending';
      case 'uploading':
        return 'uploading';
      case 'uploaded':
      case 'extracting':
      case 'indexing':
      case 'processing':
        return 'processing';
      case 'indexed':
        return 'indexed';
      case 'failed':
      case 'upload_error':
      case 'index_error':
      case 'cancelled':
        return 'failed';
      case 'deleting':
        return 'deleting';
      case 'deleted':
        return 'deleted';
      default:
        return 'pending';
    }
  }

  bool _isAllowedDocumentTransition(String from, String to) {
    if (from == to) return true;
    if (to == 'failed') return from != 'deleted';
    if (to == 'deleting') return from != 'deleted';
    return switch (from) {
      'pending' => to == 'uploading',
      'uploading' => to == 'processing',
      'processing' => to == 'indexed',
      'failed' => to == 'uploading' || to == 'processing',
      'indexed' => to == 'processing' || to == 'uploading',
      'deleting' => to == 'deleted',
      _ => false,
    };
  }

  Future<void> _transitionDocumentState(
    DocumentReference<Map<String, dynamic>> reference,
    String nextStatus,
    Map<String, dynamic> updates,
  ) async {
    final next = _normalizedDocumentState(nextStatus);
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(reference);
      if (!snapshot.exists) throw StateError('Document is not available.');
      final current = _normalizedDocumentState(snapshot.data()?['status']);
      if (!_isAllowedDocumentTransition(current, next)) {
        throw StateError(
            'Invalid document state transition: $current -> $next.');
      }
      transaction.update(reference, updates);
    });
  }

  Future<void> renameSubject(String subjectId, String name) async {
    final clean = name.trim();
    if (clean.isEmpty) throw ArgumentError('Subject name is required.');
    final uid = currentUserId;
    if (uid == null) throw StateError('Sign in to rename a subject.');
    final subjectRef = _subjectsCol.doc(subjectId);
    final subject =
        await subjectRef.get(const GetOptions(source: Source.server));
    if (subject.data()?['ownerId'] != uid) {
      throw StateError('Subject is not available.');
    }
    await subjectRef.update({
      'name': clean,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await Future.wait([
      _subjectDocumentsCol(subjectId).get().then((s) => Future.wait(
          s.docs.map((d) => d.reference.update({'subject': clean})))),
      _knowledgeCol
          .where('ownerId', isEqualTo: uid)
          .where('subjectId', isEqualTo: subjectId)
          .get()
          .then((s) => Future.wait(
              s.docs.map((d) => d.reference.update({'subject': clean})))),
    ]);
  }

  Future<void> deleteSubject(String subjectId, {String? operationId}) async {
    final uid = currentUserId;
    if (uid == null) throw StateError('Sign in to delete a subject.');
    final subjectRef = _subjectsCol.doc(subjectId);
    final subject =
        await subjectRef.get(const GetOptions(source: Source.server));
    if (subject.data()?['ownerId'] != uid) {
      throw StateError('Subject is not available.');
    }
    final snapshots = await Future.wait([
      _subjectDocumentsCol(subjectId)
          .get(const GetOptions(source: Source.server)),
      _knowledgeCol
          .where('ownerId', isEqualTo: uid)
          .get(const GetOptions(source: Source.server)),
      _chatSessionsCol
          .where('ownerId', isEqualTo: uid)
          .get(const GetOptions(source: Source.server)),
      _usersCol
          .doc(uid)
          .collection('generation_cache')
          .get(const GetOptions(source: Source.server)),
      _subjectTopicsCol(subjectId).get(const GetOptions(source: Source.server)),
    ]);
    final docs = snapshots[0].docs;
    final knowledge = snapshots[1].docs;
    final topics = snapshots[4].docs;
    final subtopicSnapshots = await Future.wait(topics.map((topic) =>
        _topicSubtopicsCol(subjectId, topic.id)
            .get(const GetOptions(source: Source.server))));
    final hierarchyRefs = <DocumentReference<Map<String, dynamic>>>[
      for (final subtopics in subtopicSnapshots)
        ...subtopics.docs.map((subtopic) => subtopic.reference),
      ...topics.map((topic) => topic.reference),
    ];
    final folderIds = <String>{
      for (final item in knowledge)
        if (item.data()['kind'] == 'folder' &&
            (item.data()['subjectId'] == subjectId ||
                item.data()['parentId'] == subjectId))
          item.id,
    };
    var changed = true;
    while (changed) {
      changed = false;
      for (final item in knowledge) {
        if (item.data()['kind'] == 'folder' &&
            folderIds.contains(item.data()['parentId']) &&
            folderIds.add(item.id)) changed = true;
      }
    }
    final subjectDocs = docs;
    final documentIds = subjectDocs.map((doc) => doc.id).toSet();
    final subjectItems = knowledge.where((item) {
      final data = item.data();
      return data['subjectId'] == subjectId ||
          folderIds.contains(item.id) ||
          folderIds.contains(data['parentId']) ||
          folderIds.contains(data['folderId']) ||
          documentIds.contains(data['sourceId']);
    }).toList();
    final sessions = snapshots[2].docs.where((session) =>
        session.data()['subjectId'] == subjectId ||
        folderIds.contains(session.data()['folderId']) ||
        folderIds.contains(session.data()['subjectId']) ||
        documentIds.contains(session.data()['documentId']));
    await Future.wait(sessions.map((session) async {
      await _deleteCollection(session.reference.collection('messages'));
      await session.reference.delete();
    }));
    final staleCache = snapshots[3].docs.where((cache) {
      final data = cache.data();
      final result = data['result'];
      final sources = result is Map ? result['sources'] : null;
      return data['scopeId'] == subjectId ||
          (sources is List &&
              sources.any((source) =>
                  source is Map && documentIds.contains(source['id'])));
    });
    await _deleteSubjectDocumentsWithStorageQueue(
      subjectDocs: subjectDocs,
      ownerId: uid,
      subjectId: subjectId,
      operationId: operationId,
    );
    await _deleteDocuments([
      ...subjectItems.map((item) => item.reference),
      ...staleCache.map((cache) => cache.reference),
      ...hierarchyRefs,
    ]);
    final user = await _usersCol.doc(uid).get();
    final batch = _firestore.batch();
    batch.set(
        _usersCol.doc(uid),
        {
          'documentsUploaded': FieldValue.increment(-subjectDocs.length),
          if (user.data()?['activeSubjectId'] == subjectId)
            'activeSubjectId': '',
        },
        SetOptions(merge: true));
    batch.delete(subjectRef);
    await batch.commit();
  }

  // ── Topic & Subtopic Management ─────────────────────────────────────────────

  /// Stream all topics for a subject
  Stream<List<Map<String, dynamic>>> streamSubjectTopics(String subjectId) {
    return _subjectTopicsCol(subjectId).orderBy('order').snapshots().map(
        (snapshot) =>
            snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList());
  }

  /// Stream all subtopics for a topic in display order.
  Stream<List<Map<String, dynamic>>> streamSubtopics(
      String subjectId, String topicId) {
    return _topicSubtopicsCol(subjectId, topicId)
        .orderBy('order')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList());
  }

  /// Get all topics with their subtopics
  Future<List<Map<String, dynamic>>> getSubjectTopicsWithSubtopics(
      String subjectId) async {
    final uid = currentUserId;
    if (uid == null) return const [];

    final subject = await _subjectsCol
        .doc(subjectId)
        .get(const GetOptions(source: Source.server));
    if (subject.data()?['ownerId'] != uid) return const [];

    final topicsSnapshot =
        await _subjectTopicsCol(subjectId).orderBy('order').get();

    final topics = <Map<String, dynamic>>[];
    for (final topicDoc in topicsSnapshot.docs) {
      final subtopicsSnapshot = await _topicSubtopicsCol(subjectId, topicDoc.id)
          .orderBy('order')
          .get();

      topics.add({
        'id': topicDoc.id,
        ...topicDoc.data(),
        'subtopics': subtopicsSnapshot.docs
            .map((doc) => {'id': doc.id, ...doc.data()})
            .toList(),
      });
    }

    return topics;
  }

  /// Loads the current subject syllabus and its manual notes for AI study
  /// tools. Notes remain in the knowledge collection and are joined through
  /// their subject/topic/subtopic IDs.
  Future<Map<String, dynamic>?> loadSubjectStudyHierarchy(
      String subjectId) async {
    final uid = currentUserId;
    final cleanSubjectId = subjectId.trim();
    if (uid == null || cleanSubjectId.isEmpty) return null;

    final snapshots = await Future.wait([
      _subjectsCol.doc(cleanSubjectId).get(),
      _subjectTopicsCol(cleanSubjectId).orderBy('order').get(),
      _knowledgeCol
          .where('ownerId', isEqualTo: uid)
          .where('subjectId', isEqualTo: cleanSubjectId)
          .get(),
    ]);
    final subjectSnapshot =
        snapshots[0] as DocumentSnapshot<Map<String, dynamic>>;
    if (!subjectSnapshot.exists || subjectSnapshot.data()?['ownerId'] != uid) {
      return null;
    }
    final topicSnapshot = snapshots[1] as QuerySnapshot<Map<String, dynamic>>;
    final noteSnapshot = snapshots[2] as QuerySnapshot<Map<String, dynamic>>;
    final subtopicSnapshots = await Future.wait(topicSnapshot.docs.map(
      (topic) =>
          _topicSubtopicsCol(cleanSubjectId, topic.id).orderBy('order').get(),
    ));

    final notes = noteSnapshot.docs
        .where((note) => note.data()['kind'] == 'note')
        .map((note) => <String, dynamic>{
              'id': note.id,
              ...note.data(),
              'content': (note.data()['content'] ?? note.data()['notes'] ?? '')
                  .toString(),
            })
        .toList();
    notes.sort((a, b) {
      final pathA =
          '${a['topicId'] ?? ''}|${a['subtopicId'] ?? ''}|${a['title'] ?? ''}|${a['id']}';
      final pathB =
          '${b['topicId'] ?? ''}|${b['subtopicId'] ?? ''}|${b['title'] ?? ''}|${b['id']}';
      return pathA.compareTo(pathB);
    });

    List<Map<String, dynamic>> notesAt(String topicId, String subtopicId) =>
        notes
            .where((note) =>
                (note['topicId']?.toString() ?? '') == topicId &&
                (note['subtopicId']?.toString() ?? '') == subtopicId)
            .toList(growable: false);

    final topics = <Map<String, dynamic>>[];
    for (var i = 0; i < topicSnapshot.docs.length; i++) {
      final topic = topicSnapshot.docs[i];
      final subtopics = subtopicSnapshots[i]
          .docs
          .map((subtopic) => <String, dynamic>{
                'id': subtopic.id,
                ...subtopic.data(),
                'notes': notesAt(topic.id, subtopic.id),
              })
          .toList(growable: false);
      topics.add({
        'id': topic.id,
        ...topic.data(),
        'notes': notesAt(topic.id, ''),
        'subtopics': subtopics,
      });
    }

    final topicIds = topicSnapshot.docs.map((topic) => topic.id).toSet();
    final subjectNotes = notesAt('', '');
    final unplacedNotes = notes.where((note) {
      final topicId = note['topicId']?.toString() ?? '';
      final subtopicId = note['subtopicId']?.toString() ?? '';
      return topicId.isEmpty
          ? subtopicId.isNotEmpty
          : !topicIds.contains(topicId) || subtopicId.isNotEmpty;
    }).where((note) {
      final topicId = note['topicId']?.toString() ?? '';
      final knownTopic = topicSnapshot.docs.any((topic) => topic.id == topicId);
      final subtopicId = note['subtopicId']?.toString() ?? '';
      final knownSubtopic = subtopicSnapshots.asMap().entries.any((entry) =>
          topicSnapshot.docs[entry.key].id == topicId &&
          entry.value.docs.any((subtopic) => subtopic.id == subtopicId));
      return !knownTopic || (subtopicId.isNotEmpty && !knownSubtopic);
    }).toList(growable: false);

    return {
      'subject': {'id': subjectSnapshot.id, ...subjectSnapshot.data()!},
      'subjectNotes': subjectNotes,
      'topics': topics,
      'unplacedNotes': unplacedNotes,
    };
  }

  /// Create a new topic
  Future<String> createTopic({
    required String subjectId,
    required String name,
  }) async {
    final uid = currentUserId;
    if (uid == null) throw StateError('Sign in to create a topic.');
    final cleanName = name.trim();
    if (subjectId.trim().isEmpty) {
      throw ArgumentError('Subject ID is required.');
    }
    if (cleanName.isEmpty) throw ArgumentError('Topic name is required.');

    final subject = await _subjectsCol.doc(subjectId).get();
    if (subject.data()?['ownerId'] != uid) {
      throw StateError('Subject is not available.');
    }

    // Get current max order
    final existing = await _subjectTopicsCol(subjectId)
        .orderBy('order', descending: true)
        .limit(1)
        .get();

    final order = existing.docs.isEmpty
        ? 0
        : ((existing.docs.first.data()['order'] as num?)?.toInt() ?? 0) + 1;

    final ref = await _subjectTopicsCol(subjectId).add({
      'name': cleanName,
      'order': order,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return ref.id;
  }

  /// Create a new subtopic under a topic
  Future<String> createSubtopic({
    required String subjectId,
    required String topicId,
    required String name,
  }) async {
    final uid = currentUserId;
    if (uid == null) throw StateError('Sign in to create a subtopic.');
    final cleanName = name.trim();
    if (subjectId.trim().isEmpty || topicId.trim().isEmpty) {
      throw ArgumentError('Subject and topic IDs are required.');
    }
    if (cleanName.isEmpty) throw ArgumentError('Subtopic name is required.');

    final subject = await _subjectsCol.doc(subjectId).get();
    if (subject.data()?['ownerId'] != uid) {
      throw StateError('Subject is not available.');
    }

    final topic = await _topicRef(subjectId, topicId)
        .get(const GetOptions(source: Source.server));
    if (!topic.exists) {
      throw StateError('Topic not found.');
    }

    // Get current max order
    final existing = await _topicSubtopicsCol(subjectId, topicId)
        .orderBy('order', descending: true)
        .limit(1)
        .get();

    final order = existing.docs.isEmpty
        ? 0
        : ((existing.docs.first.data()['order'] as num?)?.toInt() ?? 0) + 1;

    final ref = await _topicSubtopicsCol(subjectId, topicId).add({
      'name': cleanName,
      'order': order,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return ref.id;
  }

  /// Update topic name
  Future<void> updateTopicName({
    required String subjectId,
    required String topicId,
    required String name,
  }) async {
    final uid = currentUserId;
    if (uid == null) throw StateError('Sign in to update a topic.');
    final cleanName = name.trim();
    if (cleanName.isEmpty) throw ArgumentError('Topic name is required.');

    final subject = await _subjectsCol.doc(subjectId).get();
    if (subject.data()?['ownerId'] != uid) {
      throw StateError('Subject is not available.');
    }

    await _topicRef(subjectId, topicId).update({
      'name': cleanName,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Update subtopic name
  Future<void> updateSubtopicName({
    required String subjectId,
    required String topicId,
    required String subtopicId,
    required String name,
  }) async {
    final uid = currentUserId;
    if (uid == null) throw StateError('Sign in to update a subtopic.');
    final cleanName = name.trim();
    if (cleanName.isEmpty) throw ArgumentError('Subtopic name is required.');

    final subject = await _subjectsCol.doc(subjectId).get();
    if (subject.data()?['ownerId'] != uid) {
      throw StateError('Subject is not available.');
    }

    await _subtopicRef(subjectId, topicId, subtopicId).update({
      'name': cleanName,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Delete a topic and all its subtopics
  Future<void> deleteTopic({
    required String subjectId,
    required String topicId,
  }) async {
    final uid = currentUserId;
    if (uid == null) throw StateError('Sign in to delete a topic.');

    final subject = await _subjectsCol.doc(subjectId).get();
    if (subject.data()?['ownerId'] != uid) {
      throw StateError('Subject is not available.');
    }

    final topic = await _topicRef(subjectId, topicId).get();
    if (!topic.exists) throw StateError('Topic not found.');

    // Remove the hierarchy references while preserving each document record.
    final subtopics = await _topicSubtopicsCol(subjectId, topicId)
        .get(const GetOptions(source: Source.server));
    final documentSnapshots = await _subjectDocumentsCol(subjectId)
        .get(const GetOptions(source: Source.server));
    final subtopicIds = subtopics.docs.map((doc) => doc.id).toSet();
    final affectedDocuments = documentSnapshots.docs.where((doc) {
      final data = doc.data();
      return data['topicId'] == topicId ||
          ((data['topicId'] == null || data['topicId'] == '') &&
              subtopicIds.contains(data['subtopicId']));
    }).toList();
    final subtopicRefs = subtopics.docs.map((doc) => doc.reference).toList();
    if (affectedDocuments.length + subtopicRefs.length + 1 <= 500) {
      final batch = _firestore.batch();
      for (final doc in affectedDocuments) {
        batch.update(doc.reference, {'topicId': '', 'subtopicId': ''});
      }
      for (final ref in subtopicRefs) {
        batch.delete(ref);
      }
      batch.delete(_topicRef(subjectId, topicId));
      await batch.commit();
      return;
    }
    for (var i = 0; i < affectedDocuments.length; i += 450) {
      final batch = _firestore.batch();
      for (final doc in affectedDocuments.skip(i).take(450)) {
        batch.update(doc.reference, {'topicId': '', 'subtopicId': ''});
      }
      await batch.commit();
    }
    await _deleteDocuments([...subtopicRefs, _topicRef(subjectId, topicId)]);
  }

  /// Delete a subtopic
  Future<void> deleteSubtopic({
    required String subjectId,
    required String topicId,
    required String subtopicId,
  }) async {
    final uid = currentUserId;
    if (uid == null) throw StateError('Sign in to delete a subtopic.');

    final subject = await _subjectsCol
        .doc(subjectId)
        .get(const GetOptions(source: Source.server));
    if (subject.data()?['ownerId'] != uid) {
      throw StateError('Subject is not available.');
    }
    final topic = await _topicRef(subjectId, topicId)
        .get(const GetOptions(source: Source.server));
    if (!topic.exists) throw StateError('Topic not found.');
    final subtopic = await _subtopicRef(subjectId, topicId, subtopicId)
        .get(const GetOptions(source: Source.server));
    if (!subtopic.exists) throw StateError('Subtopic not found.');
    final documents = await _subjectDocumentsCol(subjectId)
        .get(const GetOptions(source: Source.server));
    final affected = documents.docs.where((doc) {
      final data = doc.data();
      return data['subtopicId'] == subtopicId &&
          (data['topicId'] == topicId ||
              data['topicId'] == null ||
              data['topicId'] == '');
    }).toList();
    if (affected.length < 500) {
      final batch = _firestore.batch();
      for (final doc in affected) {
        batch.update(doc.reference, {'subtopicId': ''});
      }
      batch.delete(_subtopicRef(subjectId, topicId, subtopicId));
      await batch.commit();
      return;
    }
    for (var i = 0; i < affected.length; i += 450) {
      final batch = _firestore.batch();
      for (final doc in affected.skip(i).take(450)) {
        batch.update(doc.reference, {'subtopicId': ''});
      }
      await batch.commit();
    }
    await _subtopicRef(subjectId, topicId, subtopicId).delete();
  }

  /// Reorder topics
  Future<void> reorderTopics({
    required String subjectId,
    required List<String> topicIds,
  }) async {
    final uid = currentUserId;
    if (uid == null) throw StateError('Sign in to reorder topics.');
    if (topicIds.toSet().length != topicIds.length ||
        topicIds.any((id) => id.trim().isEmpty)) {
      throw ArgumentError('Topic order must contain unique, non-empty IDs.');
    }

    final subject = await _subjectsCol.doc(subjectId).get();
    if (subject.data()?['ownerId'] != uid) {
      throw StateError('Subject is not available.');
    }

    final topics = await _subjectTopicsCol(subjectId).get();
    final existingIds = topics.docs.map((doc) => doc.id).toSet();
    if (!existingIds.containsAll(topicIds)) {
      throw StateError('A topic was not found.');
    }
    for (var start = 0; start < topicIds.length; start += 450) {
      final batch = _firestore.batch();
      final end = start + 450 < topicIds.length ? start + 450 : topicIds.length;
      for (var i = start; i < end; i++) {
        batch.update(_topicRef(subjectId, topicIds[i]), {
          'order': i,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();
    }
  }

  /// Reorder subtopics
  Future<void> reorderSubtopics({
    required String subjectId,
    required String topicId,
    required List<String> subtopicIds,
  }) async {
    final uid = currentUserId;
    if (uid == null) throw StateError('Sign in to reorder subtopics.');
    if (subtopicIds.toSet().length != subtopicIds.length ||
        subtopicIds.any((id) => id.trim().isEmpty)) {
      throw ArgumentError('Subtopic order must contain unique, non-empty IDs.');
    }

    final subject = await _subjectsCol.doc(subjectId).get();
    if (subject.data()?['ownerId'] != uid) {
      throw StateError('Subject is not available.');
    }

    final topic = await _topicRef(subjectId, topicId).get();
    if (!topic.exists) throw StateError('Topic not found.');
    final subtopics = await _topicSubtopicsCol(subjectId, topicId).get();
    final existingIds = subtopics.docs.map((doc) => doc.id).toSet();
    if (!existingIds.containsAll(subtopicIds)) {
      throw StateError('A subtopic was not found.');
    }
    for (var start = 0; start < subtopicIds.length; start += 450) {
      final batch = _firestore.batch();
      final end =
          start + 450 < subtopicIds.length ? start + 450 : subtopicIds.length;
      for (var i = start; i < end; i++) {
        batch.update(_subtopicRef(subjectId, topicId, subtopicIds[i]), {
          'order': i,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();
    }
  }

  // ── 2. Subject Documents ───────────────────────────────────────────────────

  Future<List<FirestoreDocumentModel>> getSubjectDocuments(
      String subjectId) async {
    final uid = currentUserId;
    if (uid == null) return const [];
    final subject = await _subjectsCol.doc(subjectId).get();
    if (subject.data()?['ownerId'] != uid) return const [];
    final documents = await _subjectDocumentsCol(subjectId).get();
    return documents.docs
        .map((doc) => FirestoreDocumentModel.fromMap({
              ...doc.data(),
              'ownerId': doc.data()['ownerId'] ?? uid,
              'subjectId': subjectId,
            }, doc.id))
        .toList();
  }

  Future<List<Map<String, dynamic>>> loadKnowledge({
    String? ownerId,
    String? subjectId,
    List<String> sourceIds = const [],
  }) async {
    final uid = ownerId ?? currentUserId;
    if (uid == null) return const [];
    if (subjectId != null && subjectId.isNotEmpty) {
      final subject = await _subjectsCol.doc(subjectId).get();
      if (subject.data()?['ownerId'] != uid) return const [];
    }
    late final List<Map<String, dynamic>> documents;
    late final List<Map<String, dynamic>> notes;
    if (sourceIds.isEmpty && subjectId != null && subjectId.isNotEmpty) {
      final root = await Future.wait([
        _subjectDocumentsCol(subjectId).get(),
        _knowledgeCol
            .where('ownerId', isEqualTo: uid)
            .where('subjectId', isEqualTo: subjectId)
            .get(),
      ]);
      final docMap = <String, Map<String, dynamic>>{
        for (final doc in root[0].docs)
          if (doc.data()['ownerId'] == null || doc.data()['ownerId'] == uid)
            doc.id: {
              'id': doc.id,
              ...doc.data(),
              'ownerId': doc.data()['ownerId'] ?? uid,
              'subjectId': subjectId,
            },
      };
      final noteMap = <String, Map<String, dynamic>>{
        for (final item in root[1].docs)
          if (item.data()['ownerId'] == uid)
            item.id: {'id': item.id, ...item.data()},
      };
      final folderIds = <String>{
        for (final item in noteMap.values)
          if (item['kind'] == 'folder') item['id'].toString(),
      };
      var frontier = Set<String>.from(folderIds);
      while (frontier.isNotEmpty) {
        final children =
            await _queryIn(_knowledgeCol, 'parentId', frontier, ownerId: uid);
        final next = <String>{};
        for (final child in children) {
          if (child.data()['ownerId'] != uid) continue;
          noteMap[child.id] = {'id': child.id, ...child.data()};
          if (child.data()['kind'] == 'folder' && folderIds.add(child.id))
            next.add(child.id);
        }
        frontier = next;
      }
      if (folderIds.isNotEmpty) {
        final nested =
            await _queryIn(_knowledgeCol, 'subjectId', folderIds, ownerId: uid);
        for (final item in nested) {
          if (item.data()['ownerId'] == uid) {
            noteMap[item.id] = {'id': item.id, ...item.data()};
          }
        }
      }
      documents = docMap.values.toList();
      notes = noteMap.values.toList();
    } else if (sourceIds.isEmpty) {
      documents = const [];
      notes = const [];
    } else {
      final selected = await Future.wait(sourceIds.map((id) async {
        final Future<DocumentSnapshot<Map<String, dynamic>>?> documentFuture =
            subjectId != null && subjectId.isNotEmpty
                ? _subjectDocumentRef(subjectId, id).get()
                : Future.value(null);
        final Future<DocumentSnapshot<Map<String, dynamic>>?> noteFuture =
            _knowledgeCol.doc(id).get();
        return Future.wait<DocumentSnapshot<Map<String, dynamic>>?>(
            [documentFuture, noteFuture]);
      }));
      documents = [];
      notes = [];
      for (final pair in selected) {
        final document = pair[0];
        final note = pair[1];
        if (document != null &&
            document.exists &&
            (document.data()?['ownerId'] == null ||
                document.data()?['ownerId'] == uid)) {
          documents.add({
            'id': document.id,
            ...document.data()!,
            'ownerId': document.data()!['ownerId'] ?? uid,
            'subjectId': subjectId,
          });
        }
        if (note != null && note.exists && note.data()?['ownerId'] == uid) {
          notes.add({'id': note.id, ...note.data()!});
        }
      }
    }
    final folderIds = <String>{};
    if (subjectId != null && subjectId.isNotEmpty) {
      folderIds.addAll(notes
          .where((item) =>
              item['kind'] == 'folder' &&
              (item['subjectId'] == subjectId || item['parentId'] == subjectId))
          .map((item) => item['id'] as String));
      var changed = true;
      while (changed) {
        changed = false;
        for (final item in notes) {
          if (item['kind'] == 'folder' &&
              folderIds.contains(item['parentId']) &&
              folderIds.add(item['id'] as String)) changed = true;
        }
      }
    }
    bool inScope(Map<String, dynamic> data, String id) {
      // An explicit source list represents a user's deliberate selection.
      // Ownership was verified while loading those records above.
      if (sourceIds.isNotEmpty) return true;
      if (subjectId != null && subjectId.isNotEmpty) {
        return data['subjectId'] == subjectId ||
            folderIds.contains(data['subjectId']) ||
            folderIds.contains(data['parentId']) ||
            folderIds.contains(data['folderId']) ||
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

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> _queryIn(
      CollectionReference<Map<String, dynamic>> collection,
      String field,
      Iterable<String> values,
      {required String ownerId}) async {
    final unique = values.toSet().toList(growable: false);
    if (unique.isEmpty) return const [];
    final batches = <List<String>>[
      for (var i = 0; i < unique.length; i += 30)
        unique.skip(i).take(30).toList(growable: false),
    ];
    final snapshots = await Future.wait(batches.map((batch) => collection
        .where('ownerId', isEqualTo: ownerId)
        .where(field, whereIn: batch)
        .get()));
    return snapshots.expand((snapshot) => snapshot.docs).toList();
  }

  Future<String> saveKnowledgeNote(
      {required String title,
      required String content,
      String subject = '',
      String subjectId = '',
      String topic = '',
      String topicId = '',
      String subtopic = '',
      String subtopicId = '',
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
      'topicId': topicId,
      'subtopic': subtopic,
      'subtopicId': subtopicId,
      'notes': notes,
      'folderId': folderId,
      'tags': tags,
      'kind': 'note',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  Future<void> updateKnowledgeNote({
    required String noteId,
    required String title,
    required String content,
  }) async {
    final uid = currentUserId;
    if (uid == null) throw StateError('Sign in to update knowledge.');
    final ref = _knowledgeCol.doc(noteId);
    final snapshot = await ref.get();
    final data = snapshot.data();
    if (data == null || data['ownerId'] != uid || data['kind'] != 'note') {
      throw StateError('That note is no longer available.');
    }
    await ref.update({
      'title': title.trim().isEmpty ? 'Note' : title.trim(),
      'content': content.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
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

  Future<void> renameWorkspaceFolder(String folderId, String name) async {
    final uid = currentUserId;
    final clean = name.trim();
    if (uid == null || clean.isEmpty) return;
    final ref = _knowledgeCol.doc(folderId);
    final folder = await ref.get();
    if (folder.data()?['ownerId'] != uid || folder.data()?['kind'] != 'folder')
      return;
    await ref
        .update({'title': clean, 'updatedAt': FieldValue.serverTimestamp()});
    final subjectId = folder.data()?['subjectId']?.toString() ?? '';
    if (subjectId.isEmpty) return;
    final docs = await _subjectDocumentsCol(subjectId)
        .where('folderId', isEqualTo: folderId)
        .get();
    await Future.wait(
        docs.docs.map((d) => d.reference.update({'subject': clean})));
  }

  Future<void> moveDocumentToFolder(String documentId, String folderId,
      {String folderName = ''}) async {
    final uid = currentUserId;
    if (uid == null) return;
    final folder = await _knowledgeCol.doc(folderId).get();
    if (folder.data()?['ownerId'] != uid || folder.data()?['kind'] != 'folder')
      return;
    final subjectId = folder.data()?['subjectId']?.toString() ?? '';
    if (subjectId.isEmpty) return;
    await _subjectDocumentRef(subjectId, documentId).update({
      'folderId': folderId,
      'subjectId': subjectId,
      'subject': folder.data()?['subject'] ?? folderName,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteWorkspaceFolder(String folderId) async {
    final uid = currentUserId;
    if (uid == null) return;
    final ref = _knowledgeCol.doc(folderId);
    final snapshot = await ref.get();
    final data = snapshot.data();
    if (data?['ownerId'] != uid || data?['kind'] != 'folder') return;
    final children = await _knowledgeCol
        .where('ownerId', isEqualTo: uid)
        .where('parentId', isEqualTo: folderId)
        .get();
    for (final child
        in children.docs.where((d) => d.data()['kind'] == 'folder')) {
      await deleteWorkspaceFolder(child.id);
    }
    final subjectId = data?['subjectId']?.toString() ?? '';
    final docs = subjectId.isEmpty
        ? null
        : await _subjectDocumentsCol(subjectId)
            .where('folderId', isEqualTo: folderId)
            .get();
    final documentIds = docs?.docs.map((d) => d.id).toSet() ?? <String>{};
    for (final doc in docs?.docs ?? const []) {
      await doc.reference.update({
        'folderId': '',
        'subjectId': subjectId,
        'subject': data?['subject'] ?? 'General',
      });
    }
    final sessions = await _chatSessionsCol
        .where('ownerId', isEqualTo: uid)
        .where('subjectId', isEqualTo: folderId)
        .get();
    for (final session in sessions.docs) {
      await _deleteCollection(session.reference.collection('messages'));
      await session.reference.delete();
    }
    final cache = await _usersCol.doc(uid).collection('generation_cache').get();
    final stale = cache.docs.where((d) {
      final sources = d.data()['result'] is Map
          ? (d.data()['result'] as Map)['sources']
          : null;
      return sources is List &&
          sources.any((s) => s is Map && documentIds.contains(s['id']));
    });
    await _deleteDocuments(stale.map((d) => d.reference).toList());
    await ref.delete();
  }

  Stream<List<Map<String, dynamic>>> streamWorkspaceItems(String ownerId) =>
      _knowledgeCol.where('ownerId', isEqualTo: ownerId).snapshots().map(
          (snapshot) =>
              snapshot.docs.map((d) => {'id': d.id, ...d.data()}).toList());

  Future<void> saveKnowledgeIndex(String documentId, Map<String, dynamic> index,
      {required String sourceText,
      required String subjectId,
      String sourceKind = 'document',
      String? downloadUrl,
      String? operationId}) async {
    final target = sourceKind == 'note'
        ? _knowledgeCol.doc(documentId)
        : _subjectDocumentRef(subjectId, documentId);
    debugPrint(
        'UPLOAD FIRESTORE FINAL UPDATE START: subject=$subjectId document=$documentId');
    final updates = <String, dynamic>{
      'structuredKnowledge': index,
      'extractedText': sourceText.length > 100000
          ? sourceText.substring(0, 100000)
          : sourceText,
      'indexedAt': FieldValue.serverTimestamp(),
      'status': 'indexed',
      if (operationId != null) 'operationId': operationId,
      if (sourceKind == 'document') 'uploadStatus': 'completed',
      if (sourceKind == 'document') ...{
        'error': FieldValue.delete(),
        'indexError': FieldValue.delete(),
      },
      if (sourceKind == 'document' && downloadUrl != null) ...{
        'downloadUrl': downloadUrl,
        'fileUrl': downloadUrl,
      },
      'updatedAt': FieldValue.serverTimestamp(),
      if (subjectId.isNotEmpty) 'subjectId': subjectId,
      if (sourceKind == 'document') ...{
        'conceptCount': (index['concepts'] as List?)?.length ?? 0,
        if (index['flashcards'] is List)
          'flashcardCount': (index['flashcards'] as List).length,
        if (index['quizzes'] is List)
          'quizCount': (index['quizzes'] as List).length,
      },
    };
    if (sourceKind == 'document') {
      await _transitionDocumentState(target, 'indexed', updates);
    } else {
      await target.update(updates);
    }
    debugPrint(
        'UPLOAD FIRESTORE FINAL UPDATE COMPLETE: subject=$subjectId document=$documentId status=indexed uploadStatus=completed');
  }

  Future<void> saveExtractedText(
          String subjectId, String documentId, String text) =>
      _subjectDocumentRef(subjectId, documentId).update({
        'extractedText':
            text.length > 100000 ? text.substring(0, 100000) : text,
        'updatedAt': FieldValue.serverTimestamp(),
      });

  Future<void> updateDocumentCounts(String subjectId, String documentId,
      {int? concepts, int? flashcards, int? quizzes}) async {
    await _subjectDocumentRef(subjectId, documentId).update({
      if (concepts != null) 'conceptCount': concepts,
      if (flashcards != null) 'flashcardCount': flashcards,
      if (quizzes != null) 'quizCount': quizzes,
    });
  }

  Future<void> renameDocument(
      String subjectId, String documentId, String title) async {
    await _subjectDocumentRef(subjectId, documentId).update({
      'title': title,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> failDocumentPipeline({
    required String subjectId,
    required String documentId,
    required String error,
    bool clearStorageReference = false,
  }) async {
    debugPrint(
        'UPLOAD FIRESTORE FAILURE UPDATE START: subject=$subjectId document=$documentId');
    await _transitionDocumentState(
      _subjectDocumentRef(subjectId, documentId),
      'failed',
      {
        'status': 'failed',
        'uploadStatus': 'failed',
        'error': error,
        'indexError': error,
        if (clearStorageReference) 'downloadUrl': '',
        if (clearStorageReference) 'fileUrl': '',
        'updatedAt': FieldValue.serverTimestamp(),
      },
    );
    debugPrint(
        'UPLOAD FIRESTORE FAILURE UPDATE COMPLETE: subject=$subjectId document=$documentId');
  }

  Future<void> cacheGeneration(String key, Map<String, dynamic> result,
      {String? scopeId}) async {
    final uid = currentUserId;
    if (uid == null) return;
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('generation_cache')
        .doc(key)
        .set({
      'result': result,
      if (scopeId != null && scopeId.isNotEmpty) 'scopeId': scopeId,
      'updatedAt': FieldValue.serverTimestamp()
    });
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

  // ── 2. Subject Documents ───────────────────────────────────────────────────

  /// Permanently delete a document from Firestore and decrement user's count
  Future<String?> deleteDocument({
    required String documentId,
    required String subjectId,
    required String ownerId,
    String? operationId,
  }) async {
    debugPrint(
        '🗑️ [DELETE] Starting deletion for document: $documentId in subject: $subjectId');
    try {
      final documentRef = _subjectDocumentRef(subjectId, documentId);
      debugPrint('🗑️ [DELETE] Document path: ${documentRef.path}');

      final subject = await _subjectsCol.doc(subjectId).get();
      if (subject.data()?['ownerId'] != ownerId) {
        debugPrint('🗑️ [DELETE] ERROR: Subject owner mismatch');
        throw StateError('Subject is not available.');
      }
      debugPrint('🗑️ [DELETE] Subject ownership verified');

      final existing = await documentRef.get();
      if (!existing.exists) {
        debugPrint('🗑️ [DELETE] ERROR: Document does not exist in Firestore');
        throw StateError('Document is not available.');
      }
      if (existing.data()?['ownerId'] != null &&
          existing.data()?['ownerId'] != ownerId) {
        debugPrint('🗑️ [DELETE] ERROR: Document owner mismatch');
        throw StateError('Document is not available.');
      }
      final storagePath = existing.data()?['storagePath']?.toString() ?? '';
      final storageTask =
          storagePath.isEmpty ? null : _storageDeleteQueueCol(ownerId).doc();
      debugPrint('🗑️ [DELETE] Document ownership verified');

      debugPrint(
          '🗑️ [DELETE] Fetching related data (chat sessions, knowledge, cache)...');
      final related = await Future.wait<dynamic>([
        _chatSessionsCol
            .where('ownerId', isEqualTo: ownerId)
            .where('documentId', isEqualTo: documentId)
            .get(),
        _knowledgeCol
            .where('ownerId', isEqualTo: ownerId)
            .where('sourceId', isEqualTo: documentId)
            .get(),
        _usersCol.doc(ownerId).collection('generation_cache').get(),
      ]);
      debugPrint('🗑️ [DELETE] Found ${related[0].docs.length} chat sessions');
      debugPrint(
          '🗑️ [DELETE] Found ${related[1].docs.length} knowledge items');
      debugPrint('🗑️ [DELETE] Found ${related[2].docs.length} cache entries');

      debugPrint('🗑️ [DELETE] Creating batch delete for main document...');
      final batch = _firestore.batch();
      batch.delete(documentRef);
      if (storageTask != null) {
        batch.set(storageTask, {
          'storagePath': storagePath,
          'operationId': operationId ??
              'delete_${documentId}_${DateTime.now().microsecondsSinceEpoch}',
          'subjectId': subjectId,
          'documentId': documentId,
          'reason': 'document_delete',
          'attempts': 0,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      batch.set(
        _usersCol.doc(ownerId),
        {'documentsUploaded': FieldValue.increment(-1)},
        SetOptions(merge: true),
      );

      debugPrint('🗑️ [DELETE] Committing batch delete...');
      await batch.commit();
      debugPrint('🗑️ [DELETE] ✅ Main document deleted from Firestore');

      debugPrint('🗑️ [DELETE] Deleting related chat sessions...');
      for (final session in related[0].docs) {
        await _deleteCollection(session.reference.collection('messages'));
        await session.reference.delete();
      }
      debugPrint('🗑️ [DELETE] ✅ Chat sessions deleted');

      debugPrint('🗑️ [DELETE] Deleting knowledge items...');
      await _deleteDocuments(related[1].docs.map((d) => d.reference).toList());
      debugPrint('🗑️ [DELETE] ✅ Knowledge items deleted');

      debugPrint('🗑️ [DELETE] Filtering stale cache entries...');
      final staleCache = related[2].docs.where((d) {
        final result = d.data()['result'];
        if (result is! Map || result['sources'] is! List) return false;
        return d.data()['scopeId'] == subjectId ||
            (result['sources'] as List)
                .any((s) => s is Map && s['id'] == documentId);
      });
      debugPrint('🗑️ [DELETE] Found ${staleCache.length} stale cache entries');
      await _deleteDocuments(staleCache.map((d) => d.reference).toList());
      debugPrint('🗑️ [DELETE] ✅ Cache entries deleted');

      debugPrint('🗑️ [DELETE] ✅✅✅ DOCUMENT DELETION COMPLETE: $documentId');
      return storageTask?.id;
    } catch (e, stackTrace) {
      debugPrint('🗑️ [DELETE] ❌ ERROR during deletion: $e');
      debugPrint('🗑️ [DELETE] Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Update the lastOpened timestamp on a document
  Future<void> updateLastOpened(String subjectId, String documentId) async {
    try {
      await _subjectDocumentRef(subjectId, documentId).update({
        'lastOpened': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      debugPrint('FirestoreService.updateLastOpened error: $e');
    }
  }

  /// Streams documents from each subject's documents subcollection.
  Stream<List<FirestoreDocumentModel>> streamUserDocuments(String ownerId) {
    debugPrint('📡 [STREAM] Creating document stream for user: $ownerId');
    late final StreamController<List<FirestoreDocumentModel>> controller;
    StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? subjectsListener;
    final documentListeners =
        <String, StreamSubscription<QuerySnapshot<Map<String, dynamic>>>>{};
    final documentListenerTokens = <String, Object>{};
    final bySubject = <String, List<FirestoreDocumentModel>>{};
    var subjectEvents = Future<void>.value();

    void emitDocuments() {
      if (controller.isClosed) return;
      final documents = bySubject.values.expand((items) => items).toList()
        ..sort((a, b) => b.uploadedAt.compareTo(a.uploadedAt));

      // Log document counts per subject
      debugPrint('📡 [STREAM] Emitting ${documents.length} total documents');
      for (final entry in bySubject.entries) {
        debugPrint(
            '📡 [STREAM]   Subject ${entry.key}: ${entry.value.length} docs');
      }

      controller.add(documents);
    }

    controller = StreamController<List<FirestoreDocumentModel>>(
      onListen: () {
        debugPrint('📡 [STREAM] Stream listener attached');
        subjectsListener = _subjectsCol
            .where('ownerId', isEqualTo: ownerId)
            .snapshots()
            .listen((subjects) {
          subjectEvents = subjectEvents.then((_) async {
            if (!controller.hasListener) return;
            debugPrint(
                '📡 [STREAM] Subjects snapshot received: ${subjects.docs.length} subjects');
            final subjectIds =
                subjects.docs.map((subject) => subject.id).toSet();
            for (final removedId in documentListeners.keys
                .where((id) => !subjectIds.contains(id))
                .toList()) {
              debugPrint(
                  '📡 [STREAM] Removing listener for deleted subject: $removedId');
              final listener = documentListeners.remove(removedId);
              documentListenerTokens.remove(removedId);
              bySubject.remove(removedId);
              if (listener != null) {
                await listener.cancel();
              }
            }
            if (!controller.hasListener) return;
            for (final subjectId in subjectIds) {
              if (documentListeners.containsKey(subjectId)) continue;
              debugPrint(
                  '📡 [STREAM] Creating document listener for subject: $subjectId');
              final listenerToken = Object();
              documentListenerTokens[subjectId] = listenerToken;
              documentListeners[subjectId] = _subjectDocumentsCol(subjectId)
                  .snapshots()
                  .listen((snapshot) {
                if (controller.isClosed ||
                    !identical(
                        documentListenerTokens[subjectId], listenerToken)) {
                  return;
                }
                debugPrint(
                    '📡 [STREAM] Documents snapshot for subject $subjectId: ${snapshot.docs.length} docs in Firestore');

                final filteredDocs = snapshot.docs
                    .where((doc) =>
                        doc.data()['ownerId'] == null ||
                        doc.data()['ownerId'] == ownerId)
                    .toList();

                debugPrint(
                    '📡 [STREAM] After owner filter: ${filteredDocs.length} docs');

                bySubject[subjectId] = filteredDocs
                    .map((doc) => FirestoreDocumentModel.fromMap({
                          ...doc.data(),
                          'ownerId': doc.data()['ownerId'] ?? ownerId,
                          'subjectId': subjectId,
                        }, doc.id))
                    .toList();
                emitDocuments();
              }, onError: (error, stackTrace) {
                if (controller.isClosed ||
                    !identical(
                        documentListenerTokens[subjectId], listenerToken)) {
                  return;
                }
                debugPrint(
                    '📡 [STREAM] ❌ Error in document stream for subject $subjectId: $error');
                controller.addError(error, stackTrace);
              });
            }
            emitDocuments();
          }).catchError((Object error, StackTrace stackTrace) {
            if (!controller.isClosed) controller.addError(error, stackTrace);
          });
        }, onError: (error, stackTrace) {
          debugPrint('📡 [STREAM] ❌ Error in subjects stream: $error');
          controller.addError(error, stackTrace);
        });
      },
      onCancel: () async {
        debugPrint('📡 [STREAM] Cancelling all listeners');
        documentListenerTokens.clear();
        await subjectsListener?.cancel();
        await subjectEvents;
        await Future.wait(
            documentListeners.values.map((listener) => listener.cancel()));
        documentListeners.clear();
        bySubject.clear();
        await controller.close();
      },
    );
    return controller.stream;
  }

  Future<void> recoverStaleUploads({
    Duration staleAfter = const Duration(minutes: 10),
  }) async {
    final uid = currentUserId;
    if (uid == null) return;
    try {
      await processPendingDeletes();
    } catch (error) {
      debugPrint('BACKEND_DELETE status=queued_retry_incomplete error=$error');
    }
    final cutoff = DateTime.now().subtract(staleAfter);
    final subjects = await _subjectsCol
        .where('ownerId', isEqualTo: uid)
        .get(const GetOptions(source: Source.server));
    final snapshots = await Future.wait(subjects.docs.map((subject) =>
        _subjectDocumentsCol(subject.id)
            .get(const GetOptions(source: Source.server))));
    final sourceIds = <String>{};
    final subjectIds = subjects.docs.map((subject) => subject.id).toSet();
    for (var index = 0; index < subjects.docs.length; index++) {
      final subjectId = subjects.docs[index].id;
      sourceIds.addAll(snapshots[index].docs.map((document) => document.id));
      await _repairHierarchyReferences(
        subjectId,
        snapshots[index].docs,
      );
    }
    final knowledge =
        await _knowledgeCol.where('ownerId', isEqualTo: uid).get();
    sourceIds.addAll(knowledge.docs.map((item) => item.id));
    await _removeOrphanGenerationCaches(uid, subjectIds, sourceIds);
    final completedRepairs =
        <(String, QueryDocumentSnapshot<Map<String, dynamic>>)>[];
    final stale = <(String, QueryDocumentSnapshot<Map<String, dynamic>>)>[];
    for (var index = 0; index < subjects.docs.length; index++) {
      final subjectId = subjects.docs[index].id;
      for (final document in snapshots[index].docs) {
        final data = document.data();
        final uploadStatus = data['uploadStatus']?.toString() ?? '';
        if (data['status'] == 'indexed') {
          if (uploadStatus != 'completed') {
            completedRepairs.add((subjectId, document));
          }
          continue;
        }
        if (!const {'queued', 'uploading', 'uploaded'}.contains(uploadStatus)) {
          continue;
        }
        final value = data['updatedAt'] ??
            data['uploadStartedAt'] ??
            data['createdAt'] ??
            data['uploadedAt'];
        final started = value is Timestamp ? value.toDate() : null;
        if (started == null || started.isBefore(cutoff)) {
          stale.add((subjectId, document));
        }
      }
    }
    final repairs = <Future<void> Function()>[
      for (final (subjectId, document) in completedRepairs)
        () => updateDocumentPipelineState(
              subjectId: subjectId,
              documentId: document.id,
              status: 'indexed',
              uploadStatus: 'completed',
            ),
      for (final (subjectId, document) in stale)
        () => failDocumentPipeline(
              subjectId: subjectId,
              documentId: document.id,
              error: 'Upload processing did not finish. Please retry.',
            ),
    ];
    for (var offset = 0; offset < repairs.length; offset += 200) {
      await Future.wait(
          repairs.skip(offset).take(200).map((repair) => repair()));
    }
  }

  Future<void> _repairHierarchyReferences(
    String subjectId,
    List<QueryDocumentSnapshot<Map<String, dynamic>>> documents,
  ) async {
    final topics = await _subjectTopicsCol(subjectId)
        .get(const GetOptions(source: Source.server));
    final topicIds = topics.docs.map((topic) => topic.id).toSet();
    final subtopicSnapshots = await Future.wait(topics.docs.map((topic) =>
        _topicSubtopicsCol(subjectId, topic.id)
            .get(const GetOptions(source: Source.server))));
    final subtopicIdsByTopic = <String, Set<String>>{
      for (var i = 0; i < topics.docs.length; i++)
        topics.docs[i].id:
            subtopicSnapshots[i].docs.map((doc) => doc.id).toSet(),
    };
    final repairs = <QueryDocumentSnapshot<Map<String, dynamic>>>[];
    for (final document in documents) {
      final data = document.data();
      final topicId = data['topicId']?.toString() ?? '';
      final subtopicId = data['subtopicId']?.toString() ?? '';
      if (topicId.isEmpty) {
        if (subtopicId.isNotEmpty) repairs.add(document);
        continue;
      }
      if (!topicIds.contains(topicId) ||
          (subtopicId.isNotEmpty &&
              !subtopicIdsByTopic[topicId]!.contains(subtopicId))) {
        repairs.add(document);
      }
    }
    for (var offset = 0; offset < repairs.length; offset += 450) {
      final batch = _firestore.batch();
      for (final document in repairs.skip(offset).take(450)) {
        final data = document.data();
        final topicId = data['topicId']?.toString() ?? '';
        final validTopic = topicIds.contains(topicId);
        batch.update(document.reference, {
          if (!validTopic) 'topicId': '',
          'subtopicId': '',
        });
      }
      await batch.commit();
    }
  }

  Future<void> _removeOrphanGenerationCaches(
    String uid,
    Set<String> subjectIds,
    Set<String> sourceIds,
  ) async {
    final cache = await _usersCol
        .doc(uid)
        .collection('generation_cache')
        .get(const GetOptions(source: Source.server));
    final orphaned = cache.docs.where((document) {
      final data = document.data();
      final scopeId = data['scopeId']?.toString() ?? '';
      if (scopeId.isNotEmpty && !subjectIds.contains(scopeId)) return true;
      final result = data['result'];
      final sources = result is Map ? result['sources'] : null;
      if (sources is! List) return false;
      return sources.any((source) {
        if (source is! Map) return false;
        final sourceId = source['id']?.toString() ?? '';
        return sourceId.isNotEmpty && !sourceIds.contains(sourceId);
      });
    });
    await _deleteDocuments(
        orphaned.map((document) => document.reference).toList());
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

  Future<void> _deleteSubjectDocumentsWithStorageQueue({
    required List<QueryDocumentSnapshot<Map<String, dynamic>>> subjectDocs,
    required String ownerId,
    required String subjectId,
    String? operationId,
  }) async {
    for (var offset = 0; offset < subjectDocs.length; offset += 200) {
      final chunk = subjectDocs.skip(offset).take(200).toList();
      Object? lastError;
      for (var attempt = 1; attempt <= 3; attempt++) {
        try {
          final batch = _firestore.batch();
          for (final document in chunk) {
            final data = document.data();
            final storagePath = data['storagePath']?.toString() ?? '';
            batch.delete(document.reference);
            if (storagePath.isNotEmpty) {
              final task = _storageDeleteQueueCol(ownerId)
                  .doc('${subjectId}_${document.id}');
              batch.set(task, {
                'storagePath': storagePath,
                'operationId':
                    operationId ?? 'subject_delete_${subjectId}_${document.id}',
                'subjectId': subjectId,
                'documentId': document.id,
                'reason': 'subject_delete',
                'attempts': 0,
                'createdAt': FieldValue.serverTimestamp(),
              });
            }
          }
          await batch.commit();
          lastError = null;
          break;
        } catch (error) {
          lastError = error;
          debugPrint(
              'BACKEND_DELETE operationId=subject_delete_$subjectId chunk=${offset ~/ 200 + 1} attempt=$attempt status=retry error=$error');
          if (attempt < 3) {
            await Future<void>.delayed(Duration(milliseconds: 300 * attempt));
          }
        }
      }
      if (lastError != null) {
        Error.throwWithStackTrace(lastError, StackTrace.current);
      }
    }
  }

  Future<void> _deleteDocuments(
    List<DocumentReference<Map<String, dynamic>>> refs, {
    String operationId = '',
    String subjectId = '',
    String documentId = '',
    void Function(int completed, int total)? onProgress,
  }) async {
    if (refs.isEmpty) return;
    final uid = currentUserId;
    final chunks = <List<DocumentReference<Map<String, dynamic>>>>[];
    for (var i = 0; i < refs.length; i += 450) {
      chunks.add(refs.skip(i).take(450).toList());
    }
    var completed = 0;
    Object? firstFailure;
    final deleteOperationId = operationId.isEmpty
        ? 'delete_${DateTime.now().microsecondsSinceEpoch}'
        : operationId;
    for (var index = 0; index < chunks.length; index++) {
      final chunk = chunks[index];
      var chunkCompleted = false;
      if (uid == null) {
        try {
          await _commitDeleteChunk(chunk, null, deleteOperationId, index + 1);
          chunkCompleted = true;
        } catch (error) {
          firstFailure ??= error;
        }
      } else {
        final taskRef = _deleteQueueCol(uid).doc();
        try {
          await taskRef.set({
            'operationId': deleteOperationId,
            'subjectId': subjectId,
            'documentId': documentId,
            'paths': chunk.map((ref) => ref.path).toList(),
            'chunk': index + 1,
            'chunkCount': chunks.length,
            'createdAt': FieldValue.serverTimestamp(),
            'attempts': 0,
          });
          await _commitDeleteChunk(
              chunk, taskRef, deleteOperationId, index + 1);
          chunkCompleted = true;
        } catch (error) {
          firstFailure ??= error;
        }
      }
      if (chunkCompleted) completed += chunk.length;
      onProgress?.call(completed, refs.length);
      debugPrint(
          'BACKEND_DELETE operationId=$deleteOperationId subjectId=$subjectId documentId=$documentId status=${firstFailure == null ? 'progress' : 'retry_pending'} progress=$completed/${refs.length} error=${firstFailure ?? ''}');
    }
    if (firstFailure != null) {
      Error.throwWithStackTrace(firstFailure, StackTrace.current);
    }
  }

  Future<void> _commitDeleteChunk(
    List<DocumentReference<Map<String, dynamic>>> refs,
    DocumentReference<Map<String, dynamic>>? taskRef,
    String operationId,
    int chunkNumber,
  ) async {
    Object? lastError;
    for (var attempt = 1; attempt <= 3; attempt++) {
      try {
        final batch = _firestore.batch();
        for (final ref in refs) {
          batch.delete(ref);
        }
        if (taskRef != null) batch.delete(taskRef);
        await batch.commit();
        return;
      } catch (error) {
        lastError = error;
        debugPrint(
            'BACKEND_DELETE operationId=$operationId chunk=$chunkNumber attempt=$attempt status=retry error=$error');
        if (attempt < 3) {
          await Future<void>.delayed(Duration(milliseconds: 300 * attempt));
        }
      }
    }
    if (taskRef != null) {
      try {
        await taskRef.set({
          'attempts': 3,
          'lastError': lastError.toString(),
          'lastAttemptAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } catch (queueError) {
        debugPrint(
            'BACKEND_DELETE operationId=$operationId status=queue_update_failed error=$queueError');
      }
    }
    Error.throwWithStackTrace(lastError!, StackTrace.current);
  }

  /// Retries persisted deletion chunks after a transient failure or restart.
  Future<void> processPendingDeletes({int limit = 50}) async {
    final uid = currentUserId;
    if (uid == null) return;
    Object? firstFailure;
    QueryDocumentSnapshot<Map<String, dynamic>>? cursor;
    while (true) {
      var query = _deleteQueueCol(uid).orderBy('createdAt');
      if (cursor != null) query = query.startAfterDocument(cursor);
      final tasks = await query.limit(limit).get();
      if (tasks.docs.isEmpty) break;
      for (final task in tasks.docs) {
        final data = task.data();
        final paths = data['paths'];
        if (paths is! List ||
            paths.length > 450 ||
            paths.any((path) => path is! String)) {
          firstFailure ??=
              StateError('Invalid persisted deletion task ${task.id}.');
          continue;
        }
        final refs = paths.cast<String>().map(_firestore.doc).toList();
        try {
          await _commitDeleteChunk(
            refs,
            task.reference,
            data['operationId']?.toString() ?? task.id,
            (data['chunk'] as num?)?.toInt() ?? 0,
          );
        } catch (error) {
          firstFailure ??= error;
        }
      }
      cursor = tasks.docs.last;
      if (tasks.docs.length < limit) break;
    }
    if (firstFailure != null) {
      Error.throwWithStackTrace(firstFailure, StackTrace.current);
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
