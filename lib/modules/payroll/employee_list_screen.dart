import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:siddhivinayak_enterprise/core/utils/currency_formatter.dart';
import 'package:siddhivinayak_enterprise/core/widgets/app_scaffold.dart';
import 'package:siddhivinayak_enterprise/core/widgets/empty_state_widget.dart';
import 'package:siddhivinayak_enterprise/core/widgets/loading_widget.dart';
import 'package:siddhivinayak_enterprise/modules/payroll/providers/employee_provider.dart';
import 'package:siddhivinayak_enterprise/modules/payroll/utils/image_helper.dart';
import 'package:siddhivinayak_enterprise/modules/payroll/widgets/image_preview_dialog.dart';

class EmployeeListScreen extends StatelessWidget {
  const EmployeeListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EmployeeProvider>();
    final theme = Theme.of(context);

    return AppScaffold(
      title: 'Labour',
      showBackButton: false,
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/payroll/add'),
        child: const Icon(Icons.person_add_outlined),
      ),
      body: _buildBody(context, provider, theme),
    );
  }

  Widget _buildBody(BuildContext context, EmployeeProvider provider, ThemeData theme) {
    if (provider.isLoading) {
      return const LoadingWidget();
    }

    if (provider.error != null) {
      return Center(child: Text('Error: ${provider.error}'));
    }

    final employees = provider.employees;

    if (employees.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.people_outlined,
        title: 'No Employees',
        message: 'Add your factory workers to manage payroll.',
        actionLabel: 'Add Employee',
        onAction: () => context.go('/payroll/add'),
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.loadEmployees(),
      child: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: employees.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (ctx, i) {
          final emp = employees[i];
          final hasAadhaar = emp.aadhaarImagePath != null && emp.aadhaarImagePath!.isNotEmpty;

          return Card(
            margin: EdgeInsets.zero,
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: InkWell(
              onTap: () => context.go('/payroll/${emp.id}'),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          child: Text(
                            emp.fullName[0].toUpperCase(),
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                        if (hasAadhaar)
                          Positioned(
                            right: -2,
                            bottom: -2,
                            child: Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 1.5),
                              ),
                              child: const Icon(Icons.fingerprint, size: 8, color: Colors.white),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  emp.fullName,
                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                                ),
                              ),
                              if (hasAadhaar)
                                GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (_) => ImagePreviewDialog(
                                        imageFile: emp.aadhaarImagePath!,
                                        employeeName: emp.fullName,
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.fingerprint, size: 12, color: Colors.green),
                                        SizedBox(width: 2),
                                        Text(
                                          'Aadhaar',
                                          style: TextStyle(fontSize: 10, color: Colors.green),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${emp.designation}${emp.department.isNotEmpty ? ' · ${emp.department}' : ''}',
                            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${CurrencyFormatter.compact(emp.salary)}/month',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (value) => _handleMenuAction(context, value, emp.id, emp.fullName),
                      itemBuilder: (_) => [
                        const PopupMenuItem(value: 'view', child: ListTile(
                          leading: Icon(Icons.visibility_outlined),
                          title: Text('View'),
                          contentPadding: EdgeInsets.zero,
                        )),
                        const PopupMenuItem(value: 'edit', child: ListTile(
                          leading: Icon(Icons.edit_outlined),
                          title: Text('Edit'),
                          contentPadding: EdgeInsets.zero,
                        )),
                        const PopupMenuItem(value: 'salary', child: ListTile(
                          leading: Icon(Icons.payments_outlined),
                          title: Text('Pay Salary'),
                          contentPadding: EdgeInsets.zero,
                        )),
                        const PopupMenuItem(value: 'delete', child: ListTile(
                          leading: Icon(Icons.delete_outline, color: Colors.red),
                          title: Text('Delete', style: TextStyle(color: Colors.red)),
                          contentPadding: EdgeInsets.zero,
                        )),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _handleMenuAction(
    BuildContext context,
    String action,
    String employeeId,
    String employeeName,
  ) async {
    switch (action) {
      case 'view':
        context.go('/payroll/$employeeId');
        break;
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
            content: Text('Are you sure you want to delete "$employeeName"? This action cannot be undone.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
        if (confirmed == true && context.mounted) {
          try {
            final provider = context.read<EmployeeProvider>();
            await provider.deleteEmployee(employeeId);

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
