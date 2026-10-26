// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'subject.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Subject _$SubjectFromJson(Map<String, dynamic> json) {
  return _Subject.fromJson(json);
}

/// @nodoc
mixin _$Subject {
  String get id => throw _privateConstructorUsedError;
  String get semesterId => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get code => throw _privateConstructorUsedError; // e.g. "CS301"
  int get colorIndex =>
      throw _privateConstructorUsedError; // index into AppColors.subjectColors
  String? get iconName => throw _privateConstructorUsedError;
  int get unitCount => throw _privateConstructorUsedError;
  int get topicCount => throw _privateConstructorUsedError;
  double get masteryScore => throw _privateConstructorUsedError; // 0.0–1.0
  int get weakTopicCount => throw _privateConstructorUsedError;
  int get totalStudyMinutes => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this Subject to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Subject
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SubjectCopyWith<Subject> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SubjectCopyWith<$Res> {
  factory $SubjectCopyWith(Subject value, $Res Function(Subject) then) =
      _$SubjectCopyWithImpl<$Res, Subject>;
  @useResult
  $Res call(
      {String id,
      String semesterId,
      String userId,
      String name,
      String? description,
      String? code,
      int colorIndex,
      String? iconName,
      int unitCount,
      int topicCount,
      double masteryScore,
      int weakTopicCount,
      int totalStudyMinutes,
      DateTime createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class _$SubjectCopyWithImpl<$Res, $Val extends Subject>
    implements $SubjectCopyWith<$Res> {
  _$SubjectCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Subject
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? semesterId = null,
    Object? userId = null,
    Object? name = null,
    Object? description = freezed,
    Object? code = freezed,
    Object? colorIndex = null,
    Object? iconName = freezed,
    Object? unitCount = null,
    Object? topicCount = null,
    Object? masteryScore = null,
    Object? weakTopicCount = null,
    Object? totalStudyMinutes = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      semesterId: null == semesterId
          ? _value.semesterId
          : semesterId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      code: freezed == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String?,
      colorIndex: null == colorIndex
          ? _value.colorIndex
          : colorIndex // ignore: cast_nullable_to_non_nullable
              as int,
      iconName: freezed == iconName
          ? _value.iconName
          : iconName // ignore: cast_nullable_to_non_nullable
              as String?,
      unitCount: null == unitCount
          ? _value.unitCount
          : unitCount // ignore: cast_nullable_to_non_nullable
              as int,
      topicCount: null == topicCount
          ? _value.topicCount
          : topicCount // ignore: cast_nullable_to_non_nullable
              as int,
      masteryScore: null == masteryScore
          ? _value.masteryScore
          : masteryScore // ignore: cast_nullable_to_non_nullable
              as double,
      weakTopicCount: null == weakTopicCount
          ? _value.weakTopicCount
          : weakTopicCount // ignore: cast_nullable_to_non_nullable
              as int,
      totalStudyMinutes: null == totalStudyMinutes
          ? _value.totalStudyMinutes
          : totalStudyMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SubjectImplCopyWith<$Res> implements $SubjectCopyWith<$Res> {
  factory _$$SubjectImplCopyWith(
          _$SubjectImpl value, $Res Function(_$SubjectImpl) then) =
      __$$SubjectImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String semesterId,
      String userId,
      String name,
      String? description,
      String? code,
      int colorIndex,
      String? iconName,
      int unitCount,
      int topicCount,
      double masteryScore,
      int weakTopicCount,
      int totalStudyMinutes,
      DateTime createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class __$$SubjectImplCopyWithImpl<$Res>
    extends _$SubjectCopyWithImpl<$Res, _$SubjectImpl>
    implements _$$SubjectImplCopyWith<$Res> {
  __$$SubjectImplCopyWithImpl(
      _$SubjectImpl _value, $Res Function(_$SubjectImpl) _then)
      : super(_value, _then);

  /// Create a copy of Subject
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? semesterId = null,
    Object? userId = null,
    Object? name = null,
    Object? description = freezed,
    Object? code = freezed,
    Object? colorIndex = null,
    Object? iconName = freezed,
    Object? unitCount = null,
    Object? topicCount = null,
    Object? masteryScore = null,
    Object? weakTopicCount = null,
    Object? totalStudyMinutes = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(_$SubjectImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      semesterId: null == semesterId
          ? _value.semesterId
          : semesterId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      code: freezed == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String?,
      colorIndex: null == colorIndex
          ? _value.colorIndex
          : colorIndex // ignore: cast_nullable_to_non_nullable
              as int,
      iconName: freezed == iconName
          ? _value.iconName
          : iconName // ignore: cast_nullable_to_non_nullable
              as String?,
      unitCount: null == unitCount
          ? _value.unitCount
          : unitCount // ignore: cast_nullable_to_non_nullable
              as int,
      topicCount: null == topicCount
          ? _value.topicCount
          : topicCount // ignore: cast_nullable_to_non_nullable
              as int,
      masteryScore: null == masteryScore
          ? _value.masteryScore
          : masteryScore // ignore: cast_nullable_to_non_nullable
              as double,
      weakTopicCount: null == weakTopicCount
          ? _value.weakTopicCount
          : weakTopicCount // ignore: cast_nullable_to_non_nullable
              as int,
      totalStudyMinutes: null == totalStudyMinutes
          ? _value.totalStudyMinutes
          : totalStudyMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SubjectImpl implements _Subject {
  const _$SubjectImpl(
      {required this.id,
      required this.semesterId,
      required this.userId,
      required this.name,
      this.description,
      this.code,
      required this.colorIndex,
      this.iconName,
      this.unitCount = 0,
      this.topicCount = 0,
      this.masteryScore = 0.0,
      this.weakTopicCount = 0,
      this.totalStudyMinutes = 0,
      required this.createdAt,
      this.updatedAt});

  factory _$SubjectImpl.fromJson(Map<String, dynamic> json) =>
      _$$SubjectImplFromJson(json);

  @override
  final String id;
  @override
  final String semesterId;
  @override
  final String userId;
  @override
  final String name;
  @override
  final String? description;
  @override
  final String? code;
// e.g. "CS301"
  @override
  final int colorIndex;
// index into AppColors.subjectColors
  @override
  final String? iconName;
  @override
  @JsonKey()
  final int unitCount;
  @override
  @JsonKey()
  final int topicCount;
  @override
  @JsonKey()
  final double masteryScore;
// 0.0–1.0
  @override
  @JsonKey()
  final int weakTopicCount;
  @override
  @JsonKey()
  final int totalStudyMinutes;
  @override
  final DateTime createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'Subject(id: $id, semesterId: $semesterId, userId: $userId, name: $name, description: $description, code: $code, colorIndex: $colorIndex, iconName: $iconName, unitCount: $unitCount, topicCount: $topicCount, masteryScore: $masteryScore, weakTopicCount: $weakTopicCount, totalStudyMinutes: $totalStudyMinutes, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SubjectImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.semesterId, semesterId) ||
                other.semesterId == semesterId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.colorIndex, colorIndex) ||
                other.colorIndex == colorIndex) &&
            (identical(other.iconName, iconName) ||
                other.iconName == iconName) &&
            (identical(other.unitCount, unitCount) ||
                other.unitCount == unitCount) &&
            (identical(other.topicCount, topicCount) ||
                other.topicCount == topicCount) &&
            (identical(other.masteryScore, masteryScore) ||
                other.masteryScore == masteryScore) &&
            (identical(other.weakTopicCount, weakTopicCount) ||
                other.weakTopicCount == weakTopicCount) &&
            (identical(other.totalStudyMinutes, totalStudyMinutes) ||
                other.totalStudyMinutes == totalStudyMinutes) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      semesterId,
      userId,
      name,
      description,
      code,
      colorIndex,
      iconName,
      unitCount,
      topicCount,
      masteryScore,
      weakTopicCount,
      totalStudyMinutes,
      createdAt,
      updatedAt);

  /// Create a copy of Subject
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SubjectImplCopyWith<_$SubjectImpl> get copyWith =>
      __$$SubjectImplCopyWithImpl<_$SubjectImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SubjectImplToJson(
      this,
    );
  }
}

abstract class _Subject implements Subject {
  const factory _Subject(
      {required final String id,
      required final String semesterId,
      required final String userId,
      required final String name,
      final String? description,
      final String? code,
      required final int colorIndex,
      final String? iconName,
      final int unitCount,
      final int topicCount,
      final double masteryScore,
      final int weakTopicCount,
      final int totalStudyMinutes,
      required final DateTime createdAt,
      final DateTime? updatedAt}) = _$SubjectImpl;

  factory _Subject.fromJson(Map<String, dynamic> json) = _$SubjectImpl.fromJson;

  @override
  String get id;
  @override
  String get semesterId;
  @override
  String get userId;
  @override
  String get name;
  @override
  String? get description;
  @override
  String? get code; // e.g. "CS301"
  @override
  int get colorIndex; // index into AppColors.subjectColors
  @override
  String? get iconName;
  @override
  int get unitCount;
  @override
  int get topicCount;
  @override
  double get masteryScore; // 0.0–1.0
  @override
  int get weakTopicCount;
  @override
  int get totalStudyMinutes;
  @override
  DateTime get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of Subject
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SubjectImplCopyWith<_$SubjectImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
