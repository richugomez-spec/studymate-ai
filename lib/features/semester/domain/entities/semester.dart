import 'package:freezed_annotation/freezed_annotation.dart';

part 'semester.freezed.dart';
part 'semester.g.dart';

@freezed
class Semester with _$Semester {
  const factory Semester({
    required String id,
    required String userId,
    required String name,
    String? description,
    required int number,
    required DateTime startDate,
    required DateTime endDate,
    @Default(false) bool isActive,
    @Default(false) bool isArchived,
    @Default(0) int subjectCount,
    @Default(0.0) double overallProgress,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _Semester;

  factory Semester.fromJson(Map<String, dynamic> json) =>
      _$SemesterFromJson(json);
}
