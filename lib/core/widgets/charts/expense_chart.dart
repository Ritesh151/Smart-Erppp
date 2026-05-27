import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:smarterp/core/extensions/context_extensions.dart';
import 'package:smarterp/core/widgets/app_card.dart';
import 'package:smarterp/core/theme/theme_extensions.dart';
import 'package:smarterp/core/models/transaction_model.dart';

class ExpenseChart extends StatelessWidget {
  final List<TransactionModel> transactions;

  const ExpenseChart({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final appTheme = context.appTheme;

    final Map<String, double> expenses = {};
    double totalExp = 0;
    for (final tx in transactions) {
      if (tx.type == TransactionType.expense) {
        final cat = tx.category ?? 'Other';
        expenses[cat] = (expenses[cat] ?? 0.0) + tx.amount;
        totalExp += tx.amount;
      }
    }

    final pieSections = expenses.entries.map((entry) {
      final index = expenses.keys.toList().indexOf(entry.key);
      final colors = [
        colorScheme.primary,
        colorScheme.secondary,
        colorScheme.tertiary,
        appTheme.warningColor ?? Colors.orange,
        Colors.purple,
        Colors.teal,
      ];
      final color = colors[index % colors.length];
      final percent = totalExp > 0 ? (entry.value / totalExp) * 100 : 0.0;

      return PieChartSectionData(
        color: color,
        value: entry.value,
        title: '${percent.toStringAsFixed(0)}%',
        radius: 40,
        titleStyle: const TextStyle(
            fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Expense Breakdown',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          if (expenses.isEmpty)
            SizedBox(
              height: 150,
              child: Center(
                  child: Text('No expenses logged in this range',
                      style: TextStyle(
                          color: colorScheme.onSurface.withOpacity(0.5)))),
            )
          else ...[
            SizedBox(
              height: 150,
              child: PieChart(
                PieChartData(
                  sections: pieSections,
                  centerSpaceRadius: 30,
                  sectionsSpace: 2,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 6,
              children: expenses.keys.map((cat) {
                final index = expenses.keys.toList().indexOf(cat);
                final colors = [
                  colorScheme.primary,
                  colorScheme.secondary,
                  colorScheme.tertiary,
                  appTheme.warningColor ?? Colors.orange,
                  Colors.purple,
                  Colors.teal,
                ];
                final color = colors[index % colors.length];
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 8, height: 8, color: color),
                    const SizedBox(width: 4),
                    Text(cat, style: const TextStyle(fontSize: 11)),
                  ],
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}
