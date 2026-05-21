import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skill_swap/core/constants/app_constants.dart';
import 'package:skill_swap/core/extensions/context_extensions.dart';
import 'package:skill_swap/models/user_model.dart';
import 'package:skill_swap/providers/home_provider.dart';
import 'package:skill_swap/routes/app_routes.dart';
import 'package:skill_swap/theme/app_colors.dart';
import 'package:skill_swap/widgets/common/empty_state.dart';
import 'package:skill_swap/widgets/common/gradient_button.dart';
import 'package:skill_swap/widgets/common/skill_chip.dart';

/// Browse users and request skill exchanges.
class MatchScreen extends ConsumerWidget {
  const MatchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(recommendedUsersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover'),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: () {},
          ),
        ],
      ),
      body: usersAsync.when(
        data: (users) {
          if (users.isEmpty) {
            return const EmptyState(
              title: 'No matches yet',
              subtitle: 'Complete your profile to get better matches.',
              icon: Icons.people_outline,
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(recommendedUsersProvider),
            child: ListView.builder(
              padding: const EdgeInsets.all(AppConstants.paddingM),
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return _MatchCard(user: user);
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const EmptyState(
          title: 'Something went wrong',
          icon: Icons.error_outline,
        ),
      ),
    );
  }
}

class _MatchCard extends StatelessWidget {
  const _MatchCard({required this.user});

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                  child: Text(
                    user.name[0].toUpperCase(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      fontSize: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            user.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          if (user.isOnline) ...[
                            const SizedBox(width: 8),
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.success,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ],
                      ),
                      Text(
                        user.experienceLevel,
                        style: TextStyle(
                          color: context.theme.hintColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pushNamed(
                    context,
                    AppRoutes.userProfile,
                    arguments: {'userId': user.id},
                  ),
                  icon: const Icon(Icons.info_outline),
                ),
              ],
            ),
            if (user.bio.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                user.bio,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: context.theme.hintColor),
              ),
            ],
            const SizedBox(height: 12),
            const Text('Teaches', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              children: user.skillsTeach
                  .map<Widget>((s) => SkillChip(label: s, isTeach: true))
                  .toList(),
            ),
            const SizedBox(height: 12),
            const Text('Wants to learn', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              children: user.skillsLearn
                  .map<Widget>((s) => SkillChip(label: s, isTeach: false))
                  .toList(),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      context.showSnack('Connected with ${user.name}!');
                    },
                    icon: const Icon(Icons.person_add_outlined, size: 18),
                    label: const Text('Connect'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GradientButton(
                    label: 'Exchange',
                    icon: Icons.swap_horiz,
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.bookSession,
                        arguments: {
                          'targetUserId': user.id,
                          'targetUserName': user.name,
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
