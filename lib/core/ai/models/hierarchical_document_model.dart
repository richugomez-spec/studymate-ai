import 'package:flutter/foundation.dart';

/// Represents a detected chapter / major unit across a large document (100–500 pages)
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
}

/// Exam weightage & frequency intelligence derived from deep analysis
class ExamWeightageTopic {
  final String topic;
  final double estimatedWeightagePercent; // e.g. 25%
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
}

/// Deep comprehensive document intelligence model for large documents (100–500+ pages)
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
  });

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
