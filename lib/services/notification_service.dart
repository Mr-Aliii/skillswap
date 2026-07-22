import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skill_swap/config/app_config.dart';
import 'package:skill_swap/models/notification_model.dart';
import 'package:skill_swap/utils/dummy_data.dart';

/// In-app notifications from Firestore.
class NotificationService {
  FirebaseFirestore? get _firestore =>
      AppConfig.isDemoMode ? null : FirebaseFirestore.instance;

  Future<List<NotificationModel>> getNotifications(String userId) async {
    if (AppConfig.isDemoMode) {
      await Future<void>.delayed(const Duration(milliseconds: 400));
      return DummyData.demoNotifications;
    }
    final snapshot = await _firestore!
        .collection(AppConfig.notificationsCollection)
        .where('userId', isEqualTo: userId)
        .get();
    final items = snapshot.docs
        .map((d) => NotificationModel.fromMap(d.data(), d.id))
        .toList();
    items.sort((a, b) {
      final aTime = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bTime = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bTime.compareTo(aTime);
    });
    return items;
  }

  Future<void> markAsRead(String notificationId) async {
    if (AppConfig.isDemoMode) return;
    await _firestore!
        .collection(AppConfig.notificationsCollection)
        .doc(notificationId)
        .update({'isRead': true});
  }
}
