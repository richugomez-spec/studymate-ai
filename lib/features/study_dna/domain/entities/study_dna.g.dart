// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'study_dna.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SensoryProfileImpl _$$SensoryProfileImplFromJson(Map<String, dynamic> json) =>
    _$SensoryProfileImpl(
      visualWeight: (json['visualWeight'] as num?)?.toDouble() ?? 0.7,
      textWeight: (json['textWeight'] as num?)?.toDouble() ?? 0.5,
      audioWeight: (json['audioWeight'] as num?)?.toDouble() ?? 0.5,
      quizWeight: (json['quizWeight'] as num?)?.toDouble() ?? 0.8,
    );

Map<String, dynamic> _$$SensoryProfileImplToJson(
        _$SensoryProfileImpl instance) =>
    <String, dynamic>{
      'visualWeight': instance.visualWeight,
      'textWeight': instance.textWeight,
      'audioWeight': instance.audioWeight,
      'quizWeight': instance.quizWeight,
    };

_$PedagogicalProfileImpl _$$PedagogicalProfileImplFromJson(
        Map<String, dynamic> json) =>
    _$PedagogicalProfileImpl(
      deductiveVsInductive:
          (json['deductiveVsInductive'] as num?)?.toDouble() ?? 0.4,
      explanationDepth:
          json['explanationDepth'] as String? ?? 'first_principles',
      mathAffinity: (json['mathAffinity'] as num?)?.toDouble() ?? 0.6,
      theoryAffinity: (json['theoryAffinity'] as num?)?.toDouble() ?? 0.6,
    );

Map<String, dynamic> _$$PedagogicalProfileImplToJson(
        _$PedagogicalProfileImpl instance) =>
    <String, dynamic>{
      'deductiveVsInductive': instance.deductiveVsInductive,
      'explanationDepth': instance.explanationDepth,
      'mathAffinity': instance.mathAffinity,
      'theoryAffinity': instance.theoryAffinity,
    };

_$TemporalProfileImpl _$$TemporalProfileImplFromJson(
        Map<String, dynamic> json) =>
    _$TemporalProfileImpl(
      peakHours: (json['peakHours'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const ['09:00-11:00', '19:00-21:00'],
      focusDurationMinutes:
          (json['focusDurationMinutes'] as num?)?.toInt() ?? 25,
      readingSpeedWpm: (json['readingSpeedWpm'] as num?)?.toInt() ?? 220,
      cognitiveFatigueRate:
          (json['cognitiveFatigueRate'] as num?)?.toDouble() ?? 0.04,
    );

Map<String, dynamic> _$$TemporalProfileImplToJson(
        _$TemporalProfileImpl instance) =>
    <String, dynamic>{
      'peakHours': instance.peakHours,
      'focusDurationMinutes': instance.focusDurationMinutes,
      'readingSpeedWpm': instance.readingSpeedWpm,
      'cognitiveFatigueRate': instance.cognitiveFatigueRate,
    };

_$RetentionProfileImpl _$$RetentionProfileImplFromJson(
        Map<String, dynamic> json) =>
    _$RetentionProfileImpl(
      baselineForgettingRate:
          (json['baselineForgettingRate'] as num?)?.toDouble() ?? 0.12,
      consolidationBoostFromQuiz:
          (json['consolidationBoostFromQuiz'] as num?)?.toDouble() ?? 1.3,
      spacingMultiplier: (json['spacingMultiplier'] as num?)?.toDouble() ?? 1.2,
    );

Map<String, dynamic> _$$RetentionProfileImplToJson(
        _$RetentionProfileImpl instance) =>
    <String, dynamic>{
      'baselineForgettingRate': instance.baselineForgettingRate,
      'consolidationBoostFromQuiz': instance.consolidationBoostFromQuiz,
      'spacingMultiplier': instance.spacingMultiplier,
    };

_$StudyDnaImpl _$$StudyDnaImplFromJson(Map<String, dynamic> json) =>
    _$StudyDnaImpl(
      userId: json['userId'] as String,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      sensory: json['sensory'] == null
          ? const SensoryProfile()
          : SensoryProfile.fromJson(json['sensory'] as Map<String, dynamic>),
      pedagogical: json['pedagogical'] == null
          ? const PedagogicalProfile()
          : PedagogicalProfile.fromJson(
              json['pedagogical'] as Map<String, dynamic>),
      temporal: json['temporal'] == null
          ? const TemporalProfile()
          : TemporalProfile.fromJson(json['temporal'] as Map<String, dynamic>),
      retention: json['retention'] == null
          ? const RetentionProfile()
          : RetentionProfile.fromJson(
              json['retention'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$StudyDnaImplToJson(_$StudyDnaImpl instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'updatedAt': instance.updatedAt.toIso8601String(),
      'sensory': instance.sensory,
      'pedagogical': instance.pedagogical,
      'temporal': instance.temporal,
      'retention': instance.retention,
    };
