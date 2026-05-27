import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:smarterp/core/models/payroll_report_model.dart';
import 'package:smarterp/core/widgets/app_card.dart';
import 'package:smarterp/modules/payroll/services/payroll_service.dart';

class PayrollAnalyticsWidget extends StatelessWidget {
  final PayrollReportModel payrollReport;
  final PayrollDashboardData? dashboard;

  const PayrollAnalyticsWidget({
    super.key,
    required this.payrollReport,
    this.dashboard,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (payrollReport.salaryTrend.isNotEmpty) ...[
          _buildSalaryTrendChart(context),
          const SizedBox(height: 24),
        ],
        if (payrollReport.departmentDistribution.isNotEmpty) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildDepartmentDistributionChart(context),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildPaymentStatusChart(context),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
        _buildSummaryCard(context),
      ],
    );
  }

  Widget _buildSalaryTrendChart(BuildContext context) {
    final trend = payrollReport.salaryTrend;
    final labels = payrollReport.trendLabels;

    if (trend.isEmpty) return const SizedBox.shrink();

    final maxY = trend.reduce((a, b) => a > b ? a : b);
    final spots = trend.asMap().entries.map((e) =>
      FlSpot(e.key.toDouble(), e.value)).toList();

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Salary Trend (12 months)',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
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
                        if (idx < 0 || idx >= labels.length) return const SizedBox();
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(labels[idx], style: const TextStyle(fontSize: 8)),
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
                    spots: spots,
                    isCurved: true,
                    color: Colors.blue,
                    barWidth: 2.5,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) =>
                        FlDotCirclePainter(
                          radius: 3,
                          color: Colors.blue,
                          strokeWidth: 0,
                        ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.blue.withOpacity(0.1),
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

  Widget _buildDepartmentDistributionChart(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final distribution = payrollReport.departmentDistribution;

    if (distribution.isEmpty) return const SizedBox.shrink();

    final entries = distribution.entries.toList();
    final totalEmployees = payrollReport.totalEmployees;

    final chartColors = [
      Colors.blue, Colors.green, Colors.orange, Colors.purple,
      Colors.teal, Colors.pink, Colors.indigo, Colors.amber,
    ];

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Department Distribution',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('${entries.length} departments',
            style: TextStyle(fontSize: 11, color: colorScheme.onSurface.withOpacity(0.4))),
          const SizedBox(height: 16),
          SizedBox(
            height: 160,
            child: PieChart(
              PieChartData(
                sections: entries.asMap().entries.map((e) {
                  final i = e.key;
                  final entry = e.value;
                  final percentage = totalEmployees > 0
                      ? (entry.value / totalEmployees) * 100 : 0.0;
                  return PieChartSectionData(
                    value: entry.value.toDouble(),
                    color: chartColors[i % chartColors.length],
                    radius: 40,
                    title: '${percentage.toStringAsFixed(0)}%',
                    titleStyle: const TextStyle(
                      fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white,
                    ),
                  );
                }).toList(),
                sectionsSpace: 1,
                centerSpaceRadius: 28,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: entries.asMap().entries.map((e) {
              final i = e.key;
              final entry = e.value;
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8, height: 8,
                    decoration: BoxDecoration(
                      color: chartColors[i % chartColors.length],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text('${entry.key} (${entry.value})',
                    style: const TextStyle(fontSize: 10)),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentStatusChart(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final report = payrollReport;

    final paidEmployees = report.paidCount;
    final pendingEmployees = report.pendingCount;
    final partiallyPaid = report.partiallyPaidCount;
    final total = paidEmployees + pendingEmployees + partiallyPaid;

    if (total == 0) return const SizedBox.shrink();

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Payment Status',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('${report.pendingCount} pending payments',
            style: TextStyle(fontSize: 11, color: colorScheme.onSurface.withOpacity(0.4))),
          const SizedBox(height: 16),
          SizedBox(
            height: 160,
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(
                    value: paidEmployees.toDouble(),
                    color: Colors.green,
                    radius: 40,
                    title: total > 0
                        ? '${(paidEmployees / total * 100).toStringAsFixed(0)}%'
                        : '0%',
                    titleStyle: const TextStyle(
                      fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white,
                    ),
                  ),
                  if (pendingEmployees > 0)
                    PieChartSectionData(
                      value: pendingEmployees.toDouble(),
                      color: Colors.red,
                      radius: 40,
                      title: '${(pendingEmployees / total * 100).toStringAsFixed(0)}%',
                      titleStyle: const TextStyle(
                        fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white,
                      ),
                    ),
                  if (partiallyPaid > 0)
                    PieChartSectionData(
                      value: partiallyPaid.toDouble(),
                      color: Colors.orange,
                      radius: 40,
                      title: '${(partiallyPaid / total * 100).toStringAsFixed(0)}%',
                      titleStyle: const TextStyle(
                        fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white,
                      ),
                    ),
                ],
                sectionsSpace: 1,
                centerSpaceRadius: 28,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _statusLegend('Paid', paidEmployees, Colors.green),
              const SizedBox(height: 4),
              _statusLegend('Pending', pendingEmployees, Colors.red),
              if (partiallyPaid > 0) ...[
                const SizedBox(height: 4),
                _statusLegend('Partial', partiallyPaid, Colors.orange),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusLegend(String label, int count, Color color) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text('$label: $count', style: const TextStyle(fontSize: 11)),
      ],
    );
  }

  Widget _buildSummaryCard(BuildContext context) {
    final report = payrollReport;
    final theme = Theme.of(context);

    return AppCard(
      child: Row(
        children: [
          Expanded(
            child: _summaryItem(
              'Avg. Salary',
              '₹${report.averageSalary.toStringAsFixed(0)}',
              Icons.people,
              theme,
            ),
          ),
          Container(width: 1, height: 40, color: theme.dividerColor),
          Expanded(
            child: _summaryItem(
              'Attendance',
              '${report.attendanceRate.toStringAsFixed(1)}%',
              Icons.calendar_today,
              theme,
            ),
          ),
          Container(width: 1, height: 40, color: theme.dividerColor),
          Expanded(
            child: _summaryItem(
              'Pay Rate',
              '${report.paymentRate.toStringAsFixed(1)}%',
              Icons.check_circle,
              theme,
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryItem(String label, String value, IconData icon, ThemeData theme) {
    return Column(
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.primary),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        Text(label, style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurface.withOpacity(0.5))),
      ],
    );
  }
}
