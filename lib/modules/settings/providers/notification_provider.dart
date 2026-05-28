import 'package:flutter/foundation.dart';
import 'package:SmartERP/core/models/notification_model.dart';
import 'package:SmartERP/core/utils/logger.dart';
import 'package:SmartERP/modules/settings/services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationService _service;

  NotificationProvider(this._service);

  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  String? _errorMessage;
  int _unreadCount = 0;
  NotificationCategory? _selectedCategory;
  String _searchQuery = '';

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get unreadCount => _unreadCount;
  NotificationCategory? get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;

  List<NotificationModel> get filteredNotifications {
    var result = _notifications;
    if (_selectedCategory != null) {
      result = result.where((n) => n.category == _selectedCategory).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      result = result.where((n) =>
        n.title.toLowerCase().contains(query) ||
        n.message.toLowerCase().contains(query)
      ).toList();
    }
    return result;
  }

  List<NotificationModel> get unreadNotifications =>
      _notifications.where((n) => !n.isRead).toList();

  List<NotificationModel> get highPriorityNotifications =>
      _notifications.where((n) => n.isHighPriority).toList();

  Future<void> loadNotifications() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _notifications = await _service.getAll();
      _unreadCount = await _service.getUnreadCount();

      _isLoading = false;
      notifyListeners();
    } catch (e, stackTrace) {
      _isLoading = false;
      _errorMessage = 'Failed to load notifications';
      notifyListeners();
      Logger.error('Failed to load notifications', e, stackTrace);
    }
  }

  Future<void> refresh() async {
    await loadNotifications();
  }

  Future<void> markAsRead(String id) async {
    try {
      await _service.markAsRead(id);
      final idx = _notifications.indexWhere((n) => n.id == id);
      if (idx != -1) {
        _notifications[idx] = _notifications[idx].markAsRead();
        _unreadCount = _notifications.where((n) => !n.isRead).length;
        notifyListeners();
      }
    } catch (e, stackTrace) {
      Logger.error('Failed to mark notification as read', e, stackTrace);
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _service.markAllAsRead();
      _notifications = _notifications.map((n) => n.markAsRead()).toList();
      _unreadCount = 0;
      notifyListeners();
    } catch (e, stackTrace) {
      Logger.error('Failed to mark all as read', e, stackTrace);
    }
  }

  Future<void> deleteNotification(String id) async {
    try {
      await _service.deleteNotification(id);
      _notifications.removeWhere((n) => n.id == id);
      _unreadCount = _notifications.where((n) => !n.isRead).length;
      notifyListeners();
    } catch (e, stackTrace) {
      _errorMessage = 'Failed to delete notification';
      notifyListeners();
      Logger.error('Failed to delete notification', e, stackTrace);
    }
  }

  Future<void> deleteAll() async {
    try {
      await _service.deleteAll();
      _notifications.clear();
      _unreadCount = 0;
      notifyListeners();
    } catch (e, stackTrace) {
      _errorMessage = 'Failed to delete all notifications';
      notifyListeners();
      Logger.error('Failed to delete all', e, stackTrace);
    }
  }

  void filterByCategory(NotificationCategory? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void search(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void createNotificationLocally(NotificationModel notification) {
    _notifications.insert(0, notification);
    if (!notification.isRead) _unreadCount++;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
