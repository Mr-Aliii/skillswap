import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:skill_swap/config/app_config.dart';

/// FCM structure – token registration and handlers (MVP placeholder).
///
/// Web requires `web/firebase-messaging-sw.js` and valid Firebase web config.
/// Until that is set up, initialization is skipped on web to avoid crashes.
class MessagingService {
  MessagingService._();

  static Future<void> initialize() async {
    if (AppConfig.useDemoMode) return;

    // FCM on Flutter web needs a registered service worker; skip until configured.
    if (kIsWeb) {
      debugPrint(
        'MessagingService: skipped on web (add web/firebase-messaging-sw.js to enable FCM)',
      );
      return;
    }

    try {
      final messaging = FirebaseMessaging.instance;
      await messaging.requestPermission();
      final token = await messaging.getToken();
      debugPrint('FCM token: ${token != null ? "received" : "null"}');

      FirebaseMessaging.onMessage.listen(_onForegroundMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpened);
    } catch (e, st) {
      debugPrint('MessagingService: init failed (non-fatal) — $e\n$st');
    }
  }

  static void _onForegroundMessage(RemoteMessage message) {
    // TODO: Show in-app notification banner
  }

  static void _onMessageOpened(RemoteMessage message) {
    // TODO: Navigate based on message.data
  }
}
