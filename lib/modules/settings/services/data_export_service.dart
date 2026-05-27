import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:smarterp/core/utils/logger.dart';
import 'package:smarterp/modules/finance/services/finance_service.dart';
import 'package:smarterp/modules/invoice/services/customer_service.dart';
import 'package:smarterp/modules/invoice/services/invoice_service.dart';
import 'package:smarterp/modules/payroll/services/attendance_service.dart';
import 'package:smarterp/modules/payroll/services/employee_service.dart';
import 'package:smarterp/modules/payroll/services/salary_service.dart';
import 'package:smarterp/modules/products/services/product_service.dart';
import 'package:smarterp/modules/transport/services/transport_service.dart';
import 'package:smarterp/modules/transport/services/vehicle_service.dart';

class DataExportService {
  final ProductService _productService;
  final FinanceService _financeService;
  final InvoiceService _invoiceService;
  final CustomerService _customerService;
  final TransportService _transportService;
  final VehicleService _vehicleService;
  final EmployeeService _employeeService;
  final AttendanceService _attendanceService;
  final SalaryService _salaryService;

  DataExportService({
    required ProductService productService,
    required FinanceService financeService,
    required InvoiceService invoiceService,
    required CustomerService customerService,
    required TransportService transportService,
    required VehicleService vehicleService,
    required EmployeeService employeeService,
    required AttendanceService attendanceService,
    required SalaryService salaryService,
  })  : _productService = productService,
        _financeService = financeService,
        _invoiceService = invoiceService,
        _customerService = customerService,
        _transportService = transportService,
        _vehicleService = vehicleService,
        _employeeService = employeeService,
        _attendanceService = attendanceService,
        _salaryService = salaryService;

  Future<String> exportModule(String module) async {
    final data = await _collectModuleData(module);
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  Future<String> exportAll() async {
    final data = <String, dynamic>{};
    for (final module in _allModules) {
      data[module] = await _collectModuleData(module);
    }
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  Future<File> exportToFile(String module) async {
    final jsonString = await exportModule(module);
    final dir = await getApplicationDocumentsDirectory();
    final exportDir = Directory('${dir.path}/exports');
    if (!await exportDir.exists()) {
      await exportDir.create(recursive: true);
    }
    final fileName = '${module}_export_${DateTime.now().millisecondsSinceEpoch}.json';
    final file = File('${exportDir.path}/$fileName');
    await file.writeAsString(jsonString);
    Logger.success('Exported $module to ${file.path}');
    return file;
  }

  Future<dynamic> _collectModuleData(String module) async {
    switch (module) {
      case 'products':
        final items = await _productService.getAllProducts();
        return items.map((p) => p.toJson()).toList();
      case 'finance':
      case 'transactions':
        final items = await _financeService.getAllTransactions();
        return items.map((t) => t.toJson()).toList();
      case 'invoices':
        final items = await _invoiceService.getAllInvoices();
        return items.map((i) => i.toJson()).toList();
      case 'customers':
        final items = await _customerService.getAllCustomers();
        return items.map((c) => c.toJson()).toList();
      case 'transports':
        final items = await _transportService.getAllTransports();
        return items.map((t) => t.toJson()).toList();
      case 'vehicles':
        final items = await _vehicleService.getAllVehicles();
        return items.map((v) => v.toJson()).toList();
      case 'employees':
        final items = await _employeeService.getAllEmployees();
        return items.map((e) => e.toJson()).toList();
      case 'attendance':
        final items = await _attendanceService.getAllRecords();
        return items.map((a) => a.toJson()).toList();
      case 'salaries':
        final items = await _salaryService.getAllSalaries();
        return items.map((s) => s.toJson()).toList();
      default:
        throw ArgumentError('Unknown module: $module');
    }
  }

  List<String> get _allModules => [
        'products',
        'transactions',
        'invoices',
        'customers',
        'transports',
        'vehicles',
        'employees',
        'attendance',
        'salaries',
      ];
}
