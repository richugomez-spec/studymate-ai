import 'package:freezed_annotation/freezed_annotation.dart';

part 'ai_config.freezed.dart';
part 'ai_config.g.dart';

enum AIProviderType { gemini, openai, grok, ollama, openRouter }

@freezed
class AIConfig with _$AIConfig {
  const factory AIConfig({
    required AIProviderType providerType,
    String? apiKey,
    String? model,
    String? baseUrl,          // for Ollama or custom OpenAI-compatible APIs
    @Default(0.7) double temperature,
    @Default(2048) int maxTokens,
    @Default(false) bool streamByDefault,
  }) = _AIConfig;

  factory AIConfig.fromJson(Map<String, dynamic> json) =>
      _$AIConfigFromJson(json);

  // Default configs per provider
  factory AIConfig.defaultGemini() => const AIConfig(
    providerType: AIProviderType.gemini,
    model: 'gemini-3.8-flash',
  );

  factory AIConfig.defaultOpenAI() => const AIConfig(
    providerType: AIProviderType.openai,
    model: 'gpt-4o-mini',
  );

  factory AIConfig.defaultGrok() => const AIConfig(
    providerType: AIProviderType.grok,
    model: 'grok-beta',
    baseUrl: 'https://api.x.ai/v1',
  );

  factory AIConfig.defaultOllama() => const AIConfig(
    providerType: AIProviderType.ollama,
    model: 'llama3.1',
    baseUrl: 'http://localhost:11434',
  );

  factory AIConfig.defaultOpenRouter() => const AIConfig(
    providerType: AIProviderType.openRouter,
    model: 'meta-llama/llama-3.1-8b-instruct:free',
    baseUrl: 'https://openrouter.ai/api/v1',
  );
}
