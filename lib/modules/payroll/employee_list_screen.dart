// lib/Pages/Payroll/employee_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:SmartERP/Providers/payroll_provider.dart';
import 'package:SmartERP/core/utils/currency_formatter.dart';
import 'package:SmartERP/core/widgets/app_scaffold.dart';
import 'package:SmartERP/core/widgets/empty_state_widget.dart';
import 'package:SmartERP/core/widgets/loading_widget.dart';

class EmployeeListScreen extends ConsumerWidget {
  const EmployeeListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final employeesAsync = ref.watch(employeesStreamProvider);

    return AppScaffold(
      title: 'Labour',
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/payroll/add'),
        child: const Icon(Icons.person_add_outlined),
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
              onAction: () => context.go('/payroll/add'),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: employees.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (ctx, i) {
              final emp = employees[i];
              return Card(
                margin: EdgeInsets.zero,
                elevation: 1,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        child: Text(
                          emp.fullName[0].toUpperCase(),
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              emp.fullName,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 15),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              emp.designation +
                                  (emp.department != null
                                      ? ' · ${emp.department}'
                                      : ''),
                              style: TextStyle(
                                  fontSize: 13, color: Colors.grey.shade600),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              CurrencyFormatter.compact(emp.monthlySalary) +
                                  '/month',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuButton<String>(
                        onSelected: (value) =>
                            _handleMenuAction(context, ref, value,                         emp.id, emp.fullName),
                        itemBuilder: (_) => const [
                          PopupMenuItem(
                            value: 'edit',
                            child: ListTile(
                              leading: Icon(Icons.edit_outlined),
                              title: Text('Edit'),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                          PopupMenuItem(
                            value: 'salary',
                            child: ListTile(
                              leading: Icon(Icons.payments_outlined),
                              title: Text('Pay Salary'),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: ListTile(
                              leading:
                                  Icon(Icons.delete_outline, color: Colors.red),
                              title: Text('Delete',
                                  style: TextStyle(color: Colors.red)),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _handleMenuAction(
    BuildContext context,
    WidgetRef ref,
    String action,
    String employeeId,
    String employeeName,
  ) async {
    switch (action) {
      case 'edit':
        context.go('/payroll/$employeeId/edit');
        break;
      case 'salary':
        context.go('/payroll/$employeeId/salary');
        break;
      case 'delete':
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete Employee'),
            content: Text(
                'Are you sure you want to delete "$employeeName"? This action cannot be undone.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                style:
                    TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
        if (confirmed == true && context.mounted) {
          try {
            await ref
                .read(payrollControllerProvider)
                    .deleteEmployee(employeeId);

            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('"$employeeName" deleted'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Failed to delete employee'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        }
        break;
    }
  }
}
