import 'package:drift/drift.dart';

class Topics extends Table {
  TextColumn get id => text()();
  TextColumn get unitId => text()();
  TextColumn get subjectId => text()();
  TextColumn get userId => text()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('not_started'))();
  RealColumn get masteryScore => real().withDefault(const Constant(0.0))();
  IntColumn get weaknessFlag => integer().withDefault(const Constant(0))();
  BoolColumn get isAIProcessed => boolean().withDefault(const Constant(false))();
  TextColumn get conceptTagsJson => text().withDefault(const Constant('[]'))();
  TextColumn get learningObjectivesJson => text().withDefault(const Constant('[]'))();
  IntColumn get totalStudyMinutes => integer().withDefault(const Constant(0))();
  IntColumn get quizAttempts => integer().withDefault(const Constant(0))();
  RealColumn get averageQuizScore => real().withDefault(const Constant(0.0))();
  IntColumn get flashcardCount => integer().withDefault(const Constant(0))();
  IntColumn get chatMessageCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastStudiedAt => dateTime().nullable()();
  DateTimeColumn get nextRevisionDue => dateTime().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
