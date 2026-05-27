import 'package:flutter/foundation.dart';
import 'package:smarterp/core/utils/logger.dart';
import 'package:smarterp/modules/reports/services/analytics_service.dart';

class AnalyticsProvider extends ChangeNotifier {
  final AnalyticsService _service;

  AnalyticsProvider(this._service);

  SalesKpi? _salesKpi;
  ExpenseKpi? _expenseKpi;
  InventoryKpi? _inventoryKpi;
  PayrollKpi? _payrollKpi;
  ProfitKpi? _profitKpi;
  CombinedKpi? _combinedKpi;

  List<double> _salesTrend = [];
  List<double> _expenseTrend = [];
  List<String> _trendLabels = [];

  bool _isLoading = false;
  String? _errorMessage;

  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

  SalesKpi? get salesKpi => _salesKpi;
  ExpenseKpi? get expenseKpi => _expenseKpi;
  InventoryKpi? get inventoryKpi => _inventoryKpi;
  PayrollKpi? get payrollKpi => _payrollKpi;
  ProfitKpi? get profitKpi => _profitKpi;
  CombinedKpi? get combinedKpi => _combinedKpi;

  List<double> get salesTrend => _salesTrend;
  List<double> get expenseTrend => _expenseTrend;
  List<String> get trendLabels => _trendLabels;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get selectedMonth => _selectedMonth;
  int get selectedYear => _selectedYear;

  Future<void> loadAllKpis() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final results = await Future.wait([
        _service.calculateAllKpis(_selectedMonth, _selectedYear),
        _service.getSalesTrend(6),
        _service.getExpenseTrend(6),
      ]);

      _combinedKpi = results[0] as CombinedKpi;
      _salesKpi = _combinedKpi!.sales;
      _expenseKpi = _combinedKpi!.expenses;
      _inventoryKpi = _combinedKpi!.inventory;
      _payrollKpi = _combinedKpi!.payroll;
      _profitKpi = _combinedKpi!.profit;

      _salesTrend = results[1] as List<double>;
      _expenseTrend = results[2] as List<double>;
      _trendLabels = _service.getTrendLabels(6);

      _isLoading = false;
      notifyListeners();
      Logger.success('All KPIs loaded');
    } catch (e, stackTrace) {
      _isLoading = false;
      _errorMessage = 'Failed to load KPIs';
      notifyListeners();
      Logger.error('Failed to load KPIs', e, stackTrace);
    }
  }

  Future<void> loadMonthKpis(int month, int year) async {
    _selectedMonth = month;
    _selectedYear = year;
    notifyListeners();
    await loadAllKpis();
  }

  Future<void> refreshKpis() async {
    await loadAllKpis();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
