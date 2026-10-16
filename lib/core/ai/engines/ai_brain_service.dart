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
    var rows = await _db.select(_db.microConcepts).get();
    if (rows.isEmpty) {
      await initializeSeedDataIfEmpty('user_alex_chen');
      rows = await _db.select(_db.microConcepts).get();
    }
    return rows.map(_mapRowToMicroConcept).toList();
  }

  /// Automatically seeds realistic micro-concepts and timeline events if empty
  Future<void> initializeSeedDataIfEmpty(String userId) async {
    final count = await _db.microConcepts.count().getSingle();
    if (count > 0) return;

    final now = DateTime.now();

    final seedConcepts = [
      MicroConceptsCompanion.insert(
        id: 'c_acid',
        topicId: 'top_transactions',
        subjectId: 'sub_dbms',
        name: 'ACID Properties',
        description: const Value('Atomicity, Consistency, Isolation, and Durability mechanics in DBMS.'),
        keyFormulasJson: const Value('["Commit = Persistent WAL", "Rollback = Undo Log"]'),
        masteryScore: const Value(0.88),
        confidenceScore: const Value(0.90),
        stabilityFactor: const Value(4.5),
        forgettingProbability: const Value(0.08),
        revisionCount: const Value(3),
        quizAccuracy: const Value(0.92),
        estimatedStudyMinutes: const Value(20),
        estimatedRevisionMinutes: const Value(6),
        lastStudiedAt: Value(now.subtract(const Duration(days: 2))),
        createdAt: now.subtract(const Duration(days: 10)),
      ),
      MicroConceptsCompanion.insert(
        id: 'c_conflict_ser',
        topicId: 'top_transactions',
        subjectId: 'sub_dbms',
        name: 'Conflict Serializability',
        description: const Value('Precedence graph cycle detection and swap-equivalent schedules.'),
        keyFormulasJson: const Value('["Conflict operations: W(X)-R(X), R(X)-W(X), W(X)-W(X)"]'),
        masteryScore: const Value(0.71),
        confidenceScore: const Value(0.68),
        stabilityFactor: const Value(2.1),
        forgettingProbability: const Value(0.19),
        revisionCount: const Value(2),
        quizAccuracy: const Value(0.75),
        estimatedStudyMinutes: const Value(25),
        estimatedRevisionMinutes: const Value(8),
        lastStudiedAt: Value(now.subtract(const Duration(days: 3))),
        createdAt: now.subtract(const Duration(days: 8)),
      ),
      MicroConceptsCompanion.insert(
        id: 'c_2pl',
        topicId: 'top_transactions',
        subjectId: 'sub_dbms',
        name: 'Two-Phase Locking (Strict 2PL)',
        description: const Value('Growing and shrinking phases; preventing cascading rollbacks in concurrent transactions.'),
        keyFormulasJson: const Value('["Growing Phase: Only Acquire Locks", "Shrinking Phase: Only Release Locks"]'),
        masteryScore: const Value(0.64),
        confidenceScore: const Value(0.60),
        stabilityFactor: const Value(1.8),
        forgettingProbability: const Value(0.24),
        revisionCount: const Value(1),
        quizAccuracy: const Value(0.65),
        estimatedStudyMinutes: const Value(30),
        estimatedRevisionMinutes: const Value(10),
        lastStudiedAt: Value(now.subtract(const Duration(days: 4))),
        createdAt: now.subtract(const Duration(days: 7)),
      ),
      MicroConceptsCompanion.insert(
        id: 'c_deadlock',
        topicId: 'top_transactions',
        subjectId: 'sub_dbms',
        name: 'Deadlock: Wait-Die vs Wound-Wait',
        description: const Value('Timestamp-based preemption algorithms to prevent circular wait states.'),
        keyFormulasJson: const Value('["Wait-Die: Non-preemptive", "Wound-Wait: Preemptive"]'),
        masteryScore: const Value(0.52),
        confidenceScore: const Value(0.48),
        stabilityFactor: const Value(1.2),
        forgettingProbability: const Value(0.31),
        revisionCount: const Value(1),
        quizAccuracy: const Value(0.50),
        estimatedStudyMinutes: const Value(25),
        estimatedRevisionMinutes: const Value(9),
        lastStudiedAt: Value(now.subtract(const Duration(days: 6))),
        createdAt: now.subtract(const Duration(days: 7)),
      ),
      MicroConceptsCompanion.insert(
        id: 'c_normalization',
        topicId: 'top_relational',
        subjectId: 'sub_dbms',
        name: 'Normalization: 3NF vs BCNF',
        description: const Value('Functional dependencies, superkeys, and lossless decomposition.'),
        keyFormulasJson: const Value('["BCNF: X must be a superkey", "3NF: Y is prime attribute allowed"]'),
        masteryScore: const Value(0.41),
        confidenceScore: const Value(0.35),
        stabilityFactor: const Value(0.9),
        forgettingProbability: const Value(0.42),
        revisionCount: const Value(0),
        quizAccuracy: const Value(0.40),
        estimatedStudyMinutes: const Value(35),
        estimatedRevisionMinutes: const Value(12),
        lastStudiedAt: Value(now.subtract(const Duration(days: 8))),
        createdAt: now.subtract(const Duration(days: 8)),
      ),
      MicroConceptsCompanion.insert(
        id: 'c_bplus',
        topicId: 'top_indexing',
        subjectId: 'sub_dbms',
        name: 'B+ Tree Indexing & Search',
        description: const Value('Multi-level indexing, node splitting, and ranged query traversal.'),
        keyFormulasJson: const Value('["Height = ceil(log_B(N))", "Leaf nodes form linked list"]'),
        masteryScore: const Value(0.79),
        confidenceScore: const Value(0.82),
        stabilityFactor: const Value(3.8),
        forgettingProbability: const Value(0.11),
        revisionCount: const Value(3),
        quizAccuracy: const Value(0.84),
        estimatedStudyMinutes: const Value(30),
        estimatedRevisionMinutes: const Value(7),
        lastStudiedAt: Value(now.subtract(const Duration(days: 1))),
        createdAt: now.subtract(const Duration(days: 12)),
      ),
    ];

    for (final c in seedConcepts) {
      await _db.into(_db.microConcepts).insert(c);
    }

    await _db.into(_db.learningTimelineEntries).insert(
      LearningTimelineEntriesCompanion.insert(
        id: 'evt_init_1',
        userId: userId,
        conceptId: const Value('c_bplus'),
        topicId: const Value('top_indexing'),
        eventType: 'mastery_leap',
        deltaMastery: const Value(0.24),
        currentMastery: const Value(0.79),
        title: 'Mastery Leap: B+ Tree Indexing',
        description: 'Completed 6 active recall questions with 84% accuracy.',
        timestamp: now.subtract(const Duration(hours: 14)),
      ),
    );

    await _db.into(_db.learningTimelineEntries).insert(
      LearningTimelineEntriesCompanion.insert(
        id: 'evt_init_2',
        userId: userId,
        conceptId: const Value('c_normalization'),
        topicId: const Value('top_relational'),
        eventType: 'gap_detected',
        deltaMastery: const Value(-0.10),
        currentMastery: const Value(0.41),
        title: 'Cognitive Vulnerability: 3NF vs BCNF',
        description: 'Struggled with candidate key identification on 2 quiz questions.',
        timestamp: now.subtract(const Duration(days: 2)),
      ),
    );
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
