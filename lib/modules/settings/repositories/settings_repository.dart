import 'package:SmartERP/core/exceptions/app_exception.dart';
import 'package:SmartERP/core/models/settings_model.dart';
import 'package:SmartERP/core/storage/storage_service.dart';
import 'package:SmartERP/core/utils/logger.dart';

class SettingsRepository {
  final StorageService<Map<dynamic, dynamic>> _storage;

  SettingsRepository({
    required StorageService<Map<dynamic, dynamic>> storage,
  }) : _storage = storage;

  Future<List<SettingsModel>> getAll() async {
    try {
      final data = _storage.getAll();
      return data
          .map((item) => SettingsModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } catch (e, stackTrace) {
      Logger.error('Failed to get all settings', e, stackTrace);
      throw StorageException('Failed to retrieve settings');
    }
  }

  Future<SettingsModel?> getById(String id) async {
    try {
      final data = _storage.get(id);
      if (data == null) return null;
      return SettingsModel.fromJson(Map<String, dynamic>.from(data));
    } catch (e, stackTrace) {
      Logger.error('Failed to get settings by id: $id', e, stackTrace);
      return null;
    }
  }

  Future<SettingsModel?> getLatest() async {
    try {
      final all = await getAll();
      if (all.isEmpty) return null;
      all.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      return all.first;
    } catch (e, stackTrace) {
      Logger.error('Failed to get latest settings', e, stackTrace);
      return null;
    }
  }

  Future<void> save(SettingsModel settings) async {
    try {
      await _storage.save(settings.id, settings.toJson());
      Logger.success('Settings saved: ${settings.companyName}');
    } catch (e, stackTrace) {
      Logger.error('Failed to save settings', e, stackTrace);
      throw StorageException('Failed to save settings');
    }
  }

  Future<void> update(SettingsModel settings) async {
    try {
      await _storage.save(settings.id, settings.toJson());
      Logger.success('Settings updated: ${settings.companyName}');
    } catch (e, stackTrace) {
      Logger.error('Failed to update settings', e, stackTrace);
      throw StorageException('Failed to update settings');
    }
  }

  Future<void> delete(String id) async {
    try {
      await _storage.delete(id);
      Logger.success('Settings deleted: $id');
    } catch (e, stackTrace) {
      Logger.error('Failed to delete settings', e, stackTrace);
      throw StorageException('Failed to delete settings');
    }
  }

  Future<void> clear() async {
    try {
      final all = await getAll();
      for (final item in all) {
        await _storage.delete(item.id);
      }
      Logger.success('All settings cleared');
    } catch (e, stackTrace) {
      Logger.error('Failed to clear settings', e, stackTrace);
      throw StorageException('Failed to clear settings');
    }
  }

  Future<bool> exists() async {
    try {
      final all = await getAll();
      return all.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}
