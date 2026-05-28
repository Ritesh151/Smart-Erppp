import 'package:SmartERP/core/models/invoice_model.dart';
import 'package:SmartERP/core/models/transaction_model.dart';
import 'package:SmartERP/core/utils/logger.dart';
import 'package:SmartERP/modules/finance/services/finance_service.dart';
import 'package:SmartERP/modules/invoice/services/invoice_service.dart';
import 'package:SmartERP/modules/payroll/services/attendance_service.dart';
import 'package:SmartERP/modules/payroll/services/employee_service.dart';
import 'package:SmartERP/modules/products/services/product_service.dart';
import 'package:SmartERP/modules/transport/services/transport_service.dart';
import 'package:SmartERP/modules/transport/models/transport_screen_model.dart';
import 'package:SmartERP/modules/transport/services/vehicle_service.dart';

enum InsightCategory {
  revenue,
  inventory,
  customers,
  transport,
  employees,
  general,
}

class BusinessInsight {
  final String id;
  final String title;
  final String description;
  final InsightCategory category;
  final double? value;
  final String? trend;
  final bool isPositive;
  final DateTime createdAt;

  BusinessInsight({
    required this.id,
    required this.title,
    required this.description,
    this.category = InsightCategory.general,
    this.value,
    this.trend,
    this.isPositive = true,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}

class AppIntelligenceService {
  final ProductService _productService;
  final FinanceService _financeService;
  final InvoiceService _invoiceService;
  final TransportService _transportService;
  final VehicleService _vehicleService;
  final EmployeeService _employeeService;
  final AttendanceService _attendanceService;

  AppIntelligenceService({
    required ProductService productService,
    required FinanceService financeService,
    required InvoiceService invoiceService,
    required TransportService transportService,
    required VehicleService vehicleService,
    required EmployeeService employeeService,
    required AttendanceService attendanceService,
  })  : _productService = productService,
        _financeService = financeService,
        _invoiceService = invoiceService,
        _transportService = transportService,
        _vehicleService = vehicleService,
        _employeeService = employeeService,
        _attendanceService = attendanceService;

  List<BusinessInsight> _cachedInsights = [];
  DateTime _lastRefresh = DateTime(2000);

  Future<List<BusinessInsight>> getInsights({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedInsights.isNotEmpty &&
        DateTime.now().difference(_lastRefresh).inMinutes < 15) {
      return _cachedInsights;
    }

    try {
      final results = await Future.wait([
        _analyzeInventory(),
        _analyzeRevenue(),
        _analyzeCustomers(),
        _analyzeTransport(),
        _analyzeEmployees(),
      ]);

      _cachedInsights = results.expand((i) => i).toList();
      _cachedInsights.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      _lastRefresh = DateTime.now();

      Logger.info('Generated ${_cachedInsights.length} business insights');
      return _cachedInsights;
    } catch (e, stackTrace) {
      Logger.error('Failed to generate insights', e, stackTrace);
      return _cachedInsights;
    }
  }

  Future<List<BusinessInsight>> _analyzeInventory() async {
    final insights = <BusinessInsight>[];

    try {
      final products = await _productService.getAllProducts();
      final outOfStock = products.where((p) => p.stockQuantity <= 0).toList();
      final lowStock = products
          .where((p) => p.stockQuantity > 0 && p.stockQuantity < (p.minStockLevel * 1.5))
          .toList();

      if (outOfStock.isNotEmpty) {
        insights.add(BusinessInsight(
          id: 'oos-${DateTime.now().millisecondsSinceEpoch}',
          title: '$outOfStock Products Out of Stock',
          description: 'Products: ${outOfStock.take(3).map((p) => p.productName).join(', ')}${outOfStock.length > 3 ? ' and ${outOfStock.length - 3} more' : ''}',
          category: InsightCategory.inventory,
          value: outOfStock.length.toDouble(),
          isPositive: false,
        ));
      }

      if (lowStock.isNotEmpty) {
        insights.add(BusinessInsight(
          id: 'low-${DateTime.now().millisecondsSinceEpoch}',
          title: '$lowStock Products Running Low',
          description: 'Consider restocking: ${lowStock.take(3).map((p) => p.productName).join(', ')}${lowStock.length > 3 ? ' and ${lowStock.length - 3} more' : ''}',
          category: InsightCategory.inventory,
          value: lowStock.length.toDouble(),
          isPositive: false,
        ));
      }

      final totalValue = products.fold<double>(
        0, (sum, p) => sum + (p.stockQuantity * p.price));
      if (totalValue > 0) {
        insights.add(BusinessInsight(
          id: 'inv-value-${DateTime.now().millisecondsSinceEpoch}',
          title: 'Inventory Value: ₹${_formatAmount(totalValue)}',
          description: '${products.length} products in stock',
          category: InsightCategory.inventory,
          value: totalValue,
          isPositive: true,
        ));
      }
    } catch (e) {
      Logger.error('Inventory analysis failed', e);
    }

    return insights;
  }

  Future<List<BusinessInsight>> _analyzeRevenue() async {
    final insights = <BusinessInsight>[];

    try {
      final transactions = await _financeService.getAllTransactions();
      final now = DateTime.now();
      final thisMonth = transactions.where((t) =>
          t.type == TransactionType.sale &&
          t.date.month == now.month &&
          t.date.year == now.year).toList();

      final lastMonth = transactions.where((t) =>
          t.type == TransactionType.sale &&
          t.date.month == now.month - 1 &&
          t.date.year == now.year).toList();

      final thisMonthSales = thisMonth.fold<double>(0, (s, t) => s + t.amount);
      final lastMonthSales = lastMonth.fold<double>(0, (s, t) => s + t.amount);

      if (thisMonthSales > 0) {
        final change = lastMonthSales > 0
            ? ((thisMonthSales - lastMonthSales) / lastMonthSales * 100)
            : 100;
        insights.add(BusinessInsight(
          id: 'rev-${DateTime.now().millisecondsSinceEpoch}',
          title: 'Month-to-Date Sales: ₹${_formatAmount(thisMonthSales)}',
          description: change >= 0
              ? '${change.toStringAsFixed(1)}% increase vs last month'
              : '${change.toStringAsFixed(1)}% decline vs last month',
          category: InsightCategory.revenue,
          value: thisMonthSales,
          trend: '${change.toStringAsFixed(1)}%',
          isPositive: change >= 0,
        ));
      }

      final totalExpenses = transactions
          .where((t) => t.type == TransactionType.expense)
          .fold<double>(0, (s, t) => s + t.amount);
      if (totalExpenses > 0) {
        final netProfit = thisMonthSales - totalExpenses;
        insights.add(BusinessInsight(
          id: 'profit-${DateTime.now().millisecondsSinceEpoch}',
          title: 'Net ${netProfit >= 0 ? 'Profit' : 'Loss'}: ₹${_formatAmount(netProfit.abs())}',
          description: netProfit >= 0
              ? 'Business is profitable this month'
              : 'Expenses exceeded sales this month',
          category: InsightCategory.revenue,
          value: netProfit,
          isPositive: netProfit >= 0,
        ));
      }
    } catch (e) {
      Logger.error('Revenue analysis failed', e);
    }

    return insights;
  }

  Future<List<BusinessInsight>> _analyzeCustomers() async {
    final insights = <BusinessInsight>[];

    try {
      final invoices = await _invoiceService.getAllInvoices();
      final pending = invoices.where((i) =>
          i.status == InvoiceStatus.sent ||
          i.status == InvoiceStatus.partiallyPaid ||
          i.status == InvoiceStatus.overdue).toList();

      if (pending.isNotEmpty) {
        final totalDue = pending.fold<double>(0, (s, i) => s + i.totalAmount);
        insights.add(BusinessInsight(
          id: 'due-${DateTime.now().millisecondsSinceEpoch}',
          title: '₹${_formatAmount(totalDue)} in Pending Payments',
          description: '${pending.length} unpaid invoices (${pending.where((i) => i.isOverdue).length} overdue)',
          category: InsightCategory.customers,
          value: totalDue,
          isPositive: false,
        ));
      }
    } catch (e) {
      Logger.error('Customer analysis failed', e);
    }

    return insights;
  }

  Future<List<BusinessInsight>> _analyzeTransport() async {
    final insights = <BusinessInsight>[];

    try {
      final transports = await _transportService.getAllTransports();
      final vehicles = await _vehicleService.getAllVehicles();
      final active = transports.where((t) => t.status == ExportStatus.inTransit || t.status == ExportStatus.planned).toList();

      if (active.isNotEmpty) {
        insights.add(BusinessInsight(
          id: 'tr-${DateTime.now().millisecondsSinceEpoch}',
          title: '$active Active Transports',
          description: '${vehicles.length} vehicles available, ${active.length} in transit',
          category: InsightCategory.transport,
          value: active.length.toDouble(),
          isPositive: true,
        ));
      }
    } catch (e) {
      Logger.error('Transport analysis failed', e);
    }

    return insights;
  }

  Future<List<BusinessInsight>> _analyzeEmployees() async {
    final insights = <BusinessInsight>[];

    try {
      final employees = await _employeeService.getAllEmployees();
      final records = await _attendanceService.getAllRecords();
      final now = DateTime.now();
      final thisMonthRecords = records.where((r) =>
          r.date.month == now.month && r.date.year == now.year).toList();

      if (employees.isNotEmpty && thisMonthRecords.isNotEmpty) {
        final avgAttendance = thisMonthRecords.length / employees.length;
        insights.add(BusinessInsight(
          id: 'hr-${DateTime.now().millisecondsSinceEpoch}',
          title: '${employees.length} Employees, ${thisMonthRecords.length} Records This Month',
          description: 'Average ${avgAttendance.toStringAsFixed(1)} attendance entries per employee',
          category: InsightCategory.employees,
          value: avgAttendance,
          isPositive: avgAttendance > 15,
        ));
      }
    } catch (e) {
      Logger.error('Employee analysis failed', e);
    }

    return insights;
  }

  String _formatAmount(double amount) {
    if (amount >= 10000000) return '${(amount / 10000000).toStringAsFixed(2)}Cr';
    if (amount >= 100000) return '${(amount / 100000).toStringAsFixed(2)}L';
    if (amount >= 1000) return '${(amount / 1000).toStringAsFixed(1)}K';
    return amount.toStringAsFixed(0);
  }
}
