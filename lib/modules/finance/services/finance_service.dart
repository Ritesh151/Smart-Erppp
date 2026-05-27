import 'package:smarterp/core/models/transaction_model.dart';
import 'package:smarterp/modules/finance/models/finance_summary_model.dart';
import 'package:smarterp/modules/finance/repositories/finance_repository.dart';
import 'package:smarterp/modules/products/repositories/product_repository.dart';
import 'package:smarterp/core/utils/logger.dart';

class FinanceService {
  final FinanceRepository _financeRepository;
  final ProductRepository _productRepository;

  FinanceService({
    required FinanceRepository financeRepository,
    required ProductRepository productRepository,
  })  : _financeRepository = financeRepository,
        _productRepository = productRepository;

  Future<List<TransactionModel>> getAllTransactions() async {
    return await _financeRepository.getAllTransactions();
  }

  Future<void> saveTransaction(TransactionModel transaction) async {
    await _financeRepository.saveTransaction(transaction);
  }

  Future<void> deleteTransaction(String id, TransactionType type) async {
    await _financeRepository.deleteTransaction(id, type);
  }

  Future<double> calculateTotalSales(DateTime? startDate, DateTime? endDate) async {
    final sales = await _financeRepository.getSales();
    return _filterAndSum(sales, startDate, endDate);
  }

  Future<double> calculateTotalPurchases(DateTime? startDate, DateTime? endDate) async {
    final purchases = await _financeRepository.getPurchases();
    return _filterAndSum(purchases, startDate, endDate);
  }

  Future<double> calculateTotalExpenses(DateTime? startDate, DateTime? endDate) async {
    final expenses = await _financeRepository.getExpenses();
    return _filterAndSum(expenses, startDate, endDate);
  }

  Future<double> calculateNetProfit(DateTime? startDate, DateTime? endDate) async {
    final sales = await calculateTotalSales(startDate, endDate);
    final purchases = await calculateTotalPurchases(startDate, endDate);
    final expenses = await calculateTotalExpenses(startDate, endDate);
    return sales - purchases - expenses;
  }

  Future<FinanceSummaryModel> getFinanceSummary(DateTime? startDate, DateTime? endDate) async {
    final sales = await calculateTotalSales(startDate, endDate);
    final purchases = await calculateTotalPurchases(startDate, endDate);
    final expenses = await calculateTotalExpenses(startDate, endDate);
    final netProfit = sales - purchases - expenses;
    final inventoryValue = await _productRepository.getTotalInventoryValue();
    final allTx = await _financeRepository.getAllTransactions();
    
    int txCount = allTx.where((tx) {
      if (startDate != null && tx.date.isBefore(startDate)) return false;
      if (endDate != null && tx.date.isAfter(endDate)) return false;
      return true;
    }).length;

    return FinanceSummaryModel(
      totalSales: sales,
      totalPurchases: purchases,
      totalExpenses: expenses,
      totalRevenue: sales, 
      netProfit: netProfit,
      totalInventoryValue: inventoryValue,
      transactionCount: txCount,
      calculatedAt: DateTime.now(),
    );
  }

  Future<List<TransactionModel>> getTransactionsByType(TransactionType type) async {
    if (type == TransactionType.sale) {
      return await _financeRepository.getSales();
    } else if (type == TransactionType.purchase) {
      return await _financeRepository.getPurchases();
    } else {
      return await _financeRepository.getExpenses();
    }
  }

  Future<List<TransactionModel>> getTransactionsByDateRange(DateTime start, DateTime end) async {
    final txs = await _financeRepository.getAllTransactions();
    return txs.where((tx) => tx.date.isAfter(start.subtract(const Duration(seconds: 1))) && 
                             tx.date.isBefore(end.add(const Duration(seconds: 1)))).toList();
  }

  Future<Map<String, double>> getMonthlySummary(int year) async {
    final txs = await _financeRepository.getAllTransactions();
    final Map<String, double> monthlySales = {};
    
    for (int i = 1; i <= 12; i++) {
      monthlySales[i.toString().padLeft(2, '0')] = 0.0;
    }

    for (final tx in txs) {
      if (tx.date.year == year && tx.type == TransactionType.sale) {
        final monthStr = tx.date.month.toString().padLeft(2, '0');
        monthlySales[monthStr] = (monthlySales[monthStr] ?? 0.0) + tx.amount;
      }
    }
    return monthlySales;
  }

  double _filterAndSum(List<TransactionModel> list, DateTime? startDate, DateTime? endDate) {
    double sum = 0.0;
    for (final tx in list) {
      if (startDate != null && tx.date.isBefore(startDate)) continue;
      if (endDate != null && tx.date.isAfter(endDate)) continue;
      sum += tx.amount;
    }
    return sum;
  }
}
