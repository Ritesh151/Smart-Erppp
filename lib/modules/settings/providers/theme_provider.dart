import 'package:flutter/material.dart';
import 'package:SmartERP/core/constants/storage_keys.dart';
import 'package:SmartERP/core/storage/preferences_service.dart';
import 'package:SmartERP/core/theme/app_theme.dart';
import 'package:SmartERP/core/utils/logger.dart';

class ThemeProvider extends ChangeNotifier {
  final PreferencesService _preferencesService;
  AppThemeMode _currentTheme = AppThemeMode.light;

  ThemeProvider(this._preferencesService);

  AppThemeMode get currentTheme => _currentTheme;

  ThemeData get themeData => AppTheme.getTheme(_currentTheme);

  Future<void> initialize() async {
    try {
      final themeName = _preferencesService.getString(
        StorageKeys.selectedTheme,
        defaultValue: AppThemeMode.light.name,
      );

      _currentTheme = AppThemeMode.values.firstWhere(
        (theme) => theme.name == themeName,
        orElse: () => AppThemeMode.light,
      );

      Logger.info('Theme initialized: ${_currentTheme.name}');
      notifyListeners();
    } catch (e, stackTrace) {
      Logger.error('Failed to initialize theme', e, stackTrace);
    }
  }

  Future<void> setTheme(AppThemeMode theme) async {
    try {
      _currentTheme = theme;
      await _preferencesService.setString(
        StorageKeys.selectedTheme,
        theme.name,
      );
      Logger.info('Theme changed to: ${theme.name}');
      notifyListeners();
    } catch (e, stackTrace) {
      Logger.error('Failed to set theme', e, stackTrace);
    }
  }

  void toggleTheme() {
    if (_currentTheme == AppThemeMode.light) {
      setTheme(AppThemeMode.dark);
    } else {
      setTheme(AppThemeMode.light);
    }
  }
}
