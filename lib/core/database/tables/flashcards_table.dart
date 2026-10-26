import 'package:drift/drift.dart';

class Flashcards extends Table {
  TextColumn get id => text()();
  TextColumn get topicId => text()();
  TextColumn get userId => text()();
  TextColumn get front => text()();
  TextColumn get back => text()();
  TextColumn get hint => text().nullable()();
  BoolColumn get isAIGenerated => boolean().withDefault(const Constant(true))();
  // SM-2 spaced repetition fields
  IntColumn get repetitions => integer().withDefault(const Constant(0))();
  RealColumn get easeFactor => real().withDefault(const Constant(2.5))();
  IntColumn get intervalDays => integer().withDefault(const Constant(1))();
  DateTimeColumn get nextReviewDue => dateTime().nullable()();
  DateTimeColumn get lastReviewedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
