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
  Map<String, double> get expensesByCategory => _expensesByCategory;
  double get totalExpenses => _totalExpenses;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;

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
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _expenses = await _service.getAllExpenses();
      _applyFilters();
      await _refreshSummary();

      _isLoading = false;
      notifyListeners();
      onDataChanged?.call();
      Logger.success('Expenses loaded: ${_expenses.length}');
    } catch (e, stackTrace) {
      _isLoading = false;
      _errorMessage = 'Failed to load expenses';
      notifyListeners();
      Logger.error('Failed to load expenses', e, stackTrace);
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
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

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
      _isLoading = false;
      _errorMessage = 'Failed to add expense';
      notifyListeners();
      Logger.error('Failed to add expense', e, stackTrace);
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
      notifyListeners();
      Logger.error('Failed to delete expense', e, stackTrace);
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
