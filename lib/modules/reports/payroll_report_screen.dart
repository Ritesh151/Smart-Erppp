// lib/Pages/Reports/payroll_report_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:siddhivinayak_enterprise/core/models/salary_model.dart';
import 'package:siddhivinayak_enterprise/core/utils/currency_formatter.dart';
import 'package:siddhivinayak_enterprise/core/utils/date_helper.dart';
import 'package:siddhivinayak_enterprise/core/widgets/app_scaffold.dart';
import 'package:siddhivinayak_enterprise/core/widgets/loading_widget.dart';
import 'package:siddhivinayak_enterprise/modules/payroll/providers/employee_provider.dart';
import 'package:siddhivinayak_enterprise/modules/payroll/providers/salary_provider.dart';

class PayrollReportScreen extends StatefulWidget {
  const PayrollReportScreen({super.key});

  @override
  State<PayrollReportScreen> createState() => _PayrollReportScreenState();
}

class _PayrollReportScreenState extends State<PayrollReportScreen> {
  DateTime _selectedMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EmployeeProvider>().loadEmployees();
      context.read<SalaryProvider>().loadSalariesForMonth(
            _selectedMonth.month,
            _selectedMonth.year,
          );
    });
  }

  void _prevMonth() {
    setState(() {
      _selectedMonth = DateTime(
          _selectedMonth.year, _selectedMonth.month - 1);
    });
    _reloadData();
  }

  void _nextMonth() {
    final next = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
    if (next.isBefore(DateTime.now().add(const Duration(days: 32)))) {
      setState(() => _selectedMonth = next);
      _reloadData();
    }
  }

  void _reloadData() {
    context.read<SalaryProvider>().loadSalariesForMonth(
          _selectedMonth.month,
          _selectedMonth.year,
        );
  }

  @override
  Widget build(BuildContext context) {
    final salaryProvider = context.watch<SalaryProvider>();
    final employeeProvider = context.watch<EmployeeProvider>();
    final isLoading = salaryProvider.isLoading;
    final salaries = salaryProvider.salaries;
    final employees = employeeProvider.employees;

    final totalPaid = salaryProvider.totalPaid;
    final totalPending = salaryProvider.totalPending;
    final totalSalaryBill = salaryProvider.totalPayable;
    final paidEmployeeIds = salaries
        .where((s) => s.isFullyPaid)
        .map((s) => s.employeeId)
        .toSet();
    final pendingCount = employees
        .where((e) => !paidEmployeeIds.contains(e.id))
        .length;

    // Department breakdown
    final deptMap = <String, double>{};
    for (final s in salaries) {
      final emp = employees.where((e) => e.id == s.employeeId).firstOrNull;
      final dept = emp?.department ?? 'Unassigned';
      deptMap[dept] = (deptMap[dept] ?? 0) + (s.isFullyPaid ? s.paidAmount : 0);
    }

    // Status breakdown
    final statusMap = <SalaryStatus, double>{};
    for (final s in salaries) {
      final amount = s.isFullyPaid ? s.paidAmount : 0;
      statusMap[s.status] = (statusMap[s.status] ?? 0) + amount;
    }

    return AppScaffold(
      title: 'Payroll Report',
      showBackButton: true,
      body: Column(
        children: [
          // Month Selector
          _MonthSelector(
            selectedMonth: _selectedMonth,
            onPrev: _prevMonth,
            onNext: _nextMonth,
          ),
          Expanded(
            child: isLoading
                ? const LoadingWidget()
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // ── Summary Cards ─────────────────────────────
                      Text(
                        'Summary',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _ReportCard(
                              icon: Icons.people_outline,
                              label: 'Total Employees',
                              value: '${employees.length}',
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _ReportCard(
                              icon: Icons.account_balance_wallet_outlined,
                              label: 'Salary Bill',
                              value:
                                  CurrencyFormatter.compact(totalSalaryBill),
                              color: Colors.purple,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _ReportCard(
                              icon: Icons.payments_outlined,
                              label: 'Total Paid',
                              value: CurrencyFormatter.compact(totalPaid),
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _ReportCard(
                              icon: Icons.pending_actions_outlined,
                              label: 'Pending',
                              value: '$pendingCount employees',
                              color: pendingCount == 0
                                  ? Colors.green
                                  : Colors.orange,
                            ),
                          ),
                        ],
                      ),

                      if (salaries.isEmpty) ...[
                        const SizedBox(height: 40),
                        Center(
                          child: Column(
                            children: [
                              Icon(Icons.bar_chart_outlined,
                                  size: 56, color: Colors.grey.shade400),
                              const SizedBox(height: 12),
                              Text(
                                'No payments recorded for ${DateHelper.monthYear(_selectedMonth)}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: Colors.grey),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        const SizedBox(height: 20),

                        // ── Department Breakdown ─────────────────────
                        if (deptMap.isNotEmpty) ...[
                          Text(
                            'Department Breakdown',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                children: deptMap.entries.map((entry) {
                                  final pct = totalPaid > 0
                                      ? entry.value / totalPaid
                                      : 0.0;
                                  return Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 12),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(entry.key,
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.w500)),
                                            Text(
                                              CurrencyFormatter.format(
                                                  entry.value),
                                              style: const TextStyle(
                                                  fontWeight:
                                                      FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          child: LinearProgressIndicator(
                                            value: pct,
                                            minHeight: 6,
                                            backgroundColor:
                                                Colors.grey.shade200,
                                          ),
                                        ),
                                        Text(
                                          '${(pct * 100).toStringAsFixed(1)}% of total',
                                          style: const TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // ── Status Breakdown ───────────────────
                        Text(
                          'Payment Status',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: statusMap.entries.map((entry) {
                                return Expanded(
                                  child: Column(
                                    children: [
                                      Text(
                                        entry.key.displayName.toUpperCase(),
                                        style: const TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        CurrencyFormatter.compact(
                                            entry.value),
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // ── Payment List ──────────────────────────────
                        Text(
                          'All Salaries (${salaries.length})',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        ...salaries.map((s) => Card(
                              margin:
                                  const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor:
                                      s.isFullyPaid
                                          ? Colors.green.withOpacity(0.15)
                                          : Colors.orange.withOpacity(0.15),
                                  foregroundColor:
                                      s.isFullyPaid ? Colors.green : Colors.orange,
                                  child: Icon(
                                      s.isFullyPaid ? Icons.check : Icons.pending),
                                ),
                                title: Text(s.employeeName,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600)),
                                subtitle: Text(
                                  '${s.status.displayName} · ${DateHelper.display(s.paymentDate)}',
                                ),
                                trailing: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      CurrencyFormatter.format(s.netSalary),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    if (s.notes != null)
                                      Text(
                                        s.notes!,
                                        style: const TextStyle(
                                            fontSize: 10,
                                            color: Colors.grey),
                                        maxLines: 1,
                                      ),
                                  ],
                                ),
                              ),
                            )),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

// ── Month Selector ────────────────────────────────────────────────────────────
class _MonthSelector extends StatelessWidget {
  final DateTime selectedMonth;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  const _MonthSelector({
    required this.selectedMonth,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final isCurrentMonth = selectedMonth.year == DateTime.now().year &&
        selectedMonth.month == DateTime.now().month;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: Theme.of(context).colorScheme.surface,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
              onPressed: onPrev, icon: const Icon(Icons.chevron_left)),
          Text(
            DateHelper.monthYear(selectedMonth),
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          IconButton(
            onPressed: isCurrentMonth ? null : onNext,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}

// ── Report Card ────────────────────────────────────────────────────────────
class _ReportCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _ReportCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                        fontSize: 11, color: Colors.grey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
