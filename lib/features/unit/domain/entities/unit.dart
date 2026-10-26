import 'package:freezed_annotation/freezed_annotation.dart';

part 'unit.freezed.dart';
part 'unit.g.dart';

@freezed
class Unit with _$Unit {
  const factory Unit({
    required String id,
    required String subjectId,
    required String userId,
    required String name,
    String? description,
    @Default(0) int sortOrder,
    @Default(0) int topicCount,
    @Default(0.0) double masteryScore,
    @Default(0) int totalStudyMinutes,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _Unit;

  factory Unit.fromJson(Map<String, dynamic> json) => _$UnitFromJson(json);
}
