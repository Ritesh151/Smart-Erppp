import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:smarterp/core/extensions/context_extensions.dart';
import 'package:smarterp/core/widgets/app_card.dart';
import 'package:smarterp/core/models/transaction_model.dart';

class ProfitChart extends StatelessWidget {
  final List<TransactionModel> transactions;

  const ProfitChart({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final now = DateTime.now();

    final Map<int, double> monthlyRevenue = {};
    final Map<int, double> monthlyExpenses = {};
    for (int i = 5; i >= 0; i--) {
      final m = now.month - i;
      final key = m > 0 ? m : 12 + m;
      monthlyRevenue[key] = 0.0;
      monthlyExpenses[key] = 0.0;
    }

    for (final tx in transactions) {
      final monthsAgo = now.month - tx.date.month + (now.year - tx.date.year) * 12;
      if (monthsAgo >= 0 && monthsAgo < 6) {
        final key = tx.date.month;
        if (tx.type == TransactionType.sale || tx.type == TransactionType.income) {
          monthlyRevenue[key] = (monthlyRevenue[key] ?? 0.0) + tx.amount;
        } else if (tx.type == TransactionType.expense || tx.type == TransactionType.purchase) {
          monthlyExpenses[key] = (monthlyExpenses[key] ?? 0.0) + tx.amount;
        }
      }
    }

    final revenueSpots = monthlyRevenue.entries
        .map((e) => FlSpot(e.key.toDouble(), e.value / 1000))
        .toList();
    final expenseSpots = monthlyExpenses.entries
        .map((e) => FlSpot(e.key.toDouble(), e.value / 1000))
        .toList();

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Revenue vs Expenses (6 Months)',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Figures in thousands (₹)',
            style: TextStyle(
              fontSize: 11,
              color: colorScheme.onSurface.withOpacity(0.4),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final monthNames = [
                          'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
                        ];
                        final idx = value.toInt() - 1;
                        if (idx < 0 || idx >= 12) return const SizedBox();
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            monthNames[idx],
                            style: const TextStyle(fontSize: 10),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: revenueSpots,
                    isCurved: true,
                    color: Colors.green,
                    barWidth: 3,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.green.withOpacity(0.1),
                    ),
                  ),
                  LineChartBarData(
                    spots: expenseSpots,
                    isCurved: true,
                    color: Colors.red,
                    barWidth: 3,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.red.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
