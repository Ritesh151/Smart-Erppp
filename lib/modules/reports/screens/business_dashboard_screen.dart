import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smarterp/core/extensions/context_extensions.dart';
import 'package:smarterp/core/widgets/app_card.dart';
import 'package:smarterp/core/widgets/app_shell.dart';
import 'package:smarterp/core/widgets/empty_state_widget.dart';
import 'package:smarterp/modules/reports/services/analytics_service.dart';
import 'package:smarterp/modules/reports/services/business_intelligence_service.dart';
import 'package:smarterp/modules/reports/widgets/analytics_cards.dart';

class BusinessDashboardScreen extends StatefulWidget {
  const BusinessDashboardScreen({super.key});

  @override
  State<BusinessDashboardScreen> createState() => _BusinessDashboardScreenState();
}

class _BusinessDashboardScreenState extends State<BusinessDashboardScreen> {
  CombinedKpi? _kpis;
  BusinessIntelligenceData? _biData;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final now = DateTime.now();
      final analytics = context.read<AnalyticsService>();
      final biService = context.read<BusinessIntelligenceService>();

      final results = await Future.wait([
        analytics.calculateAllKpis(now.month, now.year),
        biService.loadIntelligenceData(),
      ]);

      setState(() {
        _kpis = results[0] as CombinedKpi;
        _biData = results[1] as BusinessIntelligenceData;
      });
    } catch (e) {
      if (context.mounted) {
        context.showSnackBar('Failed to load dashboard: $e', isError: true);
      }
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      child: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 20),
              AnalyticsCards(
                sales: _kpis?.sales,
                expenses: _kpis?.expenses,
                inventory: _kpis?.inventory,
                payroll: _kpis?.payroll,
                profit: _kpis?.profit,
                isLoading: _isLoading,
              ),
              const SizedBox(height: 24),
              if (_biData != null) ...[
                _buildTrendChart(context, _biData!),
                const SizedBox(height: 24),
                _buildInsightsSection(context, _biData!),
                const SizedBox(height: 24),
                _buildTopProductsCustomers(context, _biData!),
                const SizedBox(height: 24),
                _buildRecentActivities(context, _biData!),
              ] else if (!_isLoading)
                EmptyStateWidget(
                  icon: Icons.analytics_outlined,
                  title: 'No Analytics Data',
                  message: 'Pull to refresh or wait for data to load.',
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Business Dashboard',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold, color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text('Key performance indicators, trends, and business insights.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildTrendChart(BuildContext context, BusinessIntelligenceData data) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (data.salesTrend.isEmpty) return const SizedBox.shrink();

    final maxY = [...data.salesTrend, ...data.profitTrend]
        .reduce((a, b) => a > b ? a : b);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Revenue & Profit Trend',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('Last 6 months',
            style: TextStyle(fontSize: 11, color: colorScheme.onSurface.withOpacity(0.4))),
          const SizedBox(height: 24),
          SizedBox(
            height: 220,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxY > 0 ? maxY / 4 : 1,
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
                        if (idx < 0 || idx >= data.trendLabels.length) return const SizedBox();
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(data.trendLabels[idx],
                            style: const TextStyle(fontSize: 9)),
                        );
                      },
                      interval: 1,
                    ),
                  ),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: data.salesTrend.asMap().entries
                        .map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
                    isCurved: true,
                    color: Colors.blue,
                    barWidth: 2.5,
                    dotData: FlDotData(show: true, getDotPainter: (_, __, ___, ____) =>
                      FlDotCirclePainter(radius: 3, color: Colors.blue, strokeWidth: 0)),
                    belowBarData: BarAreaData(show: true, color: Colors.blue.withOpacity(0.08)),
                  ),
                  LineChartBarData(
                    spots: data.profitTrend.asMap().entries
                        .map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
                    isCurved: true,
                    color: Colors.green,
                    barWidth: 2.5,
                    dotData: FlDotData(show: true, getDotPainter: (_, __, ___, ____) =>
                      FlDotCirclePainter(radius: 3, color: Colors.green, strokeWidth: 0)),
                    belowBarData: BarAreaData(show: true, color: Colors.green.withOpacity(0.08)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _legendItem('Revenue', Colors.blue),
              const SizedBox(width: 24),
              _legendItem('Profit', Colors.green),
            ],
          ),
        ],
      ),
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

  Widget _buildInsightsSection(BuildContext context, BusinessIntelligenceData data) {
    final theme = Theme.of(context);

    if (data.insights.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Insights', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ...data.insights.map((insight) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: AppCard(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (insight.isPositive ? Colors.green : Colors.red).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    insight.isPositive ? Icons.lightbulb : Icons.warning_amber,
                    size: 20,
                    color: insight.isPositive ? Colors.green : Colors.red,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(insight.title,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)
                      ),
                      const SizedBox(height: 2),
                      Text(insight.description,
                        style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withOpacity(0.5)),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(insight.category,
                    style: TextStyle(fontSize: 10, color: theme.colorScheme.primary),
                  ),
                ),
              ],
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildTopProductsCustomers(BuildContext context, BusinessIntelligenceData data) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (data.topProducts.isEmpty && data.topCustomers.isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (data.topProducts.isNotEmpty)
          Expanded(
            child: AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.shopping_bag, size: 16, color: colorScheme.primary),
                      const SizedBox(width: 6),
                      const Text('Top Products',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ..._buildProductItems(data.topProducts.take(5).toList()),
                ],
              ),
            ),
          ),
        if (data.topProducts.isNotEmpty && data.topCustomers.isNotEmpty)
          const SizedBox(width: 16),
        if (data.topCustomers.isNotEmpty)
          Expanded(
            child: AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.people, size: 16, color: colorScheme.primary),
                      const SizedBox(width: 6),
                      const Text('Top Customers',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ..._buildCustomerItems(data.topCustomers.take(5).toList()),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildRecentActivities(BuildContext context, BusinessIntelligenceData data) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (data.recentActivities.isEmpty) return const SizedBox.shrink();

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.history, size: 16, color: colorScheme.primary),
              const SizedBox(width: 6),
              const Text('Recent Activities',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          ...data.recentActivities.map((activity) {
            final isPositive = activity.type == 'sale';
            final icon = isPositive ? Icons.trending_up : Icons.money_off;
            final iconColor = isPositive ? Colors.green : Colors.red;

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: iconColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(icon, size: 14, color: iconColor),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(activity.description,
                          style: const TextStyle(fontSize: 12),
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                        ),
                        Text(_formatDate(activity.date),
                          style: TextStyle(fontSize: 10, color: colorScheme.onSurface.withOpacity(0.4)),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${isPositive ? '+' : '-'}₹${activity.amount.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: iconColor,
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

  List<Widget> _buildProductItems(List<TopProduct> products) {
    return List.generate(products.length, (i) {
      final product = products[i];
      return Padding(
        padding: EdgeInsets.only(bottom: i < products.length - 1 ? 10 : 0),
        child: Row(
          children: [
            Container(
              width: 20, height: 20,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.primaries[i].withOpacity(0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text('${i + 1}',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.primaries[i]),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(product.name,
                style: const TextStyle(fontSize: 12),
                maxLines: 1, overflow: TextOverflow.ellipsis,
              ),
            ),
            Text('₹${product.totalRevenue.toStringAsFixed(0)}',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11)),
          ],
        ),
      );
    });
  }

  List<Widget> _buildCustomerItems(List<TopCustomer> customers) {
    return List.generate(customers.length, (i) {
      final customer = customers[i];
      return Padding(
        padding: EdgeInsets.only(bottom: i < customers.length - 1 ? 10 : 0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 10,
              backgroundColor: Colors.primaries[i].withOpacity(0.15),
              child: Text('${i + 1}',
                style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.primaries[i]),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(customer.name,
                style: const TextStyle(fontSize: 12),
                maxLines: 1, overflow: TextOverflow.ellipsis,
              ),
            ),
            Text('₹${customer.totalSpent.toStringAsFixed(0)}',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11)),
          ],
        ),
      );
    });
  }

  String _formatDate(DateTime date) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
