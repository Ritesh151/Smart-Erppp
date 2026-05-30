import 'package:flutter/foundation.dart';
import 'package:SmartERP/core/models/settings_model.dart';
import 'package:SmartERP/core/utils/logger.dart';
import 'package:SmartERP/modules/settings/services/settings_service.dart';

class SettingsProvider extends ChangeNotifier {
  final SettingsService _service;

  SettingsProvider(this._service);

  SettingsModel? _settings;
  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;
  String? _successMessage;

  SettingsModel? get settings => _settings;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  String get companyName => _settings?.companyName ?? 'My Company';
  String get dateFormat => _settings?.dateFormat ?? 'dd/MM/yyyy';
  int get lowStockThreshold => _settings?.lowStockThreshold ?? 10;
  bool get salaryReminderEnabled => _settings?.salaryReminderEnabled ?? true;
  bool get autoBackupEnabled => _settings?.autoBackupEnabled ?? false;
  bool get notificationsEnabled => _settings?.notificationsEnabled ?? true;
  bool get lowStockAlertsEnabled => _settings?.lowStockAlertsEnabled ?? true;
  String get defaultSalaryPaymentMode => _settings?.defaultSalaryPaymentMode ?? 'Cash';

  Future<void> loadSettings() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _settings = await _service.ensureSettings();

      _isLoading = false;
      notifyListeners();
      Logger.success('Settings loaded');
    } catch (e, stackTrace) {
      _isLoading = false;
      _errorMessage = 'Failed to load settings';
      notifyListeners();
      Logger.error('Failed to load settings', e, stackTrace);
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
      _isSaving = true;
      _errorMessage = null;
      notifyListeners();

      await _service.updateCompanyInfo(
        companyName: companyName,
        address: address,
        phone: phone,
        email: email,
        taxId: taxId,
      );

      _settings = await _service.getSettings();
      _successMessage = 'Company info updated';
      _isSaving = false;
      notifyListeners();
    } catch (e, stackTrace) {
      _isSaving = false;
      _errorMessage = 'Failed to update company info';
      notifyListeners();
      Logger.error('Failed to update company info', e, stackTrace);
    }
  }

  Future<void> updateDateFormat(String format) async {
    try {
      await _service.updateDateFormat(format);
      _settings = await _service.getSettings();
      notifyListeners();
    } catch (e, stackTrace) {
      _errorMessage = 'Failed to update date format';
      notifyListeners();
      Logger.error('Failed to update date format', e, stackTrace);
    }
  }

  Future<void> updateLowStockThreshold(int threshold) async {
    try {
      await _service.updateLowStockThreshold(threshold);
      _settings = await _service.getSettings();
      notifyListeners();
    } catch (e, stackTrace) {
      _errorMessage = 'Failed to update low stock threshold';
      notifyListeners();
      Logger.error('Failed to update threshold', e, stackTrace);
    }
  }

  Future<void> toggleSalaryReminder(bool enabled) async {
    try {
      await _service.toggleSalaryReminder(enabled);
      _settings = await _service.getSettings();
      notifyListeners();
    } catch (e, stackTrace) {
      _errorMessage = 'Failed to toggle salary reminder';
      notifyListeners();
      Logger.error('Failed to toggle salary reminder', e, stackTrace);
    }
  }

  Future<void> toggleAutoBackup(bool enabled) async {
    try {
      await _service.toggleAutoBackup(enabled);
      _settings = await _service.getSettings();
      notifyListeners();
    } catch (e, stackTrace) {
      _errorMessage = 'Failed to toggle auto backup';
      notifyListeners();
      Logger.error('Failed to toggle auto backup', e, stackTrace);
    }
  }

  Future<void> toggleNotifications(bool enabled) async {
    try {
      await _service.toggleNotifications(enabled);
      _settings = await _service.getSettings();
      notifyListeners();
    } catch (e, stackTrace) {
      _errorMessage = 'Failed to toggle notifications';
      notifyListeners();
      Logger.error('Failed to toggle notifications', e, stackTrace);
    }
  }

  Future<void> toggleLowStockAlerts(bool enabled) async {
    try {
      await _service.toggleLowStockAlerts(enabled);
      _settings = await _service.getSettings();
      notifyListeners();
    } catch (e, stackTrace) {
      _errorMessage = 'Failed to toggle low stock alerts';
      notifyListeners();
      Logger.error('Failed to toggle low stock alerts', e, stackTrace);
    }
  }

  Future<void> updateDefaultSalaryPaymentMode(String mode) async {
    try {
      await _service.updateDefaultSalaryPaymentMode(mode);
      _settings = await _service.getSettings();
      notifyListeners();
    } catch (e, stackTrace) {
      _errorMessage = 'Failed to update salary payment mode';
      notifyListeners();
      Logger.error('Failed to update salary payment mode', e, stackTrace);
    }
  }

  Future<void> resetToDefaults() async {
    try {
      _isSaving = true;
      notifyListeners();

      await _service.resetToDefaults();
      _settings = await _service.getSettings();
      _successMessage = 'Settings reset to defaults';

      _isSaving = false;
      notifyListeners();
    } catch (e, stackTrace) {
      _isSaving = false;
      _errorMessage = 'Failed to reset settings';
      notifyListeners();
      Logger.error('Failed to reset settings', e, stackTrace);
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearSuccess() {
    _successMessage = null;
    notifyListeners();
  }
}
