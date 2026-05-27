import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SettingsPageTransition extends StatelessWidget {
  final Widget child;
  final int? delayMs;

  const SettingsPageTransition({
    super.key,
    required this.child,
    this.delayMs,
  });

  @override
  Widget build(BuildContext context) {
    return child.animate().fadeIn(
      delay: (delayMs ?? 0).ms,
      duration: 350.ms,
      curve: Curves.easeOut,
    ).slideY(
      begin: 0.03,
      end: 0,
      delay: (delayMs ?? 0).ms,
      duration: 350.ms,
      curve: Curves.easeOutCubic,
    );
  }
}

class StaggeredTileList extends StatelessWidget {
  final int itemCount;
  final Widget Function(BuildContext context, int index) itemBuilder;
  final int baseDelayMs;
  final int staggerMs;

  const StaggeredTileList({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.baseDelayMs = 40,
    this.staggerMs = 60,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(itemCount, (index) {
        return Padding(
          padding: EdgeInsets.only(bottom: index < itemCount - 1 ? 8 : 0),
          child: itemBuilder(context, index).animate().fadeIn(
            delay: (baseDelayMs + index * staggerMs).ms,
            duration: 300.ms,
          ).slideX(
            begin: 0.05,
            end: 0,
            delay: (baseDelayMs + index * staggerMs).ms,
            duration: 300.ms,
            curve: Curves.easeOutCubic,
          ),
        );
      }),
    );
  }
}

class AnimatedSection extends StatefulWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget child;
  final bool initiallyExpanded;

  const AnimatedSection({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    required this.child,
    this.initiallyExpanded = true,
  });

  @override
  State<AnimatedSection> createState() => _AnimatedSectionState();
}

class _AnimatedSectionState extends State<AnimatedSection>
    with SingleTickerProviderStateMixin {
  late bool _isExpanded;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
    _controller = AnimationController(
      duration: 300.ms,
      vsync: this,
      value: _isExpanded ? 1.0 : 0.0,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          InkWell(
            onTap: _toggle,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  if (widget.icon != null) ...[
                    Icon(widget.icon, size: 20, color: theme.colorScheme.primary),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.title,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        if (widget.subtitle != null)
                          Text(widget.subtitle!,
                            style: TextStyle(
                              fontSize: 11,
                              color: theme.colorScheme.onSurface.withOpacity(0.5),
                            ),
                          ),
                      ],
                    ),
                  ),
                  RotationTransition(
                    turns: _animation,
                    child: Icon(
                      Icons.expand_more,
                      size: 20,
                      color: theme.colorScheme.onSurface.withOpacity(0.4),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizeTransition(
            sizeFactor: _animation,
            axisAlignment: -1,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: widget.child,
            ),
          ),
        ],
      ),
    );
  }
}

class AnimatedFilterChipRow extends StatelessWidget {
  final List<Widget> chips;

  const AnimatedFilterChipRow({super.key, required this.chips});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: List.generate(chips.length, (index) {
          return Padding(
            padding: EdgeInsets.only(right: index < chips.length - 1 ? 8 : 0),
            child: chips[index].animate().fadeIn(
              delay: (index * 50).ms,
              duration: 250.ms,
            ).slideY(begin: 0.2, end: 0, delay: (index * 50).ms, duration: 250.ms),
          );
        }),
      ),
    );
  }
}
