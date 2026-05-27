import 'package:flutter/material.dart';

class AnimatedFadeTile extends StatelessWidget {
  final int index;
  final Widget child;
  final Duration duration;
  final int? totalItems;

  const AnimatedFadeTile({
    super.key,
    required this.index,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.totalItems,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration + Duration(milliseconds: index * 50),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

class ResponsivePadding extends StatelessWidget {
  final Widget child;
  final EdgeInsets compact;
  final EdgeInsets medium;
  final EdgeInsets expanded;

  const ResponsivePadding({
    super.key,
    required this.child,
    this.compact = const EdgeInsets.all(12),
    this.medium = const EdgeInsets.all(20),
    this.expanded = const EdgeInsets.all(24),
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final padding = constraints.maxWidth > 900
            ? expanded
            : constraints.maxWidth > 600
                ? medium
                : compact;
        return Padding(
          padding: padding,
          child: child,
        );
      },
    );
  }
}

class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double compactCrossAxisExtent;
  final double expandedCrossAxisExtent;
  final double childAspectRatio;
  final double spacing;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.compactCrossAxisExtent = 160,
    this.expandedCrossAxisExtent = 220,
    this.childAspectRatio = 1.4,
    this.spacing = 16,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisExtent = constraints.maxWidth > 900
            ? expandedCrossAxisExtent
            : compactCrossAxisExtent;
        return GridView.extent(
          maxCrossAxisExtent: crossAxisExtent,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: spacing,
          crossAxisSpacing: spacing,
          childAspectRatio: childAspectRatio,
          children: children,
        );
      },
    );
  }
}

class AnimatedSection extends StatefulWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  final IconData? icon;

  const AnimatedSection({
    super.key,
    required this.title,
    this.subtitle,
    required this.child,
    this.icon,
  });

  @override
  State<AnimatedSection> createState() => _AnimatedSectionState();
}

class _AnimatedSectionState extends State<AnimatedSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.icon != null)
              Row(
                children: [
                  Icon(widget.icon, size: 18, color: colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(widget.title, style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  )),
                ],
              )
            else
              Text(widget.title, style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              )),
            if (widget.subtitle != null) ...[
              const SizedBox(height: 2),
              Text(widget.subtitle!, style: TextStyle(
                fontSize: 11, color: colorScheme.onSurface.withOpacity(0.4),
              )),
            ],
            const SizedBox(height: 16),
            widget.child,
          ],
        ),
      ),
    );
  }
}
