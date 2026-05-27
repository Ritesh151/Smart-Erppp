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
import 'package:smarterp/modules/reports/widgets/stock_analytics_widget.dart';

class StockReportScreen extends StatefulWidget {
  const StockReportScreen({super.key});

  @override
  State<StockReportScreen> createState() => _StockReportScreenState();
}

class _StockReportScreenState extends State<StockReportScreen> {
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
                if (provider.stockReport != null) ...[
                  _buildMetricsRow(context, provider),
                  const SizedBox(height: 24),
                  StockAnalyticsWidget(report: provider.stockReport!),
                  const SizedBox(height: 24),
                  _buildLowStockSection(context, provider),
                  const SizedBox(height: 24),
                  _buildTopMovingSection(context, provider),
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
        Text('Stock Report',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold, color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text('Monitor inventory levels and product movement.',
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
          Text(
            '${_monthName(provider.selectedMonth)} ${provider.selectedYear}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const Spacer(),
          FilledButton.icon(
            onPressed: provider.isGenerating ? null : () => provider.generateStockReport(),
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
    final report = provider.stockReport!;

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
              title: 'Inventory Value',
              value: '₹${report.totalInventoryValue.toStringAsFixed(0)}',
              icon: Icons.account_balance,
              color: Theme.of(context).colorScheme.primary,
            ),
            MetricCard(
              title: 'Total Products',
              value: '${report.totalProducts}',
              icon: Icons.inventory_2,
              color: Colors.blue,
            ),
            MetricCard(
              title: 'Low Stock',
              value: '${report.lowStockCount}',
              icon: Icons.warning_amber,
              color: Colors.orange,
            ),
            MetricCard(
              title: 'Out of Stock',
              value: '${report.outOfStockCount}',
              icon: Icons.error_outline,
              color: Colors.red,
            ),
          ],
        );
      },
    );
  }

  Widget _buildLowStockSection(BuildContext context, ReportProvider provider) {
    final report = provider.stockReport!;
    final lowStock = report.lowStockProducts;

    if (lowStock.isEmpty) return const SizedBox.shrink();

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber, color: Colors.orange, size: 18),
              const SizedBox(width: 8),
              Text('Low Stock Products', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.orange.shade800)),
            ],
          ),
          const SizedBox(height: 16),
          ...lowStock.take(10).map((p) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.inventory, size: 16, color: Colors.orange),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p['name'] as String? ?? '',
                        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                      Text('Stock: ${p['stock']} | Min: ${p['minLevel']}',
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                    ],
                  ),
                ),
                Text('₹${(p['value'] as num).toStringAsFixed(0)}',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.orange.shade700)),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildTopMovingSection(BuildContext context, ReportProvider provider) {
    final report = provider.stockReport!;
    final topMoving = report.topMovingProducts;

    if (topMoving.isEmpty) return const SizedBox.shrink();

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Top Products by Value', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ...topMoving.take(10).map((p) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(Icons.inventory_2, size: 16, color: Theme.of(context).colorScheme.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p['name'] as String? ?? '',
                        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                      Text('${p['stock']} units | ${p['category']}',
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                    ],
                  ),
                ),
                Text('₹${(p['value'] as num).toStringAsFixed(0)}',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Theme.of(context).colorScheme.primary)),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ReportProvider provider) {
    return EmptyStateWidget(
      icon: Icons.inventory_2_outlined,
      title: 'No Stock Report',
      message: 'Generate a stock report for ${_monthName(provider.selectedMonth)} ${provider.selectedYear}',
      actionLabel: 'Generate Report',
      onAction: () => provider.generateStockReport(),
    );
  }

  String _monthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }
}
