import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skill_swap/models/notification_model.dart';
import 'package:skill_swap/providers/auth_provider.dart';
import 'package:skill_swap/providers/service_providers.dart';
import 'package:skill_swap/theme/app_colors.dart';
import 'package:skill_swap/utils/dummy_data.dart';
import 'package:skill_swap/widgets/common/empty_state.dart';
import 'package:timeago/timeago.dart' as timeago;

final notificationsProvider =
    FutureProvider<List<NotificationModel>>((ref) async {
  final uid = ref.watch(authStateProvider).valueOrNull?.uid ??
      DummyData.demoUserId;
  return ref.watch(notificationServiceProvider).getNotifications(uid);
});

/// Request, match, and session notifications.
class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  IconData _iconForType(String type) {
    switch (type) {
      case 'match':
        return Icons.people;
      case 'session':
        return Icons.calendar_today;
      case 'request':
        return Icons.swap_horiz;
      default:
        return Icons.notifications;
    }
  }

  Color _colorForType(String type) {
    switch (type) {
      case 'match':
        return AppColors.primary;
      case 'session':
        return AppColors.accent;
      case 'request':
        return AppColors.success;
      default:
        return AppColors.secondary;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: notificationsAsync.when(
        data: (items) {
          if (items.isEmpty) {
            return const EmptyState(
              title: 'No notifications',
              icon: Icons.notifications_none,
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final n = items[i];
              return Card(
                color: n.isRead
                    ? null
                    : AppColors.primary.withValues(alpha: 0.05),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        _colorForType(n.type).withValues(alpha: 0.15),
                    child: Icon(
                      _iconForType(n.type),
                      color: _colorForType(n.type),
                    ),
                  ),
                  title: Text(
                    n.title,
                    style: TextStyle(
                      fontWeight:
                          n.isRead ? FontWeight.normal : FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(n.body),
                      if (n.createdAt != null)
                        Text(
                          timeago.format(n.createdAt!),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                    ],
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const EmptyState(
          title: 'Failed to load',
          icon: Icons.error_outline,
        ),
      ),
    );
  }
}
