import 'package:hive_flutter/hive_flutter.dart';

/// Wrapper around Hive for structured key-value storage.
/// Handles initialization, box management, and type-safe reads/writes.
abstract final class HiveStorage {
  static late Box _appBox;
  static late Box _cacheBox;

  static Future<void> init() async {
    await Hive.initFlutter();
    _appBox = await Hive.openBox('app_prefs');
    _cacheBox = await Hive.openBox('ai_cache');
  }

  // ── App Preferences ────────────────────────────────────────────────────────

  static T? get<T>(String key) => _appBox.get(key) as T?;

  static Future<void> put<T>(String key, T value) => _appBox.put(key, value);

  static Future<void> delete(String key) => _appBox.delete(key);

  // ── AI Response Cache ──────────────────────────────────────────────────────

  static String? getCachedResponse(String cacheKey) =>
      _cacheBox.get(cacheKey) as String?;

  static Future<void> cacheResponse(String cacheKey, String response) =>
      _cacheBox.put(cacheKey, response);

  static Future<void> clearCache() => _cacheBox.clear();

  // ── Helpers ────────────────────────────────────────────────────────────────

  static Future<void> clearAll() async {
    await _appBox.clear();
    await _cacheBox.clear();
  }
}
