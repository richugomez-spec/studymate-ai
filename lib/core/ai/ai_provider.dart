import 'ai_message.dart';

/// Abstract interface for all AI providers.
/// Implementing a new provider only requires implementing this interface
/// and registering it in [AIConfig].
abstract class AIProvider {
  /// Display name of this provider
  String get name;

  /// Whether this provider supports streaming responses
  bool get supportsStreaming;

  /// Whether this provider supports vision (image inputs)
  bool get supportsVision;

  /// Whether this provider can run offline (e.g. Ollama)
  bool get isOfflineCapable;

  /// Send a complete request and return a full response
  Future<AIResponse> complete(AIRequest request);

  /// Stream response tokens as they arrive
  Stream<String> stream(AIRequest request);

  /// Validate that the provider is reachable and configured correctly
  Future<bool> validate();
}
