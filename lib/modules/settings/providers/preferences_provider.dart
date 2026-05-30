import 'package:flutter/foundation.dart';
import 'package:SmartERP/core/utils/logger.dart';
import 'package:SmartERP/modules/settings/services/preferences_service.dart';

class PreferencesProvider extends ChangeNotifier {
  final PreferencesService _service;

  PreferencesProvider(this._service);

  String? _dateFormat;
  bool _sidebarCollapsed = false;
  bool _notificationsEnabled = true;
  int _itemsPerPage = 20;
  bool _isLoading = false;

  String? get dateFormat => _dateFormat;
  bool get sidebarCollapsed => _sidebarCollapsed;
  bool get notificationsEnabled => _notificationsEnabled;
  int get itemsPerPage => _itemsPerPage;
  bool get isLoading => _isLoading;

  Future<void> loadPreferences() async {
    try {
      _isLoading = true;
      notifyListeners();

      await _service.getPreferences();
      _dateFormat = _service.getCurrentDateFormat();
      _sidebarCollapsed = _service.isSidebarCollapsed();
      _notificationsEnabled = _service.isNotificationsEnabled();
      _itemsPerPage = _service.getItemsPerPage();

      _isLoading = false;
      notifyListeners();
      Logger.success('Preferences loaded');
    } catch (e, stackTrace) {
      _isLoading = false;
      notifyListeners();
      Logger.error('Failed to load preferences', e, stackTrace);
    }
  }

  Future<void> updateSidebarCollapsed(bool collapsed) async {
    try {
      await _service.updateSidebarCollapsed(collapsed);
      _sidebarCollapsed = collapsed;
      notifyListeners();
    } catch (e, stackTrace) {
      Logger.error('Failed to update sidebar', e, stackTrace);
    }
  }

  Future<void> updateNotificationsEnabled(bool enabled) async {
    try {
      await _service.updateNotificationsEnabled(enabled);
      _notificationsEnabled = enabled;
      notifyListeners();
    } catch (e, stackTrace) {
      Logger.error('Failed to update notifications', e, stackTrace);
    }
  }

  Future<void> updateItemsPerPage(int count) async {
    try {
      await _service.updateItemsPerPage(count);
      _itemsPerPage = count;
      notifyListeners();
    } catch (e, stackTrace) {
      Logger.error('Failed to update items per page', e, stackTrace);
    }
  }
}
