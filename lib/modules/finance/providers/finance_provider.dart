import 'package:flutter/foundation.dart';
import 'package:smarterp/core/models/transaction_model.dart';
import 'package:smarterp/modules/finance/models/finance_summary_model.dart';
import 'package:smarterp/modules/finance/services/finance_service.dart';
import 'package:smarterp/core/utils/logger.dart';
import 'package:uuid/uuid.dart';

class FinanceProvider extends ChangeNotifier {
  final FinanceService _service;

  FinanceProvider(this._service);

  List<TransactionModel> _transactions = [];
  List<TransactionModel> _filteredTransactions = [];
  FinanceSummaryModel _summary = FinanceSummaryModel.empty();
  bool _isLoading = false;
  String? _errorMessage;

  DateTime? _startDate;
  DateTime? _endDate;
  TransactionType? _selectedType;
  String _searchQuery = '';

  List<TransactionModel> get transactions => _filteredTransactions;

  FinanceSummaryModel get summary => _summary;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;
  TransactionType? get selectedType => _selectedType;
  String get searchQuery => _searchQuery;

  Future<void> loadTransactions() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _transactions = await _service.getAllTransactions();
      _summary = await _service.getFinanceSummary(_startDate, _endDate);
      _applyFilters();

      _isLoading = false;
      notifyListeners();
      Logger.success('Finance transactions loaded: ${_transactions.length}');
    } catch (e, stackTrace) {
      _isLoading = false;
      _errorMessage = 'Failed to load financial records';
      notifyListeners();
      Logger.error('Failed to load financial records', e, stackTrace);
    }
  }

  Future<void> addTransaction({
    required TransactionType type,
    required double amount,
    required DateTime date,
    required String description,
    String? referenceId,
    String? category,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final tx = TransactionModel(
        id: const Uuid().v4(),
        type: type,
        amount: amount,
        date: date,
        description: description,
        referenceId: referenceId,
        category: category,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _service.saveTransaction(tx);
      await loadTransactions(); 
    } catch (e, stackTrace) {
      _isLoading = false;
      _errorMessage = 'Failed to record transaction';
      notifyListeners();
      Logger.error('Failed to record transaction', e, stackTrace);
      rethrow;
    }
  }

  Future<void> deleteTransaction(String id, TransactionType type) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _service.deleteTransaction(id, type);
      await loadTransactions(); 
    } catch (e, stackTrace) {
      _isLoading = false;
      _errorMessage = 'Failed to delete transaction';
      notifyListeners();
      Logger.error('Failed to delete transaction', e, stackTrace);
      rethrow;
    }
  }

  void filterByDateRange(DateTime? start, DateTime? end) {
    _startDate = start;
    _endDate = end;
    _applyFilters();
    _recalculateSummary();
    notifyListeners();
  }

  void filterByType(TransactionType? type) {
    _selectedType = type;
    _applyFilters();
    notifyListeners();
  }

  void searchTransactions(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void clearFilters() {
    _startDate = null;
    _endDate = null;
    _selectedType = null;
    _searchQuery = '';
    _filteredTransactions = List.from(_transactions);
    _recalculateSummary();
    notifyListeners();
  }

  void _applyFilters() {
    var filtered = List<TransactionModel>.from(_transactions);

    if (_startDate != null) {
      filtered = filtered.where((tx) => tx.date.isAfter(_startDate!.subtract(const Duration(seconds: 1)))).toList();
    }

    if (_endDate != null) {
      filtered = filtered.where((tx) => tx.date.isBefore(_endDate!.add(const Duration(seconds: 1)))).toList();
    }

    if (_selectedType != null) {
      filtered = filtered.where((tx) => tx.type == _selectedType).toList();
    }

    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      filtered = filtered.where((tx) => tx.description.toLowerCase().contains(q) || 
                                       (tx.referenceId?.toLowerCase().contains(q) ?? false) || 
                                       (tx.category?.toLowerCase().contains(q) ?? false)).toList();
    }

    _filteredTransactions = filtered;
  }

  Future<void> _recalculateSummary() async {
    try {
      _summary = await _service.getFinanceSummary(_startDate, _endDate);
    } catch (e) {
      Logger.error('Failed to recalculate finance summary', e);
    }
  }

  Future<Map<String, double>> getMonthlySales(int year) async {
    return await _service.getMonthlySummary(year);
  }
}
