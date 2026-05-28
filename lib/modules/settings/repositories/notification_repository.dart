import 'package:SmartERP/core/exceptions/app_exception.dart';
import 'package:SmartERP/core/models/notification_model.dart';
import 'package:SmartERP/core/storage/storage_service.dart';
import 'package:SmartERP/core/utils/logger.dart';

class NotificationRepository {
  final StorageService<Map<dynamic, dynamic>> _storage;

  NotificationRepository({
    required StorageService<Map<dynamic, dynamic>> storage,
  }) : _storage = storage;

  Future<List<NotificationModel>> getAll() async {
    try {
      final data = _storage.getAll();
      return data
          .map((item) => NotificationModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } catch (e, stackTrace) {
      Logger.error('Failed to get all notifications', e, stackTrace);
      throw StorageException('Failed to retrieve notifications');
    }
  }

  Future<NotificationModel?> getById(String id) async {
    try {
      final data = _storage.get(id);
      if (data == null) return null;
      return NotificationModel.fromJson(Map<String, dynamic>.from(data));
    } catch (e, stackTrace) {
      Logger.error('Failed to get notification by id: $id', e, stackTrace);
      return null;
    }
  }

  Future<void> save(NotificationModel notification) async {
    try {
      await _storage.save(notification.id, notification.toJson());
      Logger.success('Notification saved: ${notification.title}');
    } catch (e, stackTrace) {
      Logger.error('Failed to save notification', e, stackTrace);
      throw StorageException('Failed to save notification');
    }
  }

  Future<void> update(NotificationModel notification) async {
    try {
      await _storage.save(notification.id, notification.toJson());
      Logger.debug('Notification updated: ${notification.title}');
    } catch (e, stackTrace) {
      Logger.error('Failed to update notification', e, stackTrace);
      throw StorageException('Failed to update notification');
    }
  }

  Future<void> delete(String id) async {
    try {
      await _storage.delete(id);
      Logger.success('Notification deleted: $id');
    } catch (e, stackTrace) {
      Logger.error('Failed to delete notification', e, stackTrace);
      throw StorageException('Failed to delete notification');
    }
  }

  Future<List<NotificationModel>> getByCategory(NotificationCategory category) async {
    try {
      final all = await getAll();
      return all.where((n) => n.category == category).toList();
    } catch (e, stackTrace) {
      Logger.error('Failed to get notifications by category', e, stackTrace);
      return [];
    }
  }

  Future<List<NotificationModel>> getByPriority(NotificationPriority priority) async {
    try {
      final all = await getAll();
      return all.where((n) => n.priority == priority).toList();
    } catch (e, stackTrace) {
      Logger.error('Failed to get notifications by priority', e, stackTrace);
      return [];
    }
  }

  Future<List<NotificationModel>> getUnread() async {
    try {
      final all = await getAll();
      return all.where((n) => !n.isRead).toList();
    } catch (e, stackTrace) {
      Logger.error('Failed to get unread notifications', e, stackTrace);
      return [];
    }
  }

  Future<int> getUnreadCount() async {
    try {
      final unread = await getUnread();
      return unread.length;
    } catch (e) {
      return 0;
    }
  }

  Future<List<NotificationModel>> getRecent(int limit) async {
    try {
      final all = await getAll();
      all.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return all.take(limit).toList();
    } catch (e, stackTrace) {
      Logger.error('Failed to get recent notifications', e, stackTrace);
      return [];
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      final notification = await getById(id);
      if (notification != null) {
        await update(notification.markAsRead());
      }
    } catch (e, stackTrace) {
      Logger.error('Failed to mark notification as read: $id', e, stackTrace);
    }
  }

  Future<void> markAllAsRead() async {
    try {
      final unread = await getUnread();
      for (final notification in unread) {
        await update(notification.markAsRead());
      }
      Logger.success('All notifications marked as read');
    } catch (e, stackTrace) {
      Logger.error('Failed to mark all as read', e, stackTrace);
    }
  }

  Future<void> deleteAll() async {
    try {
      final all = await getAll();
      for (final item in all) {
        await _storage.delete(item.id);
      }
      Logger.success('All notifications deleted');
    } catch (e, stackTrace) {
      Logger.error('Failed to delete all notifications', e, stackTrace);
      throw StorageException('Failed to clear notifications');
    }
  }

  Future<void> deleteByCategory(NotificationCategory category) async {
    try {
      final items = await getByCategory(category);
      for (final item in items) {
        await _storage.delete(item.id);
      }
      Logger.success('Notifications deleted for category: $category');
    } catch (e, stackTrace) {
      Logger.error('Failed to delete notifications by category', e, stackTrace);
    }
  }

  Future<void> saveAll(List<NotificationModel> notifications) async {
    try {
      for (final notification in notifications) {
        await _storage.save(notification.id, notification.toJson());
      }
      Logger.success('${notifications.length} notifications saved');
    } catch (e, stackTrace) {
      Logger.error('Failed to save notifications batch', e, stackTrace);
      throw StorageException('Failed to save notifications batch');
    }
  }
}
