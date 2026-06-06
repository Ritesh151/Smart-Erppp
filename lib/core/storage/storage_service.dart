import 'package:hive_flutter/hive_flutter.dart';
import 'package:siddhivinayak_enterprise/core/exceptions/app_exception.dart';
import 'package:siddhivinayak_enterprise/core/utils/logger.dart';

class StorageService<T> {
  final String boxName;
  Box<dynamic>? _box;

  StorageService(this.boxName) {
    _init();
  }

  void _init() {
    if (Hive.isBoxOpen(boxName)) {
      _box = Hive.box(boxName);
      Logger.debug('Using existing box: $boxName');
    } else {
      throw StorageException('Storage box not initialized: $boxName');
    }
  }

  Box<dynamic> get box {
    if (_box == null) {
      _init();
    }
    if (_box == null || !_box!.isOpen) {
      throw StorageException('Storage box not initialized: $boxName');
    }
    return _box!;
  }

  Future<void> save(String key, T value) async {
    try {
      await box.put(key, value);
      Logger.debug('Saved to storage: $boxName/$key');
    } catch (e, stackTrace) {
      Logger.error('Failed to save to storage: $boxName/$key', e, stackTrace);
      throw StorageException('Failed to save data');
    }
  }

  T? get(String key) {
    try {
      final value = box.get(key);
      return value is T ? value : null;
    } catch (e, stackTrace) {
      Logger.error('Failed to get from storage: $boxName/$key', e, stackTrace);
      return null;
    }
  }

  T? getAt(int index) {
    try {
      if (index >= 0 && index < box.length) {
        final value = box.getAt(index);
        return value is T ? value : null;
      }
      return null;
    } catch (e, stackTrace) {
      Logger.error('Failed to get at index: $boxName/$index', e, stackTrace);
      return null;
    }
  }

  List<T> getAll() {
    try {
      return box.values.whereType<T>().toList();
    } catch (e, stackTrace) {
      Logger.error('Failed to get all from storage: $boxName', e, stackTrace);
      return [];
    }
  }

  Future<void> update(String key, T value) async {
    try {
      if (box.containsKey(key)) {
        await box.put(key, value);
        Logger.debug('Updated in storage: $boxName/$key');
      } else {
        throw StorageException('Key not found: $key');
      }
    } catch (e, stackTrace) {
      Logger.error('Failed to update storage: $boxName/$key', e, stackTrace);
      throw StorageException('Failed to update data');
    }
  }

  Future<void> delete(String key) async {
    try {
      await box.delete(key);
      Logger.debug('Deleted from storage: $boxName/$key');
    } catch (e, stackTrace) {
      Logger.error('Failed to delete from storage: $boxName/$key', e, stackTrace);
      throw StorageException('Failed to delete data');
    }
  }

  Future<void> deleteAt(int index) async {
    try {
      if (index >= 0 && index < box.length) {
        await box.deleteAt(index);
        Logger.debug('Deleted at index: $boxName/$index');
      }
    } catch (e, stackTrace) {
      Logger.error('Failed to delete at index: $boxName/$index', e, stackTrace);
      throw StorageException('Failed to delete data');
    }
  }

  Future<void> clear() async {
    try {
      await box.clear();
      Logger.info('Cleared storage: $boxName');
    } catch (e, stackTrace) {
      Logger.error('Failed to clear storage: $boxName', e, stackTrace);
      throw StorageException('Failed to clear storage');
    }
  }

  bool containsKey(String key) {
    try {
      return box.containsKey(key);
    } catch (e, stackTrace) {
      Logger.error('Failed to check key: $boxName/$key', e, stackTrace);
      return false;
    }
  }

  int get length {
    try {
      return box.length;
    } catch (e, stackTrace) {
      Logger.error('Failed to get length: $boxName', e, stackTrace);
      return 0;
    }
  }

  bool get isEmpty => length == 0;

  bool get isNotEmpty => !isEmpty;

  Future<void> close() async {
    try {
      if (_box != null && _box!.isOpen) {
        await _box!.close();
        Logger.info('Closed storage: $boxName');
      }
    } catch (e, stackTrace) {
      Logger.error('Failed to close storage: $boxName', e, stackTrace);
    }
  }
}
