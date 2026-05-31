import '../../../core/models/notification_model.dart';
import '../../../core/utils/logger.dart';
import '../../../modules/settings/services/low_stock_service.dart';
import '../../../modules/settings/services/notification_service.dart';
import '../../../modules/settings/services/settings_service.dart';

class StockAlert {
  StockAlert({
    required this.id,
    required this.title,
    required this.message,
    required this.isCritical,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String message;
  final bool isCritical;
  final DateTime createdAt;
}

class StockAlertService {
  StockAlertService({
    required LowStockService lowStockService,
    required NotificationService notificationService,
    required SettingsService settingsService,
  })  : _lowStockService = lowStockService,
        _notificationService = notificationService,
        _settingsService = settingsService;

  final LowStockService _lowStockService;
  final NotificationService _notificationService;
  final SettingsService _settingsService;

  Future<List<StockAlert>> checkAndGenerateAlerts() async {
    try {
      if (!await _settingsService.isLowStockAlertsEnabled()) {
        return [];
      }

      final alerts = <StockAlert>[];
      final items = await _lowStockService.getLowStockItems();
      final threshold = await _settingsService.getLowStockThreshold();

      for (final item in items) {
        final isCritical = item.isOutOfStock || item.deficit >= threshold;
        final alert = StockAlert(
          id: item.product.id,
          title: item.isOutOfStock ? 'Out of Stock' : 'Low Stock',
          message: '${item.product.productName} - '
              '${item.isOutOfStock ? "out of stock" : "only ${item.product.stockQuantity} left (min: ${item.product.minStockLevel})"}',
          isCritical: isCritical,
          createdAt: DateTime.now(),
        );
        alerts.add(alert);
      }

      return alerts;
    } on Exception catch (e, stackTrace) {
      Logger.error('Failed to check and generate alerts', e, stackTrace);
      return [];
    }
  }

  Future<void> sendLowStockNotifications() async {
    try {
      if (!await _settingsService.isLowStockAlertsEnabled()) {
        return;
      }

      final items = await _lowStockService.getLowStockItems();
      for (final item in items) {
        await _notificationService.createNotification(
          title: item.isOutOfStock ? 'Out of Stock' : 'Low Stock Alert',
          message: item.alertMessage,
          category: NotificationCategory.lowStock,
          priority: item.isOutOfStock
              ? NotificationPriority.critical
              : NotificationPriority.high,
          referenceId: item.product.id,
          referenceType: 'product',
        );
      }
      Logger.info('Sent ${items.length} low stock notifications');
    } on Exception catch (e, stackTrace) {
      Logger.error('Failed to send low stock notifications', e, stackTrace);
    }
  }

  Future<List<StockAlert>> getDashboardAlerts() async {
    try {
      return await checkAndGenerateAlerts();
    } on Exception catch (e, stackTrace) {
      Logger.error('Failed to get dashboard alerts', e, stackTrace);
      return [];
    }
  }

  Future<int> getAlertCount() async {
    try {
      final alerts = await checkAndGenerateAlerts();
      return alerts.length;
    } on Exception catch (_) {
      return 0;
    }
  }

  Future<int> getCriticalAlertCount() async {
    try {
      final alerts = await checkAndGenerateAlerts();
      return alerts.where((a) => a.isCritical).length;
    } on Exception catch (_) {
      return 0;
    }
  }
}
