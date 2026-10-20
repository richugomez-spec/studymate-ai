import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const int kMaxFileSizeBytes = 50 * 1024 * 1024;

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

/// Storage-only adapter. Firestore state and the complete upload lifecycle are
/// coordinated by KnowledgeEngine through FirestoreService.
class FirebaseUploadService {
  final FirebaseStorage _storage;

  FirebaseUploadService({FirebaseStorage? storage})
      : _storage = storage ?? FirebaseStorage.instance;

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

  Future<String> uploadToStorage(
    PlatformFile file, {
    required String userId,
    required String storagePath,
    void Function(double)? onProgress,
  }) async {
    validateFile(file);
    final bytes = file.bytes;
    if (bytes == null) {
      throw StateError('Could not read file bytes. Please re-select the file.');
    }

    StreamSubscription<TaskSnapshot>? progressSubscription;
    final extension = (file.extension ?? 'bin').toLowerCase();
    final task = _storage.ref(storagePath).putData(
          bytes,
          SettableMetadata(contentType: _mimeType(extension), customMetadata: {
            'originalName': file.name,
            'uploadedBy': userId,
            'uploadedAt': DateTime.now().toIso8601String(),
          }),
        );
    try {
      progressSubscription = task.snapshotEvents.listen(
        (snapshot) {
          if (snapshot.totalBytes > 0) {
            onProgress?.call(snapshot.bytesTransferred / snapshot.totalBytes);
          }
        },
        onError: (Object error, StackTrace stackTrace) {
          debugPrint('Storage progress stream error: $error');
        },
      );
      final snapshot = await task.timeout(
        const Duration(minutes: 5),
        onTimeout: () async {
          await task.cancel().timeout(const Duration(seconds: 5));
          throw TimeoutException('Storage upload timed out.');
        },
      );
      return await snapshot.ref
          .getDownloadURL()
          .timeout(const Duration(seconds: 30));
    } finally {
      await progressSubscription?.cancel().timeout(const Duration(seconds: 5));
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

final firebaseUploadServiceProvider = Provider<FirebaseUploadService>((ref) {
  return FirebaseUploadService();
});
