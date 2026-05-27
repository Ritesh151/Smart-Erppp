import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:smarterp/core/constants/app_constants.dart';
import 'package:smarterp/core/extensions/context_extensions.dart';
import 'package:smarterp/core/extensions/date_extensions.dart';
import 'package:smarterp/core/widgets/app_shell.dart';
import 'package:smarterp/core/widgets/app_card.dart';
import 'package:smarterp/core/models/employee_model.dart';
import 'package:smarterp/modules/payroll/providers/employee_provider.dart';
import 'package:smarterp/modules/payroll/widgets/animated_widgets.dart';

class EmployeeDetailsScreen extends StatefulWidget {
  final String employeeId;

  const EmployeeDetailsScreen({super.key, required this.employeeId});

  @override
  State<EmployeeDetailsScreen> createState() => _EmployeeDetailsScreenState();
}

class _EmployeeDetailsScreenState extends State<EmployeeDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<EmployeeProvider>();
      final employee = provider.employees.where((e) => e.id == widget.employeeId).firstOrNull;
      if (employee != null) provider.selectEmployee(employee);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return AppShell(
      child: Consumer<EmployeeProvider>(
        builder: (context, provider, _) {
          final employee = provider.selectedEmployee;

          if (employee == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, employee),
                const SizedBox(height: 24),
                AnimatedSection(
                  title: 'Personal Information',
                  icon: Icons.person_outline,
                  child: _buildPersonalInfo(context, employee),
                ),
                const SizedBox(height: 16),
                AnimatedSection(
                  title: 'Employment Details',
                  icon: Icons.work_outline,
                  child: _buildEmploymentInfo(context, employee),
                ),
                const SizedBox(height: 16),
                AnimatedSection(
                  title: 'Bank & Identity',
                  icon: Icons.account_balance_outlined,
                  child: _buildBankInfo(context, employee),
                ),
                const SizedBox(height: 24),
                _buildActions(context, employee),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, EmployeeModel employee) {
    final statusColor = _getStatusColor(employee.status);
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        CircleAvatar(
          radius: 32,
          backgroundColor: statusColor.withOpacity(0.1),
          child: Text(
            employee.fullName.isNotEmpty ? employee.fullName[0].toUpperCase() : '?',
            style: TextStyle(fontSize: 24, color: statusColor, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(employee.fullName, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('${employee.employeeCode} | ${employee.designation}', style: TextStyle(color: colorScheme.onSurfaceVariant)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
                  border: Border.all(color: statusColor.withOpacity(0.25), width: 0.5),
                ),
                child: Text(
                  _statusLabel(employee.status).toUpperCase(),
                  style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 11),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPersonalInfo(BuildContext context, EmployeeModel employee) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Personal Information', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          _infoRow(Icons.email_outlined, employee.email),
          _infoRow(Icons.phone_outlined, employee.phone),
          if (employee.address != null && employee.address!.isNotEmpty)
            _infoRow(Icons.location_on_outlined, employee.address!),
          if (employee.dateOfBirth != null) ...[
            const SizedBox(height: 8),
            _infoRow(Icons.cake_outlined, employee.dateOfBirth!.toFormattedDate()),
          ],
          const SizedBox(height: 8),
          _infoRow(Icons.calendar_today, 'Joined: ${employee.dateOfJoining.toFormattedDate()}'),
        ],
      ),
    );
  }

  Widget _buildEmploymentInfo(BuildContext context, EmployeeModel employee) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Employment Details', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          _infoRow(Icons.work_outlined, employee.designation),
          _infoRow(Icons.business_outlined, employee.department),
          _infoRow(Icons.monetization_on_outlined, '₹${employee.salary.toStringAsFixed(2)}'),
          _infoRow(Icons.people_outlined, employee.employmentType.name),
          if (employee.experienceInYears > 0)
            _infoRow(Icons.timer_outlined, '${employee.experienceInYears} years experience'),
        ],
      ),
    );
  }

  Widget _buildBankInfo(BuildContext context, EmployeeModel employee) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Bank & Identity', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          if (employee.bankAccountNumber != null && employee.bankAccountNumber!.isNotEmpty)
            _infoRow(Icons.account_balance_outlined, 'A/C: ${employee.bankAccountNumber!}'),
          if (employee.bankName != null && employee.bankName!.isNotEmpty)
            _infoRow(Icons.account_balance, employee.bankName!),
          if (employee.ifscCode != null && employee.ifscCode!.isNotEmpty)
            _infoRow(Icons.code_outlined, 'IFSC: ${employee.ifscCode!}'),
          if (employee.panNumber != null && employee.panNumber!.isNotEmpty)
            _infoRow(Icons.badge_outlined, 'PAN: ${employee.panNumber!}'),
          if (employee.aadharNumber != null && employee.aadharNumber!.isNotEmpty)
            _infoRow(Icons.fingerprint, 'Aadhar: ${employee.aadharNumber!}'),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context, EmployeeModel employee) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        OutlinedButton.icon(
          onPressed: () => context.push('/employees/${employee.id}/edit'),
          icon: const Icon(Icons.edit, size: 18),
          label: const Text('Edit Employee'),
        ),
        const SizedBox(width: 12),
        OutlinedButton.icon(
          onPressed: () => _confirmDelete(context, employee),
          icon: const Icon(Icons.delete_outline, size: 18),
          label: const Text('Delete'),
        ),
      ],
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
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

  void _confirmDelete(BuildContext context, EmployeeModel employee) {
    final provider = context.read<EmployeeProvider>();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Employee?'),
        content: Text('Are you sure you want to permanently delete "${employee.fullName}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: context.colorScheme.error),
            onPressed: () async {
              try {
                await provider.deleteEmployee(employee.id);
                if (context.mounted) {
                  Navigator.pop(context);
                  context.showSnackBar('Employee deleted');
                  GoRouter.of(context).pop();
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                  context.showSnackBar('Failed to delete: $e', isError: true);
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
