import 'dart:math' as math;
import '../../../features/micro_concept/domain/entities/micro_concept.dart';
import '../../../features/study_dna/domain/entities/study_dna.dart';

/// Engine 3: AI Prediction Engine
///
/// Continuous mathematical modeling for:
/// 1. Ebbinghaus forgetting probability R(t)
/// 2. Session cognitive fatigue and burnout risk
/// 3. High-yield concept triage for maximum exam score ROI
/// 4. Expected exam readiness score distribution
class AIPredictionEngine {
  const AIPredictionEngine();

  /// Calculates retrieval probability R(t) based on elapsed time and stability factor S:
  /// R(t) = exp( - (t - t_last) / (S * theta_DNA) )
  double calculateRetrievalProbability({
    required DateTime lastStudiedAt,
    required DateTime currentTimestamp,
    required double stabilityFactorDays,
    required double dnaRetentionMultiplier,
  }) {
    final elapsedHours = currentTimestamp.difference(lastStudiedAt).inMinutes / 60.0;
    final elapsedDays = elapsedHours / 24.0;

    if (elapsedDays <= 0) return 1.0;

    // S * theta_DNA gives personalized half-life scaling in days
    final effectiveStability = math.max(0.2, stabilityFactorDays * dnaRetentionMultiplier);
    final decayExponent = - (elapsedDays / effectiveStability);

    return math.exp(decayExponent).clamp(0.0, 1.0);
  }

  /// Calculates cognitive session fatigue index Phi(tau, k):
  /// Returns a normalized value between 0.0 (fresh) and 1.0 (exhausted).
  double calculateCognitiveFatigue({
    required int continuousMinutesStudied,
    required int optimalFocusMinutes,
    required double rollingAccuracyLastQuestions,
    double fatigueDecayRate = 0.04,
  }) {
    // Sigmoidal time decay
    final deltaMinutes = continuousMinutesStudied - optimalFocusMinutes;
    final timeFatigue = 1.0 / (1.0 + math.exp(-fatigueDecayRate * deltaMinutes));

    // Accuracy penalty
    final accuracyPenalty = (1.0 - rollingAccuracyLastQuestions.clamp(0.0, 1.0)) * 0.35;

    return (timeFatigue * 0.65 + accuracyPenalty).clamp(0.0, 1.0);
  }

  /// Calculates High-Yield Concept ROI:
  /// ROI(c) = (ExamWeight(c) * (1 - Mastery(c))) / EstimatedRevisionMinutes(c)
  double calculateConceptRoi({
    required double examWeight,
    required double currentMastery,
    required int estimatedRevisionMinutes,
  }) {
    final masteryGap = (1.0 - currentMastery).clamp(0.0, 1.0);
    final timeCost = math.max(1, estimatedRevisionMinutes);
    return (examWeight * masteryGap) / timeCost;
  }

  /// Triages micro-concepts by highest score yield per minute invested
  List<MicroConcept> rankHighYieldConcepts({
    required List<MicroConcept> concepts,
    required Map<String, double> examWeights, // conceptId -> weight (e.g. 1.0 to 5.0)
  }) {
    final sorted = List<MicroConcept>.from(concepts);
    sorted.sort((a, b) {
      final weightA = examWeights[a.id] ?? 1.0;
      final weightB = examWeights[b.id] ?? 1.0;
      final roiA = calculateConceptRoi(
        examWeight: weightA,
        currentMastery: a.masteryScore,
        estimatedRevisionMinutes: a.estimatedRevisionMinutes,
      );
      final roiB = calculateConceptRoi(
        examWeight: weightB,
        currentMastery: b.masteryScore,
        estimatedRevisionMinutes: b.estimatedRevisionMinutes,
      );
      return roiB.compareTo(roiA);
    });
    return sorted;
  }

  /// Estimates overall exam readiness score [0.0 - 100.0]
  double estimateExamReadiness({
    required List<MicroConcept> concepts,
    required Map<String, double> examWeights,
    required DateTime examDate,
    required DateTime currentDate,
    required StudyDna studyDna,
  }) {
    if (concepts.isEmpty) return 0.0;

    double weightedMasterySum = 0.0;
    double totalWeight = 0.0;

    for (final concept in concepts) {
      final weight = examWeights[concept.id] ?? 1.0;
      totalWeight += weight;

      // Project retention on exam date
      final lastStudied = concept.lastStudiedAt ?? currentDate.subtract(const Duration(days: 14));
      final retentionAtExam = calculateRetrievalProbability(
        lastStudiedAt: lastStudied,
        currentTimestamp: examDate,
        stabilityFactorDays: concept.stabilityFactor,
        dnaRetentionMultiplier: studyDna.retention.spacingMultiplier,
      );

      // Blended expected performance = current mastery * projected retention
      final projectedPerformance = concept.masteryScore * (0.6 + 0.4 * retentionAtExam);
      weightedMasterySum += projectedPerformance * weight;
    }

    if (totalWeight <= 0) return 0.0;
    return ((weightedMasterySum / totalWeight) * 100.0).clamp(0.0, 100.0);
  }
}
