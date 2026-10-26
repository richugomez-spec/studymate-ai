// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'topic.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TopicImpl _$$TopicImplFromJson(Map<String, dynamic> json) => _$TopicImpl(
      id: json['id'] as String,
      unitId: json['unitId'] as String,
      subjectId: json['subjectId'] as String,
      userId: json['userId'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      status: $enumDecodeNullable(_$TopicStatusEnumMap, json['status']) ??
          TopicStatus.notStarted,
      masteryScore: (json['masteryScore'] as num?)?.toDouble() ?? 0.0,
      weaknessFlag: (json['weaknessFlag'] as num?)?.toInt() ?? 0,
      isAIProcessed: json['isAIProcessed'] as bool? ?? false,
      conceptTags: (json['conceptTags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      learningObjectives: (json['learningObjectives'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      resourceCount: (json['resourceCount'] as num?)?.toInt() ?? 0,
      totalStudyMinutes: (json['totalStudyMinutes'] as num?)?.toInt() ?? 0,
      quizAttempts: (json['quizAttempts'] as num?)?.toInt() ?? 0,
      averageQuizScore: (json['averageQuizScore'] as num?)?.toDouble() ?? 0.0,
      flashcardCount: (json['flashcardCount'] as num?)?.toInt() ?? 0,
      chatMessageCount: (json['chatMessageCount'] as num?)?.toInt() ?? 0,
      lastStudiedAt: json['lastStudiedAt'] == null
          ? null
          : DateTime.parse(json['lastStudiedAt'] as String),
      nextRevisionDue: json['nextRevisionDue'] == null
          ? null
          : DateTime.parse(json['nextRevisionDue'] as String),
      sortOrder: (json['sortOrder'] as num).toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$TopicImplToJson(_$TopicImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'unitId': instance.unitId,
      'subjectId': instance.subjectId,
      'userId': instance.userId,
      'title': instance.title,
      'description': instance.description,
      'status': _$TopicStatusEnumMap[instance.status]!,
      'masteryScore': instance.masteryScore,
      'weaknessFlag': instance.weaknessFlag,
      'isAIProcessed': instance.isAIProcessed,
      'conceptTags': instance.conceptTags,
      'learningObjectives': instance.learningObjectives,
      'resourceCount': instance.resourceCount,
      'totalStudyMinutes': instance.totalStudyMinutes,
      'quizAttempts': instance.quizAttempts,
      'averageQuizScore': instance.averageQuizScore,
      'flashcardCount': instance.flashcardCount,
      'chatMessageCount': instance.chatMessageCount,
      'lastStudiedAt': instance.lastStudiedAt?.toIso8601String(),
      'nextRevisionDue': instance.nextRevisionDue?.toIso8601String(),
      'sortOrder': instance.sortOrder,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

const _$TopicStatusEnumMap = {
  TopicStatus.notStarted: 'notStarted',
  TopicStatus.inProgress: 'inProgress',
  TopicStatus.completed: 'completed',
  TopicStatus.needsRevision: 'needsRevision',
};
