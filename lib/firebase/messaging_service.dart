import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:skill_swap/config/app_config.dart';

typedef NotificationTapCallback = void Function(
    String type, Map<String, dynamic> data);

class MessagingService {
  MessagingService._();

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static NotificationTapCallback? onNotificationTap;

  static Future<void> initialize() async {
    if (AppConfig.isDemoMode) return;

    if (kIsWeb) {
      debugPrint(
        'MessagingService: skipped on web (add web/firebase-messaging-sw.js to enable FCM)',
      );
      return;
    }

    try {
      final messaging = FirebaseMessaging.instance;
      await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      final token = await messaging.getToken();
      if (token != null) {
        await _storeToken(token);
      }

      messaging.onTokenRefresh.listen(_storeToken);

      FirebaseMessaging.onMessage.listen(_onForegroundMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpened);

      final initialMessage = await messaging.getInitialMessage();
      if (initialMessage != null) {
        _handleMessage(initialMessage);
      }
    } catch (e, st) {
      debugPrint('MessagingService: init failed (non-fatal) — $e\n$st');
    }
  }

  static Future<void> _storeToken(String token) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;
      await FirebaseFirestore.instance
          .collection(AppConfig.usersCollection)
          .doc(uid)
          .set({'fcmToken': token}, SetOptions(merge: true));
    } catch (e) {
      debugPrint('MessagingService: failed to store token — $e');
    }
  }

  static Future<void> deleteToken() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;
      await FirebaseFirestore.instance
          .collection(AppConfig.usersCollection)
          .doc(uid)
          .set({'fcmToken': ''}, SetOptions(merge: true));
    } catch (e) {
      debugPrint('MessagingService: failed to delete token — $e');
    }
  }

  static void _onForegroundMessage(RemoteMessage message) {
    _handleMessage(message);
  }

  static void _onMessageOpened(RemoteMessage message) {
    _handleMessage(message);
  }

  static void _handleMessage(RemoteMessage message) {
    final data = message.data;
    final type = data['type'] ?? 'general';
    onNotificationTap?.call(type, data);
  }
}
