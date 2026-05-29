import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:SmartERP/core/constants/app_constants.dart';
import 'package:SmartERP/core/extensions/context_extensions.dart';
import 'package:SmartERP/core/models/customer_model.dart';
import 'package:SmartERP/core/routes/app_routes.dart';
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
  static const textMid = Color(0xFF374151);
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

  static BoxDecoration card({double radius = 16}) => BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E2A6E).withOpacity(0.06),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      );
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
  bool _isSaving = false;

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
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(context.isMobile ? 16 : 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFormHeader(context)
                    .animate()
                    .fadeIn(duration: 280.ms)
                    .slideX(begin: -0.04, end: 0),
                SizedBox(height: context.isMobile ? 18 : 24),
                if (context.isDesktop)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 5,
                        child: _buildContactInfoCard(context)
                            .animate()
                            .fadeIn(delay: 80.ms, duration: 280.ms)
                            .slideY(begin: 0.08, end: 0),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        flex: 5,
                        child: Column(
                          children: [
                            _buildAddressCard(context)
                                .animate()
                                .fadeIn(delay: 120.ms, duration: 280.ms)
                                .slideY(begin: 0.08, end: 0),
                            const SizedBox(height: 18),
                            _buildStatusCard(context)
                                .animate()
                                .fadeIn(delay: 160.ms, duration: 280.ms)
                                .slideY(begin: 0.08, end: 0),
                          ],
                        ),
                      ),
                    ],
                  )
                else
                  Column(
                    children: [
                      _buildContactInfoCard(context)
                          .animate()
                          .fadeIn(delay: 80.ms, duration: 280.ms)
                          .slideY(begin: 0.08, end: 0),
                      const SizedBox(height: 18),
                      _buildAddressCard(context)
                          .animate()
                          .fadeIn(delay: 120.ms, duration: 280.ms)
                          .slideY(begin: 0.08, end: 0),
                      const SizedBox(height: 18),
                      _buildStatusCard(context)
                          .animate()
                          .fadeIn(delay: 160.ms, duration: 280.ms)
                          .slideY(begin: 0.08, end: 0),
                    ],
                  ),
                SizedBox(height: context.isMobile ? 24 : 30),
                _buildActionButtons(context)
                    .animate()
                    .fadeIn(delay: 200.ms, duration: 280.ms)
                    .slideY(begin: 0.08, end: 0),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildFormHeader(BuildContext context) {
    final modeBadge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: _T.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _T.divider),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E2A6E).withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: _isEditMode ? _T.warning : _T.success,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _isEditMode ? 'Editing Mode' : 'New Customer',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: _T.textDark,
            ),
          ),
        ],
      ),
    );

    final titleBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _isEditMode ? 'Update Customer' : 'Create Customer',
          style: TextStyle(
            fontSize: context.isMobile ? 22 : 28,
            fontWeight: FontWeight.w800,
            color: _T.textDark,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          _isEditMode
              ? 'Modify customer contact and address details.'
              : 'Enter customer information and contact details.',
          style: const TextStyle(fontSize: 13, color: _T.textMuted),
        ),
      ],
    );

    return LayoutBuilder(builder: (context, constraints) {
      final isNarrow = constraints.maxWidth < 620;

      if (isNarrow) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _IconBtn(icon: Icons.arrow_back_rounded, onTap: () => context.pop()),
                const SizedBox(width: 14),
                Expanded(child: titleBlock),
              ],
            ),
            const SizedBox(height: 16),
            modeBadge,
          ],
        );
      }

      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _IconBtn(icon: Icons.arrow_back_rounded, onTap: () => context.pop()),
          const SizedBox(width: 16),
          Expanded(child: titleBlock),
          const SizedBox(width: 16),
          modeBadge,
        ],
      );
    });
  }

  // ── Contact info card ─────────────────────────────────────────────────────
  Widget _buildContactInfoCard(BuildContext context) {
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
              if (value == null || value.trim().isEmpty) {
                return 'Customer name is required';
              }
              if (value.trim().length < 2) {
                return 'Name must be at least 2 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
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
          const SizedBox(height: 16),
          AppTextField(
            controller: _phoneController,
            label: 'Phone',
            hintText: 'e.g. 9876543210',
            prefixIcon: const Icon(Icons.phone_rounded),
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value != null &&
                  value.isNotEmpty &&
                  !RegExp(r'^\d{6,15}$').hasMatch(value)) {
                return 'Enter a valid phone number (digits only)';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
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

  // ── Address card ──────────────────────────────────────────────────────────
  Widget _buildAddressCard(BuildContext context) {
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
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 520;
              if (isNarrow) {
                return Column(
                  children: [
                    AppTextField(
                      controller: _cityController,
                      label: 'City',
                      hintText: 'e.g. Mumbai',
                      prefixIcon: const Icon(Icons.location_city_rounded),
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _stateController,
                      label: 'State',
                      hintText: 'e.g. Maharashtra',
                      prefixIcon: const Icon(Icons.map_rounded),
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _pincodeController,
                      label: 'Pincode',
                      hintText: 'e.g. 400001',
                      prefixIcon:
                          const Icon(Icons.markunread_mailbox_rounded),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value != null &&
                            value.isNotEmpty &&
                            !RegExp(r'^\d{5,10}$').hasMatch(value)) {
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
                  const SizedBox(width: 16),
                  Expanded(
                    child: AppTextField(
                      controller: _stateController,
                      label: 'State',
                      hintText: 'e.g. Maharashtra',
                      prefixIcon: const Icon(Icons.map_rounded),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: AppTextField(
                      controller: _pincodeController,
                      label: 'Pincode',
                      hintText: 'e.g. 400001',
                      prefixIcon:
                          const Icon(Icons.markunread_mailbox_rounded),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value != null &&
                            value.isNotEmpty &&
                            !RegExp(r'^\d{5,10}$').hasMatch(value)) {
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

  // ── Status card ───────────────────────────────────────────────────────────
  Widget _buildStatusCard(BuildContext context) {
    final activeColor = _isActive ? _T.success : _T.warning;

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
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: activeColor.withOpacity(0.06),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: activeColor.withOpacity(0.18)),
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: activeColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _isActive
                        ? Icons.check_circle_outline_rounded
                        : Icons.pause_circle_outline_rounded,
                    color: activeColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 180),
                        child: Text(
                          _isActive ? 'Customer Active' : 'Customer Inactive',
                          key: ValueKey(_isActive),
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: _T.textDark,
                          ),
                        ),
                      ),
                      const SizedBox(height: 3),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 180),
                        child: Text(
                          _isActive
                              ? 'Visible in customer listings'
                              : 'Hidden from listings',
                          key: ValueKey('sub_$_isActive'),
                          style: const TextStyle(
                              fontSize: 11, color: _T.textMuted),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Switch(
                  value: _isActive,
                  onChanged: (value) => setState(() => _isActive = value),
                  activeColor: _T.gradientStart,
                  activeTrackColor: _T.gradientStart.withOpacity(0.25),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          // Status hint row
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: activeColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _isActive
                    ? 'This customer will appear in invoices and reports.'
                    : 'This customer will be hidden from all listings.',
                style: const TextStyle(fontSize: 11, color: _T.textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Action buttons ────────────────────────────────────────────────────────
  Widget _buildActionButtons(BuildContext context) {
    final provider = context.read<CustomerProvider>();

    return LayoutBuilder(builder: (context, constraints) {
      final isNarrow = constraints.maxWidth < 520;

      final cancelBtn = SizedBox(
        height: 52,
        child: AppButton(
          text: 'Cancel',
          variant: AppButtonVariant.outline,
          onPressed: () => context.pop(),
        ),
      );

      final submitBtn = Container(
        decoration: BoxDecoration(
          gradient: _isSaving ? null : _T.brandGradient,
          color: _isSaving ? Colors.grey.shade400 : null,
          borderRadius:
              BorderRadius.circular(AppConstants.defaultBorderRadius),
          boxShadow: _isSaving
              ? null
              : [
                  BoxShadow(
                    color: _T.gradientStart.withOpacity(0.28),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        child: SizedBox(
          height: 52,
          child: AppButton(
            text: _isEditMode ? 'Update Customer' : 'Create Customer',
            variant: AppButtonVariant.primary,
            isLoading: _isSaving,
            onPressed: _isSaving ? null : () => _submitForm(provider),
          ),
        ),
      );

      if (isNarrow) {
        return Column(
          children: [
            submitBtn,
            const SizedBox(height: 12),
            cancelBtn,
          ],
        );
      }

      return Row(
        children: [
          Expanded(child: cancelBtn),
          const SizedBox(width: 16),
          Expanded(child: submitBtn),
        ],
      );
    });
  }

  // ── Section header ────────────────────────────────────────────────────────
  Widget _buildSectionHeader({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: _T.brandGradient,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: _T.gradientStart.withOpacity(0.25),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: _T.textDark)),
              const SizedBox(height: 2),
              Text(subtitle,
                  style:
                      const TextStyle(fontSize: 11, color: _T.textMuted)),
            ],
          ),
        ),
      ],
    );
  }

  // ── Submit ────────────────────────────────────────────────────────────────
  Future<void> _submitForm(CustomerProvider provider) async {
    if (_isSaving) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final name = _nameController.text.trim();
      final email = _emailController.text.trim().isEmpty
          ? null
          : _emailController.text.trim();
      final phone = _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim();
      final address = _addressController.text.trim().isEmpty
          ? null
          : _addressController.text.trim();
      final gstNumber = _gstController.text.trim().isEmpty
          ? null
          : _gstController.text.trim();
      final city = _cityController.text.trim().isEmpty
          ? null
          : _cityController.text.trim();
      final state = _stateController.text.trim().isEmpty
          ? null
          : _stateController.text.trim();
      final pincode = _pincodeController.text.trim().isEmpty
          ? null
          : _pincodeController.text.trim();

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
          _isEditMode
              ? 'Customer updated successfully'
              : 'Customer created successfully',
        );
        context.go(AppRoutes.customers);
      }
    } catch (e) {
      if (mounted) {
        context.showSnackBar('Failed to save customer: $e', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}

// ── Reusable icon button ───────────────────────────────────────────────────
class _IconBtn extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _IconBtn({required this.icon, required this.onTap});

  @override
  State<_IconBtn> createState() => _IconBtnState();
}

class _IconBtnState extends State<_IconBtn> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: _hovered ? _T.gradientStart.withOpacity(0.06) : _T.white,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(
              color: _hovered
                  ? _T.gradientStart.withOpacity(0.3)
                  : _T.divider,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1E2A6E).withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            widget.icon,
            color: _hovered ? _T.gradientStart : _T.textDark,
            size: 20,
          ),
        ),
      ),
    );
  }
}
