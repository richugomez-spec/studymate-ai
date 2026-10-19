import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/document_processing_service.dart';
import '../../storage/hive_storage.dart';
import '../ai_config.dart';
import '../ai_message.dart';
import '../models/course_knowledge.dart';
import '../models/hierarchical_document_model.dart';
import '../providers/gemini_provider.dart';
import '../services/real_ai_chat_service.dart';
import '../services/web_search_service.dart';

/// AI-first knowledge engine.
/// Structured course/document knowledge is the primary reasoning substrate.
/// Hybrid RAG remains only as citation support in chat.
class KnowledgeEngine {
  final Ref _ref;
  static final Map<String, HierarchicalDocumentModel> _memoryCache = {};

  KnowledgeEngine(this._ref);

  KnowledgeSourceDecision routeSources({
    required String query,
    required bool hasNotes,
    required bool hasCourse,
    required bool hasConversation,
  }) {
    final web = _ref.read(webSearchServiceProvider).needsLiveWeb(query);
    final sources = <KnowledgeSourceKind>[];
    if (hasNotes) sources.add(KnowledgeSourceKind.notes);
    sources.add(KnowledgeSourceKind.modelKnowledge);
    if (web) sources.add(KnowledgeSourceKind.web);
    if (hasConversation) sources.add(KnowledgeSourceKind.conversation);
    if (hasCourse) sources.add(KnowledgeSourceKind.course);

    return KnowledgeSourceDecision(
      sources: sources,
      needsWeb: web,
      reason: web
          ? 'Query needs current or missing information — combining notes, model knowledge, and live web.'
          : hasNotes
              ? 'Personal notes first, then model knowledge to teach complete concepts.'
              : 'No notes attached — teaching from model knowledge${hasCourse ? ' and the course outline' : ''}.',
    );
  }

  String cacheKeyFor(String documentId) => 'knowledge_$documentId';

  HierarchicalDocumentModel? cachedKnowledge(String documentId) {
    if (_memoryCache.containsKey(documentId)) return _memoryCache[documentId];
    final raw = HiveStorage.getCachedResponse(cacheKeyFor(documentId));
    if (raw == null || raw.isEmpty) return null;
    try {
      final model = HierarchicalDocumentModel.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
      _memoryCache[documentId] = model;
      return model;
    } catch (_) {
      return null;
    }
  }

  Future<void> persistKnowledge(HierarchicalDocumentModel model) async {
    _memoryCache[model.documentId] = model;
    try {
      await HiveStorage.cacheResponse(
        cacheKeyFor(model.documentId),
        jsonEncode(model.toJson()),
      );
    } catch (_) {}
  }

  /// LLM enrichment of an already-extracted document. Falls back silently.
  Future<UploadedDocument> enrichDocument(UploadedDocument doc) async {
    final apiKey = _ref.read(aiApiKeyProvider);
    if (apiKey == null || apiKey.isEmpty || doc.fullText.trim().isEmpty) {
      return doc;
    }

    final cached = cachedKnowledge(doc.id);
    if (cached != null && cached.glossary.isNotEmpty && cached.courseOutline != null) {
      return _applyKnowledge(doc, cached);
    }

    try {
      final provider = GeminiProvider(AIConfig(
        providerType: AIProviderType.gemini,
        apiKey: apiKey,
        model: 'gemini-3.8-flash',
        temperature: 0.2,
        maxTokens: 4096,
      ));

      final excerpt = doc.fullText.length > 14000
          ? '${doc.fullText.substring(0, 14000)}\n\n[truncated]'
          : doc.fullText;

      final response = await provider.complete(AIRequest(messages: [
        const AIMessage(
          role: AIRole.system,
          content:
              'You are StudyMate AI knowledge compiler. Convert study material into structured JSON only. No markdown.',
        ),
        AIMessage(
          role: AIRole.user,
          content: '''Extract personal knowledge from this document.

FILE: ${doc.fileName}

MATERIAL:
$excerpt

Return JSON with this shape:
{
  "documentOverview": "2-4 sentence executive summary",
  "courseTitle": "suggested course name",
  "units": [{"title": "Unit 1 name", "topics": ["topic a", "topic b"]}],
  "topics": ["..."],
  "subtopics": ["..."],
  "glossary": [{"term": "", "definition": "", "context": ""}],
  "examples": ["..."],
  "applications": ["..."],
  "formulas": [{"name": "", "expression": "", "explanation": ""}],
  "algorithms": ["..."],
  "processes": ["..."],
  "relationships": [{"sourceConcept": "", "targetConcept": "", "relationshipType": "prerequisite|extends|contrasts|implements", "explanation": ""}],
  "keywords": ["..."],
  "importantFacts": ["..."],
  "faqs": ["Q: ... A: ..."],
  "examTips": ["..."],
  "examTraps": ["..."],
  "commonMistakes": ["..."],
  "memoryTricks": ["..."],
  "mcqs": [{"question": "", "options": ["A","B","C","D"], "correctIndex": 0, "explanation": ""}],
  "flashcards": [{"type": "definition|explanation|application|comparison|example|memoryTrick|examTip", "front": "", "back": "", "difficulty": "Easy|Medium|Hard", "conceptTitle": ""}],
  "mindMapNodes": [{"id": "root", "label": "", "parentId": "", "category": "topic", "description": "", "dependencies": [], "examples": [], "applications": [], "connections": []}],
  "likelyQuestions": ["..."],
  "examWeightage": [{"topic": "", "estimatedWeightagePercent": 20, "frequencyTier": "High", "typicalExamQuestions": [], "commonPitfalls": []}]
}''',
        ),
      ]));

      final json = _decodeJson(response.content);
      if (json == null) return doc;

      final knowledge = _mergeJsonIntoModel(doc, json);
      await persistKnowledge(knowledge);
      return _applyKnowledge(doc, knowledge);
    } catch (_) {
      return doc;
    }
  }

  UploadedDocument _applyKnowledge(
    UploadedDocument doc,
    HierarchicalDocumentModel knowledge,
  ) {
    final concepts = knowledge.glossary.isNotEmpty
        ? knowledge.glossary.take(12).map((g) {
            return ExtractedConcept(
              id: 'concept_${g.term.hashCode.abs()}',
              title: g.term,
              description: g.definition,
              initialMastery: 0.45,
              importanceScore: 5,
              keyPoints: [g.context, ...knowledge.importantFacts.take(2)],
            );
          }).toList()
        : doc.concepts;

    final flashcards = knowledge.knowledgeFlashcards.isNotEmpty
        ? knowledge.knowledgeFlashcards.map((m) => ExtractedFlashcard(
              id: m['id'] ?? 'fc_${(m['front'] ?? '').hashCode.abs()}',
              front: m['front'] ?? '',
              back: m['back'] ?? '',
              conceptTitle: m['conceptTitle'] ?? m['type'] ?? 'Concept',
              cardType: m['type'] ?? 'definition',
              difficulty: m['difficulty'] ?? 'Medium',
            )).toList()
        : doc.flashcards;
    final quizzes = knowledge.knowledgeMcqs.isNotEmpty
        ? knowledge.knowledgeMcqs.map((m) => ExtractedQuizQuestion(
              id: m['id'] ?? 'quiz_${(m['question'] ?? '').hashCode.abs()}',
              question: m['question'] ?? '',
              options: List<String>.from(m['options'] ?? const []),
              correctIndex: (m['correctIndex'] as num?)?.toInt() ?? 0,
              explanation: m['explanation'] ?? '',
              conceptTitle: m['conceptTitle'] ?? 'Concept',
              questionType: m['questionType'] ?? 'mcq',
            )).toList()
        : doc.quizzes;

    final summary = ExtractedSummary(
      title: knowledge.courseOutline?.title ?? doc.summary.title,
      overview: knowledge.documentOverview.isNotEmpty
          ? knowledge.documentOverview
          : doc.summary.overview,
      keyTakeaways: knowledge.importantFacts.isNotEmpty
          ? knowledge.importantFacts.take(8).toList()
          : doc.summary.keyTakeaways,
      coreTheorems: knowledge.formulas
          .map((f) => '${f.name}: ${f.expression}')
          .toList(),
      examTraps: knowledge.examTraps.isNotEmpty
          ? knowledge.examTraps
          : doc.summary.examTraps,
    );

    return doc.copyWith(
      concepts: concepts,
      flashcards: flashcards,
      quizzes: quizzes,
      summary: summary,
      hierarchicalModel: knowledge,
    );
  }

  HierarchicalDocumentModel _mergeJsonIntoModel(
    UploadedDocument doc,
    Map<String, dynamic> json,
  ) {
    final existing = doc.hierarchicalModel;
    final unitsJson = json['units'] as List? ?? [];
    final outline = CourseOutline(
      id: 'course_${doc.id}',
      title: (json['courseTitle'] as String?)?.trim().isNotEmpty == true
          ? json['courseTitle'] as String
          : (existing?.courseOutline?.title ??
              doc.fileName.replaceAll(RegExp(r'\.[a-zA-Z0-9]+$'), '')),
      description: (json['documentOverview'] as String?) ??
          existing?.documentOverview ??
          '',
      documentIds: [doc.id],
      units: [
        for (var i = 0; i < unitsJson.length; i++)
          CourseUnitNode(
            id: 'unit_${i + 1}',
            title: (unitsJson[i] as Map)['title']?.toString() ?? 'Unit ${i + 1}',
            topics: [
              for (var j = 0;
                  j < (((unitsJson[i] as Map)['topics'] as List?) ?? []).length;
                  j++)
                CourseTopicNode(
                  id: 'topic_${i + 1}_$j',
                  title: ((unitsJson[i] as Map)['topics'] as List)[j].toString(),
                ),
            ],
          ),
      ],
    );

    List<ExtractedDefinition> glossary = [
      ...(json['glossary'] as List? ?? []).map((g) {
        final m = Map<String, dynamic>.from(g as Map);
        return ExtractedDefinition(
          term: m['term'] ?? '',
          definition: m['definition'] ?? '',
          context: m['context'] ?? '',
          pageNumber: 1,
        );
      }),
    ];
    if (glossary.isEmpty) glossary = existing?.glossary ?? const [];

    final formulas = [
      ...(json['formulas'] as List? ?? []).map((f) {
        final m = Map<String, dynamic>.from(f as Map);
        return ExtractedFormula(
          name: m['name'] ?? '',
          expression: m['expression'] ?? '',
          explanation: m['explanation'] ?? '',
          pageNumber: 1,
        );
      }),
    ];

    final relationships = [
      ...(json['relationships'] as List? ?? []).map((r) {
        final m = Map<String, dynamic>.from(r as Map);
        return ConceptRelationship(
          sourceConcept: m['sourceConcept'] ?? '',
          targetConcept: m['targetConcept'] ?? '',
          relationshipType: m['relationshipType'] ?? 'extends',
          explanation: m['explanation'] ?? '',
        );
      }),
    ];

    final mindMapNodes = [
      ...(json['mindMapNodes'] as List? ?? []).map((n) {
        return MindMapNode.fromJson(Map<String, dynamic>.from(n as Map));
      }),
    ];

    final flashcards = [
      ...(json['flashcards'] as List? ?? []).map((f) {
        final m = Map<String, dynamic>.from(f as Map);
        return {
          'id': 'fc_${(m['front'] ?? '').hashCode.abs()}',
          'front': m['front'] ?? '',
          'back': m['back'] ?? '',
          'conceptTitle': m['conceptTitle'] ?? m['type'] ?? 'Concept',
          'type': m['type'] ?? 'definition',
          'difficulty': m['difficulty'] ?? 'Medium',
        };
      }),
    ];

    final mcqs = [
      ...(json['mcqs'] as List? ?? []).map((q) {
        final m = Map<String, dynamic>.from(q as Map);
        return {
          'id': 'quiz_${(m['question'] ?? '').hashCode.abs()}',
          'question': m['question'] ?? '',
          'options': List<String>.from(m['options'] ?? const []),
          'correctIndex': (m['correctIndex'] as num?)?.toInt() ?? 0,
          'explanation': m['explanation'] ?? '',
          'conceptTitle': m['conceptTitle'] ?? 'Concept',
          'questionType': m['questionType'] ?? 'mcq',
        };
      }),
    ];

    final weightage = [
      ...(json['examWeightage'] as List? ?? []).map((w) {
        return ExamWeightageTopic.fromJson(Map<String, dynamic>.from(w as Map));
      }),
    ];

    return HierarchicalDocumentModel(
      documentId: doc.id,
      fileName: doc.fileName,
      totalPages: existing?.totalPages ?? 1,
      documentOverview: (json['documentOverview'] as String?) ??
          existing?.documentOverview ??
          '',
      chapters: existing?.chapters ?? const [],
      formulas: formulas.isNotEmpty ? formulas : (existing?.formulas ?? const []),
      glossary: glossary,
      relationships:
          relationships.isNotEmpty ? relationships : (existing?.relationships ?? const []),
      examWeightage:
          weightage.isNotEmpty ? weightage : (existing?.examWeightage ?? const []),
      learningObjectives: List<String>.from(json['likelyQuestions'] ?? existing?.learningObjectives ?? const []),
      realWorldApplications: List<String>.from(json['applications'] ?? existing?.realWorldApplications ?? const []),
      topics: List<String>.from(json['topics'] ?? existing?.topics ?? const []),
      subtopics: List<String>.from(json['subtopics'] ?? existing?.subtopics ?? const []),
      examples: List<String>.from(json['examples'] ?? existing?.examples ?? const []),
      processes: List<String>.from(json['processes'] ?? existing?.processes ?? const []),
      algorithms: List<String>.from(json['algorithms'] ?? existing?.algorithms ?? const []),
      tables: existing?.tables ?? const [],
      keywords: List<String>.from(json['keywords'] ?? existing?.keywords ?? const []),
      importantFacts: List<String>.from(json['importantFacts'] ?? existing?.importantFacts ?? const []),
      dates: existing?.dates ?? const [],
      diagrams: existing?.diagrams ?? const [],
      comparisons: existing?.comparisons ?? const [],
      causeAndEffects: existing?.causeAndEffects ?? const [],
      advantages: existing?.advantages ?? const [],
      disadvantages: existing?.disadvantages ?? const [],
      examTraps: List<String>.from(json['examTraps'] ?? existing?.examTraps ?? const []),
      commonMistakes: List<String>.from(json['commonMistakes'] ?? existing?.commonMistakes ?? const []),
      faqs: List<String>.from(json['faqs'] ?? existing?.faqs ?? const []),
      longAnswerTopics: List<String>.from(json['likelyQuestions'] ?? existing?.longAnswerTopics ?? const []),
      shortAnswerTopics: existing?.shortAnswerTopics ?? const [],
      vivaQuestions: existing?.vivaQuestions ?? const [],
      memoryTricks: List<String>.from(json['memoryTricks'] ?? existing?.memoryTricks ?? const []),
      mindMapNodes: mindMapNodes.isNotEmpty ? mindMapNodes : (existing?.mindMapNodes ?? const []),
      courseOutline: outline.units.isNotEmpty ? outline : existing?.courseOutline,
      knowledgeFlashcards: flashcards,
      knowledgeMcqs: mcqs,
      examTips: List<String>.from(json['examTips'] ?? const []),
    );
  }

  Map<String, dynamic>? _decodeJson(String raw) {
    var text = raw.trim();
    final fence = RegExp(r'```(?:json)?\s*([\s\S]*?)```');
    final match = fence.firstMatch(text);
    if (match != null) text = match.group(1)!.trim();
    final start = text.indexOf('{');
    final end = text.lastIndexOf('}');
    if (start < 0 || end <= start) return null;
    try {
      return jsonDecode(text.substring(start, end + 1)) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }
}

final knowledgeEngineProvider = Provider<KnowledgeEngine>((ref) {
  return KnowledgeEngine(ref);
});
