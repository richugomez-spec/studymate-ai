import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../storage/secure_storage.dart';
import 'api_key_manager.dart';

class AIApiKeyNotifier extends StateNotifier<String?> {
  final Ref _ref;
  AIApiKeyNotifier(this._ref) : super(_initialKey()) {
    _loadFromStorage();
  }

  static String? _initialKey() {
    const key = String.fromEnvironment('GEMINI_API_KEY');
    return key.isEmpty ? null : key;
  }

  Future<void> _loadFromStorage() async {
    try {
      final key = await _ref
          .read(secureStorageProvider)
          .read(key: SecureStorageKeys.aiApiKey);
      if (key?.trim().isNotEmpty == true) state = key!.trim();
    } catch (_) {}
  }

  Future<void> setApiKey(String key) async {
    final clean = key.trim();
    state = clean.isEmpty ? null : clean;
    try {
      final storage = _ref.read(secureStorageProvider);
      if (clean.isEmpty) {
        await storage.delete(key: SecureStorageKeys.aiApiKey);
      } else {
        await storage.write(key: SecureStorageKeys.aiApiKey, value: clean);
      }
    } catch (_) {}
  }
}

final aiApiKeyProvider = StateNotifierProvider<AIApiKeyNotifier, String?>(
  AIApiKeyNotifier.new,
);

final apiKeyManagerProvider = Provider<ApiKeyManager>((ref) {
  return ApiKeyManager(() => [
        const String.fromEnvironment('GEMINI_API_KEY_1'),
        const String.fromEnvironment('GEMINI_API_KEY_2'),
        const String.fromEnvironment('GEMINI_API_KEY_3'),
        const String.fromEnvironment('GEMINI_API_KEY_4'),
        const String.fromEnvironment('GEMINI_API_KEY'),
        ref.read(aiApiKeyProvider) ?? '',
      ]);
});
