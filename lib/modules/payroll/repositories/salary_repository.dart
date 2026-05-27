import 'package:smarterp/core/exceptions/app_exception.dart';
import 'package:smarterp/core/models/salary_model.dart';
import 'package:smarterp/core/models/salary_history_model.dart';
import 'package:smarterp/core/storage/storage_service.dart';
import 'package:smarterp/core/utils/logger.dart';

class SalaryRepository {
  final StorageService<Map<dynamic, dynamic>> _salaryStorage;
  final StorageService<Map<dynamic, dynamic>> _historyStorage;

  SalaryRepository({
    required StorageService<Map<dynamic, dynamic>> salaryStorage,
    required StorageService<Map<dynamic, dynamic>> historyStorage,
  })  : _salaryStorage = salaryStorage,
        _historyStorage = historyStorage;

  Future<List<SalaryModel>> getAll() async {
    try {
      final data = _salaryStorage.getAll();
      return data
          .map((item) => SalaryModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } catch (e, stackTrace) {
      Logger.error('Failed to get all salaries', e, stackTrace);
      throw StorageException('Failed to retrieve salaries');
    }
  }

  Future<SalaryModel?> getById(String id) async {
    try {
      final data = _salaryStorage.get(id);
      if (data == null) return null;
      return SalaryModel.fromJson(Map<String, dynamic>.from(data));
    } catch (e, stackTrace) {
      Logger.error('Failed to get salary by id: $id', e, stackTrace);
      return null;
    }
  }

  Future<void> save(SalaryModel salary) async {
    try {
      await _salaryStorage.save(salary.id, salary.toJson());
      Logger.success('Salary saved: ${salary.employeeName} - ${salary.month}/${salary.year}');
    } catch (e, stackTrace) {
      Logger.error('Failed to save salary', e, stackTrace);
      throw StorageException('Failed to save salary');
    }
  }

  Future<void> update(SalaryModel salary) async {
    try {
      await _salaryStorage.save(salary.id, salary.toJson());
      Logger.success('Salary updated: ${salary.employeeName} - ${salary.month}/${salary.year}');
    } catch (e, stackTrace) {
      Logger.error('Failed to update salary', e, stackTrace);
      throw StorageException('Failed to update salary');
    }
  }

  Future<void> delete(String id) async {
    try {
      await _salaryStorage.delete(id);
      Logger.success('Salary deleted: $id');
    } catch (e, stackTrace) {
      Logger.error('Failed to delete salary', e, stackTrace);
      throw StorageException('Failed to delete salary');
    }
  }

  Future<List<SalaryModel>> getByEmployeeId(String employeeId) async {
    try {
      final all = await getAll();
      return all.where((s) => s.employeeId == employeeId).toList();
    } catch (e, stackTrace) {
      Logger.error('Failed to get salaries by employee', e, stackTrace);
      return [];
    }
  }

  Future<List<SalaryModel>> getByMonth(int month, int year) async {
    try {
      final all = await getAll();
      return all.where((s) => s.month == month && s.year == year).toList();
    } catch (e, stackTrace) {
      Logger.error('Failed to get salaries by month', e, stackTrace);
      return [];
    }
  }

  Future<SalaryModel?> getByEmployeeAndMonth(
    String employeeId, int month, int year,
  ) async {
    try {
      final all = await getAll();
      return all.cast<SalaryModel?>().firstWhere(
        (s) => s!.employeeId == employeeId && s.month == month && s.year == year,
        orElse: () => null,
      );
    } catch (e, stackTrace) {
      Logger.error('Failed to get salary by employee and month', e, stackTrace);
      return null;
    }
  }

  Future<List<SalaryModel>> getByStatus(SalaryStatus status) async {
    try {
      final all = await getAll();
      return all.where((s) => s.status == status).toList();
    } catch (e, stackTrace) {
      Logger.error('Failed to get salaries by status', e, stackTrace);
      return [];
    }
  }

  Future<List<SalaryModel>> getPendingSalaries() async {
    try {
      final all = await getAll();
      return all.where((s) =>
          s.status == SalaryStatus.pending || s.status == SalaryStatus.overdue).toList();
    } catch (e, stackTrace) {
      Logger.error('Failed to get pending salaries', e, stackTrace);
      return [];
    }
  }

  Future<List<SalaryHistoryModel>> getHistoryBySalaryId(String salaryId) async {
    try {
      final data = _historyStorage.getAll();
      return data
          .map((item) => SalaryHistoryModel.fromJson(Map<String, dynamic>.from(item)))
          .where((h) => h.salaryId == salaryId)
          .toList();
    } catch (e, stackTrace) {
      Logger.error('Failed to get salary history', e, stackTrace);
      return [];
    }
  }

  Future<List<SalaryHistoryModel>> getHistoryByEmployeeId(String employeeId) async {
    try {
      final data = _historyStorage.getAll();
      return data
          .map((item) => SalaryHistoryModel.fromJson(Map<String, dynamic>.from(item)))
          .where((h) => h.employeeId == employeeId)
          .toList();
    } catch (e, stackTrace) {
      Logger.error('Failed to get salary history by employee', e, stackTrace);
      return [];
    }
  }

  Future<void> saveHistory(SalaryHistoryModel history) async {
    try {
      await _historyStorage.save(history.id, history.toJson());
      Logger.success('Salary history saved: ${history.amount} - ${history.paymentMethod.displayName}');
    } catch (e, stackTrace) {
      Logger.error('Failed to save salary history', e, stackTrace);
      throw StorageException('Failed to save salary history');
    }
  }

  Future<double> getTotalPaidForMonth(int month, int year) async {
    try {
      final all = await getAll();
      double total = 0;
      for (final s in all) {
        if (s.month == month && s.year == year && s.isFullyPaid) {
          total += s.netSalary;
        }
      }
      return total;
    } catch (e, stackTrace) {
      Logger.error('Failed to get total paid', e, stackTrace);
      return 0;
    }
  }

  Future<double> getTotalPendingForMonth(int month, int year) async {
    try {
      final all = await getAll();
      double total = 0;
      for (final s in all) {
        if (s.month == month && s.year == year && !s.isFullyPaid) {
          total += s.pendingAmount;
        }
      }
      return total;
    } catch (e, stackTrace) {
      Logger.error('Failed to get total pending', e, stackTrace);
      return 0;
    }
  }

  Future<int> getSalaryCountByStatus(SalaryStatus status) async {
    try {
      final all = await getAll();
      return all.where((s) => s.status == status).length;
    } catch (e, stackTrace) {
      Logger.error('Failed to get salary count by status', e, stackTrace);
      return 0;
    }
  }
}
