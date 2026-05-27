import 'package:smarterp/core/models/expense_report_model.dart';
import 'package:smarterp/core/models/product_model.dart';
import 'package:smarterp/core/models/payroll_report_model.dart';
import 'package:smarterp/core/models/profit_loss_model.dart';
import 'package:smarterp/core/models/purchase_report_model.dart';
import 'package:smarterp/core/models/report_enums.dart';
import 'package:smarterp/core/models/report_model.dart';
import 'package:smarterp/core/models/sales_report_model.dart';
import 'package:smarterp/core/models/stock_report_model.dart';
import 'package:smarterp/core/models/transaction_model.dart';
import 'package:smarterp/core/utils/logger.dart';
import 'package:smarterp/modules/finance/services/finance_service.dart';
import 'package:smarterp/modules/invoice/services/invoice_service.dart';
import 'package:smarterp/modules/payroll/services/payroll_service.dart';
import 'package:smarterp/modules/products/services/product_service.dart';
import 'package:smarterp/modules/reports/repositories/report_repository.dart';
import 'package:smarterp/modules/reports/repositories/sales_report_repository.dart';
import 'package:smarterp/modules/reports/repositories/expense_report_repository.dart';
import 'package:smarterp/modules/reports/repositories/payroll_report_repository.dart';

class ReportGenerationResult {
  final ReportModel report;
  final bool success;
  final String? error;

  ReportGenerationResult({
    required this.report,
    required this.success,
    this.error,
  });
}

class ReportService {
  final ReportRepository _reportRepository;
  final SalesReportRepository _salesReportRepository;
  final ExpenseReportRepository _expenseReportRepository;
  final PayrollReportRepository _payrollReportRepository;
  final FinanceService _financeService;
  final InvoiceService _invoiceService;
  final ProductService _productService;
  final PayrollService _payrollService;

  ReportService({
    required ReportRepository reportRepository,
    required SalesReportRepository salesReportRepository,
    required ExpenseReportRepository expenseReportRepository,
    required PayrollReportRepository payrollReportRepository,
    required FinanceService financeService,
    required InvoiceService invoiceService,
    required ProductService productService,
    required PayrollService payrollService,
  })  : _reportRepository = reportRepository,
        _salesReportRepository = salesReportRepository,
        _expenseReportRepository = expenseReportRepository,
        _payrollReportRepository = payrollReportRepository,
        _financeService = financeService,
        _invoiceService = invoiceService,
        _productService = productService,
        _payrollService = payrollService;

  Future<ReportGenerationResult> generateSalesReport({
    required int month,
    required int year,
    ReportPeriod period = ReportPeriod.monthly,
  }) async {
    try {
      final fromDate = DateTime(year, month, 1);
      final toDate = DateTime(year, month + 1, 0);

      final transactions = await _financeService.getTransactionsByType(TransactionType.sale);
      final monthTx = transactions.where((t) =>
          t.date.month == month && t.date.year == year).toList();

      final totalSales = monthTx.fold(0.0, (sum, t) => sum + t.amount).toDouble();
      final salesCount = monthTx.length;
      final avgOrderValue = salesCount > 0 ? totalSales / salesCount : 0.0;

      final report = ReportModel.create(
        type: ReportType.sales,
        title: 'Sales Report - ${_monthName(month)} $year',
        fromDate: fromDate,
        toDate: toDate,
        period: period,
      );
      await _reportRepository.save(report);

      final topProducts = await _buildTopProducts(month, year);
      final topCustomers = await _buildTopCustomers(month, year);
      final monthlyTrend = await _buildSalesMonthlyTrend(year);

      final salesReport = SalesReportModel.create(
        reportId: report.id,
        totalSales: totalSales,
        salesCount: salesCount,
        averageOrderValue: avgOrderValue,
        topProducts: topProducts,
        topCustomers: topCustomers,
        monthlyTrend: monthlyTrend.values.toList(),
        monthlyLabels: monthlyTrend.keys.toList(),
        month: month,
        year: year,
      );
      await _salesReportRepository.saveSalesReport(salesReport);

      Logger.success('Sales report generated: $month/$year');
      return ReportGenerationResult(report: report, success: true);
    } catch (e, stackTrace) {
      Logger.error('Failed to generate sales report', e, stackTrace);
      rethrow;
    }
  }

  Future<ReportGenerationResult> generatePurchaseReport({
    required int month,
    required int year,
    ReportPeriod period = ReportPeriod.monthly,
  }) async {
    try {
      final fromDate = DateTime(year, month, 1);
      final toDate = DateTime(year, month + 1, 0);

      final transactions = await _financeService.getTransactionsByType(TransactionType.purchase);
      final monthTx = transactions.where((t) =>
          t.date.month == month && t.date.year == year).toList();

      final totalPurchases = monthTx.fold(0.0, (sum, t) => sum + t.amount).toDouble();
      final purchaseCount = monthTx.length;
      final avgOrderValue = purchaseCount > 0 ? totalPurchases / purchaseCount : 0.0;

      final report = ReportModel.create(
        type: ReportType.purchase,
        title: 'Purchase Report - ${_monthName(month)} $year',
        fromDate: fromDate,
        toDate: toDate,
        period: period,
      );
      await _reportRepository.save(report);

      final monthlyTrend = await _buildPurchaseMonthlyTrend(year);

      final purchaseReport = PurchaseReportModel.create(
        reportId: report.id,
        totalPurchases: totalPurchases,
        purchaseCount: purchaseCount,
        averageOrderValue: avgOrderValue,
        topSuppliers: [],
        monthlyTrend: monthlyTrend.values.toList(),
        monthlyLabels: monthlyTrend.keys.toList(),
        month: month,
        year: year,
      );
      await _salesReportRepository.savePurchaseReport(purchaseReport);

      Logger.success('Purchase report generated: $month/$year');
      return ReportGenerationResult(report: report, success: true);
    } catch (e, stackTrace) {
      Logger.error('Failed to generate purchase report', e, stackTrace);
      rethrow;
    }
  }

  Future<ReportGenerationResult> generateExpenseReport({
    required int month,
    required int year,
    ReportPeriod period = ReportPeriod.monthly,
  }) async {
    try {
      final fromDate = DateTime(year, month, 1);
      final toDate = DateTime(year, month + 1, 0);

      final transactions = await _financeService.getTransactionsByType(TransactionType.expense);
      final monthTx = transactions.where((t) =>
          t.date.month == month && t.date.year == year).toList();

      final totalExpenses = monthTx.fold(0.0, (sum, t) => sum + t.amount).toDouble();
      final expenseCount = monthTx.length;

      final categoryBreakdown = <String, double>{};
      String highestCategory = '';
      double highestAmount = 0;

      for (final tx in monthTx) {
        final cat = tx.category ?? 'Uncategorized';
        categoryBreakdown[cat] = (categoryBreakdown[cat] ?? 0) + tx.amount;
        if (categoryBreakdown[cat]! > highestAmount) {
          highestAmount = categoryBreakdown[cat]!;
          highestCategory = cat;
        }
      }

      final topExpenses = monthTx
        ..sort((a, b) => b.amount.compareTo(a.amount));
      final topList = topExpenses.take(10).map((tx) => {
        'id': tx.id,
        'description': tx.description,
        'amount': tx.amount,
        'category': tx.category ?? 'Uncategorized',
        'date': tx.date.toIso8601String(),
      }).toList();

      final report = ReportModel.create(
        type: ReportType.expense,
        title: 'Expense Report - ${_monthName(month)} $year',
        fromDate: fromDate,
        toDate: toDate,
        period: period,
      );
      await _reportRepository.save(report);

      final monthlyTrend = await _buildExpenseMonthlyTrend(year);

      final expenseReport = ExpenseReportModel.create(
        reportId: report.id,
        totalExpenses: totalExpenses,
        expenseCount: expenseCount,
        highestCategoryAmount: highestAmount,
        highestCategory: highestCategory,
        categoryBreakdown: categoryBreakdown,
        monthlyTrend: monthlyTrend.values.toList(),
        monthlyLabels: monthlyTrend.keys.toList(),
        topExpenses: topList,
        month: month,
        year: year,
      );
      await _expenseReportRepository.saveExpenseReport(expenseReport);

      Logger.success('Expense report generated: $month/$year');
      return ReportGenerationResult(report: report, success: true);
    } catch (e, stackTrace) {
      Logger.error('Failed to generate expense report', e, stackTrace);
      rethrow;
    }
  }

  Future<ReportGenerationResult> generateStockReport({
    required int month,
    required int year,
    ReportPeriod period = ReportPeriod.monthly,
  }) async {
    try {
      final products = await _productService.getAllProducts();
      final totalProducts = products.length;
      final totalValue = products.fold(0.0, (sum, p) => sum + (p.stockQuantity * p.price));
      final lowStock = products.where((p) =>
          p.stockQuantity <= p.minStockLevel && p.stockQuantity > 0).length;
      final outOfStock = products.where((p) => p.stockQuantity <= 0).length;
      final inStock = totalProducts - lowStock - outOfStock;

      final lowStockList = products
          .where((p) => p.stockQuantity <= p.minStockLevel)
          .map((p) => {
            'id': p.id,
            'name': p.productName,
            'stock': p.stockQuantity,
            'minLevel': p.minStockLevel,
            'value': p.stockQuantity * p.price,
          })
          .toList()
        ..sort((a, b) => (a['stock'] as int).compareTo(b['stock'] as int));

      final topMoving = products
          .where((p) => p.stockQuantity > 0)
          .map((p) => {
            'id': p.id,
            'name': p.productName,
            'stock': p.stockQuantity,
            'value': p.stockQuantity * p.price,
            'category': p.category,
          })
          .toList()
        ..sort((a, b) => (b['value'] as double).compareTo(a['value'] as double));

      final catDist = <String, int>{};
      for (final p in products) {
        catDist[p.category] = (catDist[p.category] ?? 0) + 1;
      }
      final categoryDistribution = catDist.entries.map((e) => {
        'category': e.key,
        'count': e.value,
        'percentage': totalProducts > 0 ? (e.value / totalProducts) * 100 : 0,
      }).toList();

      final report = ReportModel.create(
        type: ReportType.stock,
        title: 'Stock Report - ${_monthName(month)} $year',
        fromDate: DateTime(year, month, 1),
        toDate: DateTime(year, month + 1, 0),
        period: period,
      );
      await _reportRepository.save(report);

      final stockReport = StockReportModel.create(
        reportId: report.id,
        totalInventoryValue: totalValue,
        totalProducts: totalProducts,
        lowStockCount: lowStock,
        outOfStockCount: outOfStock,
        inStockCount: inStock,
        lowStockProducts: lowStockList.take(20).toList(),
        topMovingProducts: topMoving.take(20).toList(),
        categoryDistribution: categoryDistribution,
        month: month,
        year: year,
      );
      await _expenseReportRepository.saveStockReport(stockReport);

      Logger.success('Stock report generated: $month/$year');
      return ReportGenerationResult(report: report, success: true);
    } catch (e, stackTrace) {
      Logger.error('Failed to generate stock report', e, stackTrace);
      rethrow;
    }
  }

  Future<ReportGenerationResult> generateProfitLossReport({
    required int month,
    required int year,
    ReportPeriod period = ReportPeriod.monthly,
  }) async {
    try {
      final salesTx = await _financeService.getTransactionsByType(TransactionType.sale);
      final purchaseTx = await _financeService.getTransactionsByType(TransactionType.purchase);
      final expenseTx = await _financeService.getTransactionsByType(TransactionType.expense);

      final monthSales = salesTx.where((t) => t.date.month == month && t.date.year == year);
      final monthPurchases = purchaseTx.where((t) => t.date.month == month && t.date.year == year);
      final monthExpenses = expenseTx.where((t) => t.date.month == month && t.date.year == year);

      final totalRevenue = monthSales.fold(0.0, (s, t) => s + t.amount).toDouble();
      final totalCOGS = monthPurchases.fold(0.0, (s, t) => s + t.amount).toDouble();
      final totalExpenses = monthExpenses.fold(0.0, (s, t) => s + t.amount).toDouble();

      final grossProfit = totalRevenue - totalCOGS;
      final netProfit = grossProfit - totalExpenses;
      final profitMargin = totalRevenue > 0 ? (netProfit / totalRevenue) * 100 : 0.0;

      final prevMonth = month == 1 ? 12 : month - 1;
      final prevYear = month == 1 ? year - 1 : year;
      final prevSales = salesTx.where((t) =>
          t.date.month == prevMonth && t.date.year == prevYear);
      final prevRevenue = prevSales.fold(0.0, (s, t) => s + t.amount).toDouble();

      final prevMonthExpenses = expenseTx.where((t) =>
          t.date.month == prevMonth && t.date.year == prevYear);
      final prevExpenses = prevMonthExpenses.fold(0.0, (s, t) => s + t.amount).toDouble();
      final previousNetProfit = prevRevenue - prevExpenses;

      final revenueTrend = await _buildRevenueMonthlyTrend(year);
      final expenseTrend = await _buildExpenseMonthlyTrend(year);

      final report = ReportModel.create(
        type: ReportType.profitLoss,
        title: 'Profit & Loss - ${_monthName(month)} $year',
        fromDate: DateTime(year, month, 1),
        toDate: DateTime(year, month + 1, 0),
        period: period,
      );
      await _reportRepository.save(report);

      final pl = ProfitLossModel.create(
        reportId: report.id,
        totalRevenue: totalRevenue,
        totalCostOfGoodsSold: totalCOGS,
        totalExpenses: totalExpenses,
        grossProfit: grossProfit,
        netProfit: netProfit,
        profitMargin: profitMargin,
        previousNetProfit: previousNetProfit,
        revenueTrend: revenueTrend.values.toList(),
        expenseTrend: expenseTrend.values.toList(),
        trendLabels: revenueTrend.keys.toList(),
        month: month,
        year: year,
      );
      await _payrollReportRepository.saveProfitLoss(pl);

      Logger.success('Profit/loss report generated: $month/$year');
      return ReportGenerationResult(report: report, success: true);
    } catch (e, stackTrace) {
      Logger.error('Failed to generate profit/loss report', e, stackTrace);
      rethrow;
    }
  }

  Future<ReportGenerationResult> generatePayrollReport({
    required int month,
    required int year,
    ReportPeriod period = ReportPeriod.monthly,
  }) async {
    try {
      final dashboardData = await _payrollService.getDashboardData();
      final distribution = await _payrollService.getEmployeeDistribution();

      final totalPayable = dashboardData.totalPayable;
      final totalPaid = dashboardData.totalPaid;
      final totalPending = dashboardData.totalPending;

      final report = ReportModel.create(
        type: ReportType.payroll,
        title: 'Payroll Report - ${_monthName(month)} $year',
        fromDate: DateTime(year, month, 1),
        toDate: DateTime(year, month + 1, 0),
        period: period,
      );
      await _reportRepository.save(report);

      final salaryTrend = await _payrollService.getSalaryTrend();

      final trendLabels = List.generate(12, (i) {
        final d = DateTime(year, month - i, 1);
        return _monthName(d.month);
      }).reversed.toList();

      final payrollReport = PayrollReportModel.create(
        reportId: report.id,
        totalEmployees: dashboardData.totalEmployees,
        activeEmployees: dashboardData.activeEmployees,
        totalSalaryPayable: totalPayable,
        totalSalaryPaid: totalPaid,
        totalSalaryPending: totalPending,
        paidCount: dashboardData.paidCount,
        pendingCount: dashboardData.pendingCount,
        attendanceRate: dashboardData.attendanceRate,
        salaryTrend: salaryTrend,
        trendLabels: trendLabels,
        departmentDistribution: distribution,
        month: month,
        year: year,
      );
      await _payrollReportRepository.savePayrollReport(payrollReport);

      Logger.success('Payroll report generated: $month/$year');
      return ReportGenerationResult(report: report, success: true);
    } catch (e, stackTrace) {
      Logger.error('Failed to generate payroll report', e, stackTrace);
      rethrow;
    }
  }

  Future<List<ReportModel>> getRecentReports(int limit) async {
    return await _reportRepository.getRecent(limit);
  }

  Future<List<ReportModel>> getReportsByType(ReportType type) async {
    return await _reportRepository.getByType(type);
  }

  Future<void> deleteReport(String id) async {
    await _reportRepository.delete(id);
  }

  Future<Map<String, double>> _buildSalesMonthlyTrend(int year) async {
    final transactions = await _financeService.getTransactionsByType(TransactionType.sale);
    final trend = <String, double>{};
    for (var m = 1; m <= 12; m++) {
      const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
      final total = transactions
          .where((t) => t.date.month == m && t.date.year == year)
            .fold(0.0, (s, t) => s + t.amount).toDouble();
      trend[months[m - 1]] = total;
    }
    return trend;
  }

  Future<Map<String, double>> _buildPurchaseMonthlyTrend(int year) async {
    final transactions = await _financeService.getTransactionsByType(TransactionType.purchase);
    final trend = <String, double>{};
    for (var m = 1; m <= 12; m++) {
      const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
      final total = transactions
          .where((t) => t.date.month == m && t.date.year == year)
            .fold(0.0, (s, t) => s + t.amount).toDouble();
      trend[months[m - 1]] = total;
    }
    return trend;
  }

  Future<Map<String, double>> _buildExpenseMonthlyTrend(int year) async {
    final transactions = await _financeService.getTransactionsByType(TransactionType.expense);
    final trend = <String, double>{};
    for (var m = 1; m <= 12; m++) {
      const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
      final total = transactions
          .where((t) => t.date.month == m && t.date.year == year)
            .fold(0.0, (s, t) => s + t.amount).toDouble();
      trend[months[m - 1]] = total;
    }
    return trend;
  }

  Future<Map<String, double>> _buildRevenueMonthlyTrend(int year) async {
    final transactions = await _financeService.getTransactionsByType(TransactionType.sale);
    final trend = <String, double>{};
    for (var m = 1; m <= 12; m++) {
      const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
      final total = transactions
          .where((t) => t.date.month == m && t.date.year == year)
            .fold(0.0, (s, t) => s + t.amount).toDouble();
      trend[months[m - 1]] = total;
    }
    return trend;
  }

  Future<List<Map<String, dynamic>>> _buildTopProducts(int month, int year) async {
    try {
      final invoices = await _invoiceService.getAllInvoices();
      final productSales = <String, double>{};
      final productNames = <String, String>{};

      for (final inv in invoices) {
        if (inv.invoiceDate.month == month && inv.invoiceDate.year == year) {
          final items = await _invoiceService.getInvoiceItems(inv);
          for (final item in items) {
            productSales[item.productId] = (productSales[item.productId] ?? 0) + (item.amount ?? item.quantity * item.unitPrice);
            productNames[item.productId] = item.productName;
          }
        }
      }

      final sorted = productSales.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      return sorted.take(10).map((e) => {
        'productId': e.key,
        'name': productNames[e.key] ?? 'Unknown',
        'total': e.value,
      }).toList();
    } catch (e) {
      Logger.error('Failed to build top products', e);
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> _buildTopCustomers(int month, int year) async {
    try {
      final invoices = await _invoiceService.getAllInvoices();
      final customerSales = <String, double>{};
      final customerNames = <String, String>{};

      for (final inv in invoices) {
        if (inv.invoiceDate.month == month && inv.invoiceDate.year == year) {
          customerSales[inv.customerId] = (customerSales[inv.customerId] ?? 0) + inv.totalAmount;
          customerNames[inv.customerId] = inv.customerName;
        }
      }

      final sorted = customerSales.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      return sorted.take(10).map((e) => ({
        'customerId': e.key,
        'name': customerNames[e.key] ?? 'Unknown',
        'total': e.value,
      })).toList();
    } catch (e) {
      Logger.error('Failed to build top customers', e);
      return [];
    }
  }

  String _monthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }
}
