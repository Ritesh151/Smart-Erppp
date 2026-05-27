import 'package:smarterp/core/models/notification_model.dart';
import 'package:smarterp/core/utils/logger.dart';
import 'package:smarterp/modules/settings/services/low_stock_service.dart';
import 'package:smarterp/modules/settings/services/notification_service.dart';
import 'package:smarterp/modules/settings/services/settings_service.dart';

class StockAlert {
  final String id;
  final String title;
  final String message;
  final bool isCritical;
  final DateTime createdAt;

  StockAlert({
    required this.id,
    required this.title,
    required this.message,
    required this.isCritical,
    required this.createdAt,
  });
}

class StockAlertService {
  final LowStockService _lowStockService;
  final NotificationService _notificationService;
  final SettingsService _settingsService;

  StockAlertService({
    required LowStockService lowStockService,
    required NotificationService notificationService,
    required SettingsService settingsService,
  })  : _lowStockService = lowStockService,
        _notificationService = notificationService,
        _settingsService = settingsService;

  Future<List<StockAlert>> checkAndGenerateAlerts() async {
    try {
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
    } catch (e, stackTrace) {
      Logger.error('Failed to check and generate alerts', e, stackTrace);
      return [];
    }
  }

  Future<void> sendLowStockNotifications() async {
    try {
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
    } catch (e, stackTrace) {
      Logger.error('Failed to send low stock notifications', e, stackTrace);
    }
  }

  Future<List<StockAlert>> getDashboardAlerts() async {
    try {
      return await checkAndGenerateAlerts();
    } catch (e, stackTrace) {
      Logger.error('Failed to get dashboard alerts', e, stackTrace);
      return [];
    }
  }

  Future<int> getAlertCount() async {
    try {
      final alerts = await checkAndGenerateAlerts();
      return alerts.length;
    } catch (e) {
      return 0;
    }
  }

  Future<int> getCriticalAlertCount() async {
    try {
      final alerts = await checkAndGenerateAlerts();
      return alerts.where((a) => a.isCritical).length;
    } catch (e) {
      return 0;
    }
  }
}
