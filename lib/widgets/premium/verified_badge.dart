import 'package:flutter/material.dart';

/// Blue verified checkmark — shown after premium purchase.
class VerifiedBadge extends StatelessWidget {
  const VerifiedBadge({super.key, this.size = 18});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Color(0xFF1D9BF0),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.check,
        color: Colors.white,
        size: size * 0.65,
      ),
    );
  }
}
