import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:SmartERP/core/constants/app_constants.dart';
import 'package:SmartERP/core/extensions/context_extensions.dart';
import 'package:SmartERP/core/models/customer_model.dart';
import 'package:SmartERP/core/theme/theme_extensions.dart';
import 'package:SmartERP/core/widgets/app_button.dart';
import 'package:SmartERP/core/widgets/app_text_field.dart';
import 'package:SmartERP/modules/invoice/providers/customer_provider.dart';

class _T {
  static const gradientStart = Color(0xFF4F6EF7);
  static const gradientEnd = Color(0xFF7C3AED);

  static const bg = Color(0xFFF5F7FA);
  static const white = Colors.white;

  static const textDark = Color(0xFF111827);
  static const textMuted = Color(0xFF6B7280);
  static const textLight = Color(0xFF9CA3AF);

  static const divider = Color(0xFFE5E7EB);

  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFF59E0B);
  static const danger = Color(0xFFEF4444);

  static const Gradient brandGradient = LinearGradient(
    colors: [gradientStart, gradientEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static BoxDecoration card({double radius = 18}) {
    return BoxDecoration(
      color: white,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: divider.withOpacity(0.8)),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF1E2A6E).withOpacity(0.06),
          blurRadius: 18,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }
}

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
        _loadExistingCustomer();
      });
    }
  }

  void _loadExistingCustomer() {
    final provider = context.read<CustomerProvider>();
    final customer = provider.customers.firstWhere(
      (c) => c.id == widget.customerId,
      orElse: () => CustomerModel(
        id: '',
        name: '',
        isActive: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );

    if (customer.id.isNotEmpty) {
      setState(() {
        _nameController.text = customer.name;
        _emailController.text = customer.email ?? '';
        _phoneController.text = customer.phone ?? '';
        _addressController.text = customer.address ?? '';
        _gstController.text = customer.gstNumber ?? '';
        _cityController.text = customer.city ?? '';
        _stateController.text = customer.state ?? '';
        _pincodeController.text = customer.pincode ?? '';
        _isActive = customer.isActive;
      });
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
    return Container(
      color: _T.bg,
      child: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(context.isMobile ? 16 : 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFormHeader(context)
                    .animate()
                    .fadeIn(duration: 260.ms)
                    .slideX(begin: -0.05, end: 0),
                SizedBox(height: context.isMobile ? 18 : 24),
                if (context.isDesktop)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 5,
                        child: _buildContactInfoCard(),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        flex: 5,
                        child: Column(
                          children: [
                            _buildAddressCard(),
                            const SizedBox(height: 18),
                            _buildStatusCard(),
                          ],
                        ),
                      ),
                    ],
                  )
                else
                  Column(
                    children: [
                      _buildContactInfoCard(),
                      const SizedBox(height: 18),
                      _buildAddressCard(),
                      const SizedBox(height: 18),
                      _buildStatusCard(),
                    ],
                  ),
                const SizedBox(height: 30),
                _buildActionButtons(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormHeader(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final vertical = constraints.maxWidth < 620;
        if (vertical) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => context.pop(),
                    child: Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: _T.divider),
                      ),
                      child: const Icon(Icons.arrow_back_rounded, color: _T.textDark),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isEditMode ? 'Update Customer' : 'Create Customer',
                          style: TextStyle(
                            fontSize: context.isMobile ? 24 : 28,
                            fontWeight: FontWeight.w800,
                            color: _T.textDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _isEditMode
                              ? 'Modify customer contact and address details.'
                              : 'Enter customer information and contact details.',
                          style: const TextStyle(fontSize: 13, color: _T.textMuted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _T.divider),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(color: _T.success, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isEditMode ? 'Editing Mode' : 'New Customer',
                      style: const TextStyle(fontWeight: FontWeight.w700, color: _T.textDark),
                    ),
                  ],
                ),
              ),
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Row(
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => context.pop(),
                    child: Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: _T.divider),
                      ),
                      child: const Icon(Icons.arrow_back_rounded, color: _T.textDark),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isEditMode ? 'Update Customer' : 'Create Customer',
                          style: TextStyle(
                            fontSize: context.isMobile ? 24 : 28,
                            fontWeight: FontWeight.w800,
                            color: _T.textDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _isEditMode
                              ? 'Modify customer contact and address details.'
                              : 'Enter customer information and contact details.',
                          style: const TextStyle(fontSize: 13, color: _T.textMuted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 18),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _T.divider),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(color: _T.success, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isEditMode ? 'Editing Mode' : 'New Customer',
                    style: const TextStyle(fontWeight: FontWeight.w700, color: _T.textDark),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildContactInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _T.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            title: 'Contact Information',
            subtitle: 'Basic customer contact details',
            icon: Icons.person_rounded,
          ),
          const SizedBox(height: 22),
          AppTextField(
            controller: _nameController,
            label: 'Customer Name *',
            hintText: 'e.g. ABC Enterprises',
            prefixIcon: const Icon(Icons.business_rounded),
            validator: (value) {
              if (value == null || value.trim().isEmpty) return 'Customer name is required';
              if (value.trim().length < 2) return 'Name must be at least 2 characters';
              return null;
            },
          ),
          const SizedBox(height: 18),
          AppTextField(
            controller: _emailController,
            label: 'Email',
            hintText: 'e.g. contact@abc.com',
            prefixIcon: const Icon(Icons.email_outlined),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                  return 'Enter a valid email address';
                }
              }
              return null;
            },
          ),
          const SizedBox(height: 18),
          AppTextField(
            controller: _phoneController,
            label: 'Phone',
            hintText: 'e.g. 9876543210',
            prefixIcon: const Icon(Icons.phone_rounded),
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value != null && value.isNotEmpty && !RegExp(r'^\d{6,15}$').hasMatch(value)) {
                return 'Enter a valid phone number (digits only)';
              }
              return null;
            },
          ),
          const SizedBox(height: 18),
          AppTextField(
            controller: _gstController,
            label: 'GST Number',
            hintText: 'e.g. 27AABCU9603R1ZX',
            prefixIcon: const Icon(Icons.receipt_rounded),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _T.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            title: 'Address Details',
            subtitle: 'Customer location and address information',
            icon: Icons.location_on_rounded,
          ),
          const SizedBox(height: 22),
          AppTextField(
            controller: _addressController,
            label: 'Address',
            hintText: 'e.g. 123, Main Street',
            prefixIcon: const Icon(Icons.home_outlined),
            maxLines: 3,
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final vertical = constraints.maxWidth < 600;
              if (vertical) {
                return Column(
                  children: [
                    AppTextField(
                      controller: _cityController,
                      label: 'City',
                      hintText: 'e.g. Mumbai',
                      prefixIcon: const Icon(Icons.location_city_rounded),
                    ),
                    const SizedBox(height: 18),
                    AppTextField(
                      controller: _stateController,
                      label: 'State',
                      hintText: 'e.g. Maharashtra',
                      prefixIcon: const Icon(Icons.map_rounded),
                    ),
                    const SizedBox(height: 18),
                    AppTextField(
                      controller: _pincodeController,
                      label: 'Pincode',
                      hintText: 'e.g. 400001',
                      prefixIcon: const Icon(Icons.markunread_mailbox_rounded),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value != null && value.isNotEmpty && !RegExp(r'^\d{5,10}$').hasMatch(value)) {
                          return 'Enter a valid pincode';
                        }
                        return null;
                      },
                    ),
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      controller: _cityController,
                      label: 'City',
                      hintText: 'e.g. Mumbai',
                      prefixIcon: const Icon(Icons.location_city_rounded),
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: AppTextField(
                      controller: _stateController,
                      label: 'State',
                      hintText: 'e.g. Maharashtra',
                      prefixIcon: const Icon(Icons.map_rounded),
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: AppTextField(
                      controller: _pincodeController,
                      label: 'Pincode',
                      hintText: 'e.g. 400001',
                      prefixIcon: const Icon(Icons.markunread_mailbox_rounded),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value != null && value.isNotEmpty && !RegExp(r'^\d{5,10}$').hasMatch(value)) {
                          return 'Enter a valid pincode';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _T.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            title: 'Account Status',
            subtitle: 'Customer account visibility',
            icon: Icons.toggle_on_rounded,
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _isActive ? _T.success.withOpacity(0.06) : _T.warning.withOpacity(0.06),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: (_isActive ? _T.success : _T.warning).withOpacity(0.15),
              ),
            ),
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                _isActive ? 'Customer Active' : 'Customer Inactive',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Text(
                _isActive ? 'Visible in customer listings' : 'Hidden from listings',
              ),
              value: _isActive,
              onChanged: (value) => setState(() => _isActive = value),
              activeColor: _T.gradientStart,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final provider = context.read<CustomerProvider>();

    return LayoutBuilder(
      builder: (context, constraints) {
        final vertical = constraints.maxWidth < 520;
        if (vertical) {
          return Column(
            children: [
              SizedBox(
                height: 54,
                child: AppButton(
                  text: 'Cancel',
                  variant: AppButtonVariant.outline,
                  onPressed: () => context.pop(),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  gradient: _T.brandGradient,
                  borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                  boxShadow: [
                    BoxShadow(
                      color: _T.gradientStart.withOpacity(0.22),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: SizedBox(
                  height: 54,
                  child: AppButton(
                    text: _isEditMode ? 'Update Customer' : 'Create Customer',
                    variant: AppButtonVariant.primary,
                    onPressed: () => _submitForm(provider),
                  ),
                ),
              ),
            ],
          );
        }
        return Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 54,
                child: AppButton(
                  text: 'Cancel',
                  variant: AppButtonVariant.outline,
                  onPressed: () => context.pop(),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  gradient: _T.brandGradient,
                  borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                  boxShadow: [
                    BoxShadow(
                      color: _T.gradientStart.withOpacity(0.22),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: SizedBox(
                  height: 54,
                  child: AppButton(
                    text: _isEditMode ? 'Update Customer' : 'Create Customer',
                    variant: AppButtonVariant.primary,
                    onPressed: () => _submitForm(provider),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            gradient: _T.brandGradient,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: _T.textDark)),
              const SizedBox(height: 2),
              Text(subtitle, style: const TextStyle(fontSize: 11, color: _T.textMuted)),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _submitForm(CustomerProvider provider) async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final name = _nameController.text.trim();
      final email = _emailController.text.trim().isEmpty ? null : _emailController.text.trim();
      final phone = _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim();
      final address = _addressController.text.trim().isEmpty ? null : _addressController.text.trim();
      final gstNumber = _gstController.text.trim().isEmpty ? null : _gstController.text.trim();
      final city = _cityController.text.trim().isEmpty ? null : _cityController.text.trim();
      final state = _stateController.text.trim().isEmpty ? null : _stateController.text.trim();
      final pincode = _pincodeController.text.trim().isEmpty ? null : _pincodeController.text.trim();

      if (_isEditMode) {
        await provider.updateCustomer(
          id: widget.customerId!,
          name: name,
          email: email,
          phone: phone,
          address: address,
          gstNumber: gstNumber,
          city: city,
          state: state,
          pincode: pincode,
          isActive: _isActive,
        );
      } else {
        await provider.createCustomer(
          name: name,
          email: email,
          phone: phone,
          address: address,
          gstNumber: gstNumber,
          city: city,
          state: state,
          pincode: pincode,
        );
      }

      if (mounted) {
        context.showSnackBar(
          _isEditMode ? 'Customer updated successfully' : 'Customer created successfully',
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        context.showSnackBar('Failed to save customer: $e', isError: true);
      }
    }
  }
}
