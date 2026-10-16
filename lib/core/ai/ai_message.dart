import 'package:freezed_annotation/freezed_annotation.dart';

part 'ai_message.freezed.dart';
part 'ai_message.g.dart';

enum AIRole { system, user, assistant }

@freezed
class AIMessage with _$AIMessage {
  const factory AIMessage({
    required AIRole role,
    required String content,
    @Default([]) List<String> imageUrls,
  }) = _AIMessage;

  factory AIMessage.fromJson(Map<String, dynamic> json) =>
      _$AIMessageFromJson(json);
}

@freezed
class AIRequest with _$AIRequest {
  const factory AIRequest({
    required List<AIMessage> messages,
    String? model,
    @Default(0.7) double temperature,
    @Default(2048) int maxTokens,
    @Default(false) bool stream,
    Map<String, dynamic>? extra,
  }) = _AIRequest;
}

@freezed
class AIResponse with _$AIResponse {
  const factory AIResponse({
    required String content,
    required String model,
    required int promptTokens,
    required int completionTokens,
    Map<String, dynamic>? extra,
  }) = _AIResponse;
}
