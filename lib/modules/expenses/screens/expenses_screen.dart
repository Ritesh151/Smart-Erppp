import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:SmartERP/core/extensions/context_extensions.dart';
import 'package:SmartERP/core/widgets/empty_state_widget.dart';
import 'package:SmartERP/core/widgets/loading_widget.dart';
import 'package:SmartERP/core/models/expense_model.dart';
import 'package:SmartERP/modules/expenses/providers/expense_provider.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExpenseProvider>().loadExpenses();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final theme = context.theme;

    return Consumer<ExpenseProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.expenses.isEmpty) {
          return const LoadingWidget();
        }

        if (provider.errorMessage != null && provider.expenses.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: colorScheme.error),
                const SizedBox(height: 16),
                Text(provider.errorMessage!),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => provider.loadExpenses(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (provider.expenses.isEmpty) {
          return EmptyStateWidget(
            icon: Icons.account_balance_wallet_outlined,
            title: 'No Expenses',
            message: 'Track your expenses here.',
            actionLabel: 'Add Expense',
            onAction: () => context.go('/expenses/add'),
          );
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search expenses...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        isDense: true,
                      ),
                      onChanged: (v) => provider.searchExpenses(v),
                    ),
                  ),
                  const SizedBox(width: 12),
                  FloatingActionButton.small(
                    heroTag: 'add_expense',
                    onPressed: () => context.go('/expenses/add'),
                    child: const Icon(Icons.add),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                itemCount: provider.expenses.length,
                separatorBuilder: (_, __) => const SizedBox(height: 4),
                itemBuilder: (ctx, i) {
                  final expense = provider.expenses[i];
                  return _ExpenseTile(expense: expense);
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ExpenseTile extends StatelessWidget {
  final ExpenseModel expense;
  const _ExpenseTile({required this.expense});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final theme = context.theme;

    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.orange.shade100,
          child: Icon(Icons.receipt_outlined, color: Colors.orange.shade700),
        ),
        title: Text(
          expense.category,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          '${expense.description} \u00b7 ${_formatDate(expense.expenseDate)}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '₹${expense.amount.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            if (expense.vendor != null)
              Text(
                expense.vendor!,
                style: TextStyle(
                  fontSize: 11,
                  color: colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
