import 'package:drift/drift.dart';

class Quizzes extends Table {
  TextColumn get id => text()();
  TextColumn get topicId => text()();
  TextColumn get userId => text()();
  TextColumn get title => text()();
  TextColumn get type => text().withDefault(const Constant('mixed'))();
  TextColumn get difficulty => text().withDefault(const Constant('medium'))();
  IntColumn get questionCount => integer()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class QuizQuestions extends Table {
  TextColumn get id => text()();
  TextColumn get quizId => text()();
  TextColumn get question => text()();
  TextColumn get type => text()(); // mcq, true_false, fill_blank, short_answer
  TextColumn get optionsJson => text().withDefault(const Constant('[]'))();
  TextColumn get correctAnswer => text()();
  TextColumn get explanation => text().nullable()();
  TextColumn get difficulty => text().withDefault(const Constant('medium'))();
  IntColumn get sortOrder => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

class QuizAttempts extends Table {
  TextColumn get id => text()();
  TextColumn get quizId => text()();
  TextColumn get userId => text()();
  RealColumn get score => real()();
  IntColumn get correctCount => integer()();
  IntColumn get totalQuestions => integer()();
  IntColumn get durationSeconds => integer()();
  TextColumn get answersJson => text().withDefault(const Constant('{}'))();
  DateTimeColumn get completedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
