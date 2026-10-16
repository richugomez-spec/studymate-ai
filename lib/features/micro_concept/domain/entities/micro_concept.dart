import 'package:freezed_annotation/freezed_annotation.dart';

part 'micro_concept.freezed.dart';
part 'micro_concept.g.dart';

@freezed
class MicroConcept with _$MicroConcept {
  const factory MicroConcept({
    required String id,
    required String topicId,
    required String subjectId,
    required String name,
    required DateTime createdAt,
    String? description,
    @Default([]) List<String> keyFormulas,
    @Default(0.0) double masteryScore, // 0.0 - 1.0
    @Default(0.0) double confidenceScore, // 0.0 - 1.0
    @Default(1.0) double stabilityFactor, // memory stability half-life in days
    @Default(0.0) double forgettingProbability, // 0.0 - 1.0
    @Default(0) int revisionCount,
    @Default(0.0) double quizAccuracy,
    @Default(15) int estimatedStudyMinutes,
    @Default(5) int estimatedRevisionMinutes,
    DateTime? lastStudiedAt,
    DateTime? nextRevisionDue,
    DateTime? updatedAt,
  }) = _MicroConcept;

  factory MicroConcept.fromJson(Map<String, dynamic> json) =>
      _$MicroConceptFromJson(json);
}
