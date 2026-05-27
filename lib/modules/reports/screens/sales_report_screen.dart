import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smarterp/core/extensions/context_extensions.dart';
import 'package:smarterp/core/theme/theme_extensions.dart';
import 'package:smarterp/core/widgets/app_shell.dart';
import 'package:smarterp/core/widgets/app_card.dart';
import 'package:smarterp/core/widgets/metric_card.dart';
import 'package:smarterp/core/widgets/empty_state_widget.dart';
import 'package:smarterp/core/models/sales_report_model.dart';
import 'package:smarterp/modules/reports/providers/report_provider.dart';

class SalesReportScreen extends StatefulWidget {
  const SalesReportScreen({super.key});

  @override
  State<SalesReportScreen> createState() => _SalesReportScreenState();
}

class _SalesReportScreenState extends State<SalesReportScreen> {
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
                if (provider.salesReport != null) ...[
                  _buildMetricsRow(context, provider),
                  const SizedBox(height: 24),
                  _buildChartsSection(context, provider),
                  const SizedBox(height: 24),
                  _buildTopProducts(context, provider),
                  const SizedBox(height: 24),
                  _buildTopCustomers(context, provider),
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
            Text('Sales Report',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold, color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text('Analyze sales performance and revenue trends.',
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
    final colorScheme = Theme.of(context).colorScheme;

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
            onPressed: provider.isGenerating ? null : () => provider.generateSalesReport(),
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
    final report = provider.salesReport!;

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
              title: 'Total Sales',
              value: '₹${report.totalSales.toStringAsFixed(0)}',
              icon: Icons.trending_up,
              color: Theme.of(context).colorScheme.primary,
            ),
            MetricCard(
              title: 'Orders',
              value: '${report.salesCount}',
              icon: Icons.shopping_cart,
              color: Colors.blue,
            ),
            MetricCard(
              title: 'Avg Order Value',
              value: '₹${report.averageOrderValue.toStringAsFixed(0)}',
              icon: Icons.account_balance_wallet,
              color: Colors.green,
            ),
            MetricCard(
              title: 'Per Day',
              value: '₹${report.salesPerDay.toStringAsFixed(0)}',
              icon: Icons.calendar_today,
              color: Colors.orange,
            ),
          ],
        );
      },
    );
  }

  Widget _buildChartsSection(BuildContext context, ReportProvider provider) {
    final colorScheme = Theme.of(context).colorScheme;
    final report = provider.salesReport!;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 800;
        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildSalesTrendChart(context, report)),
              const SizedBox(width: 24),
              Expanded(child: _buildTopProductsChart(context, report)),
            ],
          );
        }
        return Column(
          children: [
            _buildSalesTrendChart(context, report),
            const SizedBox(height: 24),
            _buildTopProductsChart(context, report),
          ],
        );
      },
    );
  }

  Widget _buildSalesTrendChart(BuildContext context, SalesReportModel report) {
    final colorScheme = Theme.of(context).colorScheme;
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
          Text('Sales performance over the year',
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
                    color: colorScheme.primary,
                    barWidth: 3,
                    dotData: FlDotData(show: true),
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

  Widget _buildTopProductsChart(BuildContext context, SalesReportModel report) {
    final colorScheme = Theme.of(context).colorScheme;
    final products = report.topProducts;

    if (products.isEmpty) return const SizedBox.shrink();

    final maxVal = products.map((p) => (p['total'] as num).toDouble()).reduce(
      (a, b) => a > b ? a : b,
    );

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Top Products', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('Highest revenue generating products',
            style: TextStyle(fontSize: 11, color: colorScheme.onSurface.withOpacity(0.4))),
          const SizedBox(height: 16),
          ...products.take(5).map((p) {
            final total = (p['total'] as num).toDouble();
            final barWidth = maxVal > 0 ? (total / maxVal) : 0.0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(p['name'] as String,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text('₹${total.toStringAsFixed(0)}',
                        style: TextStyle(fontSize: 11, color: colorScheme.primary, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: SizedBox(
                      height: 6,
                      child: LinearProgressIndicator(
                        value: barWidth.clamp(0.0, 1.0),
                        backgroundColor: colorScheme.surfaceContainerHighest,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTopProducts(BuildContext context, ReportProvider provider) {
    final report = provider.salesReport!;
    if (report.topProducts.isEmpty) return const SizedBox.shrink();

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Top Products', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ...report.topProducts.map((p) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.inventory_2, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(p['name'] as String, style: const TextStyle(fontWeight: FontWeight.w500))),
                Text('₹${(p['total'] as num).toStringAsFixed(0)}',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildTopCustomers(BuildContext context, ReportProvider provider) {
    final report = provider.salesReport!;
    if (report.topCustomers.isEmpty) return const SizedBox.shrink();

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Top Customers', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ...report.topCustomers.map((c) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.blue.withOpacity(0.1),
                  child: Text(
                    (c['name'] as String).isNotEmpty ? (c['name'] as String)[0].toUpperCase() : '?',
                    style: const TextStyle(fontSize: 12, color: Colors.blue),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(c['name'] as String, style: const TextStyle(fontWeight: FontWeight.w500))),
                Text('₹${(c['total'] as num).toStringAsFixed(0)}',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade600)),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ReportProvider provider) {
    return EmptyStateWidget(
      icon: Icons.assessment_outlined,
      title: 'No Sales Report',
      message: 'Generate a sales report for ${_monthName(provider.selectedMonth)} ${provider.selectedYear}',
      actionLabel: 'Generate Report',
      onAction: () => provider.generateSalesReport(),
    );
  }

  String _monthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }
}
