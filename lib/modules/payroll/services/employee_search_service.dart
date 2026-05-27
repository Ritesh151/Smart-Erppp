import 'package:smarterp/core/models/employee_model.dart';
import 'package:smarterp/modules/payroll/repositories/employee_repository.dart';

class EmployeeSearchRequest {
  String? keyword;
  String? department;
  EmployeeStatus? status;
  EmploymentType? employmentType;
  double? minSalary;
  double? maxSalary;
  DateTime? dateOfJoiningFrom;
  DateTime? dateOfJoiningTo;

  EmployeeSearchRequest({
    this.keyword,
    this.department,
    this.status,
    this.employmentType,
    this.minSalary,
    this.maxSalary,
    this.dateOfJoiningFrom,
    this.dateOfJoiningTo,
  });

  bool get hasCriteria =>
      keyword != null ||
      department != null ||
      status != null ||
      employmentType != null ||
      minSalary != null ||
      maxSalary != null ||
      dateOfJoiningFrom != null ||
      dateOfJoiningTo != null;
}

class EmployeeSearchResult {
  final List<EmployeeModel> employees;
  final int totalCount;
  final int filteredCount;

  EmployeeSearchResult({
    required this.employees,
    required this.totalCount,
    required this.filteredCount,
  });
}

class EmployeeSearchService {
  final EmployeeRepository _repository;

  EmployeeSearchService(this._repository);

  Future<EmployeeSearchResult> search(EmployeeSearchRequest request) async {
    final all = await _repository.getAll();
    var filtered = List<EmployeeModel>.from(all);

    if (request.keyword != null && request.keyword!.trim().isNotEmpty) {
      final q = request.keyword!.toLowerCase().trim();
      filtered = filtered.where((e) =>
          e.fullName.toLowerCase().contains(q) ||
          e.employeeCode.toLowerCase().contains(q) ||
          e.email.toLowerCase().contains(q) ||
          e.phone.toLowerCase().contains(q) ||
          e.designation.toLowerCase().contains(q) ||
          e.department.toLowerCase().contains(q)).toList();
    }

    if (request.department != null) {
      filtered = filtered.where((e) =>
          e.department.toLowerCase() == request.department!.toLowerCase()).toList();
    }

    if (request.status != null) {
      filtered = filtered.where((e) => e.status == request.status).toList();
    }

    if (request.employmentType != null) {
      filtered = filtered.where((e) => e.employmentType == request.employmentType).toList();
    }

    if (request.minSalary != null) {
      filtered = filtered.where((e) => e.salary >= request.minSalary!).toList();
    }

    if (request.maxSalary != null) {
      filtered = filtered.where((e) => e.salary <= request.maxSalary!).toList();
    }

    if (request.dateOfJoiningFrom != null) {
      filtered = filtered.where((e) =>
          !e.dateOfJoining.isBefore(request.dateOfJoiningFrom!)).toList();
    }

    if (request.dateOfJoiningTo != null) {
      filtered = filtered.where((e) =>
          !e.dateOfJoining.isAfter(request.dateOfJoiningTo!)).toList();
    }

    return EmployeeSearchResult(
      employees: filtered,
      totalCount: all.length,
      filteredCount: filtered.length,
    );
  }

  Future<List<EmployeeModel>> quickSearch(String query) async {
    if (query.trim().isEmpty) return [];

    final request = EmployeeSearchRequest(keyword: query);
    final result = await search(request);
    return result.employees;
  }

  Future<List<EmployeeModel>> searchByDepartment(String department) async {
    final request = EmployeeSearchRequest(department: department);
    final result = await search(request);
    return result.employees;
  }

  Future<List<EmployeeModel>> searchByStatus(EmployeeStatus status) async {
    final request = EmployeeSearchRequest(status: status);
    final result = await search(request);
    return result.employees;
  }

  Future<List<EmployeeModel>> searchByEmploymentType(EmploymentType type) async {
    final request = EmployeeSearchRequest(employmentType: type);
    final result = await search(request);
    return result.employees;
  }

  Future<List<EmployeeModel>> searchBySalaryRange(double min, double max) async {
    final request = EmployeeSearchRequest(minSalary: min, maxSalary: max);
    final result = await search(request);
    return result.employees;
  }
}
