import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smarterp/core/extensions/context_extensions.dart';
import 'package:smarterp/core/theme/theme_extensions.dart';
import 'package:smarterp/core/widgets/app_shell.dart';
import 'package:smarterp/core/widgets/app_card.dart';
import 'package:smarterp/core/widgets/metric_card.dart';
import 'package:smarterp/core/widgets/empty_state_widget.dart';
import 'package:smarterp/modules/reports/providers/report_provider.dart';

class PurchaseReportScreen extends StatefulWidget {
  const PurchaseReportScreen({super.key});

  @override
  State<PurchaseReportScreen> createState() => _PurchaseReportScreenState();
}

class _PurchaseReportScreenState extends State<PurchaseReportScreen> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final theme = context.theme;

    return AppShell(
      child: Consumer<ReportProvider>(
        builder: (context, provider, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, provider),
                const SizedBox(height: 20),
                _buildControls(context, provider),
                const SizedBox(height: 24),
                if (provider.purchaseReport != null) ...[
                  _buildMetricsRow(context, provider),
                  const SizedBox(height: 24),
                  _buildTrendChart(context, provider),
                ] else ...[
                  if (provider.isGenerating)
                    const Center(child: Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(),
                    ))
                  else
                    _buildEmptyState(context, provider),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ReportProvider provider) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Purchase Report',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold, color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text('Track purchase volumes and supplier performance.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildControls(BuildContext context, ReportProvider provider) {
    return AppCard(
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              final prev = DateTime(provider.selectedYear, provider.selectedMonth - 1, 1);
              provider.selectMonth(prev.month, prev.year);
            },
          ),
          Text(
            '${_monthName(provider.selectedMonth)} ${provider.selectedYear}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              final next = DateTime(provider.selectedYear, provider.selectedMonth + 1, 1);
              provider.selectMonth(next.month, next.year);
            },
          ),
          const Spacer(),
          FilledButton.icon(
            onPressed: provider.isGenerating ? null : () => provider.generatePurchaseReport(),
            icon: provider.isGenerating
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.refresh, size: 18),
            label: const Text('Generate Report'),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsRow(BuildContext context, ReportProvider provider) {
    final report = provider.purchaseReport!;

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.4,
          children: [
            MetricCard(
              title: 'Total Purchases',
              value: '₹${report.totalPurchases.toStringAsFixed(0)}',
              icon: Icons.shopping_bag,
              color: Theme.of(context).colorScheme.primary,
            ),
            MetricCard(
              title: 'Purchase Orders',
              value: '${report.purchaseCount}',
              icon: Icons.receipt_long,
              color: Colors.blue,
            ),
            MetricCard(
              title: 'Avg Order Value',
              value: '₹${report.averageOrderValue.toStringAsFixed(0)}',
              icon: Icons.account_balance_wallet,
              color: Colors.green,
            ),
          ],
        );
      },
    );
  }

  Widget _buildTrendChart(BuildContext context, ReportProvider provider) {
    final colorScheme = Theme.of(context).colorScheme;
    final report = provider.purchaseReport!;
    final trend = report.monthlyTrend;
    final labels = report.monthlyLabels;

    if (trend.isEmpty) return const SizedBox.shrink();

    final maxVal = trend.reduce((a, b) => a > b ? a : b);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Monthly Purchase Trend', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('Purchase activity over the year',
            style: TextStyle(fontSize: 11, color: colorScheme.onSurface.withOpacity(0.4))),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxVal > 0 ? maxVal / 4 : 1,
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) => Text(
                        '₹${(value / 1000).toStringAsFixed(0)}k',
                        style: const TextStyle(fontSize: 9),
                      ),
                      reservedSize: 40,
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= labels.length) return const SizedBox();
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(labels[idx], style: const TextStyle(fontSize: 9)),
                        );
                      },
                      interval: 2,
                    ),
                  ),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                barGroups: trend.asMap().entries.map((e) =>
                  BarChartGroupData(
                    x: e.key,
                    barRods: [
                      BarChartRodData(
                        toY: e.value,
                        color: colorScheme.primary.withOpacity(0.7),
                        width: 12,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(4),
                          topRight: Radius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ReportProvider provider) {
    return EmptyStateWidget(
      icon: Icons.shopping_bag_outlined,
      title: 'No Purchase Report',
      message: 'Generate a purchase report for ${_monthName(provider.selectedMonth)} ${provider.selectedYear}',
      actionLabel: 'Generate Report',
      onAction: () => provider.generatePurchaseReport(),
    );
  }

  String _monthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }
}
