import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:smarterp/core/theme/theme_extensions.dart';
import 'package:smarterp/modules/payroll/providers/payroll_provider.dart';

class PayrollAnalyticsWidget extends StatelessWidget {
  final PayrollProvider provider;

  const PayrollAnalyticsWidget({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final dashboard = provider.dashboardData;
    if (dashboard == null) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 800;
        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildStatusPieChart(context)),
              const SizedBox(width: 24),
              Expanded(child: _buildSalaryTrendChart(context)),
            ],
          );
        }
        return Column(
          children: [
            _buildStatusPieChart(context),
            const SizedBox(height: 24),
            _buildSalaryTrendChart(context),
          ],
        );
      },
    );
  }

  Widget _buildStatusPieChart(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final dashboard = provider.dashboardData!;
    final totalSalaries = dashboard.paidCount + dashboard.pendingCount;

    if (totalSalaries == 0) {
      return const SizedBox.shrink();
    }

    final sections = <PieChartSectionData>[
      PieChartSectionData(
        color: Colors.green,
        value: dashboard.paidCount.toDouble(),
        title: dashboard.paidCount > 0 && totalSalaries > 0
            ? '${(dashboard.paidCount / totalSalaries * 100).toStringAsFixed(0)}%'
            : '',
        radius: 40,
        titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      PieChartSectionData(
        color: Colors.orange,
        value: dashboard.pendingCount.toDouble(),
        title: dashboard.pendingCount > 0 && totalSalaries > 0
            ? '${(dashboard.pendingCount / totalSalaries * 100).toStringAsFixed(0)}%'
            : '',
        radius: 40,
        titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Salary Status', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('Current month salary distribution',
            style: TextStyle(fontSize: 11, color: colorScheme.onSurface.withOpacity(0.4))),
          const SizedBox(height: 24),
          SizedBox(
            height: 160,
            child: PieChart(PieChartData(
              sections: sections,
              centerSpaceRadius: 30,
              sectionsSpace: 2,
            )),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _legendItem('Paid', dashboard.paidCount, Colors.green),
              const SizedBox(width: 24),
              _legendItem('Pending', dashboard.pendingCount, Colors.orange),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSalaryTrendChart(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final trend = provider.salaryTrend;
    if (trend.isEmpty) return const SizedBox.shrink();

    final maxVal = trend.reduce((a, b) => a > b ? a : b);
    final monthLabels = _monthLabels(trend.length);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Salary Trend', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('Monthly salary total over time',
            style: TextStyle(fontSize: 11, color: colorScheme.onSurface.withOpacity(0.4))),
          const SizedBox(height: 24),
          SizedBox(
            height: 160,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: trend.asMap().entries.map((entry) {
                final idx = entry.key;
                final val = entry.value;
                final barHeight = maxVal > 0 ? (val / maxVal) * 120.0 : 0.0;

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (val > 0)
                          Text(
                            '₹${(val / 1000).toStringAsFixed(0)}k',
                            style: TextStyle(fontSize: 8, color: colorScheme.onSurface.withOpacity(0.5)),
                          ),
                        const SizedBox(height: 4),
                        Container(
                          height: barHeight.clamp(0, 120),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withOpacity(0.5 + (barHeight / 120) * 0.5),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          monthLabels.length > idx ? monthLabels[idx] : '',
                          style: TextStyle(fontSize: 8, color: colorScheme.onSurface.withOpacity(0.5)),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendItem(String label, int count, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text('$label ($count)', style: const TextStyle(fontSize: 11)),
      ],
    );
  }

  List<String> _monthLabels(int count) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final now = DateTime.now();
    final labels = <String>[];
    for (var i = count - 1; i >= 0; i--) {
      final target = DateTime(now.year, now.month - i, 1);
      labels.add(months[target.month - 1]);
    }
    return labels;
  }
}
