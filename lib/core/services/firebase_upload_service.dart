import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── Constants ────────────────────────────────────────────────────────────────

/// Maximum allowed file size: 50 MB
const int kMaxFileSizeBytes = 50 * 1024 * 1024;

/// Supported file extensions
const Set<String> kSupportedExtensions = {
  'pdf',
  'docx',
  'pptx',
  'txt',
  'md',
  'png',
  'jpg',
  'jpeg',
  'webp',
  'json',
  'csv',
};

// ── Result model ─────────────────────────────────────────────────────────────

class UploadResult {
  final String downloadUrl;
  final String storagePath;
  final String firestoreDocId;

  const UploadResult({
    required this.downloadUrl,
    required this.storagePath,
    required this.firestoreDocId,
  });
}

// ── Upload progress state ─────────────────────────────────────────────────────

class UploadProgress {
  final double progress; // 0.0 → 1.0
  final String
      phase; // 'validating' | 'uploading' | 'saving' | 'done' | 'error'
  final String? error;

  const UploadProgress({
    required this.progress,
    required this.phase,
    this.error,
  });

  bool get isDone => phase == 'done';
  bool get isError => phase == 'error';
}

// ── Service ──────────────────────────────────────────────────────────────────

class FirebaseUploadService {
  final FirebaseStorage _storage;
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  FirebaseUploadService({
    FirebaseStorage? storage,
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _storage = storage ?? FirebaseStorage.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  /// Validate file type and size before uploading.
  /// Throws [ArgumentError] if validation fails.
  void validateFile(PlatformFile file) {
    final ext = (file.extension ?? '').toLowerCase();

    if (!kSupportedExtensions.contains(ext)) {
      throw ArgumentError(
        'File type ".$ext" is not supported. '
        'Allowed types: ${kSupportedExtensions.map((e) => '.$e').join(', ')}',
      );
    }

    if (file.size > kMaxFileSizeBytes) {
      final mb = (file.size / (1024 * 1024)).toStringAsFixed(1);
      throw ArgumentError(
        'File is too large ($mb MB). Maximum allowed size is 50 MB.',
      );
    }
  }

  /// Upload file to Firebase Storage and save metadata to Firestore.
  /// [onProgress] is called with progress from 0.0 → 1.0 during upload.
  /// Returns [UploadResult] with the download URL and document ID.
  Future<UploadResult> uploadFile(
    PlatformFile file, {
    void Function(double)? onProgress,
    String subject = 'General',
    String subjectId = '',
    String folderId = '',
    String topic = '',
    String subtopic = '',
    String notes = '',
    List<String> tags = const [],
  }) async {
    // 1. Validate
    validateFile(file);

    final bytes = file.bytes;
    if (bytes == null) {
      throw StateError('Could not read file bytes. Please re-select the file.');
    }

    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw StateError('Sign in to upload sources to your workspace.');
    }

    final timestamp = DateTime.now();
    final ext = (file.extension ?? 'bin').toLowerCase();
    final docRef = _firestore.collection('documents').doc();
    final storagePath =
        'uploads/$uid/${timestamp.millisecondsSinceEpoch}_${docRef.id}_${file.name}';

    // Persist the source record before starting the Storage transfer.
    try {
      await docRef.set({
        'title': file.name,
        'ownerId': uid,
        'fileName': file.name,
        'fileType': ext.toUpperCase(),
        'byteSize': file.size,
        'storagePath': storagePath,
        'downloadUrl': '',
        'uploadedAt': FieldValue.serverTimestamp(),
        'status': 'queued',
        'uploadStatus': 'queued',
        'subject': subject,
        'subjectId': subjectId,
        'folderId': folderId,
        'topic': topic,
        'subtopic': subtopic,
        'notes': notes,
        'tags': tags,
        'indexedAt': null,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }).timeout(const Duration(seconds: 20));
      await _firestore.collection('users').doc(uid).set({
        'documentsUploaded': FieldValue.increment(1),
        'lastLogin': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true)).timeout(const Duration(seconds: 20));
      final downloadUrl = await _uploadInBackground(
        bytes: bytes,
        uid: uid,
        fileName: file.name,
        ext: ext,
        storagePath: storagePath,
        documentId: docRef.id,
        uploadedAt: timestamp,
        onProgress: onProgress,
      );
      return UploadResult(
        downloadUrl: downloadUrl,
        storagePath: storagePath,
        firestoreDocId: docRef.id,
      );
    } catch (_) {
      await _markUploadFailed(docRef.id, 'upload_error');
      rethrow;
    }
  }

  Future<String> _uploadInBackground(
      {required Uint8List bytes,
      required String uid,
      required String fileName,
      required String ext,
      required String storagePath,
      required String documentId,
      required DateTime uploadedAt,
      void Function(double)? onProgress}) async {
    StreamSubscription<TaskSnapshot>? progressSubscription;
    try {
      await _firestore.collection('documents').doc(documentId).update({
        'uploadStatus': 'uploading',
        'status': 'uploading',
        'updatedAt': FieldValue.serverTimestamp(),
        'uploadStartedAt': FieldValue.serverTimestamp(),
      });
      final ref = _storage.ref(storagePath);
      final task = ref.putData(
          bytes,
          SettableMetadata(contentType: _mimeType(ext), customMetadata: {
            'originalName': fileName,
            'uploadedBy': uid,
            'uploadedAt': uploadedAt.toIso8601String(),
          }));
      progressSubscription = task.snapshotEvents.listen((snapshot) {
        if (snapshot.totalBytes > 0) {
          onProgress?.call(snapshot.bytesTransferred / snapshot.totalBytes);
        }
      }, onError: (_) {});
      final snapshot =
          await task.timeout(const Duration(minutes: 5), onTimeout: () async {
        await task.cancel().timeout(const Duration(seconds: 5));
        throw TimeoutException('Storage upload timed out.');
      });
      final url = await snapshot.ref
          .getDownloadURL()
          .timeout(const Duration(seconds: 30));
      await _firestore.collection('documents').doc(documentId).update({
        'downloadUrl': url,
        'fileUrl': url,
        'status': 'processing',
        'updatedAt': FieldValue.serverTimestamp(),
      }).timeout(const Duration(seconds: 30));
      return url;
    } catch (error) {
      final cancelled = error is FirebaseException && error.code == 'canceled';
      await _markUploadFailed(
          documentId, cancelled ? 'cancelled' : 'upload_error',
          uploadStatus: cancelled ? 'cancelled' : 'failed');
      debugPrint('Background upload failed: $error');
      rethrow;
    } finally {
      try {
        await progressSubscription
            ?.cancel()
            .timeout(const Duration(seconds: 5));
      } catch (error) {
        debugPrint('Upload progress listener did not close cleanly: $error');
      }
    }
  }

  Future<void> retryUpload(
    PlatformFile file, {
    required String documentId,
    required String storagePath,
  }) async {
    validateFile(file);
    final bytes = file.bytes;
    final uid = currentUserId;
    if (bytes == null || uid == null) {
      throw StateError('The selected file could not be uploaded.');
    }
    await _uploadInBackground(
      bytes: bytes,
      uid: uid,
      fileName: file.name,
      ext: (file.extension ?? '').toLowerCase(),
      storagePath: storagePath,
      documentId: documentId,
      uploadedAt: DateTime.now(),
    );
  }

  Future<void> recoverStaleUploads(
      {Duration staleAfter = const Duration(minutes: 10)}) async {
    final uid = currentUserId;
    if (uid == null) return;
    final snapshot = await _firestore
        .collection('documents')
        .where('ownerId', isEqualTo: uid)
        .where('uploadStatus',
            whereIn: const ['queued', 'uploading', 'uploaded']).get();
    final cutoff = DateTime.now().subtract(staleAfter);
    final completed = snapshot.docs.where((doc) =>
        doc.data()['status'] == 'indexed' &&
        doc.data()['uploadStatus'] != 'completed');
    final completedDocs = completed.toList();
    for (var i = 0; i < completedDocs.length; i += 450) {
      final batch = _firestore.batch();
      for (final doc in completedDocs.skip(i).take(450)) {
        batch.update(doc.reference, {
          'uploadStatus': 'completed',
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();
    }
    final stale = snapshot.docs.where((doc) {
      final data = doc.data();
      if (data['status'] == 'indexed' ||
          data['uploadStatus'] == 'completed' ||
          data['uploadStatus'] == 'failed' ||
          data['uploadStatus'] == 'cancelled') return false;
      if (!const {'queued', 'uploading', 'uploaded'}
          .contains(data['uploadStatus'])) {
        return false;
      }
      final value = data['updatedAt'] ??
          data['uploadStartedAt'] ??
          data['createdAt'] ??
          data['uploadedAt'];
      final started = value is Timestamp ? value.toDate() : null;
      return started != null && started.isBefore(cutoff);
    }).toList();
    for (var i = 0; i < stale.length; i += 450) {
      final batch = _firestore.batch();
      for (final doc in stale.skip(i).take(450)) {
        final storageComplete =
            (doc.data()['downloadUrl'] ?? '').toString().isNotEmpty;
        batch.update(doc.reference, {
          'uploadStatus': 'failed',
          'status': storageComplete ? 'index_error' : 'upload_error',
          'indexError': 'Upload processing did not finish. Please retry.',
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();
    }
  }

  Future<void> _markUploadFailed(String documentId, String status,
      {String uploadStatus = 'failed'}) async {
    try {
      await _firestore.collection('documents').doc(documentId).update({
        'uploadStatus': uploadStatus,
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      }).timeout(const Duration(seconds: 15));
    } catch (error) {
      debugPrint('Could not persist failed upload state: $error');
    }
  }

  Future<Uint8List> downloadDocument(String storagePath) async {
    final data = await _storage.ref(storagePath).getData(kMaxFileSizeBytes);
    if (data == null) throw StateError('Document could not be downloaded.');
    return data;
  }

  Future<void> deleteStoredDocument(String storagePath) async {
    if (storagePath.isEmpty) return;
    await _storage.ref(storagePath).delete();
  }

  /// MIME type resolver
  String _mimeType(String ext) {
    switch (ext) {
      case 'pdf':
        return 'application/pdf';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'pptx':
        return 'application/vnd.openxmlformats-officedocument.presentationml.presentation';
      case 'txt':
        return 'text/plain';
      case 'md':
        return 'text/markdown';
      case 'json':
        return 'application/json';
      case 'csv':
        return 'text/csv';
      case 'png':
        return 'image/png';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'webp':
        return 'image/webp';
      default:
        return 'application/octet-stream';
    }
  }
}

// ── Riverpod provider ─────────────────────────────────────────────────────────

final firebaseUploadServiceProvider = Provider<FirebaseUploadService>((ref) {
  return FirebaseUploadService();
});
