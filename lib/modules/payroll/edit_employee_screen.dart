import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:siddhivinayak_enterprise/core/extensions/context_extensions.dart';
import 'package:siddhivinayak_enterprise/core/models/employee_model.dart';
import 'package:siddhivinayak_enterprise/core/responsive/breakpoints.dart';
import 'package:siddhivinayak_enterprise/core/responsive/responsive_builder.dart';
import 'package:siddhivinayak_enterprise/core/utils/logger.dart';
import 'package:siddhivinayak_enterprise/Utils/validators.dart';
import 'package:siddhivinayak_enterprise/core/widgets/app_scaffold.dart';
import 'package:siddhivinayak_enterprise/core/widgets/loading_widget.dart';
import 'package:siddhivinayak_enterprise/modules/payroll/providers/employee_provider.dart';
import 'package:siddhivinayak_enterprise/modules/payroll/utils/image_helper.dart';
import 'package:siddhivinayak_enterprise/modules/payroll/widgets/aadhaar_upload_card.dart';
import 'package:siddhivinayak_enterprise/modules/payroll/widgets/image_preview_dialog.dart';

class EditEmployeeScreen extends StatefulWidget {
  final String employeeId;

  const EditEmployeeScreen({super.key, required this.employeeId});

  @override
  State<EditEmployeeScreen> createState() => _EditEmployeeScreenState();
}

class _EditEmployeeScreenState extends State<EditEmployeeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _designationCtrl = TextEditingController();
  final _departmentCtrl = TextEditingController();
  final _salaryCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  bool _initialized = false;
  bool _isSaving = false;

  String? _aadhaarImagePath;
  bool _isUploading = false;
  EmployeeModel? _employee;

  @override
  void initState() {
    super.initState();
    _loadEmployee();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _designationCtrl.dispose();
    _departmentCtrl.dispose();
    _salaryCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadEmployee() async {
    try {
      final provider = context.read<EmployeeProvider>();
      await provider.loadEmployees();
      final emp = provider.employees.where((e) => e.id == widget.employeeId).firstOrNull;
      if (emp != null && mounted) {
        setState(() {
          _employee = emp;
          _aadhaarImagePath = emp.aadhaarImagePath;
        });
        if (!_initialized) {
          _nameCtrl.text = emp.fullName;
          _designationCtrl.text = emp.designation;
          _departmentCtrl.text = emp.department;
          _salaryCtrl.text = emp.salary.toStringAsFixed(0);
          _phoneCtrl.text = emp.phone;
          _initialized = true;
        }
      }
    } catch (e, stackTrace) {
      Logger.error('Failed to load employee', e, stackTrace);
    }
  }

  Future<void> _handleAadhaarUpload() async {
    try {
      setState(() => _isUploading = true);
      final path = await ImageHelper.pickImage();
      if (path != null && mounted) {
        final provider = context.read<EmployeeProvider>();
        final success = await provider.uploadAadhaarImage(
          employeeId: widget.employeeId,
          filePath: path,
        );
        if (success && mounted) {
          setState(() => _aadhaarImagePath = path);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Aadhaar image updated'), backgroundColor: Colors.green),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<void> _handleRemoveAadhaar() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Aadhaar Image'),
        content: const Text('Are you sure?'),
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
      setState(() => _aadhaarImagePath = null);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final provider = context.read<EmployeeProvider>();

      if (_employee == null) {
        throw Exception('Employee data not loaded');
      }

      final updated = _employee!.copyWith(
        firstName: _nameCtrl.text.trim(),
        lastName: '',
        phone: _phoneCtrl.text.trim().isEmpty ? '' : _phoneCtrl.text.trim(),
        department: _departmentCtrl.text.trim().isEmpty ? 'General' : _departmentCtrl.text.trim(),
        designation: _designationCtrl.text.trim(),
        salary: double.parse(_salaryCtrl.text),
        updatedAt: DateTime.now(),
      );

      final success = await provider.updateEmployee(updated);

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Employee updated successfully'), backgroundColor: Colors.green),
        );
        context.go('/payroll');
      } else {
        throw Exception('Failed to update');
      }
    } catch (e, stackTrace) {
      Logger.error('Failed to update employee', e, stackTrace);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final deviceType = context.deviceType;
    final isDesktop = deviceType == DeviceType.desktop || deviceType == DeviceType.largeDesktop;

    if (_employee == null && !_initialized) {
      return const AppScaffold(title: 'Edit Employee', body: LoadingWidget());
    }

    return AppScaffold(
      title: 'Edit Employee',
      body: ResponsiveBuilder(
        mobile: _buildForm(theme, false),
        tablet: _buildForm(theme, false),
        desktop: _buildDesktopForm(theme),
        largeDesktop: _buildDesktopForm(theme),
        builder: (context, _) => _buildForm(theme, isDesktop),
      ),
    );
  }

  Widget _buildForm(ThemeData theme, bool isDesktop) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(theme),
                const Divider(height: 28),
                _buildFields(theme),
                const SizedBox(height: 24),
                AadhaarUploadCard(
                  currentImage: _aadhaarImagePath,
                  employeeName: _nameCtrl.text.isNotEmpty ? _nameCtrl.text.trim() : 'Employee',
                  onUpload: _handleAadhaarUpload,
                  onReplace: _handleAadhaarUpload,
                  onDelete: _handleRemoveAadhaar,
                  onViewFull: _aadhaarImagePath != null
                      ? () => showDialog(
                            context: context,
                            builder: (_) => ImagePreviewDialog(
                              imageFile: _aadhaarImagePath!,
                              employeeName: _employee?.fullName ?? 'Aadhaar Card',
                            ),
                          )
                      : null,
                  isLoading: _isUploading,
                  isDesktop: isDesktop,
                ),
                const SizedBox(height: 24),
                _buildButtons(theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopForm(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 6,
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHeader(theme),
                      const Divider(height: 28),
                      _buildFields(theme),
                      const SizedBox(height: 24),
                      _buildButtons(theme),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              flex: 4,
              child: AadhaarUploadCard(
                currentImage: _aadhaarImagePath,
                employeeName: _nameCtrl.text.isNotEmpty ? _nameCtrl.text.trim() : 'Employee',
                onUpload: _handleAadhaarUpload,
                onReplace: _handleAadhaarUpload,
                onDelete: _handleRemoveAadhaar,
                onViewFull: _aadhaarImagePath != null
                    ? () => showDialog(
                          context: context,
                          builder: (_) => ImagePreviewDialog(
                            imageFile: _aadhaarImagePath!,
                            employeeName: _employee?.fullName ?? 'Aadhaar Card',
                          ),
                        )
                    : null,
                isLoading: _isUploading,
                isDesktop: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      children: [
        CircleAvatar(
          radius: 26,
          backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
          child: Icon(Icons.edit_outlined, color: theme.colorScheme.primary),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _employee?.employeeCode ?? 'Edit Employee',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const Text('Update employee record', style: TextStyle(fontSize: 13)),
          ],
        ),
      ],
    );
  }

  Widget _buildFields(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: _nameCtrl,
          decoration: const InputDecoration(
            labelText: 'Full Name *',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.person_outline),
          ),
          validator: (v) => Validators.required(v, 'Full Name'),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _designationCtrl,
          decoration: const InputDecoration(
            labelText: 'Designation *',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.work_outline),
          ),
          validator: (v) => Validators.required(v, 'Designation'),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _departmentCtrl,
          decoration: const InputDecoration(
            labelText: 'Department',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.business_outlined),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _salaryCtrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Monthly Salary (₹) *',
            prefixText: '₹ ',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.currency_rupee_outlined),
          ),
          validator: (v) => Validators.positiveNumber(v, 'Salary'),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _phoneCtrl,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'Phone',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.phone_outlined),
          ),
        ),
      ],
    );
  }

  Widget _buildButtons(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _isSaving ? null : () => context.pop(),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Cancel'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _isSaving ? null : _save,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: _isSaving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Save Changes', style: TextStyle(fontSize: 16)),
          ),
        ),
      ],
    );
  }
}
