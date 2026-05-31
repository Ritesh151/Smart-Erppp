import '../../../core/exceptions/app_exception.dart';
import '../../../core/models/settings_model.dart';
import '../../../core/utils/logger.dart';
import '../../../modules/settings/repositories/settings_repository.dart';

class SettingsService {
  SettingsService({
    required SettingsRepository repository,
  }) : _repository = repository;

  final SettingsRepository _repository;

  Future<SettingsModel?> getSettings() async {
    try {
      return await _repository.getLatest();
    } on Exception catch (e, stackTrace) {
      Logger.error('Failed to get settings', e, stackTrace);
      return null;
    }
  }

  Future<SettingsModel> ensureSettings() async {
    try {
      final existing = await _repository.getLatest();
      if (existing != null) {
        return existing;
      }
      return await _createDefault();
    } on Exception catch (e, stackTrace) {
      Logger.error('Failed to ensure settings exist', e, stackTrace);
      rethrow;
    }
  }

  Future<SettingsModel> _createDefault() async {
    try {
      final settings = SettingsModel.create(
        companyName: 'My Company',
      );
      await _repository.save(settings);
      Logger.success('Default settings created');
      return settings;
    } on Exception catch (e, stackTrace) {
      Logger.error('Failed to create default settings', e, stackTrace);
      rethrow;
    }
  }

  Future<SettingsModel> updateSettings(SettingsModel settings) async {
    try {
      final updated = settings.copyWith(updatedAt: DateTime.now());
      await _repository.update(updated);
      Logger.success('Settings updated');
      return updated;
    } on Exception catch (e, stackTrace) {
      Logger.error('Failed to update settings', e, stackTrace);
      throw StorageException('Failed to update settings');
    }
  }

  Future<void> updateDateFormat(String format) async {
    try {
      final settings = await ensureSettings();
      await updateSettings(settings.copyWith(dateFormat: format));
      Logger.info('Date format updated to: $format');
    } on Exception catch (e, stackTrace) {
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
    } on Exception catch (e, stackTrace) {
      Logger.error('Failed to update low stock threshold', e, stackTrace);
    }
  }

  Future<void> toggleSalaryReminder({required bool enabled}) async {
    try {
      final settings = await ensureSettings();
      await updateSettings(settings.copyWith(
        salaryReminderEnabled: enabled,
      ));
      Logger.info('Salary reminder ${enabled ? 'enabled' : 'disabled'}');
    } on Exception catch (e, stackTrace) {
      Logger.error('Failed to toggle salary reminder', e, stackTrace);
    }
  }

  Future<void> toggleAutoBackup({required bool enabled}) async {
    try {
      final settings = await ensureSettings();
      await updateSettings(settings.copyWith(
        autoBackupEnabled: enabled,
        autoBackupIntervalDays: settings.autoBackupIntervalDays,
      ));
      Logger.info('Auto backup ${enabled ? 'enabled' : 'disabled'}');
    } on Exception catch (e, stackTrace) {
      Logger.error('Failed to toggle auto backup', e, stackTrace);
    }
  }

  Future<void> toggleNotifications({required bool enabled}) async {
    try {
      final settings = await ensureSettings();
      await updateSettings(settings.copyWith(
        notificationsEnabled: enabled,
      ));
      Logger.info('Notifications ${enabled ? 'enabled' : 'disabled'}');
    } on Exception catch (e, stackTrace) {
      Logger.error('Failed to toggle notifications', e, stackTrace);
    }
  }

  Future<bool> isSalaryReminderEnabled() async {
    try {
      final settings = await getSettings();
      return settings?.salaryReminderEnabled ?? true;
    } on Exception catch (_) {
      return true;
    }
  }

  Future<bool> isLowStockAlertsEnabled() async {
    try {
      final settings = await getSettings();
      return settings?.lowStockAlertsEnabled ?? true;
    } on Exception catch (_) {
      return true;
    }
  }

  Future<String> getDefaultSalaryPaymentMode() async {
    try {
      final settings = await getSettings();
      return settings?.defaultSalaryPaymentMode ?? 'Cash';
    } on Exception catch (_) {
      return 'Cash';
    }
  }

  Future<int> getLowStockThreshold() async {
    try {
      final settings = await getSettings();
      return settings?.lowStockThreshold ?? 10;
    } on Exception catch (_) {
      return 10;
    }
  }

  Future<String> getDateFormat() async {
    try {
      final settings = await getSettings();
      return settings?.dateFormat ?? 'dd/MM/yyyy';
    } on Exception catch (_) {
      return 'dd/MM/yyyy';
    }
  }

  Future<void> toggleLowStockAlerts({required bool enabled}) async {
    try {
      final settings = await ensureSettings();
      await updateSettings(settings.copyWith(
        lowStockAlertsEnabled: enabled,
      ));
      Logger.info('Low stock alerts ${enabled ? 'enabled' : 'disabled'}');
    } on Exception catch (e, stackTrace) {
      Logger.error('Failed to toggle low stock alerts', e, stackTrace);
    }
  }

  Future<void> updateDefaultSalaryPaymentMode(String mode) async {
    try {
      final settings = await ensureSettings();
      await updateSettings(settings.copyWith(
        defaultSalaryPaymentMode: mode,
      ));
      Logger.info('Default salary payment mode updated to: $mode');
    } on Exception catch (e, stackTrace) {
      Logger.error('Failed to update default salary payment mode', e, stackTrace);
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
    } on Exception catch (e, stackTrace) {
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
    } on Exception catch (e, stackTrace) {
      Logger.error('Failed to reset settings', e, stackTrace);
      throw StorageException('Failed to reset settings');
    }
  }
}
