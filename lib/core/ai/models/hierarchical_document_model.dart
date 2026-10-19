
/// Represents a detected chapter / major unit across a document
class DocumentChapter {
  final String id;
  final String title;
  final int startPage;
  final int endPage;
  final String summary;
  final List<String> keyLearningObjectives;
  final List<DocumentSection> sections;

  const DocumentChapter({
    required this.id,
    required this.title,
    required this.startPage,
    required this.endPage,
    required this.summary,
    this.keyLearningObjectives = const [],
    this.sections = const [],
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'startPage': startPage,
    'endPage': endPage,
    'summary': summary,
    'keyLearningObjectives': keyLearningObjectives,
    'sections': sections.map((s) => s.toJson()).toList(),
  };

  factory DocumentChapter.fromJson(Map<String, dynamic> json) => DocumentChapter(
    id: json['id'] ?? '',
    title: json['title'] ?? '',
    startPage: (json['startPage'] as num?)?.toInt() ?? 1,
    endPage: (json['endPage'] as num?)?.toInt() ?? 1,
    summary: json['summary'] ?? '',
    keyLearningObjectives: List<String>.from(json['keyLearningObjectives'] ?? []),
    sections: (json['sections'] as List? ?? []).map((s) => DocumentSection.fromJson(Map<String, dynamic>.from(s))).toList(),
  );
}

/// Represents a detected section within a chapter
class DocumentSection {
  final String id;
  final String title;
  final int pageNumber;
  final String summary;
  final List<String> coreTheorems;
  final List<String> detectedFormulas;
  final List<String> detectedCodeSnippets;
  final List<String> detectedTables;
  final List<String> detectedDiagrams;

  const DocumentSection({
    required this.id,
    required this.title,
    required this.pageNumber,
    required this.summary,
    this.coreTheorems = const [],
    this.detectedFormulas = const [],
    this.detectedCodeSnippets = const [],
    this.detectedTables = const [],
    this.detectedDiagrams = const [],
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'pageNumber': pageNumber,
    'summary': summary,
    'coreTheorems': coreTheorems,
    'detectedFormulas': detectedFormulas,
    'detectedCodeSnippets': detectedCodeSnippets,
    'detectedTables': detectedTables,
    'detectedDiagrams': detectedDiagrams,
  };

  factory DocumentSection.fromJson(Map<String, dynamic> json) => DocumentSection(
    id: json['id'] ?? '',
    title: json['title'] ?? '',
    pageNumber: (json['pageNumber'] as num?)?.toInt() ?? 1,
    summary: json['summary'] ?? '',
    coreTheorems: List<String>.from(json['coreTheorems'] ?? []),
    detectedFormulas: List<String>.from(json['detectedFormulas'] ?? []),
    detectedCodeSnippets: List<String>.from(json['detectedCodeSnippets'] ?? []),
    detectedTables: List<String>.from(json['detectedTables'] ?? []),
    detectedDiagrams: List<String>.from(json['detectedDiagrams'] ?? []),
  );
}

/// Key formula extracted from the material
class ExtractedFormula {
  final String name;
  final String expression;
  final String explanation;
  final int pageNumber;

  const ExtractedFormula({
    required this.name,
    required this.expression,
    required this.explanation,
    required this.pageNumber,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'expression': expression,
    'explanation': explanation,
    'pageNumber': pageNumber,
  };

  factory ExtractedFormula.fromJson(Map<String, dynamic> json) => ExtractedFormula(
    name: json['name'] ?? '',
    expression: json['expression'] ?? '',
    explanation: json['explanation'] ?? '',
    pageNumber: (json['pageNumber'] as num?)?.toInt() ?? 1,
  );
}

/// Important definition / glossary term extracted from the material
class ExtractedDefinition {
  final String term;
  final String definition;
  final String context;
  final int pageNumber;

  const ExtractedDefinition({
    required this.term,
    required this.definition,
    required this.context,
    required this.pageNumber,
  });

  Map<String, dynamic> toJson() => {
    'term': term,
    'definition': definition,
    'context': context,
    'pageNumber': pageNumber,
  };

  factory ExtractedDefinition.fromJson(Map<String, dynamic> json) => ExtractedDefinition(
    term: json['term'] ?? '',
    definition: json['definition'] ?? '',
    context: json['context'] ?? '',
    pageNumber: (json['pageNumber'] as num?)?.toInt() ?? 1,
  );
}

/// Semantic relationship between two concepts in the document DAG
class ConceptRelationship {
  final String sourceConcept;
  final String targetConcept;
  final String relationshipType; // 'prerequisite' | 'extends' | 'contrasts' | 'implements'
  final String explanation;

  const ConceptRelationship({
    required this.sourceConcept,
    required this.targetConcept,
    required this.relationshipType,
    required this.explanation,
  });

  Map<String, dynamic> toJson() => {
    'sourceConcept': sourceConcept,
    'targetConcept': targetConcept,
    'relationshipType': relationshipType,
    'explanation': explanation,
  };

  factory ConceptRelationship.fromJson(Map<String, dynamic> json) => ConceptRelationship(
    sourceConcept: json['sourceConcept'] ?? '',
    targetConcept: json['targetConcept'] ?? '',
    relationshipType: json['relationshipType'] ?? '',
    explanation: json['explanation'] ?? '',
  );
}

/// Exam weightage & frequency intelligence derived from deep analysis
class ExamWeightageTopic {
  final String topic;
  final double estimatedWeightagePercent;
  final String frequencyTier; // 'Very High' | 'High' | 'Medium' | 'Low'
  final List<String> typicalExamQuestions;
  final List<String> commonPitfalls;

  const ExamWeightageTopic({
    required this.topic,
    required this.estimatedWeightagePercent,
    required this.frequencyTier,
    this.typicalExamQuestions = const [],
    this.commonPitfalls = const [],
  });

  Map<String, dynamic> toJson() => {
    'topic': topic,
    'estimatedWeightagePercent': estimatedWeightagePercent,
    'frequencyTier': frequencyTier,
    'typicalExamQuestions': typicalExamQuestions,
    'commonPitfalls': commonPitfalls,
  };

  factory ExamWeightageTopic.fromJson(Map<String, dynamic> json) => ExamWeightageTopic(
    topic: json['topic'] ?? '',
    estimatedWeightagePercent: (json['estimatedWeightagePercent'] as num?)?.toDouble() ?? 10.0,
    frequencyTier: json['frequencyTier'] ?? 'Medium',
    typicalExamQuestions: List<String>.from(json['typicalExamQuestions'] ?? []),
    commonPitfalls: List<String>.from(json['commonPitfalls'] ?? []),
  );
}

/// Structured comparison extracted between two related paradigms/concepts
class ExtractedComparison {
  final String conceptA;
  final String conceptB;
  final List<String> pointsOfComparison;
  final String keyDifference;

  const ExtractedComparison({
    required this.conceptA,
    required this.conceptB,
    required this.pointsOfComparison,
    required this.keyDifference,
  });

  Map<String, dynamic> toJson() => {
    'conceptA': conceptA,
    'conceptB': conceptB,
    'pointsOfComparison': pointsOfComparison,
    'keyDifference': keyDifference,
  };

  factory ExtractedComparison.fromJson(Map<String, dynamic> json) => ExtractedComparison(
    conceptA: json['conceptA'] ?? '',
    conceptB: json['conceptB'] ?? '',
    pointsOfComparison: List<String>.from(json['pointsOfComparison'] ?? []),
    keyDifference: json['keyDifference'] ?? '',
  );
}

/// Mind map node with hierarchical relationships, dependencies, and examples
class MindMapNode {
  final String id;
  final String label;
  final String parentId;
  final String category; // 'topic' | 'subtopic' | 'concept' | 'example' | 'application'
  final String description;
  final List<String> dependencies;
  final List<String> examples;
  final List<String> applications;
  final List<String> connections;

  const MindMapNode({
    required this.id,
    required this.label,
    required this.parentId,
    this.category = 'concept',
    this.description = '',
    this.dependencies = const [],
    this.examples = const [],
    this.applications = const [],
    this.connections = const [],
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
    'parentId': parentId,
    'category': category,
    'description': description,
    'dependencies': dependencies,
    'examples': examples,
    'applications': applications,
    'connections': connections,
  };

  factory MindMapNode.fromJson(Map<String, dynamic> json) => MindMapNode(
    id: json['id'] ?? '',
    label: json['label'] ?? '',
    parentId: json['parentId'] ?? '',
    category: json['category'] ?? 'concept',
    description: json['description'] ?? '',
    dependencies: List<String>.from(json['dependencies'] ?? []),
    examples: List<String>.from(json['examples'] ?? []),
    applications: List<String>.from(json['applications'] ?? []),
    connections: List<String>.from(json['connections'] ?? []),
  );
}

/// Comprehensive, notebook-grade AI structured knowledge base.
/// Contains all 26 dimensions required by the AI-first architecture.
class HierarchicalDocumentModel {
  final String documentId;
  final String fileName;
  final int totalPages;
  final String documentOverview;
  final List<DocumentChapter> chapters;
  final List<ExtractedFormula> formulas;
  final List<ExtractedDefinition> glossary;
  final List<ConceptRelationship> relationships;
  final List<ExamWeightageTopic> examWeightage;
  final List<String> learningObjectives;
  final List<String> realWorldApplications;

  // ── AI-First Dimensions ──────────────────────────────────────────────────
  final List<String> topics;
  final List<String> subtopics;
  final List<String> examples;
  final List<String> processes;
  final List<String> algorithms;
  final List<String> tables;
  final List<String> keywords;
  final List<String> importantFacts;
  final List<String> dates;
  final List<String> diagrams;
  final List<ExtractedComparison> comparisons;
  final List<String> causeAndEffects;
  final List<String> advantages;
  final List<String> disadvantages;
  final List<String> examTraps;
  final List<String> commonMistakes;
  final List<String> faqs;
  final List<String> longAnswerTopics;
  final List<String> shortAnswerTopics;
  final List<String> vivaQuestions;
  final List<String> memoryTricks;
  final List<MindMapNode> mindMapNodes;

  const HierarchicalDocumentModel({
    required this.documentId,
    required this.fileName,
    required this.totalPages,
    required this.documentOverview,
    this.chapters = const [],
    this.formulas = const [],
    this.glossary = const [],
    this.relationships = const [],
    this.examWeightage = const [],
    this.learningObjectives = const [],
    this.realWorldApplications = const [],
    this.topics = const [],
    this.subtopics = const [],
    this.examples = const [],
    this.processes = const [],
    this.algorithms = const [],
    this.tables = const [],
    this.keywords = const [],
    this.importantFacts = const [],
    this.dates = const [],
    this.diagrams = const [],
    this.comparisons = const [],
    this.causeAndEffects = const [],
    this.advantages = const [],
    this.disadvantages = const [],
    this.examTraps = const [],
    this.commonMistakes = const [],
    this.faqs = const [],
    this.longAnswerTopics = const [],
    this.shortAnswerTopics = const [],
    this.vivaQuestions = const [],
    this.memoryTricks = const [],
    this.mindMapNodes = const [],
  });

  Map<String, dynamic> toJson() => {
    'documentId': documentId,
    'fileName': fileName,
    'totalPages': totalPages,
    'documentOverview': documentOverview,
    'chapters': chapters.map((c) => c.toJson()).toList(),
    'formulas': formulas.map((f) => f.toJson()).toList(),
    'glossary': glossary.map((g) => g.toJson()).toList(),
    'relationships': relationships.map((r) => r.toJson()).toList(),
    'examWeightage': examWeightage.map((w) => w.toJson()).toList(),
    'learningObjectives': learningObjectives,
    'realWorldApplications': realWorldApplications,
    'topics': topics,
    'subtopics': subtopics,
    'examples': examples,
    'processes': processes,
    'algorithms': algorithms,
    'tables': tables,
    'keywords': keywords,
    'importantFacts': importantFacts,
    'dates': dates,
    'diagrams': diagrams,
    'comparisons': comparisons.map((cp) => cp.toJson()).toList(),
    'causeAndEffects': causeAndEffects,
    'advantages': advantages,
    'disadvantages': disadvantages,
    'examTraps': examTraps,
    'commonMistakes': commonMistakes,
    'faqs': faqs,
    'longAnswerTopics': longAnswerTopics,
    'shortAnswerTopics': shortAnswerTopics,
    'vivaQuestions': vivaQuestions,
    'memoryTricks': memoryTricks,
    'mindMapNodes': mindMapNodes.map((n) => n.toJson()).toList(),
  };

  factory HierarchicalDocumentModel.fromJson(Map<String, dynamic> json) => HierarchicalDocumentModel(
    documentId: json['documentId'] ?? '',
    fileName: json['fileName'] ?? '',
    totalPages: (json['totalPages'] as num?)?.toInt() ?? 1,
    documentOverview: json['documentOverview'] ?? '',
    chapters: (json['chapters'] as List? ?? []).map((c) => DocumentChapter.fromJson(Map<String, dynamic>.from(c))).toList(),
    formulas: (json['formulas'] as List? ?? []).map((f) => ExtractedFormula.fromJson(Map<String, dynamic>.from(f))).toList(),
    glossary: (json['glossary'] as List? ?? []).map((g) => ExtractedDefinition.fromJson(Map<String, dynamic>.from(g))).toList(),
    relationships: (json['relationships'] as List? ?? []).map((r) => ConceptRelationship.fromJson(Map<String, dynamic>.from(r))).toList(),
    examWeightage: (json['examWeightage'] as List? ?? []).map((w) => ExamWeightageTopic.fromJson(Map<String, dynamic>.from(w))).toList(),
    learningObjectives: List<String>.from(json['learningObjectives'] ?? []),
    realWorldApplications: List<String>.from(json['realWorldApplications'] ?? []),
    topics: List<String>.from(json['topics'] ?? []),
    subtopics: List<String>.from(json['subtopics'] ?? []),
    examples: List<String>.from(json['examples'] ?? []),
    processes: List<String>.from(json['processes'] ?? []),
    algorithms: List<String>.from(json['algorithms'] ?? []),
    tables: List<String>.from(json['tables'] ?? []),
    keywords: List<String>.from(json['keywords'] ?? []),
    importantFacts: List<String>.from(json['importantFacts'] ?? []),
    dates: List<String>.from(json['dates'] ?? []),
    diagrams: List<String>.from(json['diagrams'] ?? []),
    comparisons: (json['comparisons'] as List? ?? []).map((cp) => ExtractedComparison.fromJson(Map<String, dynamic>.from(cp))).toList(),
    causeAndEffects: List<String>.from(json['causeAndEffects'] ?? []),
    advantages: List<String>.from(json['advantages'] ?? []),
    disadvantages: List<String>.from(json['disadvantages'] ?? []),
    examTraps: List<String>.from(json['examTraps'] ?? []),
    commonMistakes: List<String>.from(json['commonMistakes'] ?? []),
    faqs: List<String>.from(json['faqs'] ?? []),
    longAnswerTopics: List<String>.from(json['longAnswerTopics'] ?? []),
    shortAnswerTopics: List<String>.from(json['shortAnswerTopics'] ?? []),
    vivaQuestions: List<String>.from(json['vivaQuestions'] ?? []),
    memoryTricks: List<String>.from(json['memoryTricks'] ?? []),
    mindMapNodes: (json['mindMapNodes'] as List? ?? []).map((n) => MindMapNode.fromJson(Map<String, dynamic>.from(n))).toList(),
  );

  /// Generate a concise yet holistic semantic outline for reasoning prompts
  String generateHolisticReasoningPrompt() {
    final buffer = StringBuffer();
    buffer.writeln('DOCUMENT HIERARCHICAL KNOWLEDGE BASE: "$fileName" ($totalPages Pages)');
    buffer.writeln('GLOBAL OVERVIEW: $documentOverview');
    buffer.writeln();

    if (chapters.isNotEmpty) {
      buffer.writeln('CHAPTER OUTLINE & SECTIONS:');
      for (final ch in chapters) {
        buffer.writeln('• [Ch: ${ch.title}] (Pages ${ch.startPage}-${ch.endPage}): ${ch.summary}');
        for (final sec in ch.sections) {
          buffer.writeln('   - [Sec: ${sec.title}] (p.${sec.pageNumber}): ${sec.summary}');
          if (sec.detectedFormulas.isNotEmpty) {
            buffer.writeln('     Key Formula: ${sec.detectedFormulas.first}');
          }
        }
      }
      buffer.writeln();
    }

    if (formulas.isNotEmpty) {
      buffer.writeln('FORMULA SHEET:');
      for (final f in formulas.take(6)) {
        buffer.writeln('• ${f.name}: ${f.expression} (${f.explanation})');
      }
      buffer.writeln();
    }

    if (glossary.isNotEmpty) {
      buffer.writeln('KEY DEFINITIONS:');
      for (final g in glossary.take(8)) {
        buffer.writeln('• ${g.term}: ${g.definition}');
      }
      buffer.writeln();
    }

    if (relationships.isNotEmpty) {
      buffer.writeln('CONCEPT RELATIONSHIPS:');
      for (final r in relationships.take(5)) {
        buffer.writeln('• ${r.sourceConcept} ${r.relationshipType} ${r.targetConcept} (${r.explanation})');
      }
      buffer.writeln();
    }

    if (examWeightage.isNotEmpty) {
      buffer.writeln('EXAM PREDICTOR & WEIGHTAGE:');
      for (final ew in examWeightage.take(4)) {
        buffer.writeln('• ${ew.topic} [${ew.frequencyTier} Priority - ~${ew.estimatedWeightagePercent.toInt()}% Weightage]');
      }
      buffer.writeln();
    }

    return buffer.toString().trim();
  }
}
