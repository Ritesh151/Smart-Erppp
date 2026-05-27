import 'package:flutter/foundation.dart';
import 'package:smarterp/core/models/preferences_model.dart';
import 'package:smarterp/core/utils/logger.dart';
import 'package:smarterp/modules/settings/services/preferences_service.dart';

class PreferencesProvider extends ChangeNotifier {
  final PreferencesService _service;

  PreferencesProvider(this._service);

  PreferencesModel? _preferences;
  bool _isLoading = false;
  String? _errorMessage;

  PreferencesModel? get preferences => _preferences;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  String get themeName => _preferences?.themeName ?? 'light';
  String get dateFormat => _preferences?.dateFormat ?? 'dd/MM/yyyy';
  bool get sidebarCollapsed => _preferences?.sidebarCollapsed ?? false;
  bool get notificationsEnabled => _preferences?.notificationsEnabled ?? true;
  int get itemsPerPage => _preferences?.itemsPerPage ?? 20;
  int get lowStockThreshold => _preferences?.lowStockThreshold ?? 10;
  List<String> get favoriteModules => _preferences?.favoriteModules ?? [];
  String? get lastUsedModule => _preferences?.lastUsedModule;

  Future<void> loadPreferences() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _preferences = await _service.getPreferences();

      _isLoading = false;
      notifyListeners();
    } catch (e, stackTrace) {
      _isLoading = false;
      _errorMessage = 'Failed to load preferences';
      notifyListeners();
      Logger.error('Failed to load preferences', e, stackTrace);
    }
  }

  Future<void> updateThemePreference(String themeName) async {
    await _service.updateThemePreference(themeName);
    _preferences = await _service.getPreferences();
    notifyListeners();
  }

  Future<void> updateDateFormat(String format) async {
    await _service.updateDateFormat(format);
    _preferences = await _service.getPreferences();
    notifyListeners();
  }

  Future<void> updateSidebarCollapsed(bool collapsed) async {
    await _service.updateSidebarCollapsed(collapsed);
    _preferences = await _service.getPreferences();
    notifyListeners();
  }

  Future<void> toggleModuleFavorite(String moduleName) async {
    await _service.toggleModuleFavorite(moduleName);
    _preferences = await _service.getPreferences();
    notifyListeners();
  }

  Future<void> updateLastUsedModule(String moduleName) async {
    await _service.updateLastUsedModule(moduleName);
    _preferences = await _service.getPreferences();
  }

  Future<void> updateLanguage(String language) async {
    await _service.updateLanguage(language);
    _preferences = await _service.getPreferences();
    notifyListeners();
  }

  Future<void> updateNotificationsEnabled(bool enabled) async {
    await _service.updateNotificationsEnabled(enabled);
    _preferences = await _service.getPreferences();
    notifyListeners();
  }

  Future<void> updateLowStockThreshold(int threshold) async {
    await _service.updateLowStockThreshold(threshold);
    _preferences = await _service.getPreferences();
    notifyListeners();
  }

  Future<void> updateItemsPerPage(int count) async {
    await _service.updateItemsPerPage(count);
    _preferences = await _service.getPreferences();
    notifyListeners();
  }

  bool isModuleFavorite(String moduleName) {
    return _preferences?.isModuleFavorite(moduleName) ?? false;
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void invalidateCache() {
    _service.invalidateCache();
    _preferences = null;
  }
}
