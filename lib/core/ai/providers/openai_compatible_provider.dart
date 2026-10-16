import 'dart:convert';
import 'package:dio/dio.dart';

import '../ai_message.dart';
import '../ai_provider.dart';
import '../ai_config.dart';

/// OpenAI-compatible provider.
/// Works for: OpenAI, Grok, Ollama, OpenRouter, and any OpenAI-compatible API.
class OpenAICompatibleProvider implements AIProvider {
  final AIConfig config;
  late final Dio _dio;

  OpenAICompatibleProvider(this.config) {
    _dio = Dio(BaseOptions(
      baseUrl: config.baseUrl ?? 'https://api.openai.com/v1',
      headers: {
        'Authorization': 'Bearer ${config.apiKey}',
        'Content-Type': 'application/json',
        if (config.providerType == AIProviderType.openRouter) ...{
          'HTTP-Referer': 'https://studymateai.app',
          'X-Title': 'StudyMate AI',
        },
      },
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 120),
    ));
  }

  @override
  String get name => switch (config.providerType) {
    AIProviderType.openai => 'OpenAI',
    AIProviderType.grok => 'Grok (xAI)',
    AIProviderType.ollama => 'Ollama (Local)',
    AIProviderType.openRouter => 'OpenRouter',
    _ => 'OpenAI-Compatible',
  };

  @override
  bool get supportsStreaming => true;

  @override
  bool get supportsVision =>
      config.providerType == AIProviderType.openai ||
      config.model?.contains('vision') == true;

  @override
  bool get isOfflineCapable => config.providerType == AIProviderType.ollama;

  @override
  Future<AIResponse> complete(AIRequest request) async {
    final response = await _dio.post(
      '/chat/completions',
      data: _buildBody(request, stream: false),
    );
    final data = response.data as Map<String, dynamic>;
    final choice = data['choices'][0] as Map<String, dynamic>;
    final usage = data['usage'] as Map<String, dynamic>;

    return AIResponse(
      content: choice['message']['content'] as String,
      model: data['model'] as String,
      promptTokens: usage['prompt_tokens'] as int,
      completionTokens: usage['completion_tokens'] as int,
    );
  }

  @override
  Stream<String> stream(AIRequest request) async* {
    final response = await _dio.post<ResponseBody>(
      '/chat/completions',
      data: _buildBody(request, stream: true),
      options: Options(responseType: ResponseType.stream),
    );

    await for (final chunk in response.data!.stream) {
      final lines = utf8.decode(chunk).split('\n');
      for (final line in lines) {
        if (!line.startsWith('data: ')) continue;
        final data = line.substring(6);
        if (data == '[DONE]') return;
        try {
          final json = jsonDecode(data) as Map<String, dynamic>;
          final delta = json['choices']?[0]?['delta']?['content'] as String?;
          if (delta != null) yield delta;
        } catch (_) {}
      }
    }
  }

  @override
  Future<List<List<double>>> embed(List<String> texts) async {
    final response = await _dio.post(
      '/embeddings',
      data: {
        'input': texts,
        'model': 'text-embedding-3-small',
      },
    );
    final data = response.data as Map<String, dynamic>;
    return (data['data'] as List)
        .map((e) => (e['embedding'] as List).cast<double>())
        .toList();
  }

  @override
  Future<bool> validate() async {
    try {
      await complete(AIRequest(
        messages: [AIMessage(role: AIRole.user, content: 'hi')],
        maxTokens: 5,
      ));
      return true;
    } catch (_) {
      return false;
    }
  }

  Map<String, dynamic> _buildBody(AIRequest request, {required bool stream}) {
    return {
      'model': config.model,
      'messages': request.messages.map((m) => {
        'role': m.role.name,
        'content': m.content,
      }).toList(),
      'temperature': request.temperature,
      'max_tokens': request.maxTokens,
      'stream': stream,
    };
  }
}
