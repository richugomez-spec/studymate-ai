import 'package:freezed_annotation/freezed_annotation.dart';

part 'topic.freezed.dart';
part 'topic.g.dart';

enum TopicStatus { notStarted, inProgress, completed, needsRevision }

@freezed
class Topic with _$Topic {
  const factory Topic({
    required String id,
    required String unitId,
    required String subjectId,
    required String userId,
    required String title,
    String? description,
    @Default(TopicStatus.notStarted) TopicStatus status,
    @Default(0.0) double masteryScore,        // 0.0–1.0
    @Default(0) int weaknessFlag,             // 0–10 severity
    @Default(false) bool isAIProcessed,       // embeddings generated
    @Default([]) List<String> conceptTags,
    @Default([]) List<String> learningObjectives,
    @Default(0) int resourceCount,
    @Default(0) int totalStudyMinutes,
    @Default(0) int quizAttempts,
    @Default(0.0) double averageQuizScore,
    @Default(0) int flashcardCount,
    @Default(0) int chatMessageCount,
    DateTime? lastStudiedAt,
    DateTime? nextRevisionDue,
    required int sortOrder,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _Topic;

  factory Topic.fromJson(Map<String, dynamic> json) =>
      _$TopicFromJson(json);
}
