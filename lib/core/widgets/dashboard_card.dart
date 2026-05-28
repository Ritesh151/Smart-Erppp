import 'package:flutter/material.dart';
import 'package:SmartERP/core/constants/app_constants.dart';
import 'package:SmartERP/core/extensions/context_extensions.dart';

class DashboardCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? iconColor;
  final Color? backgroundColor;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;

  const DashboardCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.iconColor,
    this.backgroundColor,
    this.subtitle,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        child: Padding(
          padding: EdgeInsets.all(context.isMobile ? 12.0 : 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.all(context.isMobile ? 8 : 12),
                    decoration: BoxDecoration(
                      color: (backgroundColor ?? colorScheme.primary)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(
                        AppConstants.smallBorderRadius,
                      ),
                    ),
                    child: Icon(
                      icon,
                      color: iconColor ?? colorScheme.primary,
                      size: context.isMobile ? 20 : AppConstants.iconSizeLarge,
                    ),
                  ),
                  if (trailing != null) 
                    Flexible(child: trailing!),
                ],
              ),
              SizedBox(height: context.isMobile ? 12 : 16),
              Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.7),
                  fontSize: context.isMobile ? 12 : null,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: context.isMobile ? 4 : 8),
              Text(
                value,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                  fontSize: context.isMobile ? 18 : null,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (subtitle != null) ...[
                SizedBox(height: context.isMobile ? 4 : 8),
                Text(
                  subtitle!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.6),
                    fontSize: context.isMobile ? 10 : null,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
