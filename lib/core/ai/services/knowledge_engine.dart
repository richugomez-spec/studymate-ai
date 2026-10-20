import 'dart:convert';
import 'dart:typed_data';

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

  Future<Map<String, dynamic>> generate({
    required String task,
    required String prompt,
    String? topicId,
    Map<String, dynamic> options = const {},
  }) async {
    final firestore = _ref.read(firestoreServiceProvider);
    final records = await firestore.loadKnowledge();
    final relevant = _prioritize(records, topicId);
    final sourceSignature = relevant
        .map((r) => '${r['id']}:${r['updatedAt']}:${r['indexedAt']}')
        .join('|');
    final dateSignature = _needsWeb(prompt, relevant, topicId)
        ? DateTime.now().toIso8601String().substring(0, 10)
        : '';
    final cacheKey = _stableKey(
      '${task.toLowerCase()}|${topicId ?? ''}|${prompt.trim()}|${jsonEncode(options)}|$sourceSignature|$dateSignature',
    );
    final cached = await firestore.getGenerationCache(cacheKey);
    if (cached != null) return cached;

    final webResults = _needsWeb(prompt, relevant, topicId)
        ? await _ref
            .read(webSearchServiceProvider)
            .search(prompt)
            .catchError((_) => <Map<String, String>>[])
        : const <Map<String, String>>[];

    final apiKey = _ref.read(aiApiKeyProvider);
    if (apiKey == null || apiKey.trim().isEmpty) {
      throw StateError(
          'Add a Gemini API key in AI settings to generate study materials.');
    }
    final sources = relevant;
    final context = sources
        .map((r) {
          final type = r['kind'] ?? 'document';
          final title = r['title'] ?? r['fileName'] ?? 'Untitled source';
          final body = [r['content'], r['extractedText']]
              .whereType<String>()
              .where((text) => text.trim().isNotEmpty)
              .join('\n\n');
          return '[$type: $title | ${r['subject'] ?? ''} / ${r['topic'] ?? ''}]\n$body';
        })
        .where((s) => s.trim().isNotEmpty)
        .join('\n\n');
    final webContext = webResults
        .map((r) => '[web: ${r['title']} | ${r['url']}]\n${r['snippet']}')
        .join('\n\n');
    final provider = GeminiProvider(AIConfig(
      providerType: AIProviderType.gemini,
      apiKey: apiKey.trim(),
      model: 'gemini-3.8-flash',
      temperature: 0.4,
      maxTokens: 4096,
    ));
    final response = await provider.complete(AIRequest(messages: [
      AIMessage(
          role: AIRole.system,
          content:
              'You are StudyMate Knowledge Engine. Reason from the provided knowledge sources. Never invent source facts. If sources do not contain enough information, say so. Return only valid JSON object, with no markdown fences.'),
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
    ]));
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
    return result;
  }

  Future<Map<String, dynamic>> index({
    required String sourceId,
    required String title,
    required String content,
    String sourceKind = 'document',
    String subject = '',
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
          'Index this source as structured knowledge. Extract concepts, definitions, relationships, formulas, examples, important facts, and exam points. Do not create flashcards, quizzes, or summaries.',
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
        sourceText: content, sourceKind: sourceKind);
    return structured;
  }

  Future<Map<String, dynamic>> _generateUncached(
      {required String task,
      required String prompt,
      required String sourceText,
      required Map<String, dynamic> metadata,
      Uint8List? sourceBytes,
      String? mimeType}) async {
    final apiKey = _ref.read(aiApiKeyProvider);
    if (apiKey == null || apiKey.trim().isEmpty)
      throw StateError('Configure a Gemini API key to index sources.');
    final provider = GeminiProvider(AIConfig(
        providerType: AIProviderType.gemini,
        apiKey: apiKey.trim(),
        model: 'gemini-3.8-flash',
        temperature: 0.2,
        maxTokens: 4096));
    final request = AIRequest(messages: [
      AIMessage(
          role: AIRole.system,
          content:
              'You are StudyMate Knowledge Engine. Extract only grounded knowledge. Return one valid JSON object, no markdown.'),
      AIMessage(
          role: AIRole.user,
          content:
              'Task: $task\nMetadata: ${jsonEncode(metadata)}\n$prompt\nSource:\n$sourceText'),
    ]);
    final response = sourceBytes != null
        ? await provider.completeWithInlineData(
            request, sourceBytes, mimeType ?? 'application/octet-stream')
        : await provider.complete(request);
    final raw = response.content
        .trim()
        .replaceFirst(RegExp(r'^```(?:json)?\s*'), '')
        .replaceFirst(RegExp(r'\s*```$'), '');
    return Map<String, dynamic>.from(jsonDecode(raw) as Map);
  }

  List<Map<String, dynamic>> _prioritize(
      List<Map<String, dynamic>> records, String? topicId) {
    final scoped = topicId == null || topicId == 'current'
        ? records
        : records
            .where((r) =>
                r['id'] == topicId ||
                r['sourceId'] == topicId ||
                r['topicId'] == topicId ||
                r['folderId'] == topicId)
            .toList();
    final ordered =
        List<Map<String, dynamic>>.from(scoped.isEmpty ? records : scoped);
    int priority(Map<String, dynamic> r) => switch (r['kind']) {
          'note' => 0,
          'concept' => 1,
          'document' => 2,
          _ => 3
        };
    ordered.sort((a, b) => priority(a).compareTo(priority(b)));
    return ordered;
  }

  bool _needsWeb(
      String prompt, List<Map<String, dynamic>> sources, String? topicId) {
    final q = prompt.toLowerCase();
    return topicId == null ||
        sources.isEmpty ||
        const ['latest', 'recent', 'current', 'today', 'news', 'updated']
            .any(q.contains);
  }

  String _stableKey(String value) {
    var hash = 0xcbf29ce484222325;
    for (final unit in value.codeUnits) {
      hash = ((hash ^ unit) * 0x100000001b3) & 0xffffffffffffffff;
    }
    return hash.toRadixString(16).padLeft(16, '0');
  }

  Future<Map<String, dynamic>> generateFlashcards(
          {String? topicId,
          String prompt = 'Create useful active recall flashcards.'}) =>
      generate(task: 'flashcards', prompt: prompt, topicId: topicId, options: {
        'shape': {
          'cards': [
            {'front': 'question', 'back': 'answer'}
          ]
        }
      });
  Future<Map<String, dynamic>> generateQuiz(
          {String? topicId,
          String prompt =
              'Create a varied practice quiz with answers, explanations, confidence guidance, and weak-topic labels.'}) =>
      generate(task: 'quiz', prompt: prompt, topicId: topicId, options: {
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
          String prompt = 'Create a hierarchical mind map.'}) =>
      generate(task: 'mind_map', prompt: prompt, topicId: topicId, options: {
        'shape': {'root': '', 'nodes': [], 'edges': []}
      });
  Future<Map<String, dynamic>> generateSummary(
          {String? topicId,
          String prompt = 'Write a concise, accurate study summary.'}) =>
      generate(task: 'summary', prompt: prompt, topicId: topicId);
  Future<Map<String, dynamic>> generateExam(
          {String? topicId,
          String prompt = 'Create a balanced mock exam with answer key.'}) =>
      generate(task: 'exam', prompt: prompt, topicId: topicId);
  Future<Map<String, dynamic>> generatePYQ(
          {String? topicId,
          String prompt =
              'Analyze uploaded previous-year questions for patterns. Do not claim frequency without evidence.'}) =>
      generate(task: 'pyq', prompt: prompt, topicId: topicId);
  Future<Map<String, dynamic>> answer(
          {required String prompt, String? topicId, String history = ''}) =>
      generate(
          task: 'chat',
          prompt: '$history\n$prompt',
          topicId: topicId,
          options: const {
            'shape': {'answer': '', 'citations': []}
          });
}

final knowledgeEngineProvider =
    Provider<KnowledgeEngine>((ref) => KnowledgeEngine(ref));
