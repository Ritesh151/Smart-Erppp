import 'package:SmartERP/core/models/employee_model.dart';
import 'package:SmartERP/modules/payroll/repositories/employee_repository.dart';

class EmployeeSearchService {
  final EmployeeRepository _repository;

  EmployeeSearchService(this._repository);

  Future<List<EmployeeModel>> search(String query) =>
      _repository.search(query);
}
