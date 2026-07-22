import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skill_swap/core/constants/app_constants.dart';
import 'package:skill_swap/providers/auth_provider.dart';
import 'package:skill_swap/routes/app_routes.dart';
import 'package:skill_swap/theme/app_colors.dart';
import 'package:skill_swap/widgets/common/skill_chip.dart';
import 'package:skill_swap/widgets/premium/premium_badge_chip.dart';
import 'package:skill_swap/widgets/premium/user_avatar_badge.dart';
import 'package:skill_swap/widgets/premium/user_display_name.dart';

/// Current user profile overview.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentUserProfileProvider);

    return Scaffold(
      body: profileAsync.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text('No profile'));
          }
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200,
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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        UserAvatarBadge(user: user, radius: 48),
                      ],
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () =>
                        Navigator.pushNamed(context, AppRoutes.editProfile),
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.paddingM),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      UserDisplayName(
                        user: user,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.experienceLevel,
                        style: TextStyle(color: Theme.of(context).hintColor),
                      ),
                      if (user.showVerifiedBadge) ...[
                        const SizedBox(height: 8),
                        const PremiumBadgeChip(),
                      ],
                      if (!user.showVerifiedBadge) ...[
                        const SizedBox(height: 16),
                        _UpgradePremiumBanner(
                          onTap: () =>
                              Navigator.pushNamed(context, AppRoutes.premium),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 18),
                          Text(' ${user.rating} • ${user.sessionsCount} sessions'),
                        ],
                      ),
                      if (user.bio.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Text(user.bio),
                      ],
                      const SizedBox(height: 24),
                      const Text(
                        'Skills I Teach',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: user.skillsTeach
                            .map((s) => SkillChip(label: s, isTeach: true))
                            .toList(),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Skills I Want to Learn',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: user.skillsLearn
                            .map((s) => SkillChip(label: s, isTeach: false))
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Error loading profile')),
      ),
    );
  }
}

class _UpgradePremiumBanner extends StatelessWidget {
  const _UpgradePremiumBanner({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFFF59E0B).withValues(alpha: 0.15),
              AppColors.primary.withValues(alpha: 0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF59E0B)),
        ),
        child: Row(
          children: [
            const Icon(Icons.workspace_premium, color: Color(0xFFD97706), size: 32),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Get Premium Badge',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Verified icon + top profile visibility',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade600),
          ],
        ),
      ),
    );
  }
}
