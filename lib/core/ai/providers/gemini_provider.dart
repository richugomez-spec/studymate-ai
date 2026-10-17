import 'package:google_generative_ai/google_generative_ai.dart' as genai;

import '../ai_message.dart';
import '../ai_provider.dart';
import '../ai_config.dart';

/// Google Gemini provider using the official Dart SDK
class GeminiProvider implements AIProvider {
  final AIConfig config;
  late final genai.GenerativeModel _model;
  late final genai.GenerativeModel _embeddingModel;

  GeminiProvider(this.config) {
    _model = genai.GenerativeModel(
      model: config.model ?? 'gemini-1.5-flash-latest',
      apiKey: config.apiKey!,
      generationConfig: genai.GenerationConfig(
        temperature: config.temperature,
        maxOutputTokens: config.maxTokens,
      ),
    );
    _embeddingModel = genai.GenerativeModel(
      model: 'text-embedding-004',
      apiKey: config.apiKey!,
    );
  }

  @override
  String get name => 'Google Gemini';

  @override
  bool get supportsStreaming => true;

  @override
  bool get supportsVision => true;

  @override
  bool get isOfflineCapable => false;

  List<genai.Content> _toGeminiHistory(List<AIMessage> messages) {
    return messages
        .where((m) => m.role != AIRole.system)
        .map((m) => genai.Content(
              m.role == AIRole.user ? 'user' : 'model',
              [genai.TextPart(m.content)],
            ))
        .toList();
  }

  String? _extractSystemPrompt(List<AIMessage> messages) {
    final system = messages.where((m) => m.role == AIRole.system).firstOrNull;
    return system?.content;
  }

  @override
  Future<AIResponse> complete(AIRequest request) async {
    final systemPrompt = _extractSystemPrompt(request.messages);
    final history = _toGeminiHistory(request.messages);

    final model = systemPrompt != null
        ? genai.GenerativeModel(
            model: config.model ?? 'gemini-1.5-flash-latest',
            apiKey: config.apiKey!,
            systemInstruction: genai.Content.system(systemPrompt),
            generationConfig: genai.GenerationConfig(
              temperature: config.temperature,
              maxOutputTokens: config.maxTokens,
            ),
          )
        : _model;

    final chat = model.startChat(history: history.take(history.length - 1).toList());
    final last = history.last;
    final response = await chat.sendMessage(last);

    return AIResponse(
      content: response.text ?? '',
      model: config.model ?? 'gemini-1.5-flash-latest',
      promptTokens: response.usageMetadata?.promptTokenCount ?? 0,
      completionTokens: response.usageMetadata?.candidatesTokenCount ?? 0,
    );
  }

  @override
  Stream<String> stream(AIRequest request) async* {
    final systemPrompt = _extractSystemPrompt(request.messages);
    final history = _toGeminiHistory(request.messages);

    final model = systemPrompt != null
        ? genai.GenerativeModel(
            model: config.model ?? 'gemini-1.5-flash-latest',
            apiKey: config.apiKey!,
            systemInstruction: genai.Content.system(systemPrompt),
          )
        : _model;

    final chat = model.startChat(history: history.take(history.length - 1).toList());
    final last = history.last;

    await for (final chunk in chat.sendMessageStream(last)) {
      if (chunk.text != null) yield chunk.text!;
    }
  }

  @override
  Future<List<List<double>>> embed(List<String> texts) async {
    final results = <List<double>>[];
    for (final text in texts) {
      final response = await _embeddingModel.embedContent(
        genai.Content.text(text),
      );
      results.add(response.embedding.values.toList());
    }
    return results;
  }

  @override
  Future<bool> validate() async {
    try {
      await _model.generateContent([genai.Content.text('hi')]);
      return true;
    } catch (_) {
      return false;
    }
  }
}
