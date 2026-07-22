import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skill_swap/core/constants/app_constants.dart';
import 'package:skill_swap/providers/service_providers.dart';
import 'package:skill_swap/routes/app_routes.dart';
import 'package:skill_swap/theme/app_colors.dart';
import 'package:skill_swap/widgets/premium/premium_badge_chip.dart';
import 'package:skill_swap/widgets/premium/user_avatar_badge.dart';
import 'package:skill_swap/widgets/premium/user_display_name.dart';
import 'package:skill_swap/widgets/common/gradient_button.dart';
import 'package:skill_swap/widgets/common/skill_chip.dart';
import 'package:skill_swap/widgets/common/connection_action_buttons.dart';

/// View another user's public profile.
class UserProfileScreen extends ConsumerWidget {
  const UserProfileScreen({super.key, required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userFuture = ref.watch(userServiceProvider).getUser(userId);

    return Scaffold(
      body: FutureBuilder(
        future: userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final user = snapshot.data;
          if (user == null) {
            return const Center(child: Text('User not found'));
          }

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 180,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: user.showVerifiedBadge
                          ? const LinearGradient(
                              colors: [
                                Color(0xFFF59E0B),
                                Color(0xFFD97706),
                                AppColors.primary,
                              ],
                            )
                          : AppColors.primaryGradient,
                    ),
                    child: Center(
                      child: Hero(
                        tag: 'user_$userId',
                        child: UserAvatarBadge(user: user, radius: 48),
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.paddingM),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      UserDisplayName(
                        user: user,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      if (user.showVerifiedBadge) ...[
                        const SizedBox(height: 8),
                        const PremiumBadgeChip(),
                      ],
                      Text(
                        '${user.experienceLevel} • ⭐ ${user.rating}',
                        style: TextStyle(color: Theme.of(context).hintColor),
                      ),
                      if (user.bio.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Text(user.bio),
                      ],
                      const SizedBox(height: 24),
                      const Text('Teaches',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Wrap(
                        spacing: 8,
                        children: user.skillsTeach
                            .map((s) => SkillChip(label: s))
                            .toList(),
                      ),
                      const SizedBox(height: 16),
                      const Text('Wants to learn',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Wrap(
                        spacing: 8,
                        children: user.skillsLearn
                            .map((s) => SkillChip(label: s, isTeach: false))
                            .toList(),
                      ),
                      const SizedBox(height: 32),
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          Expanded(
                            child: ConnectionActionButtons(targetUser: user),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GradientButton(
                              label: 'Exchange',
                              icon: Icons.swap_horiz,
                              onPressed: () => Navigator.pushNamed(
                                context,
                                AppRoutes.bookSession,
                                arguments: {
                                  'targetUserId': user.id,
                                  'targetUserName': user.name,
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
