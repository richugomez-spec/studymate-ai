import 'package:drift/drift.dart';

@DataClassName('TimelineEntry')
class LearningTimelineEntries extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get conceptId => text().nullable()();
  TextColumn get topicId => text().nullable()();
  TextColumn get eventType => text()(); // initial_study, quiz_attempt, spaced_revision, gap_detected, mastery_leap
  RealColumn get deltaMastery => real().withDefault(const Constant(0.0))();
  RealColumn get currentMastery => real().withDefault(const Constant(0.0))();
  TextColumn get title => text()();
  TextColumn get description => text()();
  TextColumn get payloadJson => text().withDefault(const Constant('{}'))();
  DateTimeColumn get timestamp => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
