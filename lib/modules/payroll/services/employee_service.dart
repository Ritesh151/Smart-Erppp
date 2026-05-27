import 'package:smarterp/core/exceptions/app_exception.dart';
import 'package:smarterp/core/models/employee_model.dart';
import 'package:smarterp/core/utils/logger.dart';
import 'package:smarterp/modules/payroll/repositories/employee_repository.dart';

class EmployeeService {
  final EmployeeRepository _repository;

  EmployeeService(this._repository);

  Future<List<EmployeeModel>> getAllEmployees() async {
    try {
      return await _repository.getAll();
    } catch (e, stackTrace) {
      Logger.error('Failed to get all employees', e, stackTrace);
      rethrow;
    }
  }

  Future<EmployeeModel?> getEmployeeById(String id) async {
    try {
      return await _repository.getById(id);
    } catch (e, stackTrace) {
      Logger.error('Failed to get employee by id', e, stackTrace);
      return null;
    }
  }

  Future<EmployeeModel> createEmployee({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    String? address,
    required String department,
    required String designation,
    required DateTime dateOfJoining,
    DateTime? dateOfBirth,
    required double salary,
    required EmploymentType employmentType,
    String? bankAccountNumber,
    String? bankName,
    String? ifscCode,
    String? panNumber,
    String? aadharNumber,
  }) async {
    try {
      if (firstName.trim().isEmpty) throw ValidationException('First name is required');
      if (lastName.trim().isEmpty) throw ValidationException('Last name is required');
      if (email.trim().isEmpty) throw ValidationException('Email is required');
      if (phone.trim().isEmpty) throw ValidationException('Phone is required');
      if (department.trim().isEmpty) throw ValidationException('Department is required');
      if (designation.trim().isEmpty) throw ValidationException('Designation is required');
      if (salary <= 0) throw ValidationException('Salary must be greater than 0');

      final employeeCode = await _repository.getNextEmployeeCode();
      final now = DateTime.now();

      final employee = EmployeeModel(
        id: _generateId(),
        employeeCode: employeeCode,
        firstName: firstName.trim(),
        lastName: lastName.trim(),
        email: email.trim().toLowerCase(),
        phone: phone.trim(),
        address: address?.trim(),
        department: department.trim(),
        designation: designation.trim(),
        dateOfJoining: dateOfJoining,
        dateOfBirth: dateOfBirth,
        salary: salary,
        employmentType: employmentType,
        status: EmployeeStatus.active,
        bankAccountNumber: bankAccountNumber?.trim(),
        bankName: bankName?.trim(),
        ifscCode: ifscCode?.trim(),
        panNumber: panNumber?.trim(),
        aadharNumber: aadharNumber?.trim(),
        createdAt: now,
        updatedAt: now,
      );

      await _repository.save(employee);
      Logger.success('Employee created: ${employee.fullName} (${employee.employeeCode})');
      return employee;
    } on ValidationException {
      rethrow;
    } catch (e, stackTrace) {
      Logger.error('Failed to create employee', e, stackTrace);
      rethrow;
    }
  }

  Future<EmployeeModel> updateEmployee({
    required String id,
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    String? address,
    required String department,
    required String designation,
    required DateTime dateOfJoining,
    DateTime? dateOfBirth,
    required double salary,
    required EmploymentType employmentType,
    required EmployeeStatus status,
    String? bankAccountNumber,
    String? bankName,
    String? ifscCode,
    String? panNumber,
    String? aadharNumber,
  }) async {
    try {
      final existing = await _repository.getById(id);
      if (existing == null) throw NotFoundException('Employee not found');

      final updated = existing.copyWith(
        firstName: firstName.trim(),
        lastName: lastName.trim(),
        email: email.trim().toLowerCase(),
        phone: phone.trim(),
        address: address?.trim(),
        department: department.trim(),
        designation: designation.trim(),
        dateOfJoining: dateOfJoining,
        dateOfBirth: dateOfBirth,
        salary: salary,
        employmentType: employmentType,
        status: status,
        bankAccountNumber: bankAccountNumber?.trim(),
        bankName: bankName?.trim(),
        ifscCode: ifscCode?.trim(),
        panNumber: panNumber?.trim(),
        aadharNumber: aadharNumber?.trim(),
        updatedAt: DateTime.now(),
      );

      await _repository.update(updated);
      Logger.success('Employee updated: ${updated.fullName}');
      return updated;
    } on AppException {
      rethrow;
    } catch (e, stackTrace) {
      Logger.error('Failed to update employee', e, stackTrace);
      rethrow;
    }
  }

  Future<void> deleteEmployee(String id) async {
    try {
      await _repository.delete(id);
      Logger.success('Employee deleted: $id');
    } catch (e, stackTrace) {
      Logger.error('Failed to delete employee', e, stackTrace);
      rethrow;
    }
  }

  Future<List<EmployeeModel>> searchEmployees(String query) async {
    try {
      return await _repository.search(query);
    } catch (e, stackTrace) {
      Logger.error('Failed to search employees', e, stackTrace);
      return [];
    }
  }

  Future<List<EmployeeModel>> getEmployeesByDepartment(String department) async {
    try {
      return await _repository.filterByDepartment(department);
    } catch (e, stackTrace) {
      Logger.error('Failed to get employees by department', e, stackTrace);
      return [];
    }
  }

  Future<List<EmployeeModel>> getActiveEmployees() async {
    try {
      return await _repository.filterByStatus(EmployeeStatus.active);
    } catch (e, stackTrace) {
      Logger.error('Failed to get active employees', e, stackTrace);
      return [];
    }
  }

  Future<List<String>> getAllDepartments() async {
    try {
      return await _repository.getAllDepartments();
    } catch (e, stackTrace) {
      Logger.error('Failed to get departments', e, stackTrace);
      return [];
    }
  }

  String _generateId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp % 10000).toString().padLeft(4, '0');
    return 'EMP-$timestamp-$random';
  }
}
