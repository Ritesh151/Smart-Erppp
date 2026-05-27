import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class LoadingAnimation extends StatelessWidget {
  final double size;
  final Color? color;

  const LoadingAnimation({
    super.key,
    this.size = 40,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? Theme.of(context).colorScheme.primary;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: c,
            ),
          ).animate().shake(duration: 600.ms),
        ],
      ),
    );
  }
}

class ShimmerLoading extends StatelessWidget {
  final int itemCount;
  final double itemHeight;
  final double borderRadius;

  const ShimmerLoading({
    super.key,
    this.itemCount = 6,
    this.itemHeight = 80,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      itemBuilder: (context, index) => AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        height: itemHeight,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: colorScheme.surfaceVariant.withOpacity(0.3),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ).animate().fadeIn(
            delay: (index * 80).ms,
            duration: 400.ms,
          ),
    );
  }
}
