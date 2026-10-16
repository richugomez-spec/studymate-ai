import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../database/app_database.dart';
import 'ai_brain_service.dart';
import 'ai_learning_engine.dart';
import 'ai_prediction_engine.dart';
import '../../../features/study_dna/domain/entities/study_dna.dart';
import '../../../features/timeline/domain/entities/timeline_event.dart';

/// Database provider singleton
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

/// Engine 1: AI Brain Service Provider
final aiBrainServiceProvider = Provider<AIBrainService>((ref) {
  final db = ref.watch(databaseProvider);
  return AIBrainService(db);
});

/// Engine 2: AI Learning Engine Provider
final aiLearningEngineProvider = Provider<AILearningEngine>((ref) {
  return const AILearningEngine();
});

/// Engine 3: AI Prediction Engine Provider
final aiPredictionEngineProvider = Provider<AIPredictionEngine>((ref) {
  return const AIPredictionEngine();
});

/// Study DNA Provider
final studyDnaProvider = FutureProvider.family<StudyDna, String>((ref, userId) async {
  final brain = ref.watch(aiBrainServiceProvider);
  return brain.getStudyDna(userId);
});

/// Living Daily Learning Mission Provider
final dailyLearningMissionProvider = FutureProvider.family<DailyLearningMission?, String>((ref, userId) async {
  final brain = ref.watch(aiBrainServiceProvider);
  final learningEngine = ref.watch(aiLearningEngineProvider);

  final studyDna = await ref.watch(studyDnaProvider(userId).future);
  final concepts = await brain.getAllMicroConcepts();

  if (concepts.isEmpty) {
    return null;
  }

  return learningEngine.generateDailyMission(
    subjectName: 'Active Semester',
    concepts: concepts,
    studyDna: studyDna,
  );
});

/// Predictive Exam Readiness Provider
final examReadinessScoreProvider = FutureProvider.family<double, String>((ref, userId) async {
  final brain = ref.watch(aiBrainServiceProvider);
  final predictionEngine = ref.watch(aiPredictionEngineProvider);

  final studyDna = await ref.watch(studyDnaProvider(userId).future);
  final concepts = await brain.getAllMicroConcepts();

  if (concepts.isEmpty) return 0.0;

  return predictionEngine.estimateExamReadiness(
    concepts: concepts,
    examWeights: {for (final c in concepts) c.id: 2.0},
    examDate: DateTime.now().add(const Duration(days: 21)),
    currentDate: DateTime.now(),
    studyDna: studyDna,
  );
});

/// Learning Timeline Events Provider
final learningTimelineProvider = FutureProvider.family<List<TimelineEvent>, String>((ref, userId) async {
  final brain = ref.watch(aiBrainServiceProvider);
  return brain.getTimelineEvents(userId, limit: 30);
});
