import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:smarterp/core/models/stock_report_model.dart';
import 'package:smarterp/core/widgets/app_card.dart';

class StockAnalyticsWidget extends StatelessWidget {
  final StockReportModel report;

  const StockAnalyticsWidget({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHealthIndicator(context),
        const SizedBox(height: 24),
        _buildCategoryDistributionChart(context),
      ],
    );
  }

  Widget _buildHealthIndicator(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final health = report.stockHealthPercentage;

    final healthColor = health >= 80
        ? Colors.green
        : health >= 50
            ? Colors.orange
            : Colors.red;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Stock Health', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            children: [
              SizedBox(
                width: 100,
                height: 100,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 100,
                      height: 100,
                      child: CircularProgressIndicator(
                        value: health / 100,
                        strokeWidth: 10,
                        backgroundColor: colorScheme.surfaceContainerHighest,
                        color: healthColor,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('${health.toStringAsFixed(0)}%',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: healthColor)),
                        const Text('Healthy', style: TextStyle(fontSize: 10)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  children: [
                    _healthRow('In Stock', report.inStockCount, Colors.green),
                    const SizedBox(height: 8),
                    _healthRow('Low Stock', report.lowStockCount, Colors.orange),
                    const SizedBox(height: 8),
                    _healthRow('Out of Stock', report.outOfStockCount, Colors.red),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _healthRow(String label, int count, Color color) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Expanded(child: Text(label, style: const TextStyle(fontSize: 13))),
        Text('$count', style: TextStyle(fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _buildCategoryDistributionChart(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final distribution = report.categoryDistribution;

    if (distribution.isEmpty) return const SizedBox.shrink();

    final colors = [
      Colors.blue, Colors.green, Colors.orange, Colors.purple,
      Colors.teal, Colors.cyan, Colors.pink, Colors.indigo,
    ];

    final total = distribution.fold<int>(0, (sum, d) => sum + (d['count'] as int));

    final sections = distribution.asMap().entries.map((entry) {
      final idx = entry.key;
      final item = entry.value;
      final count = item['count'] as int;
      final percent = total > 0 ? (count / total) * 100 : 0.0;

      return PieChartSectionData(
        color: colors[idx % colors.length],
        value: count.toDouble(),
        title: percent >= 5 ? '${percent.toStringAsFixed(0)}%' : '',
        radius: 50,
        titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Category Distribution', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('Products grouped by category',
            style: TextStyle(fontSize: 11, color: colorScheme.onSurface.withOpacity(0.4))),
          const SizedBox(height: 24),
          SizedBox(
            height: 160,
            child: Row(
              children: [
                Expanded(
                  child: PieChart(
                    PieChartData(
                      sections: sections,
                      centerSpaceRadius: 30,
                      sectionsSpace: 2,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: distribution.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final item = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
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
                            '${item['category']} (${item['count']})',
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
}
