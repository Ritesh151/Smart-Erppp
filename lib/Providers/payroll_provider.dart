import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:SmartERP/core/models/employee_model.dart';
import 'package:SmartERP/core/models/salary_model.dart';
import 'package:SmartERP/core/models/salary_history_model.dart';
import 'package:SmartERP/core/storage/storage_service.dart';
import 'package:SmartERP/core/constants/storage_keys.dart';
import 'package:SmartERP/modules/payroll/repositories/employee_repository.dart';
import 'package:SmartERP/modules/payroll/repositories/salary_repository.dart';
import 'package:SmartERP/modules/payroll/services/employee_service.dart';
import 'package:SmartERP/modules/payroll/services/salary_service.dart';

// Backward-compatibility extensions for old payroll screens
extension EmployeeCompat on EmployeeModel {
  String get employeeId => id;
  double get monthlySalary => salary;
}

extension SalaryModelCompat on SalaryModel {
  String get monthYear => '$month-$year';
  double get netPaid => paidAmount;
  String get paymentMode => 'cash';
}

extension SalaryHistoryCompat on SalaryHistoryModel {
  String get paymentMode => paymentMethod.name;
  double get netPaid => amount;
}

// Repository providers
final _employeeStorageProvider = Provider<StorageService<Map<dynamic, dynamic>>>((ref) {
  return StorageService<Map<dynamic, dynamic>>(StorageKeys.employeesBox)..init();
});

final _salaryStorageProvider = Provider<StorageService<Map<dynamic, dynamic>>>((ref) {
  return StorageService<Map<dynamic, dynamic>>(StorageKeys.salaryBox)..init();
});

final _salaryHistoryStorageProvider = Provider<StorageService<Map<dynamic, dynamic>>>((ref) {
  return StorageService<Map<dynamic, dynamic>>(StorageKeys.salaryHistoryBox)..init();
});

final _employeeRepoProvider = Provider<EmployeeRepository>((ref) {
  return EmployeeRepository(ref.read(_employeeStorageProvider));
});

final _salaryRepoProvider = Provider<SalaryRepository>((ref) {
  return SalaryRepository(
    salaryStorage: ref.read(_salaryStorageProvider),
    historyStorage: ref.read(_salaryHistoryStorageProvider),
  );
});

// Service providers
final _employeeServiceProvider = Provider<EmployeeService>((ref) {
  return EmployeeService(ref.read(_employeeRepoProvider));
});

final _salaryServiceProvider = Provider<SalaryService>((ref) {
  return SalaryService(ref.read(_salaryRepoProvider));
});

// Stream providers for old payroll screens
final employeesStreamProvider = FutureProvider<List<EmployeeModel>>((ref) async {
  final service = ref.read(_employeeServiceProvider);
  return service.getAllEmployees();
});

final salaryPaymentsStreamProvider = FutureProvider<List<SalaryModel>>((ref) async {
  final service = ref.read(_salaryServiceProvider);
  return service.getAllSalaries();
});

// Payroll controller for old screens
class PayrollController {
  final EmployeeService _employeeService;
  final SalaryService _salaryService;

  PayrollController(this._employeeService, this._salaryService);

  Future<void> deleteEmployee(String employeeId) async {
    await _employeeService.deleteEmployee(employeeId);
  }

  Future<void> saveEmployee(EmployeeModel employee) async {
    await _employeeService.saveEmployee(employee);
  }

  Future<void> updateEmployee(String id, Map<String, dynamic> data) async {
    final employee = await _employeeService.getEmployee(id);
    if (employee == null) return;

    String firstName = data['firstName'] as String? ?? employee.firstName;
    String lastName = data['lastName'] as String? ?? employee.lastName;

    if (data.containsKey('fullName') && data['fullName'] != null) {
      final fullName = (data['fullName'] as String).trim();
      final parts = fullName.split(' ');
      firstName = parts.isNotEmpty ? parts.first : fullName;
      lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';
    }

    final updated = employee.copyWith(
      firstName: firstName,
      lastName: lastName,
      designation: data['designation'] as String? ?? employee.designation,
      department: data['department'] as String? ?? employee.department,
      salary: (data['salary'] as num?)?.toDouble() ??
          (data['monthlySalary'] as num?)?.toDouble() ??
          employee.salary,
      phone: data['phone'] as String? ?? employee.phone,
      updatedAt: DateTime.now(),
    );
    await _employeeService.updateEmployee(updated);
  }
}

final payrollControllerProvider = Provider<PayrollController>((ref) {
  return PayrollController(
    ref.read(_employeeServiceProvider),
    ref.read(_salaryServiceProvider),
  );
});
