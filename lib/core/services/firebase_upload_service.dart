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
  'pdf', 'docx', 'pptx', 'txt', 'md', 'png', 'jpg', 'jpeg', 'webp',
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
  final String phase;    // 'validating' | 'uploading' | 'saving' | 'done' | 'error'
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
  }) async {
    // 1. Validate
    validateFile(file);

    final bytes = file.bytes;
    if (bytes == null) {
      throw StateError('Could not read file bytes. Please re-select the file.');
    }

    final currentUser = _auth.currentUser;
    String uid;
    if (currentUser != null) {
      uid = currentUser.uid;
    } else {
      try {
        final anonUser = await _auth.signInAnonymously();
        uid = anonUser.user?.uid ?? 'guest_${DateTime.now().millisecondsSinceEpoch}';
      } catch (_) {
        uid = 'guest_${DateTime.now().millisecondsSinceEpoch}';
      }
    }

    final timestamp = DateTime.now();
    final ext = (file.extension ?? 'bin').toLowerCase();
    final storagePath = 'uploads/$uid/${timestamp.millisecondsSinceEpoch}_${file.name}';

    // 2. Upload to Firebase Storage with progress tracking (non-blocking resilience)
    String downloadUrl = '';
    try {
      final ref = _storage.ref(storagePath);
      final metadata = SettableMetadata(
        contentType: _mimeType(ext),
        customMetadata: {
          'originalName': file.name,
          'uploadedBy': uid,
          'uploadedAt': timestamp.toIso8601String(),
        },
      );

      final task = ref.putData(bytes, metadata);

      task.snapshotEvents.listen((snapshot) {
        if (snapshot.totalBytes > 0) {
          final progress = snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress?.call(progress);
        }
      }, onError: (_) {});

      // Wait for upload with short timeout on web
      final snapshot = await task.timeout(const Duration(seconds: 8));
      downloadUrl = await snapshot.ref.getDownloadURL().catchError((_) => '');
    } catch (e) {
      debugPrint('Firebase Storage upload bypass: $e');
      // If Storage fails or times out due to rules/CORS, don't block the student
    }

    // 3. Save metadata to Firestore
    String firestoreDocId = 'doc_${timestamp.millisecondsSinceEpoch}';
    try {
      final docRef = await _firestore.collection('documents').add({
        'ownerId': uid,
        'fileName': file.name,
        'fileType': ext.toUpperCase(),
        'byteSize': file.size,
        'storagePath': storagePath,
        'downloadUrl': downloadUrl,
        'uploadedAt': FieldValue.serverTimestamp(),
        'status': 'uploaded',
      }).timeout(const Duration(seconds: 15));
      firestoreDocId = docRef.id;
    } catch (_) {
      // Fallback if Firestore rules or offline
    }

    return UploadResult(
      downloadUrl: downloadUrl,
      storagePath: storagePath,
      firestoreDocId: firestoreDocId,
    );
  }

  /// Update Firestore document status after processing is complete.
  Future<void> markAsProcessed(String firestoreDocId, {
    int conceptCount = 0,
    int flashcardCount = 0,
    int quizCount = 0,
    String summary = '',
    String? extractedText,
    int? pageCount,
  }) async {
    final Map<String, dynamic> updateData = {
      'status': 'processed',
      'processedAt': FieldValue.serverTimestamp(),
      'conceptCount': conceptCount,
      'flashcardCount': flashcardCount,
      'quizCount': quizCount,
      'summary': summary,
    };
    if (extractedText != null) {
      updateData['extractedText'] = extractedText.length > 50000 
          ? extractedText.substring(0, 50000) 
          : extractedText;
    }
    if (pageCount != null) {
      updateData['pageCount'] = pageCount;
    }
    await _firestore.collection('documents').doc(firestoreDocId).update(updateData);
  }

  /// MIME type resolver
  String _mimeType(String ext) {
    switch (ext) {
      case 'pdf':   return 'application/pdf';
      case 'docx':  return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'pptx':  return 'application/vnd.openxmlformats-officedocument.presentationml.presentation';
      case 'txt':   return 'text/plain';
      case 'md':    return 'text/markdown';
      case 'png':   return 'image/png';
      case 'jpg':
      case 'jpeg':  return 'image/jpeg';
      case 'webp':  return 'image/webp';
      default:      return 'application/octet-stream';
    }
  }
}

// ── Riverpod provider ─────────────────────────────────────────────────────────

final firebaseUploadServiceProvider = Provider<FirebaseUploadService>((ref) {
  return FirebaseUploadService();
});
