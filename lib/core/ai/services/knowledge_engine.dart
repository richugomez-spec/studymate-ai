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

  static const int _operationIdRandomMax = 0x7fffffff;

  String _newOperationId(String kind) {
    // Keep this positive and below 2^31. In JavaScript, `1 << 32` truncates
    // to 32 bits and becomes zero, which makes Random.nextInt throw.
    final max = _operationIdRandomMax;
    if (max <= 0) {
      throw StateError('Operation ID random range must be positive.');
    }
    final suffix = math.Random().nextInt(max);
    return '${kind}_${DateTime.now().microsecondsSinceEpoch}_$suffix';
  }

  void _logBackendOperation({
    required String operationId,
    required String operation,
    required String status,
    required Stopwatch stopwatch,
    String? subjectId,
    String? documentId,
    Object? error,
  }) {
    debugPrint('BACKEND_OPERATION ${jsonEncode({
          'operationId': operationId,
          'operation': operation,
          'subjectId': subjectId,
          'documentId': documentId,
          'status': status,
          'durationMs': stopwatch.elapsedMilliseconds,
          'error': error?.toString(),
        })}');
  }

  Future<void> _drainStorageDeletionQueue({
    required FirestoreService firestore,
    required FirebaseUploadService upload,
  }) async {
    final tasks = await firestore.getPendingStorageDeletes();
    for (final task in tasks) {
      final taskId = task['id']?.toString();
      final storagePath = task['storagePath']?.toString() ?? '';
      if (taskId == null || storagePath.isEmpty) continue;
      try {
        await _deleteStorageObjectIfPresent(upload, storagePath);
        await firestore.completeStorageDelete(taskId);
      } catch (error) {
        try {
          await firestore.recordStorageDeleteFailure(taskId, error);
        } catch (queueError) {
          debugPrint(
              'BACKEND_STORAGE_DELETE operationId=${task['operationId']} status=queue_update_failed error=$queueError');
        }
        debugPrint(
            'BACKEND_STORAGE_DELETE operationId=${task['operationId']} subjectId=${task['subjectId']} documentId=${task['documentId']} status=retry_pending error=$error');
      }
    }
  }

  static void invalidateSubjectContext(String? subjectId, {String? ownerId}) {
    // Study hierarchy is read fresh from Firestore for every generation.
  }

  Future<String?> _resolveActiveSubjectId(
      FirestoreService firestore, String? requestedSubjectId) async {
    final active = _ref.read(activeKnowledgeSubjectIdProvider) ??
        _ref.read(activeKnowledgeWorkspaceIdProvider);
    if (active != null && active.trim().isNotEmpty) return active.trim();
    if (requestedSubjectId != null && requestedSubjectId.trim().isNotEmpty) {
      return requestedSubjectId.trim();
    }
    final persisted = await firestore.getActiveSubjectId();
    if (persisted == null || persisted.trim().isEmpty) return null;
    final subjectId = persisted.trim();
    _ref.read(activeKnowledgeSubjectIdProvider.notifier).state = subjectId;
    _ref.read(activeKnowledgeWorkspaceIdProvider.notifier).state = subjectId;
    return subjectId;
  }

  Map<String, dynamic> _buildHierarchyContext(Map<String, dynamic> hierarchy) {
    const maxCharacters = 12000;
    final buffer = StringBuffer();
    final notes = <Map<String, dynamic>>[];
    final signatureParts = <String>[];
    var truncated = false;

    void append(String line) {
      if (truncated) return;
      final remaining = maxCharacters - buffer.length;
      if (remaining <= 0) {
        truncated = true;
        return;
      }
      final value = '$line\n';
      if (value.length > remaining) {
        buffer.write(value.substring(0, remaining));
        truncated = true;
      } else {
        buffer.write(value);
      }
    }

    List<Map<String, dynamic>> maps(Object? value) => value is List
        ? value.whereType<Map>().map(Map<String, dynamic>.from).toList()
        : const <Map<String, dynamic>>[];

    void appendNotes(List<Map<String, dynamic>> nodeNotes, String indent) {
      if (nodeNotes.isEmpty) {
        append('${indent}Manual Notes: None');
        return;
      }
      append('${indent}Manual Notes:');
      for (final note in nodeNotes) {
        notes.add(note);
        signatureParts.add(
            '${note['id']}|${note['updatedAt']}|${note['topicId']}|${note['topic']}|${note['subtopicId']}|${note['subtopic']}|${note['title']}|${note['content']}');
        final content = (note['content'] ?? note['notes'] ?? '').toString();
        if (content.trim().isNotEmpty) {
          // Individual notes are bounded so one long note cannot crowd out
          // every remaining topic and subtopic in the selected subject.
          final bounded = content.length > 1800
              ? '${content.substring(0, 1800)}…'
              : content;
          append(
              '$indent  ${note['title']?.toString().trim().isNotEmpty == true ? '${note['title']}: ' : ''}$bounded');
        }
      }
    }

    final subject = hierarchy['subject'] as Map<String, dynamic>? ?? const {};
    signatureParts.add(
        'subject|${subject['id']}|${subject['name']}|${subject['updatedAt']}');
    append('Subject: ${subject['name']?.toString() ?? 'Selected subject'}');
    append('Topic: (subject-level notes)');
    append('Subtopic: (none)');
    appendNotes(maps(hierarchy['subjectNotes']), '  ');
    for (final topic in maps(hierarchy['topics'])) {
      signatureParts.add('topic|${topic['id']}|${topic['name']}');
      append('Topic: ${topic['name']?.toString() ?? 'Untitled topic'}');
      append('Subtopic: (topic-level)');
      appendNotes(maps(topic['notes']), '  ');
      for (final subtopic in maps(topic['subtopics'])) {
        signatureParts.add('subtopic|${subtopic['id']}|${subtopic['name']}');
        append('Topic: ${topic['name']?.toString() ?? 'Untitled topic'}');
        append(
            'Subtopic: ${subtopic['name']?.toString() ?? 'Untitled subtopic'}');
        appendNotes(maps(subtopic['notes']), '  ');
      }
    }
    for (final note in maps(hierarchy['unplacedNotes'])) {
      append(
          'Topic: ${note['topic']?.toString().trim().isNotEmpty == true ? note['topic'] : 'Other topic'}');
      if ((note['subtopicId']?.toString() ?? '').isNotEmpty) {
        append('Subtopic: ${note['subtopic']?.toString() ?? 'Other subtopic'}');
      }
      appendNotes([note], '  ');
    }
    if (notes.isEmpty) {
      append('Manual Notes: None');
    }
    if (truncated) {
      buffer.write('\n[Context limit reached; remaining note text omitted.]');
    }
    return {
      'context': buffer.toString().trim(),
      'notes': notes,
      'noteCount': notes.length,
      'signature': _stableKey(signatureParts.join('\n')),
    };
  }

  Future<Map<String, dynamic>> _loadHierarchyContext(
      FirestoreService firestore, String? requestedSubjectId) async {
    final subjectId =
        await _resolveActiveSubjectId(firestore, requestedSubjectId);
    if (subjectId == null) {
      throw StateError('Open a subject to use its topics and manual notes.');
    }
    final hierarchy = await firestore.loadSubjectStudyHierarchy(subjectId);
    if (hierarchy == null) {
      throw StateError(
          'That subject is not available. Select a subject and try again.');
    }
    return {
      ..._buildHierarchyContext(hierarchy),
      'subjectId': subjectId,
      'subjectName': (hierarchy['subject'] as Map<String, dynamic>?)?['name'] ??
          'Selected subject',
    };
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
    final loaded = await _loadHierarchyContext(firestore, subjectId);
    final activeSubjectId = loaded['subjectId'] as String;
    final relevant = loaded['notes'] as List<Map<String, dynamic>>;
    final studyContext = loaded['context'] as String;
    final sourceSignature = loaded['signature'] as String;
    final cacheKey = _stableKey(
      '${firestore.currentUserId ?? 'guest'}|${task.toLowerCase()}|$activeSubjectId|${prompt.trim()}|${jsonEncode(options)}|$sourceSignature',
    );
    final cached =
        forceRefresh ? null : await firestore.getGenerationCache(cacheKey);
    if (cached != null) {
      await _updateSourceCounts(
          firestore, task, topicId, activeSubjectId, cached);
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
      subjectId: activeSubjectId,
      scopeId: activeSubjectId,
      sources: relevant,
      studyContext: studyContext,
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

  /// Generates editable notes for one syllabus node. Firestore persistence is
  /// deliberately left to the caller so FirestoreService remains the sole
  /// owner of writes.
  Future<String> generateAiNotes({
    required String subjectId,
    required String topicId,
    String? subtopicId,
  }) async {
    final firestore = _ref.read(firestoreServiceProvider);
    final hierarchy = await firestore.loadSubjectStudyHierarchy(subjectId);
    if (hierarchy == null) {
      throw StateError(
          'That subject is not available. Select it and try again.');
    }
    final subject = hierarchy['subject'] as Map<String, dynamic>? ?? const {};
    final topics = (hierarchy['topics'] as List<dynamic>? ?? const [])
        .whereType<Map>()
        .map(Map<String, dynamic>.from);
    final topicMatches = topics.where((item) => item['id'] == topicId).toList();
    final topic = topicMatches.isEmpty ? null : topicMatches.first;
    if (topic == null) throw StateError('That topic is no longer available.');
    Map<String, dynamic>? subtopic;
    if (subtopicId != null && subtopicId.isNotEmpty) {
      final subtopics = (topic['subtopics'] as List<dynamic>? ?? const [])
          .whereType<Map>()
          .map(Map<String, dynamic>.from);
      final matches =
          subtopics.where((item) => item['id'] == subtopicId).toList();
      subtopic = matches.isEmpty ? null : matches.first;
      if (subtopic == null) {
        throw StateError('That subtopic is no longer available.');
      }
    }
    final noteNodes = subtopic == null
        ? [
            topic,
            ...(topic['subtopics'] as List<dynamic>? ?? const [])
                .whereType<Map>()
                .map(Map<String, dynamic>.from),
          ]
        : [subtopic];
    final noteMaps = <Map<String, dynamic>>[];
    for (final node in noteNodes) {
      final nodeNotes = (node['notes'] as List<dynamic>? ?? const [])
          .whereType<Map>()
          .map(Map<String, dynamic>.from);
      noteMaps.addAll(nodeNotes.map((note) => {
            ...note,
            if (node != topic) 'subtopic': node['name'],
          }));
    }
    final manualNotes = noteMaps.isEmpty
        ? 'None'
        : noteMaps
            .map((note) =>
                '${note['subtopic'] == null ? '' : 'Subtopic: ${note['subtopic']}\n'}${note['title'] ?? 'Manual note'}: ${note['content'] ?? ''}')
            .join('\n\n');
    final context = '''Subject:
${subject['name'] ?? 'Subject'}

Topic:
${topic['name'] ?? 'Topic'}

Subtopic:
${subtopic?['name'] ?? '(all subtopics and topic-level syllabus)'}

Manual Notes:
$manualNotes

Task:
Generate comprehensive, accurate university-level study notes for this syllabus area. Use existing manual notes as primary context, preserve and expand their correct information, and fill missing concepts with your academic knowledge. If notes are None, teach the topic fully from your knowledge. Include a definition, introduction, core concepts, working principles, architecture or structure where relevant, examples, applications, advantages, disadvantages, exam points, viva questions with concise answers, FAQs, memory tips, and revision notes. Organize with clear Markdown headings. Do not ask for materials.''';
    final response = await _completeWithFailover(
      AIRequest(messages: [
        const AIMessage(
          role: AIRole.system,
          content:
              'You are an expert university-level tutor. Produce clear, correct, comprehensive notes. Treat the hierarchy as the syllabus and manual notes as optional context.',
        ),
        AIMessage(role: AIRole.user, content: context),
      ]),
      temperature: 0.4,
    );
    final content = response.content.trim();
    if (content.isEmpty) throw StateError('The AI returned empty notes.');
    return content;
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
    required String studyContext,
  }) async {
    final request = AIRequest(messages: [
      AIMessage(
          role: AIRole.system,
          content:
              'You are StudyMate, an expert university-level study tutor. The Subject > Topic > Subtopic hierarchy is the syllabus and primary source of knowledge. If Manual Notes are present, use them as the user\'s primary context, integrate them, expand them, and fill gaps with accurate academic knowledge. If Manual Notes are None, teach the topic fully using your own academic knowledge; hierarchy titles alone are sufficient. Never ask for uploaded material or notes. Do not refer to uploaded documents, files, indexing, or internal tools. Return one valid JSON object with no markdown fences.'),
      AIMessage(
          role: AIRole.user,
          content:
              'Task: $task\nRequest: $prompt\nOptions: ${jsonEncode(options)}\nStructured context:\n$studyContext'),
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
            'title': r['title'] ?? 'Manual note',
            'kind': 'note',
          }),
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
    String? operationId,
    void Function()? onGenerated,
  }) async {
    final currentOperationId = operationId ?? _newOperationId('index');
    final stopwatch = Stopwatch()..start();
    _logBackendOperation(
      operationId: currentOperationId,
      operation: 'index',
      status: 'started',
      stopwatch: stopwatch,
      subjectId: subjectId,
      documentId: sourceId,
    );
    try {
      debugPrint('🔍 [INDEX] ========== AI INDEX GENERATION START ==========');
      debugPrint('🔍 [INDEX] Source ID: $sourceId');
      debugPrint('🔍 [INDEX] Title: $title');
      debugPrint('🔍 [INDEX] Content length: ${content.length} chars');
      debugPrint('🔍 [INDEX] Subject: $subject ($subjectId)');

      if (content.trim().isEmpty && sourceBytes == null) {
        throw StateError('No readable text was found in this source.');
      }

      // Step 5.6.1: Generate AI index
      debugPrint('🔍 [INDEX] ----- STEP 5.6.1: AI MODEL GENERATION -----');
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
      debugPrint(
          '🔍 [INDEX] ✅ AI index generated: ${structured.keys.join(", ")}');

      onGenerated?.call();
      debugPrint('🔍 [INDEX] onGenerated callback invoked');

      // Step 5.6.2: Save index to Firestore
      debugPrint('🔍 [INDEX] ----- STEP 5.6.2: SAVE INDEX TO FIRESTORE -----');
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
          operationId: currentOperationId,
        ),
      );
      debugPrint('🔍 [INDEX] ✅ Index saved to Firestore');

      invalidateSubjectContext(subjectId,
          ownerId: _ref.read(firestoreServiceProvider).currentUserId);
      debugPrint('🔍 [INDEX] Subject context invalidated');

      debugPrint(
          '🔍 [INDEX] ========== AI INDEX GENERATION COMPLETE ==========');
      _logBackendOperation(
        operationId: currentOperationId,
        operation: 'index',
        status: 'indexed',
        stopwatch: stopwatch,
        subjectId: subjectId,
        documentId: sourceId,
      );
      return structured;
    } catch (error) {
      _logBackendOperation(
        operationId: currentOperationId,
        operation: 'index',
        status: 'failed',
        stopwatch: stopwatch,
        subjectId: subjectId,
        documentId: sourceId,
        error: error,
      );
      rethrow;
    }
  }

  Future<T> _uploadStage<T>(
      String stage, Future<T> Function() operation) async {
    debugPrint('UPLOAD $stage START');
    try {
      final result = await operation().timeout(const Duration(minutes: 6));
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
    bool clearStorageReference = false,
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
            clearStorageReference: clearStorageReference,
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
    String topicId = '',
    String subtopicId = '',
    String topic = '',
    String subtopic = '',
    String notes = '',
    List<String> tags = const [],
    void Function(double)? onUploadProgress,
  }) async {
    debugPrint('📤 [UPLOAD] ========== UPLOAD PIPELINE START ==========');
    debugPrint('📤 [UPLOAD] File: ${file.name} (${file.size} bytes)');
    debugPrint('📤 [UPLOAD] Subject: $subject ($subjectId)');

    final upload = _ref.read(firebaseUploadServiceProvider);
    final firestore = _ref.read(firestoreServiceProvider);
    final ownerId = firestore.currentUserId;

    if (ownerId == null) throw StateError('Sign in to upload sources.');
    if (subjectId.trim().isEmpty) {
      throw ArgumentError('Upload requires an existing subject.');
    }

    try {
      await _drainStorageDeletionQueue(firestore: firestore, upload: upload);
    } catch (error) {
      debugPrint('BACKEND_STORAGE_DELETE status=drain_deferred error=$error');
    }

    debugPrint('📤 [UPLOAD] Owner ID: $ownerId');

    upload.validateFile(file);
    debugPrint('📤 [UPLOAD] File validation passed');

    invalidateSubjectContext(subjectId, ownerId: ownerId);
    final documentId = firestore.newSubjectDocumentId(subjectId);
    final extension = (file.extension ?? 'bin').toLowerCase();
    final storagePath =
        'uploads/$ownerId/$subjectId/${documentId}_${file.name}';
    final operationId = _newOperationId('upload');
    final stopwatch = Stopwatch()..start();
    var storageAttempted = false;
    var firestoreRecordCreated = false;
    _logBackendOperation(
      operationId: operationId,
      operation: 'upload_index',
      status: 'started',
      stopwatch: stopwatch,
      subjectId: subjectId,
      documentId: documentId,
    );

    debugPrint('📤 [UPLOAD] Generated document ID: $documentId');
    debugPrint('📤 [UPLOAD] Storage path: $storagePath');

    var failedAt = 'firestore_create';
    try {
      // Step 1: Create Firestore document record
      debugPrint('📤 [UPLOAD] ===== STEP 1: CREATE FIRESTORE DOCUMENT =====');
      await _uploadStage(
        'CREATE FIRESTORE DOCUMENT',
        () => firestore.createDocumentRecord(
          documentId: documentId,
          subjectId: subjectId,
          operationId: operationId,
          title: file.name,
          fileType: extension.toUpperCase(),
          byteSize: file.size,
          storagePath: storagePath,
          subject: subject,
          folderId: folderId,
          topicId: topicId,
          subtopicId: subtopicId,
          topic: topic,
          subtopic: subtopic,
          notes: notes,
          tags: tags,
        ),
      );
      firestoreRecordCreated = true;
      debugPrint('📤 [UPLOAD] ✅ Firestore document created');

      // Step 2: Set uploading state
      failedAt = 'storage_upload';
      debugPrint('📤 [UPLOAD] ===== STEP 2: SET UPLOADING STATE =====');
      await _uploadStage(
        'SET UPLOADING STATE',
        () => firestore.updateDocumentPipelineState(
          subjectId: subjectId,
          documentId: documentId,
          status: 'uploading',
          uploadStatus: 'uploading',
          operationId: operationId,
        ),
      );
      debugPrint('📤 [UPLOAD] ✅ Status set to uploading');

      // Step 3: Upload to Firebase Storage
      debugPrint('📤 [UPLOAD] ===== STEP 3: UPLOAD TO FIREBASE STORAGE =====');
      storageAttempted = true;
      final completedDownloadUrl = await _uploadStage(
        'STORAGE UPLOAD AND DOWNLOAD URL',
        () => upload.uploadToStorage(
          file,
          userId: ownerId,
          storagePath: storagePath,
          onProgress: onUploadProgress,
        ),
      );
      if (completedDownloadUrl.trim().isEmpty) {
        throw StateError('Storage returned an empty download URL.');
      }

      // Step 4: Save download URL and set extracting state
      failedAt = 'extract_error';
      debugPrint('📤 [UPLOAD] ===== STEP 4: SAVE DOWNLOAD URL =====');
      await _uploadStage(
        'SAVE STORAGE DOWNLOAD URL',
        () => firestore.updateDocumentPipelineState(
          subjectId: subjectId,
          documentId: documentId,
          status: 'extracting',
          uploadStatus: 'uploading',
          downloadUrl: completedDownloadUrl,
          operationId: operationId,
        ),
      );
      debugPrint('📤 [UPLOAD] ✅ Download URL saved, status set to extracting');

      // Step 5: Extract text and index document
      failedAt = 'index_error';
      debugPrint('📤 [UPLOAD] ===== STEP 5: EXTRACT AND INDEX =====');
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
          downloadUrl: completedDownloadUrl,
          operationId: operationId,
          onStage: (stage) => failedAt = stage,
        ),
      );
      debugPrint('📤 [UPLOAD] ✅ Extraction and indexing complete');

      debugPrint('📤 [UPLOAD] ========== UPLOAD PIPELINE COMPLETE ==========');
      debugPrint('📤 [UPLOAD] Document ID: $documentId');
      debugPrint(
          '📤 [UPLOAD] All async operations completed, returning result');

      _logBackendOperation(
        operationId: operationId,
        operation: 'upload_index',
        status: 'indexed',
        stopwatch: stopwatch,
        subjectId: subjectId,
        documentId: documentId,
      );
      return UploadResult(
        downloadUrl: completedDownloadUrl,
        storagePath: storagePath,
        firestoreDocId: documentId,
      );
    } catch (error, stackTrace) {
      debugPrint('📤 [UPLOAD] ❌❌❌ UPLOAD FAILED at $failedAt: $error');
      debugPrintStack(stackTrace: stackTrace);
      _logBackendOperation(
        operationId: operationId,
        operation: 'upload_index',
        status: 'failed',
        stopwatch: stopwatch,
        subjectId: subjectId,
        documentId: documentId,
        error: error,
      );
      if (storageAttempted && failedAt != 'index_error') {
        try {
          await _deleteStorageObjectIfPresent(upload, storagePath);
        } catch (compensationError) {
          try {
            await firestore.enqueueStorageDelete(
              storagePath: storagePath,
              operationId: operationId,
              subjectId: subjectId,
              documentId: documentId,
              reason: 'upload_compensation',
            );
          } catch (queueError) {
            debugPrint(
                'BACKEND_COMPENSATION operationId=$operationId subjectId=$subjectId documentId=$documentId status=queue_failed error=$queueError');
          }
          debugPrint(
              'BACKEND_COMPENSATION operationId=$operationId subjectId=$subjectId documentId=$documentId status=storage_retry_pending error=$compensationError');
        }
      }
      if (firestoreRecordCreated)
        try {
          debugPrint('📤 [UPLOAD] Persisting failure state to Firestore...');
          await _persistUploadFailure(
            firestore: firestore,
            subjectId: subjectId,
            documentId: documentId,
            error: error,
            label: 'PERSIST FAILURE STATE',
            clearStorageReference:
                storageAttempted && failedAt != 'index_error',
          );
          debugPrint('📤 [UPLOAD] ✅ Failure state persisted');
        } catch (persistError, persistStackTrace) {
          debugPrint(
              '📤 [UPLOAD] ❌ FAILURE STATE PERSISTENCE FAILED: $persistError');
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
    final operationId = _newOperationId('retry');
    final stopwatch = Stopwatch()..start();
    var replacementStorageAttempted = false;
    try {
      await _drainStorageDeletionQueue(firestore: firestore, upload: upload);
    } catch (error) {
      debugPrint('BACKEND_STORAGE_DELETE status=drain_deferred error=$error');
    }
    _logBackendOperation(
      operationId: operationId,
      operation: 'retry_index',
      status: 'started',
      stopwatch: stopwatch,
      subjectId: subjectId,
      documentId: sourceId,
    );
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
            operationId: operationId,
          ),
        );
        replacementStorageAttempted = true;
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
            operationId: operationId,
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
          operationId: operationId,
          onStage: (stage) => failedAt = stage,
        ),
      );
    } catch (error, stackTrace) {
      debugPrint('UPLOAD RETRY FAILED at $failedAt: $error');
      debugPrintStack(stackTrace: stackTrace);
      _logBackendOperation(
        operationId: operationId,
        operation: 'retry_index',
        status: 'failed',
        stopwatch: stopwatch,
        subjectId: subjectId,
        documentId: sourceId,
        error: error,
      );
      if (replacementStorageAttempted && failedAt != 'extract_error') {
        try {
          await _deleteStorageObjectIfPresent(upload, storagePath);
        } catch (compensationError) {
          try {
            await firestore.enqueueStorageDelete(
              storagePath: storagePath,
              operationId: operationId,
              subjectId: subjectId,
              documentId: sourceId,
              reason: 'retry_compensation',
            );
          } catch (queueError) {
            debugPrint(
                'BACKEND_COMPENSATION operationId=$operationId subjectId=$subjectId documentId=$sourceId status=queue_failed error=$queueError');
          }
          debugPrint(
              'BACKEND_COMPENSATION operationId=$operationId subjectId=$subjectId documentId=$sourceId status=storage_retry_pending error=$compensationError');
        }
      }
      try {
        await _persistUploadFailure(
          firestore: firestore,
          subjectId: subjectId,
          documentId: sourceId,
          error: error,
          label: 'PERSIST RETRY FAILURE STATE',
          clearStorageReference:
              replacementStorageAttempted && failedAt != 'extract_error',
        );
      } catch (persistError, persistStackTrace) {
        debugPrint('RETRY FAILURE STATE WRITE FAILED: $persistError');
        debugPrintStack(stackTrace: persistStackTrace);
      }
      Error.throwWithStackTrace(error, stackTrace);
    }
    invalidateSubjectContext(subjectId, ownerId: ownerId);
    _logBackendOperation(
      operationId: operationId,
      operation: 'retry_index',
      status: 'indexed',
      stopwatch: stopwatch,
      subjectId: subjectId,
      documentId: sourceId,
    );
  }

  Future<void> deleteDocument({
    required String subjectId,
    required String documentId,
  }) async {
    debugPrint('🔥 [KnowledgeEngine] Starting document deletion: $documentId');
    final firestore = _ref.read(firestoreServiceProvider);
    final upload = _ref.read(firebaseUploadServiceProvider);
    final ownerId = firestore.currentUserId;
    final operationId = _newOperationId('delete');
    final stopwatch = Stopwatch()..start();
    _logBackendOperation(
      operationId: operationId,
      operation: 'delete_document',
      status: 'started',
      stopwatch: stopwatch,
      subjectId: subjectId,
      documentId: documentId,
    );

    if (ownerId == null) {
      debugPrint('🔥 [KnowledgeEngine] ERROR: User not signed in');
      throw StateError('Sign in to delete this file.');
    }
    debugPrint('🔥 [KnowledgeEngine] User verified: $ownerId');

    try {
      final document =
          await firestore.getSubjectDocument(subjectId, documentId) ??
              (throw StateError('Document is not available.'));
      debugPrint(
          '🔥 [KnowledgeEngine] Document found: ${document.fileName}, storagePath: ${document.storagePath}');

      // The Firestore delete and durable Storage cleanup task commit together.
      final storageTaskId = await firestore.deleteDocument(
        documentId: documentId,
        subjectId: subjectId,
        ownerId: ownerId,
        operationId: operationId,
      );
      if (storageTaskId != null) {
        try {
          await _deleteStorageObjectIfPresent(upload, document.storagePath);
          await firestore.completeStorageDelete(storageTaskId);
        } catch (error) {
          await firestore.recordStorageDeleteFailure(storageTaskId, error);
          debugPrint(
              'BACKEND_STORAGE_DELETE operationId=$operationId subjectId=$subjectId documentId=$documentId status=retry_pending error=$error');
        }
      }
      await _drainStorageDeletionQueue(firestore: firestore, upload: upload);
    } catch (error) {
      _logBackendOperation(
        operationId: operationId,
        operation: 'delete_document',
        status: 'failed',
        stopwatch: stopwatch,
        subjectId: subjectId,
        documentId: documentId,
        error: error,
      );
      rethrow;
    }
    debugPrint('🔥 [KnowledgeEngine] ✅ Firestore deletion complete');

    // Step 3: Invalidate cache
    debugPrint('🔥 [KnowledgeEngine] Step 3: Invalidating cache...');
    invalidateSubjectContext(subjectId, ownerId: ownerId);
    debugPrint('🔥 [KnowledgeEngine] ✅ Cache invalidated');
    _logBackendOperation(
      operationId: operationId,
      operation: 'delete_document',
      status: 'deleted',
      stopwatch: stopwatch,
      subjectId: subjectId,
      documentId: documentId,
    );

    debugPrint(
        '🔥 [KnowledgeEngine] ✅✅✅ DELETE COMPLETE: document=$documentId');
  }

  Future<void> deleteSubject(String subjectId) async {
    final firestore = _ref.read(firestoreServiceProvider);
    final upload = _ref.read(firebaseUploadServiceProvider);
    final ownerId = firestore.currentUserId;
    if (ownerId == null) throw StateError('Sign in to delete this subject.');
    final operationId = _newOperationId('delete_subject');
    final stopwatch = Stopwatch()..start();
    _logBackendOperation(
      operationId: operationId,
      operation: 'delete_subject',
      status: 'started',
      stopwatch: stopwatch,
      subjectId: subjectId,
    );
    try {
      await firestore.deleteSubject(subjectId, operationId: operationId);
      await _drainStorageDeletionQueue(firestore: firestore, upload: upload);
      invalidateSubjectContext(subjectId, ownerId: ownerId);
      _logBackendOperation(
        operationId: operationId,
        operation: 'delete_subject',
        status: 'deleted',
        stopwatch: stopwatch,
        subjectId: subjectId,
      );
      debugPrint('DELETE COMPLETE: subject=$subjectId');
    } catch (error) {
      _logBackendOperation(
        operationId: operationId,
        operation: 'delete_subject',
        status: 'failed',
        stopwatch: stopwatch,
        subjectId: subjectId,
        error: error,
      );
      rethrow;
    }
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
        debugPrint(
            '🔥 [Storage] ⚠️ Storage object already missing: $storagePath');
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
    required String operationId,
    String cachedText = '',
    String? mimeType,
    void Function(String status)? onStage,
  }) async {
    debugPrint('📑 [INDEX] ========== INDEXING START ==========');
    debugPrint('📑 [INDEX] Source ID: $sourceId');
    debugPrint('📑 [INDEX] File: $fileName');

    final firestore = _ref.read(firestoreServiceProvider);
    final upload = _ref.read(firebaseUploadServiceProvider);
    final processing = _ref.read(documentProcessingServiceProvider);

    var text = cachedText.trim();
    Uint8List? bytes = file?.bytes;

    debugPrint('📑 [INDEX] Cached text length: ${text.length}');
    debugPrint('📑 [INDEX] File bytes available: ${bytes != null}');

    if (text.isEmpty) {
      onStage?.call('extract_error');

      // Step 5.1: Set extracting state
      debugPrint('📑 [INDEX] ----- STEP 5.1: SET EXTRACTING STATE -----');
      await _uploadStage(
          'SET EXTRACTING STATE',
          () => firestore.updateDocumentPipelineState(
                subjectId: subjectId,
                documentId: sourceId,
                status: 'extracting',
                uploadStatus: 'uploading',
                operationId: operationId,
              ));
      debugPrint('📑 [INDEX] ✅ Status set to extracting');

      // Step 5.2: Download document if needed
      if (bytes == null) {
        debugPrint('📑 [INDEX] ----- STEP 5.2: DOWNLOAD FROM STORAGE -----');
        bytes = await _uploadStage(
          'DOWNLOAD SOURCE FROM STORAGE',
          () => upload.downloadDocument(storagePath),
        );
        debugPrint('📑 [INDEX] ✅ Downloaded ${bytes?.length ?? 0} bytes');
      }

      final extractionBytes = bytes;
      if (extractionBytes == null) {
        throw StateError('The uploaded source could not be read.');
      }

      // Step 5.3: Extract text
      debugPrint('📑 [INDEX] ----- STEP 5.3: EXTRACT TEXT -----');
      debugPrint('📑 [INDEX] Extracting from ${extractionBytes.length} bytes');
      text = await _uploadStage(
        'EXTRACT TEXT',
        () => processing.extractText(PlatformFile(
          name: fileName,
          size: extractionBytes.length,
          bytes: extractionBytes,
        )),
      );
      debugPrint('📑 [INDEX] ✅ Extracted ${text.length} characters');

      if (text.trim().isEmpty) {
        throw StateError('No readable source content was found.');
      }

      // Step 5.4: Save extracted text to Firestore
      debugPrint('📑 [INDEX] ----- STEP 5.4: SAVE EXTRACTED TEXT -----');
      await _uploadStage(
        'SAVE EXTRACTED TEXT',
        () => firestore.saveExtractedText(subjectId, sourceId, text),
      );
      debugPrint('📑 [INDEX] ✅ Extracted text saved to Firestore');
    } else {
      debugPrint('📑 [INDEX] Using cached text (${text.length} chars)');
    }

    if (text.isEmpty && (bytes == null || bytes.isEmpty)) {
      throw StateError('No readable source content was found.');
    }

    onStage?.call('index_error');

    // Step 5.5: Set indexing state
    debugPrint('📑 [INDEX] ----- STEP 5.5: SET INDEXING STATE -----');
    await _uploadStage(
        'SET INDEXING STATE',
        () => firestore.updateDocumentPipelineState(
              subjectId: subjectId,
              documentId: sourceId,
              status: 'indexing',
              uploadStatus: 'uploading',
              operationId: operationId,
            ));
    debugPrint('📑 [INDEX] ✅ Status set to indexing');

    // Step 5.6: Generate and save index
    debugPrint('📑 [INDEX] ----- STEP 5.6: GENERATE AND SAVE INDEX -----');
    debugPrint('📑 [INDEX] Calling index() method...');
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
        operationId: operationId,
        onGenerated: () =>
            debugPrint('📑 [INDEX] ✅ AI index generation complete'),
      ),
    );
    debugPrint('📑 [INDEX] ✅ Index saved to Firestore');

    debugPrint('📑 [INDEX] ========== INDEXING COMPLETE ==========');
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
              'Build a substantial hierarchical mind map from the selected subject topics, subtopics, and manual notes. Preserve their hierarchy, include empty-note topic titles as syllabus structure, and return a useful map grounded in the available material.'}) =>
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
              'Analyze the selected subject hierarchy as the syllabus. Use available manual notes as primary context and academic knowledge to identify important units and predict useful questions. Do not claim historical frequency without evidence.'}) =>
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
    final loaded = await _loadHierarchyContext(firestore, subjectId);
    final sources = loaded['notes'] as List<Map<String, dynamic>>;
    final context = loaded['context'] as String;
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
              'You are StudyMate, an expert study tutor. The Subject > Topic > Subtopic hierarchy is the syllabus and primary source of knowledge. Use available manual notes as the user\'s primary context, expand partial notes, and fill gaps with sound academic knowledge. If Manual Notes are None, answer fully using your own knowledge; the hierarchy alone is sufficient. Never ask for uploaded material or notes. You may use web results only for genuinely current facts and identify them as outside the study notes. Never refer to uploaded documents or files. Return a clear answer, not JSON.'),
      AIMessage(
          role: AIRole.user,
          content:
              'Conversation: $history\nQuestion: $prompt\nTask: Answer the question as a helpful tutor.\nStructured context:\n$context\n\nOptional current web references:\n$webContext')
    ];
    yield* _completeStream(AIRequest(messages: messages));
  }

  // Subject hierarchy operations stay in FirestoreService; these methods are
  // the business-logic entry points for callers using KnowledgeEngine.
  Stream<List<Map<String, dynamic>>> streamTopics(String subjectId) =>
      _ref.read(firestoreServiceProvider).streamSubjectTopics(subjectId);

  Stream<List<Map<String, dynamic>>> streamSubtopics(
          String subjectId, String topicId) =>
      _ref.read(firestoreServiceProvider).streamSubtopics(subjectId, topicId);

  Future<List<Map<String, dynamic>>> getTopicsWithSubtopics(String subjectId) =>
      _ref
          .read(firestoreServiceProvider)
          .getSubjectTopicsWithSubtopics(subjectId);

  Future<String> createTopic({
    required String subjectId,
    required String name,
  }) =>
      _ref.read(firestoreServiceProvider).createTopic(
            subjectId: subjectId,
            name: name,
          );

  Future<String> createSubtopic({
    required String subjectId,
    required String topicId,
    required String name,
  }) =>
      _ref.read(firestoreServiceProvider).createSubtopic(
            subjectId: subjectId,
            topicId: topicId,
            name: name,
          );

  Future<void> renameTopic({
    required String subjectId,
    required String topicId,
    required String name,
  }) =>
      _ref.read(firestoreServiceProvider).updateTopicName(
            subjectId: subjectId,
            topicId: topicId,
            name: name,
          );

  Future<void> renameSubtopic({
    required String subjectId,
    required String topicId,
    required String subtopicId,
    required String name,
  }) =>
      _ref.read(firestoreServiceProvider).updateSubtopicName(
            subjectId: subjectId,
            topicId: topicId,
            subtopicId: subtopicId,
            name: name,
          );

  Future<void> deleteTopic({
    required String subjectId,
    required String topicId,
  }) =>
      _ref.read(firestoreServiceProvider).deleteTopic(
            subjectId: subjectId,
            topicId: topicId,
          );

  Future<void> deleteSubtopic({
    required String subjectId,
    required String topicId,
    required String subtopicId,
  }) =>
      _ref.read(firestoreServiceProvider).deleteSubtopic(
            subjectId: subjectId,
            topicId: topicId,
            subtopicId: subtopicId,
          );

  Future<void> reorderTopics({
    required String subjectId,
    required List<String> topicIds,
  }) =>
      _ref.read(firestoreServiceProvider).reorderTopics(
            subjectId: subjectId,
            topicIds: topicIds,
          );

  Future<void> reorderSubtopics({
    required String subjectId,
    required String topicId,
    required List<String> subtopicIds,
  }) =>
      _ref.read(firestoreServiceProvider).reorderSubtopics(
            subjectId: subjectId,
            topicId: topicId,
            subtopicIds: subtopicIds,
          );
}

final knowledgeEngineProvider =
    Provider<KnowledgeEngine>((ref) => KnowledgeEngine(ref));
