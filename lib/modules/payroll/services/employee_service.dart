import 'package:siddhivinayak_enterprise/core/models/employee_model.dart';
import 'package:siddhivinayak_enterprise/modules/payroll/repositories/employee_repository.dart';

class EmployeeService {
  final EmployeeRepository _repository;

  EmployeeService(this._repository);

  Future<List<EmployeeModel>> getAllEmployees() => _repository.getAll();

  Future<EmployeeModel?> getEmployee(String id) => _repository.getById(id);

  Future<void> saveEmployee(EmployeeModel employee) =>
      _repository.save(employee);

  Future<void> updateEmployee(EmployeeModel employee) =>
      _repository.update(employee);

  Future<void> deleteEmployee(String id) => _repository.delete(id);

  Future<List<EmployeeModel>> searchEmployees(String query) =>
      _repository.search(query);
}
