import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:SmartERP/core/models/backup_model.dart';
import 'package:SmartERP/core/utils/logger.dart';
import 'package:SmartERP/modules/finance/services/finance_service.dart';
import 'package:SmartERP/modules/invoice/services/customer_service.dart';
import 'package:SmartERP/modules/invoice/services/invoice_service.dart';
import 'package:SmartERP/modules/payroll/services/attendance_service.dart';
import 'package:SmartERP/modules/payroll/services/employee_service.dart';
import 'package:SmartERP/modules/payroll/services/salary_service.dart';
import 'package:SmartERP/modules/products/services/product_service.dart';
import 'package:SmartERP/modules/settings/repositories/backup_repository.dart';
import 'package:SmartERP/modules/settings/services/notification_service.dart';
import 'package:SmartERP/modules/settings/services/settings_service.dart';
import 'package:SmartERP/modules/transport/services/transport_service.dart';
import 'package:SmartERP/modules/transport/services/vehicle_service.dart';

class BackupService {
  final ProductService _productService;
  final FinanceService _financeService;
  final InvoiceService _invoiceService;
  final CustomerService _customerService;
  final TransportService _transportService;
  final VehicleService _vehicleService;
  final EmployeeService _employeeService;
  final AttendanceService _attendanceService;
  final SalaryService _salaryService;
  final NotificationService _notificationService;
  final SettingsService _settingsService;
  final BackupRepository _backupRepository;

  BackupService({
    required ProductService productService,
    required FinanceService financeService,
    required InvoiceService invoiceService,
    required CustomerService customerService,
    required TransportService transportService,
    required VehicleService vehicleService,
    required EmployeeService employeeService,
    required AttendanceService attendanceService,
    required SalaryService salaryService,
    required NotificationService notificationService,
    required SettingsService settingsService,
    required BackupRepository backupRepository,
  })  : _productService = productService,
        _financeService = financeService,
        _invoiceService = invoiceService,
        _customerService = customerService,
        _transportService = transportService,
        _vehicleService = vehicleService,
        _employeeService = employeeService,
        _attendanceService = attendanceService,
        _salaryService = salaryService,
        _notificationService = notificationService,
        _settingsService = settingsService,
        _backupRepository = backupRepository;

  Future<BackupModel> createBackup({
    String name = '',
    BackupType type = BackupType.manual,
    List<String>? includedModules,
  }) async {
    Logger.info('Starting backup: $name');

    final backupModel = BackupModel.create(
      name: name.isNotEmpty ? name : 'Backup_${_timestamp()}',
      description: '${type.name} backup',
      type: type,
      status: BackupStatus.inProgress,
      filePath: '',
      version: '1.0.0',
      includedModules: includedModules ?? _allModuleNames,
    );

    try {
      final data = await _collectModuleData(backupModel.includedModules);
      final jsonString = const JsonEncoder.withIndent('  ').convert(data);
      final bytes = utf8.encode(jsonString);
      final backupModelWithSize = backupModel.copyWith(
        fileSizeBytes: bytes.length.toDouble(),
        filePath: await _writeBackupFile(name, jsonString),
        recordCount: _countRecords(data),
        checksum: _computeChecksum(jsonString),
      );

      await _backupRepository.save(backupModelWithSize);
      final saved = backupModelWithSize.copyWith(status: BackupStatus.completed);
      await _backupRepository.update(saved);

      await _notificationService.notifyBackupComplete(saved.name);
      Logger.success('Backup completed: ${saved.name} (${saved.formattedSize})');
      return saved;
    } catch (e, stackTrace) {
      Logger.error('Backup failed', e, stackTrace);
      final failed = backupModel.copyWith(status: BackupStatus.failed);
      await _backupRepository.save(failed);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> _collectModuleData(List<String> modules) async {
    final data = <String, dynamic>{};

    if (modules.contains('products')) {
      final products = await _productService.getAllProducts();
      data['products'] = products.map((p) => p.toJson()).toList();
    }

    if (modules.contains('finance')) {
      final transactions = await _financeService.getAllTransactions();
      data['transactions'] = transactions.map((t) => t.toJson()).toList();
    }

    if (modules.contains('invoices')) {
      final invoices = await _invoiceService.getAllInvoices();
      data['invoices'] = invoices.map((i) => i.toJson()).toList();
    }

    if (modules.contains('customers')) {
      final customers = await _customerService.getAllCustomers();
      data['customers'] = customers.map((c) => c.toJson()).toList();
    }

    if (modules.contains('transports')) {
      final transports = await _transportService.getAllTransports();
      data['transports'] = transports;
    }

    if (modules.contains('vehicles')) {
      final vehicles = await _vehicleService.getAllVehicles();
      data['vehicles'] = vehicles;
    }

    if (modules.contains('employees')) {
      final employees = await _employeeService.getAllEmployees();
      data['employees'] = employees.map((e) => e.toJson()).toList();
    }

    if (modules.contains('attendance')) {
      final attendance = await _attendanceService.getAllRecords();
      data['attendance'] = attendance.map((a) => a.toJson()).toList();
    }

    if (modules.contains('salaries')) {
      final salaries = await _salaryService.getAllSalaries();
      data['salaries'] = salaries.map((s) => s.toJson()).toList();
    }

    if (modules.contains('settings')) {
      final settings = await _settingsService.getSettings();
      data['settings'] = settings?.toJson();
    }

    return data;
  }

  Future<String> _writeBackupFile(String name, String jsonString) async {
    final dir = await getApplicationDocumentsDirectory();
    final backupDir = Directory('${dir.path}/backups');
    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }
    final fileName = '${name.replaceAll(RegExp(r'[^\w\-]'), '_')}.json';
    final file = File('${backupDir.path}/$fileName');
    await file.writeAsString(jsonString);
    return file.path;
  }

  Future<void> deleteOldBackups({int keepCount = 10}) async {
    await _backupRepository.deleteOlderThan(keepCount);
  }

  Future<BackupModel?> getLatestBackup() async {
    final backups = await _backupRepository.getRecent(1);
    return backups.isNotEmpty ? backups.first : null;
  }

  int _countRecords(Map<String, dynamic> data) {
    int count = 0;
    for (final entry in data.entries) {
      if (entry.value is List) {
        count += (entry.value as List).length;
      } else if (entry.value != null) {
        count++;
      }
    }
    return count;
  }

  String _computeChecksum(String content) {
    final bytes = utf8.encode(content);
    int hash = 0;
    for (final byte in bytes) {
      hash = ((hash << 5) - hash + byte) & 0x7FFFFFFF;
    }
    return hash.toRadixString(16).padLeft(8, '0');
  }

  List<String> get _allModuleNames => [
        'products',
        'finance',
        'invoices',
        'customers',
        'transports',
        'vehicles',
        'employees',
        'attendance',
        'salaries',
        'settings',
      ];

  String _timestamp() {
    final now = DateTime.now();
    return '${now.year}${_pad(now.month)}${_pad(now.day)}_${_pad(now.hour)}${_pad(now.minute)}';
  }

  String _pad(int n) => n.toString().padLeft(2, '0');

  Future<List<BackupModel>> getAllBackups() => _backupRepository.getAll();

  Future<BackupModel?> getBackupById(String id) => _backupRepository.getById(id);

  Future<void> deleteBackup(String id) => _backupRepository.delete(id);

  Future<int> getBackupCount() => _backupRepository.getCount();

  Future<double> getTotalBackupSizeBytes() => _backupRepository.getTotalSizeBytes();
}
