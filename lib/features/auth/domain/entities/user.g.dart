// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AppUserImpl _$$AppUserImplFromJson(Map<String, dynamic> json) =>
    _$AppUserImpl(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String?,
      photoUrl: json['photoUrl'] as String?,
      institution: json['institution'] as String?,
      course: json['course'] as String?,
      yearOfStudy: (json['yearOfStudy'] as num?)?.toInt(),
      learningPersonality: $enumDecodeNullable(
              _$LearningPersonalityEnumMap, json['learningPersonality']) ??
          LearningPersonality.mixed,
      preferredExplanationStyle:
          json['preferredExplanationStyle'] as String? ?? 'intermediate',
      onboardingCompleted: json['onboardingCompleted'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$AppUserImplToJson(_$AppUserImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'displayName': instance.displayName,
      'photoUrl': instance.photoUrl,
      'institution': instance.institution,
      'course': instance.course,
      'yearOfStudy': instance.yearOfStudy,
      'learningPersonality':
          _$LearningPersonalityEnumMap[instance.learningPersonality]!,
      'preferredExplanationStyle': instance.preferredExplanationStyle,
      'onboardingCompleted': instance.onboardingCompleted,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

const _$LearningPersonalityEnumMap = {
  LearningPersonality.visual: 'visual',
  LearningPersonality.auditory: 'auditory',
  LearningPersonality.reading: 'reading',
  LearningPersonality.mixed: 'mixed',
};
