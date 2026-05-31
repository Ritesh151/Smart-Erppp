import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:siddhivinayak_enterprise/core/constants/storage_keys.dart';
import 'package:siddhivinayak_enterprise/core/models/salary_model.dart';
import 'package:siddhivinayak_enterprise/core/models/salary_history_model.dart';
import 'package:siddhivinayak_enterprise/modules/payroll/services/salary_service.dart';

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

  StreamSubscription<dynamic>? _salarySubscription;
  StreamSubscription<dynamic>? _historySubscription;
  bool _reloadQueued = false;

  SalaryProvider(this._service) {
    if (Hive.isBoxOpen(StorageKeys.salaryBox)) {
      _salarySubscription = Hive.box(StorageKeys.salaryBox).watch().listen((_) {
        _queueReload();
      });
    }
    if (Hive.isBoxOpen(StorageKeys.salaryHistoryBox)) {
      _historySubscription =
          Hive.box(StorageKeys.salaryHistoryBox).watch().listen((_) {
        _queueReload();
      });
    }
  }

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

  void _queueReload() {
    if (_reloadQueued || _isLoading) return;
    _reloadQueued = true;
    Future.microtask(() async {
      _reloadQueued = false;
      if (_currentMonth != null && _currentYear != null) {
        await loadSalariesForMonth(_currentMonth!, _currentYear!);
      } else {
        await loadSalaries();
      }
      await loadHistory();
    });
  }

  @override
  void dispose() {
    _salarySubscription?.cancel();
    _historySubscription?.cancel();
    super.dispose();
  }
}
