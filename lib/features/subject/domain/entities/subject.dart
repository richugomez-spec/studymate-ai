import 'package:freezed_annotation/freezed_annotation.dart';

part 'subject.freezed.dart';
part 'subject.g.dart';

@freezed
class Subject with _$Subject {
  const factory Subject({
    required String id,
    required String semesterId,
    required String userId,
    required String name,
    String? description,
    String? code,         // e.g. "CS301"
    required int colorIndex, // index into AppColors.subjectColors
    String? iconName,
    @Default(0) int unitCount,
    @Default(0) int topicCount,
    @Default(0.0) double masteryScore,  // 0.0–1.0
    @Default(0) int weakTopicCount,
    @Default(0) int totalStudyMinutes,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _Subject;

  factory Subject.fromJson(Map<String, dynamic> json) =>
      _$SubjectFromJson(json);
}
