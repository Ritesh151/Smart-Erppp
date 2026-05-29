// lib/Pages/Payroll/edit_employee_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:SmartERP/Providers/payroll_provider.dart';
import 'package:SmartERP/Utils/validators.dart';
import 'package:SmartERP/core/widgets/app_scaffold.dart';
import 'package:SmartERP/core/widgets/loading_widget.dart';

class EditEmployeeScreen extends ConsumerStatefulWidget {
  final String employeeId;
  const EditEmployeeScreen({super.key, required this.employeeId});

  @override
  ConsumerState<EditEmployeeScreen> createState() => _EditEmployeeScreenState();
}

class _EditEmployeeScreenState extends ConsumerState<EditEmployeeScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _designationCtrl;
  late TextEditingController _departmentCtrl;
  late TextEditingController _salaryCtrl;
  late TextEditingController _phoneCtrl;
  bool _initialized = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _designationCtrl = TextEditingController();
    _departmentCtrl = TextEditingController();
    _salaryCtrl = TextEditingController();
    _phoneCtrl = TextEditingController();
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

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      await ref.read(payrollControllerProvider).updateEmployee(
        widget.employeeId,
        {
          'fullName': _nameCtrl.text.trim(),
          'designation': _designationCtrl.text.trim(),
          'department': _departmentCtrl.text.trim().isEmpty
              ? null
              : _departmentCtrl.text.trim(),
          'monthlySalary': double.parse(_salaryCtrl.text),
          'salary': double.parse(_salaryCtrl.text),
          'phone': _phoneCtrl.text.trim().isEmpty
              ? null
              : _phoneCtrl.text.trim(),
        },
      );

      ref.invalidate(employeesStreamProvider);

      if (!mounted) return;
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          icon: const Icon(Icons.check_circle, color: Colors.green, size: 50),
          title: const Text('Employee Updated'),
          content: const Text('Employee details have been updated successfully.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );

      if (!mounted) return;
      context.go('/payroll');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update employee'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final employeesAsync = ref.watch(employeesStreamProvider);

    return employeesAsync.when(
      loading: () =>
          const AppScaffold(title: 'Edit Employee', body: LoadingWidget()),
      error: (e, _) => AppScaffold(
          title: 'Edit Employee', body: Center(child: Text('Error: $e'))),
      data: (employees) {
        final employee = employees
            .where((e) => e.id == widget.employeeId)
            .firstOrNull;

        if (employee == null) {
          return const AppScaffold(
            title: 'Edit Employee',
            body: Center(child: Text('Employee not found')),
          );
        }

        // Populate controllers once
        if (!_initialized) {
          _nameCtrl.text = employee.fullName;
          _designationCtrl.text = employee.designation;
          _departmentCtrl.text = employee.department ?? '';
          _salaryCtrl.text = employee.salary.toStringAsFixed(0);
          _phoneCtrl.text = employee.phone ?? '';
          _initialized = true;
        }

        return AppScaffold(
          title: 'Edit Employee',
          showBackButton: true,
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header info
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 26,
                            child: Text(
                              employee.fullName[0].toUpperCase(),
                              style: const TextStyle(fontSize: 22),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                employee.employeeCode ?? employee.id,
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600),
                              ),
                              const Text('Editing employee record',
                                  style: TextStyle(fontSize: 13)),
                            ],
                          ),
                        ],
                      ),
                      const Divider(height: 28),

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
                        validator: (v) =>
                            Validators.required(v, 'Designation'),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _departmentCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Department (optional)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.business_outlined),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _salaryCtrl,
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Monthly Salary (₹) *',
                          prefixText: '₹ ',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.currency_rupee_outlined),
                        ),
                        validator: (v) =>
                            Validators.positiveNumber(v, 'Salary'),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _phoneCtrl,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Phone (optional)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.phone_outlined),
                        ),
                        validator: Validators.phone,
                      ),
                      const SizedBox(height: 28),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed:
                                  _isSaving ? null : () => context.pop(),
                              style: OutlinedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _isSaving ? null : _save,
                              style: ElevatedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                              child: _isSaving
                                  ? const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white),
                                        ),
                                        SizedBox(width: 12),
                                        Text('Saving...',
                                            style: TextStyle(fontSize: 16)),
                                      ],
                                    )
                                  : const Text('Save Changes',
                                      style: TextStyle(fontSize: 16)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
