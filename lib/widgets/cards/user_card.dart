import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:skill_swap/core/constants/app_constants.dart';
import 'package:skill_swap/models/user_model.dart';
import 'package:skill_swap/theme/app_colors.dart';
import 'package:skill_swap/widgets/common/skill_chip.dart';

/// Recommended / discover user card with hero support.
class UserCard extends StatelessWidget {
  const UserCard({
    super.key,
    required this.user,
    this.onTap,
    this.onConnect,
    this.heroTag,
  });

  final UserModel user;
  final VoidCallback? onTap;
  final VoidCallback? onConnect;
  final String? heroTag;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: AppConstants.paddingM),
        padding: const EdgeInsets.all(AppConstants.paddingM),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
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
                Hero(
                  tag: heroTag ?? 'avatar_${user.id}',
                  child: CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                    child: Text(
                      user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                if (user.isOnline)
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
            Text(
              user.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
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
            if (user.skillsTeach.isNotEmpty)
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
      ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.1, end: 0),
    );
  }
}
