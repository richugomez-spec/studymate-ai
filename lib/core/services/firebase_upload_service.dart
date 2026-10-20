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
    late final UploadTask task;
    try {
      debugPrint('UPLOAD STORAGE TASK CREATE START: $storagePath');
      task = _storage.ref(storagePath).putData(
            bytes,
            SettableMetadata(
              contentType: _mimeType(extension),
              customMetadata: {
                'originalName': file.name,
                'uploadedBy': userId,
                'uploadedAt': DateTime.now().toIso8601String(),
              },
            ),
          );
      debugPrint('UPLOAD STORAGE TASK CREATE COMPLETE: $storagePath');
      progressSubscription = task.snapshotEvents.listen(
        (snapshot) {
          if (snapshot.totalBytes > 0) {
            onProgress?.call(snapshot.bytesTransferred / snapshot.totalBytes);
          }
        },
        onError: (Object error, StackTrace stackTrace) {
          debugPrint('Storage progress stream error: $error');
          debugPrintStack(stackTrace: stackTrace);
        },
      );
      debugPrint('UPLOAD STORAGE TASK WAIT START: $storagePath');
      final snapshot = await task.timeout(
        const Duration(minutes: 5),
        onTimeout: () async {
          debugPrint('UPLOAD STORAGE TIMEOUT; CANCEL START: $storagePath');
          try {
            await task.cancel();
            debugPrint('UPLOAD STORAGE TIMEOUT; CANCEL COMPLETE: $storagePath');
          } catch (error, stackTrace) {
            debugPrint('UPLOAD STORAGE TIMEOUT; CANCEL FAILED: $error');
            debugPrintStack(stackTrace: stackTrace);
            rethrow;
          }
          throw TimeoutException('Storage upload timed out.');
        },
      );
      debugPrint('UPLOAD STORAGE TASK COMPLETE: $storagePath');
      debugPrint('UPLOAD DOWNLOAD URL FETCH START: $storagePath');
      final downloadUrl = await snapshot.ref
          .getDownloadURL()
          .timeout(const Duration(seconds: 30));
      debugPrint('UPLOAD DOWNLOAD URL FETCH COMPLETE: $storagePath');
      debugPrint(
          'UPLOAD DOWNLOAD URL RECEIVED: $storagePath (${downloadUrl.length} chars)');
      return downloadUrl;
    } catch (error, stackTrace) {
      debugPrint('UPLOAD STORAGE FAILED: $storagePath: $error');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    } finally {
      if (progressSubscription != null) {
        debugPrint(
            'UPLOAD STORAGE PROGRESS LISTENER CANCEL START: $storagePath');
        try {
          await progressSubscription.cancel().timeout(
                const Duration(seconds: 5),
              );
          debugPrint(
              'UPLOAD STORAGE PROGRESS LISTENER CANCEL COMPLETE: $storagePath');
        } catch (error, stackTrace) {
          debugPrint('UPLOAD STORAGE PROGRESS LISTENER CANCEL FAILED: $error');
          debugPrintStack(stackTrace: stackTrace);
          rethrow;
        }
      }
    }
  }

  Future<Uint8List> downloadDocument(String storagePath) async {
    debugPrint('SOURCE STORAGE DOWNLOAD START: $storagePath');
    final data = await _storage.ref(storagePath).getData(kMaxFileSizeBytes);
    if (data == null) throw StateError('Document could not be downloaded.');
    debugPrint('SOURCE STORAGE DOWNLOAD COMPLETE: $storagePath');
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
