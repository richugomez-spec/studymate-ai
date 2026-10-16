// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'topic.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Topic _$TopicFromJson(Map<String, dynamic> json) {
  return _Topic.fromJson(json);
}

/// @nodoc
mixin _$Topic {
  String get id => throw _privateConstructorUsedError;
  String get unitId => throw _privateConstructorUsedError;
  String get subjectId => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  TopicStatus get status => throw _privateConstructorUsedError;
  double get masteryScore => throw _privateConstructorUsedError; // 0.0–1.0
  int get weaknessFlag => throw _privateConstructorUsedError; // 0–10 severity
  bool get isAIProcessed =>
      throw _privateConstructorUsedError; // embeddings generated
  List<String> get conceptTags => throw _privateConstructorUsedError;
  List<String> get learningObjectives => throw _privateConstructorUsedError;
  int get resourceCount => throw _privateConstructorUsedError;
  int get totalStudyMinutes => throw _privateConstructorUsedError;
  int get quizAttempts => throw _privateConstructorUsedError;
  double get averageQuizScore => throw _privateConstructorUsedError;
  int get flashcardCount => throw _privateConstructorUsedError;
  int get chatMessageCount => throw _privateConstructorUsedError;
  DateTime? get lastStudiedAt => throw _privateConstructorUsedError;
  DateTime? get nextRevisionDue => throw _privateConstructorUsedError;
  int get sortOrder => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this Topic to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Topic
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TopicCopyWith<Topic> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TopicCopyWith<$Res> {
  factory $TopicCopyWith(Topic value, $Res Function(Topic) then) =
      _$TopicCopyWithImpl<$Res, Topic>;
  @useResult
  $Res call(
      {String id,
      String unitId,
      String subjectId,
      String userId,
      String title,
      String? description,
      TopicStatus status,
      double masteryScore,
      int weaknessFlag,
      bool isAIProcessed,
      List<String> conceptTags,
      List<String> learningObjectives,
      int resourceCount,
      int totalStudyMinutes,
      int quizAttempts,
      double averageQuizScore,
      int flashcardCount,
      int chatMessageCount,
      DateTime? lastStudiedAt,
      DateTime? nextRevisionDue,
      int sortOrder,
      DateTime createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class _$TopicCopyWithImpl<$Res, $Val extends Topic>
    implements $TopicCopyWith<$Res> {
  _$TopicCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Topic
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? unitId = null,
    Object? subjectId = null,
    Object? userId = null,
    Object? title = null,
    Object? description = freezed,
    Object? status = null,
    Object? masteryScore = null,
    Object? weaknessFlag = null,
    Object? isAIProcessed = null,
    Object? conceptTags = null,
    Object? learningObjectives = null,
    Object? resourceCount = null,
    Object? totalStudyMinutes = null,
    Object? quizAttempts = null,
    Object? averageQuizScore = null,
    Object? flashcardCount = null,
    Object? chatMessageCount = null,
    Object? lastStudiedAt = freezed,
    Object? nextRevisionDue = freezed,
    Object? sortOrder = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      unitId: null == unitId
          ? _value.unitId
          : unitId // ignore: cast_nullable_to_non_nullable
              as String,
      subjectId: null == subjectId
          ? _value.subjectId
          : subjectId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as TopicStatus,
      masteryScore: null == masteryScore
          ? _value.masteryScore
          : masteryScore // ignore: cast_nullable_to_non_nullable
              as double,
      weaknessFlag: null == weaknessFlag
          ? _value.weaknessFlag
          : weaknessFlag // ignore: cast_nullable_to_non_nullable
              as int,
      isAIProcessed: null == isAIProcessed
          ? _value.isAIProcessed
          : isAIProcessed // ignore: cast_nullable_to_non_nullable
              as bool,
      conceptTags: null == conceptTags
          ? _value.conceptTags
          : conceptTags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      learningObjectives: null == learningObjectives
          ? _value.learningObjectives
          : learningObjectives // ignore: cast_nullable_to_non_nullable
              as List<String>,
      resourceCount: null == resourceCount
          ? _value.resourceCount
          : resourceCount // ignore: cast_nullable_to_non_nullable
              as int,
      totalStudyMinutes: null == totalStudyMinutes
          ? _value.totalStudyMinutes
          : totalStudyMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      quizAttempts: null == quizAttempts
          ? _value.quizAttempts
          : quizAttempts // ignore: cast_nullable_to_non_nullable
              as int,
      averageQuizScore: null == averageQuizScore
          ? _value.averageQuizScore
          : averageQuizScore // ignore: cast_nullable_to_non_nullable
              as double,
      flashcardCount: null == flashcardCount
          ? _value.flashcardCount
          : flashcardCount // ignore: cast_nullable_to_non_nullable
              as int,
      chatMessageCount: null == chatMessageCount
          ? _value.chatMessageCount
          : chatMessageCount // ignore: cast_nullable_to_non_nullable
              as int,
      lastStudiedAt: freezed == lastStudiedAt
          ? _value.lastStudiedAt
          : lastStudiedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      nextRevisionDue: freezed == nextRevisionDue
          ? _value.nextRevisionDue
          : nextRevisionDue // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      sortOrder: null == sortOrder
          ? _value.sortOrder
          : sortOrder // ignore: cast_nullable_to_non_nullable
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
abstract class _$$TopicImplCopyWith<$Res> implements $TopicCopyWith<$Res> {
  factory _$$TopicImplCopyWith(
          _$TopicImpl value, $Res Function(_$TopicImpl) then) =
      __$$TopicImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String unitId,
      String subjectId,
      String userId,
      String title,
      String? description,
      TopicStatus status,
      double masteryScore,
      int weaknessFlag,
      bool isAIProcessed,
      List<String> conceptTags,
      List<String> learningObjectives,
      int resourceCount,
      int totalStudyMinutes,
      int quizAttempts,
      double averageQuizScore,
      int flashcardCount,
      int chatMessageCount,
      DateTime? lastStudiedAt,
      DateTime? nextRevisionDue,
      int sortOrder,
      DateTime createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class __$$TopicImplCopyWithImpl<$Res>
    extends _$TopicCopyWithImpl<$Res, _$TopicImpl>
    implements _$$TopicImplCopyWith<$Res> {
  __$$TopicImplCopyWithImpl(
      _$TopicImpl _value, $Res Function(_$TopicImpl) _then)
      : super(_value, _then);

  /// Create a copy of Topic
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? unitId = null,
    Object? subjectId = null,
    Object? userId = null,
    Object? title = null,
    Object? description = freezed,
    Object? status = null,
    Object? masteryScore = null,
    Object? weaknessFlag = null,
    Object? isAIProcessed = null,
    Object? conceptTags = null,
    Object? learningObjectives = null,
    Object? resourceCount = null,
    Object? totalStudyMinutes = null,
    Object? quizAttempts = null,
    Object? averageQuizScore = null,
    Object? flashcardCount = null,
    Object? chatMessageCount = null,
    Object? lastStudiedAt = freezed,
    Object? nextRevisionDue = freezed,
    Object? sortOrder = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(_$TopicImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      unitId: null == unitId
          ? _value.unitId
          : unitId // ignore: cast_nullable_to_non_nullable
              as String,
      subjectId: null == subjectId
          ? _value.subjectId
          : subjectId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as TopicStatus,
      masteryScore: null == masteryScore
          ? _value.masteryScore
          : masteryScore // ignore: cast_nullable_to_non_nullable
              as double,
      weaknessFlag: null == weaknessFlag
          ? _value.weaknessFlag
          : weaknessFlag // ignore: cast_nullable_to_non_nullable
              as int,
      isAIProcessed: null == isAIProcessed
          ? _value.isAIProcessed
          : isAIProcessed // ignore: cast_nullable_to_non_nullable
              as bool,
      conceptTags: null == conceptTags
          ? _value._conceptTags
          : conceptTags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      learningObjectives: null == learningObjectives
          ? _value._learningObjectives
          : learningObjectives // ignore: cast_nullable_to_non_nullable
              as List<String>,
      resourceCount: null == resourceCount
          ? _value.resourceCount
          : resourceCount // ignore: cast_nullable_to_non_nullable
              as int,
      totalStudyMinutes: null == totalStudyMinutes
          ? _value.totalStudyMinutes
          : totalStudyMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      quizAttempts: null == quizAttempts
          ? _value.quizAttempts
          : quizAttempts // ignore: cast_nullable_to_non_nullable
              as int,
      averageQuizScore: null == averageQuizScore
          ? _value.averageQuizScore
          : averageQuizScore // ignore: cast_nullable_to_non_nullable
              as double,
      flashcardCount: null == flashcardCount
          ? _value.flashcardCount
          : flashcardCount // ignore: cast_nullable_to_non_nullable
              as int,
      chatMessageCount: null == chatMessageCount
          ? _value.chatMessageCount
          : chatMessageCount // ignore: cast_nullable_to_non_nullable
              as int,
      lastStudiedAt: freezed == lastStudiedAt
          ? _value.lastStudiedAt
          : lastStudiedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      nextRevisionDue: freezed == nextRevisionDue
          ? _value.nextRevisionDue
          : nextRevisionDue // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      sortOrder: null == sortOrder
          ? _value.sortOrder
          : sortOrder // ignore: cast_nullable_to_non_nullable
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
class _$TopicImpl implements _Topic {
  const _$TopicImpl(
      {required this.id,
      required this.unitId,
      required this.subjectId,
      required this.userId,
      required this.title,
      this.description,
      this.status = TopicStatus.notStarted,
      this.masteryScore = 0.0,
      this.weaknessFlag = 0,
      this.isAIProcessed = false,
      final List<String> conceptTags = const [],
      final List<String> learningObjectives = const [],
      this.resourceCount = 0,
      this.totalStudyMinutes = 0,
      this.quizAttempts = 0,
      this.averageQuizScore = 0.0,
      this.flashcardCount = 0,
      this.chatMessageCount = 0,
      this.lastStudiedAt,
      this.nextRevisionDue,
      required this.sortOrder,
      required this.createdAt,
      this.updatedAt})
      : _conceptTags = conceptTags,
        _learningObjectives = learningObjectives;

  factory _$TopicImpl.fromJson(Map<String, dynamic> json) =>
      _$$TopicImplFromJson(json);

  @override
  final String id;
  @override
  final String unitId;
  @override
  final String subjectId;
  @override
  final String userId;
  @override
  final String title;
  @override
  final String? description;
  @override
  @JsonKey()
  final TopicStatus status;
  @override
  @JsonKey()
  final double masteryScore;
// 0.0–1.0
  @override
  @JsonKey()
  final int weaknessFlag;
// 0–10 severity
  @override
  @JsonKey()
  final bool isAIProcessed;
// embeddings generated
  final List<String> _conceptTags;
// embeddings generated
  @override
  @JsonKey()
  List<String> get conceptTags {
    if (_conceptTags is EqualUnmodifiableListView) return _conceptTags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_conceptTags);
  }

  final List<String> _learningObjectives;
  @override
  @JsonKey()
  List<String> get learningObjectives {
    if (_learningObjectives is EqualUnmodifiableListView)
      return _learningObjectives;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_learningObjectives);
  }

  @override
  @JsonKey()
  final int resourceCount;
  @override
  @JsonKey()
  final int totalStudyMinutes;
  @override
  @JsonKey()
  final int quizAttempts;
  @override
  @JsonKey()
  final double averageQuizScore;
  @override
  @JsonKey()
  final int flashcardCount;
  @override
  @JsonKey()
  final int chatMessageCount;
  @override
  final DateTime? lastStudiedAt;
  @override
  final DateTime? nextRevisionDue;
  @override
  final int sortOrder;
  @override
  final DateTime createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'Topic(id: $id, unitId: $unitId, subjectId: $subjectId, userId: $userId, title: $title, description: $description, status: $status, masteryScore: $masteryScore, weaknessFlag: $weaknessFlag, isAIProcessed: $isAIProcessed, conceptTags: $conceptTags, learningObjectives: $learningObjectives, resourceCount: $resourceCount, totalStudyMinutes: $totalStudyMinutes, quizAttempts: $quizAttempts, averageQuizScore: $averageQuizScore, flashcardCount: $flashcardCount, chatMessageCount: $chatMessageCount, lastStudiedAt: $lastStudiedAt, nextRevisionDue: $nextRevisionDue, sortOrder: $sortOrder, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TopicImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.unitId, unitId) || other.unitId == unitId) &&
            (identical(other.subjectId, subjectId) ||
                other.subjectId == subjectId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.masteryScore, masteryScore) ||
                other.masteryScore == masteryScore) &&
            (identical(other.weaknessFlag, weaknessFlag) ||
                other.weaknessFlag == weaknessFlag) &&
            (identical(other.isAIProcessed, isAIProcessed) ||
                other.isAIProcessed == isAIProcessed) &&
            const DeepCollectionEquality()
                .equals(other._conceptTags, _conceptTags) &&
            const DeepCollectionEquality()
                .equals(other._learningObjectives, _learningObjectives) &&
            (identical(other.resourceCount, resourceCount) ||
                other.resourceCount == resourceCount) &&
            (identical(other.totalStudyMinutes, totalStudyMinutes) ||
                other.totalStudyMinutes == totalStudyMinutes) &&
            (identical(other.quizAttempts, quizAttempts) ||
                other.quizAttempts == quizAttempts) &&
            (identical(other.averageQuizScore, averageQuizScore) ||
                other.averageQuizScore == averageQuizScore) &&
            (identical(other.flashcardCount, flashcardCount) ||
                other.flashcardCount == flashcardCount) &&
            (identical(other.chatMessageCount, chatMessageCount) ||
                other.chatMessageCount == chatMessageCount) &&
            (identical(other.lastStudiedAt, lastStudiedAt) ||
                other.lastStudiedAt == lastStudiedAt) &&
            (identical(other.nextRevisionDue, nextRevisionDue) ||
                other.nextRevisionDue == nextRevisionDue) &&
            (identical(other.sortOrder, sortOrder) ||
                other.sortOrder == sortOrder) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        unitId,
        subjectId,
        userId,
        title,
        description,
        status,
        masteryScore,
        weaknessFlag,
        isAIProcessed,
        const DeepCollectionEquality().hash(_conceptTags),
        const DeepCollectionEquality().hash(_learningObjectives),
        resourceCount,
        totalStudyMinutes,
        quizAttempts,
        averageQuizScore,
        flashcardCount,
        chatMessageCount,
        lastStudiedAt,
        nextRevisionDue,
        sortOrder,
        createdAt,
        updatedAt
      ]);

  /// Create a copy of Topic
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TopicImplCopyWith<_$TopicImpl> get copyWith =>
      __$$TopicImplCopyWithImpl<_$TopicImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TopicImplToJson(
      this,
    );
  }
}

abstract class _Topic implements Topic {
  const factory _Topic(
      {required final String id,
      required final String unitId,
      required final String subjectId,
      required final String userId,
      required final String title,
      final String? description,
      final TopicStatus status,
      final double masteryScore,
      final int weaknessFlag,
      final bool isAIProcessed,
      final List<String> conceptTags,
      final List<String> learningObjectives,
      final int resourceCount,
      final int totalStudyMinutes,
      final int quizAttempts,
      final double averageQuizScore,
      final int flashcardCount,
      final int chatMessageCount,
      final DateTime? lastStudiedAt,
      final DateTime? nextRevisionDue,
      required final int sortOrder,
      required final DateTime createdAt,
      final DateTime? updatedAt}) = _$TopicImpl;

  factory _Topic.fromJson(Map<String, dynamic> json) = _$TopicImpl.fromJson;

  @override
  String get id;
  @override
  String get unitId;
  @override
  String get subjectId;
  @override
  String get userId;
  @override
  String get title;
  @override
  String? get description;
  @override
  TopicStatus get status;
  @override
  double get masteryScore; // 0.0–1.0
  @override
  int get weaknessFlag; // 0–10 severity
  @override
  bool get isAIProcessed; // embeddings generated
  @override
  List<String> get conceptTags;
  @override
  List<String> get learningObjectives;
  @override
  int get resourceCount;
  @override
  int get totalStudyMinutes;
  @override
  int get quizAttempts;
  @override
  double get averageQuizScore;
  @override
  int get flashcardCount;
  @override
  int get chatMessageCount;
  @override
  DateTime? get lastStudiedAt;
  @override
  DateTime? get nextRevisionDue;
  @override
  int get sortOrder;
  @override
  DateTime get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of Topic
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TopicImplCopyWith<_$TopicImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
