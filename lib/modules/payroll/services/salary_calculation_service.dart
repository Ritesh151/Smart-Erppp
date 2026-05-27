import 'package:smarterp/core/exceptions/app_exception.dart';
import 'package:smarterp/core/models/employee_model.dart';
import 'package:smarterp/core/models/salary_model.dart';

class SalaryCalculationRequest {
  final String employeeId;
  final String employeeName;
  final double basicSalary;
  final double bonus;
  final double overtime;
  final double deductions;
  final int month;
  final int year;

  SalaryCalculationRequest({
    required this.employeeId,
    required this.employeeName,
    required this.basicSalary,
    this.bonus = 0,
    this.overtime = 0,
    this.deductions = 0,
    required this.month,
    required this.year,
  });

  double get grossSalary => basicSalary + bonus + overtime;
  double get netSalary => grossSalary - deductions;
}

class SalaryBreakdown {
  final double basicSalary;
  final double bonus;
  final double overtime;
  final double deductions;
  final double grossSalary;
  final double netSalary;
  final double deductionPercentage;
  final double netPercentage;

  SalaryBreakdown({
    required this.basicSalary,
    required this.bonus,
    required this.overtime,
    required this.deductions,
    required this.grossSalary,
    required this.netSalary,
  })  : deductionPercentage =
            grossSalary > 0 ? (deductions / grossSalary) * 100 : 0,
        netPercentage =
            grossSalary > 0 ? (netSalary / grossSalary) * 100 : 0;

  Map<String, double> get componentMap => {
        'Basic': basicSalary,
        if (bonus > 0) 'Bonus': bonus,
        if (overtime > 0) 'Overtime': overtime,
        if (deductions > 0) 'Deductions': deductions,
      };

  List<SalaryComponent> get components {
    final list = <SalaryComponent>[];
    if (basicSalary > 0) {
      list.add(SalaryComponent('Basic', basicSalary, grossSalary, isPositive: true));
    }
    if (bonus > 0) {
      list.add(SalaryComponent('Bonus', bonus, grossSalary, isPositive: true));
    }
    if (overtime > 0) {
      list.add(SalaryComponent('Overtime', overtime, grossSalary, isPositive: true));
    }
    if (deductions > 0) {
      list.add(SalaryComponent('Deductions', deductions, grossSalary, isPositive: false));
    }
    return list;
  }
}

class SalaryComponent {
  final String label;
  final double amount;
  final double percentage;
  final bool isPositive;

  SalaryComponent(this.label, this.amount, double total, {required this.isPositive})
      : percentage = total > 0 ? (amount / total) * 100 : 0;
}

class SalaryCalculationService {
  static const double _minBasicSalary = 0;

  SalaryBreakdown calculate(SalaryCalculationRequest request) {
    _validate(request);

    final grossSalary = request.grossSalary;
    final netSalary = grossSalary < request.deductions
        ? 0.0
        : grossSalary - request.deductions;

    return SalaryBreakdown(
      basicSalary: request.basicSalary,
      bonus: request.bonus,
      overtime: request.overtime,
      deductions: request.deductions,
      grossSalary: grossSalary,
      netSalary: netSalary,
    );
  }

  SalaryBreakdown calculateFromModel(SalaryModel model) {
    return SalaryBreakdown(
      basicSalary: model.basicSalary,
      bonus: model.bonus,
      overtime: model.overtime,
      deductions: model.deductions,
      grossSalary: model.basicSalary + model.bonus + model.overtime,
      netSalary: model.netSalary,
    );
  }

  SalaryBreakdown calculateFromEmployee(
      EmployeeModel employee, int month, int year) {
    final basicSalary = employee.salary;
    return SalaryBreakdown(
      basicSalary: basicSalary,
      bonus: 0,
      overtime: 0,
      deductions: 0,
      grossSalary: basicSalary,
      netSalary: basicSalary,
    );
  }

  SalaryCalculationRequest generateProRatedRequest({
    required String employeeId,
    required String employeeName,
    required double monthlyBasicSalary,
    required int month,
    required int year,
    required DateTime joiningDate,
  }) {
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final firstWorkingDay = joiningDate.day;
    final workingDays = daysInMonth - firstWorkingDay + 1;
    final proRatedBasic =
        (monthlyBasicSalary / daysInMonth) * workingDays;

    return SalaryCalculationRequest(
      employeeId: employeeId,
      employeeName: employeeName,
      basicSalary: proRatedBasic,
      month: month,
      year: year,
    );
  }

  void _validate(SalaryCalculationRequest request) {
    if (request.basicSalary < _minBasicSalary) {
      throw ValidationException('Basic salary cannot be negative');
    }
    if (request.bonus < 0) {
      throw ValidationException('Bonus cannot be negative');
    }
    if (request.overtime < 0) {
      throw ValidationException('Overtime cannot be negative');
    }
    if (request.deductions < 0) {
      throw ValidationException('Deductions cannot be negative');
    }
    if (request.month < 1 || request.month > 12) {
      throw ValidationException('Invalid month');
    }
    if (request.year < 2000 || request.year > 2100) {
      throw ValidationException('Invalid year');
    }
  }
}
