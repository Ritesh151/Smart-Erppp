import 'package:flutter/foundation.dart';
import 'package:SmartERP/core/models/transaction_model.dart';
import 'package:SmartERP/core/utils/logger.dart';
import 'package:SmartERP/modules/finance/services/finance_service.dart';

class FinanceProvider extends ChangeNotifier {
  final FinanceService _service;
  VoidCallback? onDataChanged;

  bool _isLoading = false;
  String? _errorMessage;

  double totalSales = 0;
  double totalPurchases = 0;
  double netRevenue = 0;
  double netProfit = 0;
  double totalExpenses = 0;
  double totalPayroll = 0;
  double outstandingPayments = 0;
  double pendingPayments = 0;
  int salesCount = 0;
  int purchasesCount = 0;
  List<Map<String, dynamic>> monthlyRevenue = [];
  List<Map<String, dynamic>> sales = [];
  List<Map<String, dynamic>> purchases = [];

  FinanceProvider(this._service);

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  FinanceSummary get summary => FinanceSummary(
    totalSales: totalSales,
    totalPurchases: totalPurchases,
    netRevenue: netRevenue,
    netProfit: netProfit,
  );

  List<TransactionModel> _transactions = [];
  List<TransactionModel> get transactions => _transactions;

  Future<void> loadFinancialSummary({DateTime? startDate, DateTime? endDate}) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final summary = await _service.getFinancialSummary(
        startDate ?? DateTime.now().subtract(const Duration(days: 365)),
        endDate ?? DateTime.now(),
      );

      totalSales = summary['totalSales'] as double;
      totalPurchases = summary['totalPurchases'] as double;
      netRevenue = summary['netRevenue'] as double;
      netProfit = summary['netProfit'] as double;
      totalExpenses = summary['totalExpenses'] as double;
      totalPayroll = summary['totalPayroll'] as double;
      outstandingPayments = summary['outstandingPayments'] as double;
      pendingPayments = summary['pendingPayments'] as double;
      salesCount = summary['salesCount'] as int;
      purchasesCount = summary['purchasesCount'] as int;
      monthlyRevenue = List<Map<String, dynamic>>.from(summary['monthlyRevenue'] as List);

      _isLoading = false;
      notifyListeners();
      Logger.success('Financial summary loaded');
    } catch (e, stackTrace) {
      _isLoading = false;
      _errorMessage = 'Failed to load financial summary';
      notifyListeners();
      Logger.error('Failed to load financial summary', e, stackTrace);
    }
  }

  Future<void> loadSalesReport({DateTime? startDate, DateTime? endDate}) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      sales = await _service.getSalesReport(
        startDate ?? DateTime.now().subtract(const Duration(days: 365)),
        endDate ?? DateTime.now(),
      );

      _isLoading = false;
      notifyListeners();
      Logger.success('Sales report loaded: ${sales.length} entries');
    } catch (e, stackTrace) {
      _isLoading = false;
      _errorMessage = 'Failed to load sales report';
      notifyListeners();
      Logger.error('Failed to load sales report', e, stackTrace);
    }
  }

  Future<void> loadPurchaseReport({DateTime? startDate, DateTime? endDate}) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      purchases = await _service.getPurchaseReport(
        startDate ?? DateTime.now().subtract(const Duration(days: 365)),
        endDate ?? DateTime.now(),
      );

      _isLoading = false;
      notifyListeners();
      Logger.success('Purchase report loaded: ${purchases.length} entries');
    } catch (e, stackTrace) {
      _isLoading = false;
      _errorMessage = 'Failed to load purchase report';
      notifyListeners();
      Logger.error('Failed to load purchase report', e, stackTrace);
    }
  }

  Future<void> loadTransactions() async {
    await loadFinancialSummary();
    await loadSalesReport();
    await loadPurchaseReport();
    try {
      _transactions = await _service.getAllTransactions();
      notifyListeners();
      onDataChanged?.call();
    } catch (e, stackTrace) {
      Logger.error('Failed to load transactions', e, stackTrace);
    }
  }

  Future<void> savePurchase(Map<String, dynamic> purchase) async {
    try {
      await _service.savePurchase(purchase);
      await loadTransactions();
    } catch (e, stackTrace) {
      _errorMessage = 'Failed to save purchase';
      notifyListeners();
      Logger.error('Failed to save purchase', e, stackTrace);
      rethrow;
    }
  }

  Future<void> deleteSale(String id) async {
    try {
      await _service.deleteSale(id);
      await loadTransactions();
    } catch (e, stackTrace) {
      _errorMessage = 'Failed to delete sale';
      notifyListeners();
      Logger.error('Failed to delete sale', e, stackTrace);
      rethrow;
    }
  }

  Future<void> deletePurchase(String id) async {
    try {
      await _service.deletePurchase(id);
      await loadTransactions();
    } catch (e, stackTrace) {
      _errorMessage = 'Failed to delete purchase';
      notifyListeners();
      Logger.error('Failed to delete purchase', e, stackTrace);
      rethrow;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

class FinanceSummary {
  final double totalSales;
  final double totalPurchases;
  final double netRevenue;
  final double netProfit;

  FinanceSummary({
    required this.totalSales,
    required this.totalPurchases,
    required this.netRevenue,
    required this.netProfit,
  });
}
