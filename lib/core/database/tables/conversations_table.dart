import 'package:drift/drift.dart';

class Conversations extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get title => text()();
  TextColumn get contextType => text().withDefault(const Constant('global'))();
  TextColumn get contextId => text().nullable()(); // semesterId/subjectId/topicId
  IntColumn get messageCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get lastMessageAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Messages extends Table {
  TextColumn get id => text()();
  TextColumn get conversationId => text()();
  TextColumn get role => text()(); // user, assistant, system
  TextColumn get content => text()();
  TextColumn get sourceChunkIdsJson => text().withDefault(const Constant('[]'))();
  IntColumn get promptTokens => integer().withDefault(const Constant(0))();
  IntColumn get completionTokens => integer().withDefault(const Constant(0))();
  TextColumn get aiProvider => text().nullable()();
  TextColumn get aiModel => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
