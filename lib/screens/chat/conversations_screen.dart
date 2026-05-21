import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skill_swap/models/chat_model.dart';
import 'package:skill_swap/providers/auth_provider.dart';
import 'package:skill_swap/providers/service_providers.dart';
import 'package:skill_swap/routes/app_routes.dart';
import 'package:skill_swap/theme/app_colors.dart';
import 'package:skill_swap/utils/dummy_data.dart';
import 'package:skill_swap/widgets/common/empty_state.dart';
import 'package:timeago/timeago.dart' as timeago;

final chatsProvider = FutureProvider<List<ChatModel>>((ref) async {
  final uid = ref.watch(authStateProvider).valueOrNull?.uid ??
      DummyData.demoUserId;
  return ref.watch(chatServiceProvider).getChats(uid);
});

/// Conversation list with online status and unread badges.
class ConversationsScreen extends ConsumerWidget {
  const ConversationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatsAsync = ref.watch(chatsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: chatsAsync.when(
        data: (chats) {
          if (chats.isEmpty) {
            return const EmptyState(
              title: 'No conversations yet',
              subtitle: 'Connect with someone to start chatting.',
              icon: Icons.chat_bubble_outline,
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: chats.length,
            separatorBuilder: (_, __) => const Divider(height: 1, indent: 72),
            itemBuilder: (context, i) {
              final chat = chats[i];
              return ListTile(
                leading: Stack(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor:
                          AppColors.primary.withValues(alpha: 0.15),
                      child: Text(
                        chat.otherUserName.isNotEmpty
                            ? chat.otherUserName[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    if (chat.isOtherOnline)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                title: Text(
                  chat.otherUserName,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  chat.lastMessage,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (chat.lastMessageAt != null)
                      Text(
                        timeago.format(chat.lastMessageAt!),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    if (chat.unreadCount > 0) ...[
                      const SizedBox(height: 4),
                      CircleAvatar(
                        radius: 10,
                        backgroundColor: AppColors.primary,
                        child: Text(
                          '${chat.unreadCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                onTap: () => Navigator.pushNamed(
                  context,
                  AppRoutes.chat,
                  arguments: {
                    'chatId': chat.id,
                    'otherUserName': chat.otherUserName,
                    'otherUserId': chat.otherUserId,
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const EmptyState(
          title: 'Could not load chats',
          icon: Icons.error_outline,
        ),
      ),
    );
  }
}
