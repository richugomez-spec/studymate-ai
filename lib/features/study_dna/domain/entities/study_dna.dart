import 'package:freezed_annotation/freezed_annotation.dart';

part 'study_dna.freezed.dart';
part 'study_dna.g.dart';

@freezed
class SensoryProfile with _$SensoryProfile {
  const factory SensoryProfile({
    @Default(0.7) double visualWeight,
    @Default(0.5) double textWeight,
    @Default(0.5) double audioWeight,
    @Default(0.8) double quizWeight,
  }) = _SensoryProfile;

  factory SensoryProfile.fromJson(Map<String, dynamic> json) =>
      _$SensoryProfileFromJson(json);
}

@freezed
class PedagogicalProfile with _$PedagogicalProfile {
  const factory PedagogicalProfile({
    @Default(0.4) double deductiveVsInductive, // 0.0 = example first, 1.0 = theory first
    @Default('first_principles') String explanationDepth, // concise, standard, first_principles, analogy_driven
    @Default(0.6) double mathAffinity,
    @Default(0.6) double theoryAffinity,
  }) = _PedagogicalProfile;

  factory PedagogicalProfile.fromJson(Map<String, dynamic> json) =>
      _$PedagogicalProfileFromJson(json);
}

@freezed
class TemporalProfile with _$TemporalProfile {
  const factory TemporalProfile({
    @Default(['09:00-11:00', '19:00-21:00']) List<String> peakHours,
    @Default(25) int focusDurationMinutes,
    @Default(220) int readingSpeedWpm,
    @Default(0.04) double cognitiveFatigueRate,
  }) = _TemporalProfile;

  factory TemporalProfile.fromJson(Map<String, dynamic> json) =>
      _$TemporalProfileFromJson(json);
}

@freezed
class RetentionProfile with _$RetentionProfile {
  const factory RetentionProfile({
    @Default(0.12) double baselineForgettingRate,
    @Default(1.3) double consolidationBoostFromQuiz,
    @Default(1.2) double spacingMultiplier,
  }) = _RetentionProfile;

  factory RetentionProfile.fromJson(Map<String, dynamic> json) =>
      _$RetentionProfileFromJson(json);
}

@freezed
class StudyDna with _$StudyDna {
  const factory StudyDna({
    required String userId,
    required DateTime updatedAt,
    @Default(SensoryProfile()) SensoryProfile sensory,
    @Default(PedagogicalProfile()) PedagogicalProfile pedagogical,
    @Default(TemporalProfile()) TemporalProfile temporal,
    @Default(RetentionProfile()) RetentionProfile retention,
  }) = _StudyDna;

  factory StudyDna.fromJson(Map<String, dynamic> json) =>
      _$StudyDnaFromJson(json);
}
