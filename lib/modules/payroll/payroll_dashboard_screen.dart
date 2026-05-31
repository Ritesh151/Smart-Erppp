// lib/Pages/Payroll/payroll_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:siddhivinayak_enterprise/core/models/employee_model.dart';
import 'package:siddhivinayak_enterprise/Providers/payroll_provider.dart';
import 'package:siddhivinayak_enterprise/core/utils/currency_formatter.dart';
import 'package:siddhivinayak_enterprise/core/utils/date_helper.dart';
import 'package:siddhivinayak_enterprise/core/widgets/app_scaffold.dart';
import 'package:siddhivinayak_enterprise/core/widgets/empty_state_widget.dart';
import 'package:siddhivinayak_enterprise/core/widgets/loading_widget.dart';

class PayrollDashboardScreen extends ConsumerStatefulWidget {
  const PayrollDashboardScreen({super.key});

  @override
  ConsumerState<PayrollDashboardScreen> createState() =>
      _PayrollDashboardScreenState();
}

class _PayrollDashboardScreenState
    extends ConsumerState<PayrollDashboardScreen> {
  String? _selectedEmployeeId;

  // ── Delete confirmation ──────────────────────────────────────────────────
  void _confirmDelete(EmployeeModel emp) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.warning_amber_rounded,
            color: Colors.orange, size: 40),
        title: const Text('Delete Employee'),
        content: Text(
          'Are you sure you want to remove "${emp.fullName}" from the system?\n\n'
          'This action will deactivate the employee record.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await ref
                    .read(payrollControllerProvider)
                    .deleteEmployee(emp.employeeId);
                if (!mounted) return;
                if (_selectedEmployeeId == emp.employeeId) {
                  setState(() => _selectedEmployeeId = null);
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${emp.fullName} removed successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to delete: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final employeesAsync = ref.watch(employeesStreamProvider);
    final paymentsAsync = ref.watch(salaryPaymentsStreamProvider);
    final isLargeScreen = MediaQuery.of(context).size.width > 900;

    return AppScaffold(
      title: 'Payroll Management',
      showBackButton: false,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/payroll/add'),
        icon: const Icon(Icons.person_add_outlined),
        label: const Text('Add Employee'),
        tooltip: 'Add Employee',
      ),
      body: employeesAsync.when(
        loading: () => const LoadingWidget(),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (employees) {
          if (employees.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.people_outlined,
              title: 'No Employees',
              message: 'Add your factory workers to manage payroll.',
              actionLabel: 'Add Employee',
              onAction: () => context.push('/payroll/add'),
            );
          }

          // Compute HR stats
          final payments = paymentsAsync.asData?.value ?? [];
          final now = DateTime.now();
          final currentKey = DateHelper.firestoreKey(now);
          final thisMonthPayments =
              payments.where((p) => p.monthYear == currentKey).toList();
          final totalPaidThisMonth =
              thisMonthPayments.fold<double>(0, (s, p) => s + p.netPaid);
          final paidEmployeeIds =
              thisMonthPayments.map((p) => p.employeeId).toSet();
          final pendingCount = employees
              .where((e) => !paidEmployeeIds.contains(e.employeeId))
              .length;

          final statsHeader = _HrStatsHeader(
            totalEmployees: employees.length,
            totalPaidThisMonth: totalPaidThisMonth,
            pendingCount: pendingCount,
          );

          if (isLargeScreen) {
            return Column(
              children: [
                statsHeader,
                Expanded(
                  child: Row(
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.35,
                        child: _EmployeePanel(
                          employees: employees,
                          selectedEmployeeId: _selectedEmployeeId,
                          onEmployeeSelected: (id) =>
                              setState(() => _selectedEmployeeId = id),
                          onEdit: (emp) =>
                              context.push('/payroll/${emp.employeeId}/edit'),
                          onDelete: _confirmDelete,
                        ),
                      ),
                      VerticalDivider(width: 1, color: Colors.grey.shade300),
                      Expanded(
                        child: _selectedEmployeeId != null
                            ? _SalaryPanel(employeeId: _selectedEmployeeId!)
                            : Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.person_search_outlined,
                                      size: 48,
                                      color: Colors.grey.shade400,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Select an employee to view details',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          } else {
            return Column(
              children: [
                statsHeader,
                Expanded(
                  child: DefaultTabController(
                    length: 2,
                    child: Column(
                      children: [
                        TabBar(
                          tabs: const [
                            Tab(icon: Icon(Icons.people), text: 'Employees'),
                            Tab(icon: Icon(Icons.payments), text: 'Salary'),
                          ],
                        ),
                        Expanded(
                          child: TabBarView(
                            children: [
                              _EmployeePanel(
                                employees: employees,
                                selectedEmployeeId: _selectedEmployeeId,
                                onEmployeeSelected: (id) =>
                                    setState(() => _selectedEmployeeId = id),
                                onEdit: (emp) => context
                                    .push('/payroll/${emp.employeeId}/edit'),
                                onDelete: _confirmDelete,
                              ),
                              _selectedEmployeeId != null
                                  ? _SalaryPanel(
                                      employeeId: _selectedEmployeeId!)
                                  : Center(
                                      child: Text(
                                        'Select an employee first',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge,
                                      ),
                                    ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}

// ─── HR Stats Header ────────────────────────────────────────────────────────
class _HrStatsHeader extends StatelessWidget {
  final int totalEmployees;
  final double totalPaidThisMonth;
  final int pendingCount;

  const _HrStatsHeader({
    required this.totalEmployees,
    required this.totalPaidThisMonth,
    required this.pendingCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      child: Row(
        children: [
          _StatChip(
            icon: Icons.people_outline,
            label: 'Employees',
            value: '$totalEmployees',
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          _StatChip(
            icon: Icons.payments_outlined,
            label: 'Paid This Month',
            value: CurrencyFormatter.compact(totalPaidThisMonth),
            color: Colors.green,
          ),
          const SizedBox(width: 8),
          _StatChip(
            icon: Icons.pending_actions_outlined,
            label: 'Pending',
            value: '$pendingCount',
            color: pendingCount == 0 ? Colors.green : Colors.orange,
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Row(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      value,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: color,
                      ),
                    ),
                    Text(
                      label,
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Employee List Panel ──────────────────────────────────────────────────
class _EmployeePanel extends ConsumerWidget {
  final List<EmployeeModel> employees;
  final String? selectedEmployeeId;
  final Function(String) onEmployeeSelected;
  final Function(EmployeeModel) onEdit;
  final Function(EmployeeModel) onDelete;

  const _EmployeePanel({
    required this.employees,
    required this.selectedEmployeeId,
    required this.onEmployeeSelected,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLargeScreen = MediaQuery.of(context).size.width > 900;
    final payments =
        ref.watch(salaryPaymentsStreamProvider).asData?.value ?? [];
    final now = DateTime.now();
    final currentKey = DateHelper.firestoreKey(now);

    return Column(
      children: [
        if (isLargeScreen)
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Employees (${employees.length})',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                SizedBox(
                  width: 36,
                  height: 36,
                  child: IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => context.push('/payroll/add'),
                    iconSize: 20,
                    padding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(8),
            itemCount: employees.length,
            cacheExtent: 300,
            addRepaintBoundaries: true,
            addAutomaticKeepAlives: false,
            separatorBuilder: (_, __) => const SizedBox(height: 4),
            itemBuilder: (ctx, i) {
              final emp = employees[i];
              final isSelected = emp.employeeId == selectedEmployeeId;

              // Check if paid this month
              final paidThisMonth = payments.any((p) =>
                  p.employeeId == emp.employeeId && p.monthYear == currentKey);

              return Card(
                key: ValueKey(emp.employeeId),
                margin: EdgeInsets.zero,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                    : null,
                child: ListTile(
                  selected: isSelected,
                  selectedTileColor:
                      Theme.of(context).colorScheme.primary.withOpacity(0.05),
                  leading: CircleAvatar(
                    backgroundColor: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey.shade300,
                    foregroundColor: isSelected ? Colors.white : Colors.black87,
                    child: Text(emp.fullName[0].toUpperCase()),
                  ),
                  title: Text(emp.fullName,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(emp.designation,
                          style: const TextStyle(fontSize: 12)),
                      if (emp.department != null)
                        Text(
                          'Dept: ${emp.department}',
                          style:
                              const TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      Row(
                        children: [
                          Text(
                            CurrencyFormatter.compact(emp.monthlySalary),
                            style: const TextStyle(
                                fontSize: 11, fontWeight: FontWeight.w500),
                          ),
                          const Text(
                            '/mo',
                            style: TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: paidThisMonth
                                  ? Colors.green.withOpacity(0.15)
                                  : Colors.orange.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              paidThisMonth ? 'Paid' : 'Pending',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: paidThisMonth
                                    ? Colors.green.shade700
                                    : Colors.orange.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  isThreeLine: true,
                  trailing: PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    tooltip: 'Options',
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          onEdit(emp);
                          break;
                        case 'delete':
                          onDelete(emp);
                          break;
                        case 'pay':
                          context.push('/payroll/${emp.employeeId}/salary');
                          break;
                        case 'history':
                          context.push('/payroll/${emp.employeeId}/history');
                          break;
                      }
                    },
                    itemBuilder: (ctx) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: ListTile(
                          leading: Icon(Icons.edit_outlined),
                          title: Text('Edit'),
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'pay',
                        child: ListTile(
                          leading: Icon(Icons.payments_outlined),
                          title: Text('Pay Salary'),
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'history',
                        child: ListTile(
                          leading: Icon(Icons.history_outlined),
                          title: Text('Salary History'),
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                        ),
                      ),
                      const PopupMenuDivider(),
                      const PopupMenuItem(
                        value: 'delete',
                        child: ListTile(
                          leading:
                              Icon(Icons.delete_outline, color: Colors.red),
                          title: Text('Delete',
                              style: TextStyle(color: Colors.red)),
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                        ),
                      ),
                    ],
                  ),
                  onTap: () => onEmployeeSelected(emp.employeeId),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ─── Salary Details Panel ──────────────────────────────────────────────────
class _SalaryPanel extends ConsumerWidget {
  final String employeeId;

  const _SalaryPanel({required this.employeeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final employeesAsync = ref.watch(employeesStreamProvider);
    final salariesAsync = ref.watch(salaryPaymentsStreamProvider);

    return employeesAsync.when(
      loading: () => const LoadingWidget(),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (employees) {
        final employee =
            employees.where((e) => e.employeeId == employeeId).firstOrNull;
        if (employee == null) {
          return const Center(child: Text('Employee not found'));
        }

        return salariesAsync.when(
          loading: () => const LoadingWidget(),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (payments) {
            final now = DateTime.now();
            final currentMonthKey = DateHelper.firestoreKey(now);
            final employeePayments =
                payments.where((p) => p.employeeId == employeeId).toList();
            final currentMonthPayments = employeePayments
                .where((p) => p.monthYear == currentMonthKey)
                .toList();

            final totalPaidThisMonth = currentMonthPayments.fold<double>(
                0, (sum, p) => sum + p.paidAmount);
            final remainingSalary = (employee.salary - totalPaidThisMonth)
                .clamp(0.0, double.infinity);
            final paymentPercentage = employee.salary > 0
                ? (totalPaidThisMonth / employee.salary * 100)
                : 0;

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Employee Header
                    Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 32,
                              child: Text(employee.fullName[0].toUpperCase()),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    employee.fullName,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  Text(employee.designation,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(color: Colors.grey)),
                                  if (employee.department != null)
                                    Text(
                                      'Dept: ${employee.department}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(color: Colors.grey),
                                    ),
                                ],
                              ),
                            ),
                            // Edit button in salary panel
                            IconButton(
                              icon: const Icon(Icons.edit_outlined),
                              onPressed: () => context
                                  .push('/payroll/${employee.employeeId}/edit'),
                              tooltip: 'Edit Employee',
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Current Month Salary Summary
                    Text(
                      'Current Month (${DateHelper.monthYear(now)})',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: _SalaryMetricCard(
                            label: 'Monthly Salary',
                            amount: employee.salary,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _SalaryMetricCard(
                            label: 'Already Paid',
                            amount: totalPaidThisMonth,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _SalaryMetricCard(
                            label: 'Remaining',
                            amount: remainingSalary,
                            color: remainingSalary == 0
                                ? Colors.green
                                : Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Progress bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: paymentPercentage / 100,
                        minHeight: 8,
                        backgroundColor: Colors.grey.shade300,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          remainingSalary == 0 ? Colors.green : Colors.orange,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${paymentPercentage.toStringAsFixed(1)}% paid',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: Colors.grey),
                    ),
                    const SizedBox(height: 20),

                    // Action Buttons Row
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: remainingSalary > 0
                                ? () =>
                                    context.push('/payroll/$employeeId/salary')
                                : null,
                            icon: const Icon(Icons.payments_outlined),
                            label: const Text('Record Payment'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton.icon(
                          onPressed: () =>
                              context.push('/payroll/$employeeId/history'),
                          icon: const Icon(Icons.history_outlined),
                          label: const Text('History'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Payment History
                    Text(
                      'Payment History (${DateHelper.monthYear(now)})',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),

                    if (currentMonthPayments.isEmpty)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            'No payments recorded yet',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: Colors.grey),
                          ),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: currentMonthPayments.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (ctx, idx) {
                          final payment = currentMonthPayments[idx];
                          return Card(
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.green.withOpacity(0.2),
                                foregroundColor: Colors.green,
                                child: const Icon(Icons.check),
                              ),
                              title: Text(
                                  '${CurrencyFormatter.format(payment.paidAmount)} paid'),
                              subtitle: Text(
                                DateHelper.displayDateTime(payment.paymentDate),
                              ),
                              trailing: Text(
                                payment.paymentMode.toUpperCase(),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: Colors.grey),
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// ─── Metric Card Widget ─────────────────────────────────────────────────────
class _SalaryMetricCard extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;

  const _SalaryMetricCard({
    required this.label,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  width: 4,
                  height: 24,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    CurrencyFormatter.format(amount),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
