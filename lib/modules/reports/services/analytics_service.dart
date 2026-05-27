import 'package:smarterp/core/models/transaction_model.dart';
import 'package:smarterp/core/utils/logger.dart';
import 'package:smarterp/modules/finance/services/finance_service.dart';
import 'package:smarterp/modules/payroll/services/payroll_service.dart';
import 'package:smarterp/modules/products/services/product_service.dart';

class SalesKpi {
  final double totalSales;
  final int totalOrders;
  final double averageOrderValue;
  final double salesGrowth;
  final double revenuePerDay;

  SalesKpi({
    required this.totalSales,
    required this.totalOrders,
    required this.averageOrderValue,
    required this.salesGrowth,
    required this.revenuePerDay,
  });
}

class ExpenseKpi {
  final double totalExpenses;
  final int expenseCount;
  final double expenseGrowth;
  final double expenseToRevenueRatio;

  ExpenseKpi({
    required this.totalExpenses,
    required this.expenseCount,
    required this.expenseGrowth,
    required this.expenseToRevenueRatio,
  });
}

class InventoryKpi {
  final double totalValue;
  final int totalProducts;
  final int lowStockCount;
  final int outOfStockCount;
  final double stockHealthPercentage;

  InventoryKpi({
    required this.totalValue,
    required this.totalProducts,
    required this.lowStockCount,
    required this.outOfStockCount,
    required this.stockHealthPercentage,
  });
}

class PayrollKpi {
  final int totalEmployees;
  final double totalPayable;
  final double totalPaid;
  final double paymentRate;
  final double attendanceRate;

  PayrollKpi({
    required this.totalEmployees,
    required this.totalPayable,
    required this.totalPaid,
    required this.paymentRate,
    required this.attendanceRate,
  });
}

class ProfitKpi {
  final double totalRevenue;
  final double totalCosts;
  final double netProfit;
  final double profitMargin;
  final double profitGrowth;

  ProfitKpi({
    required this.totalRevenue,
    required this.totalCosts,
    required this.netProfit,
    required this.profitMargin,
    required this.profitGrowth,
  });
}

class CombinedKpi {
  final SalesKpi sales;
  final ExpenseKpi expenses;
  final InventoryKpi inventory;
  final PayrollKpi payroll;
  final ProfitKpi profit;

  CombinedKpi({
    required this.sales,
    required this.expenses,
    required this.inventory,
    required this.payroll,
    required this.profit,
  });
}

class AnalyticsService {
  final FinanceService _financeService;
  final PayrollService _payrollService;
  final ProductService _productService;

  AnalyticsService({
    required FinanceService financeService,
    required PayrollService payrollService,
    required ProductService productService,
  })  : _financeService = financeService,
        _payrollService = payrollService,
        _productService = productService;

  Future<SalesKpi> calculateSalesKpi(int month, int year) async {
    try {
      final allSales = await _financeService.getTransactionsByType(TransactionType.sale);
      final monthSales = allSales.where((t) =>
          t.date.month == month && t.date.year == year).toList();
      final totalSales = monthSales.fold(0.0, (s, t) => s + t.amount).toDouble();
      final totalOrders = monthSales.length;
      final avgOrderValue = totalOrders > 0 ? totalSales / totalOrders : 0.0;

      final prevMonth = month == 1 ? 12 : month - 1;
      final prevYear = month == 1 ? year - 1 : year;
      final prevSales = allSales.where((t) =>
          t.date.month == prevMonth && t.date.year == prevYear);
      final prevTotal = prevSales.fold(0.0, (s, t) => s + t.amount).toDouble();
      final salesGrowth = prevTotal > 0
          ? ((totalSales - prevTotal) / prevTotal) * 100
          : 0.0;

      final daysInMonth = DateTime(year, month + 1, 0).day;
      final revenuePerDay = daysInMonth > 0 ? totalSales / daysInMonth : 0.0;

      return SalesKpi(
        totalSales: totalSales,
        totalOrders: totalOrders,
        averageOrderValue: avgOrderValue,
        salesGrowth: salesGrowth,
        revenuePerDay: revenuePerDay,
      );
    } catch (e, stackTrace) {
      Logger.error('Failed to calculate sales KPI', e, stackTrace);
      rethrow;
    }
  }

  Future<ExpenseKpi> calculateExpenseKpi(int month, int year) async {
    try {
      final allExpenses = await _financeService.getTransactionsByType(TransactionType.expense);
      final monthExpenses = allExpenses.where((t) =>
          t.date.month == month && t.date.year == year).toList();
      final totalExpenses = monthExpenses.fold(0.0, (s, t) => s + t.amount).toDouble();      final expenseCount = monthExpenses.length;

      final prevMonth = month == 1 ? 12 : month - 1;
      final prevYear = month == 1 ? year - 1 : year;
      final prevExpenses = allExpenses.where((t) =>
          t.date.month == prevMonth && t.date.year == prevYear);
      final prevTotal = prevExpenses.fold(0.0, (s, t) => s + t.amount).toDouble();
      final expenseGrowth = prevTotal > 0
          ? ((totalExpenses - prevTotal) / prevTotal) * 100
          : 0.0;

      final allSales = await _financeService.getTransactionsByType(TransactionType.sale);
      final monthSales = allSales.where((t) =>
          t.date.month == month && t.date.year == year);
      final totalSales = monthSales.fold(0.0, (s, t) => s + t.amount).toDouble();
      final expenseRatio = totalSales > 0 ? (totalExpenses / totalSales) * 100 : 0.0;

      return ExpenseKpi(
        totalExpenses: totalExpenses,
        expenseCount: expenseCount,
        expenseGrowth: expenseGrowth,
        expenseToRevenueRatio: expenseRatio,
      );
    } catch (e, stackTrace) {
      Logger.error('Failed to calculate expense KPI', e, stackTrace);
      rethrow;
    }
  }

  Future<InventoryKpi> calculateInventoryKpi() async {
    try {
      final products = await _productService.getAllProducts();
      final totalProducts = products.length;
      final totalValue = products.fold(0.0, (s, p) => s + (p.stockQuantity * p.price)).toDouble();
      final lowStock = products.where((p) =>
          p.stockQuantity <= p.minStockLevel && p.stockQuantity > 0).length;
      final outOfStock = products.where((p) => p.stockQuantity <= 0).length;
      final healthPct = totalProducts > 0
          ? ((totalProducts - lowStock - outOfStock) / totalProducts) * 100
          : 0.0;

      return InventoryKpi(
        totalValue: totalValue,
        totalProducts: totalProducts,
        lowStockCount: lowStock,
        outOfStockCount: outOfStock,
        stockHealthPercentage: healthPct,
      );
    } catch (e, stackTrace) {
      Logger.error('Failed to calculate inventory KPI', e, stackTrace);
      rethrow;
    }
  }

  Future<PayrollKpi> calculatePayrollKpi(int month, int year) async {
    try {
      final dashboard = await _payrollService.getDashboardData();
      final paymentRate = dashboard.totalPayable > 0
          ? (dashboard.totalPaid / dashboard.totalPayable) * 100
          : 0.0;

      return PayrollKpi(
        totalEmployees: dashboard.totalEmployees,
        totalPayable: dashboard.totalPayable,
        totalPaid: dashboard.totalPaid,
        paymentRate: paymentRate,
        attendanceRate: dashboard.attendanceRate,
      );
    } catch (e, stackTrace) {
      Logger.error('Failed to calculate payroll KPI', e, stackTrace);
      rethrow;
    }
  }

  Future<ProfitKpi> calculateProfitKpi(int month, int year) async {
    try {
      final allSales = await _financeService.getTransactionsByType(TransactionType.sale);
      final allExpenses = await _financeService.getTransactionsByType(TransactionType.expense);

      final monthSales = allSales.where((t) =>
          t.date.month == month && t.date.year == year);
      final monthExpenses = allExpenses.where((t) =>
          t.date.month == month && t.date.year == year);

      final totalRevenue = monthSales.fold(0.0, (s, t) => s + t.amount).toDouble();
      final totalCosts = monthExpenses.fold(0.0, (s, t) => s + t.amount).toDouble();
      final netProfit = totalRevenue - totalCosts;
      final profitMargin = totalRevenue > 0 ? (netProfit / totalRevenue) * 100 : 0.0;

      final prevMonth = month == 1 ? 12 : month - 1;
      final prevYear = month == 1 ? year - 1 : year;
      final prevSales = allSales.where((t) =>
          t.date.month == prevMonth && t.date.year == prevYear);
      final prevExpenses = allExpenses.where((t) =>
          t.date.month == prevMonth && t.date.year == prevYear);
      final prevRevenue = prevSales.fold(0.0, (s, t) => s + t.amount).toDouble();
      final prevCosts = prevExpenses.fold(0.0, (s, t) => s + t.amount).toDouble();
      final prevProfit = prevRevenue - prevCosts;
      final profitGrowth = prevProfit != 0
          ? ((netProfit - prevProfit) / prevProfit.abs()) * 100
          : 0.0;

      return ProfitKpi(
        totalRevenue: totalRevenue,
        totalCosts: totalCosts,
        netProfit: netProfit,
        profitMargin: profitMargin,
        profitGrowth: profitGrowth,
      );
    } catch (e, stackTrace) {
      Logger.error('Failed to calculate profit KPI', e, stackTrace);
      rethrow;
    }
  }

  Future<CombinedKpi> calculateAllKpis(int month, int year) async {
    try {
      final results = await Future.wait([
        calculateSalesKpi(month, year),
        calculateExpenseKpi(month, year),
        calculateInventoryKpi(),
        calculatePayrollKpi(month, year),
        calculateProfitKpi(month, year),
      ]);

      return CombinedKpi(
        sales: results[0] as SalesKpi,
        expenses: results[1] as ExpenseKpi,
        inventory: results[2] as InventoryKpi,
        payroll: results[3] as PayrollKpi,
        profit: results[4] as ProfitKpi,
      );
    } catch (e, stackTrace) {
      Logger.error('Failed to calculate all KPIs', e, stackTrace);
      rethrow;
    }
  }

  Future<List<double>> getSalesTrend(int months) async {
    try {
      final allSales = await _financeService.getTransactionsByType(TransactionType.sale);
      final now = DateTime.now();
      final trend = <double>[];

      for (var i = months - 1; i >= 0; i--) {
        final target = DateTime(now.year, now.month - i, 1);
        final total = allSales
            .where((t) => t.date.month == target.month && t.date.year == target.year)
            .fold(0.0, (s, t) => s + t.amount).toDouble();
        trend.add(total);
      }
      return trend;
    } catch (e, stackTrace) {
      Logger.error('Failed to get sales trend', e, stackTrace);
      return List.filled(months, 0);
    }
  }

  Future<List<double>> getExpenseTrend(int months) async {
    try {
      final allExpenses = await _financeService.getTransactionsByType(TransactionType.expense);
      final now = DateTime.now();
      final trend = <double>[];

      for (var i = months - 1; i >= 0; i--) {
        final target = DateTime(now.year, now.month - i, 1);
        final total = allExpenses
            .where((t) => t.date.month == target.month && t.date.year == target.year)
            .fold(0.0, (s, t) => s + t.amount).toDouble();
        trend.add(total);
      }
      return trend;
    } catch (e, stackTrace) {
      Logger.error('Failed to get expense trend', e, stackTrace);
      return List.filled(months, 0);
    }
  }

  List<String> getTrendLabels(int count) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final now = DateTime.now();
    final labels = <String>[];
    for (var i = count - 1; i >= 0; i--) {
      final target = DateTime(now.year, now.month - i, 1);
      labels.add(months[target.month - 1]);
    }
    return labels;
  }
}
