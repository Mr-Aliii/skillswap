import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skill_swap/core/extensions/context_extensions.dart';
import 'package:skill_swap/models/notification_model.dart';
import 'package:skill_swap/providers/auth_provider.dart';
import 'package:skill_swap/providers/connection_provider.dart';
import 'package:skill_swap/providers/service_providers.dart';
import 'package:skill_swap/screens/chat/conversations_screen.dart';
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
      case 'connection_request':
        return Icons.person_add;
      case 'request':
        return Icons.swap_horiz;
      case 'chat_message':
        return Icons.chat;
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
      case 'connection_request':
        return AppColors.primary;
      case 'request':
        return AppColors.success;
      case 'chat_message':
        return AppColors.secondary;
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
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        backgroundColor:
                            _colorForType(n.type).withValues(alpha: 0.15),
                        child: Icon(
                          _iconForType(n.type),
                          color: _colorForType(n.type),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              n.title,
                              style: TextStyle(
                                fontWeight: n.isRead
                                    ? FontWeight.normal
                                    : FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(n.body),
                            if (n.createdAt != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                timeago.format(n.createdAt!),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                            if (n.type == 'connection_request')
                              _ConnectionRequestActions(notification: n),
                          ],
                        ),
                      ),
                    ],
                  ),
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

class _ConnectionRequestActions extends ConsumerWidget {
  const _ConnectionRequestActions({required this.notification});

  final NotificationModel notification;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final senderId = notification.data?['senderId'];
    final requestId = notification.data?['connectionRequestId'];
    final senderName = notification.data?['senderName'] ?? 'User';

    if (senderId == null || requestId == null) return const SizedBox.shrink();

    final connectionAsync = ref.watch(connectionRequestProvider(senderId));
    final currentUserId = ref.watch(authStateProvider).valueOrNull?.uid ?? DummyData.demoUserId;
    final currentUserProfile = ref.watch(currentUserProfileProvider).valueOrNull ?? DummyData.demoUser;

    return connectionAsync.when(
      data: (req) {
        if (req == null || req.status != 'pending') {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.only(top: 12.0),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () async {
                    try {
                      await ref.read(connectionServiceProvider).declineConnectionRequest(
                            requestId: requestId,
                            currentUserId: currentUserId,
                          );
                      ref.invalidate(connectionRequestProvider(senderId));
                      ref.invalidate(notificationsProvider);
                      context.showSnack('Request declined.');
                    } catch (e) {
                      context.showSnack('Failed to decline: $e');
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  child: const Text('Decline'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      await ref.read(connectionServiceProvider).acceptConnectionRequest(
                            requestId: requestId,
                            currentUserId: currentUserId,
                            currentUserName: currentUserProfile.name,
                          );
                      ref.invalidate(connectionRequestProvider(senderId));
                      ref.invalidate(chatsProvider);
                      ref.invalidate(notificationsProvider);
                      context.showSnack('Connected with $senderName!');
                    } catch (e) {
                      context.showSnack('Failed to accept: $e');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  child: const Text('Accept'),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.only(top: 12.0),
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
