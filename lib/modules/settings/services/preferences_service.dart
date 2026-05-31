import '../../../core/constants/storage_keys.dart';
import '../../../core/models/preferences_model.dart';
import '../../../core/storage/preferences_service.dart' as pref;
import '../../../core/utils/logger.dart';

class PreferencesService {
  PreferencesService({required pref.PreferencesService preferencesService})
      : _preferences = preferencesService;

  final pref.PreferencesService _preferences;
  PreferencesModel? _cached;

  Future<PreferencesModel> getPreferences() async {
    try {
      if (_cached != null) {
        return _cached!;
      }
      return await _loadPreferences();
    } on Exception catch (e, stackTrace) {
      Logger.error('Failed to get preferences', e, stackTrace);
      rethrow;
    }
  }

  Future<PreferencesModel> _loadPreferences() async {
    final sidebarCollapsed = _preferences.getBool(
      StorageKeys.sidebarCollapsed,
      defaultValue: false,
    )!;

    _cached = PreferencesModel.create(
      userId: 'default',
      sidebarCollapsed: sidebarCollapsed,
      dateFormat: _preferences.getString(
        StorageKeys.language,
        defaultValue: 'dd/MM/yyyy',
      )!,
      language: _preferences.getString(
        StorageKeys.language,
        defaultValue: 'en',
      )!,
    );
    return _cached!;
  }

  Future<void> updateSidebarCollapsed({required bool collapsed}) async {
    try {
      await _preferences.setBool(StorageKeys.sidebarCollapsed, collapsed);
      _cached = _cached?.copyWith(
        sidebarCollapsed: collapsed,
        updatedAt: DateTime.now(),
      );
    } on Exception catch (e, stackTrace) {
      Logger.error('Failed to update sidebar preference', e, stackTrace);
    }
  }

  Future<void> toggleModuleFavorite(String moduleName) async {
    try {
      final prefs = await getPreferences();
      _cached = prefs.toggleFavorite(moduleName);
      Logger.info('Favorite module toggled: $moduleName');
    } on Exception catch (e, stackTrace) {
      Logger.error('Failed to toggle favorite module', e, stackTrace);
    }
  }

  Future<void> updateLastUsedModule(String moduleName) async {
    try {
      final prefs = await getPreferences();
      _cached = prefs.copyWith(
        lastUsedModule: moduleName,
        updatedAt: DateTime.now(),
      );
    } on Exception catch (e, stackTrace) {
      Logger.error('Failed to update last used module', e, stackTrace);
    }
  }

  Future<void> updateLanguage(String language) async {
    try {
      await _preferences.setString(StorageKeys.language, language);
      final prefs = await getPreferences();
      _cached = prefs.copyWith(language: language, updatedAt: DateTime.now());
      Logger.info('Language preference updated: $language');
    } on Exception catch (e, stackTrace) {
      Logger.error('Failed to update language preference', e, stackTrace);
    }
  }

  Future<void> updateNotificationsEnabled({required bool enabled}) async {
    try {
      final prefs = await getPreferences();
      _cached = prefs.copyWith(
        notificationsEnabled: enabled,
        updatedAt: DateTime.now(),
      );
      Logger.info('Notifications preference: $enabled');
    } on Exception catch (e, stackTrace) {
      Logger.error('Failed to update notifications preference', e, stackTrace);
    }
  }

  Future<void> updateLowStockThreshold(int threshold) async {
    try {
      final prefs = await getPreferences();
      _cached = prefs.copyWith(
        lowStockThreshold: threshold,
        updatedAt: DateTime.now(),
      );
      Logger.info('Low stock threshold preference: $threshold');
    } on Exception catch (e, stackTrace) {
      Logger.error('Failed to update low stock threshold', e, stackTrace);
    }
  }

  Future<void> updateItemsPerPage(int count) async {
    try {
      final prefs = await getPreferences();
      _cached = prefs.copyWith(itemsPerPage: count, updatedAt: DateTime.now());
    } on Exception catch (e, stackTrace) {
      Logger.error('Failed to update items per page', e, stackTrace);
    }
  }

  String getCurrentDateFormat() => _cached?.dateFormat ?? 'dd/MM/yyyy';

  bool isSidebarCollapsed() => _cached?.sidebarCollapsed ?? false;

  bool isNotificationsEnabled() => _cached?.notificationsEnabled ?? true;

  int getItemsPerPage() => _cached?.itemsPerPage ?? 20;

  void invalidateCache() {
    _cached = null;
  }
}
