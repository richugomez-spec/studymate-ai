import 'package:drift/drift.dart';

@DataClassName('ConceptDependencyEntry')
class ConceptDependencies extends Table {
  TextColumn get id => text()();
  TextColumn get sourceConceptId => text()();
  TextColumn get targetConceptId => text()();
  TextColumn get dependencyType => text().withDefault(const Constant('prerequisite'))(); // prerequisite, correlated, part_of, contrasted_with
  RealColumn get strength => real().withDefault(const Constant(1.0))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
