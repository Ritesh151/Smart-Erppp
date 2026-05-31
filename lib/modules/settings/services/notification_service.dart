import '../../../core/models/notification_model.dart';
import '../../../core/utils/logger.dart';
import '../../../modules/settings/repositories/notification_repository.dart';

class NotificationService {
  NotificationService({required NotificationRepository repository})
      : _repository = repository;

  final NotificationRepository _repository;

  Future<List<NotificationModel>> getAll() async {
    try {
      return await _repository.getAll();
    } on Exception catch (e, stackTrace) {
      Logger.error('Failed to get notifications', e, stackTrace);
      return [];
    }
  }

  Future<int> getUnreadCount() async {
    try {
      return await _repository.getUnreadCount();
    } on Exception catch (_) {
      return 0;
    }
  }

  Future<List<NotificationModel>> getRecent(int limit) async {
    try {
      return await _repository.getRecent(limit);
    } on Exception catch (e, stackTrace) {
      Logger.error('Failed to get recent notifications', e, stackTrace);
      return [];
    }
  }

  Future<void> createNotification({
    required String title,
    required String message,
    required NotificationCategory category,
    NotificationPriority priority = NotificationPriority.medium,
    String? referenceId,
    String? referenceType,
    String? actionRoute,
  }) async {
    try {
      final notification = NotificationModel.create(
        title: title,
        message: message,
        category: category,
        priority: priority,
        referenceId: referenceId,
        referenceType: referenceType,
        actionRoute: actionRoute,
      );
      await _repository.save(notification);
      Logger.info('Notification created: $title');
    } on Exception catch (e, stackTrace) {
      Logger.error('Failed to create notification', e, stackTrace);
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      await _repository.markAsRead(id);
    } on Exception catch (e, stackTrace) {
      Logger.error('Failed to mark notification as read', e, stackTrace);
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _repository.markAllAsRead();
    } on Exception catch (e, stackTrace) {
      Logger.error('Failed to mark all as read', e, stackTrace);
    }
  }

  Future<void> deleteNotification(String id) async {
    try {
      await _repository.delete(id);
    } on Exception catch (e, stackTrace) {
      Logger.error('Failed to delete notification', e, stackTrace);
    }
  }

  Future<void> deleteAll() async {
    try {
      await _repository.deleteAll();
    } on Exception catch (e, stackTrace) {
      Logger.error('Failed to delete all notifications', e, stackTrace);
    }
  }

  Future<List<NotificationModel>> getByCategory(NotificationCategory category) async {
    try {
      return await _repository.getByCategory(category);
    } on Exception catch (e, stackTrace) {
      Logger.error('Failed to get notifications by category', e, stackTrace);
      return [];
    }
  }

  Future<void> notifyLowStock(String productName, int stock, int threshold) async {
    await createNotification(
      title: 'Low Stock Alert',
      message: '$productName has only $stock units (threshold: $threshold)',
      category: NotificationCategory.lowStock,
      priority: stock <= 0 ? NotificationPriority.critical : NotificationPriority.high,
      referenceType: 'product',
    );
  }

  Future<void> notifySalaryReminder(String employeeName, double amount) async {
    await createNotification(
      title: 'Salary Reminder',
      message: '$employeeName has pending salary of ₹${amount.toStringAsFixed(0)}',
      category: NotificationCategory.salaryReminder,
      referenceType: 'salary',
    );
  }

  Future<void> notifyPaymentDue(String customerName, double amount, String invoiceId) async {
    await createNotification(
      title: 'Payment Due',
      message: '$customerName has a payment of ₹${amount.toStringAsFixed(0)} due',
      category: NotificationCategory.paymentDue,
      priority: NotificationPriority.high,
      referenceId: invoiceId,
      referenceType: 'invoice',
    );
  }

  Future<void> notifySystem(String title, String message) async {
    await createNotification(
      title: title,
      message: message,
      category: NotificationCategory.system,
      priority: NotificationPriority.low,
    );
  }

  Future<void> notifyBackupComplete(String backupName) async {
    await createNotification(
      title: 'Backup Complete',
      message: 'Backup "$backupName" completed successfully',
      category: NotificationCategory.backup,
      priority: NotificationPriority.low,
      referenceType: 'backup',
    );
  }

  Future<void> notifyBusinessAlert(String title, String message,
      {NotificationPriority priority = NotificationPriority.medium}) async {
    await createNotification(
      title: title,
      message: message,
      category: NotificationCategory.businessAlert,
      priority: priority,
    );
  }
}
