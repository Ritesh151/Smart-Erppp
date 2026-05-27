import 'package:flutter/material.dart';

class HoverAnimation extends StatefulWidget {
  final Widget child;
  final double scale;
  final double? elevation;
  final Color? shadowColor;
  final Duration duration;

  const HoverAnimation({
    super.key,
    required this.child,
    this.scale = 1.02,
    this.elevation,
    this.shadowColor,
    this.duration = const Duration(milliseconds: 200),
  });

  @override
  State<HoverAnimation> createState() => _HoverAnimationState();
}

class _HoverAnimationState extends State<HoverAnimation> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: widget.duration,
        transform: Matrix4.identity()..scale(_isHovered ? widget.scale : 1.0),
        decoration: widget.elevation != null || widget.shadowColor != null
            ? BoxDecoration(
                boxShadow: _isHovered
                    ? [
                        BoxShadow(
                          color: (widget.shadowColor ?? Colors.black)
                              .withOpacity(0.15),
                          blurRadius: widget.elevation ?? 12,
                          offset: const Offset(0, 6),
                        ),
                      ]
                    : [],
              )
            : null,
        child: widget.child,
      ),
    );
  }
}
