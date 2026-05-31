import 'package:siddhivinayak_enterprise/core/models/expense_model.dart';
import 'package:siddhivinayak_enterprise/core/models/invoice_model.dart';
import 'package:siddhivinayak_enterprise/core/models/transaction_model.dart';
import 'package:siddhivinayak_enterprise/core/utils/logger.dart';
import 'package:siddhivinayak_enterprise/modules/finance/repositories/finance_repository.dart';
import 'package:siddhivinayak_enterprise/modules/finance/services/return_service.dart';
import 'package:siddhivinayak_enterprise/modules/invoice/services/invoice_service.dart';
import 'package:siddhivinayak_enterprise/modules/products/services/product_service.dart';
import 'package:siddhivinayak_enterprise/modules/payroll/services/employee_service.dart';
import 'package:siddhivinayak_enterprise/modules/payroll/repositories/salary_repository.dart';
import 'package:siddhivinayak_enterprise/modules/expenses/repositories/expense_repository.dart';

class FinanceService {
  final FinanceRepository financeRepository;
  final InvoiceService invoiceService;
  final ProductService productService;
  final EmployeeService employeeService;
  final SalaryRepository salaryRepository;
  final ExpenseRepository expenseRepository;
  final ReturnService returnService;

  FinanceService({
    required this.financeRepository,
    required this.invoiceService,
    required this.productService,
    required this.employeeService,
    required this.salaryRepository,
    required this.expenseRepository,
    required this.returnService,
  });

  Future<Map<String, dynamic>> getFinancialSummary(DateTime startDate, DateTime endDate) async {
    try {
      final sales = await getSalesReport(startDate, endDate);
      final purchases = await getPurchaseReport(startDate, endDate);
      final allExpenses = await expenseRepository.getAll();
      final invoices = await invoiceService.getAllInvoices();
      final salaryHistory = await salaryRepository.getAllHistory();

      final totalSales = sales.fold<double>(
        0, (sum, s) => sum + ((s['total'] as num?)?.toDouble() ?? 0),
      );

      final totalPurchases = purchases.fold<double>(
        0, (sum, p) => sum + ((p['totalAmount'] as num?)?.toDouble() ?? 0),
      );

      final totalExpenses = allExpenses.fold<double>(
        0, (sum, e) => sum + e.amount,
      );

      final totalPayroll = salaryHistory
          .where((h) => _isInRange(h.paymentDate, startDate, endDate))
          .fold<double>(0, (sum, h) => sum + h.amount);

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
      final invoices = await invoiceService.getAllInvoices();
      final sales = <Map<String, dynamic>>[];

      for (final invoice in invoices) {
        if (_isInRange(invoice.invoiceDate, startDate, endDate)) {
          sales.add(await _invoiceToSaleMap(invoice));
        }
      }

      final returns = await returnService.getReturnsByDateRange(startDate, endDate);
      for (final item in returns) {
        sales.add({
          'id': item['id'] as String? ?? '',
          'invoiceId': item['invoiceId'] as String? ?? '',
          'invoiceNumber': item['invoiceNumber'] as String? ?? '',
          'customerName': item['customerName'] as String? ?? '',
          'total': -((item['refundAmount'] as num?)?.toDouble() ?? 0),
          'taxAmount': 0.0,
          'status': 'returned',
          'paymentStatus': 'Refunded',
          'createdAt': item['returnDate'] as String? ?? item['createdAt'] as String? ?? '',
          'items': item['items'] as List<dynamic>? ?? const [],
          'source': 'return',
        });
      }

      sales.sort((a, b) {
        final ad = DateTime.tryParse(a['createdAt'] as String? ?? '');
        final bd = DateTime.tryParse(b['createdAt'] as String? ?? '');
        return (bd ?? DateTime(2000)).compareTo(ad ?? DateTime(2000));
      });
      return sales;
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
      return getSalesReport(DateTime(2000), DateTime(2100));
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

  Future<void> savePurchase(Map<String, dynamic> purchase) async {
    await financeRepository.savePurchase(purchase);
  }

  Future<void> updatePurchase(Map<String, dynamic> purchase) async {
    await financeRepository.updatePurchase(purchase);
  }

  Future<void> deletePurchase(String id) async {
    await financeRepository.deletePurchase(id);
  }

  Future<double> getTotalSales() async {
    final sales = await getAllSales();
    final grossSales = sales.fold<double>(0, (sum, s) => sum + ((s['total'] as num?)?.toDouble() ?? 0));
    return grossSales;
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
      final salaryHistory = await salaryRepository.getAllHistory();
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

      for (final salary in salaryHistory) {
        transactions.add(TransactionModel(
          id: salary.id,
          type: TransactionType.expense,
          amount: salary.amount,
          date: salary.paymentDate,
          description: 'Salary paid to ${salary.employeeName}',
          referenceId: salary.salaryId,
          category: 'Payroll',
          createdAt: salary.createdAt,
          updatedAt: salary.createdAt,
        ));
      }

      transactions.sort((a, b) => b.date.compareTo(a.date));
      return transactions;
    } catch (e, stackTrace) {
      Logger.error('Failed to get all transactions', e, stackTrace);
      return [];
    }
  }

  bool _isInRange(DateTime date, DateTime start, DateTime end) {
    return !date.isBefore(start) && !date.isAfter(end);
  }

  Future<Map<String, dynamic>> _invoiceToSaleMap(InvoiceModel invoice) async {
    final items = await invoiceService.getInvoiceItems(invoice.id);
    final cancelled = invoice.status == InvoiceStatus.cancelled;
    return {
      'id': invoice.id,
      'invoiceId': invoice.id,
      'invoiceNumber': invoice.invoiceNumber,
      'customerName': invoice.customerName,
      'customerPhone': invoice.customerPhone ?? '',
      'customerAddress': invoice.customerAddress ?? '',
      'total': cancelled ? 0.0 : invoice.totalAmount,
      'taxAmount': cancelled ? 0.0 : invoice.taxAmount,
      'paidAmount': invoice.paidAmount,
      'status': invoice.status.name,
      'paymentStatus': _paymentStatus(invoice),
      'createdAt': invoice.invoiceDate.toIso8601String(),
      'items': items.map((item) {
        return {
          'productId': item.productId,
          'productName': item.productName,
          'quantity': item.quantity,
          'price': item.unitPrice,
          'amount': item.taxableAmount,
          'gstRate': item.taxRate,
          'gstAmount': item.taxAmount,
          'totalAmount': item.amount,
          'hsnCode': item.hsnCode,
        };
      }).toList(),
      'source': 'invoice',
    };
  }

  String _paymentStatus(InvoiceModel invoice) {
    if (invoice.status == InvoiceStatus.cancelled) return 'Cancelled';
    if (invoice.paidAmount <= 0) return 'Unpaid';
    if (invoice.paidAmount >= invoice.totalAmount) return 'Paid';
    return 'Partially Paid';
  }
}
