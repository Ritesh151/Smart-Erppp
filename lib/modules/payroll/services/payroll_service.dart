import 'package:smarterp/core/exceptions/app_exception.dart';
import 'package:smarterp/core/models/employee_model.dart';
import 'package:smarterp/core/models/salary_model.dart';
import 'package:smarterp/core/utils/logger.dart';
import 'package:smarterp/modules/payroll/repositories/employee_repository.dart';
import 'package:smarterp/modules/payroll/repositories/attendance_repository.dart';
import 'package:smarterp/modules/payroll/repositories/salary_repository.dart';

class PayrollService {
  final EmployeeRepository _employeeRepository;
  final AttendanceRepository _attendanceRepository;
  final SalaryRepository _salaryRepository;

  PayrollService({
    required EmployeeRepository employeeRepository,
    required AttendanceRepository attendanceRepository,
    required SalaryRepository salaryRepository,
  })  : _employeeRepository = employeeRepository,
        _attendanceRepository = attendanceRepository,
        _salaryRepository = salaryRepository;

  Future<PayrollDashboardData> getDashboardData() async {
    try {
      final employees = await _employeeRepository.getAll();
      final salaries = await _salaryRepository.getAll();
      final now = DateTime.now();
      final month = now.month;
      final year = now.year;

      final totalEmployees = employees.length;
      final activeEmployees = employees.where((e) => e.status == EmployeeStatus.active).length;

      double totalPayable = 0;
      double totalPaid = 0;
      double totalPending = 0;
      int paidCount = 0;
      int pendingCount = 0;

      for (final s in salaries) {
        if (s.month == month && s.year == year) {
          totalPayable += s.netSalary;
          totalPaid += s.paidAmount;
          totalPending += s.pendingAmount;
          if (s.isFullyPaid) paidCount++;
          if (s.status == SalaryStatus.pending || s.status == SalaryStatus.overdue) {
            pendingCount++;
          }
        }
      }

      final attendanceMonth = await _attendanceRepository.getByMonth(month, year);
      final totalRecords = attendanceMonth.length;
      final presentRecords = attendanceMonth.where((a) => a.isPresent).length;
      final attendanceRate = totalRecords > 0 ? (presentRecords / totalRecords) * 100 : 0.0;

      return PayrollDashboardData(
        totalEmployees: totalEmployees,
        activeEmployees: activeEmployees,
        totalPayable: totalPayable,
        totalPaid: totalPaid,
        totalPending: totalPending,
        paidCount: paidCount,
        pendingCount: pendingCount,
        attendanceRate: attendanceRate,
        month: month,
        year: year,
      );
    } catch (e, stackTrace) {
      Logger.error('Failed to get dashboard data', e, stackTrace);
      rethrow;
    }
  }

  Future<List<SalaryModel>> getMonthlySalaries(int month, int year) async {
    try {
      return await _salaryRepository.getByMonth(month, year);
    } catch (e, stackTrace) {
      Logger.error('Failed to get monthly salaries', e, stackTrace);
      return [];
    }
  }

  Future<MonthlySalarySummary> getMonthlySummary(int month, int year) async {
    try {
      final salaries = await _salaryRepository.getByMonth(month, year);
      double totalPayable = 0;
      double totalPaid = 0;
      double totalPending = 0;
      int paidCount = 0;
      int pendingCount = 0;
      int partiallyPaidCount = 0;

      for (final s in salaries) {
        totalPayable += s.netSalary;
        totalPaid += s.paidAmount;
        totalPending += s.pendingAmount;
        if (s.isFullyPaid) paidCount++;
        if (s.isPartiallyPaid) partiallyPaidCount++;
        if (s.status == SalaryStatus.pending || s.status == SalaryStatus.overdue) {
          pendingCount++;
        }
      }

      return MonthlySalarySummary(
        totalEmployees: salaries.length,
        totalPayable: totalPayable,
        totalPaid: totalPaid,
        totalPending: totalPending,
        paidCount: paidCount,
        pendingCount: pendingCount,
        partiallyPaidCount: partiallyPaidCount,
        month: month,
        year: year,
      );
    } catch (e, stackTrace) {
      Logger.error('Failed to get monthly summary', e, stackTrace);
      rethrow;
    }
  }

  Future<List<int>> getMonthlyTrend({int months = 12}) async {
    try {
      final salaries = await _salaryRepository.getAll();
      final now = DateTime.now();
      final trend = <int>[];

      for (var i = months - 1; i >= 0; i--) {
        final targetDate = DateTime(now.year, now.month - i, 1);
        final count = salaries.where((s) =>
            s.year == targetDate.year && s.month == targetDate.month).length;
        trend.add(count);
      }

      return trend;
    } catch (e, stackTrace) {
      Logger.error('Failed to get monthly trend', e, stackTrace);
      return List.filled(12, 0);
    }
  }

  Future<List<double>> getSalaryTrend({int months = 12}) async {
    try {
      final salaries = await _salaryRepository.getAll();
      final now = DateTime.now();
      final trend = <double>[];

      for (var i = months - 1; i >= 0; i--) {
        final targetDate = DateTime(now.year, now.month - i, 1);
        double total = 0;
        for (final s in salaries) {
          if (s.year == targetDate.year && s.month == targetDate.month) {
            total += s.netSalary;
          }
        }
        trend.add(total);
      }

      return trend;
    } catch (e, stackTrace) {
      Logger.error('Failed to get salary trend', e, stackTrace);
      return List.filled(12, 0);
    }
  }

  Future<Map<String, int>> getEmployeeDistribution() async {
    try {
      final employees = await _employeeRepository.getAll();
      final distribution = <String, int>{};
      for (final e in employees) {
        distribution[e.department] = (distribution[e.department] ?? 0) + 1;
      }
      return distribution;
    } catch (e, stackTrace) {
      Logger.error('Failed to get employee distribution', e, stackTrace);
      return {};
    }
  }

  Future<Map<EmployeeStatus, int>> getEmployeeStatusDistribution() async {
    try {
      final employees = await _employeeRepository.getAll();
      final distribution = <EmployeeStatus, int>{};
      for (final status in EmployeeStatus.values) {
        distribution[status] = 0;
      }
      for (final e in employees) {
        distribution[e.status] = (distribution[e.status] ?? 0) + 1;
      }
      return distribution;
    } catch (e, stackTrace) {
      Logger.error('Failed to get employee status distribution', e, stackTrace);
      return {};
    }
  }
}

class PayrollDashboardData {
  final int totalEmployees;
  final int activeEmployees;
  final double totalPayable;
  final double totalPaid;
  final double totalPending;
  final int paidCount;
  final int pendingCount;
  final double attendanceRate;
  final int month;
  final int year;

  PayrollDashboardData({
    required this.totalEmployees,
    required this.activeEmployees,
    required this.totalPayable,
    required this.totalPaid,
    required this.totalPending,
    required this.paidCount,
    required this.pendingCount,
    required this.attendanceRate,
    required this.month,
    required this.year,
  });
}

class MonthlySalarySummary {
  final int totalEmployees;
  final double totalPayable;
  final double totalPaid;
  final double totalPending;
  final int paidCount;
  final int pendingCount;
  final int partiallyPaidCount;
  final int month;
  final int year;

  MonthlySalarySummary({
    required this.totalEmployees,
    required this.totalPayable,
    required this.totalPaid,
    required this.totalPending,
    required this.paidCount,
    required this.pendingCount,
    required this.partiallyPaidCount,
    required this.month,
    required this.year,
  });
}
