import 'dart:convert';
import 'package:drift/drift.dart';
import '../../database/app_database.dart';
import '../../../features/micro_concept/domain/entities/micro_concept.dart';
import '../../../features/study_dna/domain/entities/study_dna.dart';
import '../../../features/timeline/domain/entities/timeline_event.dart';

/// Engine 1: AI Brain Service
///
/// Persistent cognitive memory manager connecting the Drift database,
/// probabilistic mastery ledger, Study DNA profiles, and learning timeline events.
class AIBrainService {
  final AppDatabase _db;

  const AIBrainService(this._db);

  /// Fetch all micro-concepts for a subject
  Future<List<MicroConcept>> getMicroConceptsForSubject(String subjectId) async {
    final rows = await (_db.select(_db.microConcepts)
          ..where((t) => t.subjectId.equals(subjectId)))
        .get();

    return rows.map(_mapRowToMicroConcept).toList();
  }

  /// Fetch all micro-concepts across all subjects for a user
  Future<List<MicroConcept>> getAllMicroConcepts() async {
    // Purge any legacy dummy seed concepts if they exist in the local database
    await (_db.delete(_db.microConcepts)
          ..where((t) => t.id.isIn(const [
                'c_acid',
                'c_conflict_ser',
                'c_2pl',
                'c_deadlock',
                'c_normalization',
                'c_bplus',
              ])))
        .go();
    await (_db.delete(_db.learningTimelineEntries)
          ..where((t) => t.userId.equals('user_alex_chen')))
        .go();

    final rows = await _db.select(_db.microConcepts).get();
    return rows.map(_mapRowToMicroConcept).toList();
  }

  /// Update micro-concept mastery after an active recall event (quiz/flashcard)
  Future<void> recordActiveRecallAttempt({
    required String conceptId,
    required String userId,
    required bool isCorrect,
    required double confidenceSelfRating, // 0.0 - 1.0
    required int responseLatencySeconds,
  }) async {
    final existing = await (_db.select(_db.microConcepts)
          ..where((t) => t.id.equals(conceptId)))
        .getSingleOrNull();

    if (existing == null) return;

    final oldMastery = existing.masteryScore;
    final totalAttempts = existing.revisionCount + 1;

    // Adaptive SM-2 / Bayesian mastery adjustment
    final double masteryDelta;
    final double newStability;

    if (isCorrect) {
      // Reward based on confidence calibration
      final confidenceBonus = (confidenceSelfRating >= 0.7) ? 0.05 : 0.02;
      masteryDelta = ((1.0 - oldMastery) * 0.25) + confidenceBonus;
      // Exponentially scale stability half-life in days
      newStability = existing.stabilityFactor * 1.6;
    } else {
      // Penalty for incorrect recall
      masteryDelta = - (oldMastery * 0.20);
      // Reset stability to base 1 day
      newStability = 1.0;
    }

    final newMastery = (oldMastery + masteryDelta).clamp(0.0, 1.0);
    final now = DateTime.now();
    final nextRevision = now.add(Duration(days: newStability.round().clamp(1, 90)));

    // Update MicroConcept record
    await (_db.update(_db.microConcepts)..where((t) => t.id.equals(conceptId))).write(
      MicroConceptsCompanion(
        masteryScore: Value(newMastery),
        stabilityFactor: Value(newStability),
        forgettingProbability: const Value(0.05), // Reset immediately after recall
        revisionCount: Value(totalAttempts),
        lastStudiedAt: Value(now),
        nextRevisionDue: Value(nextRevision),
        updatedAt: Value(now),
      ),
    );

    // Record immutable Timeline Event
    final eventId = 'evt_${now.millisecondsSinceEpoch}_${conceptId.hashCode}';
    await _db.into(_db.learningTimelineEntries).insert(
      LearningTimelineEntriesCompanion(
        id: Value(eventId),
        userId: Value(userId),
        conceptId: Value(conceptId),
        topicId: Value(existing.topicId),
        eventType: Value(isCorrect ? 'mastery_leap' : 'gap_detected'),
        deltaMastery: Value(newMastery - oldMastery),
        currentMastery: Value(newMastery),
        title: Value(isCorrect ? 'Mastery Solidified: ${existing.name}' : 'Knowledge Gap: ${existing.name}'),
        description: Value(isCorrect
            ? 'Score elevated from ${(oldMastery * 100).toInt()}% to ${(newMastery * 100).toInt()}%.'
            : 'Struggled during recall drill. Review scheduled in next revision mission.'),
        payloadJson: Value(jsonEncode({
          'isCorrect': isCorrect,
          'latencySeconds': responseLatencySeconds,
          'confidenceSelfRating': confidenceSelfRating,
        })),
        timestamp: Value(now),
      ),
    );
  }

  /// Get Study DNA profile for user
  Future<StudyDna> getStudyDna(String userId) async {
    final row = await (_db.select(_db.studyDnaEntries)
          ..where((t) => t.userId.equals(userId)))
        .getSingleOrNull();

    if (row == null) {
      final defaultDna = StudyDna(userId: userId, updatedAt: DateTime.now());
      await saveStudyDna(defaultDna);
      return defaultDna;
    }

    try {
      return StudyDna(
        userId: row.userId,
        updatedAt: row.updatedAt,
        sensory: SensoryProfile.fromJson(jsonDecode(row.sensoryProfileJson) as Map<String, dynamic>),
        pedagogical: PedagogicalProfile.fromJson(jsonDecode(row.pedagogicalProfileJson) as Map<String, dynamic>),
        temporal: TemporalProfile.fromJson(jsonDecode(row.temporalProfileJson) as Map<String, dynamic>),
        retention: RetentionProfile.fromJson(jsonDecode(row.retentionProfileJson) as Map<String, dynamic>),
      );
    } catch (_) {
      return StudyDna(userId: userId, updatedAt: DateTime.now());
    }
  }

  /// Save or update Study DNA profile
  Future<void> saveStudyDna(StudyDna dna) async {
    await _db.into(_db.studyDnaEntries).insertOnConflictUpdate(
      StudyDnaEntriesCompanion(
        userId: Value(dna.userId),
        sensoryProfileJson: Value(jsonEncode(dna.sensory.toJson())),
        pedagogicalProfileJson: Value(jsonEncode(dna.pedagogical.toJson())),
        temporalProfileJson: Value(jsonEncode(dna.temporal.toJson())),
        retentionProfileJson: Value(jsonEncode(dna.retention.toJson())),
        updatedAt: Value(dna.updatedAt),
      ),
    );
  }

  /// Fetch learning timeline events
  Future<List<TimelineEvent>> getTimelineEvents(String userId, {int limit = 50}) async {
    final rows = await (_db.select(_db.learningTimelineEntries)
          ..where((t) => t.userId.equals(userId))
          ..orderBy([(t) => OrderingTerm.desc(t.timestamp)])
          ..limit(limit))
        .get();

    return rows.map((r) {
      Map<String, dynamic> payload = {};
      try {
        payload = jsonDecode(r.payloadJson) as Map<String, dynamic>;
      } catch (_) {}

      return TimelineEvent(
        id: r.id,
        userId: r.userId,
        eventType: r.eventType,
        title: r.title,
        description: r.description,
        timestamp: r.timestamp,
        conceptId: r.conceptId,
        topicId: r.topicId,
        deltaMastery: r.deltaMastery,
        currentMastery: r.currentMastery,
        payload: payload,
      );
    }).toList();
  }

  MicroConcept _mapRowToMicroConcept(MicroConceptEntry row) {
    List<String> formulas = [];
    try {
      formulas = List<String>.from(jsonDecode(row.keyFormulasJson) as List);
    } catch (_) {}

    return MicroConcept(
      id: row.id,
      topicId: row.topicId,
      subjectId: row.subjectId,
      name: row.name,
      description: row.description,
      keyFormulas: formulas,
      masteryScore: row.masteryScore,
      confidenceScore: row.confidenceScore,
      stabilityFactor: row.stabilityFactor,
      forgettingProbability: row.forgettingProbability,
      revisionCount: row.revisionCount,
      quizAccuracy: row.quizAccuracy,
      estimatedStudyMinutes: row.estimatedStudyMinutes,
      estimatedRevisionMinutes: row.estimatedRevisionMinutes,
      lastStudiedAt: row.lastStudiedAt,
      nextRevisionDue: row.nextRevisionDue,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }
}
