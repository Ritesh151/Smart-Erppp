import 'package:smarterp/core/exceptions/app_exception.dart';
import 'package:smarterp/core/models/expense_report_model.dart';
import 'package:smarterp/core/models/stock_report_model.dart';
import 'package:smarterp/core/storage/storage_service.dart';
import 'package:smarterp/core/utils/logger.dart';

class ExpenseReportRepository {
  final StorageService<Map<dynamic, dynamic>> _expenseStorage;
  final StorageService<Map<dynamic, dynamic>> _stockStorage;

  ExpenseReportRepository({
    required StorageService<Map<dynamic, dynamic>> expenseStorage,
    required StorageService<Map<dynamic, dynamic>> stockStorage,
  })  : _expenseStorage = expenseStorage,
        _stockStorage = stockStorage;

  Future<List<ExpenseReportModel>> getAllExpenseReports() async {
    try {
      final data = _expenseStorage.getAll();
      return data
          .map((item) => ExpenseReportModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } catch (e, stackTrace) {
      Logger.error('Failed to get all expense reports', e, stackTrace);
      throw StorageException('Failed to retrieve expense reports');
    }
  }

  Future<ExpenseReportModel?> getExpenseReportById(String id) async {
    try {
      final data = _expenseStorage.get(id);
      if (data == null) return null;
      return ExpenseReportModel.fromJson(Map<String, dynamic>.from(data));
    } catch (e, stackTrace) {
      Logger.error('Failed to get expense report by id: $id', e, stackTrace);
      return null;
    }
  }

  Future<ExpenseReportModel?> getExpenseReportByMonth(int month, int year) async {
    try {
      final all = await getAllExpenseReports();
      return all.cast<ExpenseReportModel?>().firstWhere(
        (r) => r!.month == month && r.year == year,
        orElse: () => null,
      );
    } catch (e, stackTrace) {
      Logger.error('Failed to get expense report by month', e, stackTrace);
      return null;
    }
  }

  Future<void> saveExpenseReport(ExpenseReportModel report) async {
    try {
      await _expenseStorage.save(report.id, report.toJson());
      Logger.success('Expense report saved: ${report.month}/${report.year}');
    } catch (e, stackTrace) {
      Logger.error('Failed to save expense report', e, stackTrace);
      throw StorageException('Failed to save expense report');
    }
  }

  Future<void> updateExpenseReport(ExpenseReportModel report) async {
    try {
      await _expenseStorage.save(report.id, report.toJson());
      Logger.success('Expense report updated: ${report.month}/${report.year}');
    } catch (e, stackTrace) {
      Logger.error('Failed to update expense report', e, stackTrace);
      throw StorageException('Failed to update expense report');
    }
  }

  Future<void> deleteExpenseReport(String id) async {
    try {
      await _expenseStorage.delete(id);
      Logger.success('Expense report deleted: $id');
    } catch (e, stackTrace) {
      Logger.error('Failed to delete expense report', e, stackTrace);
      throw StorageException('Failed to delete expense report');
    }
  }

  Future<List<StockReportModel>> getAllStockReports() async {
    try {
      final data = _stockStorage.getAll();
      return data
          .map((item) => StockReportModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } catch (e, stackTrace) {
      Logger.error('Failed to get all stock reports', e, stackTrace);
      throw StorageException('Failed to retrieve stock reports');
    }
  }

  Future<StockReportModel?> getStockReportById(String id) async {
    try {
      final data = _stockStorage.get(id);
      if (data == null) return null;
      return StockReportModel.fromJson(Map<String, dynamic>.from(data));
    } catch (e, stackTrace) {
      Logger.error('Failed to get stock report by id: $id', e, stackTrace);
      return null;
    }
  }

  Future<StockReportModel?> getStockReportByMonth(int month, int year) async {
    try {
      final all = await getAllStockReports();
      return all.cast<StockReportModel?>().firstWhere(
        (r) => r!.month == month && r.year == year,
        orElse: () => null,
      );
    } catch (e, stackTrace) {
      Logger.error('Failed to get stock report by month', e, stackTrace);
      return null;
    }
  }

  Future<void> saveStockReport(StockReportModel report) async {
    try {
      await _stockStorage.save(report.id, report.toJson());
      Logger.success('Stock report saved: ${report.month}/${report.year}');
    } catch (e, stackTrace) {
      Logger.error('Failed to save stock report', e, stackTrace);
      throw StorageException('Failed to save stock report');
    }
  }

  Future<void> updateStockReport(StockReportModel report) async {
    try {
      await _stockStorage.save(report.id, report.toJson());
      Logger.success('Stock report updated: ${report.month}/${report.year}');
    } catch (e, stackTrace) {
      Logger.error('Failed to update stock report', e, stackTrace);
      throw StorageException('Failed to update stock report');
    }
  }

  Future<void> deleteStockReport(String id) async {
    try {
      await _stockStorage.delete(id);
      Logger.success('Stock report deleted: $id');
    } catch (e, stackTrace) {
      Logger.error('Failed to delete stock report', e, stackTrace);
      throw StorageException('Failed to delete stock report');
    }
  }

  Future<List<ExpenseReportModel>> getExpenseReportsByYear(int year) async {
    try {
      final all = await getAllExpenseReports();
      return all.where((r) => r.year == year).toList();
    } catch (e, stackTrace) {
      Logger.error('Failed to get expense reports by year', e, stackTrace);
      return [];
    }
  }

  Future<List<StockReportModel>> getStockReportsByYear(int year) async {
    try {
      final all = await getAllStockReports();
      return all.where((r) => r.year == year).toList();
    } catch (e, stackTrace) {
      Logger.error('Failed to get stock reports by year', e, stackTrace);
      return [];
    }
  }
}
