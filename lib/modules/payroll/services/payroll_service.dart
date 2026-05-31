import 'package:siddhivinayak_enterprise/core/models/employee_model.dart';
import 'package:siddhivinayak_enterprise/core/models/attendance_model.dart';
import 'package:siddhivinayak_enterprise/core/models/salary_model.dart';
import 'package:siddhivinayak_enterprise/modules/payroll/repositories/employee_repository.dart';
import 'package:siddhivinayak_enterprise/modules/payroll/repositories/attendance_repository.dart';
import 'package:siddhivinayak_enterprise/modules/payroll/repositories/salary_repository.dart';

class PayrollService {
  final EmployeeRepository employeeRepository;
  final AttendanceRepository attendanceRepository;
  final SalaryRepository salaryRepository;

  PayrollService({
    required this.employeeRepository,
    required this.attendanceRepository,
    required this.salaryRepository,
  });

  Future<List<EmployeeModel>> getAllEmployees() =>
      employeeRepository.getAll();

  Future<List<AttendanceModel>> getAllAttendance() =>
      attendanceRepository.getAll();

  Future<List<SalaryModel>> getAllSalaries() =>
      salaryRepository.getAllSalaries();

  Future<SalaryModel?> getSalaryForEmployeeMonth(
      String employeeId, int month, int year) async {
    final salaries = await salaryRepository.getSalariesForMonth(month, year);
    try {
      return salaries.firstWhere((s) => s.employeeId == employeeId);
    } catch (_) {
      return null;
    }
  }

  Future<void> generateSalariesForMonth(int month, int year) async {
    final employees = await employeeRepository.getAll();
    final existingSalaries =
        await salaryRepository.getSalariesForMonth(month, year);
    final existingIds =
        existingSalaries.map((s) => s.employeeId).toSet();

    for (final emp in employees) {
      if (existingIds.contains(emp.id)) continue;
      final salary = SalaryModel.create(
        employeeId: emp.id,
        employeeName: emp.fullName,
        month: month,
        year: year,
        basicSalary: emp.salary,
      );
      await salaryRepository.saveSalary(salary);
    }
  }

  Future<void> deleteEmployee(String employeeId) async {
    await employeeRepository.delete(employeeId);
  }

  Future<List<SalaryModel>> getMonthlySalaries(int month, int year) =>
      salaryRepository.getSalariesForMonth(month, year);

  Future<PayrollDashboardData> getDashboardData() async {
    final employees = await employeeRepository.getAll();
    final salaries = await salaryRepository.getAllSalaries();
    final pendingCount = salaries.where((s) => s.pendingAmount > 0).length;
    final totalPending =
        salaries.fold<double>(0, (sum, s) => sum + s.pendingAmount);
    final totalPaid =
        salaries.fold<double>(0, (sum, s) => sum + s.paidAmount);
    return PayrollDashboardData(
      employeeCount: employees.length,
      pendingCount: pendingCount,
      totalPending: totalPending,
      totalPaid: totalPaid,
    );
  }
}

class PayrollDashboardData {
  final int employeeCount;
  final int pendingCount;
  final double totalPending;
  final double totalPaid;

  PayrollDashboardData({
    required this.employeeCount,
    required this.pendingCount,
    required this.totalPending,
    required this.totalPaid,
  });
}
