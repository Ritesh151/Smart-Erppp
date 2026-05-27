import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smarterp/core/extensions/context_extensions.dart';
import 'package:smarterp/core/models/payroll_report_model.dart';
import 'package:smarterp/core/widgets/app_card.dart';
import 'package:smarterp/core/widgets/app_shell.dart';
import 'package:smarterp/core/widgets/empty_state_widget.dart';
import 'package:smarterp/core/widgets/metric_card.dart';
import 'package:smarterp/modules/payroll/services/payroll_service.dart';
import 'package:smarterp/modules/reports/repositories/payroll_report_repository.dart';
import 'package:smarterp/modules/reports/services/report_service.dart';
import 'package:smarterp/modules/reports/widgets/payroll_analytics_widget.dart';

class PayrollReportScreen extends StatefulWidget {
  const PayrollReportScreen({super.key});

  @override
  State<PayrollReportScreen> createState() => _PayrollReportScreenState();
}

class _PayrollReportScreenState extends State<PayrollReportScreen> {
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;
  bool _isLoading = false;
  PayrollReportModel? _report;
  PayrollDashboardData? _dashboard;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 20),
            _buildControls(context),
            const SizedBox(height: 24),
            if (_isLoading)
              const Center(child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(),
              ))
            else if (_report != null)
              _buildReportContent(context, _report!)
            else
              EmptyStateWidget(
                icon: Icons.payments_outlined,
                title: 'No Payroll Report',
                message: 'Generate a payroll report for ${_monthName(_selectedMonth)} $_selectedYear',
                actionLabel: 'Generate Report',
                onAction: () => _generateReport(context),
              ),
          ],
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
        Text('Payroll Report',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold, color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text('Employee salary, payments, and distribution analysis.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildControls(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => _changeMonth(-1),
          ),
          Text(
            '${_monthName(_selectedMonth)} $_selectedYear',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () => _changeMonth(1),
          ),
          const Spacer(),
          FilledButton.icon(
            onPressed: _isLoading ? null : () => _generateReport(context),
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Generate'),
          ),
        ],
      ),
    );
  }

  void _changeMonth(int delta) {
    setState(() {
      _selectedMonth += delta;
      if (_selectedMonth < 1) { _selectedMonth = 12; _selectedYear--; }
      if (_selectedMonth > 12) { _selectedMonth = 1; _selectedYear++; }
    });
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final repo = context.read<PayrollReportRepository>();
      final report = await repo.getPayrollReportByMonth(_selectedMonth, _selectedYear);
      final payrollService = context.read<PayrollService>();
      final dashboard = await payrollService.getDashboardData();
      setState(() {
        _report = report;
        _dashboard = dashboard;
      });
    } catch (e) {
      if (context.mounted) {
        context.showSnackBar('Failed to load report: $e', isError: true);
      }
    }
    setState(() => _isLoading = false);
  }

  Future<void> _generateReport(BuildContext context) async {
    setState(() => _isLoading = true);
    try {
      final reportService = context.read<ReportService>();
      await reportService.generatePayrollReport(
        month: _selectedMonth,
        year: _selectedYear,
      );
      await _loadData();
      if (context.mounted) {
        context.showSnackBar('Payroll report generated successfully');
      }
    } catch (e) {
      if (context.mounted) {
        context.showSnackBar('Failed to generate report: $e', isError: true);
      }
    }
    setState(() => _isLoading = false);
  }

  Widget _buildReportContent(BuildContext context, PayrollReportModel report) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMetricsGrid(context, report),
        const SizedBox(height: 24),
        PayrollAnalyticsWidget(payrollReport: report, dashboard: _dashboard),
        if (report.topEarners.isNotEmpty) ...[
          const SizedBox(height: 24),
          _buildTopEarnersCard(context, report),
        ],
      ],
    );
  }

  Widget _buildMetricsGrid(BuildContext context, PayrollReportModel report) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 800 ? 5 : constraints.maxWidth > 500 ? 3 : 2;
        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.4,
          children: [
            MetricCard(
              title: 'Employees',
              value: '${report.totalEmployees}',
              subtitle: '${report.activeEmployees} active',
              icon: Icons.people,
              color: Colors.blue,
            ),
            MetricCard(
              title: 'Total Payable',
              value: '₹${report.totalSalaryPayable.toStringAsFixed(0)}',
              icon: Icons.account_balance_wallet,
              color: Colors.orange,
            ),
            MetricCard(
              title: 'Total Paid',
              value: '₹${report.totalSalaryPaid.toStringAsFixed(0)}',
              subtitle: '${report.paidCount} employees',
              icon: Icons.check_circle,
              color: Colors.green,
            ),
            MetricCard(
              title: 'Total Pending',
              value: '₹${report.totalSalaryPending.toStringAsFixed(0)}',
              subtitle: '${report.pendingCount} employees',
              icon: Icons.pending,
              color: Colors.red,
            ),
            MetricCard(
              title: 'Payment Rate',
              value: '${report.paymentRate.toStringAsFixed(1)}%',
              icon: Icons.trending_up,
              color: report.paymentRate > 80 ? Colors.green : Colors.orange,
            ),
          ],
        );
      },
    );
  }

  Widget _buildTopEarnersCard(BuildContext context, PayrollReportModel report) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Top Earners', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...report.topEarners.asMap().entries.map((entry) {
            final idx = entry.key;
            final earner = entry.value;
            return Padding(
              padding: EdgeInsets.only(bottom: idx < report.topEarners.length - 1 ? 12 : 0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.primaries[idx % Colors.primaries.length].withOpacity(0.2),
                    child: Text('${idx + 1}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Colors.primaries[idx % Colors.primaries.length],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${earner['name'] ?? 'Unknown'}',
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                        if (earner['department'] != null)
                          Text('${earner['department']}',
                            style: TextStyle(fontSize: 11, color: colorScheme.onSurface.withOpacity(0.5)),
                          ),
                      ],
                    ),
                  ),
                  Text('₹${(earner['salary'] as num).toStringAsFixed(0)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
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
