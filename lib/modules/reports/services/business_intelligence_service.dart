import 'package:smarterp/core/models/transaction_model.dart';
import 'package:smarterp/core/utils/logger.dart';
import 'package:smarterp/modules/finance/services/finance_service.dart';
import 'package:smarterp/modules/invoice/services/invoice_service.dart';
import 'package:smarterp/modules/payroll/services/payroll_service.dart';
import 'package:smarterp/modules/products/services/product_service.dart';

class BusinessInsight {
  final String title;
  final String description;
  final String value;
  final double change;
  final bool isPositive;
  final String category;

  BusinessInsight({
    required this.title,
    required this.description,
    required this.value,
    required this.change,
    required this.isPositive,
    required this.category,
  });
}

class TopProduct {
  final String name;
  final double totalRevenue;
  final int quantity;

  TopProduct({required this.name, required this.totalRevenue, required this.quantity});
}

class TopCustomer {
  final String name;
  final double totalSpent;
  final int orderCount;

  TopCustomer({required this.name, required this.totalSpent, required this.orderCount});
}

class RecentActivity {
  final String id;
  final String type;
  final String description;
  final double amount;
  final DateTime date;

  RecentActivity({
    required this.id,
    required this.type,
    required this.description,
    required this.amount,
    required this.date,
  });
}

class BusinessIntelligenceData {
  final double revenueGrowth;
  final double expenseGrowth;
  final List<double> salesTrend;
  final List<double> profitTrend;
  final List<String> trendLabels;
  final List<TopProduct> topProducts;
  final List<TopCustomer> topCustomers;
  final List<RecentActivity> recentActivities;
  final List<BusinessInsight> insights;

  BusinessIntelligenceData({
    required this.revenueGrowth,
    required this.expenseGrowth,
    required this.salesTrend,
    required this.profitTrend,
    required this.trendLabels,
    required this.topProducts,
    required this.topCustomers,
    required this.recentActivities,
    required this.insights,
  });
}

class BusinessIntelligenceService {
  final FinanceService _financeService;
  final InvoiceService _invoiceService;
  final ProductService _productService;
  final PayrollService _payrollService;

  BusinessIntelligenceService({
    required FinanceService financeService,
    required InvoiceService invoiceService,
    required ProductService productService,
    required PayrollService payrollService,
  })  : _financeService = financeService,
        _invoiceService = invoiceService,
        _productService = productService,
        _payrollService = payrollService;

  Future<BusinessIntelligenceData> loadIntelligenceData() async {
    try {
      final now = DateTime.now();
      final month = now.month;
      final year = now.year;

      final results = await Future.wait([
        _financeService.getTransactionsByType(TransactionType.sale),
        _financeService.getTransactionsByType(TransactionType.expense),
        _financeService.getAllTransactions(),
        _productService.getAllProducts(),
        _invoiceService.getAllInvoices(),
      ]);

      final allSales = results[0] as List<TransactionModel>;
      final allExpenses = results[1] as List<TransactionModel>;
      final allTransactions = results[2] as List<TransactionModel>;
      final invoices = results[4] as List;

      final monthSales = allSales.where((t) =>
          t.date.month == month && t.date.year == year);
      final totalRevenue = monthSales.fold(0.0, (s, t) => s + t.amount).toDouble();

      final monthExpenses = allExpenses.where((t) =>
          t.date.month == month && t.date.year == year);
      final totalExpenses = monthExpenses.fold(0.0, (s, t) => s + t.amount).toDouble();

      final prevMonth = month == 1 ? 12 : month - 1;
      final prevYear = month == 1 ? year - 1 : year;
      final prevSales = allSales.where((t) =>
          t.date.month == prevMonth && t.date.year == prevYear);
      final prevRevenue = prevSales.fold(0.0, (s, t) => s + t.amount).toDouble();
      final revenueGrowth = prevRevenue > 0
          ? ((totalRevenue - prevRevenue) / prevRevenue) * 100
          : 0.0;

      const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
      final salesTrend = <double>[];
      final profitTrend = <double>[];
      final trendLabels = <String>[];

      for (var i = 5; i >= 0; i--) {
        final target = DateTime(year, month - i, 1);
        final s = allSales
            .where((t) => t.date.month == target.month && t.date.year == target.year)
            .fold(0.0, (sum, t) => sum + t.amount).toDouble();
        final e = allExpenses
            .where((t) => t.date.month == target.month && t.date.year == target.year)
            .fold(0.0, (sum, t) => sum + t.amount).toDouble();
        salesTrend.add(s);
        profitTrend.add(s - e);
        trendLabels.add(months[target.month - 1]);
      }

      final topProducts = await _buildTopProducts(month, year);
      final topCustomers = await _buildTopCustomers(month, year);

      final recentTx = allTransactions
        ..sort((a, b) => b.date.compareTo(a.date));
      final recentActivities = recentTx.take(10).map((t) => RecentActivity(
        id: t.id,
        type: t.type.name,
        description: t.description,
        amount: t.amount,
        date: t.date,
      )).toList();

      final insights = await _generateInsights(
        month, year, totalRevenue, totalExpenses,
        prevRevenue, revenueGrowth,
      );

      return BusinessIntelligenceData(
        revenueGrowth: revenueGrowth,
        expenseGrowth: 0,
        salesTrend: salesTrend,
        profitTrend: profitTrend,
        trendLabels: trendLabels,
        topProducts: topProducts,
        topCustomers: topCustomers,
        recentActivities: recentActivities,
        insights: insights,
      );
    } catch (e, stackTrace) {
      Logger.error('Failed to load intelligence data', e, stackTrace);
      rethrow;
    }
  }

  Future<List<TopProduct>> _buildTopProducts(int month, int year) async {
    try {
      final invoices = await _invoiceService.getAllInvoices();
      final productMap = <String, TopProduct>{};

      for (final inv in invoices) {
        if (inv.invoiceDate.month != month || inv.invoiceDate.year != year) continue;
        final items = await _invoiceService.getInvoiceItems(inv);
        for (final item in items) {
          final existing = productMap[item.productId];
          final total = item.amount ?? item.quantity * item.unitPrice;
          if (existing != null) {
            productMap[item.productId] = TopProduct(
              name: item.productName,
              totalRevenue: existing.totalRevenue + total,
              quantity: (existing.quantity + item.quantity).toInt(),
            );
          } else {
            productMap[item.productId] = TopProduct(
              name: item.productName,
              totalRevenue: total,
              quantity: item.quantity.toInt(),
            );
          }
        }
      }

      final sorted = productMap.values.toList()
        ..sort((a, b) => b.totalRevenue.compareTo(a.totalRevenue));
      return sorted.take(10).toList();
    } catch (e) {
      Logger.error('Failed to build top products', e);
      return [];
    }
  }

  Future<List<TopCustomer>> _buildTopCustomers(int month, int year) async {
    try {
      final invoices = await _invoiceService.getAllInvoices();
      final customerMap = <String, TopCustomer>{};

      for (final inv in invoices) {
        if (inv.invoiceDate.month != month || inv.invoiceDate.year != year) continue;
        final existing = customerMap[inv.customerId];
        if (existing != null) {
          customerMap[inv.customerId] = TopCustomer(
            name: inv.customerName,
            totalSpent: existing.totalSpent + inv.totalAmount,
            orderCount: existing.orderCount + 1,
          );
        } else {
          customerMap[inv.customerId] = TopCustomer(
            name: inv.customerName,
            totalSpent: inv.totalAmount,
            orderCount: 1,
          );
        }
      }

      final sorted = customerMap.values.toList()
        ..sort((a, b) => b.totalSpent.compareTo(a.totalSpent));
      return sorted.take(10).toList();
    } catch (e) {
      Logger.error('Failed to build top customers', e);
      return [];
    }
  }

  Future<List<BusinessInsight>> _generateInsights(
    int month, int year,
    double revenue, double expenses,
    double prevRevenue, double revenueGrowth,
  ) async {
    final insights = <BusinessInsight>[];

    if (revenueGrowth > 0) {
      insights.add(BusinessInsight(
        title: 'Revenue Growing',
        description: 'Revenue increased by ${revenueGrowth.toStringAsFixed(1)}% compared to last month',
        value: '+${revenueGrowth.toStringAsFixed(1)}%',
        change: revenueGrowth,
        isPositive: true,
        category: 'Sales',
      ));
    } else if (revenueGrowth < 0) {
      insights.add(BusinessInsight(
        title: 'Revenue Declining',
        description: 'Revenue dropped by ${revenueGrowth.abs().toStringAsFixed(1)}% compared to last month',
        value: '${revenueGrowth.toStringAsFixed(1)}%',
        change: revenueGrowth,
        isPositive: false,
        category: 'Sales',
      ));
    }

    final profitMargin = revenue > 0 ? ((revenue - expenses) / revenue) * 100 : 0.0;
    if (profitMargin > 20) {
      insights.add(BusinessInsight(
        title: 'Healthy Margin',
        description: 'Profit margin at ${profitMargin.toStringAsFixed(1)}%',
        value: '${profitMargin.toStringAsFixed(1)}%',
        change: profitMargin,
        isPositive: true,
        category: 'Profit',
      ));
    } else if (profitMargin < 0) {
      insights.add(BusinessInsight(
        title: 'Operating at Loss',
        description: 'Expenses exceed revenue. Review costs.',
        value: '${profitMargin.toStringAsFixed(1)}%',
        change: profitMargin,
        isPositive: false,
        category: 'Profit',
      ));
    }

    try {
      final products = await _productService.getAllProducts();
      final lowStock = products.where((p) =>
          p.stockQuantity <= p.minStockLevel && p.stockQuantity > 0).length;
      final outOfStock = products.where((p) => p.stockQuantity <= 0).length;

      if (lowStock > 0) {
        insights.add(BusinessInsight(
          title: 'Low Stock Alert',
          description: '$lowStock products are below minimum stock level',
          value: '$lowStock items',
          change: -lowStock.toDouble(),
          isPositive: false,
          category: 'Inventory',
        ));
      }
      if (outOfStock > 0) {
        insights.add(BusinessInsight(
          title: 'Out of Stock',
          description: '$outOfStock products are out of stock',
          value: '$outOfStock items',
          change: -outOfStock.toDouble(),
          isPositive: false,
          category: 'Inventory',
        ));
      }
    } catch (_) {}

    try {
      final dashboard = await _payrollService.getDashboardData();
      final unpaidRate = dashboard.totalPayable > 0
          ? ((dashboard.totalPayable - dashboard.totalPaid) / dashboard.totalPayable * 100)
          : 0.0;
      if (unpaidRate > 30) {
        insights.add(BusinessInsight(
          title: 'High Pending Salaries',
          description: '${unpaidRate.toStringAsFixed(0)}% of salaries are unpaid',
          value: '${unpaidRate.toStringAsFixed(0)}%',
          change: -unpaidRate,
          isPositive: false,
          category: 'Payroll',
        ));
      }
    } catch (_) {}

    return insights;
  }
}