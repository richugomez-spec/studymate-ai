// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'concept_dependency.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ConceptDependencyImpl _$$ConceptDependencyImplFromJson(
        Map<String, dynamic> json) =>
    _$ConceptDependencyImpl(
      id: json['id'] as String,
      sourceConceptId: json['sourceConceptId'] as String,
      targetConceptId: json['targetConceptId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      dependencyType: json['dependencyType'] as String? ?? 'prerequisite',
      strength: (json['strength'] as num?)?.toDouble() ?? 1.0,
    );

Map<String, dynamic> _$$ConceptDependencyImplToJson(
        _$ConceptDependencyImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sourceConceptId': instance.sourceConceptId,
      'targetConceptId': instance.targetConceptId,
      'createdAt': instance.createdAt.toIso8601String(),
      'dependencyType': instance.dependencyType,
      'strength': instance.strength,
    };
