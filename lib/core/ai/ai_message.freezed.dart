// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ai_message.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

AIMessage _$AIMessageFromJson(Map<String, dynamic> json) {
  return _AIMessage.fromJson(json);
}

/// @nodoc
mixin _$AIMessage {
  AIRole get role => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  List<String> get imageUrls => throw _privateConstructorUsedError;

  /// Serializes this AIMessage to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AIMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AIMessageCopyWith<AIMessage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AIMessageCopyWith<$Res> {
  factory $AIMessageCopyWith(AIMessage value, $Res Function(AIMessage) then) =
      _$AIMessageCopyWithImpl<$Res, AIMessage>;
  @useResult
  $Res call({AIRole role, String content, List<String> imageUrls});
}

/// @nodoc
class _$AIMessageCopyWithImpl<$Res, $Val extends AIMessage>
    implements $AIMessageCopyWith<$Res> {
  _$AIMessageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AIMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? role = null,
    Object? content = null,
    Object? imageUrls = null,
  }) {
    return _then(_value.copyWith(
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as AIRole,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrls: null == imageUrls
          ? _value.imageUrls
          : imageUrls // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AIMessageImplCopyWith<$Res>
    implements $AIMessageCopyWith<$Res> {
  factory _$$AIMessageImplCopyWith(
          _$AIMessageImpl value, $Res Function(_$AIMessageImpl) then) =
      __$$AIMessageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({AIRole role, String content, List<String> imageUrls});
}

/// @nodoc
class __$$AIMessageImplCopyWithImpl<$Res>
    extends _$AIMessageCopyWithImpl<$Res, _$AIMessageImpl>
    implements _$$AIMessageImplCopyWith<$Res> {
  __$$AIMessageImplCopyWithImpl(
      _$AIMessageImpl _value, $Res Function(_$AIMessageImpl) _then)
      : super(_value, _then);

  /// Create a copy of AIMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? role = null,
    Object? content = null,
    Object? imageUrls = null,
  }) {
    return _then(_$AIMessageImpl(
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as AIRole,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrls: null == imageUrls
          ? _value._imageUrls
          : imageUrls // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AIMessageImpl implements _AIMessage {
  const _$AIMessageImpl(
      {required this.role,
      required this.content,
      final List<String> imageUrls = const []})
      : _imageUrls = imageUrls;

  factory _$AIMessageImpl.fromJson(Map<String, dynamic> json) =>
      _$$AIMessageImplFromJson(json);

  @override
  final AIRole role;
  @override
  final String content;
  final List<String> _imageUrls;
  @override
  @JsonKey()
  List<String> get imageUrls {
    if (_imageUrls is EqualUnmodifiableListView) return _imageUrls;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_imageUrls);
  }

  @override
  String toString() {
    return 'AIMessage(role: $role, content: $content, imageUrls: $imageUrls)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AIMessageImpl &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.content, content) || other.content == content) &&
            const DeepCollectionEquality()
                .equals(other._imageUrls, _imageUrls));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, role, content,
      const DeepCollectionEquality().hash(_imageUrls));

  /// Create a copy of AIMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AIMessageImplCopyWith<_$AIMessageImpl> get copyWith =>
      __$$AIMessageImplCopyWithImpl<_$AIMessageImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AIMessageImplToJson(
      this,
    );
  }
}

abstract class _AIMessage implements AIMessage {
  const factory _AIMessage(
      {required final AIRole role,
      required final String content,
      final List<String> imageUrls}) = _$AIMessageImpl;

  factory _AIMessage.fromJson(Map<String, dynamic> json) =
      _$AIMessageImpl.fromJson;

  @override
  AIRole get role;
  @override
  String get content;
  @override
  List<String> get imageUrls;

  /// Create a copy of AIMessage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AIMessageImplCopyWith<_$AIMessageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$AIRequest {
  List<AIMessage> get messages => throw _privateConstructorUsedError;
  String? get model => throw _privateConstructorUsedError;
  double get temperature => throw _privateConstructorUsedError;
  int get maxTokens => throw _privateConstructorUsedError;
  bool get stream => throw _privateConstructorUsedError;
  Map<String, dynamic>? get extra => throw _privateConstructorUsedError;

  /// Create a copy of AIRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AIRequestCopyWith<AIRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AIRequestCopyWith<$Res> {
  factory $AIRequestCopyWith(AIRequest value, $Res Function(AIRequest) then) =
      _$AIRequestCopyWithImpl<$Res, AIRequest>;
  @useResult
  $Res call(
      {List<AIMessage> messages,
      String? model,
      double temperature,
      int maxTokens,
      bool stream,
      Map<String, dynamic>? extra});
}

/// @nodoc
class _$AIRequestCopyWithImpl<$Res, $Val extends AIRequest>
    implements $AIRequestCopyWith<$Res> {
  _$AIRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AIRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? messages = null,
    Object? model = freezed,
    Object? temperature = null,
    Object? maxTokens = null,
    Object? stream = null,
    Object? extra = freezed,
  }) {
    return _then(_value.copyWith(
      messages: null == messages
          ? _value.messages
          : messages // ignore: cast_nullable_to_non_nullable
              as List<AIMessage>,
      model: freezed == model
          ? _value.model
          : model // ignore: cast_nullable_to_non_nullable
              as String?,
      temperature: null == temperature
          ? _value.temperature
          : temperature // ignore: cast_nullable_to_non_nullable
              as double,
      maxTokens: null == maxTokens
          ? _value.maxTokens
          : maxTokens // ignore: cast_nullable_to_non_nullable
              as int,
      stream: null == stream
          ? _value.stream
          : stream // ignore: cast_nullable_to_non_nullable
              as bool,
      extra: freezed == extra
          ? _value.extra
          : extra // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AIRequestImplCopyWith<$Res>
    implements $AIRequestCopyWith<$Res> {
  factory _$$AIRequestImplCopyWith(
          _$AIRequestImpl value, $Res Function(_$AIRequestImpl) then) =
      __$$AIRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<AIMessage> messages,
      String? model,
      double temperature,
      int maxTokens,
      bool stream,
      Map<String, dynamic>? extra});
}

/// @nodoc
class __$$AIRequestImplCopyWithImpl<$Res>
    extends _$AIRequestCopyWithImpl<$Res, _$AIRequestImpl>
    implements _$$AIRequestImplCopyWith<$Res> {
  __$$AIRequestImplCopyWithImpl(
      _$AIRequestImpl _value, $Res Function(_$AIRequestImpl) _then)
      : super(_value, _then);

  /// Create a copy of AIRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? messages = null,
    Object? model = freezed,
    Object? temperature = null,
    Object? maxTokens = null,
    Object? stream = null,
    Object? extra = freezed,
  }) {
    return _then(_$AIRequestImpl(
      messages: null == messages
          ? _value._messages
          : messages // ignore: cast_nullable_to_non_nullable
              as List<AIMessage>,
      model: freezed == model
          ? _value.model
          : model // ignore: cast_nullable_to_non_nullable
              as String?,
      temperature: null == temperature
          ? _value.temperature
          : temperature // ignore: cast_nullable_to_non_nullable
              as double,
      maxTokens: null == maxTokens
          ? _value.maxTokens
          : maxTokens // ignore: cast_nullable_to_non_nullable
              as int,
      stream: null == stream
          ? _value.stream
          : stream // ignore: cast_nullable_to_non_nullable
              as bool,
      extra: freezed == extra
          ? _value._extra
          : extra // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc

class _$AIRequestImpl implements _AIRequest {
  const _$AIRequestImpl(
      {required final List<AIMessage> messages,
      this.model,
      this.temperature = 0.7,
      this.maxTokens = 2048,
      this.stream = false,
      final Map<String, dynamic>? extra})
      : _messages = messages,
        _extra = extra;

  final List<AIMessage> _messages;
  @override
  List<AIMessage> get messages {
    if (_messages is EqualUnmodifiableListView) return _messages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_messages);
  }

  @override
  final String? model;
  @override
  @JsonKey()
  final double temperature;
  @override
  @JsonKey()
  final int maxTokens;
  @override
  @JsonKey()
  final bool stream;
  final Map<String, dynamic>? _extra;
  @override
  Map<String, dynamic>? get extra {
    final value = _extra;
    if (value == null) return null;
    if (_extra is EqualUnmodifiableMapView) return _extra;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'AIRequest(messages: $messages, model: $model, temperature: $temperature, maxTokens: $maxTokens, stream: $stream, extra: $extra)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AIRequestImpl &&
            const DeepCollectionEquality().equals(other._messages, _messages) &&
            (identical(other.model, model) || other.model == model) &&
            (identical(other.temperature, temperature) ||
                other.temperature == temperature) &&
            (identical(other.maxTokens, maxTokens) ||
                other.maxTokens == maxTokens) &&
            (identical(other.stream, stream) || other.stream == stream) &&
            const DeepCollectionEquality().equals(other._extra, _extra));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_messages),
      model,
      temperature,
      maxTokens,
      stream,
      const DeepCollectionEquality().hash(_extra));

  /// Create a copy of AIRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AIRequestImplCopyWith<_$AIRequestImpl> get copyWith =>
      __$$AIRequestImplCopyWithImpl<_$AIRequestImpl>(this, _$identity);
}

abstract class _AIRequest implements AIRequest {
  const factory _AIRequest(
      {required final List<AIMessage> messages,
      final String? model,
      final double temperature,
      final int maxTokens,
      final bool stream,
      final Map<String, dynamic>? extra}) = _$AIRequestImpl;

  @override
  List<AIMessage> get messages;
  @override
  String? get model;
  @override
  double get temperature;
  @override
  int get maxTokens;
  @override
  bool get stream;
  @override
  Map<String, dynamic>? get extra;

  /// Create a copy of AIRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AIRequestImplCopyWith<_$AIRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$AIResponse {
  String get content => throw _privateConstructorUsedError;
  String get model => throw _privateConstructorUsedError;
  int get promptTokens => throw _privateConstructorUsedError;
  int get completionTokens => throw _privateConstructorUsedError;
  Map<String, dynamic>? get extra => throw _privateConstructorUsedError;

  /// Create a copy of AIResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AIResponseCopyWith<AIResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AIResponseCopyWith<$Res> {
  factory $AIResponseCopyWith(
          AIResponse value, $Res Function(AIResponse) then) =
      _$AIResponseCopyWithImpl<$Res, AIResponse>;
  @useResult
  $Res call(
      {String content,
      String model,
      int promptTokens,
      int completionTokens,
      Map<String, dynamic>? extra});
}

/// @nodoc
class _$AIResponseCopyWithImpl<$Res, $Val extends AIResponse>
    implements $AIResponseCopyWith<$Res> {
  _$AIResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AIResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? content = null,
    Object? model = null,
    Object? promptTokens = null,
    Object? completionTokens = null,
    Object? extra = freezed,
  }) {
    return _then(_value.copyWith(
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      model: null == model
          ? _value.model
          : model // ignore: cast_nullable_to_non_nullable
              as String,
      promptTokens: null == promptTokens
          ? _value.promptTokens
          : promptTokens // ignore: cast_nullable_to_non_nullable
              as int,
      completionTokens: null == completionTokens
          ? _value.completionTokens
          : completionTokens // ignore: cast_nullable_to_non_nullable
              as int,
      extra: freezed == extra
          ? _value.extra
          : extra // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AIResponseImplCopyWith<$Res>
    implements $AIResponseCopyWith<$Res> {
  factory _$$AIResponseImplCopyWith(
          _$AIResponseImpl value, $Res Function(_$AIResponseImpl) then) =
      __$$AIResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String content,
      String model,
      int promptTokens,
      int completionTokens,
      Map<String, dynamic>? extra});
}

/// @nodoc
class __$$AIResponseImplCopyWithImpl<$Res>
    extends _$AIResponseCopyWithImpl<$Res, _$AIResponseImpl>
    implements _$$AIResponseImplCopyWith<$Res> {
  __$$AIResponseImplCopyWithImpl(
      _$AIResponseImpl _value, $Res Function(_$AIResponseImpl) _then)
      : super(_value, _then);

  /// Create a copy of AIResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? content = null,
    Object? model = null,
    Object? promptTokens = null,
    Object? completionTokens = null,
    Object? extra = freezed,
  }) {
    return _then(_$AIResponseImpl(
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      model: null == model
          ? _value.model
          : model // ignore: cast_nullable_to_non_nullable
              as String,
      promptTokens: null == promptTokens
          ? _value.promptTokens
          : promptTokens // ignore: cast_nullable_to_non_nullable
              as int,
      completionTokens: null == completionTokens
          ? _value.completionTokens
          : completionTokens // ignore: cast_nullable_to_non_nullable
              as int,
      extra: freezed == extra
          ? _value._extra
          : extra // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc

class _$AIResponseImpl implements _AIResponse {
  const _$AIResponseImpl(
      {required this.content,
      required this.model,
      required this.promptTokens,
      required this.completionTokens,
      final Map<String, dynamic>? extra})
      : _extra = extra;

  @override
  final String content;
  @override
  final String model;
  @override
  final int promptTokens;
  @override
  final int completionTokens;
  final Map<String, dynamic>? _extra;
  @override
  Map<String, dynamic>? get extra {
    final value = _extra;
    if (value == null) return null;
    if (_extra is EqualUnmodifiableMapView) return _extra;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'AIResponse(content: $content, model: $model, promptTokens: $promptTokens, completionTokens: $completionTokens, extra: $extra)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AIResponseImpl &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.model, model) || other.model == model) &&
            (identical(other.promptTokens, promptTokens) ||
                other.promptTokens == promptTokens) &&
            (identical(other.completionTokens, completionTokens) ||
                other.completionTokens == completionTokens) &&
            const DeepCollectionEquality().equals(other._extra, _extra));
  }

  @override
  int get hashCode => Object.hash(runtimeType, content, model, promptTokens,
      completionTokens, const DeepCollectionEquality().hash(_extra));

  /// Create a copy of AIResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AIResponseImplCopyWith<_$AIResponseImpl> get copyWith =>
      __$$AIResponseImplCopyWithImpl<_$AIResponseImpl>(this, _$identity);
}

abstract class _AIResponse implements AIResponse {
  const factory _AIResponse(
      {required final String content,
      required final String model,
      required final int promptTokens,
      required final int completionTokens,
      final Map<String, dynamic>? extra}) = _$AIResponseImpl;

  @override
  String get content;
  @override
  String get model;
  @override
  int get promptTokens;
  @override
  int get completionTokens;
  @override
  Map<String, dynamic>? get extra;

  /// Create a copy of AIResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AIResponseImplCopyWith<_$AIResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
