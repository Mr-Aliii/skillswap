import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:skill_swap/config/app_config.dart';
import 'package:skill_swap/config/firebase_config.dart';
import 'package:skill_swap/firebase/firebase_options.dart';

/// Initializes Firebase when not in demo mode.
class FirebaseInitializer {
  FirebaseInitializer._();

  static Future<void> initialize() async {
    if (AppConfig.isDemoMode) return;

    if (!FirebaseConfig.hasRealCredentials) {
      debugPrint(
        '⚠️ Firebase: placeholder keys in firebase_options.dart. '
        'Run: flutterfire configure',
      );
    }

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
}
