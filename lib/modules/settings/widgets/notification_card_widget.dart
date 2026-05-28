import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:SmartERP/core/models/notification_model.dart';
import 'package:SmartERP/core/widgets/app_card.dart';

class NotificationCardWidget extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const NotificationCardWidget({
    super.key,
    required this.notification,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (_) => onDelete?.call(),
      child: AnimatedContainer(
        duration: 300.ms,
        curve: Curves.easeInOut,
        child: AppCard(
          color: notification.isRead ? null : theme.colorScheme.primary.withOpacity(0.04),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildIcon(context),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            if (!notification.isRead)
                              Container(
                                width: 8, height: 8,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            if (!notification.isRead) const SizedBox(width: 6),
                            Expanded(
                              child: Text(notification.title,
                                style: TextStyle(
                                  fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            _buildPriorityBadge(context),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(notification.message,
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Text(notification.timeAgo,
                              style: TextStyle(
                                fontSize: 10,
                                color: theme.colorScheme.onSurface.withOpacity(0.4),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: _categoryColor(notification.category).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(notification.category.name,
                                style: TextStyle(
                                  fontSize: 9,
                                  color: _categoryColor(notification.category),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (onDelete != null)
                    IconButton(
                      icon: const Icon(Icons.close, size: 16),
                      onPressed: onDelete,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      color: theme.colorScheme.onSurface.withOpacity(0.3),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(BuildContext context) {
    final icon = _categoryIcon(notification.category);
    final color = _categoryColor(notification.category);

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, size: 18, color: color),
    );
  }

  Widget _buildPriorityBadge(BuildContext context) {
    if (!notification.isHighPriority) return const SizedBox();

    final color = notification.priority == NotificationPriority.critical
        ? Colors.red
        : Colors.orange;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        notification.priority.name.toUpperCase(),
        style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }

  IconData _categoryIcon(NotificationCategory cat) {
    switch (cat) {
      case NotificationCategory.lowStock:
        return Icons.inventory_2;
      case NotificationCategory.salaryReminder:
        return Icons.payments;
      case NotificationCategory.paymentDue:
        return Icons.account_balance_wallet;
      case NotificationCategory.transportAlert:
        return Icons.local_shipping;
      case NotificationCategory.invoiceReminder:
        return Icons.receipt_long;
      case NotificationCategory.system:
        return Icons.settings;
      case NotificationCategory.backup:
        return Icons.backup;
      case NotificationCategory.businessAlert:
        return Icons.analytics;
    }
  }

  Color _categoryColor(NotificationCategory cat) {
    switch (cat) {
      case NotificationCategory.lowStock:
        return Colors.red;
      case NotificationCategory.salaryReminder:
        return Colors.purple;
      case NotificationCategory.paymentDue:
        return Colors.orange;
      case NotificationCategory.transportAlert:
        return Colors.blue;
      case NotificationCategory.invoiceReminder:
        return Colors.teal;
      case NotificationCategory.system:
        return Colors.grey;
      case NotificationCategory.backup:
        return Colors.green;
      case NotificationCategory.businessAlert:
        return Colors.indigo;
    }
  }
}
