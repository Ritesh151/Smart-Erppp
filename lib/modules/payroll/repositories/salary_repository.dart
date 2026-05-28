import 'package:SmartERP/core/models/salary_model.dart';
import 'package:SmartERP/core/models/salary_history_model.dart';
import 'package:SmartERP/core/storage/storage_service.dart';
import 'package:SmartERP/core/utils/logger.dart';

class SalaryRepository {
  final StorageService<Map<dynamic, dynamic>> _salaryStorage;
  final StorageService<Map<dynamic, dynamic>> _historyStorage;

  SalaryRepository({
    required StorageService<Map<dynamic, dynamic>> salaryStorage,
    required StorageService<Map<dynamic, dynamic>> historyStorage,
  })  : _salaryStorage = salaryStorage,
        _historyStorage = historyStorage;

  // Salary CRUD
  Future<List<SalaryModel>> getAllSalaries() async {
    try {
      final data = _salaryStorage.getAll();
      return data
          .map((item) =>
              SalaryModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } catch (e, stackTrace) {
      Logger.error('Failed to get all salaries', e, stackTrace);
      return [];
    }
  }

  Future<SalaryModel?> getSalaryById(String id) async {
    try {
      final data = _salaryStorage.get(id);
      if (data == null) return null;
      return SalaryModel.fromJson(Map<String, dynamic>.from(data));
    } catch (e, stackTrace) {
      Logger.error('Failed to get salary by id: $id', e, stackTrace);
      return null;
    }
  }

  Future<void> saveSalary(SalaryModel salary) async {
    try {
      await _salaryStorage.save(salary.id, salary.toJson());
      Logger.success('Salary saved: ${salary.id}');
    } catch (e, stackTrace) {
      Logger.error('Failed to save salary', e, stackTrace);
      rethrow;
    }
  }

  Future<void> updateSalary(SalaryModel salary) async {
    try {
      await _salaryStorage.update(salary.id, salary.toJson());
      Logger.success('Salary updated: ${salary.id}');
    } catch (e, stackTrace) {
      Logger.error('Failed to update salary', e, stackTrace);
      rethrow;
    }
  }

  // History CRUD
  Future<List<SalaryHistoryModel>> getAllHistory() async {
    try {
      final data = _historyStorage.getAll();
      return data
          .map((item) =>
              SalaryHistoryModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } catch (e, stackTrace) {
      Logger.error('Failed to get salary history', e, stackTrace);
      return [];
    }
  }

  Future<void> saveHistory(SalaryHistoryModel history) async {
    try {
      await _historyStorage.save(history.id, history.toJson());
      Logger.success('Salary history saved: ${history.id}');
    } catch (e, stackTrace) {
      Logger.error('Failed to save salary history', e, stackTrace);
      rethrow;
    }
  }

  Future<List<SalaryHistoryModel>> getHistoryForEmployee(String employeeId) async {
    final all = await getAllHistory();
    return all.where((h) => h.employeeId == employeeId).toList();
  }

  Future<List<SalaryModel>> getSalariesForMonth(int month, int year) async {
    final all = await getAllSalaries();
    return all.where((s) => s.month == month && s.year == year).toList();
  }
}
