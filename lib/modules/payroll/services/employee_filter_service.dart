import 'package:SmartERP/core/models/employee_model.dart';
import 'package:SmartERP/modules/payroll/repositories/employee_repository.dart';

class EmployeeFilterService {
  final EmployeeRepository _repository;

  EmployeeFilterService(this._repository);

  Future<List<EmployeeModel>> filterByDepartment(String department) async {
    final all = await _repository.getAll();
    return all
        .where((e) =>
            e.department.toLowerCase() == department.toLowerCase())
        .toList();
  }

  Future<List<EmployeeModel>> filterByStatus(EmployeeStatus status) async {
    final all = await _repository.getAll();
    return all.where((e) => e.status == status).toList();
  }

  Future<List<EmployeeModel>> filterByType(EmploymentType type) async {
    final all = await _repository.getAll();
    return all.where((e) => e.employmentType == type).toList();
  }
}
