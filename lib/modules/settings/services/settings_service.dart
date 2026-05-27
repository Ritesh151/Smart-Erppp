import 'package:smarterp/core/constants/storage_keys.dart';
import 'package:smarterp/core/exceptions/app_exception.dart';
import 'package:smarterp/core/models/settings_model.dart';
import 'package:smarterp/core/storage/preferences_service.dart';
import 'package:smarterp/core/utils/logger.dart';
import 'package:smarterp/modules/settings/repositories/settings_repository.dart';

class SettingsService {
  final SettingsRepository _repository;
  final PreferencesService _preferencesService;

  SettingsService({
    required SettingsRepository repository,
    required PreferencesService preferencesService,
  })  : _repository = repository,
        _preferencesService = preferencesService;

  Future<SettingsModel?> getSettings() async {
    try {
      return await _repository.getLatest();
    } catch (e, stackTrace) {
      Logger.error('Failed to get settings', e, stackTrace);
      return null;
    }
  }

  Future<SettingsModel> ensureSettings() async {
    try {
      final existing = await _repository.getLatest();
      if (existing != null) return existing;
      return await _createDefault();
    } catch (e, stackTrace) {
      Logger.error('Failed to ensure settings exist', e, stackTrace);
      rethrow;
    }
  }

  Future<SettingsModel> _createDefault() async {
    try {
      final settings = SettingsModel.create(
        companyName: 'My Company',
        dateFormat: 'dd/MM/yyyy',
        lowStockThreshold: 10,
        salaryReminderEnabled: true,
      );
      await _repository.save(settings);
      Logger.success('Default settings created');
      return settings;
    } catch (e, stackTrace) {
      Logger.error('Failed to create default settings', e, stackTrace);
      rethrow;
    }
  }

  Future<SettingsModel> updateSettings(SettingsModel settings) async {
    try {
      final updated = settings.copyWith(updatedAt: DateTime.now());
      await _repository.update(updated);

      await _preferencesService.setString(
        StorageKeys.selectedTheme,
        updated.dateFormat,
      );

      Logger.success('Settings updated');
      return updated;
    } catch (e, stackTrace) {
      Logger.error('Failed to update settings', e, stackTrace);
      throw StorageException('Failed to update settings');
    }
  }

  Future<void> updateDateFormat(String format) async {
    try {
      final settings = await ensureSettings();
      await updateSettings(settings.copyWith(dateFormat: format));
      Logger.info('Date format updated to: $format');
    } catch (e, stackTrace) {
      Logger.error('Failed to update date format', e, stackTrace);
    }
  }

  Future<void> updateLowStockThreshold(int threshold) async {
    try {
      final settings = await ensureSettings();
      await updateSettings(settings.copyWith(
        lowStockThreshold: threshold,
      ));
      Logger.info('Low stock threshold updated to: $threshold');
    } catch (e, stackTrace) {
      Logger.error('Failed to update low stock threshold', e, stackTrace);
    }
  }

  Future<void> toggleSalaryReminder(bool enabled) async {
    try {
      final settings = await ensureSettings();
      await updateSettings(settings.copyWith(
        salaryReminderEnabled: enabled,
      ));
      Logger.info('Salary reminder ${enabled ? 'enabled' : 'disabled'}');
    } catch (e, stackTrace) {
      Logger.error('Failed to toggle salary reminder', e, stackTrace);
    }
  }

  Future<void> toggleAutoBackup(bool enabled) async {
    try {
      final settings = await ensureSettings();
      await updateSettings(settings.copyWith(
        autoBackupEnabled: enabled,
        autoBackupIntervalDays: settings.autoBackupIntervalDays,
      ));
      Logger.info('Auto backup ${enabled ? 'enabled' : 'disabled'}');
    } catch (e, stackTrace) {
      Logger.error('Failed to toggle auto backup', e, stackTrace);
    }
  }

  Future<void> toggleNotifications(bool enabled) async {
    try {
      final settings = await ensureSettings();
      await updateSettings(settings.copyWith(
        notificationsEnabled: enabled,
      ));
      Logger.info('Notifications ${enabled ? 'enabled' : 'disabled'}');
    } catch (e, stackTrace) {
      Logger.error('Failed to toggle notifications', e, stackTrace);
    }
  }

  Future<bool> isSalaryReminderEnabled() async {
    try {
      final settings = await getSettings();
      return settings?.salaryReminderEnabled ?? true;
    } catch (e) {
      return true;
    }
  }

  Future<int> getLowStockThreshold() async {
    try {
      final settings = await getSettings();
      return settings?.lowStockThreshold ?? 10;
    } catch (e) {
      return 10;
    }
  }

  Future<String> getDateFormat() async {
    try {
      final settings = await getSettings();
      return settings?.dateFormat ?? 'dd/MM/yyyy';
    } catch (e) {
      return 'dd/MM/yyyy';
    }
  }

  Future<void> updateCompanyInfo({
    required String companyName,
    String? address,
    String? phone,
    String? email,
    String? taxId,
  }) async {
    try {
      final settings = await ensureSettings();
      await updateSettings(settings.copyWith(
        companyName: companyName,
        companyAddress: address ?? settings.companyAddress,
        companyPhone: phone ?? settings.companyPhone,
        companyEmail: email ?? settings.companyEmail,
        taxId: taxId ?? settings.taxId,
      ));
      Logger.success('Company info updated');
    } catch (e, stackTrace) {
      Logger.error('Failed to update company info', e, stackTrace);
      throw StorageException('Failed to update company info');
    }
  }

  Future<void> resetToDefaults() async {
    try {
      final existing = await _repository.getLatest();
      if (existing != null) {
        await _repository.delete(existing.id);
      }
      await _createDefault();
      Logger.info('Settings reset to defaults');
    } catch (e, stackTrace) {
      Logger.error('Failed to reset settings', e, stackTrace);
      throw StorageException('Failed to reset settings');
    }
  }
}
