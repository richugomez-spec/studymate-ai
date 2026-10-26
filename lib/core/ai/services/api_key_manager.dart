import 'dart:async';

import 'package:flutter/foundation.dart';

/// Rotates configured Gemini keys, retries transient failures, and cools down
/// keys whose quota or credentials have been rejected.
class ApiKeyManager {
  ApiKeyManager(this._configuredKeys);

  final List<String> Function() _configuredKeys;
  final Map<String, DateTime> _cooldowns = {};
  int _nextKeyIndex = 0;

  static const modelFallbacks = <String>[
    'gemini-2.5-pro',
    'gemini-2.5-flash',
    'gemini-2.5-flash-lite',
    'gemini-3.5-flash-lite',
    'gemini-3.8-flash',
  ];

  static const _maxRetries = 3;
  static const _requestTimeout = Duration(seconds: 30);

  Future<T> run<T>(
    Future<T> Function(String apiKey, String model) request,
  ) async {
    final keys = _configuredKeys()
        .map((key) => key.trim())
        .where((key) => key.isNotEmpty)
        .toSet()
        .toList(growable: false);
    if (keys.isEmpty) {
      debugPrint(
        'Gemini request not sent: no API key from dart-define, Firestore, or secure storage.',
      );
      throw const AiGenerationUnavailable();
    }

    Object? lastFailure;
    for (final model in modelFallbacks) {
      var modelUnsupported = false;
      final start = _nextKeyIndex % keys.length;
      for (var offset = 0; offset < keys.length; offset++) {
        final keyIndex = (start + offset) % keys.length;
        final key = keys[keyIndex];
        if (_isCoolingDown(key)) continue;
        _nextKeyIndex = (keyIndex + 1) % keys.length;

        for (var retry = 0; retry <= _maxRetries; retry++) {
          try {
            return await request(key, model).timeout(_requestTimeout);
          } catch (error) {
            lastFailure = error;
            final failure = _classify(error);
            debugPrint(
              'Gemini request attempt failed (key ${keyIndex + 1}, '
              'model $model, retry $retry): ${_redact(error, keys)}',
            );

            if (failure == _FailureKind.quota ||
                failure == _FailureKind.invalidKey) {
              _cooldowns[key] = DateTime.now().add(
                failure == _FailureKind.quota
                    ? const Duration(minutes: 1)
                    : const Duration(minutes: 10),
              );
              break;
            }
            if (failure == _FailureKind.unsupportedModel) {
              modelUnsupported = true;
              break;
            }
            if (failure == _FailureKind.transient && retry < _maxRetries) {
              await Future<void>.delayed(
                Duration(milliseconds: 500 * (1 << retry)),
              );
            } else {
              break;
            }
          }
        }
        if (modelUnsupported) break;
      }

      // If all configured keys have quota or credential cooldowns, wait for a
      // later request instead of surfacing provider errors or sleeping minutes.
      if (!_hasAvailableKey(keys)) break;
    }

    if (lastFailure != null) {
      debugPrint(
          'Gemini request exhausted configured keys and model fallbacks.');
    }
    throw const AiGenerationUnavailable();
  }

  Stream<String> runStream(
    Stream<String> Function(String apiKey, String model) request,
  ) async* {
    final keys = _configuredKeys()
        .map((key) => key.trim())
        .where((key) => key.isNotEmpty)
        .toSet()
        .toList();
    if (keys.isEmpty) {
      debugPrint(
        'Gemini stream not opened: no API key from dart-define, Firestore, or secure storage.',
      );
      throw const AiGenerationUnavailable();
    }
    Object? lastFailure;
    for (final model in modelFallbacks) {
      var unsupported = false;
      for (var offset = 0; offset < keys.length; offset++) {
        final index = (_nextKeyIndex + offset) % keys.length;
        final key = keys[index];
        if (_isCoolingDown(key)) continue;
        _nextKeyIndex = (index + 1) % keys.length;
        for (var retry = 0; retry <= _maxRetries; retry++) {
          var emitted = false;
          try {
            await for (final chunk
                in request(key, model).timeout(_requestTimeout)) {
              emitted = true;
              yield chunk;
            }
            return;
          } catch (error) {
            lastFailure = error;
            if (emitted) rethrow;
            final failure = _classify(error);
            debugPrint(
              'Gemini stream attempt failed (key ${index + 1}, '
              'model $model, retry $retry): ${_redact(error, keys)}',
            );
            if (failure == _FailureKind.quota ||
                failure == _FailureKind.invalidKey) {
              _cooldowns[key] = DateTime.now().add(failure == _FailureKind.quota
                  ? const Duration(minutes: 1)
                  : const Duration(minutes: 10));
              break;
            }
            if (failure == _FailureKind.unsupportedModel) {
              unsupported = true;
              break;
            }
            if (failure == _FailureKind.transient && retry < _maxRetries) {
              await Future<void>.delayed(
                  Duration(milliseconds: 500 * (1 << retry)));
              continue;
            }
            break;
          }
        }
        if (unsupported) break;
      }
      if (!_hasAvailableKey(keys)) break;
    }
    if (lastFailure != null) debugPrint('Gemini streaming retries exhausted.');
    throw const AiGenerationUnavailable();
  }

  bool _isCoolingDown(String key) {
    final until = _cooldowns[key];
    if (until == null) return false;
    if (DateTime.now().isBefore(until)) return true;
    _cooldowns.remove(key);
    return false;
  }

  bool _hasAvailableKey(List<String> keys) =>
      keys.any((key) => !_isCoolingDown(key));

  _FailureKind _classify(Object error) {
    if (error is TimeoutException) return _FailureKind.transient;
    final message = error.toString().toLowerCase();
    if (message.contains('quota') ||
        message.contains('resource_exhausted') ||
        message.contains('rate limit') ||
        message.contains('too many requests') ||
        message.contains('429')) {
      return _FailureKind.quota;
    }
    if (message.contains('api_key_invalid') ||
        message.contains('invalid api key') ||
        message.contains('api key not valid') ||
        message.contains('401')) {
      return _FailureKind.invalidKey;
    }
    if (message.contains('model not found') ||
        message.contains('not found for api version') ||
        message.contains('unsupported model') ||
        message.contains('model is not supported') ||
        (message.contains('model') &&
            (message.contains('permission to access') ||
                message.contains('not available to this account'))) ||
        message.contains('404')) {
      return _FailureKind.unsupportedModel;
    }
    if (message.contains('timeout') ||
        message.contains('timed out') ||
        message.contains('socketexception') ||
        message.contains('clientexception') ||
        RegExp(r'\b(500|502|503|504)\b').hasMatch(message)) {
      return _FailureKind.transient;
    }
    return _FailureKind.other;
  }

  String _redact(Object error, List<String> keys) {
    var message = error.toString();
    for (final key in keys) {
      message = message.replaceAll(key, '[redacted]');
    }
    return message;
  }
}

enum _FailureKind { transient, quota, invalidKey, unsupportedModel, other }

/// The UI may handle this without exposing provider, key, model, or quota data.
class AiGenerationUnavailable implements Exception {
  const AiGenerationUnavailable();
}
