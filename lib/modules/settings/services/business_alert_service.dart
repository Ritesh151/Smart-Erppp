import '../../../core/models/notification_model.dart';
import '../../../core/utils/logger.dart';
import '../../../modules/settings/services/app_intelligence_service.dart';
import '../../../modules/settings/services/notification_service.dart';

class BusinessAlert {
  BusinessAlert({
    required this.id,
    required this.title,
    required this.message,
    this.severity = 'info',
    this.actionLabel,
    this.actionRoute,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  final String id;
  final String title;
  final String message;
  final String severity;
  final String? actionLabel;
  final String? actionRoute;
  final DateTime createdAt;

  bool get isCritical => severity == 'critical';
  bool get isWarning => severity == 'warning';
  bool get isInfo => severity == 'info';
}

class BusinessAlertService {
  BusinessAlertService({
    required AppIntelligenceService intelligenceService,
    required NotificationService notificationService,
  })  : _intelligenceService = intelligenceService,
        _notificationService = notificationService;

  final AppIntelligenceService _intelligenceService;
  final NotificationService _notificationService;

  Future<List<BusinessAlert>> generateAlerts() async {
    final alerts = <BusinessAlert>[];
    final insights = await _intelligenceService.getInsights(forceRefresh: true);

    for (final insight in insights) {
      if (!insight.isPositive) {
        switch (insight.category) {
          case InsightCategory.inventory:
            if (insight.title.startsWith('0 ')) {
              alerts.add(BusinessAlert(
                id: 'alert-oos-${DateTime.now().millisecondsSinceEpoch}',
                title: 'Stock Out Critical',
                message: insight.description,
                severity: 'critical',
                actionLabel: 'View Inventory',
              ));
            } else {
              alerts.add(BusinessAlert(
                id: 'alert-low-${DateTime.now().millisecondsSinceEpoch}',
                title: insight.title,
                message: insight.description,
                severity: 'warning',
                actionLabel: 'Restock Now',
              ));
            }

          case InsightCategory.customers:
            alerts.add(BusinessAlert(
              id: 'alert-due-${DateTime.now().millisecondsSinceEpoch}',
              title: insight.title,
              message: insight.description,
              severity: 'warning',
              actionLabel: 'View Invoices',
            ));

          case InsightCategory.revenue:
            alerts.add(BusinessAlert(
              id: 'alert-rev-${DateTime.now().millisecondsSinceEpoch}',
              title: insight.title,
              message: insight.description,
              severity: 'warning',
            ));

          default:
            break;
        }
      }
    }

    if (alerts.isNotEmpty) {
      for (final alert in alerts) {
        await _notificationService.createNotification(
          title: alert.title,
          message: alert.message,
          category: NotificationCategory.businessAlert,
          priority: alert.isCritical
              ? NotificationPriority.critical
              : alert.isWarning
                  ? NotificationPriority.high
                  : NotificationPriority.medium,
        );
      }
      Logger.info('Generated ${alerts.length} business alerts');
    }

    return alerts;
  }

  Future<List<BusinessAlert>> getCriticalAlerts() async {
    final alerts = await generateAlerts();
    return alerts.where((a) => a.isCritical).toList();
  }

  Future<List<BusinessAlert>> getWarningAlerts() async {
    final alerts = await generateAlerts();
    return alerts.where((a) => a.isWarning).toList();
  }
}
