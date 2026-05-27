import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smarterp/core/extensions/context_extensions.dart';
import 'package:smarterp/core/theme/theme_extensions.dart';
import 'package:smarterp/core/widgets/app_shell.dart';
import 'package:smarterp/core/widgets/app_card.dart';
import 'package:smarterp/core/widgets/empty_state_widget.dart';
import 'package:smarterp/core/widgets/metric_card.dart';
import 'package:smarterp/modules/transport/providers/transport_analytics_provider.dart';

class TransportAnalyticsScreen extends StatefulWidget {
  const TransportAnalyticsScreen({super.key});

  @override
  State<TransportAnalyticsScreen> createState() => _TransportAnalyticsScreenState();
}

class _TransportAnalyticsScreenState extends State<TransportAnalyticsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransportAnalyticsProvider>().loadAnalytics();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final theme = context.theme;

    return AppShell(
      child: Consumer<TransportAnalyticsProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Transport Analytics',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Overview of transport operations and statistics.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 24),
                if (provider.totalTransports == 0)
                  const EmptyStateWidget(
                    icon: Icons.analytics_outlined,
                    title: 'No Data Available',
                    message: 'Start creating transports to see analytics.',
                  )
                else ...[
                  _buildMetricsRow(context, provider),
                  const SizedBox(height: 24),
                  _buildChartsRow(context, provider),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMetricsRow(BuildContext context, TransportAnalyticsProvider provider) {
    final colorScheme = context.colorScheme;

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
              title: 'Total Transports',
              value: '${provider.totalTransports}',
              icon: Icons.local_shipping,
              color: colorScheme.primary,
            ),
            MetricCard(
              title: 'Completed',
              value: '${provider.completedTransports}',
              subtitle: '${(provider.completionRate * 100).toStringAsFixed(0)}% rate',
              icon: Icons.check_circle,
              color: Colors.green,
            ),
            MetricCard(
              title: 'Planned',
              value: '${provider.plannedTransports}',
              subtitle: 'Pending departure',
              icon: Icons.schedule,
              color: Colors.orange,
            ),
            MetricCard(
              title: 'Cancelled',
              value: '${provider.cancelledTransports}',
              subtitle: '${(provider.cancellationRate * 100).toStringAsFixed(0)}% rate',
              icon: Icons.cancel,
              color: Colors.red,
            ),
          ],
        );
      },
    );
  }

  Widget _buildChartsRow(BuildContext context, TransportAnalyticsProvider provider) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 800;
        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildStatusPieChart(context, provider)),
              const SizedBox(width: 24),
              Expanded(child: _buildWeeklyTrendChart(context, provider)),
            ],
          );
        }
        return Column(
          children: [
            _buildStatusPieChart(context, provider),
            const SizedBox(height: 24),
            _buildWeeklyTrendChart(context, provider),
          ],
        );
      },
    );
  }

  Widget _buildStatusPieChart(BuildContext context, TransportAnalyticsProvider provider) {
    final colorScheme = context.colorScheme;
    final distribution = provider.statusDistribution;
    final total = provider.totalTransports;

    if (total == 0) return const SizedBox.shrink();

    final sectionColors = [
      Colors.orange,
      Colors.blue,
      Colors.green,
      Colors.red,
    ];

    final sectionLabels = [
      'Planned',
      'On The Way',
      'Delivered',
      'Cancelled',
    ];

    final pieSections = distribution.entries.toList().asMap().entries.map((entry) {
      final idx = entry.key;
      final statusEntry = entry.value;
      final percent = total > 0 ? (statusEntry.value / total) * 100 : 0.0;

      return PieChartSectionData(
        color: sectionColors[idx % sectionColors.length],
        value: statusEntry.value.toDouble(),
        title: percent >= 5 ? '${percent.toStringAsFixed(0)}%' : '',
        radius: 40,
        titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Status Distribution',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Transport breakdown by current status',
            style: TextStyle(fontSize: 11, color: colorScheme.onSurface.withOpacity(0.4)),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 150,
            child: PieChart(
              PieChartData(
                sections: pieSections,
                centerSpaceRadius: 30,
                sectionsSpace: 2,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: sectionLabels.asMap().entries.map((entry) {
              final idx = entry.key;
              final label = entry.value;
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: sectionColors[idx],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text('$label (${distribution.values.toList()[idx]})', style: const TextStyle(fontSize: 11)),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyTrendChart(BuildContext context, TransportAnalyticsProvider provider) {
    final colorScheme = context.colorScheme;
    final weeklyData = provider.weeklyTrend;

    final maxVal = weeklyData.reduce((a, b) => a > b ? a : b);
    final dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Weekly Activity',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Transports created in the last 7 days',
            style: TextStyle(fontSize: 11, color: colorScheme.onSurface.withOpacity(0.4)),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 150,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: weeklyData.asMap().entries.map((entry) {
                final idx = entry.key;
                final val = entry.value;
                final barHeight = maxVal > 0 ? (val / maxVal) * 120.0 : 0.0;

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '$val',
                          style: TextStyle(
                            fontSize: 9,
                            color: colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          height: barHeight.clamp(0, 120),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withOpacity(0.6 + (barHeight / 120) * 0.4),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dayLabels[idx],
                          style: TextStyle(
                            fontSize: 9,
                            color: colorScheme.onSurface.withOpacity(0.5),
                          ),
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
}
