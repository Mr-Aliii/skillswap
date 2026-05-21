import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Skeleton shimmer placeholder for loading states.
class ShimmerLoader extends StatelessWidget {
  const ShimmerLoader({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
      highlightColor: isDark ? Colors.grey.shade700 : Colors.grey.shade100,
      child: child,
    );
  }
}

class ShimmerCard extends StatelessWidget {
  const ShimmerCard({super.key, this.height = 100});

  final double height;

  @override
  Widget build(BuildContext context) {
    return ShimmerLoader(
      child: Container(
        height: height,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
