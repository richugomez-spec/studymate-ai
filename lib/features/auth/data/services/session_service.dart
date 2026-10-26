import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../domain/entities/user.dart';

abstract final class AuthSessionKeys {
  static const token = 'auth_session_token';
  static const userId = 'auth_session_user_id';
  static const email = 'auth_session_email';
  static const userJson = 'auth_session_user_data';
  static const lastLogin = 'auth_session_last_login';
}

/// Service responsible for managing secure persistence and restoration of user session.
class SessionService {
  final FlutterSecureStorage _secureStorage;

  const SessionService(this._secureStorage);

  /// Persist authenticated user session securely
  Future<void> saveSession(AppUser user, {String? token}) async {
    await Future.wait([
      _secureStorage.write(key: AuthSessionKeys.userId, value: user.id),
      _secureStorage.write(key: AuthSessionKeys.email, value: user.email),
      _secureStorage.write(key: AuthSessionKeys.userJson, value: jsonEncode(user.toJson())),
      _secureStorage.write(
        key: AuthSessionKeys.lastLogin,
        value: DateTime.now().toIso8601String(),
      ),
      if (token != null)
        _secureStorage.write(key: AuthSessionKeys.token, value: token),
    ]);
  }

  /// Restore user details cached in secure storage
  Future<AppUser?> restoreSession() async {
    try {
      final userJson = await _secureStorage.read(key: AuthSessionKeys.userJson);
      if (userJson == null) return null;
      final map = jsonDecode(userJson) as Map<String, dynamic>;
      return AppUser.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  /// Get stored session auth token
  Future<String?> getAuthToken() async {
    return await _secureStorage.read(key: AuthSessionKeys.token);
  }

  /// Check whether an active session is persisted
  Future<bool> hasActiveSession() async {
    final userId = await _secureStorage.read(key: AuthSessionKeys.userId);
    return userId != null && userId.isNotEmpty;
  }

  /// Clear all stored session credentials (called on logout)
  Future<void> clearSession() async {
    await Future.wait([
      _secureStorage.delete(key: AuthSessionKeys.userId),
      _secureStorage.delete(key: AuthSessionKeys.email),
      _secureStorage.delete(key: AuthSessionKeys.userJson),
      _secureStorage.delete(key: AuthSessionKeys.token),
      _secureStorage.delete(key: AuthSessionKeys.lastLogin),
    ]);
  }
}
