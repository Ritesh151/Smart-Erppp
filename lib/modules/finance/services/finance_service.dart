import 'package:SmartERP/core/models/expense_model.dart';
import 'package:SmartERP/core/models/transaction_model.dart';
import 'package:SmartERP/core/utils/logger.dart';
import 'package:SmartERP/modules/finance/repositories/finance_repository.dart';
import 'package:SmartERP/modules/invoice/services/invoice_service.dart';
import 'package:SmartERP/modules/products/services/product_service.dart';
import 'package:SmartERP/modules/payroll/services/employee_service.dart';
import 'package:SmartERP/modules/expenses/repositories/expense_repository.dart';

class FinanceService {
  final FinanceRepository financeRepository;
  final InvoiceService invoiceService;
  final ProductService productService;
  final EmployeeService employeeService;
  final ExpenseRepository expenseRepository;

  FinanceService({
    required this.financeRepository,
    required this.invoiceService,
    required this.productService,
    required this.employeeService,
    required this.expenseRepository,
  });

  Future<Map<String, dynamic>> getFinancialSummary(DateTime startDate, DateTime endDate) async {
    try {
      final sales = await getSalesReport(startDate, endDate);
      final purchases = await getPurchaseReport(startDate, endDate);
      final allExpenses = await expenseRepository.getAll();
      final employees = await employeeService.getAllEmployees();
      final invoices = await invoiceService.getAllInvoices();

      final totalSales = sales.fold<double>(
        0, (sum, s) => sum + ((s['total'] as num?)?.toDouble() ?? 0),
      );

      final totalPurchases = purchases.fold<double>(
        0, (sum, p) => sum + ((p['totalAmount'] as num?)?.toDouble() ?? 0),
      );

      final totalExpenses = allExpenses.fold<double>(
        0, (sum, e) => sum + e.amount,
      );

      final totalPayroll = employees.fold<double>(
        0, (sum, e) => sum + e.salary,
      );

      final outstandingInvoices = invoices
          .where((inv) => inv.status.name == 'sent' || inv.status.name == 'partiallyPaid')
          .fold<double>(0, (sum, inv) => sum + inv.balanceAmount);

      final pendingPayments = purchases
          .where((p) => (p['status'] as String?) == 'pending')
          .fold<double>(0, (sum, p) => sum + ((p['totalAmount'] as num?)?.toDouble() ?? 0));

      final netRevenue = totalSales - totalPurchases;
      final netProfit = totalSales - totalExpenses - totalPayroll;

      final monthlyRevenue = <String, double>{};
      for (final s in sales) {
        final date = DateTime.tryParse(s['createdAt'] as String? ?? '');
        if (date != null && date.isAfter(startDate) && date.isBefore(endDate)) {
          final key = '${date.year}-${date.month.toString().padLeft(2, '0')}';
          monthlyRevenue[key] = (monthlyRevenue[key] ?? 0) + ((s['total'] as num?)?.toDouble() ?? 0);
        }
      }

      return {
        'totalSales': totalSales,
        'totalPurchases': totalPurchases,
        'netRevenue': netRevenue,
        'netProfit': netProfit,
        'totalExpenses': totalExpenses,
        'totalPayroll': totalPayroll,
        'outstandingPayments': outstandingInvoices,
        'pendingPayments': pendingPayments,
        'monthlyRevenue': monthlyRevenue.entries
            .map((e) => {'month': e.key, 'amount': e.value})
            .toList(),
        'salesCount': sales.length,
        'purchasesCount': purchases.length,
      };
    } catch (e, stackTrace) {
      Logger.error('Failed to get financial summary', e, stackTrace);
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getSalesReport(DateTime startDate, DateTime endDate) async {
    try {
      return financeRepository.getSalesByDateRange(startDate, endDate);
    } catch (e, stackTrace) {
      Logger.error('Failed to get sales report', e, stackTrace);
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getPurchaseReport(DateTime startDate, DateTime endDate) async {
    try {
      return financeRepository.getPurchasesByDateRange(startDate, endDate);
    } catch (e, stackTrace) {
      Logger.error('Failed to get purchase report', e, stackTrace);
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getAllSales() async {
    try {
      return financeRepository.getAllSales();
    } catch (e, stackTrace) {
      Logger.error('Failed to get all sales', e, stackTrace);
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getAllPurchases() async {
    try {
      return financeRepository.getAllPurchases();
    } catch (e, stackTrace) {
      Logger.error('Failed to get all purchases', e, stackTrace);
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getAllExpenses() async {
    try {
      return financeRepository.getAllExpenses();
    } catch (e, stackTrace) {
      Logger.error('Failed to get all expenses', e, stackTrace);
      return [];
    }
  }

  Future<void> saveSale(Map<String, dynamic> sale) async {
    await financeRepository.saveSale(sale);
  }

  Future<void> savePurchase(Map<String, dynamic> purchase) async {
    await financeRepository.savePurchase(purchase);
  }

  Future<void> updateSale(Map<String, dynamic> sale) async {
    await financeRepository.updateSale(sale);
  }

  Future<void> updatePurchase(Map<String, dynamic> purchase) async {
    await financeRepository.updatePurchase(purchase);
  }

  Future<void> deleteSale(String id) async {
    await financeRepository.deleteSale(id);
  }

  Future<void> deletePurchase(String id) async {
    await financeRepository.deletePurchase(id);
  }

  Future<double> getTotalSales() async {
    final sales = await getAllSales();
    return sales.fold<double>(0, (sum, s) => sum + ((s['total'] as num?)?.toDouble() ?? 0));
  }

  Future<double> getTotalPurchases() async {
    final purchases = await getAllPurchases();
    return purchases.fold<double>(0, (sum, p) => sum + ((p['totalAmount'] as num?)?.toDouble() ?? 0));
  }

  Future<double> getNetProfit() async {
    final summary = await getFinancialSummary(
      DateTime(2000),
      DateTime(2100),
    );
    return summary['netProfit'] as double;
  }

  Future<double> getOutstandingPayments() async {
    final invoices = await invoiceService.getAllInvoices();
    return invoices
        .where((inv) => inv.status.name == 'sent' || inv.status.name == 'partiallyPaid' || inv.status.name == 'overdue')
        .fold<double>(0, (sum, inv) => sum + inv.balanceAmount);
  }

  Future<List<TransactionModel>> getAllTransactions() async {
    try {
      final sales = await getAllSales();
      final purchases = await getAllPurchases();
      final expenses = await getAllExpenses();
      final now = DateTime.now();
      final transactions = <TransactionModel>[];

      for (final s in sales) {
        transactions.add(TransactionModel(
          id: s['id'] as String? ?? '',
          type: TransactionType.sale,
          amount: (s['total'] as num?)?.toDouble() ?? 0,
          date: DateTime.tryParse(s['createdAt'] as String? ?? '') ?? now,
          description: 'Sale to ${s['customerName'] ?? 'Customer'}',
          createdAt: DateTime.tryParse(s['createdAt'] as String? ?? '') ?? now,
          updatedAt: DateTime.tryParse(s['createdAt'] as String? ?? '') ?? now,
        ));
      }

      for (final p in purchases) {
        transactions.add(TransactionModel(
          id: p['id'] as String? ?? '',
          type: TransactionType.purchase,
          amount: (p['totalAmount'] as num?)?.toDouble() ?? 0,
          date: DateTime.tryParse(p['createdAt'] as String? ?? '') ?? now,
          description: 'Purchase from ${p['supplierName'] ?? 'Supplier'}',
          createdAt: DateTime.tryParse(p['createdAt'] as String? ?? '') ?? now,
          updatedAt: DateTime.tryParse(p['createdAt'] as String? ?? '') ?? now,
        ));
      }

      for (final e in expenses) {
        transactions.add(TransactionModel(
          id: e['id'] as String? ?? '',
          type: TransactionType.expense,
          amount: (e['amount'] as num?)?.toDouble() ?? 0,
          date: DateTime.tryParse(e['date'] as String? ?? e['expenseDate'] as String? ?? '') ?? now,
          description: e['description'] as String? ?? 'Expense',
          createdAt: DateTime.tryParse(e['createdAt'] as String? ?? '') ?? now,
          updatedAt: DateTime.tryParse(e['updatedAt'] as String? ?? '') ?? now,
        ));
      }

      transactions.sort((a, b) => b.date.compareTo(a.date));
      return transactions;
    } catch (e, stackTrace) {
      Logger.error('Failed to get all transactions', e, stackTrace);
      return [];
    }
  }
}
