// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AIConfigImpl _$$AIConfigImplFromJson(Map<String, dynamic> json) =>
    _$AIConfigImpl(
      providerType: $enumDecode(_$AIProviderTypeEnumMap, json['providerType']),
      apiKey: json['apiKey'] as String?,
      model: json['model'] as String?,
      baseUrl: json['baseUrl'] as String?,
      temperature: (json['temperature'] as num?)?.toDouble() ?? 0.7,
      maxTokens: (json['maxTokens'] as num?)?.toInt() ?? 2048,
      streamByDefault: json['streamByDefault'] as bool? ?? false,
    );

Map<String, dynamic> _$$AIConfigImplToJson(_$AIConfigImpl instance) =>
    <String, dynamic>{
      'providerType': _$AIProviderTypeEnumMap[instance.providerType]!,
      'apiKey': instance.apiKey,
      'model': instance.model,
      'baseUrl': instance.baseUrl,
      'temperature': instance.temperature,
      'maxTokens': instance.maxTokens,
      'streamByDefault': instance.streamByDefault,
    };

const _$AIProviderTypeEnumMap = {
  AIProviderType.gemini: 'gemini',
  AIProviderType.openai: 'openai',
  AIProviderType.grok: 'grok',
  AIProviderType.ollama: 'ollama',
  AIProviderType.openRouter: 'openRouter',
};
