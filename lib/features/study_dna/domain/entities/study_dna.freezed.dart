// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'study_dna.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SensoryProfile _$SensoryProfileFromJson(Map<String, dynamic> json) {
  return _SensoryProfile.fromJson(json);
}

/// @nodoc
mixin _$SensoryProfile {
  double get visualWeight => throw _privateConstructorUsedError;
  double get textWeight => throw _privateConstructorUsedError;
  double get audioWeight => throw _privateConstructorUsedError;
  double get quizWeight => throw _privateConstructorUsedError;

  /// Serializes this SensoryProfile to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SensoryProfile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SensoryProfileCopyWith<SensoryProfile> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SensoryProfileCopyWith<$Res> {
  factory $SensoryProfileCopyWith(
          SensoryProfile value, $Res Function(SensoryProfile) then) =
      _$SensoryProfileCopyWithImpl<$Res, SensoryProfile>;
  @useResult
  $Res call(
      {double visualWeight,
      double textWeight,
      double audioWeight,
      double quizWeight});
}

/// @nodoc
class _$SensoryProfileCopyWithImpl<$Res, $Val extends SensoryProfile>
    implements $SensoryProfileCopyWith<$Res> {
  _$SensoryProfileCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SensoryProfile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? visualWeight = null,
    Object? textWeight = null,
    Object? audioWeight = null,
    Object? quizWeight = null,
  }) {
    return _then(_value.copyWith(
      visualWeight: null == visualWeight
          ? _value.visualWeight
          : visualWeight // ignore: cast_nullable_to_non_nullable
              as double,
      textWeight: null == textWeight
          ? _value.textWeight
          : textWeight // ignore: cast_nullable_to_non_nullable
              as double,
      audioWeight: null == audioWeight
          ? _value.audioWeight
          : audioWeight // ignore: cast_nullable_to_non_nullable
              as double,
      quizWeight: null == quizWeight
          ? _value.quizWeight
          : quizWeight // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SensoryProfileImplCopyWith<$Res>
    implements $SensoryProfileCopyWith<$Res> {
  factory _$$SensoryProfileImplCopyWith(_$SensoryProfileImpl value,
          $Res Function(_$SensoryProfileImpl) then) =
      __$$SensoryProfileImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {double visualWeight,
      double textWeight,
      double audioWeight,
      double quizWeight});
}

/// @nodoc
class __$$SensoryProfileImplCopyWithImpl<$Res>
    extends _$SensoryProfileCopyWithImpl<$Res, _$SensoryProfileImpl>
    implements _$$SensoryProfileImplCopyWith<$Res> {
  __$$SensoryProfileImplCopyWithImpl(
      _$SensoryProfileImpl _value, $Res Function(_$SensoryProfileImpl) _then)
      : super(_value, _then);

  /// Create a copy of SensoryProfile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? visualWeight = null,
    Object? textWeight = null,
    Object? audioWeight = null,
    Object? quizWeight = null,
  }) {
    return _then(_$SensoryProfileImpl(
      visualWeight: null == visualWeight
          ? _value.visualWeight
          : visualWeight // ignore: cast_nullable_to_non_nullable
              as double,
      textWeight: null == textWeight
          ? _value.textWeight
          : textWeight // ignore: cast_nullable_to_non_nullable
              as double,
      audioWeight: null == audioWeight
          ? _value.audioWeight
          : audioWeight // ignore: cast_nullable_to_non_nullable
              as double,
      quizWeight: null == quizWeight
          ? _value.quizWeight
          : quizWeight // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SensoryProfileImpl implements _SensoryProfile {
  const _$SensoryProfileImpl(
      {this.visualWeight = 0.7,
      this.textWeight = 0.5,
      this.audioWeight = 0.5,
      this.quizWeight = 0.8});

  factory _$SensoryProfileImpl.fromJson(Map<String, dynamic> json) =>
      _$$SensoryProfileImplFromJson(json);

  @override
  @JsonKey()
  final double visualWeight;
  @override
  @JsonKey()
  final double textWeight;
  @override
  @JsonKey()
  final double audioWeight;
  @override
  @JsonKey()
  final double quizWeight;

  @override
  String toString() {
    return 'SensoryProfile(visualWeight: $visualWeight, textWeight: $textWeight, audioWeight: $audioWeight, quizWeight: $quizWeight)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SensoryProfileImpl &&
            (identical(other.visualWeight, visualWeight) ||
                other.visualWeight == visualWeight) &&
            (identical(other.textWeight, textWeight) ||
                other.textWeight == textWeight) &&
            (identical(other.audioWeight, audioWeight) ||
                other.audioWeight == audioWeight) &&
            (identical(other.quizWeight, quizWeight) ||
                other.quizWeight == quizWeight));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, visualWeight, textWeight, audioWeight, quizWeight);

  /// Create a copy of SensoryProfile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SensoryProfileImplCopyWith<_$SensoryProfileImpl> get copyWith =>
      __$$SensoryProfileImplCopyWithImpl<_$SensoryProfileImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SensoryProfileImplToJson(
      this,
    );
  }
}

abstract class _SensoryProfile implements SensoryProfile {
  const factory _SensoryProfile(
      {final double visualWeight,
      final double textWeight,
      final double audioWeight,
      final double quizWeight}) = _$SensoryProfileImpl;

  factory _SensoryProfile.fromJson(Map<String, dynamic> json) =
      _$SensoryProfileImpl.fromJson;

  @override
  double get visualWeight;
  @override
  double get textWeight;
  @override
  double get audioWeight;
  @override
  double get quizWeight;

  /// Create a copy of SensoryProfile
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SensoryProfileImplCopyWith<_$SensoryProfileImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PedagogicalProfile _$PedagogicalProfileFromJson(Map<String, dynamic> json) {
  return _PedagogicalProfile.fromJson(json);
}

/// @nodoc
mixin _$PedagogicalProfile {
  double get deductiveVsInductive =>
      throw _privateConstructorUsedError; // 0.0 = example first, 1.0 = theory first
  String get explanationDepth =>
      throw _privateConstructorUsedError; // concise, standard, first_principles, analogy_driven
  double get mathAffinity => throw _privateConstructorUsedError;
  double get theoryAffinity => throw _privateConstructorUsedError;

  /// Serializes this PedagogicalProfile to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PedagogicalProfile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PedagogicalProfileCopyWith<PedagogicalProfile> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PedagogicalProfileCopyWith<$Res> {
  factory $PedagogicalProfileCopyWith(
          PedagogicalProfile value, $Res Function(PedagogicalProfile) then) =
      _$PedagogicalProfileCopyWithImpl<$Res, PedagogicalProfile>;
  @useResult
  $Res call(
      {double deductiveVsInductive,
      String explanationDepth,
      double mathAffinity,
      double theoryAffinity});
}

/// @nodoc
class _$PedagogicalProfileCopyWithImpl<$Res, $Val extends PedagogicalProfile>
    implements $PedagogicalProfileCopyWith<$Res> {
  _$PedagogicalProfileCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PedagogicalProfile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? deductiveVsInductive = null,
    Object? explanationDepth = null,
    Object? mathAffinity = null,
    Object? theoryAffinity = null,
  }) {
    return _then(_value.copyWith(
      deductiveVsInductive: null == deductiveVsInductive
          ? _value.deductiveVsInductive
          : deductiveVsInductive // ignore: cast_nullable_to_non_nullable
              as double,
      explanationDepth: null == explanationDepth
          ? _value.explanationDepth
          : explanationDepth // ignore: cast_nullable_to_non_nullable
              as String,
      mathAffinity: null == mathAffinity
          ? _value.mathAffinity
          : mathAffinity // ignore: cast_nullable_to_non_nullable
              as double,
      theoryAffinity: null == theoryAffinity
          ? _value.theoryAffinity
          : theoryAffinity // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PedagogicalProfileImplCopyWith<$Res>
    implements $PedagogicalProfileCopyWith<$Res> {
  factory _$$PedagogicalProfileImplCopyWith(_$PedagogicalProfileImpl value,
          $Res Function(_$PedagogicalProfileImpl) then) =
      __$$PedagogicalProfileImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {double deductiveVsInductive,
      String explanationDepth,
      double mathAffinity,
      double theoryAffinity});
}

/// @nodoc
class __$$PedagogicalProfileImplCopyWithImpl<$Res>
    extends _$PedagogicalProfileCopyWithImpl<$Res, _$PedagogicalProfileImpl>
    implements _$$PedagogicalProfileImplCopyWith<$Res> {
  __$$PedagogicalProfileImplCopyWithImpl(_$PedagogicalProfileImpl _value,
      $Res Function(_$PedagogicalProfileImpl) _then)
      : super(_value, _then);

  /// Create a copy of PedagogicalProfile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? deductiveVsInductive = null,
    Object? explanationDepth = null,
    Object? mathAffinity = null,
    Object? theoryAffinity = null,
  }) {
    return _then(_$PedagogicalProfileImpl(
      deductiveVsInductive: null == deductiveVsInductive
          ? _value.deductiveVsInductive
          : deductiveVsInductive // ignore: cast_nullable_to_non_nullable
              as double,
      explanationDepth: null == explanationDepth
          ? _value.explanationDepth
          : explanationDepth // ignore: cast_nullable_to_non_nullable
              as String,
      mathAffinity: null == mathAffinity
          ? _value.mathAffinity
          : mathAffinity // ignore: cast_nullable_to_non_nullable
              as double,
      theoryAffinity: null == theoryAffinity
          ? _value.theoryAffinity
          : theoryAffinity // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PedagogicalProfileImpl implements _PedagogicalProfile {
  const _$PedagogicalProfileImpl(
      {this.deductiveVsInductive = 0.4,
      this.explanationDepth = 'first_principles',
      this.mathAffinity = 0.6,
      this.theoryAffinity = 0.6});

  factory _$PedagogicalProfileImpl.fromJson(Map<String, dynamic> json) =>
      _$$PedagogicalProfileImplFromJson(json);

  @override
  @JsonKey()
  final double deductiveVsInductive;
// 0.0 = example first, 1.0 = theory first
  @override
  @JsonKey()
  final String explanationDepth;
// concise, standard, first_principles, analogy_driven
  @override
  @JsonKey()
  final double mathAffinity;
  @override
  @JsonKey()
  final double theoryAffinity;

  @override
  String toString() {
    return 'PedagogicalProfile(deductiveVsInductive: $deductiveVsInductive, explanationDepth: $explanationDepth, mathAffinity: $mathAffinity, theoryAffinity: $theoryAffinity)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PedagogicalProfileImpl &&
            (identical(other.deductiveVsInductive, deductiveVsInductive) ||
                other.deductiveVsInductive == deductiveVsInductive) &&
            (identical(other.explanationDepth, explanationDepth) ||
                other.explanationDepth == explanationDepth) &&
            (identical(other.mathAffinity, mathAffinity) ||
                other.mathAffinity == mathAffinity) &&
            (identical(other.theoryAffinity, theoryAffinity) ||
                other.theoryAffinity == theoryAffinity));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, deductiveVsInductive,
      explanationDepth, mathAffinity, theoryAffinity);

  /// Create a copy of PedagogicalProfile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PedagogicalProfileImplCopyWith<_$PedagogicalProfileImpl> get copyWith =>
      __$$PedagogicalProfileImplCopyWithImpl<_$PedagogicalProfileImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PedagogicalProfileImplToJson(
      this,
    );
  }
}

abstract class _PedagogicalProfile implements PedagogicalProfile {
  const factory _PedagogicalProfile(
      {final double deductiveVsInductive,
      final String explanationDepth,
      final double mathAffinity,
      final double theoryAffinity}) = _$PedagogicalProfileImpl;

  factory _PedagogicalProfile.fromJson(Map<String, dynamic> json) =
      _$PedagogicalProfileImpl.fromJson;

  @override
  double get deductiveVsInductive; // 0.0 = example first, 1.0 = theory first
  @override
  String
      get explanationDepth; // concise, standard, first_principles, analogy_driven
  @override
  double get mathAffinity;
  @override
  double get theoryAffinity;

  /// Create a copy of PedagogicalProfile
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PedagogicalProfileImplCopyWith<_$PedagogicalProfileImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TemporalProfile _$TemporalProfileFromJson(Map<String, dynamic> json) {
  return _TemporalProfile.fromJson(json);
}

/// @nodoc
mixin _$TemporalProfile {
  List<String> get peakHours => throw _privateConstructorUsedError;
  int get focusDurationMinutes => throw _privateConstructorUsedError;
  int get readingSpeedWpm => throw _privateConstructorUsedError;
  double get cognitiveFatigueRate => throw _privateConstructorUsedError;

  /// Serializes this TemporalProfile to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TemporalProfile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TemporalProfileCopyWith<TemporalProfile> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TemporalProfileCopyWith<$Res> {
  factory $TemporalProfileCopyWith(
          TemporalProfile value, $Res Function(TemporalProfile) then) =
      _$TemporalProfileCopyWithImpl<$Res, TemporalProfile>;
  @useResult
  $Res call(
      {List<String> peakHours,
      int focusDurationMinutes,
      int readingSpeedWpm,
      double cognitiveFatigueRate});
}

/// @nodoc
class _$TemporalProfileCopyWithImpl<$Res, $Val extends TemporalProfile>
    implements $TemporalProfileCopyWith<$Res> {
  _$TemporalProfileCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TemporalProfile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? peakHours = null,
    Object? focusDurationMinutes = null,
    Object? readingSpeedWpm = null,
    Object? cognitiveFatigueRate = null,
  }) {
    return _then(_value.copyWith(
      peakHours: null == peakHours
          ? _value.peakHours
          : peakHours // ignore: cast_nullable_to_non_nullable
              as List<String>,
      focusDurationMinutes: null == focusDurationMinutes
          ? _value.focusDurationMinutes
          : focusDurationMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      readingSpeedWpm: null == readingSpeedWpm
          ? _value.readingSpeedWpm
          : readingSpeedWpm // ignore: cast_nullable_to_non_nullable
              as int,
      cognitiveFatigueRate: null == cognitiveFatigueRate
          ? _value.cognitiveFatigueRate
          : cognitiveFatigueRate // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TemporalProfileImplCopyWith<$Res>
    implements $TemporalProfileCopyWith<$Res> {
  factory _$$TemporalProfileImplCopyWith(_$TemporalProfileImpl value,
          $Res Function(_$TemporalProfileImpl) then) =
      __$$TemporalProfileImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<String> peakHours,
      int focusDurationMinutes,
      int readingSpeedWpm,
      double cognitiveFatigueRate});
}

/// @nodoc
class __$$TemporalProfileImplCopyWithImpl<$Res>
    extends _$TemporalProfileCopyWithImpl<$Res, _$TemporalProfileImpl>
    implements _$$TemporalProfileImplCopyWith<$Res> {
  __$$TemporalProfileImplCopyWithImpl(
      _$TemporalProfileImpl _value, $Res Function(_$TemporalProfileImpl) _then)
      : super(_value, _then);

  /// Create a copy of TemporalProfile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? peakHours = null,
    Object? focusDurationMinutes = null,
    Object? readingSpeedWpm = null,
    Object? cognitiveFatigueRate = null,
  }) {
    return _then(_$TemporalProfileImpl(
      peakHours: null == peakHours
          ? _value._peakHours
          : peakHours // ignore: cast_nullable_to_non_nullable
              as List<String>,
      focusDurationMinutes: null == focusDurationMinutes
          ? _value.focusDurationMinutes
          : focusDurationMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      readingSpeedWpm: null == readingSpeedWpm
          ? _value.readingSpeedWpm
          : readingSpeedWpm // ignore: cast_nullable_to_non_nullable
              as int,
      cognitiveFatigueRate: null == cognitiveFatigueRate
          ? _value.cognitiveFatigueRate
          : cognitiveFatigueRate // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TemporalProfileImpl implements _TemporalProfile {
  const _$TemporalProfileImpl(
      {final List<String> peakHours = const ['09:00-11:00', '19:00-21:00'],
      this.focusDurationMinutes = 25,
      this.readingSpeedWpm = 220,
      this.cognitiveFatigueRate = 0.04})
      : _peakHours = peakHours;

  factory _$TemporalProfileImpl.fromJson(Map<String, dynamic> json) =>
      _$$TemporalProfileImplFromJson(json);

  final List<String> _peakHours;
  @override
  @JsonKey()
  List<String> get peakHours {
    if (_peakHours is EqualUnmodifiableListView) return _peakHours;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_peakHours);
  }

  @override
  @JsonKey()
  final int focusDurationMinutes;
  @override
  @JsonKey()
  final int readingSpeedWpm;
  @override
  @JsonKey()
  final double cognitiveFatigueRate;

  @override
  String toString() {
    return 'TemporalProfile(peakHours: $peakHours, focusDurationMinutes: $focusDurationMinutes, readingSpeedWpm: $readingSpeedWpm, cognitiveFatigueRate: $cognitiveFatigueRate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TemporalProfileImpl &&
            const DeepCollectionEquality()
                .equals(other._peakHours, _peakHours) &&
            (identical(other.focusDurationMinutes, focusDurationMinutes) ||
                other.focusDurationMinutes == focusDurationMinutes) &&
            (identical(other.readingSpeedWpm, readingSpeedWpm) ||
                other.readingSpeedWpm == readingSpeedWpm) &&
            (identical(other.cognitiveFatigueRate, cognitiveFatigueRate) ||
                other.cognitiveFatigueRate == cognitiveFatigueRate));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_peakHours),
      focusDurationMinutes,
      readingSpeedWpm,
      cognitiveFatigueRate);

  /// Create a copy of TemporalProfile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TemporalProfileImplCopyWith<_$TemporalProfileImpl> get copyWith =>
      __$$TemporalProfileImplCopyWithImpl<_$TemporalProfileImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TemporalProfileImplToJson(
      this,
    );
  }
}

abstract class _TemporalProfile implements TemporalProfile {
  const factory _TemporalProfile(
      {final List<String> peakHours,
      final int focusDurationMinutes,
      final int readingSpeedWpm,
      final double cognitiveFatigueRate}) = _$TemporalProfileImpl;

  factory _TemporalProfile.fromJson(Map<String, dynamic> json) =
      _$TemporalProfileImpl.fromJson;

  @override
  List<String> get peakHours;
  @override
  int get focusDurationMinutes;
  @override
  int get readingSpeedWpm;
  @override
  double get cognitiveFatigueRate;

  /// Create a copy of TemporalProfile
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TemporalProfileImplCopyWith<_$TemporalProfileImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

RetentionProfile _$RetentionProfileFromJson(Map<String, dynamic> json) {
  return _RetentionProfile.fromJson(json);
}

/// @nodoc
mixin _$RetentionProfile {
  double get baselineForgettingRate => throw _privateConstructorUsedError;
  double get consolidationBoostFromQuiz => throw _privateConstructorUsedError;
  double get spacingMultiplier => throw _privateConstructorUsedError;

  /// Serializes this RetentionProfile to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RetentionProfile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RetentionProfileCopyWith<RetentionProfile> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RetentionProfileCopyWith<$Res> {
  factory $RetentionProfileCopyWith(
          RetentionProfile value, $Res Function(RetentionProfile) then) =
      _$RetentionProfileCopyWithImpl<$Res, RetentionProfile>;
  @useResult
  $Res call(
      {double baselineForgettingRate,
      double consolidationBoostFromQuiz,
      double spacingMultiplier});
}

/// @nodoc
class _$RetentionProfileCopyWithImpl<$Res, $Val extends RetentionProfile>
    implements $RetentionProfileCopyWith<$Res> {
  _$RetentionProfileCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RetentionProfile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? baselineForgettingRate = null,
    Object? consolidationBoostFromQuiz = null,
    Object? spacingMultiplier = null,
  }) {
    return _then(_value.copyWith(
      baselineForgettingRate: null == baselineForgettingRate
          ? _value.baselineForgettingRate
          : baselineForgettingRate // ignore: cast_nullable_to_non_nullable
              as double,
      consolidationBoostFromQuiz: null == consolidationBoostFromQuiz
          ? _value.consolidationBoostFromQuiz
          : consolidationBoostFromQuiz // ignore: cast_nullable_to_non_nullable
              as double,
      spacingMultiplier: null == spacingMultiplier
          ? _value.spacingMultiplier
          : spacingMultiplier // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RetentionProfileImplCopyWith<$Res>
    implements $RetentionProfileCopyWith<$Res> {
  factory _$$RetentionProfileImplCopyWith(_$RetentionProfileImpl value,
          $Res Function(_$RetentionProfileImpl) then) =
      __$$RetentionProfileImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {double baselineForgettingRate,
      double consolidationBoostFromQuiz,
      double spacingMultiplier});
}

/// @nodoc
class __$$RetentionProfileImplCopyWithImpl<$Res>
    extends _$RetentionProfileCopyWithImpl<$Res, _$RetentionProfileImpl>
    implements _$$RetentionProfileImplCopyWith<$Res> {
  __$$RetentionProfileImplCopyWithImpl(_$RetentionProfileImpl _value,
      $Res Function(_$RetentionProfileImpl) _then)
      : super(_value, _then);

  /// Create a copy of RetentionProfile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? baselineForgettingRate = null,
    Object? consolidationBoostFromQuiz = null,
    Object? spacingMultiplier = null,
  }) {
    return _then(_$RetentionProfileImpl(
      baselineForgettingRate: null == baselineForgettingRate
          ? _value.baselineForgettingRate
          : baselineForgettingRate // ignore: cast_nullable_to_non_nullable
              as double,
      consolidationBoostFromQuiz: null == consolidationBoostFromQuiz
          ? _value.consolidationBoostFromQuiz
          : consolidationBoostFromQuiz // ignore: cast_nullable_to_non_nullable
              as double,
      spacingMultiplier: null == spacingMultiplier
          ? _value.spacingMultiplier
          : spacingMultiplier // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RetentionProfileImpl implements _RetentionProfile {
  const _$RetentionProfileImpl(
      {this.baselineForgettingRate = 0.12,
      this.consolidationBoostFromQuiz = 1.3,
      this.spacingMultiplier = 1.2});

  factory _$RetentionProfileImpl.fromJson(Map<String, dynamic> json) =>
      _$$RetentionProfileImplFromJson(json);

  @override
  @JsonKey()
  final double baselineForgettingRate;
  @override
  @JsonKey()
  final double consolidationBoostFromQuiz;
  @override
  @JsonKey()
  final double spacingMultiplier;

  @override
  String toString() {
    return 'RetentionProfile(baselineForgettingRate: $baselineForgettingRate, consolidationBoostFromQuiz: $consolidationBoostFromQuiz, spacingMultiplier: $spacingMultiplier)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RetentionProfileImpl &&
            (identical(other.baselineForgettingRate, baselineForgettingRate) ||
                other.baselineForgettingRate == baselineForgettingRate) &&
            (identical(other.consolidationBoostFromQuiz,
                    consolidationBoostFromQuiz) ||
                other.consolidationBoostFromQuiz ==
                    consolidationBoostFromQuiz) &&
            (identical(other.spacingMultiplier, spacingMultiplier) ||
                other.spacingMultiplier == spacingMultiplier));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, baselineForgettingRate,
      consolidationBoostFromQuiz, spacingMultiplier);

  /// Create a copy of RetentionProfile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RetentionProfileImplCopyWith<_$RetentionProfileImpl> get copyWith =>
      __$$RetentionProfileImplCopyWithImpl<_$RetentionProfileImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RetentionProfileImplToJson(
      this,
    );
  }
}

abstract class _RetentionProfile implements RetentionProfile {
  const factory _RetentionProfile(
      {final double baselineForgettingRate,
      final double consolidationBoostFromQuiz,
      final double spacingMultiplier}) = _$RetentionProfileImpl;

  factory _RetentionProfile.fromJson(Map<String, dynamic> json) =
      _$RetentionProfileImpl.fromJson;

  @override
  double get baselineForgettingRate;
  @override
  double get consolidationBoostFromQuiz;
  @override
  double get spacingMultiplier;

  /// Create a copy of RetentionProfile
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RetentionProfileImplCopyWith<_$RetentionProfileImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

StudyDna _$StudyDnaFromJson(Map<String, dynamic> json) {
  return _StudyDna.fromJson(json);
}

/// @nodoc
mixin _$StudyDna {
  String get userId => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  SensoryProfile get sensory => throw _privateConstructorUsedError;
  PedagogicalProfile get pedagogical => throw _privateConstructorUsedError;
  TemporalProfile get temporal => throw _privateConstructorUsedError;
  RetentionProfile get retention => throw _privateConstructorUsedError;

  /// Serializes this StudyDna to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StudyDna
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StudyDnaCopyWith<StudyDna> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StudyDnaCopyWith<$Res> {
  factory $StudyDnaCopyWith(StudyDna value, $Res Function(StudyDna) then) =
      _$StudyDnaCopyWithImpl<$Res, StudyDna>;
  @useResult
  $Res call(
      {String userId,
      DateTime updatedAt,
      SensoryProfile sensory,
      PedagogicalProfile pedagogical,
      TemporalProfile temporal,
      RetentionProfile retention});

  $SensoryProfileCopyWith<$Res> get sensory;
  $PedagogicalProfileCopyWith<$Res> get pedagogical;
  $TemporalProfileCopyWith<$Res> get temporal;
  $RetentionProfileCopyWith<$Res> get retention;
}

/// @nodoc
class _$StudyDnaCopyWithImpl<$Res, $Val extends StudyDna>
    implements $StudyDnaCopyWith<$Res> {
  _$StudyDnaCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StudyDna
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? updatedAt = null,
    Object? sensory = null,
    Object? pedagogical = null,
    Object? temporal = null,
    Object? retention = null,
  }) {
    return _then(_value.copyWith(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      sensory: null == sensory
          ? _value.sensory
          : sensory // ignore: cast_nullable_to_non_nullable
              as SensoryProfile,
      pedagogical: null == pedagogical
          ? _value.pedagogical
          : pedagogical // ignore: cast_nullable_to_non_nullable
              as PedagogicalProfile,
      temporal: null == temporal
          ? _value.temporal
          : temporal // ignore: cast_nullable_to_non_nullable
              as TemporalProfile,
      retention: null == retention
          ? _value.retention
          : retention // ignore: cast_nullable_to_non_nullable
              as RetentionProfile,
    ) as $Val);
  }

  /// Create a copy of StudyDna
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SensoryProfileCopyWith<$Res> get sensory {
    return $SensoryProfileCopyWith<$Res>(_value.sensory, (value) {
      return _then(_value.copyWith(sensory: value) as $Val);
    });
  }

  /// Create a copy of StudyDna
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PedagogicalProfileCopyWith<$Res> get pedagogical {
    return $PedagogicalProfileCopyWith<$Res>(_value.pedagogical, (value) {
      return _then(_value.copyWith(pedagogical: value) as $Val);
    });
  }

  /// Create a copy of StudyDna
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TemporalProfileCopyWith<$Res> get temporal {
    return $TemporalProfileCopyWith<$Res>(_value.temporal, (value) {
      return _then(_value.copyWith(temporal: value) as $Val);
    });
  }

  /// Create a copy of StudyDna
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $RetentionProfileCopyWith<$Res> get retention {
    return $RetentionProfileCopyWith<$Res>(_value.retention, (value) {
      return _then(_value.copyWith(retention: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$StudyDnaImplCopyWith<$Res>
    implements $StudyDnaCopyWith<$Res> {
  factory _$$StudyDnaImplCopyWith(
          _$StudyDnaImpl value, $Res Function(_$StudyDnaImpl) then) =
      __$$StudyDnaImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String userId,
      DateTime updatedAt,
      SensoryProfile sensory,
      PedagogicalProfile pedagogical,
      TemporalProfile temporal,
      RetentionProfile retention});

  @override
  $SensoryProfileCopyWith<$Res> get sensory;
  @override
  $PedagogicalProfileCopyWith<$Res> get pedagogical;
  @override
  $TemporalProfileCopyWith<$Res> get temporal;
  @override
  $RetentionProfileCopyWith<$Res> get retention;
}

/// @nodoc
class __$$StudyDnaImplCopyWithImpl<$Res>
    extends _$StudyDnaCopyWithImpl<$Res, _$StudyDnaImpl>
    implements _$$StudyDnaImplCopyWith<$Res> {
  __$$StudyDnaImplCopyWithImpl(
      _$StudyDnaImpl _value, $Res Function(_$StudyDnaImpl) _then)
      : super(_value, _then);

  /// Create a copy of StudyDna
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? updatedAt = null,
    Object? sensory = null,
    Object? pedagogical = null,
    Object? temporal = null,
    Object? retention = null,
  }) {
    return _then(_$StudyDnaImpl(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      sensory: null == sensory
          ? _value.sensory
          : sensory // ignore: cast_nullable_to_non_nullable
              as SensoryProfile,
      pedagogical: null == pedagogical
          ? _value.pedagogical
          : pedagogical // ignore: cast_nullable_to_non_nullable
              as PedagogicalProfile,
      temporal: null == temporal
          ? _value.temporal
          : temporal // ignore: cast_nullable_to_non_nullable
              as TemporalProfile,
      retention: null == retention
          ? _value.retention
          : retention // ignore: cast_nullable_to_non_nullable
              as RetentionProfile,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$StudyDnaImpl implements _StudyDna {
  const _$StudyDnaImpl(
      {required this.userId,
      required this.updatedAt,
      this.sensory = const SensoryProfile(),
      this.pedagogical = const PedagogicalProfile(),
      this.temporal = const TemporalProfile(),
      this.retention = const RetentionProfile()});

  factory _$StudyDnaImpl.fromJson(Map<String, dynamic> json) =>
      _$$StudyDnaImplFromJson(json);

  @override
  final String userId;
  @override
  final DateTime updatedAt;
  @override
  @JsonKey()
  final SensoryProfile sensory;
  @override
  @JsonKey()
  final PedagogicalProfile pedagogical;
  @override
  @JsonKey()
  final TemporalProfile temporal;
  @override
  @JsonKey()
  final RetentionProfile retention;

  @override
  String toString() {
    return 'StudyDna(userId: $userId, updatedAt: $updatedAt, sensory: $sensory, pedagogical: $pedagogical, temporal: $temporal, retention: $retention)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StudyDnaImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.sensory, sensory) || other.sensory == sensory) &&
            (identical(other.pedagogical, pedagogical) ||
                other.pedagogical == pedagogical) &&
            (identical(other.temporal, temporal) ||
                other.temporal == temporal) &&
            (identical(other.retention, retention) ||
                other.retention == retention));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, userId, updatedAt, sensory,
      pedagogical, temporal, retention);

  /// Create a copy of StudyDna
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StudyDnaImplCopyWith<_$StudyDnaImpl> get copyWith =>
      __$$StudyDnaImplCopyWithImpl<_$StudyDnaImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StudyDnaImplToJson(
      this,
    );
  }
}

abstract class _StudyDna implements StudyDna {
  const factory _StudyDna(
      {required final String userId,
      required final DateTime updatedAt,
      final SensoryProfile sensory,
      final PedagogicalProfile pedagogical,
      final TemporalProfile temporal,
      final RetentionProfile retention}) = _$StudyDnaImpl;

  factory _StudyDna.fromJson(Map<String, dynamic> json) =
      _$StudyDnaImpl.fromJson;

  @override
  String get userId;
  @override
  DateTime get updatedAt;
  @override
  SensoryProfile get sensory;
  @override
  PedagogicalProfile get pedagogical;
  @override
  TemporalProfile get temporal;
  @override
  RetentionProfile get retention;

  /// Create a copy of StudyDna
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StudyDnaImplCopyWith<_$StudyDnaImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
