// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'micro_concept.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MicroConceptImpl _$$MicroConceptImplFromJson(Map<String, dynamic> json) =>
    _$MicroConceptImpl(
      id: json['id'] as String,
      topicId: json['topicId'] as String,
      subjectId: json['subjectId'] as String,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      description: json['description'] as String?,
      keyFormulas: (json['keyFormulas'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      masteryScore: (json['masteryScore'] as num?)?.toDouble() ?? 0.0,
      confidenceScore: (json['confidenceScore'] as num?)?.toDouble() ?? 0.0,
      stabilityFactor: (json['stabilityFactor'] as num?)?.toDouble() ?? 1.0,
      forgettingProbability:
          (json['forgettingProbability'] as num?)?.toDouble() ?? 0.0,
      revisionCount: (json['revisionCount'] as num?)?.toInt() ?? 0,
      quizAccuracy: (json['quizAccuracy'] as num?)?.toDouble() ?? 0.0,
      estimatedStudyMinutes:
          (json['estimatedStudyMinutes'] as num?)?.toInt() ?? 15,
      estimatedRevisionMinutes:
          (json['estimatedRevisionMinutes'] as num?)?.toInt() ?? 5,
      lastStudiedAt: json['lastStudiedAt'] == null
          ? null
          : DateTime.parse(json['lastStudiedAt'] as String),
      nextRevisionDue: json['nextRevisionDue'] == null
          ? null
          : DateTime.parse(json['nextRevisionDue'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$MicroConceptImplToJson(_$MicroConceptImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'topicId': instance.topicId,
      'subjectId': instance.subjectId,
      'name': instance.name,
      'createdAt': instance.createdAt.toIso8601String(),
      'description': instance.description,
      'keyFormulas': instance.keyFormulas,
      'masteryScore': instance.masteryScore,
      'confidenceScore': instance.confidenceScore,
      'stabilityFactor': instance.stabilityFactor,
      'forgettingProbability': instance.forgettingProbability,
      'revisionCount': instance.revisionCount,
      'quizAccuracy': instance.quizAccuracy,
      'estimatedStudyMinutes': instance.estimatedStudyMinutes,
      'estimatedRevisionMinutes': instance.estimatedRevisionMinutes,
      'lastStudiedAt': instance.lastStudiedAt?.toIso8601String(),
      'nextRevisionDue': instance.nextRevisionDue?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
