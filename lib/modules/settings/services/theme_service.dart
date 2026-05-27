import 'package:flutter/material.dart';
import 'package:smarterp/core/constants/storage_keys.dart';
import 'package:smarterp/core/models/theme_model.dart';
import 'package:smarterp/core/storage/preferences_service.dart';
import 'package:smarterp/core/theme/app_theme.dart';
import 'package:smarterp/core/utils/logger.dart';

class ThemeService {
  final PreferencesService _preferencesService;

  ThemeService({required PreferencesService preferencesService})
      : _preferencesService = preferencesService;

  ThemeData getThemeData(String themeName) {
    final mode = _parseThemeMode(themeName);
    return AppTheme.getTheme(mode);
  }

  Future<ThemeModel?> getCurrentThemeModel() async {
    try {
      final themeName = _preferencesService.getString(
        StorageKeys.selectedTheme,
        defaultValue: AppThemeMode.light.name,
      );
      return _getThemeModelByName(themeName!);
    } catch (e, stackTrace) {
      Logger.error('Failed to get current theme model', e, stackTrace);
      return ThemeModel.light;
    }
  }

  Future<String> getCurrentThemeName() async {
    try {
      return _preferencesService.getString(
        StorageKeys.selectedTheme,
        defaultValue: AppThemeMode.light.name,
      )!;
    } catch (e) {
      return AppThemeMode.light.name;
    }
  }

  Future<void> setTheme(String themeName) async {
    try {
      await _preferencesService.setString(StorageKeys.selectedTheme, themeName);
      Logger.info('Theme changed to: $themeName');
    } catch (e, stackTrace) {
      Logger.error('Failed to set theme', e, stackTrace);
    }
  }

  Future<List<ThemeModel>> getAvailableThemes() async {
    return [
      ThemeModel.light,
      ThemeModel.dark,
      ThemeModel.businessBlue,
      ThemeModel.professionalGreen,
    ];
  }

  AppThemeMode _parseThemeMode(String name) {
    return AppThemeMode.values.firstWhere(
      (mode) => mode.name == name,
      orElse: () => AppThemeMode.light,
    );
  }

  ThemeModel _getThemeModelByName(String name) {
    switch (name) {
      case 'dark':
        return ThemeModel.dark;
      case 'businessBlue':
        return ThemeModel.businessBlue;
      case 'professionalGreen':
        return ThemeModel.professionalGreen;
      default:
        return ThemeModel.light;
    }
  }

  ColorScheme buildColorScheme(ThemeModel model) {
    if (model.isDark) {
      return ColorScheme.dark(
        primary: model.primaryColor,
        secondary: model.secondaryColor,
        surface: model.surfaceColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.white,
      );
    }
    return ColorScheme.light(
      primary: model.primaryColor,
      secondary: model.secondaryColor,
      surface: model.surfaceColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.black,
    );
  }
}
