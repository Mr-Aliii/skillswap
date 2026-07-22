import 'package:flutter/material.dart';
import 'package:skill_swap/models/user_model.dart';
import 'package:skill_swap/theme/app_colors.dart';
import 'package:skill_swap/widgets/premium/verified_badge.dart';

/// Avatar with optional verified badge overlay (premium users).
class UserAvatarBadge extends StatelessWidget {
  const UserAvatarBadge({
    super.key,
    required this.user,
    this.radius = 24,
    this.heroTag,
  });

  final UserModel user;
  final double radius;
  final String? heroTag;

  @override
  Widget build(BuildContext context) {
    final avatar = CircleAvatar(
      radius: radius,
      backgroundColor: user.showVerifiedBadge
          ? const Color(0xFFF59E0B).withValues(alpha: 0.2)
          : AppColors.primary.withValues(alpha: 0.2),
      child: Text(
        user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: user.showVerifiedBadge
              ? const Color(0xFFD97706)
              : AppColors.primary,
          fontSize: radius * 0.75,
        ),
      ),
    );

    final wrapped = heroTag != null
        ? Hero(tag: heroTag!, child: avatar)
        : avatar;

    if (!user.showVerifiedBadge) return wrapped;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        wrapped,
        Positioned(
          right: -2,
          bottom: -2,
          child: VerifiedBadge(size: radius * 0.55),
        ),
      ],
    );
  }
}
