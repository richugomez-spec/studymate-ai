import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_key_manager.dart';
import 'knowledge_engine.dart';

class RealChatMessage {
  final String id;
  final String role;
  final String content;
  final DateTime timestamp;
  final bool isThinking;
  final String? citedSource;

  const RealChatMessage(
      {required this.id,
      required this.role,
      required this.content,
      required this.timestamp,
      this.isThinking = false,
      this.citedSource});

  RealChatMessage copyWith(
          {String? content, bool? isThinking, String? citedSource}) =>
      RealChatMessage(
        id: id,
        role: role,
        content: content ?? this.content,
        timestamp: timestamp,
        isThinking: isThinking ?? this.isThinking,
        citedSource: citedSource ?? this.citedSource,
      );
}

/// Chat delegates all reasoning and source selection to KnowledgeEngine.
class RealAIChatService {
  RealAIChatService(this._ref);
  final Ref _ref;
  static String cleanMarkdownArtifacts(String text) => text.trim();

  Future<String> askAI(
      {required String prompt,
      required List<RealChatMessage> conversationHistory,
      String? subjectId,
      List<String> sourceIds = const []}) async {
    final history = conversationHistory
        .take(12)
        .map((m) => '${m.role}: ${m.content}')
        .join('\n');
    final result = await _ref.read(knowledgeEngineProvider).answer(
        prompt: prompt,
        history: history,
        subjectId: subjectId,
        sourceIds: sourceIds);
    final answer = result['answer'] ?? result['response'] ?? result['text'];
    if (answer is String && answer.trim().isNotEmpty) return answer.trim();
    throw const AiGenerationUnavailable();
  }
}

final realAIChatServiceProvider =
    Provider<RealAIChatService>((ref) => RealAIChatService(ref));
