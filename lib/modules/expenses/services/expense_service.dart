import 'package:SmartERP/core/models/expense_model.dart';
import 'package:SmartERP/modules/expenses/repositories/expense_repository.dart';
import 'package:SmartERP/core/utils/logger.dart';
import 'package:uuid/uuid.dart';

class ExpenseService {
  final ExpenseRepository _repository;

  ExpenseService(this._repository);

  Future<List<ExpenseModel>> getAllExpenses() async {
    return await _repository.getAll();
  }

  Future<ExpenseModel?> getExpenseById(String id) async {
    return await _repository.getById(id);
  }

  Future<ExpenseModel> createExpense({
    required String category,
    required String description,
    required double amount,
    required DateTime expenseDate,
    String? vendor,
    String? notes,
  }) async {
    final expense = ExpenseModel(
      id: const Uuid().v4(),
      expenseNumber: _generateExpenseNumber(),
      category: category,
      description: description,
      amount: amount,
      expenseDate: expenseDate,
      vendor: vendor,
      paymentMethod: null,
      referenceNumber: null,
      status: ExpenseStatus.pending,
      approvedBy: null,
      approvedAt: null,
      notes: notes,
      attachments: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _repository.save(expense);
    Logger.success('Expense created: ${expense.expenseNumber}');
    return expense;
  }

  Future<List<ExpenseModel>> searchExpenses(String query) async {
    final all = await _repository.getAll();
    if (query.trim().isEmpty) return all;
    final q = query.toLowerCase();
    return all.where((e) =>
      e.description.toLowerCase().contains(q) ||
      e.category.toLowerCase().contains(q) ||
      (e.vendor?.toLowerCase().contains(q) ?? false)
    ).toList();
  }

  Future<Map<String, double>> getExpensesByCategory() async {
    final all = await _repository.getAll();
    final Map<String, double> result = {};
    for (final e in all) {
      result[e.category] = (result[e.category] ?? 0) + e.amount;
    }
    return result;
  }

  Future<ExpenseModel> updateExpense({
    required String id,
    required String category,
    required String description,
    required double amount,
    required DateTime expenseDate,
    String? vendor,
    String? notes,
  }) async {
    final existing = await _repository.getById(id);
    if (existing == null) throw Exception('Expense not found');

    final updated = ExpenseModel(
      id: existing.id,
      expenseNumber: existing.expenseNumber,
      category: category,
      description: description,
      amount: amount,
      expenseDate: expenseDate,
      vendor: vendor,
      paymentMethod: existing.paymentMethod,
      referenceNumber: existing.referenceNumber,
      status: existing.status,
      approvedBy: existing.approvedBy,
      approvedAt: existing.approvedAt,
      notes: notes,
      attachments: existing.attachments,
      createdAt: existing.createdAt,
      updatedAt: DateTime.now(),
    );

    await _repository.save(updated);
    Logger.success('Expense updated: ${updated.expenseNumber}');
    return updated;
  }

  Future<void> deleteExpense(String id) async {
    await _repository.delete(id);
  }

  Future<double> getTotalExpenses() async {
    final all = await _repository.getAll();
    return all.fold<double>(0, (sum, e) => sum + e.amount);
  }

  String _generateExpenseNumber() {
    final now = DateTime.now();
    final ts = now.millisecondsSinceEpoch.toString().substring(5);
    return 'EXP-$ts';
  }
}
