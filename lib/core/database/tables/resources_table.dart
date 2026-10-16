import 'package:drift/drift.dart';

class LearningResources extends Table {
  TextColumn get id => text()();
  TextColumn get topicId => text()();
  TextColumn get userId => text()();
  TextColumn get name => text()();
  TextColumn get type => text()(); // pdf, docx, pptx, image, audio, youtube, txt
  TextColumn get localPath => text().nullable()();
  TextColumn get cloudUrl => text().nullable()();
  TextColumn get youtubeUrl => text().nullable()();
  TextColumn get extractedText => text().nullable()();
  IntColumn get pageCount => integer().nullable()();
  IntColumn get chunkCount => integer().withDefault(const Constant(0))();
  BoolColumn get isProcessed => boolean().withDefault(const Constant(false))();
  TextColumn get processingStatus => text().withDefault(const Constant('pending'))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class ResourceChunks extends Table {
  TextColumn get id => text()();
  TextColumn get resourceId => text()();
  TextColumn get topicId => text()();
  TextColumn get content => text()();
  IntColumn get chunkIndex => integer()();
  IntColumn get tokenCount => integer()();
  TextColumn get embeddingJson => text().nullable()(); // JSON float array
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
