import 'package:SmartERP/core/models/salary_model.dart';
import 'package:SmartERP/core/models/salary_history_model.dart';
import 'package:SmartERP/modules/payroll/repositories/salary_repository.dart';

class SalaryService {
  final SalaryRepository _repository;

  SalaryService(this._repository);

  Future<List<SalaryModel>> getAllSalaries() => _repository.getAllSalaries();

  Future<SalaryModel?> getSalary(String id) => _repository.getSalaryById(id);

  Future<void> saveSalary(SalaryModel salary) => _repository.saveSalary(salary);

  Future<void> updateSalary(SalaryModel salary) =>
      _repository.updateSalary(salary);

  Future<List<SalaryModel>> getSalariesForMonth(int month, int year) =>
      _repository.getSalariesForMonth(month, year);

  Future<List<SalaryHistoryModel>> getAllHistory() =>
      _repository.getAllHistory();

  Future<void> saveHistory(SalaryHistoryModel history) =>
      _repository.saveHistory(history);

  Future<List<SalaryHistoryModel>> getHistoryForEmployee(String employeeId) =>
      _repository.getHistoryForEmployee(employeeId);
}
