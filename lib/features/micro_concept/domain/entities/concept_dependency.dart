import 'package:freezed_annotation/freezed_annotation.dart';

part 'concept_dependency.freezed.dart';
part 'concept_dependency.g.dart';

@freezed
class ConceptDependency with _$ConceptDependency {
  const factory ConceptDependency({
    required String id,
    required String sourceConceptId,
    required String targetConceptId,
    required DateTime createdAt,
    @Default('prerequisite') String dependencyType, // prerequisite, correlated, part_of, contrasted_with
    @Default(1.0) double strength,
  }) = _ConceptDependency;

  factory ConceptDependency.fromJson(Map<String, dynamic> json) =>
      _$ConceptDependencyFromJson(json);
}
