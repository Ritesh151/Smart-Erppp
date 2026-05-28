import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:SmartERP/core/extensions/context_extensions.dart';
import 'package:SmartERP/core/widgets/loading_widget.dart';
import 'package:SmartERP/modules/expenses/providers/expense_provider.dart';

class ExpenseSummaryScreen extends StatefulWidget {
  const ExpenseSummaryScreen({super.key});

  @override
  State<ExpenseSummaryScreen> createState() => _ExpenseSummaryScreenState();
}

class _ExpenseSummaryScreenState extends State<ExpenseSummaryScreen> {
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

    return Consumer<ExpenseProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.expensesByCategory.isEmpty) {
          return const LoadingWidget();
        }

        final byCategory = provider.expensesByCategory;
        final total = provider.totalExpenses;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: SizedBox(
            width: 600,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Expense Summary',
                  style: context.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          'Total Expenses',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '₹${total.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ...byCategory.entries.map(
                  (e) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(e.key),
                      trailing: Text(
                        '₹${e.value.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: LinearProgressIndicator(
                        value: total > 0 ? e.value / total : 0,
                        backgroundColor: Colors.grey.shade200,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
