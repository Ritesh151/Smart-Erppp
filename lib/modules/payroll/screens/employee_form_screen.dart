import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:smarterp/core/exceptions/app_exception.dart';
import 'package:smarterp/core/extensions/context_extensions.dart';
import 'package:smarterp/core/widgets/app_shell.dart';
import 'package:smarterp/core/widgets/app_card.dart';
import 'package:smarterp/core/models/employee_model.dart';
import 'package:smarterp/modules/payroll/providers/employee_provider.dart';

class EmployeeFormScreen extends StatefulWidget {
  final String? employeeId;

  const EmployeeFormScreen({super.key, this.employeeId});

  @override
  State<EmployeeFormScreen> createState() => _EmployeeFormScreenState();
}

class _EmployeeFormScreenState extends State<EmployeeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _designationController = TextEditingController();
  final _salaryController = TextEditingController();
  final _bankAccountController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _ifscController = TextEditingController();
  final _panController = TextEditingController();
  final _aadharController = TextEditingController();

  String _selectedDepartment = 'General';
  EmploymentType _employmentType = EmploymentType.fullTime;
  EmployeeStatus _status = EmployeeStatus.active;
  DateTime _dateOfJoining = DateTime.now();
  DateTime? _dateOfBirth;
  bool _isSaving = false;
  bool _isEditMode = false;

  final List<String> _departments = [
    'General', 'Administration', 'Finance', 'HR', 'IT',
    'Marketing', 'Operations', 'Sales', 'Transport',
  ];

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.employeeId != null;
    if (_isEditMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadEmployee();
      });
    }
  }

  void _loadEmployee() {
    final provider = context.read<EmployeeProvider>();
    final employee = provider.employees.where((e) => e.id == widget.employeeId).firstOrNull;
    if (employee == null) return;

    _firstNameController.text = employee.firstName;
    _lastNameController.text = employee.lastName;
    _emailController.text = employee.email;
    _phoneController.text = employee.phone;
    _addressController.text = employee.address ?? '';
    _designationController.text = employee.designation;
    _salaryController.text = employee.salary.toStringAsFixed(2);
    _selectedDepartment = employee.department;
    _employmentType = employee.employmentType;
    _status = employee.status;
    _dateOfJoining = employee.dateOfJoining;
    _dateOfBirth = employee.dateOfBirth;
    _bankAccountController.text = employee.bankAccountNumber ?? '';
    _bankNameController.text = employee.bankName ?? '';
    _ifscController.text = employee.ifscCode ?? '';
    _panController.text = employee.panNumber ?? '';
    _aadharController.text = employee.aadharNumber ?? '';
    setState(() {});
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _designationController.dispose();
    _salaryController.dispose();
    _bankAccountController.dispose();
    _bankNameController.dispose();
    _ifscController.dispose();
    _panController.dispose();
    _aadharController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final theme = context.theme;

    return AppShell(
      child: Consumer<EmployeeProvider>(
        builder: (context, provider, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isEditMode ? 'Edit Employee' : 'Add Employee',
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _isEditMode ? 'Update employee information' : 'Fill in the employee details below',
                    style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 24),
                  _buildPersonalInfoSection(context),
                  const SizedBox(height: 16),
                  _buildEmploymentSection(context),
                  const SizedBox(height: 16),
                  _buildBankInfoSection(context),
                  const SizedBox(height: 24),
                  _buildActions(context, provider),
                  if (provider.errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: colorScheme.error),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(provider.errorMessage!, style: TextStyle(color: colorScheme.error)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPersonalInfoSection(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Personal Information', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(labelText: 'First Name *', hintText: 'First name', border: OutlineInputBorder()),
                textCapitalization: TextCapitalization.words,
                validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
              )),
              const SizedBox(width: 12),
              Expanded(child: TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(labelText: 'Last Name *', hintText: 'Last name', border: OutlineInputBorder()),
                textCapitalization: TextCapitalization.words,
                validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
              )),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email *', hintText: 'email@example.com', border: OutlineInputBorder()),
                keyboardType: TextInputType.emailAddress,
                validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
              )),
              const SizedBox(width: 12),
              Expanded(child: TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone *', hintText: 'Phone number', border: OutlineInputBorder()),
                keyboardType: TextInputType.phone,
                validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
              )),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _addressController,
            decoration: const InputDecoration(labelText: 'Address', hintText: 'Full address', border: OutlineInputBorder()),
            maxLines: 2,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _datePickerField(
                label: 'Date of Birth',
                value: _dateOfBirth,
                onPicked: (d) => setState(() => _dateOfBirth = d),
              )),
              const SizedBox(width: 12),
              Expanded(child: _datePickerField(
                label: 'Date of Joining *',
                value: _dateOfJoining,
                onPicked: (d) => setState(() => _dateOfJoining = d),
              )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmploymentSection(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Employment Details', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: TextFormField(
                controller: _designationController,
                decoration: const InputDecoration(labelText: 'Designation *', hintText: 'e.g. Software Engineer', border: OutlineInputBorder()),
                textCapitalization: TextCapitalization.words,
                validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
              )),
              const SizedBox(width: 12),
              Expanded(child: DropdownButtonFormField<String>(
                value: _selectedDepartment,
                decoration: const InputDecoration(labelText: 'Department *', border: OutlineInputBorder()),
                items: _departments.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                onChanged: (v) => setState(() => _selectedDepartment = v!),
              )),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: TextFormField(
                controller: _salaryController,
                decoration: const InputDecoration(labelText: 'Salary *', prefixText: '₹ ', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Required';
                  if (double.tryParse(v.trim()) == null || double.parse(v.trim()) <= 0) return 'Invalid salary';
                  return null;
                },
              )),
              const SizedBox(width: 12),
              Expanded(child: DropdownButtonFormField<EmploymentType>(
                value: _employmentType,
                decoration: const InputDecoration(labelText: 'Employment Type', border: OutlineInputBorder()),
                items: EmploymentType.values.map((t) => DropdownMenuItem(value: t, child: Text(t.name))).toList(),
                onChanged: (v) => setState(() => _employmentType = v!),
              )),
            ],
          ),
          if (_isEditMode) ...[
            const SizedBox(height: 12),
            DropdownButtonFormField<EmployeeStatus>(
              value: _status,
              decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
              items: EmployeeStatus.values.map((s) => DropdownMenuItem(value: s, child: Text(s.name))).toList(),
              onChanged: (v) => setState(() => _status = v!),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBankInfoSection(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Bank & Identity Details', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: TextFormField(
                controller: _bankAccountController,
                decoration: const InputDecoration(labelText: 'Bank Account', border: OutlineInputBorder()),
              )),
              const SizedBox(width: 12),
              Expanded(child: TextFormField(
                controller: _bankNameController,
                decoration: const InputDecoration(labelText: 'Bank Name', border: OutlineInputBorder()),
                textCapitalization: TextCapitalization.words,
              )),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: TextFormField(
                controller: _ifscController,
                decoration: const InputDecoration(labelText: 'IFSC Code', border: OutlineInputBorder()),
                textCapitalization: TextCapitalization.characters,
              )),
              const SizedBox(width: 12),
              Expanded(child: TextFormField(
                controller: _panController,
                decoration: const InputDecoration(labelText: 'PAN Number', border: OutlineInputBorder()),
                textCapitalization: TextCapitalization.characters,
              )),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _aadharController,
            decoration: const InputDecoration(labelText: 'Aadhar Number', border: OutlineInputBorder()),
          ),
        ],
      ),
    );
  }

  Widget _datePickerField({
    required String label,
    required DateTime? value,
    required ValueChanged<DateTime> onPicked,
  }) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: DateTime(1950),
          lastDate: DateTime(2030),
        );
        if (picked != null) onPicked(picked);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.calendar_today),
          border: const OutlineInputBorder(),
        ),
        child: Text(
          value != null ? '${value.day}/${value.month}/${value.year}' : 'Not set',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context, EmployeeProvider provider) {
    return Row(
      children: [
        OutlinedButton(
          onPressed: () => GoRouter.of(context).pop(),
          child: const Text('Cancel'),
        ),
        const SizedBox(width: 12),
        FilledButton(
          onPressed: _isSaving ? null : () => _handleSave(provider),
          child: _isSaving
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : Text(_isEditMode ? 'Update Employee' : 'Add Employee'),
        ),
      ],
    );
  }

  Future<void> _handleSave(EmployeeProvider provider) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final salary = double.parse(_salaryController.text.trim());

      if (_isEditMode) {
        await provider.updateEmployee(
          id: widget.employeeId!,
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
          department: _selectedDepartment,
          designation: _designationController.text.trim(),
          dateOfJoining: _dateOfJoining,
          dateOfBirth: _dateOfBirth,
          salary: salary,
          employmentType: _employmentType,
          status: _status,
          bankAccountNumber: _bankAccountController.text.trim().isEmpty ? null : _bankAccountController.text.trim(),
          bankName: _bankNameController.text.trim().isEmpty ? null : _bankNameController.text.trim(),
          ifscCode: _ifscController.text.trim().isEmpty ? null : _ifscController.text.trim(),
          panNumber: _panController.text.trim().isEmpty ? null : _panController.text.trim(),
          aadharNumber: _aadharController.text.trim().isEmpty ? null : _aadharController.text.trim(),
        );
      } else {
        await provider.createEmployee(
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
          department: _selectedDepartment,
          designation: _designationController.text.trim(),
          dateOfJoining: _dateOfJoining,
          dateOfBirth: _dateOfBirth,
          salary: salary,
          employmentType: _employmentType,
          bankAccountNumber: _bankAccountController.text.trim().isEmpty ? null : _bankAccountController.text.trim(),
          bankName: _bankNameController.text.trim().isEmpty ? null : _bankNameController.text.trim(),
          ifscCode: _ifscController.text.trim().isEmpty ? null : _ifscController.text.trim(),
          panNumber: _panController.text.trim().isEmpty ? null : _panController.text.trim(),
          aadharNumber: _aadharController.text.trim().isEmpty ? null : _aadharController.text.trim(),
        );
      }

      if (context.mounted) {
        context.showSnackBar(_isEditMode ? 'Employee updated successfully' : 'Employee created successfully');
        GoRouter.of(context).pop();
      }
    } on ValidationException catch (e) {
      if (context.mounted) {
        context.showSnackBar(e.message, isError: true);
      }
    } catch (e) {
      if (context.mounted) {
        context.showSnackBar('Failed to save employee: $e', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
