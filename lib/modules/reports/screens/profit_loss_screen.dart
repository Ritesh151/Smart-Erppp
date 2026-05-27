import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:smarterp/core/extensions/context_extensions.dart';
import 'package:smarterp/core/theme/theme_extensions.dart';
import 'package:smarterp/core/widgets/app_shell.dart';
import 'package:smarterp/core/widgets/app_card.dart';
import 'package:smarterp/core/widgets/metric_card.dart';
import 'package:smarterp/core/widgets/empty_state_widget.dart';
import 'package:smarterp/modules/reports/providers/report_provider.dart';
import 'package:smarterp/modules/reports/services/profit_loss_service.dart';

class ProfitLossScreen extends StatefulWidget {
  const ProfitLossScreen({super.key});

  @override
  State<ProfitLossScreen> createState() => _ProfitLossScreenState();
}

class _ProfitLossScreenState extends State<ProfitLossScreen> {
  ProfitLossResult? _result;
  bool _isLoading = false;

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
                _buildHeader(context),
                const SizedBox(height: 20),
                _buildControls(context, provider),
                const SizedBox(height: 24),
                if (_result != null) ...[
                  _buildMetricsRow(context, _result!),
                  const SizedBox(height: 24),
                  _buildBreakdownCard(context, _result!),
                  const SizedBox(height: 24),
                  _buildRevenueVsExpenseChart(context),
                ] else ...[
                  if (_isLoading)
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

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Profit & Loss',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold, color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text('Revenue, costs, and profitability analysis.',
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
            onPressed: () => _loadData(provider, provider.selectedMonth - 1, provider.selectedYear),
          ),
          Text(
            '${_monthName(provider.selectedMonth)} ${provider.selectedYear}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () => _loadData(provider, provider.selectedMonth + 1, provider.selectedYear),
          ),
          const Spacer(),
          FilledButton.icon(
            onPressed: _isLoading ? null : () => _loadData(provider, provider.selectedMonth, provider.selectedYear),
            icon: _isLoading
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.refresh, size: 18),
            label: const Text('Calculate'),
          ),
        ],
      ),
    );
  }

  Future<void> _loadData(ReportProvider provider, int month, int year) async {
    if (month < 1) { month = 12; year--; }
    if (month > 12) { month = 1; year++; }
    provider.selectMonth(month, year);

    setState(() => _isLoading = true);
    try {
      final plService = ProfitLossService(
        financeService: context.read(),
        payrollService: context.read(),
      );
      _result = await plService.calculateProfitLoss(month, year);
    } catch (e) {
      if (context.mounted) {
        context.showSnackBar('Failed to calculate P&L: $e', isError: true);
      }
    }
    setState(() => _isLoading = false);
  }

  Widget _buildMetricsRow(BuildContext context, ProfitLossResult result) {
    final color = result.isProfitable ? Colors.green : Colors.red;

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
          children: List.generate(4, (i) =>
            MetricCard(
              title: i == 0 ? 'Total Revenue' : i == 1 ? 'Total Costs' : i == 2 ? (result.isProfitable ? 'Net Profit' : 'Net Loss') : 'Profit Margin',
              value: i == 0 ? '₹${result.totalRevenue.toStringAsFixed(0)}' : i == 1 ? '₹${result.totalCosts.toStringAsFixed(0)}' : i == 2 ? '₹${result.netProfit.toStringAsFixed(0)}' : '${result.profitMargin.toStringAsFixed(1)}%',
              subtitle: i == 0 ? null : i == 1 ? 'Purchases + Expenses' : i == 3 && result.profitGrowth != 0 ? '${result.profitGrowth > 0 ? '+' : ''}${result.profitGrowth.toStringAsFixed(1)}% vs last' : null,
              icon: i == 0 ? Icons.trending_up : i == 1 ? Icons.money_off : i == 2 ? (result.isProfitable ? Icons.check_circle : Icons.error) : Icons.pie_chart,
              color: i <= 1 ? (i == 0 ? Colors.blue : Colors.red) : color,
            ).animate().fadeIn(delay: (i * 80).ms, duration: 300.ms).slideY(begin: 0.1, end: 0),
          ),
        );
      },
    );
  }

  Widget _buildBreakdownCard(BuildContext context, ProfitLossResult result) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('P&L Breakdown', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _breakdownRow('Total Revenue', result.totalRevenue, Colors.blue, Icons.trending_up),
          const Divider(height: 24),
          _breakdownRow('Cost of Goods Sold', result.totalPurchases, Colors.orange, Icons.shopping_cart),
          const Divider(height: 24),
          _breakdownRow('Gross Profit', result.grossProfit,
            result.grossProfit >= 0 ? Colors.green : Colors.red, Icons.account_balance),
          const Divider(height: 24),
          _breakdownRow('Operating Expenses', result.totalExpenses, Colors.red, Icons.money_off),
          if (result.totalPayrollCost > 0) ...[
            const Divider(height: 24),
            _breakdownRow('Payroll Costs', result.totalPayrollCost, Colors.purple, Icons.people),
          ],
          const Divider(height: 24, thickness: 2),
          _breakdownRow('Net Profit / Loss', result.netProfit,
            result.isProfitable ? Colors.green : Colors.red, Icons.account_balance,
            bold: true, large: true),
        ],
      ),
    );
  }

  Widget _breakdownRow(String label, double amount, Color color, IconData icon,
      {bool bold = false, bool large = false}) {
    return Row(
      children: [
        Icon(icon, size: large ? 22 : 18, color: color),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label,
            style: TextStyle(
              fontSize: large ? 15 : 13,
              fontWeight: bold ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ),
        Text(
          '${amount >= 0 ? '' : '-'}₹${amount.abs().toStringAsFixed(0)}',
          style: TextStyle(
            fontSize: large ? 16 : 13,
            fontWeight: bold ? FontWeight.bold : FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildRevenueVsExpenseChart(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return FutureBuilder<RevenueVsExpense>(
      future: ProfitLossService(
        financeService: context.read(),
        payrollService: context.read(),
      ).getRevenueVsExpenseTrend(6),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.revenue.isEmpty) {
          return const SizedBox.shrink();
        }

        final data = snapshot.data!;
        final maxVal = [...data.revenue, ...data.expenses]
            .reduce((a, b) => a > b ? a : b);

        return AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Revenue vs Expenses', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('6-month comparison',
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
                            style: const TextStyle(fontSize: 8),
                          ),
                          reservedSize: 36,
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final idx = value.toInt();
                            if (idx < 0 || idx >= data.labels.length) return const SizedBox();
                            return Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(data.labels[idx], style: const TextStyle(fontSize: 9)),
                            );
                          },
                          interval: 1,
                        ),
                      ),
                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: List.generate(data.revenue.length, (i) =>
                      BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(
                            toY: data.revenue[i],
                            color: Colors.blue,
                            width: 8,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(3), topRight: Radius.circular(3),
                            ),
                          ),
                          BarChartRodData(
                            toY: data.expenses[i],
                            color: Colors.red,
                            width: 8,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(3), topRight: Radius.circular(3),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _legendItem('Revenue', Colors.blue),
                  const SizedBox(width: 24),
                  _legendItem('Expenses', Colors.red),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _legendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, ReportProvider provider) {
    return EmptyStateWidget(
      icon: Icons.account_balance_outlined,
      title: 'No P&L Data',
      message: 'Calculate P&L for ${_monthName(provider.selectedMonth)} ${provider.selectedYear}',
      actionLabel: 'Calculate Now',
      onAction: () => _loadData(provider, provider.selectedMonth, provider.selectedYear),
    );
  }

  String _monthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }
}
