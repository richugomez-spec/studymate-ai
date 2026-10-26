// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ai_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

AIConfig _$AIConfigFromJson(Map<String, dynamic> json) {
  return _AIConfig.fromJson(json);
}

/// @nodoc
mixin _$AIConfig {
  AIProviderType get providerType => throw _privateConstructorUsedError;
  String? get apiKey => throw _privateConstructorUsedError;
  String? get model => throw _privateConstructorUsedError;
  String? get baseUrl =>
      throw _privateConstructorUsedError; // for Ollama or custom OpenAI-compatible APIs
  double get temperature => throw _privateConstructorUsedError;
  int get maxTokens => throw _privateConstructorUsedError;
  bool get streamByDefault => throw _privateConstructorUsedError;

  /// Serializes this AIConfig to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AIConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AIConfigCopyWith<AIConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AIConfigCopyWith<$Res> {
  factory $AIConfigCopyWith(AIConfig value, $Res Function(AIConfig) then) =
      _$AIConfigCopyWithImpl<$Res, AIConfig>;
  @useResult
  $Res call(
      {AIProviderType providerType,
      String? apiKey,
      String? model,
      String? baseUrl,
      double temperature,
      int maxTokens,
      bool streamByDefault});
}

/// @nodoc
class _$AIConfigCopyWithImpl<$Res, $Val extends AIConfig>
    implements $AIConfigCopyWith<$Res> {
  _$AIConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AIConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? providerType = null,
    Object? apiKey = freezed,
    Object? model = freezed,
    Object? baseUrl = freezed,
    Object? temperature = null,
    Object? maxTokens = null,
    Object? streamByDefault = null,
  }) {
    return _then(_value.copyWith(
      providerType: null == providerType
          ? _value.providerType
          : providerType // ignore: cast_nullable_to_non_nullable
              as AIProviderType,
      apiKey: freezed == apiKey
          ? _value.apiKey
          : apiKey // ignore: cast_nullable_to_non_nullable
              as String?,
      model: freezed == model
          ? _value.model
          : model // ignore: cast_nullable_to_non_nullable
              as String?,
      baseUrl: freezed == baseUrl
          ? _value.baseUrl
          : baseUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      temperature: null == temperature
          ? _value.temperature
          : temperature // ignore: cast_nullable_to_non_nullable
              as double,
      maxTokens: null == maxTokens
          ? _value.maxTokens
          : maxTokens // ignore: cast_nullable_to_non_nullable
              as int,
      streamByDefault: null == streamByDefault
          ? _value.streamByDefault
          : streamByDefault // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AIConfigImplCopyWith<$Res>
    implements $AIConfigCopyWith<$Res> {
  factory _$$AIConfigImplCopyWith(
          _$AIConfigImpl value, $Res Function(_$AIConfigImpl) then) =
      __$$AIConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {AIProviderType providerType,
      String? apiKey,
      String? model,
      String? baseUrl,
      double temperature,
      int maxTokens,
      bool streamByDefault});
}

/// @nodoc
class __$$AIConfigImplCopyWithImpl<$Res>
    extends _$AIConfigCopyWithImpl<$Res, _$AIConfigImpl>
    implements _$$AIConfigImplCopyWith<$Res> {
  __$$AIConfigImplCopyWithImpl(
      _$AIConfigImpl _value, $Res Function(_$AIConfigImpl) _then)
      : super(_value, _then);

  /// Create a copy of AIConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? providerType = null,
    Object? apiKey = freezed,
    Object? model = freezed,
    Object? baseUrl = freezed,
    Object? temperature = null,
    Object? maxTokens = null,
    Object? streamByDefault = null,
  }) {
    return _then(_$AIConfigImpl(
      providerType: null == providerType
          ? _value.providerType
          : providerType // ignore: cast_nullable_to_non_nullable
              as AIProviderType,
      apiKey: freezed == apiKey
          ? _value.apiKey
          : apiKey // ignore: cast_nullable_to_non_nullable
              as String?,
      model: freezed == model
          ? _value.model
          : model // ignore: cast_nullable_to_non_nullable
              as String?,
      baseUrl: freezed == baseUrl
          ? _value.baseUrl
          : baseUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      temperature: null == temperature
          ? _value.temperature
          : temperature // ignore: cast_nullable_to_non_nullable
              as double,
      maxTokens: null == maxTokens
          ? _value.maxTokens
          : maxTokens // ignore: cast_nullable_to_non_nullable
              as int,
      streamByDefault: null == streamByDefault
          ? _value.streamByDefault
          : streamByDefault // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AIConfigImpl implements _AIConfig {
  const _$AIConfigImpl(
      {required this.providerType,
      this.apiKey,
      this.model,
      this.baseUrl,
      this.temperature = 0.7,
      this.maxTokens = 2048,
      this.streamByDefault = false});

  factory _$AIConfigImpl.fromJson(Map<String, dynamic> json) =>
      _$$AIConfigImplFromJson(json);

  @override
  final AIProviderType providerType;
  @override
  final String? apiKey;
  @override
  final String? model;
  @override
  final String? baseUrl;
// for Ollama or custom OpenAI-compatible APIs
  @override
  @JsonKey()
  final double temperature;
  @override
  @JsonKey()
  final int maxTokens;
  @override
  @JsonKey()
  final bool streamByDefault;

  @override
  String toString() {
    return 'AIConfig(providerType: $providerType, apiKey: $apiKey, model: $model, baseUrl: $baseUrl, temperature: $temperature, maxTokens: $maxTokens, streamByDefault: $streamByDefault)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AIConfigImpl &&
            (identical(other.providerType, providerType) ||
                other.providerType == providerType) &&
            (identical(other.apiKey, apiKey) || other.apiKey == apiKey) &&
            (identical(other.model, model) || other.model == model) &&
            (identical(other.baseUrl, baseUrl) || other.baseUrl == baseUrl) &&
            (identical(other.temperature, temperature) ||
                other.temperature == temperature) &&
            (identical(other.maxTokens, maxTokens) ||
                other.maxTokens == maxTokens) &&
            (identical(other.streamByDefault, streamByDefault) ||
                other.streamByDefault == streamByDefault));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, providerType, apiKey, model,
      baseUrl, temperature, maxTokens, streamByDefault);

  /// Create a copy of AIConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AIConfigImplCopyWith<_$AIConfigImpl> get copyWith =>
      __$$AIConfigImplCopyWithImpl<_$AIConfigImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AIConfigImplToJson(
      this,
    );
  }
}

abstract class _AIConfig implements AIConfig {
  const factory _AIConfig(
      {required final AIProviderType providerType,
      final String? apiKey,
      final String? model,
      final String? baseUrl,
      final double temperature,
      final int maxTokens,
      final bool streamByDefault}) = _$AIConfigImpl;

  factory _AIConfig.fromJson(Map<String, dynamic> json) =
      _$AIConfigImpl.fromJson;

  @override
  AIProviderType get providerType;
  @override
  String? get apiKey;
  @override
  String? get model;
  @override
  String? get baseUrl; // for Ollama or custom OpenAI-compatible APIs
  @override
  double get temperature;
  @override
  int get maxTokens;
  @override
  bool get streamByDefault;

  /// Create a copy of AIConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AIConfigImplCopyWith<_$AIConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
