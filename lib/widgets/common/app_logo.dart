import 'package:flutter/material.dart';
import 'package:skill_swap/theme/app_colors.dart';

/// SkillSwap logo placeholder with gradient icon.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 80, this.showText = true});

  final double size;
  final bool showText;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(size * 0.28),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.35),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(
            Icons.swap_horiz_rounded,
            color: Colors.white,
            size: size * 0.5,
          ),
        ),
        if (showText) ...[
          const SizedBox(height: 12),
          Text(
            'SkillSwap',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ],
    );
  }
}
