import 'package:flutter/foundation.dart';
import 'package:smarterp/core/exceptions/app_exception.dart';
import 'package:smarterp/core/models/salary_model.dart';
import 'package:smarterp/core/models/salary_history_model.dart';
import 'package:smarterp/core/utils/logger.dart';
import 'package:smarterp/modules/payroll/services/salary_service.dart';

class SalaryProvider extends ChangeNotifier {
  final SalaryService _service;

  SalaryProvider(this._service);

  List<SalaryModel> _salaries = [];
  List<SalaryHistoryModel> _paymentHistory = [];
  SalaryModel? _selectedSalary;

  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;
  SalaryStatus? _selectedStatus;

  bool _isLoading = false;
  String? _errorMessage;

  List<SalaryModel> get salaries => _salaries;
  List<SalaryHistoryModel> get paymentHistory => _paymentHistory;
  SalaryModel? get selectedSalary => _selectedSalary;

  int get selectedMonth => _selectedMonth;
  int get selectedYear => _selectedYear;
  SalaryStatus? get selectedStatus => _selectedStatus;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int get totalCount => _salaries.length;
  int get paidCount => _salaries.where((s) => s.isFullyPaid).length;
  int get pendingCount => _salaries.where((s) =>
      s.status == SalaryStatus.pending || s.status == SalaryStatus.overdue).length;
  int get partialPaidCount => _salaries.where((s) => s.isPartiallyPaid).length;

  double get totalPayable =>
      _salaries.fold(0.0, (sum, s) => sum + s.netSalary);
  double get totalPaid =>
      _salaries.fold(0.0, (sum, s) => sum + s.paidAmount);
  double get totalPending =>
      _salaries.fold(0.0, (sum, s) => sum + s.pendingAmount);

  List<SalaryModel> get filteredSalaries {
    if (_selectedStatus == null) return _salaries;
    return _salaries.where((s) => s.status == _selectedStatus).toList();
  }

  Future<void> loadSalaries() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _salaries = await _service.getSalariesByMonth(_selectedMonth, _selectedYear);

      _isLoading = false;
      notifyListeners();
      Logger.success('Salaries loaded: ${_salaries.length}');
    } catch (e, stackTrace) {
      _isLoading = false;
      _errorMessage = 'Failed to load salaries';
      notifyListeners();
      Logger.error('Failed to load salaries', e, stackTrace);
    }
  }

  Future<void> loadSalariesForMonth(int month, int year) async {
    _selectedMonth = month;
    _selectedYear = year;
    notifyListeners();
    await loadSalaries();
  }

  Future<void> generateSalary({
    required String employeeId,
    required String employeeName,
    required double basicSalary,
    double bonus = 0,
    double overtime = 0,
    double deductions = 0,
    String? notes,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final salary = await _service.generateSalary(
        employeeId: employeeId,
        employeeName: employeeName,
        month: _selectedMonth,
        year: _selectedYear,
        basicSalary: basicSalary,
        bonus: bonus,
        overtime: overtime,
        deductions: deductions,
        notes: notes,
      );

      _salaries.add(salary);

      _isLoading = false;
      notifyListeners();
      Logger.success('Salary generated for $employeeName');
    } on ValidationException catch (e) {
      _isLoading = false;
      _errorMessage = e.message;
      notifyListeners();
      rethrow;
    } catch (e, stackTrace) {
      _isLoading = false;
      _errorMessage = 'Failed to generate salary';
      notifyListeners();
      Logger.error('Failed to generate salary', e, stackTrace);
      rethrow;
    }
  }

  Future<void> updateSalary({
    required String id,
    double? bonus,
    double? overtime,
    double? deductions,
    String? notes,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final updated = await _service.updateSalary(
        id: id,
        bonus: bonus,
        overtime: overtime,
        deductions: deductions,
        notes: notes,
      );

      final index = _salaries.indexWhere((s) => s.id == id);
      if (index != -1) _salaries[index] = updated;
      if (_selectedSalary?.id == id) _selectedSalary = updated;

      _isLoading = false;
      notifyListeners();
      Logger.success('Salary updated');
    } on ValidationException catch (e) {
      _isLoading = false;
      _errorMessage = e.message;
      notifyListeners();
      rethrow;
    } catch (e, stackTrace) {
      _isLoading = false;
      _errorMessage = 'Failed to update salary';
      notifyListeners();
      Logger.error('Failed to update salary', e, stackTrace);
      rethrow;
    }
  }

  Future<void> processPayment({
    required String salaryId,
    required double amount,
    required PaymentMethod paymentMethod,
    String? referenceNumber,
    String? notes,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final updated = await _service.processPayment(
        salaryId: salaryId,
        amount: amount,
        paymentMethod: paymentMethod,
        referenceNumber: referenceNumber,
        notes: notes,
      );

      final index = _salaries.indexWhere((s) => s.id == salaryId);
      if (index != -1) _salaries[index] = updated;
      if (_selectedSalary?.id == salaryId) {
        _selectedSalary = updated;
        await loadPaymentHistory(salaryId);
      }

      _isLoading = false;
      notifyListeners();
      Logger.success('Payment processed');
    } on ValidationException catch (e) {
      _isLoading = false;
      _errorMessage = e.message;
      notifyListeners();
      rethrow;
    } catch (e, stackTrace) {
      _isLoading = false;
      _errorMessage = 'Failed to process payment';
      notifyListeners();
      Logger.error('Failed to process payment', e, stackTrace);
      rethrow;
    }
  }

  Future<void> loadPaymentHistory(String salaryId) async {
    try {
      _paymentHistory = await _service.getPaymentHistory(salaryId);
      notifyListeners();
    } catch (e, stackTrace) {
      Logger.error('Failed to load payment history', e, stackTrace);
    }
  }

  void selectSalary(SalaryModel? salary) {
    _selectedSalary = salary;
    if (salary != null) {
      loadPaymentHistory(salary.id);
    } else {
      _paymentHistory = [];
    }
    notifyListeners();
  }

  void filterByStatus(SalaryStatus? status) {
    _selectedStatus = status;
    notifyListeners();
  }

  void clearFilters() {
    _selectedStatus = null;
    notifyListeners();
  }

  Future<void> deleteSalary(String id) async {
    try {
      await _service.deleteSalary(id);
      _salaries.removeWhere((s) => s.id == id);
      if (_selectedSalary?.id == id) {
        _selectedSalary = null;
        _paymentHistory = [];
      }
      notifyListeners();
      Logger.success('Salary deleted');
    } catch (e, stackTrace) {
      _errorMessage = 'Failed to delete salary';
      notifyListeners();
      Logger.error('Failed to delete salary', e, stackTrace);
      rethrow;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
