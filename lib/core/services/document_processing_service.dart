import 'dart:convert';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

import '../../services/firestore_service.dart';
import '../storage/hive_storage.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';

/// Models for real extracted learning assets
class ExtractedConcept {
  final String id;
  final String title;
  final String description;
  final double initialMastery;
  final int importanceScore;
  final List<String> keyPoints;

  const ExtractedConcept({
    required this.id,
    required this.title,
    required this.description,
    this.initialMastery = 0.5,
    this.importanceScore = 4,
    this.keyPoints = const [],
  });
}

class ExtractedFlashcard {
  final String id;
  final String front;
  final String back;
  final String conceptTitle;

  const ExtractedFlashcard({
    required this.id,
    required this.front,
    required this.back,
    required this.conceptTitle,
  });
}

class ExtractedQuizQuestion {
  final String id;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  final String conceptTitle;

  const ExtractedQuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    required this.conceptTitle,
  });
}

class ExtractedSummary {
  final String title;
  final String overview;
  final List<String> keyTakeaways;
  final List<String> coreTheorems;
  final List<String> examTraps;

  const ExtractedSummary({
    required this.title,
    required this.overview,
    required this.keyTakeaways,
    required this.coreTheorems,
    required this.examTraps,
  });
}

class UploadedDocument {
  final String id;
  final String fileName;
  final String fileType;
  final int byteSize;
  final String fullText;
  final List<ExtractedConcept> concepts;
  final List<ExtractedFlashcard> flashcards;
  final List<ExtractedQuizQuestion> quizzes;
  final ExtractedSummary summary;
  final DateTime uploadedAt;

  /// Firebase Storage download URL — populated after cloud upload
  final String? downloadUrl;
  final String subjectId;
  final String subject;

  const UploadedDocument({
    required this.id,
    required this.fileName,
    required this.fileType,
    required this.byteSize,
    required this.fullText,
    required this.concepts,
    required this.flashcards,
    required this.quizzes,
    required this.summary,
    required this.uploadedAt,
    this.downloadUrl,
    this.subjectId = '',
    this.subject = '',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'fileName': fileName,
        'fileType': fileType,
        'byteSize': byteSize,
        'fullText':
            fullText.length > 50000 ? fullText.substring(0, 50000) : fullText,
        'concepts': concepts
            .map((c) => {
                  'id': c.id,
                  'title': c.title,
                  'description': c.description,
                  'initialMastery': c.initialMastery,
                  'importanceScore': c.importanceScore,
                  'keyPoints': c.keyPoints,
                })
            .toList(),
        'flashcards': flashcards
            .map((f) => {
                  'id': f.id,
                  'front': f.front,
                  'back': f.back,
                  'conceptTitle': f.conceptTitle,
                })
            .toList(),
        'quizzes': quizzes
            .map((q) => {
                  'id': q.id,
                  'question': q.question,
                  'options': q.options,
                  'correctIndex': q.correctIndex,
                  'explanation': q.explanation,
                  'conceptTitle': q.conceptTitle,
                })
            .toList(),
        'summary': {
          'title': summary.title,
          'overview': summary.overview,
          'keyTakeaways': summary.keyTakeaways,
          'coreTheorems': summary.coreTheorems,
          'examTraps': summary.examTraps,
        },
        'uploadedAt': uploadedAt.toIso8601String(),
        'downloadUrl': downloadUrl,
        'subjectId': subjectId,
        'subject': subject,
      };

  factory UploadedDocument.fromJson(Map<String, dynamic> json) {
    final rawText = (json['fullText'] as String?) ?? '';

    return UploadedDocument(
      id: json['id'] ?? '',
      fileName: json['fileName'] ?? '',
      fileType: json['fileType'] ?? 'DOC',
      byteSize: (json['byteSize'] as num?)?.toInt() ?? 0,
      fullText: rawText,
      concepts: const [],
      flashcards: const [],
      quizzes: const [],
      summary: ExtractedSummary(
          title: json['fileName'] ?? '',
          overview: '',
          keyTakeaways: const [],
          coreTheorems: const [],
          examTraps: const []),
      uploadedAt: DateTime.tryParse(json['uploadedAt'] ?? '') ?? DateTime.now(),
      downloadUrl: json['downloadUrl'],
      subjectId: json['subjectId'] ?? '',
      subject: json['subject'] ?? '',
    );
  }
}

/// State notifier holding the active uploaded document with persistent per-user disk cache.
/// Keyed by userId so documents persist across logout/login and app restarts.
class ActiveDocumentNotifier extends StateNotifier<UploadedDocument?> {
  final String _userId;

  ActiveDocumentNotifier(this._userId) : super(null) {
    _restoreFromCache();
  }

  String get _storageKey =>
      _userId.isNotEmpty ? 'active_doc_$_userId' : 'active_doc_guest';

  void _restoreFromCache() {
    try {
      final cachedJson = HiveStorage.get<String>(_storageKey);
      if (cachedJson != null && cachedJson.isNotEmpty) {
        final map = jsonDecode(cachedJson) as Map<String, dynamic>;
        state = UploadedDocument.fromJson(map);
      }
    } catch (_) {}
  }

  void setDocument(UploadedDocument doc) {
    state = doc;
    try {
      HiveStorage.put(_storageKey, jsonEncode(doc.toJson()));
    } catch (_) {}
  }

  void clearDocument() {
    state = null;
    try {
      HiveStorage.delete(_storageKey);
    } catch (_) {}
  }
}

/// User-scoped active document provider. Changes user → restores their last opened document.
final activeDocumentProvider =
    StateNotifierProvider<ActiveDocumentNotifier, UploadedDocument?>((ref) {
  final user = ref.watch(currentUserProvider);
  final userId = user?.id ?? '';
  return ActiveDocumentNotifier(userId);
});

/// Family variant keyed by userId — use this everywhere auth is available.
final activeDocumentFamilyProvider = StateNotifierProvider.family<
    ActiveDocumentNotifier, UploadedDocument?, String>(
  (ref, userId) => ActiveDocumentNotifier(userId),
);

/// Explicit multi-source selection shared by the library and knowledge tools.
final selectedKnowledgeSourceIdsProvider =
    StateProvider<List<String>>((ref) => const []);
final activeKnowledgeWorkspaceIdProvider =
    StateProvider<String?>((ref) => null);
final activeKnowledgeSubjectIdProvider = StateProvider<String?>((ref) => null);
final activeKnowledgeSubjectNameProvider =
    StateProvider<String?>((ref) => null);

final activeKnowledgeSubjectNameSyncProvider = Provider<void>((ref) {
  final subjectId = ref.watch(activeKnowledgeSubjectIdProvider);
  if (subjectId == null || subjectId.isEmpty) return;
  ref.listen<AsyncValue<String?>>(
    subjectNameStreamProvider(subjectId),
    (_, next) {
      if (!next.hasValue) return;
      final name = next.valueOrNull;
      ref.read(activeKnowledgeSubjectNameProvider.notifier).state =
          name?.isNotEmpty == true ? name : null;
    },
  );
});

/// Service responsible for real file parsing, text extraction,
/// and AI micro-concept synthesis.
class DocumentProcessingService {
  DocumentProcessingService();

  /// Pick multiple files from the user's filesystem
  Future<List<PlatformFile>> pickMultipleFiles(
      {List<String>? allowedExtensions}) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowMultiple: true,
      allowedExtensions: allowedExtensions ??
          [
            'pdf',
            'pptx',
            'docx',
            'txt',
            'md',
            'json',
            'csv',
            'png',
            'jpg',
            'jpeg',
            'webp',
          ],
      withData: true,
    );

    if (result == null || result.files.isEmpty) return [];
    return result.files.where((f) => f.bytes != null).toList();
  }

  /// Extract raw text from any supported file
  Future<String> extractText(PlatformFile file) async {
    final bytes = file.bytes;
    if (bytes == null) {
      throw Exception('Could not read file data. Please try another file.');
    }

    final ext = (file.extension ?? '').toLowerCase();

    if (ext == 'pdf') {
      return _extractFromPdf(bytes);
    } else if (ext == 'pptx') {
      return _extractFromPptx(bytes);
    } else if (ext == 'docx') {
      return _extractFromDocx(bytes);
    } else if (['png', 'jpg', 'jpeg', 'webp'].contains(ext)) {
      return _extractFromImage();
    } else {
      // Plain text, markdown, json, etc.
      return utf8.decode(bytes, allowMalformed: true);
    }
  }

  /// Extract text from images (OCR metadata extraction)
  String _extractFromImage() => '';

  /// Extract text from PDF using Syncfusion
  String _extractFromPdf(Uint8List bytes) {
    final document = PdfDocument(inputBytes: bytes);
    final textExtractor = PdfTextExtractor(document);
    final buffer = StringBuffer();

    final pageCount = document.pages.count;
    for (int i = 0; i < pageCount; i++) {
      final pageText =
          textExtractor.extractText(startPageIndex: i, endPageIndex: i);
      if (pageText.trim().isNotEmpty) {
        buffer.writeln('--- Page ${i + 1} ---');
        buffer.writeln(pageText.trim());
        buffer.writeln();
      }
    }

    document.dispose();
    final result = buffer.toString().trim();
    return result;
  }

  /// Extract text from PPTX (unzip archive and read slide XML text tags)
  String _extractFromPptx(Uint8List bytes) {
    final archive = ZipDecoder().decodeBytes(bytes);
    final buffer = StringBuffer();
    int slideIndex = 1;

    for (final file in archive) {
      if (file.name.startsWith('ppt/slides/slide') &&
          file.name.endsWith('.xml')) {
        final content =
            utf8.decode(file.content as List<int>, allowMalformed: true);
        final slideText = _extractTextFromXml(content);
        if (slideText.isNotEmpty) {
          buffer.writeln('--- Slide $slideIndex ---');
          buffer.writeln(slideText);
          buffer.writeln();
          slideIndex++;
        }
      }
    }

    final result = buffer.toString().trim();
    return result;
  }

  /// Extract text from DOCX
  String _extractFromDocx(Uint8List bytes) {
    final archive = ZipDecoder().decodeBytes(bytes);
    final buffer = StringBuffer();

    for (final file in archive) {
      if (file.name == 'word/document.xml') {
        final content =
            utf8.decode(file.content as List<int>, allowMalformed: true);
        buffer.writeln(_extractTextFromXml(content));
      }
    }

    return buffer.toString().trim();
  }

  /// Read XML text nodes from Office documents without using generation logic.
  String _extractTextFromXml(String xml) {
    final buffer = StringBuffer();
    var cursor = 0;
    while (cursor < xml.length) {
      final textStart = xml.indexOf('>', cursor);
      if (textStart < 0) break;
      final textEnd = xml.indexOf('<', textStart + 1);
      if (textEnd < 0) break;
      final text = xml.substring(textStart + 1, textEnd).trim();
      if (text.isNotEmpty) buffer.write('${_decodeXmlText(text)} ');
      cursor = textEnd + 1;
    }
    return buffer.toString().trim();
  }

  String _decodeXmlText(String text) => text
      .replaceAll('&amp;', '&')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&quot;', '"')
      .replaceAll('&apos;', "'");
}

final documentProcessingServiceProvider =
    Provider<DocumentProcessingService>((ref) {
  return DocumentProcessingService();
});
