import 'dart:typed_data';

import 'package:google_generative_ai/google_generative_ai.dart' as genai;

import '../ai_message.dart';
import '../ai_provider.dart';
import '../ai_config.dart';

/// Google Gemini provider using the official Dart SDK
class GeminiProvider implements AIProvider {
  final AIConfig config;
  late final genai.GenerativeModel _model;

  GeminiProvider(this.config) {
    _model = genai.GenerativeModel(
      model: config.model ?? 'gemini-3.8-flash',
      apiKey: config.apiKey!,
      generationConfig: genai.GenerationConfig(
        temperature: config.temperature,
        maxOutputTokens: config.maxTokens,
      ),
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
            model: config.model ?? 'gemini-3.8-flash',
            apiKey: config.apiKey!,
            systemInstruction: genai.Content.system(systemPrompt),
            generationConfig: genai.GenerationConfig(
              temperature: config.temperature,
              maxOutputTokens: config.maxTokens,
            ),
          )
        : _model;

    final chat =
        model.startChat(history: history.take(history.length - 1).toList());
    final last = history.last;
    final response = await chat.sendMessage(last);

    return AIResponse(
      content: response.text ?? '',
      model: config.model ?? 'gemini-3.8-flash',
      promptTokens: response.usageMetadata?.promptTokenCount ?? 0,
      completionTokens: response.usageMetadata?.candidatesTokenCount ?? 0,
    );
  }

  Future<AIResponse> completeWithInlineData(
      AIRequest request, Uint8List bytes, String mimeType) async {
    final systemPrompt = _extractSystemPrompt(request.messages);
    final model = genai.GenerativeModel(
      model: config.model ?? 'gemini-3.8-flash',
      apiKey: config.apiKey!,
      systemInstruction:
          systemPrompt == null ? null : genai.Content.system(systemPrompt),
      generationConfig: genai.GenerationConfig(
          temperature: config.temperature, maxOutputTokens: config.maxTokens),
    );
    final userText =
        request.messages.where((m) => m.role == AIRole.user).last.content;
    final response = await model.generateContent([
      genai.Content.multi(
          [genai.TextPart(userText), genai.DataPart(mimeType, bytes)]),
    ]);
    return AIResponse(
      content: response.text ?? '',
      model: config.model ?? 'gemini-3.8-flash',
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
            model: config.model ?? 'gemini-3.8-flash',
            apiKey: config.apiKey!,
            systemInstruction: genai.Content.system(systemPrompt),
          )
        : _model;

    final chat =
        model.startChat(history: history.take(history.length - 1).toList());
    final last = history.last;

    await for (final chunk in chat.sendMessageStream(last)) {
      if (chunk.text != null) yield chunk.text!;
    }
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
