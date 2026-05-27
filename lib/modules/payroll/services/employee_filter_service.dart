import 'package:smarterp/core/models/employee_model.dart';
import 'package:smarterp/modules/payroll/repositories/employee_repository.dart';

class EmployeeFilterOptions {
  final List<String> departments;
  final List<EmployeeStatus> statuses;
  final List<EmploymentType> employmentTypes;
  final double maxSalary;
  final double minSalary;
  final int totalEmployees;

  EmployeeFilterOptions({
    required this.departments,
    required this.statuses,
    required this.employmentTypes,
    required this.maxSalary,
    required this.minSalary,
    required this.totalEmployees,
  });
}

class AppliedEmployeeFilter {
  String? department;
  EmployeeStatus? status;
  EmploymentType? employmentType;
  double? minSalary;
  double? maxSalary;

  AppliedEmployeeFilter({
    this.department,
    this.status,
    this.employmentType,
    this.minSalary,
    this.maxSalary,
  });

  bool get hasAny =>
      department != null ||
      status != null ||
      employmentType != null ||
      minSalary != null ||
      maxSalary != null;

  void clear() {
    department = null;
    status = null;
    employmentType = null;
    minSalary = null;
    maxSalary = null;
  }

  AppliedEmployeeFilter copy() => AppliedEmployeeFilter(
    department: department,
    status: status,
    employmentType: employmentType,
    minSalary: minSalary,
    maxSalary: maxSalary,
  );
}

class EmployeeFilterService {
  final EmployeeRepository _repository;

  EmployeeFilterService(this._repository);

  Future<EmployeeFilterOptions> getFilterOptions() async {
    final all = await _repository.getAll();

    final departments = all.map((e) => e.department).toSet().toList()..sort();
    final statuses = EmployeeStatus.values.toList();
    final employmentTypes = EmploymentType.values.toList();
    final maxSalary = all.isEmpty ? 0.0 : all.map((e) => e.salary).reduce((a, b) => a > b ? a : b);
    final minSalary = all.isEmpty ? 0.0 : all.map((e) => e.salary).reduce((a, b) => a < b ? a : b);

    return EmployeeFilterOptions(
      departments: departments,
      statuses: statuses,
      employmentTypes: employmentTypes,
      maxSalary: maxSalary,
      minSalary: minSalary,
      totalEmployees: all.length,
    );
  }

  Future<List<EmployeeModel>> applyFilter({
    required List<EmployeeModel> employees,
    required AppliedEmployeeFilter filter,
  }) async {
    var filtered = List<EmployeeModel>.from(employees);

    if (filter.department != null) {
      filtered = filtered.where((e) => e.department == filter.department).toList();
    }

    if (filter.status != null) {
      filtered = filtered.where((e) => e.status == filter.status).toList();
    }

    if (filter.employmentType != null) {
      filtered = filtered.where((e) => e.employmentType == filter.employmentType).toList();
    }

    if (filter.minSalary != null) {
      filtered = filtered.where((e) => e.salary >= filter.minSalary!).toList();
    }

    if (filter.maxSalary != null) {
      filtered = filtered.where((e) => e.salary <= filter.maxSalary!).toList();
    }

    return filtered;
  }

  int countActive(List<EmployeeModel> employees) {
    return employees.where((e) => e.status == EmployeeStatus.active).length;
  }

  int countByDepartment(List<EmployeeModel> employees, String department) {
    return employees.where((e) => e.department == department).length;
  }

  int countByEmploymentType(List<EmployeeModel> employees, EmploymentType type) {
    return employees.where((e) => e.employmentType == type).length;
  }

  Map<String, int> getDepartmentDistribution(List<EmployeeModel> employees) {
    final map = <String, int>{};
    for (final e in employees) {
      map[e.department] = (map[e.department] ?? 0) + 1;
    }
    return map;
  }

  Map<EmployeeStatus, int> getStatusDistribution(List<EmployeeModel> employees) {
    final map = <EmployeeStatus, int>{};
    for (final status in EmployeeStatus.values) {
      map[status] = 0;
    }
    for (final e in employees) {
      map[e.status] = (map[e.status] ?? 0) + 1;
    }
    return map;
  }
}
