import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
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
  String get monthYear => '$year-${month.toString().padLeft(2, '0')}';
  double get netPaid => paidAmount;
  String get paymentMode {
    final normalized = notes?.toLowerCase().trim();
    if (normalized == 'banktransfer') return 'bank transfer';
    return normalized == null || normalized.isEmpty ? 'cash' : normalized;
  }
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

final _payrollDataVersionProvider = StreamProvider<int>((ref) {
  final controller = StreamController<int>();
  final subscriptions = <StreamSubscription<dynamic>>[];
  var version = 0;

  void emit() {
    if (!controller.isClosed) {
      controller.add(++version);
    }
  }

  for (final boxName in [
    StorageKeys.employeesBox,
    StorageKeys.salaryBox,
    StorageKeys.salaryHistoryBox,
  ]) {
    if (Hive.isBoxOpen(boxName)) {
      subscriptions.add(Hive.box(boxName).watch().listen((_) => emit()));
    }
  }

  emit();
  ref.onDispose(() {
    for (final sub in subscriptions) {
      sub.cancel();
    }
    if (!controller.isClosed) controller.close();
  });
  return controller.stream;
});

// Stream providers for old payroll screens
final employeesStreamProvider = FutureProvider<List<EmployeeModel>>((ref) async {
  ref.watch(_payrollDataVersionProvider);
  final service = ref.read(_employeeServiceProvider);
  return service.getAllEmployees();
});

final salaryPaymentsStreamProvider = FutureProvider<List<SalaryModel>>((ref) async {
  ref.watch(_payrollDataVersionProvider);
  final service = ref.read(_salaryServiceProvider);
  return service.getAllSalaries();
});

final salaryHistoryStreamProvider =
    FutureProvider<List<SalaryHistoryModel>>((ref) async {
  ref.watch(_payrollDataVersionProvider);
  final service = ref.read(_salaryServiceProvider);
  return service.getAllHistory();
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

  Future<SalaryHistoryModel> paySalary({
    required EmployeeModel employee,
    required DateTime paymentDate,
    required PaymentMethod paymentMethod,
  }) async {
    if (employee.salary <= 0) {
      throw Exception('Employee salary must be greater than zero');
    }

    final month = paymentDate.month;
    final year = paymentDate.year;
    final monthlySalaries =
        await _salaryService.getSalariesForMonth(month, year);
    SalaryModel? salary;
    for (final item in monthlySalaries) {
      if (item.employeeId == employee.id) {
        salary = item;
        break;
      }
    }

    salary ??= SalaryModel.create(
      employeeId: employee.id,
      employeeName: employee.fullName,
      month: month,
      year: year,
      basicSalary: employee.salary,
    );

    final remaining = (salary.netSalary - salary.paidAmount)
        .clamp(0.0, double.infinity);
    if (remaining <= 0) {
      throw Exception('Salary is already paid for this month');
    }

    final paidAmount = salary.paidAmount + remaining;
    final updated = salary.copyWith(
      paidAmount: paidAmount,
      status: paidAmount >= salary.netSalary
          ? SalaryStatus.paid
          : SalaryStatus.partiallyPaid,
      paymentDate: paymentDate,
      notes: paymentMethod.name,
      updatedAt: DateTime.now(),
    );

    if (await _salaryService.getSalary(salary.id) == null) {
      await _salaryService.saveSalary(updated);
    } else {
      await _salaryService.updateSalary(updated);
    }

    final history = SalaryHistoryModel(
      id: _transactionId(),
      salaryId: updated.id,
      employeeId: employee.id,
      employeeName: employee.fullName,
      amount: remaining,
      paymentMethod: paymentMethod,
      paymentDate: paymentDate,
      notes: 'Salary paid for ${paymentDate.month}/${paymentDate.year}',
      referenceNumber: null,
      paymentType: PaymentType.full,
      createdAt: DateTime.now(),
    );
    await _salaryService.saveHistory(history);
    return history;
  }

  String _transactionId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp % 10000).toString().padLeft(4, '0');
    return 'PAY-$timestamp-$random';
  }
}

final payrollControllerProvider = Provider<PayrollController>((ref) {
  return PayrollController(
    ref.read(_employeeServiceProvider),
    ref.read(_salaryServiceProvider),
  );
});
