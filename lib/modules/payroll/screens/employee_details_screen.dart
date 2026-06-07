import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:siddhivinayak_enterprise/core/extensions/context_extensions.dart';
import 'package:siddhivinayak_enterprise/core/models/employee_model.dart';
import 'package:siddhivinayak_enterprise/core/responsive/responsive_builder.dart';
import 'package:siddhivinayak_enterprise/core/utils/logger.dart';
import 'package:siddhivinayak_enterprise/core/widgets/app_scaffold.dart';
import 'package:siddhivinayak_enterprise/core/widgets/loading_widget.dart';
import 'package:siddhivinayak_enterprise/modules/payroll/providers/employee_provider.dart';
import 'package:siddhivinayak_enterprise/modules/payroll/utils/image_helper.dart';
import 'package:siddhivinayak_enterprise/modules/payroll/widgets/aadhaar_upload_card.dart';
import 'package:siddhivinayak_enterprise/modules/payroll/widgets/employee_avatar.dart';
import 'package:siddhivinayak_enterprise/modules/payroll/widgets/image_preview_dialog.dart';

class EmployeeDetailsScreen extends StatefulWidget {
  final String employeeId;

  const EmployeeDetailsScreen({super.key, required this.employeeId});

  @override
  State<EmployeeDetailsScreen> createState() => _EmployeeDetailsScreenState();
}

class _EmployeeDetailsScreenState extends State<EmployeeDetailsScreen> {
  EmployeeModel? _employee;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadEmployee();
  }

  Future<void> _loadEmployee() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final provider = context.read<EmployeeProvider>();
      await provider.loadEmployees();
      final emp = provider.employees.where((e) => e.id == widget.employeeId).firstOrNull;
      setState(() {
        _employee = emp;
        _isLoading = false;
        if (emp == null) _error = 'Employee not found';
      });
    } catch (e, stackTrace) {
      Logger.error('Failed to load employee', e, stackTrace);
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _handleUpload() async {
    try {
      final path = await ImageHelper.pickImage();
      if (path == null || !mounted) return;

      final provider = context.read<EmployeeProvider>();
      final success = await provider.uploadAadhaarImage(
        employeeId: widget.employeeId,
        filePath: path,
      );

      if (success && mounted) {
        await _loadEmployee();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Aadhaar image uploaded successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to upload: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleRemove() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Aadhaar Image'),
        content: const Text('Are you sure you want to remove the Aadhaar card image?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final provider = context.read<EmployeeProvider>();
    final success = await provider.removeAadhaarImage(widget.employeeId);
    if (success && mounted) {
      await _loadEmployee();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aadhaar image removed'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _showPreview() {
    if (_employee?.aadhaarImagePath == null) return;
    showDialog(
      context: context,
      builder: (_) => ImagePreviewDialog(
        imageFile: _employee!.aadhaarImagePath!,
        employeeName: _employee!.fullName,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const AppScaffold(title: 'Employee Details', body: LoadingWidget());
    }

    if (_error != null || _employee == null) {
      return AppScaffold(
        title: 'Employee Details',
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(_error ?? 'Employee not found'),
            ],
          ),
        ),
      );
    }

    return ResponsiveBuilder(
      mobile: _buildMobileLayout(context),
      tablet: _buildTabletLayout(context),
      desktop: _buildDesktopLayout(context),
      builder: (context, deviceType) => _buildMobileLayout(context),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return _buildScaffold(
      context,
      SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildProfileHeader(context),
            const SizedBox(height: 16),
            _buildDetailCards(context),
            const SizedBox(height: 16),
            _buildAadhaarSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return _buildScaffold(
      context,
      SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: Column(
                children: [
                  _buildProfileHeader(context),
                  const SizedBox(height: 16),
                  _buildDetailCards(context),
                ],
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              flex: 4,
              child: _buildAadhaarSection(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return _buildScaffold(
      context,
      SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 6,
              child: Column(
                children: [
                  _buildProfileHeader(context),
                  const SizedBox(height: 16),
                  _buildDetailCards(context),
                ],
              ),
            ),
            const SizedBox(width: 32),
            Expanded(
              flex: 4,
              child: _buildAadhaarSection(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScaffold(BuildContext context, Widget body) {
    return AppScaffold(
      title: 'Employee Details',
      body: RefreshIndicator(onRefresh: _loadEmployee, child: body),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    final theme = Theme.of(context);
    final emp = _employee!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            EmployeeAvatar(
              employee: emp,
              aadhaarImagePath: emp.aadhaarImagePath,
              size: 72,
              showAadhaarBadge: emp.aadhaarImagePath != null,
              onAadhaarClick: emp.aadhaarImagePath != null ? _showPreview : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    emp.fullName,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    emp.designation,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    emp.department,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (value) => _handleMenuAction(context, value),
              itemBuilder: (_) => [
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
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCards(BuildContext context) {
    final theme = Theme.of(context);
    final emp = _employee!;

    return Column(
      children: [
        _buildInfoCard(
          context,
          'Personal Information',
          [
            _buildInfoRow(Icons.badge_outlined, 'Employee Code', emp.employeeCode),
            _buildInfoRow(Icons.email_outlined, 'Email', emp.email),
            _buildInfoRow(Icons.phone_outlined, 'Phone', emp.phone),
          ],
        ),
        const SizedBox(height: 12),
        _buildInfoCard(
          context,
          'Employment Details',
          [
            _buildInfoRow(Icons.work_outlined, 'Department', emp.department),
            _buildInfoRow(Icons.work_history_outlined, 'Designation', emp.designation),
            _buildInfoRow(Icons.calendar_today_outlined, 'Joining Date', _formatDate(emp.dateOfJoining)),
            _buildInfoRow(Icons.monetization_on_outlined, 'Salary', '₹ ${_formatSalary(emp.salary)}'),
          ],
        ),
        if (emp.aadharNumber != null || emp.panNumber != null) ...[
          const SizedBox(height: 12),
          _buildInfoCard(
            context,
            'Documents',
            [
              if (emp.aadharNumber != null)
                _buildInfoRow(Icons.fingerprint_rounded, 'Aadhaar Number', emp.aadharNumber!),
              if (emp.panNumber != null)
                _buildInfoRow(Icons.credit_card_rounded, 'PAN Number', emp.panNumber!),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildInfoCard(BuildContext context, String title, List<Widget> children) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const Divider(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.onSurface.withOpacity(0.5)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAadhaarSection(BuildContext context) {
    final emp = _employee!;
    final hasImage = emp.aadhaarImagePath != null;

    return AadhaarUploadCard(
      currentImage: emp.aadhaarImagePath,
      employeeName: emp.fullName,
      onUpload: _handleUpload,
      onReplace: _handleUpload,
      onDelete: _handleRemove,
      onViewFull: _showPreview,
      isDesktop: context.isDesktop || context.isLargeDesktop,
      isLoading: context.watch<EmployeeProvider>().isUploadingImage,
    );
  }

  void _handleMenuAction(BuildContext context, String value) {
    switch (value) {
      case 'edit':
        context.go('/payroll/${widget.employeeId}/edit');
        break;
      case 'salary':
        context.go('/payroll/${widget.employeeId}/salary');
        break;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatSalary(double salary) {
    if (salary >= 100000) {
      return '${(salary / 100000).toStringAsFixed(1)}L';
    } else if (salary >= 1000) {
      return '${(salary / 1000).toStringAsFixed(1)}K';
    }
    return salary.toStringAsFixed(0);
  }
}
