import 'package:drift/drift.dart';

/// StudyDna Table — Dynamic cognitive fingerprint per user
class StudyDnaEntries extends Table {
  TextColumn get userId => text()();
  TextColumn get sensoryProfileJson => text()(); // visual, text, audio, quiz weights
  TextColumn get pedagogicalProfileJson => text()(); // deductive vs inductive, depth, math vs theory
  TextColumn get temporalProfileJson => text()(); // peak hours, focus duration, reading speed, fatigue rate
  TextColumn get retentionProfileJson => text()(); // baseline decay, consolidation boost, spacing multiplier
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {userId};
}
