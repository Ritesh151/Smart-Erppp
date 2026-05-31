import 'package:siddhivinayak_enterprise/core/exceptions/app_exception.dart';
import 'package:siddhivinayak_enterprise/core/models/expense_model.dart';
import 'package:siddhivinayak_enterprise/core/storage/storage_service.dart';
import 'package:siddhivinayak_enterprise/core/utils/logger.dart';

class ExpenseRepository {
  final StorageService<Map<dynamic, dynamic>> _storage;

  ExpenseRepository(this._storage);

  Future<List<ExpenseModel>> getAll() async {
    try {
      final data = _storage.getAll();
      return data
          .map((item) => ExpenseModel.fromJson(Map<String, dynamic>.from(item)))
          .toList()
        ..sort((a, b) => b.expenseDate.compareTo(a.expenseDate));
    } catch (e, stackTrace) {
      Logger.error('Failed to get expenses', e, stackTrace);
      throw StorageException('Failed to retrieve expenses');
    }
  }

  Future<ExpenseModel?> getById(String id) async {
    try {
      final data = _storage.get(id);
      if (data == null) return null;
      return ExpenseModel.fromJson(Map<String, dynamic>.from(data));
    } catch (e, stackTrace) {
      Logger.error('Failed to get expense by id', e, stackTrace);
      return null;
    }
  }

  Future<void> save(ExpenseModel expense) async {
    try {
      await _storage.save(expense.id, expense.toJson());
      Logger.success('Expense saved: ${expense.id}');
    } catch (e, stackTrace) {
      Logger.error('Failed to save expense', e, stackTrace);
      throw StorageException('Failed to save expense');
    }
  }

  Future<void> delete(String id) async {
    try {
      await _storage.delete(id);
      Logger.success('Expense deleted: $id');
    } catch (e, stackTrace) {
      Logger.error('Failed to delete expense', e, stackTrace);
      throw StorageException('Failed to delete expense');
    }
  }
}
