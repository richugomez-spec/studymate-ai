import 'package:freezed_annotation/freezed_annotation.dart';

part 'timeline_event.freezed.dart';
part 'timeline_event.g.dart';

@freezed
class TimelineEvent with _$TimelineEvent {
  const factory TimelineEvent({
    required String id,
    required String userId,
    required String eventType, // initial_study, quiz_attempt, spaced_revision, gap_detected, mastery_leap
    required String title,
    required String description,
    required DateTime timestamp,
    String? conceptId,
    String? topicId,
    @Default(0.0) double deltaMastery,
    @Default(0.0) double currentMastery,
    @Default({}) Map<String, dynamic> payload,
  }) = _TimelineEvent;

  factory TimelineEvent.fromJson(Map<String, dynamic> json) =>
      _$TimelineEventFromJson(json);
}
