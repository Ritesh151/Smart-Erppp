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
import 'package:smarterp/modules/reports/widgets/expense_analytics_widget.dart';

class ExpenseReportScreen extends StatefulWidget {
  const ExpenseReportScreen({super.key});

  @override
  State<ExpenseReportScreen> createState() => _ExpenseReportScreenState();
}

class _ExpenseReportScreenState extends State<ExpenseReportScreen> {
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
                if (provider.expenseReport != null) ...[
                  _buildMetricsRow(context, provider),
                  const SizedBox(height: 24),
                  ExpenseAnalyticsWidget(report: provider.expenseReport!),
                  const SizedBox(height: 24),
                  _buildMonthlyTrendChart(context, provider),
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Expense Report',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold, color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text('Track and analyze business expenses by category.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface.withOpacity(0.6),
          ),
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
            onPressed: provider.isGenerating ? null : () => provider.generateExpenseReport(),
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
    final report = provider.expenseReport!;

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 600 ? 4 : 2;
        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.4,
          children: [
            MetricCard(
              title: 'Total Expenses',
              value: '₹${report.totalExpenses.toStringAsFixed(0)}',
              icon: Icons.money_off,
              color: Colors.red,
            ),
            MetricCard(
              title: 'Expense Count',
              value: '${report.expenseCount}',
              icon: Icons.receipt_long,
              color: Colors.orange,
            ),
            MetricCard(
              title: 'Avg Per Expense',
              value: '₹${report.averageExpense.toStringAsFixed(0)}',
              icon: Icons.account_balance_wallet,
              color: Colors.blue,
            ),
            MetricCard(
              title: 'Top Category',
              value: report.highestCategory.isNotEmpty ? report.highestCategory : '-',
              subtitle: report.highestCategoryAmount > 0
                  ? '₹${report.highestCategoryAmount.toStringAsFixed(0)}'
                  : null,
              icon: Icons.category,
              color: Colors.purple,
            ),
          ],
        );
      },
    );
  }

  Widget _buildMonthlyTrendChart(BuildContext context, ReportProvider provider) {
    final colorScheme = Theme.of(context).colorScheme;
    final report = provider.expenseReport!;
    final trend = report.monthlyTrend;
    final labels = report.monthlyLabels;

    if (trend.isEmpty) return const SizedBox.shrink();

    final maxVal = trend.reduce((a, b) => a > b ? a : b);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Monthly Trend', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('Expense trend over the year',
            style: TextStyle(fontSize: 11, color: colorScheme.onSurface.withOpacity(0.4))),
          const SizedBox(height: 24),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
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
                lineBarsData: [
                  LineChartBarData(
                    spots: trend.asMap().entries.map((e) =>
                      FlSpot(e.key.toDouble(), e.value)
                    ).toList(),
                    isCurved: true,
                    color: Colors.red,
                    barWidth: 3,
                    dotData: FlDotData(show: true),
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

  Widget _buildEmptyState(BuildContext context, ReportProvider provider) {
    return EmptyStateWidget(
      icon: Icons.money_off_outlined,
      title: 'No Expense Report',
      message: 'Generate an expense report for ${_monthName(provider.selectedMonth)} ${provider.selectedYear}',
      actionLabel: 'Generate Report',
      onAction: () => provider.generateExpenseReport(),
    );
  }

  String _monthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }
}
