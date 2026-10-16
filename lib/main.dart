import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';

import 'app.dart';
import 'core/storage/hive_storage.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (e) {
    debugPrint('Firebase initialization: $e');
  }

  // Hive (key-value cache)
  await HiveStorage.init();

  // Drift (SQLite ORM) — initialized lazily via provider

  runApp(
    const ProviderScope(
      child: StudyMateApp(),
    ),
  );
}
