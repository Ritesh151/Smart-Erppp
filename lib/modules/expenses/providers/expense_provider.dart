import 'package:flutter/foundation.dart';
import 'package:SmartERP/core/models/expense_model.dart';
import 'package:SmartERP/modules/expenses/services/expense_service.dart';
import 'package:SmartERP/core/utils/logger.dart';

class ExpenseProvider extends ChangeNotifier {
  final ExpenseService _service;
  VoidCallback? onDataChanged;

  ExpenseProvider(this._service, {VoidCallback? onDataChanged})
      : onDataChanged = onDataChanged;

  List<ExpenseModel> _expenses = [];
  List<ExpenseModel> _filteredExpenses = [];
  Map<String, double> _expensesByCategory = {};
  double _totalExpenses = 0;
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';

  List<ExpenseModel> get expenses => _filteredExpenses;

  ExpenseModel? getExpenseById(String id) {
    try {
      return _expenses.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }
  Map<String, double> get expensesByCategory => _expensesByCategory;
  double get totalExpenses => _totalExpenses;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;

  ExpenseModel? _selectedExpense;

  ExpenseModel? get selectedExpense => _selectedExpense;

  Future<void> loadExpenseById(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _selectedExpense = await _service.getExpenseById(id);
    } catch (e, stackTrace) {
      _errorMessage = 'Failed to load expense details';
      Logger.error('Failed to load expense details', e, stackTrace);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  static const List<String> categories = [
    'Raw Materials',
    'Transportation',
    'Utilities',
    'Salaries',
    'Maintenance',
    'Office Supplies',
    'Marketing',
    'Other',
  ];

  Future<void> loadExpenses() async {
    Logger.debug('loadExpenses: START');
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      Logger.debug('loadExpenses: calling service.getAllExpenses');
      _expenses = await _service.getAllExpenses();
      Logger.debug('loadExpenses: getAllExpenses done, count=${_expenses.length}');
      _applyFilters();
      Logger.debug('loadExpenses: _applyFilters done');
      await _refreshSummary();
      Logger.debug('loadExpenses: _refreshSummary done');
      Logger.success('Expenses loaded: ${_expenses.length}');
    } catch (e, stackTrace) {
      _errorMessage = 'Failed to load expenses';
      Logger.error('loadExpenses: FAILED', e, stackTrace);
    } finally {
      _isLoading = false;
      notifyListeners();
      Logger.debug('loadExpenses: END isLoading=false, errorMessage=$_errorMessage');
      if (_errorMessage == null) onDataChanged?.call();
    }
  }

  Future<void> addExpense({
    required String category,
    required String description,
    required double amount,
    required DateTime expenseDate,
    String? vendor,
    String? notes,
  }) async {
    try {
      await _service.createExpense(
        category: category,
        description: description,
        amount: amount,
        expenseDate: expenseDate,
        vendor: vendor,
        notes: notes,
      );
      await loadExpenses();
    } catch (e, stackTrace) {
      _errorMessage = 'Failed to add expense';
      notifyListeners();
      Logger.error('Failed to add expense', e, stackTrace);
      rethrow;
    }
  }

  Future<void> updateExpense({
    required String id,
    required String category,
    required String description,
    required double amount,
    required DateTime expenseDate,
    String? vendor,
    String? notes,
  }) async {
    try {
      await _service.updateExpense(
        id: id,
        category: category,
        description: description,
        amount: amount,
        expenseDate: expenseDate,
        vendor: vendor,
        notes: notes,
      );
      await loadExpenses();
    } catch (e, stackTrace) {
      _errorMessage = 'Failed to update expense';
      notifyListeners();
      Logger.error('Failed to update expense', e, stackTrace);
      rethrow;
    }
  }

  Future<void> deleteExpense(String id) async {
    try {
      await _service.deleteExpense(id);
      _expenses.removeWhere((e) => e.id == id);
      _applyFilters();
      await _refreshSummary();
      notifyListeners();
      onDataChanged?.call();
    } catch (e, stackTrace) {
      _errorMessage = 'Failed to delete expense';
      Logger.error('Failed to delete expense', e, stackTrace);
      notifyListeners();
      rethrow;
    }
  }

  void searchExpenses(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    _filteredExpenses = List.from(_expenses);
    notifyListeners();
  }

  void _applyFilters() {
    if (_searchQuery.trim().isEmpty) {
      _filteredExpenses = List.from(_expenses);
    } else {
      final q = _searchQuery.toLowerCase();
      _filteredExpenses = _expenses.where((e) =>
        e.description.toLowerCase().contains(q) ||
        e.category.toLowerCase().contains(q) ||
        (e.vendor?.toLowerCase().contains(q) ?? false)
      ).toList();
    }
  }

  Future<void> _refreshSummary() async {
    _expensesByCategory = await _service.getExpensesByCategory();
    _totalExpenses = await _service.getTotalExpenses();
  }
}
