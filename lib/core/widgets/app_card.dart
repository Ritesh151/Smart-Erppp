import 'package:flutter/material.dart';
import 'package:smarterp/core/theme/theme_extensions.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? elevation;
  final Color? color;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;
  final Border? border;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.elevation,
    this.color,
    this.onTap,
    this.borderRadius,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;

    Widget cardContent = Container(
      padding: padding ?? appTheme.cardPadding,
      decoration: BoxDecoration(
        color: color ?? appTheme.cardBackground,
        borderRadius: borderRadius ??
            BorderRadius.circular(appTheme.cardBorderRadius ?? 8.0),
        border: border ?? Border.all(color: appTheme.cardBorder ?? Colors.grey.shade300),
      ),
      child: child,
    );

    if (onTap != null) {
      cardContent = InkWell(
        onTap: onTap,
        borderRadius: borderRadius ??
            BorderRadius.circular(appTheme.cardBorderRadius ?? 8.0),
        child: cardContent,
      );
    }

    return Card(
      elevation: elevation ?? appTheme.cardElevation ?? 2.0,
      margin: margin ?? const EdgeInsets.all(8.0),
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ??
            BorderRadius.circular(appTheme.cardBorderRadius ?? 8.0),
      ),
      child: cardContent,
    );
  }
}
