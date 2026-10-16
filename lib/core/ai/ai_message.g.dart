// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AIMessageImpl _$$AIMessageImplFromJson(Map<String, dynamic> json) =>
    _$AIMessageImpl(
      role: $enumDecode(_$AIRoleEnumMap, json['role']),
      content: json['content'] as String,
      imageUrls: (json['imageUrls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$AIMessageImplToJson(_$AIMessageImpl instance) =>
    <String, dynamic>{
      'role': _$AIRoleEnumMap[instance.role]!,
      'content': instance.content,
      'imageUrls': instance.imageUrls,
    };

const _$AIRoleEnumMap = {
  AIRole.system: 'system',
  AIRole.user: 'user',
  AIRole.assistant: 'assistant',
};
