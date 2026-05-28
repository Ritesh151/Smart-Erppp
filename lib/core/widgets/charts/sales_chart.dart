import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:SmartERP/core/extensions/context_extensions.dart';
import 'package:SmartERP/core/widgets/app_card.dart';
import 'package:SmartERP/core/models/transaction_model.dart';

class SalesChart extends StatelessWidget {
  final List<TransactionModel> transactions;

  const SalesChart({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final now = DateTime.now();
    final Map<int, double> dailySales = {};
    for (int i = 0; i < 7; i++) dailySales[i] = 0.0;

    for (final tx in transactions) {
      if (tx.type == TransactionType.sale) {
        final diff = now.difference(tx.date).inDays;
        if (diff >= 0 && diff < 7) {
          dailySales[6 - diff] = (dailySales[6 - diff] ?? 0.0) + tx.amount;
        }
      }
    }

    final spots = dailySales.entries
        .map((e) => FlSpot(e.key.toDouble(), e.value / 1000))
        .toList();

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sales Trend (Last 7 Days)',
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
                        final date =
                            now.subtract(Duration(days: 6 - value.toInt()));
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            '${date.day}/${date.month}',
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
                    spots: spots,
                    isCurved: true,
                    color: colorScheme.primary,
                    barWidth: 3,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: colorScheme.primary.withOpacity(0.1),
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
