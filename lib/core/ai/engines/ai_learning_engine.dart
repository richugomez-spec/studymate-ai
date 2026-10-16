import '../../../features/micro_concept/domain/entities/micro_concept.dart';
import '../../../features/micro_concept/domain/entities/concept_dependency.dart';
import '../../../features/study_dna/domain/entities/study_dna.dart';

/// Result of a prerequisite validation on a micro-concept DAG
class PrerequisiteValidation {
  final bool isUnlocked;
  final MicroConcept targetConcept;
  final List<MicroConcept> blockedPrerequisites;
  final String statusMessage;

  const PrerequisiteValidation({
    required this.isUnlocked,
    required this.targetConcept,
    required this.blockedPrerequisites,
    required this.statusMessage,
  });
}

/// Model for the Daily Learning Mission
class DailyLearningMission {
  final String id;
  final String title;
  final String description;
  final List<MicroConcept> targetConcepts;
  final int estimatedMinutes;
  final int expectedMasteryGainPercent;
  final String subjectName;
  final String callToAction;

  const DailyLearningMission({
    required this.id,
    required this.title,
    required this.description,
    required this.targetConcepts,
    required this.estimatedMinutes,
    required this.expectedMasteryGainPercent,
    required this.subjectName,
    required this.callToAction,
  });
}

/// Engine 2: AI Learning Engine
///
/// Directs curriculum sequencing, prerequisite enforcement, and adaptive pedagogy.
class AILearningEngine {
  const AILearningEngine();

  /// Validates whether a micro-concept can be studied or if foundational prerequisites are missing.
  /// Standard mastery threshold for prerequisite nodes is 0.70 (70%).
  PrerequisiteValidation validatePrerequisites({
    required MicroConcept targetConcept,
    required List<MicroConcept> allConcepts,
    required List<ConceptDependency> dependencies,
    double masteryThreshold = 0.70,
  }) {
    final conceptMap = {for (final c in allConcepts) c.id: c};

    // Find all immediate prerequisites
    final prerequisiteIds = dependencies
        .where((d) => d.targetConceptId == targetConcept.id && d.dependencyType == 'prerequisite')
        .map((d) => d.sourceConceptId)
        .toList();

    final blocked = <MicroConcept>[];

    for (final pid in prerequisiteIds) {
      final prereqConcept = conceptMap[pid];
      if (prereqConcept != null && prereqConcept.masteryScore < masteryThreshold) {
        blocked.add(prereqConcept);
      }
    }

    if (blocked.isEmpty) {
      return PrerequisiteValidation(
        isUnlocked: true,
        targetConcept: targetConcept,
        blockedPrerequisites: const [],
        statusMessage: 'Ready to study: Foundations are solid.',
      );
    }

    final blockedNames = blocked.map((c) => c.name).join(', ');
    return PrerequisiteValidation(
      isUnlocked: false,
      targetConcept: targetConcept,
      blockedPrerequisites: blocked,
      statusMessage:
          'Prerequisite gap detected: Mastery in $blockedNames is below ${(masteryThreshold * 100).toInt()}%. Complete foundational review first.',
    );
  }

  /// Synthesizes the living Daily Learning Mission based on lowest mastery and highest forgetting risk
  DailyLearningMission generateDailyMission({
    required String subjectName,
    required List<MicroConcept> concepts,
    required StudyDna studyDna,
  }) {
    if (concepts.isEmpty) {
      return const DailyLearningMission(
        id: 'mission_default',
        title: 'Start Your First Learning Mission',
        description: 'Upload your first syllabus notes to activate your AI Learning OS.',
        targetConcepts: [],
        estimatedMinutes: 15,
        expectedMasteryGainPercent: 10,
        subjectName: 'Getting Started',
        callToAction: 'Upload Course Materials',
      );
    }

    // Sort concepts prioritizing:
    // 1. High forgetting probability (retention breach)
    // 2. Low mastery with prerequisites satisfied
    final sorted = List<MicroConcept>.from(concepts);
    sorted.sort((a, b) {
      // Prioritize imminent forgetting
      if (b.forgettingProbability != a.forgettingProbability) {
        return b.forgettingProbability.compareTo(a.forgettingProbability);
      }
      return a.masteryScore.compareTo(b.masteryScore);
    });

    final targetConcepts = sorted.take(2).toList();
    final totalMinutes = targetConcepts.fold<int>(0, (sum, c) => sum + c.estimatedRevisionMinutes);
    final focusMinutes = studyDna.temporal.focusDurationMinutes;
    final cappedMinutes = totalMinutes > 0 ? totalMinutes.clamp(10, focusMinutes + 10) : 18;

    final conceptNames = targetConcepts.map((c) => c.name).join(' & ');
    final primary = targetConcepts.first;
    final currentPct = (primary.masteryScore * 100).toInt();
    final targetPct = (currentPct + 20).clamp(75, 95);

    return DailyLearningMission(
      id: 'mission_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Master $conceptNames',
      description:
          'You have mastered $currentPct% of ${primary.name}. Spend approximately $cappedMinutes minutes focused revision to reach $targetPct% mastery.',
      targetConcepts: targetConcepts,
      estimatedMinutes: cappedMinutes,
      expectedMasteryGainPercent: targetPct - currentPct,
      subjectName: subjectName,
      callToAction: 'Start Targeted Mission',
    );
  }

  /// Synthesizes customized system instructions adapted to the student's Study DNA
  String buildPersonalizedSystemPrompt({
    required StudyDna studyDna,
    String? subjectName,
    String? topicName,
    List<String> weakConcepts = const [],
  }) {
    final depthInstruction = switch (studyDna.pedagogical.explanationDepth) {
      'concise' => 'Be concise, structured, and bullet-point oriented. Avoid conversational padding.',
      'analogy_driven' => 'Use intuitive analogies, visual metaphors, and real-world parallels for every abstract rule.',
      'first_principles' => 'Deconstruct concepts down to first principles. Explain the fundamental mechanics of why things work.',
      _ => 'Provide balanced, rigorous explanations appropriate for an undergraduate university exam.',
    };

    final pathwayInstruction = studyDna.pedagogical.deductiveVsInductive < 0.5
        ? 'Present a concrete, relatable example first BEFORE formalizing definitions or theorems.'
        : 'State the formal definition and rule first, followed immediately by rigorous application examples.';

    final visualInstruction = studyDna.sensory.visualWeight > 0.65
        ? 'Whenever explaining multi-step processes or architecture, include a Mermaid diagram (```mermaid) or comparison table.'
        : '';

    final contextSection = [
      if (subjectName != null) 'Subject: $subjectName',
      if (topicName != null) 'Current Topic: $topicName',
    ].join(' | ');

    final weakSection = weakConcepts.isNotEmpty
        ? '\nStudent has documented vulnerabilities in: ${weakConcepts.join(', ')}. Scrutinize these areas with extra clarity.'
        : '';

    return '''You are StudyMate AI, the student's personal AI Learning Operating System.
Your mission is not merely to answer queries, but to actively build synaptic retention and conceptual mastery.

$contextSection$weakSection

Pedagogical Directives:
- $depthInstruction
- $pathwayInstruction
$visualInstruction
- Conclude responses with a 1-question active recall drill to test comprehension.
- Never give passive text walls; maintain desirable difficulty with engaging questioning.''';
  }
}
