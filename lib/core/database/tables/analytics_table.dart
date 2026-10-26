import 'package:drift/drift.dart';

class StudySessions extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get topicId => text().nullable()();
  TextColumn get subjectId => text().nullable()();
  TextColumn get sessionType => text()(); // study, quiz, flashcard, chat
  IntColumn get durationMinutes => integer()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get endedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class DailyAnalytics extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get date => text()(); // YYYY-MM-DD
  IntColumn get studyMinutes => integer().withDefault(const Constant(0))();
  IntColumn get quizzesCompleted => integer().withDefault(const Constant(0))();
  IntColumn get flashcardsReviewed => integer().withDefault(const Constant(0))();
  IntColumn get aiChatMessages => integer().withDefault(const Constant(0))();
  IntColumn get topicsStudied => integer().withDefault(const Constant(0))();
  BoolColumn get goalMet => boolean().withDefault(const Constant(false))();
  IntColumn get streakDay => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}
