import 'package:siddhivinayak_enterprise/core/storage/storage_service.dart';
import 'package:siddhivinayak_enterprise/core/utils/logger.dart';

class FinanceRepository {
  final StorageService<Map<dynamic, dynamic>> purchaseStorage;
  final StorageService<Map<dynamic, dynamic>> expensesStorage;

  FinanceRepository({
    required this.purchaseStorage,
    required this.expensesStorage,
  });

  List<Map<String, dynamic>> getAllPurchases() {
    try {
      return purchaseStorage.getAll()
          .map((e) => Map<String, dynamic>.from(e))
          .toList()
        ..sort((a, b) {
          final ad = DateTime.tryParse(a['createdAt'] as String? ?? '');
          final bd = DateTime.tryParse(b['createdAt'] as String? ?? '');
          return bd?.compareTo(ad ?? DateTime(2000)) ?? 0;
        });
    } catch (e, stackTrace) {
      Logger.error('Failed to get all purchases', e, stackTrace);
      return [];
    }
  }

  List<Map<String, dynamic>> getAllExpenses() {
    try {
      return expensesStorage.getAll()
          .map((e) => Map<String, dynamic>.from(e))
          .toList()
        ..sort((a, b) {
          final ad = DateTime.tryParse(a['createdAt'] as String? ?? '');
          final bd = DateTime.tryParse(b['createdAt'] as String? ?? '');
          return bd?.compareTo(ad ?? DateTime(2000)) ?? 0;
        });
    } catch (e, stackTrace) {
      Logger.error('Failed to get all expenses', e, stackTrace);
      return [];
    }
  }

  List<Map<String, dynamic>> getPurchasesByDateRange(DateTime start, DateTime end) {
    return getAllPurchases().where((p) {
      final purchaseDate = DateTime.tryParse(p['purchaseDate'] as String? ?? '');
      if (purchaseDate == null) return false;
      return !purchaseDate.isBefore(start) && !purchaseDate.isAfter(end);
    }).toList();
  }

  Future<void> savePurchase(Map<String, dynamic> purchase) async {
    try {
      await purchaseStorage.save(purchase['id'] as String, purchase);
      Logger.success('Purchase saved: ${purchase['id']}');
    } catch (e, stackTrace) {
      Logger.error('Failed to save purchase', e, stackTrace);
      rethrow;
    }
  }

  Future<void> updatePurchase(Map<String, dynamic> purchase) async {
    try {
      await purchaseStorage.update(purchase['id'] as String, purchase);
      Logger.success('Purchase updated: ${purchase['id']}');
    } catch (e, stackTrace) {
      Logger.error('Failed to update purchase', e, stackTrace);
      rethrow;
    }
  }

  Future<void> deletePurchase(String id) async {
    try {
      await purchaseStorage.delete(id);
      Logger.success('Purchase deleted: $id');
    } catch (e, stackTrace) {
      Logger.error('Failed to delete purchase', e, stackTrace);
      rethrow;
    }
  }

  Future<void> saveExpense(Map<String, dynamic> expense) async {
    try {
      await expensesStorage.save(expense['id'] as String, expense);
      Logger.success('Expense saved: ${expense['id']}');
    } catch (e, stackTrace) {
      Logger.error('Failed to save expense', e, stackTrace);
      rethrow;
    }
  }

  Future<void> deleteExpense(String id) async {
    try {
      await expensesStorage.delete(id);
      Logger.success('Expense deleted: $id');
    } catch (e, stackTrace) {
      Logger.error('Failed to delete expense', e, stackTrace);
      rethrow;
    }
  }
}
