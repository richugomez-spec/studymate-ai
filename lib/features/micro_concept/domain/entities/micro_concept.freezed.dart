// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'micro_concept.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

MicroConcept _$MicroConceptFromJson(Map<String, dynamic> json) {
  return _MicroConcept.fromJson(json);
}

/// @nodoc
mixin _$MicroConcept {
  String get id => throw _privateConstructorUsedError;
  String get topicId => throw _privateConstructorUsedError;
  String get subjectId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  List<String> get keyFormulas => throw _privateConstructorUsedError;
  double get masteryScore => throw _privateConstructorUsedError; // 0.0 - 1.0
  double get confidenceScore => throw _privateConstructorUsedError; // 0.0 - 1.0
  double get stabilityFactor =>
      throw _privateConstructorUsedError; // memory stability half-life in days
  double get forgettingProbability =>
      throw _privateConstructorUsedError; // 0.0 - 1.0
  int get revisionCount => throw _privateConstructorUsedError;
  double get quizAccuracy => throw _privateConstructorUsedError;
  int get estimatedStudyMinutes => throw _privateConstructorUsedError;
  int get estimatedRevisionMinutes => throw _privateConstructorUsedError;
  DateTime? get lastStudiedAt => throw _privateConstructorUsedError;
  DateTime? get nextRevisionDue => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this MicroConcept to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MicroConcept
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MicroConceptCopyWith<MicroConcept> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MicroConceptCopyWith<$Res> {
  factory $MicroConceptCopyWith(
          MicroConcept value, $Res Function(MicroConcept) then) =
      _$MicroConceptCopyWithImpl<$Res, MicroConcept>;
  @useResult
  $Res call(
      {String id,
      String topicId,
      String subjectId,
      String name,
      DateTime createdAt,
      String? description,
      List<String> keyFormulas,
      double masteryScore,
      double confidenceScore,
      double stabilityFactor,
      double forgettingProbability,
      int revisionCount,
      double quizAccuracy,
      int estimatedStudyMinutes,
      int estimatedRevisionMinutes,
      DateTime? lastStudiedAt,
      DateTime? nextRevisionDue,
      DateTime? updatedAt});
}

/// @nodoc
class _$MicroConceptCopyWithImpl<$Res, $Val extends MicroConcept>
    implements $MicroConceptCopyWith<$Res> {
  _$MicroConceptCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MicroConcept
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? topicId = null,
    Object? subjectId = null,
    Object? name = null,
    Object? createdAt = null,
    Object? description = freezed,
    Object? keyFormulas = null,
    Object? masteryScore = null,
    Object? confidenceScore = null,
    Object? stabilityFactor = null,
    Object? forgettingProbability = null,
    Object? revisionCount = null,
    Object? quizAccuracy = null,
    Object? estimatedStudyMinutes = null,
    Object? estimatedRevisionMinutes = null,
    Object? lastStudiedAt = freezed,
    Object? nextRevisionDue = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      topicId: null == topicId
          ? _value.topicId
          : topicId // ignore: cast_nullable_to_non_nullable
              as String,
      subjectId: null == subjectId
          ? _value.subjectId
          : subjectId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      keyFormulas: null == keyFormulas
          ? _value.keyFormulas
          : keyFormulas // ignore: cast_nullable_to_non_nullable
              as List<String>,
      masteryScore: null == masteryScore
          ? _value.masteryScore
          : masteryScore // ignore: cast_nullable_to_non_nullable
              as double,
      confidenceScore: null == confidenceScore
          ? _value.confidenceScore
          : confidenceScore // ignore: cast_nullable_to_non_nullable
              as double,
      stabilityFactor: null == stabilityFactor
          ? _value.stabilityFactor
          : stabilityFactor // ignore: cast_nullable_to_non_nullable
              as double,
      forgettingProbability: null == forgettingProbability
          ? _value.forgettingProbability
          : forgettingProbability // ignore: cast_nullable_to_non_nullable
              as double,
      revisionCount: null == revisionCount
          ? _value.revisionCount
          : revisionCount // ignore: cast_nullable_to_non_nullable
              as int,
      quizAccuracy: null == quizAccuracy
          ? _value.quizAccuracy
          : quizAccuracy // ignore: cast_nullable_to_non_nullable
              as double,
      estimatedStudyMinutes: null == estimatedStudyMinutes
          ? _value.estimatedStudyMinutes
          : estimatedStudyMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      estimatedRevisionMinutes: null == estimatedRevisionMinutes
          ? _value.estimatedRevisionMinutes
          : estimatedRevisionMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      lastStudiedAt: freezed == lastStudiedAt
          ? _value.lastStudiedAt
          : lastStudiedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      nextRevisionDue: freezed == nextRevisionDue
          ? _value.nextRevisionDue
          : nextRevisionDue // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MicroConceptImplCopyWith<$Res>
    implements $MicroConceptCopyWith<$Res> {
  factory _$$MicroConceptImplCopyWith(
          _$MicroConceptImpl value, $Res Function(_$MicroConceptImpl) then) =
      __$$MicroConceptImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String topicId,
      String subjectId,
      String name,
      DateTime createdAt,
      String? description,
      List<String> keyFormulas,
      double masteryScore,
      double confidenceScore,
      double stabilityFactor,
      double forgettingProbability,
      int revisionCount,
      double quizAccuracy,
      int estimatedStudyMinutes,
      int estimatedRevisionMinutes,
      DateTime? lastStudiedAt,
      DateTime? nextRevisionDue,
      DateTime? updatedAt});
}

/// @nodoc
class __$$MicroConceptImplCopyWithImpl<$Res>
    extends _$MicroConceptCopyWithImpl<$Res, _$MicroConceptImpl>
    implements _$$MicroConceptImplCopyWith<$Res> {
  __$$MicroConceptImplCopyWithImpl(
      _$MicroConceptImpl _value, $Res Function(_$MicroConceptImpl) _then)
      : super(_value, _then);

  /// Create a copy of MicroConcept
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? topicId = null,
    Object? subjectId = null,
    Object? name = null,
    Object? createdAt = null,
    Object? description = freezed,
    Object? keyFormulas = null,
    Object? masteryScore = null,
    Object? confidenceScore = null,
    Object? stabilityFactor = null,
    Object? forgettingProbability = null,
    Object? revisionCount = null,
    Object? quizAccuracy = null,
    Object? estimatedStudyMinutes = null,
    Object? estimatedRevisionMinutes = null,
    Object? lastStudiedAt = freezed,
    Object? nextRevisionDue = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$MicroConceptImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      topicId: null == topicId
          ? _value.topicId
          : topicId // ignore: cast_nullable_to_non_nullable
              as String,
      subjectId: null == subjectId
          ? _value.subjectId
          : subjectId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      keyFormulas: null == keyFormulas
          ? _value._keyFormulas
          : keyFormulas // ignore: cast_nullable_to_non_nullable
              as List<String>,
      masteryScore: null == masteryScore
          ? _value.masteryScore
          : masteryScore // ignore: cast_nullable_to_non_nullable
              as double,
      confidenceScore: null == confidenceScore
          ? _value.confidenceScore
          : confidenceScore // ignore: cast_nullable_to_non_nullable
              as double,
      stabilityFactor: null == stabilityFactor
          ? _value.stabilityFactor
          : stabilityFactor // ignore: cast_nullable_to_non_nullable
              as double,
      forgettingProbability: null == forgettingProbability
          ? _value.forgettingProbability
          : forgettingProbability // ignore: cast_nullable_to_non_nullable
              as double,
      revisionCount: null == revisionCount
          ? _value.revisionCount
          : revisionCount // ignore: cast_nullable_to_non_nullable
              as int,
      quizAccuracy: null == quizAccuracy
          ? _value.quizAccuracy
          : quizAccuracy // ignore: cast_nullable_to_non_nullable
              as double,
      estimatedStudyMinutes: null == estimatedStudyMinutes
          ? _value.estimatedStudyMinutes
          : estimatedStudyMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      estimatedRevisionMinutes: null == estimatedRevisionMinutes
          ? _value.estimatedRevisionMinutes
          : estimatedRevisionMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      lastStudiedAt: freezed == lastStudiedAt
          ? _value.lastStudiedAt
          : lastStudiedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      nextRevisionDue: freezed == nextRevisionDue
          ? _value.nextRevisionDue
          : nextRevisionDue // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MicroConceptImpl implements _MicroConcept {
  const _$MicroConceptImpl(
      {required this.id,
      required this.topicId,
      required this.subjectId,
      required this.name,
      required this.createdAt,
      this.description,
      final List<String> keyFormulas = const [],
      this.masteryScore = 0.0,
      this.confidenceScore = 0.0,
      this.stabilityFactor = 1.0,
      this.forgettingProbability = 0.0,
      this.revisionCount = 0,
      this.quizAccuracy = 0.0,
      this.estimatedStudyMinutes = 15,
      this.estimatedRevisionMinutes = 5,
      this.lastStudiedAt,
      this.nextRevisionDue,
      this.updatedAt})
      : _keyFormulas = keyFormulas;

  factory _$MicroConceptImpl.fromJson(Map<String, dynamic> json) =>
      _$$MicroConceptImplFromJson(json);

  @override
  final String id;
  @override
  final String topicId;
  @override
  final String subjectId;
  @override
  final String name;
  @override
  final DateTime createdAt;
  @override
  final String? description;
  final List<String> _keyFormulas;
  @override
  @JsonKey()
  List<String> get keyFormulas {
    if (_keyFormulas is EqualUnmodifiableListView) return _keyFormulas;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_keyFormulas);
  }

  @override
  @JsonKey()
  final double masteryScore;
// 0.0 - 1.0
  @override
  @JsonKey()
  final double confidenceScore;
// 0.0 - 1.0
  @override
  @JsonKey()
  final double stabilityFactor;
// memory stability half-life in days
  @override
  @JsonKey()
  final double forgettingProbability;
// 0.0 - 1.0
  @override
  @JsonKey()
  final int revisionCount;
  @override
  @JsonKey()
  final double quizAccuracy;
  @override
  @JsonKey()
  final int estimatedStudyMinutes;
  @override
  @JsonKey()
  final int estimatedRevisionMinutes;
  @override
  final DateTime? lastStudiedAt;
  @override
  final DateTime? nextRevisionDue;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'MicroConcept(id: $id, topicId: $topicId, subjectId: $subjectId, name: $name, createdAt: $createdAt, description: $description, keyFormulas: $keyFormulas, masteryScore: $masteryScore, confidenceScore: $confidenceScore, stabilityFactor: $stabilityFactor, forgettingProbability: $forgettingProbability, revisionCount: $revisionCount, quizAccuracy: $quizAccuracy, estimatedStudyMinutes: $estimatedStudyMinutes, estimatedRevisionMinutes: $estimatedRevisionMinutes, lastStudiedAt: $lastStudiedAt, nextRevisionDue: $nextRevisionDue, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MicroConceptImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.topicId, topicId) || other.topicId == topicId) &&
            (identical(other.subjectId, subjectId) ||
                other.subjectId == subjectId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality()
                .equals(other._keyFormulas, _keyFormulas) &&
            (identical(other.masteryScore, masteryScore) ||
                other.masteryScore == masteryScore) &&
            (identical(other.confidenceScore, confidenceScore) ||
                other.confidenceScore == confidenceScore) &&
            (identical(other.stabilityFactor, stabilityFactor) ||
                other.stabilityFactor == stabilityFactor) &&
            (identical(other.forgettingProbability, forgettingProbability) ||
                other.forgettingProbability == forgettingProbability) &&
            (identical(other.revisionCount, revisionCount) ||
                other.revisionCount == revisionCount) &&
            (identical(other.quizAccuracy, quizAccuracy) ||
                other.quizAccuracy == quizAccuracy) &&
            (identical(other.estimatedStudyMinutes, estimatedStudyMinutes) ||
                other.estimatedStudyMinutes == estimatedStudyMinutes) &&
            (identical(
                    other.estimatedRevisionMinutes, estimatedRevisionMinutes) ||
                other.estimatedRevisionMinutes == estimatedRevisionMinutes) &&
            (identical(other.lastStudiedAt, lastStudiedAt) ||
                other.lastStudiedAt == lastStudiedAt) &&
            (identical(other.nextRevisionDue, nextRevisionDue) ||
                other.nextRevisionDue == nextRevisionDue) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      topicId,
      subjectId,
      name,
      createdAt,
      description,
      const DeepCollectionEquality().hash(_keyFormulas),
      masteryScore,
      confidenceScore,
      stabilityFactor,
      forgettingProbability,
      revisionCount,
      quizAccuracy,
      estimatedStudyMinutes,
      estimatedRevisionMinutes,
      lastStudiedAt,
      nextRevisionDue,
      updatedAt);

  /// Create a copy of MicroConcept
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MicroConceptImplCopyWith<_$MicroConceptImpl> get copyWith =>
      __$$MicroConceptImplCopyWithImpl<_$MicroConceptImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MicroConceptImplToJson(
      this,
    );
  }
}

abstract class _MicroConcept implements MicroConcept {
  const factory _MicroConcept(
      {required final String id,
      required final String topicId,
      required final String subjectId,
      required final String name,
      required final DateTime createdAt,
      final String? description,
      final List<String> keyFormulas,
      final double masteryScore,
      final double confidenceScore,
      final double stabilityFactor,
      final double forgettingProbability,
      final int revisionCount,
      final double quizAccuracy,
      final int estimatedStudyMinutes,
      final int estimatedRevisionMinutes,
      final DateTime? lastStudiedAt,
      final DateTime? nextRevisionDue,
      final DateTime? updatedAt}) = _$MicroConceptImpl;

  factory _MicroConcept.fromJson(Map<String, dynamic> json) =
      _$MicroConceptImpl.fromJson;

  @override
  String get id;
  @override
  String get topicId;
  @override
  String get subjectId;
  @override
  String get name;
  @override
  DateTime get createdAt;
  @override
  String? get description;
  @override
  List<String> get keyFormulas;
  @override
  double get masteryScore; // 0.0 - 1.0
  @override
  double get confidenceScore; // 0.0 - 1.0
  @override
  double get stabilityFactor; // memory stability half-life in days
  @override
  double get forgettingProbability; // 0.0 - 1.0
  @override
  int get revisionCount;
  @override
  double get quizAccuracy;
  @override
  int get estimatedStudyMinutes;
  @override
  int get estimatedRevisionMinutes;
  @override
  DateTime? get lastStudiedAt;
  @override
  DateTime? get nextRevisionDue;
  @override
  DateTime? get updatedAt;

  /// Create a copy of MicroConcept
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MicroConceptImplCopyWith<_$MicroConceptImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
