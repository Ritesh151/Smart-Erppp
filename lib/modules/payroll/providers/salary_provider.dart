import 'package:flutter/foundation.dart';
import 'package:SmartERP/core/models/salary_model.dart';
import 'package:SmartERP/core/models/salary_history_model.dart';
import 'package:SmartERP/modules/payroll/services/salary_service.dart';

class SalaryProvider extends ChangeNotifier {
  final SalaryService _service;

  List<SalaryModel> _salaries = [];
  List<SalaryHistoryModel> _history = [];
  bool _isLoading = false;
  String? _error;
  int? _currentMonth;
  int? _currentYear;

  List<SalaryModel> get salaries => _salaries;
  List<SalaryHistoryModel> get history => _history;
  bool get isLoading => _isLoading;
  String? get error => _error;

  double get totalPayable =>
      _salaries.fold<double>(0, (sum, s) => sum + s.netSalary);

  double get totalPaid =>
      _salaries.fold<double>(0, (sum, s) => sum + s.paidAmount);

  double get totalPending => totalPayable - totalPaid;

  SalaryProvider(this._service);

  Future<void> loadSalaries() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _salaries = await _service.getAllSalaries();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadSalariesForMonth(int month, int year) async {
    _isLoading = true;
    _error = null;
    _currentMonth = month;
    _currentYear = year;
    notifyListeners();

    try {
      _salaries = await _service.getSalariesForMonth(month, year);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadHistory() async {
    try {
      _history = await _service.getAllHistory();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
