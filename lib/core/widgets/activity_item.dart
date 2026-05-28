import 'package:flutter/material.dart';
import 'package:SmartERP/core/extensions/context_extensions.dart';
import 'package:SmartERP/core/extensions/date_extensions.dart';

class ActivityItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final DateTime timestamp;
  final VoidCallback? onTap;
  final Color? iconColor;

  const ActivityItem({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.timestamp,
    this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final color = iconColor ?? colorScheme.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: color.withOpacity(0.1),
              child: Icon(icon, size: 16, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 11,
                      color: colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              timestamp.toRelativeTime(),
              style: TextStyle(
                fontSize: 10,
                color: colorScheme.onSurface.withOpacity(0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
