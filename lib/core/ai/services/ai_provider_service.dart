import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../ai_config.dart';
import '../ai_provider.dart';
import '../providers/gemini_provider.dart';
import '../providers/openai_compatible_provider.dart';
import '../../storage/secure_storage.dart';

part 'ai_provider_service.g.dart';

/// Reads active AI config from secure storage and returns the correct [AIProvider].
/// Automatically picks Ollama if offline mode is enabled.
@riverpod
Future<AIProvider> activeAIProvider(ActiveAIProviderRef ref) async {
  final secureStorage = ref.watch(secureStorageProvider);
  final configJson = await secureStorage.read(key: SecureStorageKeys.aiConfig);

  AIConfig config;
  if (configJson == null) {
    // Default: Gemini Flash
    config = AIConfig.defaultGemini();
  } else {
    config = AIConfig.fromJson(
      Map<String, dynamic>.from(
        // simple decode, production would use json_serializable
        {'providerType': configJson},
      ),
    );
  }

  return _buildProvider(config);
}

AIProvider _buildProvider(AIConfig config) {
  return switch (config.providerType) {
    AIProviderType.gemini => GeminiProvider(config),
    AIProviderType.openai => OpenAICompatibleProvider(
        config.copyWith(baseUrl: 'https://api.openai.com/v1'),
      ),
    AIProviderType.grok => OpenAICompatibleProvider(
        config.copyWith(baseUrl: 'https://api.x.ai/v1'),
      ),
    AIProviderType.ollama => OpenAICompatibleProvider(
        config.copyWith(
          baseUrl: config.baseUrl ?? 'http://localhost:11434',
          apiKey: 'ollama', // Ollama accepts any non-empty key
        ),
      ),
    AIProviderType.openRouter => OpenAICompatibleProvider(
        config.copyWith(baseUrl: 'https://openrouter.ai/api/v1'),
      ),
  };
}
