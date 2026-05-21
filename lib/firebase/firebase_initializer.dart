import 'package:firebase_core/firebase_core.dart';
import 'package:skill_swap/config/app_config.dart';
import 'package:skill_swap/firebase/firebase_options.dart';

/// Initializes Firebase when not in demo mode.
class FirebaseInitializer {
  FirebaseInitializer._();

  static Future<void> initialize() async {
    if (AppConfig.useDemoMode) return;
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
}
