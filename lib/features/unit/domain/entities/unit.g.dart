// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UnitImpl _$$UnitImplFromJson(Map<String, dynamic> json) => _$UnitImpl(
      id: json['id'] as String,
      subjectId: json['subjectId'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
      topicCount: (json['topicCount'] as num?)?.toInt() ?? 0,
      masteryScore: (json['masteryScore'] as num?)?.toDouble() ?? 0.0,
      totalStudyMinutes: (json['totalStudyMinutes'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$UnitImplToJson(_$UnitImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'subjectId': instance.subjectId,
      'userId': instance.userId,
      'name': instance.name,
      'description': instance.description,
      'sortOrder': instance.sortOrder,
      'topicCount': instance.topicCount,
      'masteryScore': instance.masteryScore,
      'totalStudyMinutes': instance.totalStudyMinutes,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
