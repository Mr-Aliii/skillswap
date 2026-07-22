import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skill_swap/core/extensions/context_extensions.dart';
import 'package:skill_swap/models/user_model.dart';
import 'package:skill_swap/providers/auth_provider.dart';
import 'package:skill_swap/providers/connection_provider.dart';
import 'package:skill_swap/providers/service_providers.dart';
import 'package:skill_swap/routes/app_routes.dart';
import 'package:skill_swap/screens/chat/conversations_screen.dart';
import 'package:skill_swap/screens/notifications/notifications_screen.dart';
import 'package:skill_swap/theme/app_colors.dart';
import 'package:skill_swap/utils/dummy_data.dart';

/// Interactive buttons that change state based on the connection request status between the current user and [targetUser].
class ConnectionActionButtons extends ConsumerWidget {
  const ConnectionActionButtons({super.key, required this.targetUser});

  final UserModel targetUser;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectionAsync = ref.watch(connectionRequestProvider(targetUser.id));
    final currentUserId = ref.watch(authStateProvider).valueOrNull?.uid ?? DummyData.demoUserId;
    final currentUserProfile = ref.watch(currentUserProfileProvider).valueOrNull ?? DummyData.demoUser;

    return connectionAsync.when(
      data: (req) {
        if (req == null) {
          return OutlinedButton.icon(
            onPressed: () async {
              try {
                await ref.read(connectionServiceProvider).sendConnectionRequest(
                      senderId: currentUserId,
                      receiverId: targetUser.id,
                      senderName: currentUserProfile.name,
                    );
                ref.invalidate(connectionRequestProvider(targetUser.id));
                context.showSnack('Connection request sent to ${targetUser.name}!');
              } catch (e) {
                context.showSnack('Failed to send request: $e');
              }
            },
            icon: const Icon(Icons.person_add_outlined, size: 18),
            label: const Text('Connect'),
          );
        }

        if (req.status == 'pending') {
          if (req.senderId == currentUserId) {
            return OutlinedButton.icon(
              onPressed: () async {
                try {
                  await ref.read(connectionServiceProvider).cancelConnectionRequest(
                        senderId: currentUserId,
                        receiverId: targetUser.id,
                      );
                  ref.invalidate(connectionRequestProvider(targetUser.id));
                  context.showSnack('Connection request cancelled.');
                } catch (e) {
                  context.showSnack('Failed to cancel request: $e');
                }
              },
              icon: const Icon(Icons.close, size: 18),
              label: const Text('Cancel Request'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.orange,
                side: const BorderSide(color: Colors.orange),
              ),
            );
          } else {
            return Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      try {
                        await ref.read(connectionServiceProvider).declineConnectionRequest(
                              requestId: req.id,
                              currentUserId: currentUserId,
                            );
                        ref.invalidate(connectionRequestProvider(targetUser.id));
                        ref.invalidate(notificationsProvider);
                        context.showSnack('Request declined.');
                      } catch (e) {
                        context.showSnack('Failed to decline: $e');
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: EdgeInsets.zero,
                    ),
                    child: const Text('Decline', style: TextStyle(fontSize: 12)),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        await ref.read(connectionServiceProvider).acceptConnectionRequest(
                              requestId: req.id,
                              currentUserId: currentUserId,
                              currentUserName: currentUserProfile.name,
                            );
                        ref.invalidate(connectionRequestProvider(targetUser.id));
                        ref.invalidate(chatsProvider);
                        ref.invalidate(notificationsProvider);
                        context.showSnack('Connected with ${targetUser.name}!');
                      } catch (e) {
                        context.showSnack('Failed to accept: $e');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.zero,
                    ),
                    child: const Text('Accept', style: TextStyle(fontSize: 12)),
                  ),
                ),
              ],
            );
          }
        }

        if (req.status == 'accepted') {
          return OutlinedButton.icon(
            onPressed: () {
              final chatId = currentUserId.compareTo(targetUser.id) < 0
                  ? '${currentUserId}_${targetUser.id}'
                  : '${targetUser.id}_$currentUserId';
              Navigator.pushNamed(
                context,
                AppRoutes.chat,
                arguments: {
                  'chatId': chatId,
                  'otherUserName': targetUser.name,
                  'otherUserId': targetUser.id,
                },
              );
            },
            icon: const Icon(Icons.chat_bubble_outline, size: 18),
            label: const Text('Chat'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
            ),
          );
        }

        return OutlinedButton.icon(
          onPressed: () async {
            try {
              await ref.read(connectionServiceProvider).sendConnectionRequest(
                    senderId: currentUserId,
                    receiverId: targetUser.id,
                    senderName: currentUserProfile.name,
                  );
              ref.invalidate(connectionRequestProvider(targetUser.id));
              context.showSnack('Connection request sent to ${targetUser.name}!');
            } catch (e) {
              context.showSnack('Failed to send request: $e');
            }
          },
          icon: const Icon(Icons.person_add_outlined, size: 18),
          label: const Text('Connect'),
        );
      },
      loading: () => const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      error: (_, __) => OutlinedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.error_outline),
        label: const Text('Error'),
      ),
    );
  }
}
