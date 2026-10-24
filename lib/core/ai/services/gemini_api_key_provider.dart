import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../storage/secure_storage.dart';
import 'api_key_manager.dart';

/// Manages application-wide Gemini API keys.
///
/// Keys entered in Developer Options are saved permanently to Firestore
/// (`system_config/gemini_api`) and cached locally. Every logged-in user
/// automatically consumes these global keys through [apiKeyManagerProvider]
/// with round-robin rotation and automatic failover.
class AIApiKeyNotifier extends StateNotifier<String?> {
  final Ref _ref;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _firestoreSub;
  StreamSubscription<User?>? _authSub;
  List<String> _keys = [];

  AIApiKeyNotifier(this._ref) : super(_initialKey()) {
    _initKeys();
  }

  List<String> get configuredKeys => List.unmodifiable(_keys);

  static String? _initialKey() {
    const key = String.fromEnvironment('GEMINI_API_KEY');
    return key.isEmpty ? null : key;
  }

  void _initKeys() {
    // 1. Initialise with build-time environment keys if present
    final envKeys = [
      const String.fromEnvironment('GEMINI_API_KEY_1'),
      const String.fromEnvironment('GEMINI_API_KEY_2'),
      const String.fromEnvironment('GEMINI_API_KEY_3'),
      const String.fromEnvironment('GEMINI_API_KEY_4'),
      const String.fromEnvironment('GEMINI_API_KEY'),
    ].map((k) => k.trim()).where((k) => k.isNotEmpty).toList();

    if (envKeys.isNotEmpty) {
      _keys = envKeys;
      state = envKeys.first;
    }

    // 2. Load cached keys from secure storage for immediate offline/startup use
    _loadFromStorage();

    // 3. Connect to Firestore system_config for real-time global permanent keys
    _bindFirestore();

    // 4. Ensure sync whenever authentication state changes
    _authSub = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        _fetchFromFirestore();
      }
    });
  }

  Future<void> _loadFromStorage() async {
    try {
      final storage = _ref.read(secureStorageProvider);
      final rawList = await storage.read(key: 'ai_api_keys');
      final singleKey = await storage.read(key: SecureStorageKeys.aiApiKey);

      final loaded = <String>[];
      if (rawList != null && rawList.trim().isNotEmpty) {
        for (final k in rawList.split('\n')) {
          final clean = k.trim();
          if (clean.isNotEmpty && !loaded.contains(clean)) loaded.add(clean);
        }
      }
      if (loaded.isEmpty && singleKey != null && singleKey.trim().isNotEmpty) {
        loaded.add(singleKey.trim());
      }

      if (loaded.isNotEmpty) {
        _keys = loaded;
        state = loaded.first;
      }
    } catch (_) {}
  }

  Future<void> _cacheKeysLocally(List<String> keys) async {
    try {
      final storage = _ref.read(secureStorageProvider);
      if (keys.isEmpty) {
        await storage.delete(key: SecureStorageKeys.aiApiKey);
        await storage.delete(key: 'ai_api_keys');
      } else {
        await storage.write(key: SecureStorageKeys.aiApiKey, value: keys.first);
        await storage.write(key: 'ai_api_keys', value: keys.join('\n'));
      }
    } catch (_) {}
  }

  void _bindFirestore() {
    try {
      _firestoreSub?.cancel();
      _firestoreSub = FirebaseFirestore.instance
          .collection('system_config')
          .doc('gemini_api')
          .snapshots()
          .listen((snapshot) {
        if (!snapshot.exists || snapshot.data() == null) return;
        _applyFirestoreData(snapshot.data()!);
      }, onError: (e) {
        debugPrint('Firestore system_config snapshot error: $e');
      });
    } catch (e) {
      debugPrint('Unable to bind Firestore system_config: $e');
    }
  }

  Future<void> _fetchFromFirestore() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('system_config')
          .doc('gemini_api')
          .get(const GetOptions(source: Source.serverAndCache));
      if (doc.exists && doc.data() != null) {
        _applyFirestoreData(doc.data()!);
      }
    } catch (_) {}
  }

  void _applyFirestoreData(Map<String, dynamic> data) {
    final rawList = data['apiKeys'] as List<dynamic>?;
    final singleKey = data['apiKey']?.toString();

    final incoming = <String>[];
    if (rawList != null) {
      for (final item in rawList) {
        final clean = item.toString().trim();
        if (clean.isNotEmpty && !incoming.contains(clean)) incoming.add(clean);
      }
    }
    if (incoming.isEmpty && singleKey != null && singleKey.trim().isNotEmpty) {
      incoming.add(singleKey.trim());
    }

    if (incoming.isNotEmpty) {
      _keys = incoming;
      state = incoming.first;
      _cacheKeysLocally(incoming);
    }
  }

  Future<void> setApiKeysFromText(String text) async {
    final rawItems = text.split(RegExp(r'[\r\n,;]+'));
    final cleanList = <String>[];
    for (final item in rawItems) {
      final clean = item.trim();
      if (clean.isNotEmpty && !cleanList.contains(clean)) {
        cleanList.add(clean);
      }
    }
    await setApiKeys(cleanList);
  }

  Future<void> setApiKey(String key) async {
    await setApiKeysFromText(key);
  }

  Future<void> setApiKeys(List<String> keys) async {
    final cleanList = keys
        .map((k) => k.trim())
        .where((k) => k.isNotEmpty)
        .toSet()
        .toList(growable: false);

    _keys = cleanList;
    state = cleanList.isEmpty ? null : cleanList.first;
    await _cacheKeysLocally(cleanList);

    try {
      final docRef = FirebaseFirestore.instance
          .collection('system_config')
          .doc('gemini_api');
      if (cleanList.isEmpty) {
        await docRef.delete();
      } else {
        await docRef.set({
          'apiKeys': cleanList,
          'apiKey': cleanList.first,
          'keyCount': cleanList.length,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    } catch (e) {
      debugPrint('Failed to save global API keys to Firestore: $e');
    }
  }

  @override
  void dispose() {
    _firestoreSub?.cancel();
    _authSub?.cancel();
    super.dispose();
  }
}

final aiApiKeyProvider = StateNotifierProvider<AIApiKeyNotifier, String?>(
  AIApiKeyNotifier.new,
);

final aiApiKeyListProvider = Provider<List<String>>((ref) {
  final notifier = ref.watch(aiApiKeyProvider.notifier);
  final single = ref.watch(aiApiKeyProvider);
  final keys = <String>{...notifier.configuredKeys};
  if (single != null && single.isNotEmpty) keys.add(single);
  return keys.toList(growable: false);
});

final apiKeyManagerProvider = Provider<ApiKeyManager>((ref) {
  return ApiKeyManager(() {
    final configured = ref.watch(aiApiKeyListProvider);
    return [
      ...configured,
      const String.fromEnvironment('GEMINI_API_KEY_1'),
      const String.fromEnvironment('GEMINI_API_KEY_2'),
      const String.fromEnvironment('GEMINI_API_KEY_3'),
      const String.fromEnvironment('GEMINI_API_KEY_4'),
      const String.fromEnvironment('GEMINI_API_KEY'),
    ];
  });
});
