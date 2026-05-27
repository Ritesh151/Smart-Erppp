import 'package:smarterp/core/exceptions/app_exception.dart';
import 'package:smarterp/core/models/transaction_model.dart';
import 'package:smarterp/core/storage/storage_service.dart';
import 'package:smarterp/core/utils/logger.dart';

class FinanceRepository {
  final StorageService<Map<dynamic, dynamic>> _salesStorage;
  final StorageService<Map<dynamic, dynamic>> _purchaseStorage;
  final StorageService<Map<dynamic, dynamic>> _expensesStorage;

  FinanceRepository({
    required StorageService<Map<dynamic, dynamic>> salesStorage,
    required StorageService<Map<dynamic, dynamic>> purchaseStorage,
    required StorageService<Map<dynamic, dynamic>> expensesStorage,
  })  : _salesStorage = salesStorage,
        _purchaseStorage = purchaseStorage,
        _expensesStorage = expensesStorage;

  Future<List<TransactionModel>> getSales() async {
    try {
      final data = _salesStorage.getAll();
      return data
          .map((item) => TransactionModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } catch (e, stackTrace) {
      Logger.error('Failed to get sales transactions', e, stackTrace);
      throw StorageException('Failed to retrieve sales');
    }
  }

  Future<List<TransactionModel>> getPurchases() async {
    try {
      final data = _purchaseStorage.getAll();
      return data
          .map((item) => TransactionModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } catch (e, stackTrace) {
      Logger.error('Failed to get purchase transactions', e, stackTrace);
      throw StorageException('Failed to retrieve purchases');
    }
  }

  Future<List<TransactionModel>> getExpenses() async {
    try {
      final data = _expensesStorage.getAll();
      return data
          .map((item) => TransactionModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } catch (e, stackTrace) {
      Logger.error('Failed to get expense transactions', e, stackTrace);
      throw StorageException('Failed to retrieve expenses');
    }
  }

  Future<List<TransactionModel>> getAllTransactions() async {
    final sales = await getSales();
    final purchases = await getPurchases();
    final expenses = await getExpenses();
    return [...sales, ...purchases, ...expenses]..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> saveTransaction(TransactionModel transaction) async {
    try {
      final json = transaction.toJson();
      if (transaction.type == TransactionType.sale) {
        await _salesStorage.save(transaction.id, json);
      } else if (transaction.type == TransactionType.purchase) {
        await _purchaseStorage.save(transaction.id, json);
      } else {
        await _expensesStorage.save(transaction.id, json);
      }
      Logger.success('Transaction saved: ${transaction.id}');
    } catch (e, stackTrace) {
      Logger.error('Failed to save transaction', e, stackTrace);
      throw StorageException('Failed to save transaction');
    }
  }

  Future<void> deleteTransaction(String id, TransactionType type) async {
    try {
      if (type == TransactionType.sale) {
        await _salesStorage.delete(id);
      } else if (type == TransactionType.purchase) {
        await _purchaseStorage.delete(id);
      } else {
        await _expensesStorage.delete(id);
      }
      Logger.success('Transaction deleted: $id');
    } catch (e, stackTrace) {
      Logger.error('Failed to delete transaction', e, stackTrace);
      throw StorageException('Failed to delete transaction');
    }
  }
}
