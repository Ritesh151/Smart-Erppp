import 'package:siddhivinayak_enterprise/core/exceptions/app_exception.dart';
import 'package:siddhivinayak_enterprise/core/models/backup_model.dart';
import 'package:siddhivinayak_enterprise/core/storage/storage_service.dart';
import 'package:siddhivinayak_enterprise/core/utils/logger.dart';

class BackupRepository {
  final StorageService<Map<dynamic, dynamic>> _storage;

  BackupRepository({
    required StorageService<Map<dynamic, dynamic>> storage,
  }) : _storage = storage;

  Future<List<BackupModel>> getAll() async {
    try {
      final data = _storage.getAll();
      return data
          .map((item) => BackupModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } catch (e, stackTrace) {
      Logger.error('Failed to get all backups', e, stackTrace);
      throw StorageException('Failed to retrieve backups');
    }
  }

  Future<BackupModel?> getById(String id) async {
    try {
      final data = _storage.get(id);
      if (data == null) return null;
      return BackupModel.fromJson(Map<String, dynamic>.from(data));
    } catch (e, stackTrace) {
      Logger.error('Failed to get backup by id: $id', e, stackTrace);
      return null;
    }
  }

  Future<void> save(BackupModel backup) async {
    try {
      await _storage.save(backup.id, backup.toJson());
      Logger.success('Backup saved: ${backup.name}');
    } catch (e, stackTrace) {
      Logger.error('Failed to save backup', e, stackTrace);
      throw StorageException('Failed to save backup');
    }
  }

  Future<void> update(BackupModel backup) async {
    try {
      await _storage.save(backup.id, backup.toJson());
      Logger.debug('Backup updated: ${backup.name}');
    } catch (e, stackTrace) {
      Logger.error('Failed to update backup', e, stackTrace);
      throw StorageException('Failed to update backup');
    }
  }

  Future<void> delete(String id) async {
    try {
      await _storage.delete(id);
      Logger.success('Backup deleted: $id');
    } catch (e, stackTrace) {
      Logger.error('Failed to delete backup', e, stackTrace);
      throw StorageException('Failed to delete backup');
    }
  }

  Future<List<BackupModel>> getByType(BackupType type) async {
    try {
      final all = await getAll();
      return all.where((b) => b.type == type).toList();
    } catch (e, stackTrace) {
      Logger.error('Failed to get backups by type', e, stackTrace);
      return [];
    }
  }

  Future<List<BackupModel>> getByStatus(BackupStatus status) async {
    try {
      final all = await getAll();
      return all.where((b) => b.status == status).toList();
    } catch (e, stackTrace) {
      Logger.error('Failed to get backups by status', e, stackTrace);
      return [];
    }
  }

  Future<List<BackupModel>> getRecent(int limit) async {
    try {
      final all = await getAll();
      all.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return all.take(limit).toList();
    } catch (e, stackTrace) {
      Logger.error('Failed to get recent backups', e, stackTrace);
      return [];
    }
  }

  Future<List<BackupModel>> getAutomaticBackups() async {
    try {
      final all = await getAll();
      return all.where((b) => b.isAutomatic).toList();
    } catch (e, stackTrace) {
      Logger.error('Failed to get automatic backups', e, stackTrace);
      return [];
    }
  }

  Future<void> deleteOlderThan(int keepCount) async {
    try {
      final all = await getAll();
      all.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      if (all.length <= keepCount) return;
      final toDelete = all.skip(keepCount);
      for (final backup in toDelete) {
        await _storage.delete(backup.id);
      }
      Logger.info('Deleted ${toDelete.length} old backups');
    } catch (e, stackTrace) {
      Logger.error('Failed to delete old backups', e, stackTrace);
    }
  }

  Future<void> deleteAll() async {
    try {
      final all = await getAll();
      for (final item in all) {
        await _storage.delete(item.id);
      }
      Logger.success('All backups deleted');
    } catch (e, stackTrace) {
      Logger.error('Failed to delete all backups', e, stackTrace);
      throw StorageException('Failed to clear backups');
    }
  }

  Future<int> getCount() async {
    try {
      final all = await getAll();
      return all.length;
    } catch (e) {
      return 0;
    }
  }

  Future<double> getTotalSizeBytes() async {
    try {
      final all = await getAll();
      double total = 0;
      for (final b in all) {
        total += b.fileSizeBytes;
      }
      return total;
    } catch (e) {
      return 0;
    }
  }
}
