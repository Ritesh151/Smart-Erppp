import 'package:flutter/foundation.dart';
import 'package:smarterp/core/models/report_enums.dart';
import 'package:smarterp/core/models/report_model.dart';
import 'package:smarterp/core/models/sales_report_model.dart';
import 'package:smarterp/core/models/purchase_report_model.dart';
import 'package:smarterp/core/models/expense_report_model.dart';
import 'package:smarterp/core/models/stock_report_model.dart';
import 'package:smarterp/core/models/profit_loss_model.dart';
import 'package:smarterp/core/models/payroll_report_model.dart';
import 'package:smarterp/core/utils/logger.dart';
import 'package:smarterp/modules/reports/services/report_service.dart';

class ReportProvider extends ChangeNotifier {
  final ReportService _service;

  ReportProvider(this._service);

  List<ReportModel> _reports = [];
  ReportModel? _selectedReport;

  SalesReportModel? _salesReport;
  PurchaseReportModel? _purchaseReport;
  ExpenseReportModel? _expenseReport;
  StockReportModel? _stockReport;
  ProfitLossModel? _profitLossReport;
  PayrollReportModel? _payrollReport;

  bool _isLoading = false;
  bool _isGenerating = false;
  String? _errorMessage;
  String? _successMessage;

  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;
  ReportType? _selectedType;

  List<ReportModel> get reports => _reports;
  ReportModel? get selectedReport => _selectedReport;

  SalesReportModel? get salesReport => _salesReport;
  PurchaseReportModel? get purchaseReport => _purchaseReport;
  ExpenseReportModel? get expenseReport => _expenseReport;
  StockReportModel? get stockReport => _stockReport;
  ProfitLossModel? get profitLossReport => _profitLossReport;
  PayrollReportModel? get payrollReport => _payrollReport;

  bool get isLoading => _isLoading;
  bool get isGenerating => _isGenerating;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  int get selectedMonth => _selectedMonth;
  int get selectedYear => _selectedYear;
  ReportType? get selectedType => _selectedType;

  Future<void> loadReports() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _reports = await _service.getReportsByType(_selectedType ?? ReportType.sales);

      _isLoading = false;
      notifyListeners();
      Logger.success('Reports loaded: ${_reports.length}');
    } catch (e, stackTrace) {
      _isLoading = false;
      _errorMessage = 'Failed to load reports';
      notifyListeners();
      Logger.error('Failed to load reports', e, stackTrace);
    }
  }

  void selectMonth(int month, int year) {
    _selectedMonth = month;
    _selectedYear = year;
    notifyListeners();
  }

  void selectType(ReportType? type) {
    _selectedType = type;
    notifyListeners();
    loadReports();
  }

  Future<void> generateSalesReport() async {
    try {
      _isGenerating = true;
      _errorMessage = null;
      _successMessage = null;
      notifyListeners();

      final result = await _service.generateSalesReport(
        month: _selectedMonth,
        year: _selectedYear,
      );

      if (result.success) {
        _successMessage = 'Sales report generated successfully';
        await loadReports();
      }

      _isGenerating = false;
      notifyListeners();
    } catch (e, stackTrace) {
      _isGenerating = false;
      _errorMessage = 'Failed to generate sales report';
      notifyListeners();
      Logger.error('Failed to generate sales report', e, stackTrace);
    }
  }

  Future<void> generatePurchaseReport() async {
    try {
      _isGenerating = true;
      _errorMessage = null;
      _successMessage = null;
      notifyListeners();

      final result = await _service.generatePurchaseReport(
        month: _selectedMonth,
        year: _selectedYear,
      );

      if (result.success) {
        _successMessage = 'Purchase report generated successfully';
        await loadReports();
      }

      _isGenerating = false;
      notifyListeners();
    } catch (e, stackTrace) {
      _isGenerating = false;
      _errorMessage = 'Failed to generate purchase report';
      notifyListeners();
      Logger.error('Failed to generate purchase report', e, stackTrace);
    }
  }

  Future<void> generateExpenseReport() async {
    try {
      _isGenerating = true;
      _errorMessage = null;
      _successMessage = null;
      notifyListeners();

      final result = await _service.generateExpenseReport(
        month: _selectedMonth,
        year: _selectedYear,
      );

      if (result.success) {
        _successMessage = 'Expense report generated successfully';
        await loadReports();
      }

      _isGenerating = false;
      notifyListeners();
    } catch (e, stackTrace) {
      _isGenerating = false;
      _errorMessage = 'Failed to generate expense report';
      notifyListeners();
      Logger.error('Failed to generate expense report', e, stackTrace);
    }
  }

  Future<void> generateStockReport() async {
    try {
      _isGenerating = true;
      _errorMessage = null;
      _successMessage = null;
      notifyListeners();

      final result = await _service.generateStockReport(
        month: _selectedMonth,
        year: _selectedYear,
      );

      if (result.success) {
        _successMessage = 'Stock report generated successfully';
        await loadReports();
      }

      _isGenerating = false;
      notifyListeners();
    } catch (e, stackTrace) {
      _isGenerating = false;
      _errorMessage = 'Failed to generate stock report';
      notifyListeners();
      Logger.error('Failed to generate stock report', e, stackTrace);
    }
  }

  Future<void> generateProfitLossReport() async {
    try {
      _isGenerating = true;
      _errorMessage = null;
      _successMessage = null;
      notifyListeners();

      final result = await _service.generateProfitLossReport(
        month: _selectedMonth,
        year: _selectedYear,
      );

      if (result.success) {
        _successMessage = 'Profit & loss report generated successfully';
        await loadReports();
      }

      _isGenerating = false;
      notifyListeners();
    } catch (e, stackTrace) {
      _isGenerating = false;
      _errorMessage = 'Failed to generate profit/loss report';
      notifyListeners();
      Logger.error('Failed to generate profit/loss report', e, stackTrace);
    }
  }

  Future<void> generatePayrollReport() async {
    try {
      _isGenerating = true;
      _errorMessage = null;
      _successMessage = null;
      notifyListeners();

      final result = await _service.generatePayrollReport(
        month: _selectedMonth,
        year: _selectedYear,
      );

      if (result.success) {
        _successMessage = 'Payroll report generated successfully';
        await loadReports();
      }

      _isGenerating = false;
      notifyListeners();
    } catch (e, stackTrace) {
      _isGenerating = false;
      _errorMessage = 'Failed to generate payroll report';
      notifyListeners();
      Logger.error('Failed to generate payroll report', e, stackTrace);
    }
  }

  Future<void> deleteReport(String id) async {
    try {
      await _service.deleteReport(id);
      _reports.removeWhere((r) => r.id == id);
      if (_selectedReport?.id == id) _selectedReport = null;
      notifyListeners();
      Logger.success('Report deleted');
    } catch (e, stackTrace) {
      _errorMessage = 'Failed to delete report';
      notifyListeners();
      Logger.error('Failed to delete report', e, stackTrace);
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearSuccess() {
    _successMessage = null;
    notifyListeners();
  }

  void selectReport(ReportModel? report) {
    _selectedReport = report;
    notifyListeners();
  }
}
