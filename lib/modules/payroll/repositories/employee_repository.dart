import 'package:smarterp/core/exceptions/app_exception.dart';
import 'package:smarterp/core/models/employee_model.dart';
import 'package:smarterp/core/storage/storage_service.dart';
import 'package:smarterp/core/utils/logger.dart';

class EmployeeRepository {
  final StorageService<Map<dynamic, dynamic>> _storage;

  EmployeeRepository(this._storage);

  Future<List<EmployeeModel>> getAll() async {
    try {
      final data = _storage.getAll();
      return data
          .map((item) => EmployeeModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } catch (e, stackTrace) {
      Logger.error('Failed to get all employees', e, stackTrace);
      throw StorageException('Failed to retrieve employees');
    }
  }

  Future<EmployeeModel?> getById(String id) async {
    try {
      final data = _storage.get(id);
      if (data == null) return null;
      return EmployeeModel.fromJson(Map<String, dynamic>.from(data));
    } catch (e, stackTrace) {
      Logger.error('Failed to get employee by id: $id', e, stackTrace);
      return null;
    }
  }

  Future<void> save(EmployeeModel employee) async {
    try {
      await _storage.save(employee.id, employee.toJson());
      Logger.success('Employee saved: ${employee.fullName}');
    } catch (e, stackTrace) {
      Logger.error('Failed to save employee', e, stackTrace);
      throw StorageException('Failed to save employee');
    }
  }

  Future<void> update(EmployeeModel employee) async {
    try {
      await _storage.save(employee.id, employee.toJson());
      Logger.success('Employee updated: ${employee.fullName}');
    } catch (e, stackTrace) {
      Logger.error('Failed to update employee', e, stackTrace);
      throw StorageException('Failed to update employee');
    }
  }

  Future<void> delete(String id) async {
    try {
      await _storage.delete(id);
      Logger.success('Employee deleted: $id');
    } catch (e, stackTrace) {
      Logger.error('Failed to delete employee', e, stackTrace);
      throw StorageException('Failed to delete employee');
    }
  }

  Future<List<EmployeeModel>> search(String query) async {
    try {
      final all = await getAll();
      if (query.trim().isEmpty) return all;
      final q = query.trim().toLowerCase();
      return all.where((e) {
        return e.fullName.toLowerCase().contains(q) ||
            e.employeeCode.toLowerCase().contains(q) ||
            e.phone.toLowerCase().contains(q) ||
            e.email.toLowerCase().contains(q) ||
            e.designation.toLowerCase().contains(q) ||
            e.department.toLowerCase().contains(q);
      }).toList();
    } catch (e, stackTrace) {
      Logger.error('Failed to search employees', e, stackTrace);
      return [];
    }
  }

  Future<List<EmployeeModel>> filterByDepartment(String department) async {
    try {
      final all = await getAll();
      return all.where((e) => e.department == department).toList();
    } catch (e, stackTrace) {
      Logger.error('Failed to filter employees by department', e, stackTrace);
      return [];
    }
  }

  Future<List<EmployeeModel>> filterByStatus(EmployeeStatus status) async {
    try {
      final all = await getAll();
      return all.where((e) => e.status == status).toList();
    } catch (e, stackTrace) {
      Logger.error('Failed to filter employees by status', e, stackTrace);
      return [];
    }
  }

  Future<List<EmployeeModel>> filterByEmploymentType(EmploymentType type) async {
    try {
      final all = await getAll();
      return all.where((e) => e.employmentType == type).toList();
    } catch (e, stackTrace) {
      Logger.error('Failed to filter employees by type', e, stackTrace);
      return [];
    }
  }

  Future<bool> employeeCodeExists(String code, {String? excludeId}) async {
    try {
      final all = await getAll();
      return all.any((e) =>
          e.employeeCode == code && (excludeId == null || e.id != excludeId));
    } catch (e, stackTrace) {
      Logger.error('Failed to check employee code', e, stackTrace);
      return false;
    }
  }

  Future<String> getNextEmployeeCode() async {
    try {
      final all = await getAll();
      if (all.isEmpty) return 'EMP-0001';
      final maxCode = all.map((e) {
        final parts = e.employeeCode.split('-');
        if (parts.length == 2) return int.tryParse(parts[1]) ?? 0;
        return 0;
      }).reduce((a, b) => a > b ? a : b);
      return 'EMP-${(maxCode + 1).toString().padLeft(4, '0')}';
    } catch (e, stackTrace) {
      Logger.error('Failed to generate employee code', e, stackTrace);
      return 'EMP-0001';
    }
  }

  Future<List<String>> getAllDepartments() async {
    try {
      final all = await getAll();
      return all.map((e) => e.department).toSet().toList()..sort();
    } catch (e, stackTrace) {
      Logger.error('Failed to get departments', e, stackTrace);
      return [];
    }
  }

  Future<int> getTotalCount() async {
    try {
      return _storage.getAll().length;
    } catch (e, stackTrace) {
      Logger.error('Failed to get employee count', e, stackTrace);
      return 0;
    }
  }

  Future<int> getCountByStatus(EmployeeStatus status) async {
    try {
      final all = await getAll();
      return all.where((e) => e.status == status).length;
    } catch (e, stackTrace) {
      Logger.error('Failed to get count by status', e, stackTrace);
      return 0;
    }
  }

  Future<double> getTotalSalary() async {
    try {
      final all = await getAll();
      double total = 0;
      for (final e in all) {
        total += e.salary;
      }
      return total;
    } catch (e, stackTrace) {
      Logger.error('Failed to get total salary', e, stackTrace);
      return 0;
    }
  }
}
