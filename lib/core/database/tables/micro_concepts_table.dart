import 'package:drift/drift.dart';

@DataClassName('MicroConceptEntry')
class MicroConcepts extends Table {
  TextColumn get id => text()();
  TextColumn get topicId => text()();
  TextColumn get subjectId => text()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  TextColumn get keyFormulasJson => text().withDefault(const Constant('[]'))();
  RealColumn get masteryScore => real().withDefault(const Constant(0.0))();
  RealColumn get confidenceScore => real().withDefault(const Constant(0.0))();
  RealColumn get stabilityFactor => real().withDefault(const Constant(1.0))();
  RealColumn get forgettingProbability => real().withDefault(const Constant(0.0))();
  IntColumn get revisionCount => integer().withDefault(const Constant(0))();
  RealColumn get quizAccuracy => real().withDefault(const Constant(0.0))();
  IntColumn get estimatedStudyMinutes => integer().withDefault(const Constant(15))();
  IntColumn get estimatedRevisionMinutes => integer().withDefault(const Constant(5))();
  DateTimeColumn get lastStudiedAt => dateTime().nullable()();
  DateTimeColumn get nextRevisionDue => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
