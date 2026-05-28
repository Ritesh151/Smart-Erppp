import 'dart:convert';
import 'dart:io';

import 'package:SmartERP/core/models/backup_model.dart';
import 'package:SmartERP/core/models/notification_model.dart';
import 'package:SmartERP/core/storage/storage_service.dart';
import 'package:SmartERP/core/utils/logger.dart';
import 'package:SmartERP/modules/settings/repositories/backup_repository.dart';
import 'package:SmartERP/modules/settings/services/notification_service.dart';

class RestoreResult {
  final bool success;
  final int modulesRestored;
  final int recordsRestored;
  final List<String> errors;
  final String? backupName;

  RestoreResult({
    required this.success,
    this.modulesRestored = 0,
    this.recordsRestored = 0,
    this.errors = const [],
    this.backupName,
  });
}

class RestoreService {
  final BackupRepository _backupRepository;
  final NotificationService _notificationService;
  final StorageService<Map<dynamic, dynamic>> _productsStorage;
  final StorageService<Map<dynamic, dynamic>> _transactionsStorage;
  final StorageService<Map<dynamic, dynamic>> _invoicesStorage;
  final StorageService<Map<dynamic, dynamic>> _customersStorage;
  final StorageService<Map<dynamic, dynamic>> _transportsStorage;
  final StorageService<Map<dynamic, dynamic>> _vehiclesStorage;
  final StorageService<Map<dynamic, dynamic>> _employeesStorage;
  final StorageService<Map<dynamic, dynamic>> _attendanceStorage;
  final StorageService<Map<dynamic, dynamic>> _salariesStorage;

  RestoreService({
    required BackupRepository backupRepository,
    required NotificationService notificationService,
    required StorageService<Map<dynamic, dynamic>> productsStorage,
    required StorageService<Map<dynamic, dynamic>> transactionsStorage,
    required StorageService<Map<dynamic, dynamic>> invoicesStorage,
    required StorageService<Map<dynamic, dynamic>> customersStorage,
    required StorageService<Map<dynamic, dynamic>> transportsStorage,
    required StorageService<Map<dynamic, dynamic>> vehiclesStorage,
    required StorageService<Map<dynamic, dynamic>> employeesStorage,
    required StorageService<Map<dynamic, dynamic>> attendanceStorage,
    required StorageService<Map<dynamic, dynamic>> salariesStorage,
  })  : _backupRepository = backupRepository,
        _notificationService = notificationService,
        _productsStorage = productsStorage,
        _transactionsStorage = transactionsStorage,
        _invoicesStorage = invoicesStorage,
        _customersStorage = customersStorage,
        _transportsStorage = transportsStorage,
        _vehiclesStorage = vehiclesStorage,
        _employeesStorage = employeesStorage,
        _attendanceStorage = attendanceStorage,
        _salariesStorage = salariesStorage;

  Future<RestoreResult> restoreFromBackup(String backupId) async {
    Logger.info('Starting restore from backup: $backupId');

    final backup = await _backupRepository.getById(backupId);
    if (backup == null) {
      return RestoreResult(
        success: false,
        errors: ['Backup not found: $backupId'],
      );
    }

    return _performRestore(backup);
  }

  Future<RestoreResult> restoreFromFile(String filePath) async {
    Logger.info('Starting restore from file: $filePath');

    final file = File(filePath);
    if (!await file.exists()) {
      return RestoreResult(
        success: false,
        errors: ['File not found: $filePath'],
      );
    }

    final jsonString = await file.readAsString();
    Map<String, dynamic> data;
    try {
      data = json.decode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      return RestoreResult(
        success: false,
        errors: ['Invalid backup file: $e'],
      );
    }

    final errors = <String>[];
    int restored = 0;

    final storageMap = <String, StorageService<Map<dynamic, dynamic>>>{
      'products': _productsStorage,
      'transactions': _transactionsStorage,
      'invoices': _invoicesStorage,
      'customers': _customersStorage,
      'transports': _transportsStorage,
      'vehicles': _vehiclesStorage,
      'employees': _employeesStorage,
      'attendance': _attendanceStorage,
      'salaries': _salariesStorage,
    };

    for (final entry in data.entries) {
      if (entry.value == null) continue;

      final storage = storageMap[entry.key];
      if (storage == null) {
        if (entry.key != 'settings') {
          errors.add('Unknown module: ${entry.key}');
        }
        continue;
      }

      try {
        if (entry.value is List) {
          final items = entry.value as List;
          for (final item in items) {
            if (item is Map) {
              final id = item['id']?.toString() ?? _generateId();
              await storage.save(id, Map<String, dynamic>.from(item));
              restored++;
            }
          }
        }
      } catch (e, stackTrace) {
        Logger.error('Failed to restore module: ${entry.key}', e, stackTrace);
        errors.add('${entry.key}: $e');
      }
    }

    Logger.success('Restore completed: $restored records from file');
    return RestoreResult(
      success: errors.isEmpty,
      modulesRestored: data.length,
      recordsRestored: restored,
      errors: errors,
    );
  }

  Future<RestoreResult> _performRestore(BackupModel backup) async {
    try {
      await _backupRepository.update(
        backup.copyWith(status: BackupStatus.restoring),
      );

      final result = await restoreFromFile(backup.filePath);

      if (result.success) {
        await _backupRepository.update(
          backup.copyWith(
            status: BackupStatus.completed,
            restoredAt: DateTime.now(),
          ),
        );
        await _notificationService.createNotification(
          title: 'Restore Complete',
          message: 'Restored ${result.recordsRestored} records from "${backup.name}"',
          category: NotificationCategory.backup,
          priority: NotificationPriority.medium,
        );
      } else {
        await _backupRepository.update(
          backup.copyWith(status: BackupStatus.failed),
        );
      }

      return result;
    } catch (e, stackTrace) {
      Logger.error('Restore failed', e, stackTrace);
      await _backupRepository.update(
        backup.copyWith(status: BackupStatus.failed),
      );
      return RestoreResult(
        success: false,
        errors: ['Restore failed: $e'],
        backupName: backup.name,
      );
    }
  }

  String _generateId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'RESTORE-$timestamp';
  }
}
