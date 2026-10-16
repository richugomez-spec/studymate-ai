import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Keys for secure storage
abstract final class SecureStorageKeys {
  static const aiConfig = 'ai_config';
  static const aiApiKey = 'ai_api_key';
  static const userPrefs = 'user_prefs';
}

/// Riverpod provider for FlutterSecureStorage
final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );
});
