import 'package:flutter/foundation.dart';
import 'package:smarterp/core/models/employee_model.dart';
import 'package:smarterp/core/utils/logger.dart';
import 'package:smarterp/modules/payroll/services/payroll_service.dart';

class PayrollProvider extends ChangeNotifier {
  final PayrollService _service;

  PayrollProvider(this._service);

  PayrollDashboardData? _dashboardData;
  MonthlySalarySummary? _monthlySummary;
  List<int> _monthlyTrend = [];
  List<double> _salaryTrend = [];
  Map<String, int> _employeeDistribution = {};
  Map<EmployeeStatus, int> _statusDistribution = {};

  bool _isLoading = false;
  String? _errorMessage;

  PayrollDashboardData? get dashboardData => _dashboardData;
  MonthlySalarySummary? get monthlySummary => _monthlySummary;
  List<int> get monthlyTrend => _monthlyTrend;
  List<double> get salaryTrend => _salaryTrend;
  Map<String, int> get employeeDistribution => _employeeDistribution;
  Map<EmployeeStatus, int> get statusDistribution => _statusDistribution;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadDashboard() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final results = await Future.wait([
        _service.getDashboardData(),
        _service.getMonthlyTrend(),
        _service.getSalaryTrend(),
        _service.getEmployeeDistribution(),
        _service.getEmployeeStatusDistribution(),
      ]);

      _dashboardData = results[0] as PayrollDashboardData;
      _monthlyTrend = results[1] as List<int>;
      _salaryTrend = results[2] as List<double>;
      _employeeDistribution = results[3] as Map<String, int>;
      _statusDistribution = results[4] as Map<EmployeeStatus, int>;

      _isLoading = false;
      notifyListeners();
      Logger.success('Payroll dashboard data loaded');
    } catch (e, stackTrace) {
      _isLoading = false;
      _errorMessage = 'Failed to load dashboard data';
      notifyListeners();
      Logger.error('Failed to load dashboard data', e, stackTrace);
    }
  }

  Future<void> loadMonthlySummary(int month, int year) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _monthlySummary = await _service.getMonthlySummary(month, year);

      _isLoading = false;
      notifyListeners();
    } catch (e, stackTrace) {
      _isLoading = false;
      _errorMessage = 'Failed to load monthly summary';
      notifyListeners();
      Logger.error('Failed to load monthly summary', e, stackTrace);
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
