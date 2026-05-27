import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AnimatedCard extends StatelessWidget {
  final Widget child;
  final int index;
  final Duration delay;

  const AnimatedCard({
    super.key,
    required this.child,
    this.index = 0,
    this.delay = const Duration(milliseconds: 60),
  });

  @override
  Widget build(BuildContext context) {
    return child
        .animate()
        .fadeIn(delay: (index * delay.inMilliseconds).ms, duration: 300.ms)
        .slideY(begin: 0.15, end: 0, delay: (index * delay.inMilliseconds).ms, duration: 300.ms);
  }
}
