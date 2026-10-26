// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subject.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SubjectImpl _$$SubjectImplFromJson(Map<String, dynamic> json) =>
    _$SubjectImpl(
      id: json['id'] as String,
      semesterId: json['semesterId'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      code: json['code'] as String?,
      colorIndex: (json['colorIndex'] as num).toInt(),
      iconName: json['iconName'] as String?,
      unitCount: (json['unitCount'] as num?)?.toInt() ?? 0,
      topicCount: (json['topicCount'] as num?)?.toInt() ?? 0,
      masteryScore: (json['masteryScore'] as num?)?.toDouble() ?? 0.0,
      weakTopicCount: (json['weakTopicCount'] as num?)?.toInt() ?? 0,
      totalStudyMinutes: (json['totalStudyMinutes'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$SubjectImplToJson(_$SubjectImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'semesterId': instance.semesterId,
      'userId': instance.userId,
      'name': instance.name,
      'description': instance.description,
      'code': instance.code,
      'colorIndex': instance.colorIndex,
      'iconName': instance.iconName,
      'unitCount': instance.unitCount,
      'topicCount': instance.topicCount,
      'masteryScore': instance.masteryScore,
      'weakTopicCount': instance.weakTopicCount,
      'totalStudyMinutes': instance.totalStudyMinutes,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
