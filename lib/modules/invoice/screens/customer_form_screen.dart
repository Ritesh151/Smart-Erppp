import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:smarterp/core/exceptions/app_exception.dart';
import 'package:smarterp/core/extensions/context_extensions.dart';
import 'package:smarterp/core/theme/theme_extensions.dart';
import 'package:smarterp/core/widgets/app_shell.dart';
import 'package:smarterp/core/widgets/app_card.dart';
import 'package:smarterp/core/widgets/app_text_field.dart';
import 'package:smarterp/modules/invoice/providers/customer_provider.dart';

class CustomerFormScreen extends StatefulWidget {
  final String? customerId;

  const CustomerFormScreen({super.key, this.customerId});

  @override
  State<CustomerFormScreen> createState() => _CustomerFormScreenState();
}

class _CustomerFormScreenState extends State<CustomerFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _gstController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _pincodeController;

  bool _isEditMode = false;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.customerId != null;

    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _addressController = TextEditingController();
    _gstController = TextEditingController();
    _cityController = TextEditingController();
    _stateController = TextEditingController();
    _pincodeController = TextEditingController();

    if (_isEditMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadCustomerData();
      });
    }
  }

  void _loadCustomerData() {
    final provider = context.read<CustomerProvider>();
    final customer = provider.customers.where((c) => c.id == widget.customerId).firstOrNull;
    if (customer != null) {
      _nameController.text = customer.name;
      _emailController.text = customer.email ?? '';
      _phoneController.text = customer.phone ?? '';
      _addressController.text = customer.address ?? '';
      _gstController.text = customer.gstNumber ?? '';
      _cityController.text = customer.city ?? '';
      _stateController.text = customer.state ?? '';
      _pincodeController.text = customer.pincode ?? '';
      _isActive = customer.isActive;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _gstController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return AppShell(
      child: Consumer<CustomerProvider>(
        builder: (context, provider, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isEditMode ? 'Edit Customer Details' : 'New Customer',
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Enter the customer information below',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Basic Information', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 16),
                        AppTextField(
                          controller: _nameController,
                          label: 'Customer Name *',
                          hint: 'Enter customer name',
                          prefixIcon: const Icon(Icons.person_outline),
                          validator: (v) => v == null || v.trim().isEmpty ? 'Name is required' : null,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: AppTextField(
                                controller: _phoneController,
                                label: 'Phone',
                                hint: 'Enter phone number',
                                prefixIcon: const Icon(Icons.phone_outlined),
                                keyboardType: TextInputType.phone,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: AppTextField(
                                controller: _emailController,
                                label: 'Email',
                                hint: 'Enter email address',
                                prefixIcon: const Icon(Icons.email_outlined),
                                keyboardType: TextInputType.emailAddress,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Address', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 16),
                        AppTextField(
                          controller: _addressController,
                          label: 'Address',
                          hint: 'Enter street address',
                          prefixIcon: const Icon(Icons.location_on_outlined),
                          maxLines: 2,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: AppTextField(
                                controller: _cityController,
                                label: 'City',
                                hint: 'Enter city',
                                prefixIcon: const Icon(Icons.business),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: AppTextField(
                                controller: _stateController,
                                label: 'State',
                                hint: 'Enter state',
                                prefixIcon: const Icon(Icons.map_outlined),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          controller: _pincodeController,
                          label: 'Pincode',
                          hint: 'Enter pincode',
                          prefixIcon: const Icon(Icons.markunread_mailbox_outlined),
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Tax Information', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 16),
                        AppTextField(
                          controller: _gstController,
                          label: 'GST Number',
                          hint: 'Enter GST number (e.g., 27ABCDE1234F1Z5)',
                          prefixIcon: const Icon(Icons.receipt_outlined),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 16),
                      FilledButton(
                        onPressed: provider.isLoading ? null : () => _saveCustomer(provider),
                        child: provider.isLoading
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                            : Text(_isEditMode ? 'Update Customer' : 'Add Customer'),
                      ),
                    ],
                  ),
                  if (provider.errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error),
                          const SizedBox(width: 8),
                          Expanded(child: Text(provider.errorMessage!, style: TextStyle(color: Theme.of(context).colorScheme.error))),
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

  Future<void> _saveCustomer(CustomerProvider provider) async {
    if (!_formKey.currentState!.validate()) return;

    try {
      if (_isEditMode) {
        await provider.updateCustomer(
          id: widget.customerId!,
          name: _nameController.text,
          email: _emailController.text.isNotEmpty ? _emailController.text : null,
          phone: _phoneController.text.isNotEmpty ? _phoneController.text : null,
          address: _addressController.text.isNotEmpty ? _addressController.text : null,
          gstNumber: _gstController.text.isNotEmpty ? _gstController.text : null,
          city: _cityController.text.isNotEmpty ? _cityController.text : null,
          state: _stateController.text.isNotEmpty ? _stateController.text : null,
          pincode: _pincodeController.text.isNotEmpty ? _pincodeController.text : null,
          isActive: _isActive,
        );
      } else {
        await provider.createCustomer(
          name: _nameController.text,
          email: _emailController.text.isNotEmpty ? _emailController.text : null,
          phone: _phoneController.text.isNotEmpty ? _phoneController.text : null,
          address: _addressController.text.isNotEmpty ? _addressController.text : null,
          gstNumber: _gstController.text.isNotEmpty ? _gstController.text : null,
          city: _cityController.text.isNotEmpty ? _cityController.text : null,
          state: _stateController.text.isNotEmpty ? _stateController.text : null,
          pincode: _pincodeController.text.isNotEmpty ? _pincodeController.text : null,
        );
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    } on ValidationException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: Theme.of(context).colorScheme.error),
      );
    } catch (e) {
      // Error already handled in provider
    }
  }
}
