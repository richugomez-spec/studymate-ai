// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'concept_dependency.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ConceptDependency _$ConceptDependencyFromJson(Map<String, dynamic> json) {
  return _ConceptDependency.fromJson(json);
}

/// @nodoc
mixin _$ConceptDependency {
  String get id => throw _privateConstructorUsedError;
  String get sourceConceptId => throw _privateConstructorUsedError;
  String get targetConceptId => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  String get dependencyType =>
      throw _privateConstructorUsedError; // prerequisite, correlated, part_of, contrasted_with
  double get strength => throw _privateConstructorUsedError;

  /// Serializes this ConceptDependency to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ConceptDependency
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ConceptDependencyCopyWith<ConceptDependency> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ConceptDependencyCopyWith<$Res> {
  factory $ConceptDependencyCopyWith(
          ConceptDependency value, $Res Function(ConceptDependency) then) =
      _$ConceptDependencyCopyWithImpl<$Res, ConceptDependency>;
  @useResult
  $Res call(
      {String id,
      String sourceConceptId,
      String targetConceptId,
      DateTime createdAt,
      String dependencyType,
      double strength});
}

/// @nodoc
class _$ConceptDependencyCopyWithImpl<$Res, $Val extends ConceptDependency>
    implements $ConceptDependencyCopyWith<$Res> {
  _$ConceptDependencyCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ConceptDependency
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? sourceConceptId = null,
    Object? targetConceptId = null,
    Object? createdAt = null,
    Object? dependencyType = null,
    Object? strength = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      sourceConceptId: null == sourceConceptId
          ? _value.sourceConceptId
          : sourceConceptId // ignore: cast_nullable_to_non_nullable
              as String,
      targetConceptId: null == targetConceptId
          ? _value.targetConceptId
          : targetConceptId // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      dependencyType: null == dependencyType
          ? _value.dependencyType
          : dependencyType // ignore: cast_nullable_to_non_nullable
              as String,
      strength: null == strength
          ? _value.strength
          : strength // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ConceptDependencyImplCopyWith<$Res>
    implements $ConceptDependencyCopyWith<$Res> {
  factory _$$ConceptDependencyImplCopyWith(_$ConceptDependencyImpl value,
          $Res Function(_$ConceptDependencyImpl) then) =
      __$$ConceptDependencyImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String sourceConceptId,
      String targetConceptId,
      DateTime createdAt,
      String dependencyType,
      double strength});
}

/// @nodoc
class __$$ConceptDependencyImplCopyWithImpl<$Res>
    extends _$ConceptDependencyCopyWithImpl<$Res, _$ConceptDependencyImpl>
    implements _$$ConceptDependencyImplCopyWith<$Res> {
  __$$ConceptDependencyImplCopyWithImpl(_$ConceptDependencyImpl _value,
      $Res Function(_$ConceptDependencyImpl) _then)
      : super(_value, _then);

  /// Create a copy of ConceptDependency
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? sourceConceptId = null,
    Object? targetConceptId = null,
    Object? createdAt = null,
    Object? dependencyType = null,
    Object? strength = null,
  }) {
    return _then(_$ConceptDependencyImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      sourceConceptId: null == sourceConceptId
          ? _value.sourceConceptId
          : sourceConceptId // ignore: cast_nullable_to_non_nullable
              as String,
      targetConceptId: null == targetConceptId
          ? _value.targetConceptId
          : targetConceptId // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      dependencyType: null == dependencyType
          ? _value.dependencyType
          : dependencyType // ignore: cast_nullable_to_non_nullable
              as String,
      strength: null == strength
          ? _value.strength
          : strength // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ConceptDependencyImpl implements _ConceptDependency {
  const _$ConceptDependencyImpl(
      {required this.id,
      required this.sourceConceptId,
      required this.targetConceptId,
      required this.createdAt,
      this.dependencyType = 'prerequisite',
      this.strength = 1.0});

  factory _$ConceptDependencyImpl.fromJson(Map<String, dynamic> json) =>
      _$$ConceptDependencyImplFromJson(json);

  @override
  final String id;
  @override
  final String sourceConceptId;
  @override
  final String targetConceptId;
  @override
  final DateTime createdAt;
  @override
  @JsonKey()
  final String dependencyType;
// prerequisite, correlated, part_of, contrasted_with
  @override
  @JsonKey()
  final double strength;

  @override
  String toString() {
    return 'ConceptDependency(id: $id, sourceConceptId: $sourceConceptId, targetConceptId: $targetConceptId, createdAt: $createdAt, dependencyType: $dependencyType, strength: $strength)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConceptDependencyImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.sourceConceptId, sourceConceptId) ||
                other.sourceConceptId == sourceConceptId) &&
            (identical(other.targetConceptId, targetConceptId) ||
                other.targetConceptId == targetConceptId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.dependencyType, dependencyType) ||
                other.dependencyType == dependencyType) &&
            (identical(other.strength, strength) ||
                other.strength == strength));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, sourceConceptId,
      targetConceptId, createdAt, dependencyType, strength);

  /// Create a copy of ConceptDependency
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ConceptDependencyImplCopyWith<_$ConceptDependencyImpl> get copyWith =>
      __$$ConceptDependencyImplCopyWithImpl<_$ConceptDependencyImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ConceptDependencyImplToJson(
      this,
    );
  }
}

abstract class _ConceptDependency implements ConceptDependency {
  const factory _ConceptDependency(
      {required final String id,
      required final String sourceConceptId,
      required final String targetConceptId,
      required final DateTime createdAt,
      final String dependencyType,
      final double strength}) = _$ConceptDependencyImpl;

  factory _ConceptDependency.fromJson(Map<String, dynamic> json) =
      _$ConceptDependencyImpl.fromJson;

  @override
  String get id;
  @override
  String get sourceConceptId;
  @override
  String get targetConceptId;
  @override
  DateTime get createdAt;
  @override
  String
      get dependencyType; // prerequisite, correlated, part_of, contrasted_with
  @override
  double get strength;

  /// Create a copy of ConceptDependency
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ConceptDependencyImplCopyWith<_$ConceptDependencyImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
