// lib/Pages/Reports/expense_statement_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:siddhivinayak_enterprise/core/models/expense_model.dart';
import 'package:siddhivinayak_enterprise/core/utils/currency_formatter.dart';
import 'package:siddhivinayak_enterprise/core/utils/date_helper.dart';
import 'package:siddhivinayak_enterprise/core/widgets/app_scaffold.dart';
import 'package:siddhivinayak_enterprise/core/widgets/date_range_picker.dart';
import 'package:siddhivinayak_enterprise/core/widgets/empty_state_widget.dart';
import 'package:siddhivinayak_enterprise/core/widgets/loading_widget.dart';
import 'package:siddhivinayak_enterprise/modules/expenses/providers/expense_provider.dart';

class ExpenseStatementScreen extends StatefulWidget {
  const ExpenseStatementScreen({super.key});

  @override
  State<ExpenseStatementScreen> createState() => _ExpenseStatementScreenState();
}

class _ExpenseStatementScreenState extends State<ExpenseStatementScreen> {
  DateTimeRange? _range;

  @override
  void initState() {
    super.initState();
    _range = DateHelper.currentMonth();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExpenseProvider>().loadExpenses();
    });
  }

  @override
  Widget build(BuildContext context) {
    final expenseProvider = context.watch<ExpenseProvider>();
    final all = expenseProvider.expenses;
    final isLoading = expenseProvider.isLoading;

    return AppScaffold(
      title: 'Expense Statement',
      backRoute: '/reports',
      body: isLoading
          ? const LoadingWidget()
          : _buildContent(all),
    );
  }

  Widget _buildContent(List<ExpenseModel> all) {
    final filtered = _range == null
        ? all
        : all
            .where((e) => DateHelper.isInRange(e.expenseDate, _range!))
            .toList();

    // Group by category
    final Map<String, double> byCategory = {};
    for (final e in filtered) {
      byCategory[e.category] =
          (byCategory[e.category] ?? 0) + e.amount;
    }
    final grandTotal =
        filtered.fold<double>(0, (s, e) => s + e.amount);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: DateRangePickerWidget(
            initialRange: _range,
            onChanged: (r) => setState(() => _range = r),
          ),
        ),

        // Category summary cards
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Expenses',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  Text(CurrencyFormatter.format(grandTotal),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                ],
              ),
              const Divider(),
              ...byCategory.entries.map(
                (e) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(e.key,
                          style: const TextStyle(fontSize: 13)),
                      Text(CurrencyFormatter.format(e.value),
                          style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 13)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        Expanded(
          child: filtered.isEmpty
              ? const EmptyStateWidget(
                  icon: Icons.account_balance_wallet_outlined,
                  title: 'No Expenses',
                  message: 'No expenses in the selected period.',
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: 4),
                  itemBuilder: (ctx, i) {
                    final e = filtered[i];
                    return Card(
                      margin: EdgeInsets.zero,
                      child: ListTile(
                        title: Text(e.category,
                            style: const TextStyle(
                                fontWeight: FontWeight.w500)),
                        subtitle: Text(
                            '${e.description} · ${DateHelper.display(e.expenseDate)}'),
                        trailing: Text(
                            CurrencyFormatter.format(e.amount),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold)),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
