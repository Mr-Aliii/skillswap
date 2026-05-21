import 'package:flutter/material.dart';
import 'package:skill_swap/theme/app_colors.dart';

/// Skill tag chip for profiles and cards.
class SkillChip extends StatelessWidget {
  const SkillChip({
    super.key,
    required this.label,
    this.isTeach = true,
    this.onDeleted,
  });

  final String label;
  final bool isTeach;
  final VoidCallback? onDeleted;

  @override
  Widget build(BuildContext context) {
    final color = isTeach ? AppColors.primary : AppColors.accent;
    return Chip(
      label: Text(label),
      deleteIcon: onDeleted != null ? const Icon(Icons.close, size: 16) : null,
      onDeleted: onDeleted,
      backgroundColor: color.withValues(alpha: 0.12),
      labelStyle: TextStyle(
        color: color,
        fontWeight: FontWeight.w500,
        fontSize: 12,
      ),
      side: BorderSide.none,
      padding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }
}
