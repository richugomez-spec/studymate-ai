// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'timeline_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

TimelineEvent _$TimelineEventFromJson(Map<String, dynamic> json) {
  return _TimelineEvent.fromJson(json);
}

/// @nodoc
mixin _$TimelineEvent {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get eventType =>
      throw _privateConstructorUsedError; // initial_study, quiz_attempt, spaced_revision, gap_detected, mastery_leap
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;
  String? get conceptId => throw _privateConstructorUsedError;
  String? get topicId => throw _privateConstructorUsedError;
  double get deltaMastery => throw _privateConstructorUsedError;
  double get currentMastery => throw _privateConstructorUsedError;
  Map<String, dynamic> get payload => throw _privateConstructorUsedError;

  /// Serializes this TimelineEvent to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TimelineEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TimelineEventCopyWith<TimelineEvent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TimelineEventCopyWith<$Res> {
  factory $TimelineEventCopyWith(
          TimelineEvent value, $Res Function(TimelineEvent) then) =
      _$TimelineEventCopyWithImpl<$Res, TimelineEvent>;
  @useResult
  $Res call(
      {String id,
      String userId,
      String eventType,
      String title,
      String description,
      DateTime timestamp,
      String? conceptId,
      String? topicId,
      double deltaMastery,
      double currentMastery,
      Map<String, dynamic> payload});
}

/// @nodoc
class _$TimelineEventCopyWithImpl<$Res, $Val extends TimelineEvent>
    implements $TimelineEventCopyWith<$Res> {
  _$TimelineEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TimelineEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? eventType = null,
    Object? title = null,
    Object? description = null,
    Object? timestamp = null,
    Object? conceptId = freezed,
    Object? topicId = freezed,
    Object? deltaMastery = null,
    Object? currentMastery = null,
    Object? payload = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      eventType: null == eventType
          ? _value.eventType
          : eventType // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      conceptId: freezed == conceptId
          ? _value.conceptId
          : conceptId // ignore: cast_nullable_to_non_nullable
              as String?,
      topicId: freezed == topicId
          ? _value.topicId
          : topicId // ignore: cast_nullable_to_non_nullable
              as String?,
      deltaMastery: null == deltaMastery
          ? _value.deltaMastery
          : deltaMastery // ignore: cast_nullable_to_non_nullable
              as double,
      currentMastery: null == currentMastery
          ? _value.currentMastery
          : currentMastery // ignore: cast_nullable_to_non_nullable
              as double,
      payload: null == payload
          ? _value.payload
          : payload // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TimelineEventImplCopyWith<$Res>
    implements $TimelineEventCopyWith<$Res> {
  factory _$$TimelineEventImplCopyWith(
          _$TimelineEventImpl value, $Res Function(_$TimelineEventImpl) then) =
      __$$TimelineEventImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      String eventType,
      String title,
      String description,
      DateTime timestamp,
      String? conceptId,
      String? topicId,
      double deltaMastery,
      double currentMastery,
      Map<String, dynamic> payload});
}

/// @nodoc
class __$$TimelineEventImplCopyWithImpl<$Res>
    extends _$TimelineEventCopyWithImpl<$Res, _$TimelineEventImpl>
    implements _$$TimelineEventImplCopyWith<$Res> {
  __$$TimelineEventImplCopyWithImpl(
      _$TimelineEventImpl _value, $Res Function(_$TimelineEventImpl) _then)
      : super(_value, _then);

  /// Create a copy of TimelineEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? eventType = null,
    Object? title = null,
    Object? description = null,
    Object? timestamp = null,
    Object? conceptId = freezed,
    Object? topicId = freezed,
    Object? deltaMastery = null,
    Object? currentMastery = null,
    Object? payload = null,
  }) {
    return _then(_$TimelineEventImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      eventType: null == eventType
          ? _value.eventType
          : eventType // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      conceptId: freezed == conceptId
          ? _value.conceptId
          : conceptId // ignore: cast_nullable_to_non_nullable
              as String?,
      topicId: freezed == topicId
          ? _value.topicId
          : topicId // ignore: cast_nullable_to_non_nullable
              as String?,
      deltaMastery: null == deltaMastery
          ? _value.deltaMastery
          : deltaMastery // ignore: cast_nullable_to_non_nullable
              as double,
      currentMastery: null == currentMastery
          ? _value.currentMastery
          : currentMastery // ignore: cast_nullable_to_non_nullable
              as double,
      payload: null == payload
          ? _value._payload
          : payload // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TimelineEventImpl implements _TimelineEvent {
  const _$TimelineEventImpl(
      {required this.id,
      required this.userId,
      required this.eventType,
      required this.title,
      required this.description,
      required this.timestamp,
      this.conceptId,
      this.topicId,
      this.deltaMastery = 0.0,
      this.currentMastery = 0.0,
      final Map<String, dynamic> payload = const {}})
      : _payload = payload;

  factory _$TimelineEventImpl.fromJson(Map<String, dynamic> json) =>
      _$$TimelineEventImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String eventType;
// initial_study, quiz_attempt, spaced_revision, gap_detected, mastery_leap
  @override
  final String title;
  @override
  final String description;
  @override
  final DateTime timestamp;
  @override
  final String? conceptId;
  @override
  final String? topicId;
  @override
  @JsonKey()
  final double deltaMastery;
  @override
  @JsonKey()
  final double currentMastery;
  final Map<String, dynamic> _payload;
  @override
  @JsonKey()
  Map<String, dynamic> get payload {
    if (_payload is EqualUnmodifiableMapView) return _payload;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_payload);
  }

  @override
  String toString() {
    return 'TimelineEvent(id: $id, userId: $userId, eventType: $eventType, title: $title, description: $description, timestamp: $timestamp, conceptId: $conceptId, topicId: $topicId, deltaMastery: $deltaMastery, currentMastery: $currentMastery, payload: $payload)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TimelineEventImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.eventType, eventType) ||
                other.eventType == eventType) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.conceptId, conceptId) ||
                other.conceptId == conceptId) &&
            (identical(other.topicId, topicId) || other.topicId == topicId) &&
            (identical(other.deltaMastery, deltaMastery) ||
                other.deltaMastery == deltaMastery) &&
            (identical(other.currentMastery, currentMastery) ||
                other.currentMastery == currentMastery) &&
            const DeepCollectionEquality().equals(other._payload, _payload));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      eventType,
      title,
      description,
      timestamp,
      conceptId,
      topicId,
      deltaMastery,
      currentMastery,
      const DeepCollectionEquality().hash(_payload));

  /// Create a copy of TimelineEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TimelineEventImplCopyWith<_$TimelineEventImpl> get copyWith =>
      __$$TimelineEventImplCopyWithImpl<_$TimelineEventImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TimelineEventImplToJson(
      this,
    );
  }
}

abstract class _TimelineEvent implements TimelineEvent {
  const factory _TimelineEvent(
      {required final String id,
      required final String userId,
      required final String eventType,
      required final String title,
      required final String description,
      required final DateTime timestamp,
      final String? conceptId,
      final String? topicId,
      final double deltaMastery,
      final double currentMastery,
      final Map<String, dynamic> payload}) = _$TimelineEventImpl;

  factory _TimelineEvent.fromJson(Map<String, dynamic> json) =
      _$TimelineEventImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String
      get eventType; // initial_study, quiz_attempt, spaced_revision, gap_detected, mastery_leap
  @override
  String get title;
  @override
  String get description;
  @override
  DateTime get timestamp;
  @override
  String? get conceptId;
  @override
  String? get topicId;
  @override
  double get deltaMastery;
  @override
  double get currentMastery;
  @override
  Map<String, dynamic> get payload;

  /// Create a copy of TimelineEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TimelineEventImplCopyWith<_$TimelineEventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
