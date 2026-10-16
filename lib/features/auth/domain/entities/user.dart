import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

enum LearningPersonality { visual, auditory, reading, mixed }

@freezed
class AppUser with _$AppUser {
  const factory AppUser({
    required String id,
    required String email,
    String? displayName,
    String? photoUrl,
    String? institution,
    String? course,
    int? yearOfStudy,
    @Default(LearningPersonality.mixed) LearningPersonality learningPersonality,
    @Default('intermediate') String preferredExplanationStyle,
    @Default(false) bool onboardingCompleted,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _AppUser;

  factory AppUser.fromJson(Map<String, dynamic> json) =>
      _$AppUserFromJson(json);
}
