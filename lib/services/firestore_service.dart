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
  static final Map<String, Future<void>> _legacyMigrationTasks = {};
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

  CollectionReference<Map<String, dynamic>> get _legacyDocumentsCol =>
      _firestore.collection('documents');

  CollectionReference<Map<String, dynamic>> get _chatSessionsCol =>
      _firestore.collection('chat_sessions');

  CollectionReference<Map<String, dynamic>> get _studyProgressCol =>
      _firestore.collection('study_progress');

  CollectionReference<Map<String, dynamic>> get _knowledgeCol =>
      _firestore.collection('knowledge_items');

  CollectionReference<Map<String, dynamic>> get _subjectsCol =>
      _firestore.collection('subjects');

  CollectionReference<Map<String, dynamic>> _subjectDocumentsCol(
          String subjectId) =>
      _subjectsCol.doc(subjectId).collection('documents');

  DocumentReference<Map<String, dynamic>> _subjectDocumentRef(
          String subjectId, String documentId) =>
      _subjectDocumentsCol(subjectId).doc(documentId);

  /// Subjects are user-owned workspace roots. Legacy text-only subject names
  /// remain readable while new uploads use stable subject IDs.
  Stream<List<Map<String, dynamic>>> streamSubjects(String ownerId) =>
      Stream<void>.fromFuture(migrateLegacyRootDocuments(ownerId)).asyncExpand(
        (_) => _subjectsCol
            .where('ownerId', isEqualTo: ownerId)
            .snapshots()
            .map((snapshot) => snapshot.docs
                .map((d) => {'id': d.id, ...d.data()})
                .toList()),
      );

  /// Moves existing root-level document records into their owning subject.
  /// All ongoing reads and writes use subjects/{subjectId}/documents.
  Future<void> migrateLegacyRootDocuments([String? ownerId]) async {
    final uid = ownerId ?? currentUserId;
    if (uid == null) return;
    final active = _legacyMigrationTasks[uid];
    if (active != null) {
      await active;
      return;
    }
    final task = _migrateLegacyRootDocuments(uid);
    _legacyMigrationTasks[uid] = task;
    try {
      await task;
    } finally {
      if (identical(_legacyMigrationTasks[uid], task)) {
        _legacyMigrationTasks.remove(uid);
      }
    }
  }

  Future<void> _migrateLegacyRootDocuments(String uid) async {
    final userRef = _usersCol.doc(uid);
    final user = await userRef.get();
    if (user.data()?['legacyDocumentsMigratedAt'] != null) return;

    final legacy = await _legacyDocumentsCol
        .where('ownerId', isEqualTo: uid)
        .get();
    final subjects = await _subjectsCol.where('ownerId', isEqualTo: uid).get();
    final byId = <String, DocumentReference<Map<String, dynamic>>>{
      for (final subject in subjects.docs) subject.id: subject.reference,
    };
    final byName = <String, DocumentReference<Map<String, dynamic>>>{
      for (final subject in subjects.docs)
        (subject.data()['name'] as String? ?? '').trim().toLowerCase():
            subject.reference,
    };

    for (var offset = 0; offset < legacy.docs.length; offset += 150) {
      final batch = _firestore.batch();
      for (final oldDoc in legacy.docs.skip(offset).take(150)) {
        final data = oldDoc.data();
        final subjectName = (data['subject'] as String? ?? 'General').trim();
        var subjectRef = byId[data['subjectId']?.toString() ?? ''];
        subjectRef ??= byName[subjectName.toLowerCase()];
        if (subjectRef == null) {
          subjectRef = _subjectsCol.doc();
          batch.set(subjectRef, {
            'ownerId': uid,
            'name': subjectName.isEmpty ? 'General' : subjectName,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
          byId[subjectRef.id] = subjectRef;
          byName[subjectName.toLowerCase()] = subjectRef;
        }

        final priorStatus = data['status']?.toString() ?? '';
        final priorUploadStatus = data['uploadStatus']?.toString() ?? '';
        final settled = priorStatus == 'indexed' ||
            priorUploadStatus == 'completed';
        final hasStorage =
            (data['downloadUrl'] ?? '').toString().isNotEmpty;
        batch.set(_subjectDocumentRef(subjectRef.id, oldDoc.id), {
          ...data,
          'subjectId': subjectRef.id,
          'status': settled
              ? 'indexed'
              : hasStorage
                  ? 'index_error'
                  : priorUploadStatus == 'cancelled'
                      ? 'cancelled'
                      : 'upload_error',
          'uploadStatus': settled
              ? 'completed'
              : priorUploadStatus == 'cancelled'
                  ? 'cancelled'
                  : 'failed',
          if (!settled)
            'indexError': 'Legacy upload processing did not finish. Please retry.',
          'updatedAt': FieldValue.serverTimestamp(),
        });
        batch.delete(oldDoc.reference);
      }
      await batch.commit();
    }
    await userRef.set({
      'legacyDocumentsMigratedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

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
    await migrateLegacyRootDocuments(uid);
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
    String folderId = '',
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
    await migrateLegacyRootDocuments(uid);
    final subjectSnapshot = await _subjectsCol.doc(subjectId).get();
    if (subjectSnapshot.data()?['ownerId'] != uid) {
      throw StateError('The selected subject is not available.');
    }
    if (folderId.isNotEmpty) {
      final folder = await _knowledgeCol.doc(folderId).get();
      final folderData = folder.data();
      if (folderData?['ownerId'] != uid ||
          folderData?['kind'] != 'folder' ||
          folderData?['subjectId'] != subjectId) {
        throw StateError('The selected folder is not in this subject.');
      }
    }
    final subjectName =
        subjectSnapshot.data()?['name']?.toString() ?? subject;
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
      'folderId': folderId,
      'topic': topic,
      'subtopic': subtopic,
      'notes': notes,
      'tags': tags,
      'indexedAt': null,
      'createdAt': now,
      'updatedAt': now,
    });
    batch.set(_usersCol.doc(uid), {
      'documentsUploaded': FieldValue.increment(1),
      'lastLogin': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    await batch.commit().timeout(const Duration(seconds: 30));
  }

  Future<FirestoreDocumentModel?> getSubjectDocument(
      String subjectId, String documentId) async {
    final uid = currentUserId;
    if (uid == null) return null;
    final snapshot = await _subjectDocumentRef(subjectId, documentId).get();
    final data = snapshot.data();
    if (data == null || data['ownerId'] != uid) return null;
    return FirestoreDocumentModel.fromMap(data, snapshot.id);
  }

  Future<void> updateDocumentPipelineState({
    required String subjectId,
    required String documentId,
    required String status,
    String? uploadStatus,
    String? downloadUrl,
    String? error,
  }) async {
    await _subjectDocumentRef(subjectId, documentId).update({
      'status': status,
      if (uploadStatus != null) 'uploadStatus': uploadStatus,
      if (downloadUrl != null) ...{
        'downloadUrl': downloadUrl,
        'fileUrl': downloadUrl,
      },
      if (error != null) 'indexError': error,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> renameSubject(String subjectId, String name) async {
    final clean = name.trim();
    if (clean.isEmpty) throw ArgumentError('Subject name is required.');
    final uid = currentUserId;
    if (uid == null) throw StateError('Sign in to rename a subject.');
    await migrateLegacyRootDocuments(uid);
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
      _subjectDocumentsCol(subjectId)
          .where('ownerId', isEqualTo: uid)
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
    await migrateLegacyRootDocuments(uid);
    final subjectRef = _subjectsCol.doc(subjectId);
    final subject = await subjectRef.get();
    if (subject.data()?['ownerId'] != uid) {
      throw StateError('Subject is not available.');
    }
    final snapshots = await Future.wait([
      _subjectDocumentsCol(subjectId).where('ownerId', isEqualTo: uid).get(),
      _knowledgeCol.where('ownerId', isEqualTo: uid).get(),
      _chatSessionsCol.where('ownerId', isEqualTo: uid).get(),
      _usersCol.doc(uid).collection('generation_cache').get(),
    ]);
    final docs = snapshots[0].docs;
    final knowledge = snapshots[1].docs;
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
    await _deleteDocuments([
      ...subjectDocs.map((doc) => doc.reference),
      ...subjectItems.map((item) => item.reference),
      ...staleCache.map((cache) => cache.reference),
    ]);
    final user = await _usersCol.doc(uid).get();
    final batch = _firestore.batch();
    batch.set(_usersCol.doc(uid), {
      'documentsUploaded': FieldValue.increment(-subjectDocs.length),
      if (user.data()?['activeSubjectId'] == subjectId) 'activeSubjectId': '',
    }, SetOptions(merge: true));
    batch.delete(subjectRef);
    await batch.commit();
  }

  Future<List<FirestoreDocumentModel>> getSubjectDocuments(
      String subjectId) async {
    final uid = currentUserId;
    if (uid == null) return const [];
    await migrateLegacyRootDocuments(uid);
    final documents = await _subjectDocumentsCol(subjectId)
        .where('ownerId', isEqualTo: uid)
        .get();
    return documents.docs
        .map((doc) => FirestoreDocumentModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<List<Map<String, dynamic>>> loadKnowledge({
    String? ownerId,
    String? subjectId,
    List<String> sourceIds = const [],
  }) async {
    final uid = ownerId ?? currentUserId;
    if (uid == null) return const [];
    await migrateLegacyRootDocuments(uid);
    late final List<Map<String, dynamic>> documents;
    late final List<Map<String, dynamic>> notes;
    if (sourceIds.isEmpty && subjectId != null && subjectId.isNotEmpty) {
      final root = await Future.wait([
        _subjectDocumentsCol(subjectId)
            .where('ownerId', isEqualTo: uid)
            .get(),
        _knowledgeCol
            .where('ownerId', isEqualTo: uid)
            .where('subjectId', isEqualTo: subjectId)
            .get(),
      ]);
      final docMap = <String, Map<String, dynamic>>{
        for (final doc in root[0].docs)
          if (doc.data()['ownerId'] == uid)
            doc.id: {'id': doc.id, ...doc.data()},
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
        final nested = await _queryIn(
            _knowledgeCol, 'subjectId', folderIds,
            ownerId: uid);
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
            document.data()?['ownerId'] == uid) {
          documents.add({'id': document.id, ...document.data()!});
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
        .where('ownerId', isEqualTo: uid)
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
        .where('ownerId', isEqualTo: uid)
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
      String sourceKind = 'document'}) async {
    final target = sourceKind == 'note'
        ? _knowledgeCol.doc(documentId)
        : _subjectDocumentRef(subjectId, documentId);
    await target.update({
      'structuredKnowledge': index,
      'extractedText': sourceText.length > 100000
          ? sourceText.substring(0, 100000)
          : sourceText,
      'indexedAt': FieldValue.serverTimestamp(),
      'status': 'indexed',
      if (sourceKind == 'document') 'uploadStatus': 'completed',
      'updatedAt': FieldValue.serverTimestamp(),
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
    String status = 'index_error',
  }) async {
    await updateDocumentPipelineState(
      subjectId: subjectId,
      documentId: documentId,
      status: status,
      uploadStatus: 'failed',
      error: error,
    );
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
  Future<void> deleteDocument({
    required String documentId,
    required String subjectId,
    required String ownerId,
  }) async {
    try {
      final documentRef = _subjectDocumentRef(subjectId, documentId);
      final existing = await documentRef.get();
      if (existing.data()?['ownerId'] != ownerId) {
        throw StateError('Document is not available.');
      }
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
      final batch = _firestore.batch();
      batch.delete(documentRef);
      batch.set(
        _usersCol.doc(ownerId),
        {'documentsUploaded': FieldValue.increment(-1)},
        SetOptions(merge: true),
      );
      await batch.commit();
      for (final session in related[0].docs) {
        await _deleteCollection(session.reference.collection('messages'));
        await session.reference.delete();
      }
      await _deleteDocuments(
          related[1].docs.map((d) => d.reference).toList());
      final staleCache = related[2].docs.where((d) {
        final result = d.data()['result'];
        if (result is! Map || result['sources'] is! List) return false;
        return d.data()['scopeId'] == subjectId ||
            (result['sources'] as List)
            .any((s) => s is Map && s['id'] == documentId);
      });
      await _deleteDocuments(staleCache.map((d) => d.reference).toList());
    } catch (e) {
      debugPrint('FirestoreService.deleteDocument error: $e');
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

  /// Stream of user's uploaded documents
  Stream<List<FirestoreDocumentModel>> streamUserDocuments(String ownerId) {
    return Stream<void>.fromFuture(migrateLegacyRootDocuments(ownerId))
        .asyncExpand((_) => _firestore
            .collectionGroup('documents')
            .where('ownerId', isEqualTo: ownerId)
            .snapshots()
            .map((snapshot) {
              final documents = snapshot.docs
                  .map((doc) =>
                      FirestoreDocumentModel.fromMap(doc.data(), doc.id))
                  .toList();
              documents.sort((a, b) => b.uploadedAt.compareTo(a.uploadedAt));
              return documents;
            }))
        .handleError((e) {
      debugPrint('FirestoreService.streamUserDocuments error: $e');
    });
  }

  Future<void> recoverStaleUploads({
    Duration staleAfter = const Duration(minutes: 10),
  }) async {
    final uid = currentUserId;
    if (uid == null) return;
    await migrateLegacyRootDocuments(uid);
    final snapshot = await _firestore
        .collectionGroup('documents')
        .where('ownerId', isEqualTo: uid)
        .get();
    final cutoff = DateTime.now().subtract(staleAfter);
    final completedRepairs =
        <QueryDocumentSnapshot<Map<String, dynamic>>>[];
    final stale = <QueryDocumentSnapshot<Map<String, dynamic>>>[];
    for (final document in snapshot.docs) {
      final data = document.data();
      final uploadStatus = data['uploadStatus']?.toString() ?? '';
      if (data['status'] == 'indexed') {
        if (uploadStatus != 'completed') completedRepairs.add(document);
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
      if (started == null || started.isBefore(cutoff)) stale.add(document);
    }
    for (var offset = 0;
        offset < completedRepairs.length + stale.length;
        offset += 200) {
      final pending = <Future<void>>[];
      for (final document in completedRepairs.skip(offset).take(200)) {
        final subjectId = document.reference.parent.parent?.id;
        if (subjectId == null) {
          throw StateError('Indexed document is outside a subject.');
        }
        pending.add(updateDocumentPipelineState(
          subjectId: subjectId,
          documentId: document.id,
          status: 'indexed',
          uploadStatus: 'completed',
        ));
      }
      final staleOffset = offset <= completedRepairs.length
          ? 0
          : offset - completedRepairs.length;
      for (final document in stale.skip(staleOffset).take(200 - pending.length)) {
        final subjectId = document.reference.parent.parent?.id;
        if (subjectId == null) {
          throw StateError('Stale document is outside a subject.');
        }
        final hasStorage =
            (document.data()['downloadUrl'] ?? '').toString().isNotEmpty;
        pending.add(failDocumentPipeline(
          subjectId: subjectId,
          documentId: document.id,
          error: 'Upload processing did not finish. Please retry.',
          status: hasStorage ? 'index_error' : 'upload_error',
        ));
      }
      await Future.wait(pending);
    }
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
