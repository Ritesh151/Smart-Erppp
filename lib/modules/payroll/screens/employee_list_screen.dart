import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:smarterp/core/constants/app_constants.dart';
import 'package:smarterp/core/extensions/context_extensions.dart';
import 'package:smarterp/core/theme/theme_extensions.dart';
import 'package:smarterp/core/widgets/app_shell.dart';
import 'package:smarterp/core/widgets/app_card.dart';
import 'package:smarterp/core/widgets/empty_state_widget.dart';
import 'package:smarterp/core/widgets/search_filter_bar.dart';
import 'package:smarterp/core/models/employee_model.dart';
import 'package:smarterp/modules/payroll/providers/employee_provider.dart';
import 'package:smarterp/modules/payroll/widgets/animated_widgets.dart';

class EmployeeListScreen extends StatefulWidget {
  const EmployeeListScreen({super.key});

  @override
  State<EmployeeListScreen> createState() => _EmployeeListScreenState();
}

class _EmployeeListScreenState extends State<EmployeeListScreen> {
  String? _selectedStatusFilter;

  final List<Map<String, dynamic>> _statusOptions = [
    {'label': 'Active', 'value': 'active'},
    {'label': 'Inactive', 'value': 'inactive'},
    {'label': 'On Leave', 'value': 'onLeave'},
    {'label': 'Terminated', 'value': 'terminated'},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EmployeeProvider>().loadEmployees();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final theme = context.theme;

    return AppShell(
      child: Consumer<EmployeeProvider>(
        builder: (context, provider, _) {
          final employees = provider.employees;

          return ResponsivePadding(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, provider),
                const SizedBox(height: 20),
                _buildFilterBar(context, provider),
                const SizedBox(height: 16),
                _buildStatsRow(context, provider),
                const SizedBox(height: 20),
                Expanded(
                  child: provider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : employees.isEmpty
                          ? _buildEmptyState(provider)
                          : _buildEmployeeList(context, employees, provider),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, EmployeeProvider provider) {
    final theme = context.theme;
    final colorScheme = context.colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Employee Management',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold, color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text('Manage your workforce and employee records.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: () => context.push('/employees/create'),
          icon: const Icon(Icons.add),
          label: const Text('Add Employee'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterBar(BuildContext context, EmployeeProvider provider) {
    return SearchFilterBar(
      hintText: 'Search by name, code, phone, designation...',
      searchQuery: provider.searchQuery,
      onSearchChanged: (query) => provider.searchEmployees(query),
      categories: provider.departments,
      selectedCategory: provider.selectedDepartment,
      onCategoryChanged: (cat) => provider.filterByDepartment(cat),
      statusOptions: _statusOptions,
      selectedStatus: _selectedStatusFilter,
      onStatusChanged: (val) {
        setState(() => _selectedStatusFilter = val);
        EmployeeStatus? status;
        if (val == 'active') status = EmployeeStatus.active;
        if (val == 'inactive') status = EmployeeStatus.inactive;
        if (val == 'onLeave') status = EmployeeStatus.onLeave;
        if (val == 'terminated') status = EmployeeStatus.terminated;
        provider.filterByStatus(status);
      },
      onClearAll: () {
        setState(() => _selectedStatusFilter = null);
        provider.clearFilters();
      },
    );
  }

  Widget _buildStatsRow(BuildContext context, EmployeeProvider provider) {
    final theme = context.theme;
    final colorScheme = context.colorScheme;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildStatCard('Total', '${provider.totalEmployees}', Icons.people, colorScheme.primary, theme),
          const SizedBox(width: 12),
          _buildStatCard('Active', '${provider.activeEmployees}', Icons.check_circle, Colors.green.shade600, theme),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color, ThemeData theme) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
              Text(value, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(EmployeeProvider provider) {
    final hasFilters = provider.searchQuery.isNotEmpty ||
        provider.selectedDepartment != null ||
        provider.selectedStatus != null;

    if (hasFilters) {
      return EmptyStateWidget(
        icon: Icons.search_off,
        title: 'No Employees Found',
        message: 'Try adjusting your search or filters.',
        actionLabel: 'Reset Filters',
        onAction: () => provider.clearFilters(),
      );
    }

    return EmptyStateWidget(
      icon: Icons.people_outline,
      title: 'No Employees Yet',
      message: 'Add your first employee to start managing your workforce.',
      actionLabel: 'Add Employee',
      onAction: () => context.push('/employees/create'),
    );
  }

  Widget _buildEmployeeList(
    BuildContext context,
    List<EmployeeModel> employees,
    EmployeeProvider provider,
  ) {
    final colorScheme = context.colorScheme;

    return SlidableAutoCloseBehavior(
      child: ListView.builder(
        itemCount: employees.length,
        itemBuilder: (context, index) {
          final employee = employees[index];
          final statusColor = _getStatusColor(employee.status);

          return AnimatedFadeTile(
            index: index,
            totalItems: employees.length,
            child: Card(
            margin: const EdgeInsets.only(bottom: 10),
            elevation: 1,
             shape: RoundedRectangleBorder(
               borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
               side: Border.all(color: colorScheme.outlineVariant.withOpacity(0.5)),
             ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
              child: Slidable(
                key: ValueKey(employee.id),
                endActionPane: ActionPane(
                  motion: const DrawerMotion(),
                  children: [
                    SlidableAction(
                      onPressed: (context) => context.push('/employees/${employee.id}/edit'),
                      backgroundColor: Colors.blue.shade600,
                      foregroundColor: Colors.white,
                      icon: Icons.edit,
                      label: 'Edit',
                    ),
                    SlidableAction(
                      onPressed: (context) => _confirmDelete(context, employee, provider),
                      backgroundColor: colorScheme.error,
                      foregroundColor: Colors.white,
                      icon: Icons.delete,
                      label: 'Delete',
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: statusColor.withOpacity(0.1),
                    child: Text(
                      employee.fullName.isNotEmpty
                          ? employee.fullName[0].toUpperCase()
                          : '?',
                      style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(employee.fullName, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '${employee.employeeCode} | ${employee.designation} | ${employee.department}',
                      style: TextStyle(fontSize: 12, color: colorScheme.onSurface.withOpacity(0.6)),
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
                          border: Border.all(color: statusColor.withOpacity(0.25), width: 0.5),
                        ),
                        child: Text(
                          _statusLabel(employee.status),
                          style: TextStyle(color: statusColor, fontSize: 9, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.chevron_right, size: 16),
                    ],
                  ),
                  onTap: () => context.push('/employees/${employee.id}'),
                ),
              ),
            ),
          ),
        );
        },
      ),
    );
  }

  Color _getStatusColor(EmployeeStatus status) {
    switch (status) {
      case EmployeeStatus.active: return Colors.green;
      case EmployeeStatus.inactive: return Colors.grey;
      case EmployeeStatus.onLeave: return Colors.orange;
      case EmployeeStatus.terminated: return Colors.red;
    }
  }

  String _statusLabel(EmployeeStatus status) {
    switch (status) {
      case EmployeeStatus.active: return 'ACTIVE';
      case EmployeeStatus.inactive: return 'INACTIVE';
      case EmployeeStatus.onLeave: return 'ON LEAVE';
      case EmployeeStatus.terminated: return 'TERMINATED';
    }
  }

  void _confirmDelete(BuildContext context, EmployeeModel employee, EmployeeProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Employee?'),
        content: Text('Are you sure you want to permanently delete "${employee.fullName}"? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: context.colorScheme.error),
            onPressed: () async {
              try {
                await provider.deleteEmployee(employee.id);
                if (context.mounted) {
                  Navigator.pop(context);
                  context.showSnackBar('Employee deleted successfully');
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                  context.showSnackBar('Failed to delete employee: $e', isError: true);
                }
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
