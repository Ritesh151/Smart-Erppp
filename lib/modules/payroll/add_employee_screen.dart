import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import 'package:siddhivinayak_enterprise/core/extensions/context_extensions.dart';
import 'package:siddhivinayak_enterprise/core/models/employee_model.dart';
import 'package:siddhivinayak_enterprise/core/responsive/breakpoints.dart';
import 'package:siddhivinayak_enterprise/core/responsive/responsive_builder.dart';
import 'package:siddhivinayak_enterprise/core/utils/logger.dart';
import 'package:siddhivinayak_enterprise/Utils/validators.dart';
import 'package:siddhivinayak_enterprise/core/widgets/app_scaffold.dart';
import 'package:siddhivinayak_enterprise/modules/payroll/providers/employee_provider.dart';
import 'package:siddhivinayak_enterprise/modules/payroll/utils/image_helper.dart';
import 'package:siddhivinayak_enterprise/modules/payroll/widgets/aadhaar_upload_card.dart';

class AddEmployeeScreen extends StatefulWidget {
  const AddEmployeeScreen({super.key});

  @override
  State<AddEmployeeScreen> createState() => _AddEmployeeScreenState();
}

class _AddEmployeeScreenState extends State<AddEmployeeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _designationCtrl = TextEditingController();
  final _departmentCtrl = TextEditingController();
  final _salaryCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  bool _isSaving = false;

  String? _aadhaarImagePath;
  bool _isUploading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _designationCtrl.dispose();
    _departmentCtrl.dispose();
    _salaryCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleAadhaarUpload() async {
    try {
      setState(() => _isUploading = true);
      final path = await ImageHelper.pickImage();
      if (path != null && mounted) {
        setState(() => _aadhaarImagePath = path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick image: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final now = DateTime.now();
      final employeeId = const Uuid().v4();
      final name = _nameCtrl.text.trim();

      final employee = EmployeeModel(
        id: employeeId,
        employeeCode: 'EMP-${(now.millisecondsSinceEpoch % 100000).toString().padLeft(5, '0')}',
        firstName: name,
        lastName: '',
        email: _emailCtrl.text.trim().isEmpty
            ? '${name.toLowerCase().replaceAll(' ', '.')}@company.com'
            : _emailCtrl.text.trim(),
        phone: _phoneCtrl.text.trim().isEmpty ? '' : _phoneCtrl.text.trim(),
        department: _departmentCtrl.text.trim().isEmpty ? 'General' : _departmentCtrl.text.trim(),
        designation: _designationCtrl.text.trim(),
        dateOfJoining: now,
        salary: double.parse(_salaryCtrl.text),
        employmentType: EmploymentType.fullTime,
        status: EmployeeStatus.active,
        aadhaarImagePath: _aadhaarImagePath,
        createdAt: now,
        updatedAt: now,
      );

      final provider = context.read<EmployeeProvider>();
      final success = await provider.addEmployee(employee);

      if (success && _aadhaarImagePath != null && mounted) {
        await provider.uploadAadhaarImage(
          employeeId: employeeId,
          filePath: _aadhaarImagePath!,
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$name added successfully'),
          backgroundColor: Colors.green,
        ),
      );
      context.go('/payroll');
    } catch (e, stackTrace) {
      Logger.error('Failed to save employee', e, stackTrace);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add employee: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final deviceType = context.deviceType;
    final isDesktopLayout = deviceType == DeviceType.desktop || deviceType == DeviceType.largeDesktop;

    return AppScaffold(
      title: 'Add Employee',
      body: ResponsiveBuilder(
        mobile: _buildMobileLayout(theme, false),
        tablet: _buildMobileLayout(theme, false),
        desktop: _buildDesktopLayout(theme),
        largeDesktop: _buildDesktopLayout(theme),
        builder: (context, _) => _buildMobileLayout(theme, isDesktopLayout),
      ),
    );
  }

  Widget _buildMobileLayout(ThemeData theme, bool isDesktop) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildFormCard(theme, isDesktop),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 6,
              child: _buildFormFields(theme),
            ),
            const SizedBox(width: 24),
            Expanded(
              flex: 4,
              child: Column(
                children: [
                  AadhaarUploadCard(
                    currentImage: _aadhaarImagePath,
                    employeeName: _nameCtrl.text.isNotEmpty ? _nameCtrl.text.trim() : 'Employee',
                    onUpload: _handleAadhaarUpload,
                    onReplace: _handleAadhaarUpload,
                    onDelete: () => setState(() => _aadhaarImagePath = null),
                    onViewFull: _aadhaarImagePath != null
                        ? () => showDialog(
                              context: context,
                              builder: (_) => ImagePreviewDialog(
                                imageFile: _aadhaarImagePath!,
                                employeeName: 'Aadhaar Card',
                              ),
                            )
                        : null,
                    isLoading: _isUploading,
                    isDesktop: true,
                  ),
                  const SizedBox(height: 16),
                  _buildActionButtons(theme, true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormCard(ThemeData theme, bool isDesktop) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                  child: Icon(Icons.person_add_outlined, color: theme.colorScheme.primary),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('New Employee', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text('Fill in employee details', style: TextStyle(fontSize: 13, color: Colors.grey)),
                  ],
                ),
              ],
            ),
            const Divider(height: 28),
            _buildFormFields(theme),
            const SizedBox(height: 24),
            AadhaarUploadCard(
              currentImage: _aadhaarImagePath,
              employeeName: _nameCtrl.text.isNotEmpty ? _nameCtrl.text.trim() : 'Employee',
              onUpload: _handleAadhaarUpload,
              onReplace: _handleAadhaarUpload,
              onDelete: () => setState(() => _aadhaarImagePath = null),
              onViewFull: _aadhaarImagePath != null
                  ? () => showDialog(
                        context: context,
                        builder: (_) => ImagePreviewDialog(
                          imageFile: _aadhaarImagePath!,
                          employeeName: 'Aadhaar Card',
                        ),
                      )
                  : null,
              isLoading: _isUploading,
              isDesktop: isDesktop,
            ),
            const SizedBox(height: 24),
            _buildActionButtons(theme, isDesktop),
          ],
        ),
      ),
    );
  }

  Widget _buildFormFields(ThemeData theme) {
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
        const SizedBox(height: 16),
        TextFormField(
          controller: _emailCtrl,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Email',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.email_outlined),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(ThemeData theme, bool isDesktop) {
    return Row(
      children: [
        Expanded(
            child: OutlinedButton(
              onPressed: _isSaving ? null : () => context.pop(),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: isDesktop ? 14 : 16),
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
                padding: EdgeInsets.symmetric(vertical: isDesktop ? 14 : 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            child: _isSaving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Add Employee', style: TextStyle(fontSize: 16)),
          ),
        ),
      ],
    );
  }
}

class ImagePreviewDialog extends StatelessWidget {
  final String imageFile;
  final String? employeeName;

  const ImagePreviewDialog({super.key, required this.imageFile, this.employeeName});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      backgroundColor: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.fingerprint_rounded),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    employeeName ?? 'Aadhaar Card',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          ClipRRect(
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
            child: Image(
              image: ImageHelper.getImageProvider(imageFile) ?? AssetImage('assets/images/placeholder.png') as ImageProvider,
              fit: BoxFit.contain,
              height: MediaQuery.of(context).size.height * 0.6,
              width: double.infinity,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 300,
                color: Colors.grey.shade200,
                child: const Center(
                  child: Icon(Icons.broken_image_rounded, size: 64, color: Colors.grey),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
