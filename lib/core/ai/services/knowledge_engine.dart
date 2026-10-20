import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/firestore_service.dart';
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
        : (topicId != null && topicId.contains(',')
            ? topicId
                .split(',')
                .map((id) => id.trim())
                .where((id) => id.isNotEmpty)
                .toList()
            : const <String>[]);
    final records = await firestore.loadKnowledge(
      subjectId: subjectId,
      sourceIds: scopedIds,
    );
    final relevant =
        _prioritize(records, topicId, prompt, sourceIds: scopedIds);
    final sourceSignature = relevant
        .map((r) => '${r['id']}:${r['updatedAt']}:${r['indexedAt']}')
        .join('|');
    final dateSignature = _needsWeb(prompt, relevant)
        ? DateTime.now().toIso8601String().substring(0, 10)
        : '';
    final cacheKey = _stableKey(
      '${firestore.currentUserId ?? 'guest'}|${task.toLowerCase()}|${subjectId ?? ''}|${topicId ?? ''}|${scopedIds.join(',')}|${prompt.trim()}|${jsonEncode(options)}|$sourceSignature|$dateSignature',
    );
    final cached =
        forceRefresh ? null : await firestore.getGenerationCache(cacheKey);
    if (cached != null) {
      await _updateSourceCounts(firestore, task, topicId, cached);
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
    await firestore.cacheGeneration(cacheKey, result);
    await _updateSourceCounts(firestore, task, topicId, result);
    return result;
  }

  Future<void> _updateSourceCounts(
    FirestoreService firestore,
    String task,
    String? topicId,
    Map<String, dynamic> result,
  ) async {
    if (topicId == null ||
        topicId.isEmpty ||
        topicId == 'current' ||
        topicId.contains(',')) return;
    if (task == 'flashcards') {
      final cards = result['cards'];
      if (cards is List) {
        await firestore.updateDocumentCounts(topicId, flashcards: cards.length);
      }
    } else if (task == 'quiz') {
      final questions = result['questions'];
      if (questions is List) {
        await firestore.updateDocumentCounts(topicId,
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
  }) async {
    if (content.trim().isEmpty && sourceBytes == null) {
      throw StateError('No readable text was found in this source.');
    }
    final structured = await _generateUncached(
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
    );
    await _ref.read(firestoreServiceProvider).saveKnowledgeIndex(
        sourceId, structured,
        sourceText: content, sourceKind: sourceKind, subjectId: subjectId);
    if (sourceKind == 'document') {
      unawaited(_prepareDocumentStudyCounts(sourceId, subjectId));
    }
    return structured;
  }

  Future<void> _prepareDocumentStudyCounts(
      String sourceId, String subjectId) async {
    final jobs = <String, Future<Map<String, dynamic>> Function()>{
      'flashcards': () =>
          generateFlashcards(topicId: sourceId, subjectId: subjectId),
      'quiz': () => generateQuiz(topicId: sourceId, subjectId: subjectId),
      'summary': () => generateSummary(topicId: sourceId, subjectId: subjectId),
      'mind_map': () =>
          generateMindMap(topicId: sourceId, subjectId: subjectId),
    };
    await Future.wait(jobs.entries.map((job) async {
      try {
        await job.value();
      } catch (_) {
        debugPrint('${job.key} pre-generation did not complete.');
      }
    }));
  }

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
    final response = await _completeWithFailover(
      request,
      temperature: 0.2,
      sourceBytes: sourceBytes,
      mimeType: mimeType,
    );
    final raw = response.content
        .trim()
        .replaceFirst(RegExp(r'^```(?:json)?\s*'), '')
        .replaceFirst(RegExp(r'\s*```$'), '');
    return Map<String, dynamic>.from(jsonDecode(raw) as Map);
  }

  List<Map<String, dynamic>> _prioritize(
      List<Map<String, dynamic>> records, String? topicId, String prompt,
      {List<String> sourceIds = const []}) {
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
    return sourceIds.isNotEmpty ? ordered : ordered.take(24).toList();
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
    final sourceOrder =
        sources.map((source) => (source['id'] ?? '').toString()).toSet();
    final sourceHeads =
        <String, ({Map<String, dynamic> source, String text, double score})>{};
    for (final chunk in chunks) {
      sourceHeads.putIfAbsent(
          (chunk.source['id'] ?? '').toString(), () => chunk);
    }
    final prioritized =
        <({Map<String, dynamic> source, String text, double score})>[
      ...sourceOrder.map((id) => sourceHeads[id]).whereType<
          ({Map<String, dynamic> source, String text, double score})>(),
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
          String prompt = 'Create useful active recall flashcards.'}) =>
      generate(
          task: 'flashcards',
          prompt: prompt,
          topicId: topicId,
          subjectId: subjectId,
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
          String prompt =
              'Create a varied practice quiz with answers, explanations, confidence guidance, and weak-topic labels.'}) =>
      generate(
          task: 'quiz',
          prompt: prompt,
          topicId: topicId,
          subjectId: subjectId,
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
          bool forceRefresh = false,
          String prompt =
              'Build a complete hierarchical mind map from extracted concepts in every selected source. Include a root, major branches, and nested sub-concepts; create at least three meaningful levels when source material supports them. Return non-empty nodes and edges, preserving relationships between concepts. Give every node a stable id and parentId.'}) =>
      generate(
          task: 'mind_map',
          prompt: prompt,
          topicId: topicId,
          subjectId: subjectId,
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
          bool forceRefresh = false,
          String prompt = 'Write a concise, accurate study summary.'}) =>
      generate(
          task: 'summary',
          prompt: prompt,
          topicId: topicId,
          subjectId: subjectId,
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
          String prompt = 'Create a balanced mock exam with an answer key.'}) =>
      generate(
          task: 'exam',
          prompt: prompt,
          topicId: topicId,
          subjectId: subjectId,
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
          String prompt =
              'Analyze uploaded previous-year questions for patterns. Do not claim frequency without evidence.'}) =>
      generate(
          task: 'pyq',
          prompt: prompt,
          topicId: topicId,
          subjectId: subjectId,
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
    final records = await firestore.loadKnowledge(
        subjectId: subjectId, sourceIds: sourceIds);
    final sources = _prioritize(records, null, prompt, sourceIds: sourceIds);
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
