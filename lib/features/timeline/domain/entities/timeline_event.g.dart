// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timeline_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TimelineEventImpl _$$TimelineEventImplFromJson(Map<String, dynamic> json) =>
    _$TimelineEventImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      eventType: json['eventType'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      conceptId: json['conceptId'] as String?,
      topicId: json['topicId'] as String?,
      deltaMastery: (json['deltaMastery'] as num?)?.toDouble() ?? 0.0,
      currentMastery: (json['currentMastery'] as num?)?.toDouble() ?? 0.0,
      payload: json['payload'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$$TimelineEventImplToJson(_$TimelineEventImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'eventType': instance.eventType,
      'title': instance.title,
      'description': instance.description,
      'timestamp': instance.timestamp.toIso8601String(),
      'conceptId': instance.conceptId,
      'topicId': instance.topicId,
      'deltaMastery': instance.deltaMastery,
      'currentMastery': instance.currentMastery,
      'payload': instance.payload,
    };
