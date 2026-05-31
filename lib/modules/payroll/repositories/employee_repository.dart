import 'package:siddhivinayak_enterprise/core/models/employee_model.dart';
import 'package:siddhivinayak_enterprise/core/storage/storage_service.dart';
import 'package:siddhivinayak_enterprise/core/utils/logger.dart';

class EmployeeRepository {
  final StorageService<Map<dynamic, dynamic>> _storage;

  EmployeeRepository(this._storage);

  Future<List<EmployeeModel>> getAll() async {
    try {
      final data = _storage.getAll();
      return data
          .map((item) =>
              EmployeeModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } catch (e, stackTrace) {
      Logger.error('Failed to get all employees', e, stackTrace);
      return [];
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
      Logger.success('Employee saved: ${employee.id}');
    } catch (e, stackTrace) {
      Logger.error('Failed to save employee', e, stackTrace);
      rethrow;
    }
  }

  Future<void> update(EmployeeModel employee) async {
    try {
      await _storage.update(employee.id, employee.toJson());
      Logger.success('Employee updated: ${employee.id}');
    } catch (e, stackTrace) {
      Logger.error('Failed to update employee', e, stackTrace);
      rethrow;
    }
  }

  Future<void> delete(String id) async {
    try {
      await _storage.delete(id);
      Logger.success('Employee deleted: $id');
    } catch (e, stackTrace) {
      Logger.error('Failed to delete employee', e, stackTrace);
      rethrow;
    }
  }

  Future<List<EmployeeModel>> search(String query) async {
    try {
      final employees = await getAll();
      final q = query.toLowerCase();
      return employees.where((e) {
        return e.fullName.toLowerCase().contains(q) ||
            e.employeeCode.toLowerCase().contains(q) ||
            e.designation.toLowerCase().contains(q) ||
            e.department.toLowerCase().contains(q) ||
            e.phone.contains(q);
      }).toList();
    } catch (e, stackTrace) {
      Logger.error('Failed to search employees', e, stackTrace);
      return [];
    }
  }
}
