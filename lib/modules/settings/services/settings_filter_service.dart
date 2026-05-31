import '../../../core/models/backup_model.dart';
import '../../../core/models/notification_model.dart';
import '../../../core/utils/logger.dart';
import '../../../modules/settings/repositories/backup_repository.dart';
import '../../../modules/settings/repositories/notification_repository.dart';

class NotificationFilter {
  NotificationFilter({
    this.category,
    this.priority,
    this.isRead,
    this.startDate,
    this.endDate,
    this.keyword,
  });

  final NotificationCategory? category;
  final NotificationPriority? priority;
  final bool? isRead;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? keyword;

  bool get hasActiveFilters =>
    category != null ||
    priority != null ||
    isRead != null ||
    startDate != null ||
    endDate != null ||
    (keyword != null && keyword!.isNotEmpty);
}

class BackupFilter {
  BackupFilter({
    this.type,
    this.status,
    this.startDate,
    this.endDate,
    this.keyword,
    this.isEncrypted,
  });

  final BackupType? type;
  final BackupStatus? status;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? keyword;
  final bool? isEncrypted;

  bool get hasActiveFilters =>
    type != null ||
    status != null ||
    startDate != null ||
    endDate != null ||
    (keyword != null && keyword!.isNotEmpty) ||
    isEncrypted != null;
}

class SettingsFilterService {
  SettingsFilterService({
    required NotificationRepository notificationRepository,
    required BackupRepository backupRepository,
  })  : _notificationRepository = notificationRepository,
        _backupRepository = backupRepository;

  final NotificationRepository _notificationRepository;
  final BackupRepository _backupRepository;

  Future<List<NotificationModel>> filterNotifications(NotificationFilter filter) async {
    try {
      var results = await _notificationRepository.getAll();

      if (filter.category != null) {
        results = results.where((n) => n.category == filter.category).toList();
      }

      if (filter.priority != null) {
        results = results.where((n) => n.priority == filter.priority).toList();
      }

      if (filter.isRead != null) {
        results = results.where((n) => n.isRead == filter.isRead).toList();
      }

      if (filter.startDate != null) {
        results = results.where((n) =>
            n.createdAt.isAfter(filter.startDate!.subtract(const Duration(days: 1)))).toList();
      }

      if (filter.endDate != null) {
        results = results.where((n) =>
            n.createdAt.isBefore(filter.endDate!.add(const Duration(days: 1)))).toList();
      }

      if (filter.keyword != null && filter.keyword!.isNotEmpty) {
        final q = filter.keyword!.toLowerCase();
        results = results.where((n) =>
            n.title.toLowerCase().contains(q) ||
            n.message.toLowerCase().contains(q)).toList();
      }

      results.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return results;
    } on Exception catch (e, stackTrace) {
      Logger.error('Failed to filter notifications', e, stackTrace);
      return [];
    }
  }

  Future<List<BackupModel>> filterBackups(BackupFilter filter) async {
    try {
      var results = await _backupRepository.getAll();

      if (filter.type != null) {
        results = results.where((b) => b.type == filter.type).toList();
      }

      if (filter.status != null) {
        results = results.where((b) => b.status == filter.status).toList();
      }

      if (filter.isEncrypted != null) {
        results = results.where((b) => b.isEncrypted == filter.isEncrypted).toList();
      }

      if (filter.startDate != null) {
        results = results.where((b) =>
            b.createdAt.isAfter(filter.startDate!.subtract(const Duration(days: 1)))).toList();
      }

      if (filter.endDate != null) {
        results = results.where((b) =>
            b.createdAt.isBefore(filter.endDate!.add(const Duration(days: 1)))).toList();
      }

      if (filter.keyword != null && filter.keyword!.isNotEmpty) {
        final q = filter.keyword!.toLowerCase();
        results = results.where((b) =>
            b.name.toLowerCase().contains(q) ||
            b.description.toLowerCase().contains(q)).toList();
      }

      results.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return results;
    } on Exception catch (e, stackTrace) {
      Logger.error('Failed to filter backups', e, stackTrace);
      return [];
    }
  }

  Future<Map<NotificationCategory, int>> getNotificationCountByCategory() async {
    try {
      final all = await _notificationRepository.getAll();
      final counts = <NotificationCategory, int>{};
      for (final n in all) {
        counts[n.category] = (counts[n.category] ?? 0) + 1;
      }
      return counts;
    } on Exception catch (_) {
      return {};
    }
  }

  Future<Map<BackupStatus, int>> getBackupCountByStatus() async {
    try {
      final all = await _backupRepository.getAll();
      final counts = <BackupStatus, int>{};
      for (final b in all) {
        counts[b.status] = (counts[b.status] ?? 0) + 1;
      }
      return counts;
    } on Exception catch (_) {
      return {};
    }
  }

  Future<Map<BackupType, int>> getBackupCountByType() async {
    try {
      final all = await _backupRepository.getAll();
      final counts = <BackupType, int>{};
      for (final b in all) {
        counts[b.type] = (counts[b.type] ?? 0) + 1;
      }
      return counts;
    } on Exception catch (_) {
      return {};
    }
  }
}
