import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skill_swap/core/constants/app_constants.dart';
import 'package:skill_swap/core/extensions/context_extensions.dart';
import 'package:skill_swap/models/user_model.dart';
import 'package:skill_swap/providers/auth_provider.dart';
import 'package:skill_swap/providers/home_provider.dart';
import 'package:skill_swap/routes/app_routes.dart';
import 'package:skill_swap/theme/app_colors.dart';
import 'package:skill_swap/widgets/common/empty_state.dart';
import 'package:skill_swap/widgets/common/gradient_button.dart';
import 'package:skill_swap/widgets/common/skill_chip.dart';
import 'package:skill_swap/widgets/premium/premium_badge_chip.dart';
import 'package:skill_swap/widgets/premium/user_avatar_badge.dart';
import 'package:skill_swap/widgets/premium/user_display_name.dart';
import 'package:skill_swap/widgets/common/connection_action_buttons.dart';

/// Browse users and request skill exchanges.
class MatchScreen extends ConsumerWidget {
  const MatchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(recommendedUsersProvider);
    final currentUser = ref.watch(currentUserProfileProvider).valueOrNull;

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
                return _MatchCard(user: user, currentUser: currentUser);
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
  const _MatchCard({required this.user, this.currentUser});

  final UserModel user;
  final UserModel? currentUser;

  /// Skills that match: I want to learn ↔ they teach
  List<String> get _theyTeachWhatIWant {
    if (currentUser == null) return [];
    return currentUser!.skillsLearn
        .where((s) => user.skillsTeach.contains(s))
        .toList();
  }

  /// Skills that match: I teach ↔ they want to learn
  List<String> get _iTeachWhatTheyWant {
    if (currentUser == null) return [];
    return currentUser!.skillsTeach
        .where((s) => user.skillsLearn.contains(s))
        .toList();
  }

  int get _matchCount => _theyTeachWhatIWant.length + _iTeachWhatTheyWant.length;

  @override
  Widget build(BuildContext context) {
    final isPremium = user.showVerifiedBadge;
    final hasMatch = _matchCount > 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isPremium
            ? const BorderSide(color: Color(0xFFF59E0B), width: 1.5)
            : hasMatch
            ? BorderSide(color: AppColors.primary.withValues(alpha: 0.4), width: 1)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                UserAvatarBadge(user: user, radius: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      UserDisplayName(user: user, showPremiumChip: false),
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
                if (_matchCount > 0)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.accent],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.swap_horiz,
                            size: 14, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(
                          '$_matchCount match${_matchCount > 1 ? 'es' : ''}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (isPremium) const PremiumBadgeChip(compact: true),
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
            // Match reason section
            if (_theyTeachWhatIWant.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(Icons.school, size: 16, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Can teach you: ${_theyTeachWhatIWant.join(', ')}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (_iTeachWhatTheyWant.isNotEmpty) ...[
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lightbulb, size: 16, color: AppColors.accent),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Wants to learn from you: ${_iTeachWhatTheyWant.join(', ')}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.accent,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
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
                  child: ConnectionActionButtons(targetUser: user),
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
