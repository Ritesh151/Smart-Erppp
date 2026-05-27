import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smarterp/core/extensions/context_extensions.dart';
import 'package:smarterp/core/theme/theme_extensions.dart';
import 'package:smarterp/core/widgets/app_shell.dart';
import 'package:smarterp/core/widgets/app_card.dart';
import 'package:smarterp/core/widgets/metric_card.dart';
import 'package:smarterp/core/widgets/empty_state_widget.dart';
import 'package:smarterp/modules/payroll/providers/payroll_provider.dart';
import 'package:smarterp/modules/payroll/widgets/payroll_analytics_widget.dart';

class PayrollDashboardScreen extends StatefulWidget {
  const PayrollDashboardScreen({super.key});

  @override
  State<PayrollDashboardScreen> createState() => _PayrollDashboardScreenState();
}

class _PayrollDashboardScreenState extends State<PayrollDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PayrollProvider>().loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final theme = context.theme;

    return AppShell(
      child: Consumer<PayrollProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.dashboardData == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, provider),
                const SizedBox(height: 24),
                _buildMetricsGrid(context, provider),
                const SizedBox(height: 24),
                if (provider.dashboardData != null && provider.dashboardData!.totalPayable > 0) ...[
                  _buildChartsSection(context, provider),
                  const SizedBox(height: 24),
                ],
                _buildDepartmentDistribution(context, provider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, PayrollProvider provider) {
    final colorScheme = Theme.of(context).colorScheme;
    final dashboard = provider.dashboardData;
    final monthName = _monthName(dashboard?.month ?? DateTime.now().month);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Payroll Dashboard', style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold, color: colorScheme.onSurface,
            )),
            const SizedBox(height: 4),
            Text(
              'Overview of $monthName payroll and employee statistics.',
              style: TextStyle(fontSize: 13, color: colorScheme.onSurface.withOpacity(0.6)),
            ),
          ],
        ),
        if (dashboard != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: dashboard.attendanceRate >= 80 ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Attendance: ${dashboard.attendanceRate.toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w600,
                color: dashboard.attendanceRate >= 80 ? Colors.green : Colors.orange,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMetricsGrid(BuildContext context, PayrollProvider provider) {
    final colorScheme = context.colorScheme;
    final dashboard = provider.dashboardData;
    if (dashboard == null) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 700 ? 4 : (constraints.maxWidth > 500 ? 3 : 2);
        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.4,
          children: [
            MetricCard(
              title: 'Total Employees',
              value: '${dashboard.totalEmployees}',
              subtitle: '${dashboard.activeEmployees} active',
              icon: Icons.people,
              color: colorScheme.primary,
            ),
            MetricCard(
              title: 'Total Payable',
              value: '₹${dashboard.totalPayable.toStringAsFixed(0)}',
              subtitle: 'This month',
              icon: Icons.account_balance_wallet,
              color: Colors.blue,
            ),
            MetricCard(
              title: 'Total Paid',
              value: '₹${dashboard.totalPaid.toStringAsFixed(0)}',
              subtitle: '${dashboard.paidCount} salaries',
              icon: Icons.check_circle,
              color: Colors.green,
            ),
            MetricCard(
              title: 'Total Pending',
              value: '₹${dashboard.totalPending.toStringAsFixed(0)}',
              subtitle: '${dashboard.pendingCount} unpaid',
              icon: Icons.pending_actions,
              color: Colors.orange,
            ),
          ],
        );
      },
    );
  }

  Widget _buildChartsSection(BuildContext context, PayrollProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),
        PayrollAnalyticsWidget(provider: provider),
      ],
    );
  }

  Widget _buildDepartmentDistribution(BuildContext context, PayrollProvider provider) {
    final colorScheme = Theme.of(context).colorScheme;
    final distribution = provider.employeeDistribution;

    if (distribution.isEmpty) return const SizedBox.shrink();

    final maxCount = distribution.values.reduce((a, b) => a > b ? a : b);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Department Distribution', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('Employees grouped by department',
            style: TextStyle(fontSize: 11, color: colorScheme.onSurface.withOpacity(0.4))),
          const SizedBox(height: 20),
          ...distribution.entries.map((entry) {
            final barWidth = maxCount > 0 ? (entry.value / maxCount) : 0.0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(entry.key, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                      Text('${entry.value}', style: TextStyle(fontSize: 12, color: colorScheme.primary, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: SizedBox(
                      height: 8,
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

  String _monthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }
}
