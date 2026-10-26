import 'package:drift/drift.dart';

class Subjects extends Table {
  TextColumn get id => text()();
  TextColumn get semesterId => text()();
  TextColumn get userId => text()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  TextColumn get code => text().nullable()();
  IntColumn get colorIndex => integer().withDefault(const Constant(0))();
  TextColumn get iconName => text().nullable()();
  RealColumn get masteryScore => real().withDefault(const Constant(0.0))();
  IntColumn get totalStudyMinutes => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
