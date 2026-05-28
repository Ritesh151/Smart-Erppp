import 'package:shared_preferences/shared_preferences.dart';
import 'package:SmartERP/core/exceptions/app_exception.dart';
import 'package:SmartERP/core/utils/logger.dart';

class PreferencesService {
  static PreferencesService? _instance;
  static SharedPreferences? _preferences;

  PreferencesService._();

  static Future<PreferencesService> getInstance() async {
    _instance ??= PreferencesService._();
    _preferences ??= await SharedPreferences.getInstance();
    return _instance!;
  }

  SharedPreferences get preferences {
    if (_preferences == null) {
      throw StorageException('PreferencesService not initialized');
    }
    return _preferences!;
  }

  Future<bool> setString(String key, String value) async {
    try {
      final result = await preferences.setString(key, value);
      Logger.debug('Saved preference: $key = $value');
      return result;
    } catch (e, stackTrace) {
      Logger.error('Failed to save preference: $key', e, stackTrace);
      return false;
    }
  }

  String? getString(String key, {String? defaultValue}) {
    try {
      return preferences.getString(key) ?? defaultValue;
    } catch (e, stackTrace) {
      Logger.error('Failed to get preference: $key', e, stackTrace);
      return defaultValue;
    }
  }

  Future<bool> setInt(String key, int value) async {
    try {
      final result = await preferences.setInt(key, value);
      Logger.debug('Saved preference: $key = $value');
      return result;
    } catch (e, stackTrace) {
      Logger.error('Failed to save preference: $key', e, stackTrace);
      return false;
    }
  }

  int? getInt(String key, {int? defaultValue}) {
    try {
      return preferences.getInt(key) ?? defaultValue;
    } catch (e, stackTrace) {
      Logger.error('Failed to get preference: $key', e, stackTrace);
      return defaultValue;
    }
  }

  Future<bool> setBool(String key, bool value) async {
    try {
      final result = await preferences.setBool(key, value);
      Logger.debug('Saved preference: $key = $value');
      return result;
    } catch (e, stackTrace) {
      Logger.error('Failed to save preference: $key', e, stackTrace);
      return false;
    }
  }

  bool? getBool(String key, {bool? defaultValue}) {
    try {
      return preferences.getBool(key) ?? defaultValue;
    } catch (e, stackTrace) {
      Logger.error('Failed to get preference: $key', e, stackTrace);
      return defaultValue;
    }
  }

  Future<bool> setDouble(String key, double value) async {
    try {
      final result = await preferences.setDouble(key, value);
      Logger.debug('Saved preference: $key = $value');
      return result;
    } catch (e, stackTrace) {
      Logger.error('Failed to save preference: $key', e, stackTrace);
      return false;
    }
  }

  double? getDouble(String key, {double? defaultValue}) {
    try {
      return preferences.getDouble(key) ?? defaultValue;
    } catch (e, stackTrace) {
      Logger.error('Failed to get preference: $key', e, stackTrace);
      return defaultValue;
    }
  }

  Future<bool> setStringList(String key, List<String> value) async {
    try {
      final result = await preferences.setStringList(key, value);
      Logger.debug('Saved preference list: $key');
      return result;
    } catch (e, stackTrace) {
      Logger.error('Failed to save preference list: $key', e, stackTrace);
      return false;
    }
  }

  List<String>? getStringList(String key, {List<String>? defaultValue}) {
    try {
      return preferences.getStringList(key) ?? defaultValue;
    } catch (e, stackTrace) {
      Logger.error('Failed to get preference list: $key', e, stackTrace);
      return defaultValue;
    }
  }

  Future<bool> remove(String key) async {
    try {
      final result = await preferences.remove(key);
      Logger.debug('Removed preference: $key');
      return result;
    } catch (e, stackTrace) {
      Logger.error('Failed to remove preference: $key', e, stackTrace);
      return false;
    }
  }

  Future<bool> clear() async {
    try {
      final result = await preferences.clear();
      Logger.info('Cleared all preferences');
      return result;
    } catch (e, stackTrace) {
      Logger.error('Failed to clear preferences', e, stackTrace);
      return false;
    }
  }

  bool containsKey(String key) {
    try {
      return preferences.containsKey(key);
    } catch (e, stackTrace) {
      Logger.error('Failed to check key: $key', e, stackTrace);
      return false;
    }
  }

  Set<String> getKeys() {
    try {
      return preferences.getKeys();
    } catch (e, stackTrace) {
      Logger.error('Failed to get keys', e, stackTrace);
      return {};
    }
  }
}
