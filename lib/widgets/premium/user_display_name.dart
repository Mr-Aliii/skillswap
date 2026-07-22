import 'package:flutter/material.dart';
import 'package:skill_swap/models/user_model.dart';
import 'package:skill_swap/widgets/premium/premium_badge_chip.dart';
import 'package:skill_swap/widgets/premium/verified_badge.dart';

/// Name row with verified icon + optional premium chip.
class UserDisplayName extends StatelessWidget {
  const UserDisplayName({
    super.key,
    required this.user,
    this.style,
    this.showPremiumChip = true,
  });

  final UserModel user;
  final TextStyle? style;
  final bool showPremiumChip;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            user.name,
            style: style ??
                const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (user.showVerifiedBadge) ...[
          const SizedBox(width: 4),
          VerifiedBadge(size: (style?.fontSize ?? 15) + 2),
        ],
        if (showPremiumChip && user.showVerifiedBadge) ...[
          const SizedBox(width: 6),
          const PremiumBadgeChip(compact: true),
        ],
      ],
    );
  }
}
