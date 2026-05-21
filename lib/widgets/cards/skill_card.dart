import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:skill_swap/core/constants/app_constants.dart';
import 'package:skill_swap/models/skill_model.dart';
import 'package:skill_swap/theme/app_colors.dart';

/// Trending skill card for home dashboard.
class SkillCard extends StatelessWidget {
  const SkillCard({super.key, required this.skill, this.onTap});

  final SkillModel skill;
  final VoidCallback? onTap;

  IconData _iconForCategory(String category) {
    switch (category) {
      case 'Design':
        return Icons.palette_outlined;
      case 'Development':
        return Icons.code;
      case 'Marketing':
        return Icons.campaign_outlined;
      case 'Language':
        return Icons.translate;
      case 'Music':
        return Icons.music_note;
      default:
        return Icons.star_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: AppConstants.paddingM),
        padding: const EdgeInsets.all(AppConstants.paddingM),
        decoration: BoxDecoration(
          gradient: skill.trending
              ? AppColors.cardGradient
              : null,
          color: skill.trending
              ? null
              : Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              _iconForCategory(skill.category),
              color: skill.trending ? Colors.white : AppColors.primary,
            ),
            const Spacer(),
            Text(
              skill.name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: skill.trending ? Colors.white : null,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              '${skill.learnersCount} learners',
              style: TextStyle(
                fontSize: 11,
                color: skill.trending
                    ? Colors.white70
                    : Theme.of(context).hintColor,
              ),
            ),
          ],
        ),
      ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95)),
    );
  }
}
