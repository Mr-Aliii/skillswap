import 'package:flutter/material.dart';
import 'package:skill_swap/core/constants/app_constants.dart';
import 'package:skill_swap/models/user_model.dart';
import 'package:skill_swap/theme/app_colors.dart';
import 'package:skill_swap/widgets/common/skill_chip.dart';
import 'package:skill_swap/widgets/premium/premium_badge_chip.dart';
import 'package:skill_swap/widgets/premium/user_avatar_badge.dart';
import 'package:skill_swap/widgets/premium/user_display_name.dart';

/// Recommended / discover user card with hero support.
class UserCard extends StatelessWidget {
  const UserCard({
    super.key,
    required this.user,
    this.onTap,
    this.onConnect,
    this.heroTag,
    this.matchedSkills = const [],
  });

  final UserModel user;
  final VoidCallback? onTap;
  final VoidCallback? onConnect;
  final String? heroTag;
  /// Skills this user teaches that match current user's learning list.
  final List<String> matchedSkills;

  @override
  Widget build(BuildContext context) {
    final isPremium = user.showVerifiedBadge;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: AppConstants.paddingM),
        padding: const EdgeInsets.all(AppConstants.paddingM),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
          border: isPremium
              ? Border.all(color: const Color(0xFFF59E0B), width: 1.5)
              : null,
          boxShadow: [
            BoxShadow(
              color: isPremium
                  ? const Color(0xFFF59E0B).withValues(alpha: 0.2)
                  : Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                UserAvatarBadge(
                  user: user,
                  radius: 24,
                  heroTag: heroTag ?? 'avatar_${user.id}',
                ),
                const Spacer(),
                if (isPremium) const PremiumBadgeChip(compact: true),
                if (user.isOnline && !isPremium)
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            UserDisplayName(user: user, showPremiumChip: false),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.star, size: 14, color: Colors.amber),
                const SizedBox(width: 4),
                Text(
                  user.rating.toStringAsFixed(1),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (matchedSkills.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.accent],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Can teach: ${matchedSkills.join(', ')}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 4),
            ]
            else if (user.skillsTeach.isNotEmpty)
              SkillChip(label: user.skillsTeach.first, isTeach: true),
            const Spacer(),
            if (onConnect != null)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: onConnect,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  child: const Text('Connect', style: TextStyle(fontSize: 12)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
