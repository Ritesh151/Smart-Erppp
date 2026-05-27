import 'package:flutter/material.dart';
import 'package:smarterp/core/widgets/app_card.dart';

class KpiWidget extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color color;
  final String? change;
  final bool isPositive;

  const KpiWidget({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    required this.icon,
    required this.color,
    this.change,
    this.isPositive = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 20, color: color),
              ),
              const Spacer(),
              if (change != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: (isPositive ? Colors.green : Colors.red).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                        size: 10,
                        color: isPositive ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 2),
                      Text(change!,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isPositive ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const Spacer(),
          Text(title,
            style: TextStyle(
              fontSize: 11,
              color: colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 4),
          Text(value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(subtitle!,
              style: TextStyle(
                fontSize: 10,
                color: colorScheme.onSurface.withOpacity(0.4),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
