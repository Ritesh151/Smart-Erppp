import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:smarterp/core/models/expense_report_model.dart';
import 'package:smarterp/core/widgets/app_card.dart';

class ExpenseAnalyticsWidget extends StatelessWidget {
  final ExpenseReportModel report;

  const ExpenseAnalyticsWidget({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCategoryPieChart(context),
        const SizedBox(height: 24),
        if (report.topExpenses.isNotEmpty)
          _buildTopExpenses(context),
      ],
    );
  }

  Widget _buildCategoryPieChart(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final breakdown = report.categoryBreakdown;

    if (breakdown.isEmpty) return const SizedBox.shrink();

    final total = breakdown.values.fold(0.0, (a, b) => a + b);
    final colors = [
      Colors.red, Colors.orange, Colors.blue, Colors.green,
      Colors.purple, Colors.teal, Colors.cyan, Colors.pink,
      Colors.indigo, Colors.amber,
    ];

    final sections = breakdown.entries.toList().asMap().entries.map((entry) {
      final idx = entry.key;
      final categoryEntry = entry.value;
      final percent = total > 0 ? (categoryEntry.value / total) * 100 : 0.0;

      return PieChartSectionData(
        color: colors[idx % colors.length],
        value: categoryEntry.value,
        title: percent >= 5 ? '${percent.toStringAsFixed(0)}%' : '',
        radius: 50,
        titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Category Breakdown', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('Expense distribution by category',
            style: TextStyle(fontSize: 11, color: colorScheme.onSurface.withOpacity(0.4))),
          const SizedBox(height: 24),
          SizedBox(
            height: 180,
            child: Row(
              children: [
                Expanded(
                  child: PieChart(
                    PieChartData(
                      sections: sections,
                      centerSpaceRadius: 35,
                      sectionsSpace: 2,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: breakdown.entries.toList().asMap().entries.map((entry) {
                    final idx = entry.key;
                    final categoryEntry = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 10, height: 10,
                            decoration: BoxDecoration(
                              color: colors[idx % colors.length],
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${categoryEntry.key} (₹${categoryEntry.value.toStringAsFixed(0)})',
                            style: const TextStyle(fontSize: 10),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopExpenses(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Top Expenses', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ...report.topExpenses.take(10).map((e) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.receipt, size: 16, color: Colors.red),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(e['description'] as String? ?? '',
                        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                      Text(e['category'] as String? ?? '',
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                    ],
                  ),
                ),
                Text('₹${(e['amount'] as num).toStringAsFixed(0)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
