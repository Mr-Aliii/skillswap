import 'package:skill_swap/firebase/firebase_options.dart';

/// Detects whether real Firebase credentials are present (from FlutterFire CLI).
class FirebaseConfig {
  FirebaseConfig._();

  static bool get hasRealCredentials {
    final options = DefaultFirebaseOptions.currentPlatform;
    final apiKey = options.apiKey;
    final appId = options.appId;
    return apiKey.isNotEmpty &&
        appId.isNotEmpty &&
        !apiKey.startsWith('YOUR_') &&
        !appId.startsWith('YOUR_');
  }
}
