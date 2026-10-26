import 'package:drift/drift.dart';
import 'connection/connection.dart';

import 'tables/semesters_table.dart';
import 'tables/subjects_table.dart';
import 'tables/units_table.dart';
import 'tables/topics_table.dart';
import 'tables/resources_table.dart';
import 'tables/flashcards_table.dart';
import 'tables/quizzes_table.dart';
import 'tables/conversations_table.dart';
import 'tables/analytics_table.dart';
import 'tables/micro_concepts_table.dart';
import 'tables/concept_dependencies_table.dart';
import 'tables/study_dna_table.dart';
import 'tables/learning_timeline_table.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Semesters,
    Subjects,
    Units,
    Topics,
    MicroConcepts,
    ConceptDependencies,
    StudyDnaEntries,
    LearningTimelineEntries,
    LearningResources,
    ResourceChunks,
    Flashcards,
    Quizzes,
    QuizQuestions,
    QuizAttempts,
    Conversations,
    Messages,
    StudySessions,
    DailyAnalytics,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
    onUpgrade: (m, from, to) async {
      // Future migrations go here
    },
  );
}

