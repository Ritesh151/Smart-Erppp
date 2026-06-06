import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:siddhivinayak_enterprise/core/constants/storage_keys.dart';
import 'package:siddhivinayak_enterprise/core/models/invoice_model.dart';
import 'package:siddhivinayak_enterprise/core/models/product_model.dart';
import 'package:siddhivinayak_enterprise/core/models/transaction_model.dart';
import 'package:siddhivinayak_enterprise/core/utils/logger.dart';
import 'package:siddhivinayak_enterprise/modules/finance/services/finance_service.dart';
import 'package:siddhivinayak_enterprise/modules/invoice/services/invoice_service.dart';
import 'package:siddhivinayak_enterprise/modules/products/services/product_service.dart';

class DashboardProvider extends ChangeNotifier {
  DashboardProvider({
    required InvoiceService invoiceService,
    required ProductService productService,
    required FinanceService financeService,
  })  : _invoiceService = invoiceService,
        _productService = productService,
        _financeService = financeService {
    _subscribeToSourceBoxes();
    _startAutoRefresh();
  }

  final InvoiceService _invoiceService;
  final ProductService _productService;
  final FinanceService _financeService;

  double _totalSales = 0;
  double _overdueAmount = 0;
  int _overdueCount = 0;
  double _dueSoonAmount = 0;
  int _dueSoonCount = 0;
  double _paidThisMonthAmount = 0;
  int _paidThisMonthCount = 0;
  double _totalInventoryValue = 0;
  int _lowStockCount = 0;
  double _monthlyExpenses = 0;
  double _netProfit = 0;
  bool _isLoading = false;
  String? _errorMessage;
  List<InvoiceModel> _invoices = [];
  List<ProductModel> _products = [];
  final List<StreamSubscription<dynamic>> _sourceSubscriptions = [];
  bool _refreshQueued = false;
  Timer? _autoRefreshTimer;

  List<InvoiceModel> _dueTodayInvoices = [];
  List<InvoiceModel> _dueIn3DaysInvoices = [];
  List<InvoiceModel> _dueIn7DaysInvoices = [];

  double get totalSales => _totalSales;
  double get overdueAmount => _overdueAmount;
  int get overdueCount => _overdueCount;
  double get dueSoonAmount => _dueSoonAmount;
  int get dueSoonCount => _dueSoonCount;
  double get paidThisMonthAmount => _paidThisMonthAmount;
  int get paidThisMonthCount => _paidThisMonthCount;
  double get totalInventoryValue => _totalInventoryValue;
  int get lowStockCount => _lowStockCount;
  double get monthlyExpenses => _monthlyExpenses;
  double get netProfit => _netProfit;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<InvoiceModel> get invoices => _invoices;
  List<ProductModel> get products => _products;
  List<InvoiceModel> get dueTodayInvoices => _dueTodayInvoices;
  List<InvoiceModel> get dueIn3DaysInvoices => _dueIn3DaysInvoices;
  List<InvoiceModel> get dueIn7DaysInvoices => _dueIn7DaysInvoices;

  double get overdueProgress =>
      _overdueCount > 0 || _dueSoonCount > 0 || _paidThisMonthCount > 0
          ? _overdueAmount / (_overdueAmount + _dueSoonAmount + _paidThisMonthAmount + 1)
          : 0;

  double get dueSoonProgress =>
      _overdueCount > 0 || _dueSoonCount > 0 || _paidThisMonthCount > 0
          ? _dueSoonAmount / (_overdueAmount + _dueSoonAmount + _paidThisMonthAmount + 1)
          : 0;

  double get paidThisMonthProgress =>
      _paidThisMonthCount > 0 ? _paidThisMonthAmount / (_overdueAmount + _dueSoonAmount + _paidThisMonthAmount + 1) : 0;

  double get netProfitMargin =>
      _totalSales > 0 ? (_netProfit / _totalSales) * 100 : 0;

  Future<void> refresh() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final results = await Future.wait([
        _invoiceService.getAllInvoices(),
        _productService.getAllProducts(),
        _financeService.getAllTransactions(),
      ]);

      _invoices = results[0] as List<InvoiceModel>;
      _products = results[1] as List<ProductModel>;
      final transactions = results[2] as List<TransactionModel>;

      _calculateMetrics(_invoices, _products, transactions);

      _isLoading = false;
      notifyListeners();
      Logger.success('Dashboard metrics refreshed');
    } catch (e, stackTrace) {
      _isLoading = false;
      _errorMessage = 'Failed to refresh dashboard';
      notifyListeners();
      Logger.error('Failed to refresh dashboard', e, stackTrace);
    }
  }

  void _subscribeToSourceBoxes() {
    for (final boxName in [
      StorageKeys.invoicesBox,
      StorageKeys.invoiceItemsBox,
      StorageKeys.returnsBox,
      StorageKeys.productsBox,
      StorageKeys.expensesBox,
      StorageKeys.purchaseBox,
      StorageKeys.salaryBox,
      StorageKeys.salaryHistoryBox,
    ]) {
      if (Hive.isBoxOpen(boxName)) {
        _sourceSubscriptions.add(Hive.box(boxName).watch().listen((_) {
          _queueRefresh();
        }));
      }
    }
  }

  void _startAutoRefresh() {
    _autoRefreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      refresh();
    });
  }

  void _queueRefresh() {
    if (_refreshQueued || _isLoading) return;
    _refreshQueued = true;
    Future.microtask(() async {
      _refreshQueued = false;
      await refresh();
    });
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    for (final sub in _sourceSubscriptions) {
      sub.cancel();
    }
    super.dispose();
  }

  void _calculateMetrics(
    List<InvoiceModel> invoices,
    List<ProductModel> products,
    List<TransactionModel> transactions,
  ) {
    final now = DateTime.now();

    double salesTotal = transactions
        .where((tx) => tx.type == TransactionType.sale)
        .fold<double>(0, (sum, tx) => sum + tx.amount);
    double overdueTotal = 0;
    int overdueTotalCount = 0;
    double dueSoonTotal = 0;
    int dueSoonTotalCount = 0;
    double paidThisMonthTotal = 0;
    int paidThisMonthTotalCount = 0;

    final dueToday = <InvoiceModel>[];
    final dueIn3Days = <InvoiceModel>[];
    final dueIn7Days = <InvoiceModel>[];

    for (final inv in invoices) {
      if (inv.status != InvoiceStatus.cancelled) {
        final isOverdue = inv.status == InvoiceStatus.overdue ||
            (inv.status != InvoiceStatus.paid &&
                now.isAfter(inv.dueDate));
        if (isOverdue) {
          overdueTotal += inv.balanceAmount;
          overdueTotalCount++;
        } else if (inv.status != InvoiceStatus.paid) {
          final diff = inv.dueDate.difference(now).inDays;
          if (diff == 0) {
            dueToday.add(inv);
          } else if (diff <= 3) {
            dueIn3Days.add(inv);
          } else if (diff <= 7) {
            dueIn7Days.add(inv);
          }
          if (diff >= 0 && diff < 7) {
            dueSoonTotal += inv.balanceAmount;
            dueSoonTotalCount++;
          }
        }
      }

      if (inv.status == InvoiceStatus.paid &&
          inv.updatedAt.month == now.month &&
          inv.updatedAt.year == now.year) {
        paidThisMonthTotal += inv.totalAmount;
        paidThisMonthTotalCount++;
      }
    }

    _totalSales = salesTotal;
    _overdueAmount = overdueTotal;
    _overdueCount = overdueTotalCount;
    _dueSoonAmount = dueSoonTotal;
    _dueSoonCount = dueSoonTotalCount;
    _paidThisMonthAmount = paidThisMonthTotal;
    _paidThisMonthCount = paidThisMonthTotalCount;
    _dueTodayInvoices = dueToday;
    _dueIn3DaysInvoices = dueIn3Days;
    _dueIn7DaysInvoices = dueIn7Days;

    _totalInventoryValue = 0;
    _lowStockCount = 0;
    for (final p in products) {
      _totalInventoryValue += p.inventoryValue;
      if (p.isLowStock) _lowStockCount++;
    }

    double monthlyExp = 0;
    double allExpenses = 0;
    for (final tx in transactions) {
      if (tx.type == TransactionType.expense) {
        if (tx.date.month == now.month && tx.date.year == now.year) {
          monthlyExp += tx.amount;
        }
        allExpenses += tx.amount;
      }
    }
    _monthlyExpenses = monthlyExp;
    _netProfit = _totalSales - allExpenses;
  }
}
