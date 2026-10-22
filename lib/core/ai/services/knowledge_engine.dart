import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show debugPrint, debugPrintStack;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/firestore_service.dart';
import '../../services/document_processing_service.dart';
import '../../services/firebase_upload_service.dart';
import '../ai_config.dart';
import '../ai_message.dart';
import '../providers/gemini_provider.dart';
import 'gemini_api_key_provider.dart';
import 'web_search_service.dart';

/// The single Gemini reasoning path for all StudyMate knowledge tools.
class KnowledgeEngine {
  KnowledgeEngine(this._ref);
  final Ref _ref;
  static final Map<String, Future<Map<String, dynamic>>> _inFlight = {};
  static final Map<String, Future<List<Map<String, dynamic>>>> _contextCache =
      {};

  static void invalidateSubjectContext(String? subjectId, {String? ownerId}) {
    if (subjectId == null || subjectId.isEmpty) {
      if (ownerId == null) {
        _contextCache.clear();
      } else {
        _contextCache.removeWhere((key, _) => key.startsWith('$ownerId|'));
      }
      return;
    }
    final prefix = '${ownerId ?? ''}|$subjectId|';
    _contextCache.removeWhere((key, _) => key.startsWith(prefix));
  }

  Future<List<Map<String, dynamic>>> _loadContext(
    FirestoreService firestore, {
    String? subjectId,
    required List<String> sourceIds,
  }) async {
    final ownerId = firestore.currentUserId ?? 'guest';
    final selection = List<String>.from(sourceIds)..sort();
    final key = '$ownerId|${subjectId ?? ''}|${selection.join(',')}';
    final pending = _contextCache[key];
    if (pending != null) return pending;
    final load = firestore.loadKnowledge(
      subjectId: subjectId,
      sourceIds: sourceIds,
    );
    _contextCache[key] = load;
    try {
      return await load;
    } catch (_) {
      if (identical(_contextCache[key], load)) _contextCache.remove(key);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> generate({
    required String task,
    required String prompt,
    String? topicId,
    String? subjectId,
    List<String> sourceIds = const [],
    bool forceRefresh = false,
    Map<String, dynamic> options = const {},
  }) async {
    final firestore = _ref.read(firestoreServiceProvider);
    final scopedIds = sourceIds.isNotEmpty
        ? sourceIds
        : subjectId != null && subjectId.isNotEmpty
            ? const <String>[]
            : (topicId != null && topicId.contains(',')
                ? topicId
                    .split(',')
                    .map((id) => id.trim())
                    .where((id) => id.isNotEmpty)
                    .toList()
                : const <String>[]);
    final records = await _loadContext(firestore,
        subjectId: subjectId, sourceIds: scopedIds);
    final relevant = _prioritize(records,
        subjectId != null && subjectId.isNotEmpty ? null : topicId, prompt,
        sourceIds: scopedIds,
        includeAll:
            subjectId != null && subjectId.isNotEmpty && scopedIds.isEmpty);
    final sourceSignature = relevant
        .map((r) => '${r['id']}:${r['updatedAt']}:${r['indexedAt']}')
        .join('|');
    final dateSignature = _needsWeb(prompt, relevant)
        ? DateTime.now().toIso8601String().substring(0, 10)
        : '';
    final cacheKey = _stableKey(
      '${firestore.currentUserId ?? 'guest'}|${task.toLowerCase()}|${subjectId ?? ''}|${subjectId != null && subjectId.isNotEmpty ? subjectId : topicId ?? ''}|${scopedIds.join(',')}|${prompt.trim()}|${jsonEncode(options)}|$sourceSignature|$dateSignature',
    );
    final cached =
        forceRefresh ? null : await firestore.getGenerationCache(cacheKey);
    if (cached != null) {
      await _updateSourceCounts(firestore, task, topicId, subjectId, cached);
      return cached;
    }

    final pending = _inFlight[cacheKey];
    if (pending != null) return pending;
    final generation = _generateAndCache(
      firestore: firestore,
      cacheKey: cacheKey,
      task: task,
      prompt: prompt,
      options: options,
      topicId: topicId,
      subjectId: subjectId,
      scopeId: subjectId ?? topicId,
      sources: relevant,
    );
    _inFlight[cacheKey] = generation;
    try {
      return await generation;
    } finally {
      if (identical(_inFlight[cacheKey], generation)) {
        _inFlight.remove(cacheKey);
      }
    }
  }

  Future<Map<String, dynamic>> _generateAndCache({
    required FirestoreService firestore,
    required String cacheKey,
    required String task,
    required String prompt,
    required Map<String, dynamic> options,
    required String? topicId,
    required String? subjectId,
    required String? scopeId,
    required List<Map<String, dynamic>> sources,
  }) async {
    final webResults = _needsWeb(prompt, sources)
        ? await _ref
            .read(webSearchServiceProvider)
            .search(prompt)
            .catchError((_) => <Map<String, String>>[])
        : const <Map<String, String>>[];

    final context = _rankedContexts(sources, prompt);
    final webContext = webResults
        .map((r) => '[web: ${r['title']} | ${r['url']}]\n${r['snippet']}')
        .join('\n\n');
    final request = AIRequest(messages: [
      AIMessage(
          role: AIRole.system,
          content:
              'You are StudyMate, an expert study tutor. The model is responsible for every answer. Treat documents and notes only as reference context: synthesize an original answer, never reproduce paragraphs, OCR text, or source passages. Use web results when present for current facts. Do not mention internal tools, models, retries, source routing, or whether any source was used. If evidence is incomplete, explain the uncertainty naturally. Return one valid JSON object with no markdown fences.'),
      AIMessage(
          role: AIRole.user,
          content:
              'Task: $task\nRequest: $prompt\nOptions: ${jsonEncode(options)}\nSources (user notes, indexed concepts, uploaded documents, then web results):\n${[
            context,
            webContext
          ].where((s) => s.isNotEmpty).join('\n\n').isEmpty ? '(No source material found. Use general knowledge and identify that limitation in your response.)' : [
                  context,
                  webContext
                ].where((s) => s.isNotEmpty).join('\n\n')}'),
    ]);
    final response = await _completeWithFailover(request, temperature: 0.4);
    final raw = response.content
        .trim()
        .replaceFirst(RegExp(r'^```(?:json)?\s*'), '')
        .replaceFirst(RegExp(r'\s*```$'), '');
    final result = Map<String, dynamic>.from(jsonDecode(raw) as Map);
    result['sources'] = [
      ...sources.map((r) => {
            'id': r['id'],
            'title': r['title'] ?? r['fileName'],
            'kind': r['kind']
          }),
      ...webResults
          .map((r) => {'title': r['title'], 'url': r['url'], 'kind': 'web'}),
    ];
    await firestore.cacheGeneration(cacheKey, result, scopeId: scopeId);
    await _updateSourceCounts(firestore, task, topicId, subjectId, result);
    return result;
  }

  Future<void> _updateSourceCounts(
    FirestoreService firestore,
    String task,
    String? topicId,
    String? subjectId,
    Map<String, dynamic> result,
  ) async {
    if (topicId == null ||
        subjectId == null ||
        subjectId.isEmpty ||
        topicId.isEmpty ||
        topicId == 'current' ||
        topicId.contains(',')) return;
    if (task == 'flashcards') {
      final cards = result['cards'];
      if (cards is List) {
        await firestore.updateDocumentCounts(subjectId, topicId,
            flashcards: cards.length);
      }
    } else if (task == 'quiz') {
      final questions = result['questions'];
      if (questions is List) {
        await firestore.updateDocumentCounts(subjectId, topicId,
            quizzes: questions.length);
      }
    }
  }

  Future<Map<String, dynamic>> index({
    required String sourceId,
    required String title,
    required String content,
    String sourceKind = 'document',
    String subject = '',
    String subjectId = '',
    String topic = '',
    String subtopic = '',
    Uint8List? sourceBytes,
    String? mimeType,
    String? downloadUrl,
    void Function()? onGenerated,
  }) async {
    if (content.trim().isEmpty && sourceBytes == null) {
      throw StateError('No readable text was found in this source.');
    }
    final structured = await _uploadStage(
      'AI INDEX GENERATION',
      () => _generateUncached(
        task: 'index_knowledge',
        prompt:
            'Index this source as structured knowledge. Extract concepts, definitions, relationships, formulas, examples, important facts, and exam points. Include sourceConfidence as a decimal from 0 to 1 based on source clarity and completeness. Do not create flashcards, quizzes, or summaries.',
        sourceText: content,
        metadata: {
          'title': title,
          'subject': subject,
          'topic': topic,
          'subtopic': subtopic
        },
        sourceBytes: content.trim().isEmpty ? sourceBytes : null,
        mimeType: mimeType,
      ),
    );
    onGenerated?.call();
    final firestore = _ref.read(firestoreServiceProvider);
    await _uploadStage(
      'FIRESTORE INDEX UPDATE',
      () => firestore.saveKnowledgeIndex(
        sourceId,
        structured,
        sourceText: content,
        sourceKind: sourceKind,
        subjectId: subjectId,
        downloadUrl: downloadUrl,
      ),
    );
    invalidateSubjectContext(subjectId,
        ownerId: _ref.read(firestoreServiceProvider).currentUserId);
    return structured;
  }

  Future<T> _uploadStage<T>(
      String stage, Future<T> Function() operation) async {
    debugPrint('UPLOAD $stage START');
    try {
      final result = await operation();
      debugPrint('UPLOAD $stage COMPLETE');
      return result;
    } catch (error, stackTrace) {
      debugPrint('UPLOAD $stage FAILED: $error');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> _persistUploadFailure({
    required FirestoreService firestore,
    required String subjectId,
    required String documentId,
    required Object error,
    required String label,
  }) async {
    Object? lastError;
    StackTrace? lastStackTrace;
    for (var attempt = 1; attempt <= 3; attempt++) {
      try {
        await _uploadStage(
          '$label ($attempt/3)',
          () => firestore.failDocumentPipeline(
            subjectId: subjectId,
            documentId: documentId,
            error: error.toString(),
          ),
        );
        return;
      } catch (persistError, persistStackTrace) {
        lastError = persistError;
        lastStackTrace = persistStackTrace;
        if (attempt == 3) break;
        await _uploadStage(
          'WAIT BEFORE FAILURE UPDATE RETRY',
          () => Future<void>.delayed(Duration(milliseconds: 250 * attempt)),
        );
      }
    }
    Error.throwWithStackTrace(lastError!, lastStackTrace!);
  }

  Future<UploadResult> uploadAndIndex(
    PlatformFile file, {
    required String subject,
    required String subjectId,
    String folderId = '',
    String topic = '',
    String subtopic = '',
    String notes = '',
    List<String> tags = const [],
    void Function(double)? onUploadProgress,
  }) async {
    final upload = _ref.read(firebaseUploadServiceProvider);
    final firestore = _ref.read(firestoreServiceProvider);
    final ownerId = firestore.currentUserId;
    if (ownerId == null) throw StateError('Sign in to upload sources.');
    if (subjectId.trim().isEmpty) {
      throw ArgumentError('Upload requires an existing subject.');
    }
    upload.validateFile(file);
    invalidateSubjectContext(subjectId, ownerId: ownerId);
    final documentId = firestore.newSubjectDocumentId(subjectId);
    final extension = (file.extension ?? 'bin').toLowerCase();
    final storagePath =
        'uploads/$ownerId/$subjectId/${documentId}_${file.name}';
    var failedAt = 'firestore_create';
    debugPrint('UPLOAD START: ${file.name} subject=$subjectId');
    try {
      await _uploadStage(
        'CREATE FIRESTORE DOCUMENT',
        () => firestore.createDocumentRecord(
          documentId: documentId,
          subjectId: subjectId,
          title: file.name,
          fileType: extension.toUpperCase(),
          byteSize: file.size,
          storagePath: storagePath,
          subject: subject,
          folderId: folderId,
          topic: topic,
          subtopic: subtopic,
          notes: notes,
          tags: tags,
        ),
      );
      failedAt = 'storage_upload';
      await _uploadStage(
        'SET UPLOADING STATE',
        () => firestore.updateDocumentPipelineState(
          subjectId: subjectId,
          documentId: documentId,
          status: 'uploading',
          uploadStatus: 'uploading',
        ),
      );
      final downloadUrl = await _uploadStage(
        'STORAGE UPLOAD AND DOWNLOAD URL',
        () => upload.uploadToStorage(
          file,
          userId: ownerId,
          storagePath: storagePath,
          onProgress: onUploadProgress,
        ),
      );
      if (downloadUrl.trim().isEmpty) {
        throw StateError('Storage returned an empty download URL.');
      }
      failedAt = 'extract_error';
      await _uploadStage(
        'SAVE STORAGE DOWNLOAD URL',
        () => firestore.updateDocumentPipelineState(
          subjectId: subjectId,
          documentId: documentId,
          status: 'extracting',
          uploadStatus: 'uploading',
          downloadUrl: downloadUrl,
        ),
      );
      failedAt = 'index_error';
      await _uploadStage(
        'EXTRACT AND INDEX DOCUMENT',
        () => _indexUploadedSource(
          sourceId: documentId,
          fileName: file.name,
          file: file,
          storagePath: storagePath,
          subject: subject,
          subjectId: subjectId,
          topic: topic,
          subtopic: subtopic,
          downloadUrl: downloadUrl,
          onStage: (stage) => failedAt = stage,
        ),
      );
      debugPrint('UPLOAD COMPLETE: document=$documentId');
      return UploadResult(
        downloadUrl: downloadUrl,
        storagePath: storagePath,
        firestoreDocId: documentId,
      );
    } catch (error, stackTrace) {
      debugPrint('UPLOAD FAILED at $failedAt: $error');
      debugPrintStack(stackTrace: stackTrace);
      try {
        await _persistUploadFailure(
          firestore: firestore,
          subjectId: subjectId,
          documentId: documentId,
          error: error,
          label: 'PERSIST FAILURE STATE',
        );
      } catch (persistError, persistStackTrace) {
        debugPrint('UPLOAD FAILURE STATE WRITE FAILED: $persistError');
        debugPrintStack(stackTrace: persistStackTrace);
      }
      invalidateSubjectContext(subjectId, ownerId: ownerId);
      Error.throwWithStackTrace(error, stackTrace);
    }
  }

  Future<void> retryDocumentIndex({
    required String sourceId,
    required String title,
    required String subject,
    required String subjectId,
    required String storagePath,
    required String status,
    required String fileType,
    String extractedText = '',
    String topic = '',
    String subtopic = '',
    PlatformFile? replacementFile,
  }) async {
    final upload = _ref.read(firebaseUploadServiceProvider);
    final firestore = _ref.read(firestoreServiceProvider);
    final ownerId = firestore.currentUserId;
    if (ownerId == null) throw StateError('Sign in to retry indexing.');
    var failedAt = 'upload_error';
    debugPrint('UPLOAD RETRY START: document=$sourceId status=$status');
    invalidateSubjectContext(subjectId, ownerId: ownerId);
    try {
      final existingDocument = await _uploadStage(
        'LOAD RETRY DOCUMENT',
        () => firestore.getSubjectDocument(subjectId, sourceId),
      );
      var downloadUrl = existingDocument?.fileUrl ?? '';
      if (downloadUrl.isEmpty) {
        if (replacementFile == null) {
          throw StateError('Select the source file to retry its upload.');
        }
        upload.validateFile(replacementFile);
        failedAt = 'storage_upload';
        await _uploadStage(
          'SET RETRY UPLOADING STATE',
          () => firestore.updateDocumentPipelineState(
            subjectId: subjectId,
            documentId: sourceId,
            status: 'uploading',
            uploadStatus: 'uploading',
          ),
        );
        downloadUrl = await _uploadStage(
          'RETRY STORAGE UPLOAD AND DOWNLOAD URL',
          () => upload.uploadToStorage(
            replacementFile,
            userId: ownerId,
            storagePath: storagePath,
          ),
        );
        if (downloadUrl.trim().isEmpty) {
          throw StateError('Storage returned an empty download URL.');
        }
        await _uploadStage(
          'SAVE RETRY DOWNLOAD URL',
          () => firestore.updateDocumentPipelineState(
            subjectId: subjectId,
            documentId: sourceId,
            status: 'extracting',
            uploadStatus: 'uploading',
            downloadUrl: downloadUrl,
          ),
        );
      }
      failedAt = 'extract_error';
      await _uploadStage(
        'RETRY EXTRACTION AND INDEXING',
        () => _indexUploadedSource(
          sourceId: sourceId,
          fileName: title,
          file: replacementFile,
          storagePath: storagePath,
          subject: subject,
          subjectId: subjectId,
          topic: topic,
          subtopic: subtopic,
          cachedText: extractedText,
          mimeType: _mimeTypeFor(fileType),
          downloadUrl: downloadUrl,
          onStage: (stage) => failedAt = stage,
        ),
      );
    } catch (error, stackTrace) {
      debugPrint('UPLOAD RETRY FAILED at $failedAt: $error');
      debugPrintStack(stackTrace: stackTrace);
      try {
        await _persistUploadFailure(
          firestore: firestore,
          subjectId: subjectId,
          documentId: sourceId,
          error: error,
          label: 'PERSIST RETRY FAILURE STATE',
        );
      } catch (persistError, persistStackTrace) {
        debugPrint('RETRY FAILURE STATE WRITE FAILED: $persistError');
        debugPrintStack(stackTrace: persistStackTrace);
      }
      Error.throwWithStackTrace(error, stackTrace);
    }
    invalidateSubjectContext(subjectId, ownerId: ownerId);
  }

  Future<void> deleteDocument({
    required String subjectId,
    required String documentId,
  }) async {
    debugPrint('🔥 [KnowledgeEngine] Starting document deletion: $documentId');
    final firestore = _ref.read(firestoreServiceProvider);
    final upload = _ref.read(firebaseUploadServiceProvider);
    final ownerId = firestore.currentUserId;

    if (ownerId == null) {
      debugPrint('🔥 [KnowledgeEngine] ERROR: User not signed in');
      throw StateError('Sign in to delete this file.');
    }
    debugPrint('🔥 [KnowledgeEngine] User verified: $ownerId');

    debugPrint('🔥 [KnowledgeEngine] Fetching document metadata...');
    final document = await firestore.getSubjectDocument(subjectId, documentId);
    if (document == null) {
      debugPrint('🔥 [KnowledgeEngine] ERROR: Document not found');
      throw StateError('Document is not available.');
    }
    debugPrint('🔥 [KnowledgeEngine] Document found: ${document.fileName}, storagePath: ${document.storagePath}');

    // Step 1: Delete from Firebase Storage
    debugPrint('🔥 [KnowledgeEngine] Step 1: Deleting from Firebase Storage...');
    await _deleteStorageObjectIfPresent(upload, document.storagePath);
    debugPrint('🔥 [KnowledgeEngine] ✅ Storage deletion complete');

    // Step 2: Delete from Firestore
    debugPrint('🔥 [KnowledgeEngine] Step 2: Deleting from Firestore...');
    await firestore.deleteDocument(
      documentId: documentId,
      subjectId: subjectId,
      ownerId: ownerId,
    );
    debugPrint('🔥 [KnowledgeEngine] ✅ Firestore deletion complete');

    // Step 3: Invalidate cache
    debugPrint('🔥 [KnowledgeEngine] Step 3: Invalidating cache...');
    invalidateSubjectContext(subjectId, ownerId: ownerId);
    debugPrint('🔥 [KnowledgeEngine] ✅ Cache invalidated');

    debugPrint('🔥 [KnowledgeEngine] ✅✅✅ DELETE COMPLETE: document=$documentId');
  }

  Future<void> deleteSubject(String subjectId) async {
    final firestore = _ref.read(firestoreServiceProvider);
    final upload = _ref.read(firebaseUploadServiceProvider);
    final ownerId = firestore.currentUserId;
    if (ownerId == null) throw StateError('Sign in to delete this subject.');
    final documents = await firestore.getSubjectDocuments(subjectId);
    await Future.wait(documents.map((document) =>
        _deleteStorageObjectIfPresent(upload, document.storagePath)));
    await firestore.deleteSubject(subjectId);
    invalidateSubjectContext(subjectId, ownerId: ownerId);
    debugPrint('DELETE COMPLETE: subject=$subjectId');
  }

  Future<void> _deleteStorageObjectIfPresent(
      FirebaseUploadService upload, String storagePath) async {
    if (storagePath.isEmpty) {
      debugPrint('🔥 [Storage] No storage path provided, skipping');
      return;
    }
    debugPrint('🔥 [Storage] Attempting to delete: $storagePath');
    try {
      await upload.deleteStoredDocument(storagePath);
      debugPrint('🔥 [Storage] ✅ File deleted successfully');
    } catch (error) {
      if (error.toString().contains('object-not-found')) {
        debugPrint('🔥 [Storage] ⚠️ Storage object already missing: $storagePath');
        return;
      }
      debugPrint('🔥 [Storage] ❌ Storage deletion error: $error');
      rethrow;
    }
  }

  Future<void> _indexUploadedSource({
    required String sourceId,
    required String fileName,
    required PlatformFile? file,
    required String storagePath,
    required String subject,
    required String subjectId,
    required String topic,
    required String subtopic,
    required String downloadUrl,
    String cachedText = '',
    String? mimeType,
    void Function(String status)? onStage,
  }) async {
    final firestore = _ref.read(firestoreServiceProvider);
    final upload = _ref.read(firebaseUploadServiceProvider);
    final processing = _ref.read(documentProcessingServiceProvider);
    var text = cachedText.trim();
    Uint8List? bytes = file?.bytes;
    if (text.isEmpty) {
      onStage?.call('extract_error');
      await _uploadStage(
          'SET EXTRACTING STATE',
          () => firestore.updateDocumentPipelineState(
                subjectId: subjectId,
                documentId: sourceId,
                status: 'extracting',
                uploadStatus: 'uploading',
              ));
      if (bytes == null) {
        bytes = await _uploadStage(
          'DOWNLOAD SOURCE FROM STORAGE',
          () => upload.downloadDocument(storagePath),
        );
      }
      final extractionBytes = bytes;
      if (extractionBytes == null) {
        throw StateError('The uploaded source could not be read.');
      }
      text = await _uploadStage(
        'EXTRACT TEXT',
        () => processing.extractText(PlatformFile(
          name: fileName,
          size: extractionBytes.length,
          bytes: extractionBytes,
        )),
      );
      if (text.trim().isEmpty) {
        throw StateError('No readable source content was found.');
      }
      await _uploadStage(
        'SAVE EXTRACTED TEXT',
        () => firestore.saveExtractedText(subjectId, sourceId, text),
      );
    }
    if (text.isEmpty && (bytes == null || bytes.isEmpty)) {
      throw StateError('No readable source content was found.');
    }
    onStage?.call('index_error');
    await _uploadStage(
        'SET INDEXING STATE',
        () => firestore.updateDocumentPipelineState(
              subjectId: subjectId,
              documentId: sourceId,
              status: 'indexing',
              uploadStatus: 'uploading',
            ));
    await _uploadStage(
      'GENERATE AND SAVE INDEX',
      () => index(
        sourceId: sourceId,
        title: fileName,
        content: text,
        subject: subject,
        subjectId: subjectId,
        topic: topic,
        subtopic: subtopic,
        sourceBytes: bytes,
        mimeType: mimeType ?? _mimeTypeFor(file?.extension),
        downloadUrl: downloadUrl,
        onGenerated: () => debugPrint('INDEXING COMPLETE: document=$sourceId'),
      ),
    );
    debugPrint('FIRESTORE UPDATED: document=$sourceId');
  }

  String _mimeTypeFor(String? extension) =>
      switch (extension?.toLowerCase().replaceAll('.', '')) {
        'pdf' => 'application/pdf',
        'pptx' =>
          'application/vnd.openxmlformats-officedocument.presentationml.presentation',
        'docx' =>
          'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
        'txt' => 'text/plain',
        'md' => 'text/markdown',
        _ => 'application/octet-stream',
      };

  Future<Map<String, dynamic>> _generateUncached(
      {required String task,
      required String prompt,
      required String sourceText,
      required Map<String, dynamic> metadata,
      Uint8List? sourceBytes,
      String? mimeType}) async {
    final request = AIRequest(messages: [
      AIMessage(
          role: AIRole.system,
          content:
              'You are StudyMate. Extract grounded structured knowledge for future reasoning. Source material is context only. Never create user-facing answers, summaries, or study tools during indexing. Include a sourceConfidence decimal from 0 to 1. Return one valid JSON object, no markdown.'),
      AIMessage(
          role: AIRole.user,
          content:
              'Task: $task\nMetadata: ${jsonEncode(metadata)}\n$prompt\nSource:\n$sourceText'),
    ]);
    debugPrint('UPLOAD INDEX MODEL REQUEST START: $task');
    final response = await _completeWithFailover(
      request,
      temperature: 0.2,
      sourceBytes: sourceBytes,
      mimeType: mimeType,
    );
    debugPrint('UPLOAD INDEX MODEL REQUEST COMPLETE: $task');
    final raw = response.content
        .trim()
        .replaceFirst(RegExp(r'^```(?:json)?\s*'), '')
        .replaceFirst(RegExp(r'\s*```$'), '');
    return Map<String, dynamic>.from(jsonDecode(raw) as Map);
  }

  List<Map<String, dynamic>> _prioritize(
      List<Map<String, dynamic>> records, String? topicId, String prompt,
      {List<String> sourceIds = const [], bool includeAll = false}) {
    final scoped = sourceIds.isNotEmpty
        ? records
        : topicId == null || topicId == 'current'
            ? records
            : records
                .where((r) =>
                    r['id'] == topicId ||
                    r['sourceId'] == topicId ||
                    r['topicId'] == topicId ||
                    r['folderId'] == topicId)
                .toList();
    if ((sourceIds.isNotEmpty || (topicId != null && topicId != 'current')) &&
        scoped.isEmpty) {
      return const [];
    }
    final queryTerms = prompt
        .toLowerCase()
        .split(RegExp(r'[^a-z0-9]+'))
        .where((term) => term.length > 2)
        .toSet();
    int relevance(Map<String, dynamic> r) {
      final text =
          '${r['title'] ?? ''} ${r['topic'] ?? ''} ${r['content'] ?? ''} ${r['extractedText'] ?? ''}'
              .toLowerCase();
      return queryTerms.fold<int>(
          0, (score, term) => score + (text.contains(term) ? 1 : 0));
    }

    final hasParentSource = scoped.any((r) => r['kind'] != 'concept');
    final ordered = List<Map<String, dynamic>>.from(
        hasParentSource ? scoped.where((r) => r['kind'] != 'concept') : scoped);
    int priority(Map<String, dynamic> r) => switch (r['kind']) {
          'note' => 0,
          'concept' => 1,
          'document' => 2,
          _ => 3
        };
    ordered.sort((a, b) {
      final score = relevance(b).compareTo(relevance(a));
      return score != 0 ? score : priority(a).compareTo(priority(b));
    });
    return sourceIds.isNotEmpty || includeAll
        ? ordered
        : ordered.take(24).toList();
  }

  String _rankedContexts(List<Map<String, dynamic>> sources, String prompt) {
    final query = _terms(prompt);
    final chunks =
        <({Map<String, dynamic> source, String text, double score})>[];
    for (final source in sources) {
      final raw = <String>[
        if (source['content'] is String) source['content'] as String,
        if (source['structuredKnowledge'] is Map)
          jsonEncode(source['structuredKnowledge']),
        if (source['extractedText'] is String)
          source['extractedText'] as String,
      ].where((part) => part.trim().isNotEmpty).join('\n');
      if (raw.isEmpty) continue;
      final words = raw.split(RegExp(r'\s+'));
      const window = 150;
      const overlap = 30;
      for (var start = 0; start < words.length; start += window - overlap) {
        final text = words.skip(start).take(window).join(' ').trim();
        if (text.isEmpty) continue;
        final terms = _terms(text);
        final intersection = query.intersection(terms).length;
        final score = query.isEmpty || terms.isEmpty
            ? 0.0
            : intersection /
                math.sqrt((query.length * terms.length).toDouble());
        chunks.add((source: source, text: text, score: score));
        if (start + window >= words.length) break;
      }
    }
    chunks.sort((a, b) => b.score.compareTo(a.score));
    final selected = <String>[];
    final perSource = <String, int>{};
    var chars = 0;
    final sourceHeads =
        <String, ({Map<String, dynamic> source, String text, double score})>{};
    for (final chunk in chunks) {
      sourceHeads.putIfAbsent(
          (chunk.source['id'] ?? '').toString(), () => chunk);
    }
    final firstChunks = sourceHeads.values.toList()
      ..sort((a, b) => b.score.compareTo(a.score));
    final prioritized =
        <({Map<String, dynamic> source, String text, double score})>[
      ...firstChunks,
      ...chunks,
    ];
    final seen = <String>{};
    for (final chunk in prioritized) {
      final id = (chunk.source['id'] ?? '').toString();
      final identity = '$id:${chunk.text.hashCode}';
      if (!seen.add(identity)) continue;
      if ((perSource[id] ?? 0) >= 4) continue;
      final header =
          '[${chunk.source['kind'] ?? 'document'}: ${chunk.source['title'] ?? chunk.source['fileName'] ?? 'Source'} | ${chunk.source['subject'] ?? ''} / ${chunk.source['topic'] ?? ''}]';
      final entry = '$header\n${chunk.text}';
      if (chars + entry.length > 9000) continue;
      selected.add(entry);
      chars += entry.length;
      perSource[id] = (perSource[id] ?? 0) + 1;
    }
    return selected.join('\n\n');
  }

  Set<String> _terms(String text) => text
      .toLowerCase()
      .split(RegExp(r'[^a-z0-9]+'))
      .where((term) => term.length > 2)
      .toSet();

  bool _needsWeb(String prompt, List<Map<String, dynamic>> sources) {
    final q = prompt.toLowerCase();
    final needsFreshness = const [
      'latest',
      'recent',
      'current',
      'today',
      'news',
      'updated',
      'this year',
      'this month',
      'as of now',
      'newest',
    ].any(q.contains);
    final lowConfidence = sources.any((source) {
      if (source['kind'] != 'document') return false;
      final index = source['structuredKnowledge'];
      if (index is! Map || index.isEmpty) return true;
      final confidence = index['sourceConfidence'] ??
          index['confidence'] ??
          index['confidenceScore'];
      return confidence is! num || confidence < 0.7;
    });
    return needsFreshness || lowConfidence;
  }

  Future<AIResponse> _completeWithFailover(
    AIRequest request, {
    required double temperature,
    Uint8List? sourceBytes,
    String? mimeType,
  }) {
    return _ref.read(apiKeyManagerProvider).run((apiKey, model) {
      final provider = GeminiProvider(AIConfig(
        providerType: AIProviderType.gemini,
        apiKey: apiKey,
        model: model,
        temperature: temperature,
        maxTokens: 4096,
      ));
      if (sourceBytes != null) {
        return provider.completeWithInlineData(
          request,
          sourceBytes,
          mimeType ?? 'application/octet-stream',
        );
      }
      return provider.complete(request);
    });
  }

  Stream<String> _completeStream(AIRequest request) =>
      _ref.read(apiKeyManagerProvider).runStream((apiKey, model) {
        final provider = GeminiProvider(AIConfig(
          providerType: AIProviderType.gemini,
          apiKey: apiKey,
          model: model,
          temperature: 0.4,
          maxTokens: 4096,
        ));
        return provider.stream(request);
      });

  String _stableKey(String value) {
    var hash = 0;
    for (final unit in value.codeUnits) {
      hash = (hash * 31 + unit) & 0x7fffffff;
    }
    return hash.toRadixString(16).padLeft(8, '0');
  }

  Future<Map<String, dynamic>> generateFlashcards(
          {String? topicId,
          String? subjectId,
          List<String> sourceIds = const [],
          String prompt = 'Create useful active recall flashcards.'}) =>
      generate(
          task: 'flashcards',
          prompt: prompt,
          topicId: topicId,
          subjectId: subjectId,
          sourceIds: sourceIds,
          options: {
            'shape': {
              'cards': [
                {'front': 'question', 'back': 'answer'}
              ]
            }
          });
  Future<Map<String, dynamic>> generateQuiz(
          {String? topicId,
          String? subjectId,
          List<String> sourceIds = const [],
          String prompt =
              'Create a varied practice quiz with answers, explanations, confidence guidance, and weak-topic labels.'}) =>
      generate(
          task: 'quiz',
          prompt: prompt,
          topicId: topicId,
          subjectId: subjectId,
          sourceIds: sourceIds,
          options: {
            'shape': {
              'questions': [
                {
                  'question': '',
                  'options': [],
                  'answer': '',
                  'answerIndex': 0,
                  'explanation': '',
                  'confidence': 'low|medium|high',
                  'topic': ''
                }
              ]
            }
          });
  Future<Map<String, dynamic>> generateMindMap(
          {String? topicId,
          String? subjectId,
          List<String> sourceIds = const [],
          bool forceRefresh = false,
          String prompt =
              'Build a substantial hierarchical mind map from all retrieved source chunks. Identify at least 12 distinct concepts when the material supports them, organize them beneath meaningful parent branches, and return at least 12 nodes and 12 parent-child edges. Add cross-links between related branches using labeled edges. Include concise descriptions and stable unique IDs. Never return an empty map or a root-only result; use the strongest available concepts if the source is sparse.'}) =>
      generate(
          task: 'mind_map',
          prompt: prompt,
          topicId: topicId,
          subjectId: subjectId,
          sourceIds: sourceIds,
          forceRefresh: forceRefresh,
          options: {
            'shape': {
              'root': 'topic title',
              'nodes': [
                {
                  'id': 'unique-id',
                  'parentId': 'parent-id',
                  'name': '',
                  'description': ''
                }
              ],
              'edges': [
                {
                  'from': 'parent-id',
                  'to': 'unique-id',
                  'label': 'relationship'
                }
              ]
            }
          });
  Future<Map<String, dynamic>> generateSummary(
          {String? topicId,
          String? subjectId,
          List<String> sourceIds = const [],
          bool forceRefresh = false,
          String prompt = 'Write a concise, accurate study summary.'}) =>
      generate(
          task: 'summary',
          prompt: prompt,
          topicId: topicId,
          subjectId: subjectId,
          sourceIds: sourceIds,
          forceRefresh: forceRefresh,
          options: {
            'shape': {
              'overview': '',
              'key_takeaways': [],
              'key_concepts': [],
              'important_points': [],
              'examples': [],
              'exam_tips': [],
              'formulas': [],
              'variable_meanings': []
            }
          });
  Future<Map<String, dynamic>> generateExam(
          {String? topicId,
          String? subjectId,
          List<String> sourceIds = const [],
          String prompt = 'Create a balanced mock exam with an answer key.'}) =>
      generate(
          task: 'exam',
          prompt: prompt,
          topicId: topicId,
          subjectId: subjectId,
          sourceIds: sourceIds,
          options: {
            'shape': {
              'title': '',
              'questions': [
                {
                  'prompt': '',
                  'marks': 0,
                  'modelAnswer': '',
                  'markingScheme': [],
                  'commonMistakes': []
                }
              ]
            }
          });
  Future<Map<String, dynamic>> generatePYQ(
          {String? topicId,
          String? subjectId,
          List<String> sourceIds = const [],
          String prompt =
              'Analyze uploaded previous-year questions for patterns. Do not claim frequency without evidence.'}) =>
      generate(
          task: 'pyq',
          prompt: prompt,
          topicId: topicId,
          subjectId: subjectId,
          sourceIds: sourceIds,
          options: {
            'shape': {
              'frequently_repeated_questions': [],
              'topic_frequency': [],
              'marks_distribution': [],
              'important_units': [],
              'predicted_questions': []
            }
          });
  Future<Map<String, dynamic>> answer(
          {required String prompt,
          String? topicId,
          String? subjectId,
          List<String> sourceIds = const [],
          String history = ''}) =>
      generate(
          task: 'chat',
          prompt: '$history\n$prompt',
          topicId: topicId,
          subjectId: subjectId,
          sourceIds: sourceIds,
          options: const {
            'shape': {'answer': '', 'citations': []}
          });

  Stream<String> answerStream(
      {required String prompt,
      String? subjectId,
      List<String> sourceIds = const [],
      String history = ''}) async* {
    final firestore = _ref.read(firestoreServiceProvider);
    final selectedIds = sourceIds;
    final records = await _loadContext(firestore,
        subjectId: subjectId, sourceIds: selectedIds);
    final sources = _prioritize(records, null, prompt,
        sourceIds: selectedIds,
        includeAll:
            subjectId != null && subjectId.isNotEmpty && selectedIds.isEmpty);
    final context = _rankedContexts(sources, prompt);
    var web = const <Map<String, String>>[];
    if (_needsWeb(prompt, sources)) {
      try {
        web = await _ref.read(webSearchServiceProvider).search(prompt);
      } catch (_) {
        debugPrint('Optional web context was unavailable.');
      }
    }
    final webContext = web
        .map((item) =>
            '[web: ${item['title']} | ${item['url']}] ${item['snippet']}')
        .join('\n');
    final messages = <AIMessage>[
      const AIMessage(
          role: AIRole.system,
          content:
              'You are StudyMate, an expert study tutor. Synthesize an original answer using source context; never reproduce source passages. Return a clear answer, not JSON.'),
      AIMessage(
          role: AIRole.user,
          content:
              'Conversation: $history\nQuestion: $prompt\nReference context:\n${[
            context,
            webContext
          ].where((part) => part.isNotEmpty).join('\n\n').isEmpty ? '(No source material found; use general knowledge.)' : [
                  context,
                  webContext
                ].where((part) => part.isNotEmpty).join('\n\n')}')
    ];
    yield* _completeStream(AIRequest(messages: messages));
  }
}

final knowledgeEngineProvider =
    Provider<KnowledgeEngine>((ref) => KnowledgeEngine(ref));
