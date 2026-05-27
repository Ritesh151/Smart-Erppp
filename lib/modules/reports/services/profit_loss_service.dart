import 'package:smarterp/core/models/transaction_model.dart';
import 'package:smarterp/core/utils/logger.dart';
import 'package:smarterp/modules/finance/services/finance_service.dart';
import 'package:smarterp/modules/payroll/services/payroll_service.dart';

class ProfitLossResult {
  final String id;
  final int month;
  final int year;
  final double totalRevenue;
  final double totalPurchases;
  final double totalExpenses;
  final double totalPayrollCost;
  final double grossProfit;
  final double netProfit;
  final double profitMargin;
  final double previousNetProfit;
  final double profitGrowth;
  final DateTime calculatedAt;

  ProfitLossResult({
    required this.id,
    required this.month,
    required this.year,
    required this.totalRevenue,
    required this.totalPurchases,
    required this.totalExpenses,
    required this.totalPayrollCost,
    required this.grossProfit,
    required this.netProfit,
    required this.profitMargin,
    required this.previousNetProfit,
    required this.profitGrowth,
    required this.calculatedAt,
  });

  bool get isProfitable => netProfit > 0;
  bool get isLoss => netProfit < 0;
  double get totalCosts => totalPurchases + totalExpenses + totalPayrollCost;
}

class RevenueVsExpense {
  final List<double> revenue;
  final List<double> expenses;
  final List<String> labels;

  RevenueVsExpense({
    required this.revenue,
    required this.expenses,
    required this.labels,
  });
}

class ProfitLossService {
  final FinanceService _financeService;
  final PayrollService _payrollService;

  ProfitLossService({
    required FinanceService financeService,
    required PayrollService payrollService,
  })  : _financeService = financeService,
        _payrollService = payrollService;

  Future<ProfitLossResult> calculateProfitLoss(int month, int year) async {
    try {
      final results = await Future.wait([
        _financeService.getTransactionsByType(TransactionType.sale),
        _financeService.getTransactionsByType(TransactionType.purchase),
        _financeService.getTransactionsByType(TransactionType.expense),
        _payrollService.getDashboardData(),
      ]);

      final allSales = results[0] as List<TransactionModel>;
      final allPurchases = results[1] as List<TransactionModel>;
      final allExpenses = results[2] as List<TransactionModel>;
      final dashboard = results[3] as PayrollDashboardData;

      final monthSales = allSales.where((t) =>
          t.date.month == month && t.date.year == year);
      final monthPurchases = allPurchases.where((t) =>
          t.date.month == month && t.date.year == year);
      final monthExpenses = allExpenses.where((t) =>
          t.date.month == month && t.date.year == year);

      final totalRevenue = monthSales.fold(0.0, (s, t) => s + t.amount).toDouble();
      final totalPurchases = monthPurchases.fold(0.0, (s, t) => s + t.amount).toDouble();
      final totalExpenses = monthExpenses.fold(0.0, (s, t) => s + t.amount).toDouble();
      final totalPayrollCost = dashboard.totalPayable.toDouble();

      final grossProfit = totalRevenue - totalPurchases;
      final netProfit = totalRevenue - totalPurchases - totalExpenses - totalPayrollCost;
      final profitMargin = totalRevenue > 0 ? (netProfit / totalRevenue) * 100 : 0.0;

      final prevMonth = month == 1 ? 12 : month - 1;
      final prevYear = month == 1 ? year - 1 : year;
      final prevSales = allSales.where((t) =>
          t.date.month == prevMonth && t.date.year == prevYear);
      final prevExpenses = allExpenses.where((t) =>
          t.date.month == prevMonth && t.date.year == prevYear);
      final prevRevenue = prevSales.fold(0.0, (s, t) => s + t.amount).toDouble();
      final prevCosts = prevExpenses.fold(0.0, (s, t) => s + t.amount).toDouble();
      final previousNetProfit = prevRevenue - prevCosts;
      final profitGrowth = previousNetProfit != 0
          ? ((netProfit - previousNetProfit) / previousNetProfit.abs()) * 100
          : 0.0;

      return ProfitLossResult(
        id: 'PL-${DateTime.now().millisecondsSinceEpoch}',
        month: month,
        year: year,
        totalRevenue: totalRevenue,
        totalPurchases: totalPurchases,
        totalExpenses: totalExpenses,
        totalPayrollCost: totalPayrollCost,
        grossProfit: grossProfit,
        netProfit: netProfit,
        profitMargin: profitMargin,
        previousNetProfit: previousNetProfit,
        profitGrowth: profitGrowth,
        calculatedAt: DateTime.now(),
      );
    } catch (e, stackTrace) {
      Logger.error('Failed to calculate profit/loss', e, stackTrace);
      rethrow;
    }
  }

  Future<RevenueVsExpense> getRevenueVsExpenseTrend(int months) async {
    try {
      final allSales = await _financeService.getTransactionsByType(TransactionType.sale);
      final allExpenses = await _financeService.getTransactionsByType(TransactionType.expense);
      final now = DateTime.now();

      final revenue = <double>[];
      final expenses = <double>[];
      final labels = <String>[];
      const monthNames = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];

      for (var i = months - 1; i >= 0; i--) {
        final target = DateTime(now.year, now.month - i, 1);
        final rev = allSales
            .where((t) => t.date.month == target.month && t.date.year == target.year)
            .fold(0.0, (s, t) => s + t.amount);
        final exp = allExpenses
            .where((t) => t.date.month == target.month && t.date.year == target.year)
            .fold(0.0, (s, t) => s + t.amount);
        revenue.add(rev);
        expenses.add(exp);
        labels.add(monthNames[target.month - 1]);
      }

      return RevenueVsExpense(revenue: revenue, expenses: expenses, labels: labels);
    } catch (e, stackTrace) {
      Logger.error('Failed to get revenue vs expense trend', e, stackTrace);
      return RevenueVsExpense(revenue: [], expenses: [], labels: []);
    }
  }

  Future<List<double>> getProfitTrend(int months) async {
    try {
      final allSales = await _financeService.getTransactionsByType(TransactionType.sale);
      final allExpenses = await _financeService.getTransactionsByType(TransactionType.expense);
      final now = DateTime.now();
      final trend = <double>[];

      for (var i = months - 1; i >= 0; i--) {
        final target = DateTime(now.year, now.month - i, 1);
        final rev = allSales
            .where((t) => t.date.month == target.month && t.date.year == target.year)
            .fold(0.0, (s, t) => s + t.amount);
        final exp = allExpenses
            .where((t) => t.date.month == target.month && t.date.year == target.year)
            .fold(0.0, (s, t) => s + t.amount);
        trend.add(rev - exp);
      }

      return trend;
    } catch (e, stackTrace) {
      Logger.error('Failed to get profit trend', e, stackTrace);
      return List.filled(months, 0);
    }
  }
}
