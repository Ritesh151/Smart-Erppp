import 'dart:convert';
import 'dart:io';

import 'package:smarterp/core/storage/storage_service.dart';
import 'package:smarterp/core/utils/logger.dart';

class DataImportResult {
  final int recordsImported;
  final int recordsSkipped;
  final List<String> errors;

  DataImportResult({
    this.recordsImported = 0,
    this.recordsSkipped = 0,
    this.errors = const [],
  });

  bool get success => errors.isEmpty;
}

class DataImportService {
  final StorageService<Map<dynamic, dynamic>> _productsStorage;
  final StorageService<Map<dynamic, dynamic>> _transactionsStorage;
  final StorageService<Map<dynamic, dynamic>> _invoicesStorage;
  final StorageService<Map<dynamic, dynamic>> _customersStorage;
  final StorageService<Map<dynamic, dynamic>> _transportsStorage;
  final StorageService<Map<dynamic, dynamic>> _vehiclesStorage;
  final StorageService<Map<dynamic, dynamic>> _employeesStorage;
  final StorageService<Map<dynamic, dynamic>> _attendanceStorage;
  final StorageService<Map<dynamic, dynamic>> _salariesStorage;

  DataImportService({
    required StorageService<Map<dynamic, dynamic>> productsStorage,
    required StorageService<Map<dynamic, dynamic>> transactionsStorage,
    required StorageService<Map<dynamic, dynamic>> invoicesStorage,
    required StorageService<Map<dynamic, dynamic>> customersStorage,
    required StorageService<Map<dynamic, dynamic>> transportsStorage,
    required StorageService<Map<dynamic, dynamic>> vehiclesStorage,
    required StorageService<Map<dynamic, dynamic>> employeesStorage,
    required StorageService<Map<dynamic, dynamic>> attendanceStorage,
    required StorageService<Map<dynamic, dynamic>> salariesStorage,
  })  : _productsStorage = productsStorage,
        _transactionsStorage = transactionsStorage,
        _invoicesStorage = invoicesStorage,
        _customersStorage = customersStorage,
        _transportsStorage = transportsStorage,
        _vehiclesStorage = vehiclesStorage,
        _employeesStorage = employeesStorage,
        _attendanceStorage = attendanceStorage,
        _salariesStorage = salariesStorage;

  Future<DataImportResult> importFromFile(
    String filePath, {
    bool merge = false,
  }) async {
    final file = File(filePath);
    if (!await file.exists()) {
      return DataImportResult(errors: ['File not found: $filePath']);
    }

    final jsonString = await file.readAsString();
    return importFromJson(jsonString, merge: merge);
  }

  Future<DataImportResult> importFromJson(
    String jsonString, {
    bool merge = false,
  }) async {
    Map<String, dynamic> data;
    try {
      data = json.decode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      return DataImportResult(errors: ['Invalid JSON: $e']);
    }

    final errors = <String>[];
    int imported = 0;
    int skipped = 0;

    final storageMap = <String, StorageService<Map<dynamic, dynamic>>>{
      'products': _productsStorage,
      'transactions': _transactionsStorage,
      'invoices': _invoicesStorage,
      'customers': _customersStorage,
      'transports': _transportsStorage,
      'vehicles': _vehiclesStorage,
      'employees': _employeesStorage,
      'attendance': _attendanceStorage,
      'salaries': _salariesStorage,
    };

    for (final entry in data.entries) {
      if (entry.value == null) continue;

      final storage = storageMap[entry.key];
      if (storage == null) {
        errors.add('Unknown module: ${entry.key}');
        continue;
      }

      try {
        if (entry.value is List) {
          final items = entry.value as List;
          for (final item in items) {
            if (item is Map) {
              final id = item['id']?.toString();
              if (id != null && !merge && storage.containsKey(id)) {
                skipped++;
                continue;
              }
              await storage.save(
                id ?? _generateId(),
                Map<String, dynamic>.from(item),
              );
              imported++;
            }
          }
        }
      } catch (e, stackTrace) {
        Logger.error('Failed to import module: ${entry.key}', e, stackTrace);
        errors.add('${entry.key}: $e');
      }
    }

    Logger.success('Import complete: $imported imported, $skipped skipped');
    return DataImportResult(
      recordsImported: imported,
      recordsSkipped: skipped,
      errors: errors,
    );
  }

  Future<DataImportResult> importModuleFromFile(
    String module,
    String filePath, {
    bool merge = false,
  }) async {
    final file = File(filePath);
    if (!await file.exists()) {
      return DataImportResult(errors: ['File not found: $filePath']);
    }

    final jsonString = await file.readAsString();
    List<dynamic> items;
    try {
      items = json.decode(jsonString) as List<dynamic>;
    } catch (e) {
      return DataImportResult(errors: ['Invalid JSON array: $e']);
    }

    return _importModuleItems(module, items, merge: merge);
  }

  Future<DataImportResult> _importModuleItems(
    String module,
    List<dynamic> items, {
    bool merge = false,
  }) async {
    final storageMap = <String, StorageService<Map<dynamic, dynamic>>>{
      'products': _productsStorage,
      'transactions': _transactionsStorage,
      'invoices': _invoicesStorage,
      'customers': _customersStorage,
      'transports': _transportsStorage,
      'vehicles': _vehiclesStorage,
      'employees': _employeesStorage,
      'attendance': _attendanceStorage,
      'salaries': _salariesStorage,
    };

    final storage = storageMap[module];
    if (storage == null) {
      return DataImportResult(errors: ['Unknown module: $module']);
    }

    final errors = <String>[];
    int imported = 0;
    int skipped = 0;

    for (final item in items) {
      if (item is! Map) {
        skipped++;
        continue;
      }
      try {
        final id = item['id']?.toString();
        if (id != null && !merge && storage.containsKey(id)) {
          skipped++;
          continue;
        }
        await storage.save(
          id ?? _generateId(),
          Map<String, dynamic>.from(item),
        );
        imported++;
      } catch (e) {
        errors.add('$e');
      }
    }

    return DataImportResult(
      recordsImported: imported,
      recordsSkipped: skipped,
      errors: errors,
    );
  }

  String _generateId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'IMP-$timestamp';
  }
}
