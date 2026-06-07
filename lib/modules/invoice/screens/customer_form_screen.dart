import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:siddhivinayak_enterprise/core/extensions/context_extensions.dart';
import 'package:siddhivinayak_enterprise/core/models/customer_model.dart';
import 'package:siddhivinayak_enterprise/modules/invoice/providers/customer_provider.dart';

class _T {
  static const gradientStart = Color(0xFF6366F1);
  static const gradientEnd = Color(0xFF7C3AED);
  static const bg = Color(0xFFF8FAFC);
  static const white = Colors.white;
  static const border = Color(0xFFE2E8F0);
  static const textPrimary = Color(0xFF0F172A);
  static const textSecondary = Color(0xFF475569);
  static const textTertiary = Color(0xFF94A3B8);
  static const textDisabled = Color(0xFFCBD5E1);
  static const success = Color(0xFF10B981);
  static const danger = Color(0xFFF43F5E);
  static const indigo50 = Color(0xFFEEF2FF);
  static const indigo100 = Color(0xFFE0E7FF);

  static const Gradient brandGradient = LinearGradient(
    colors: [gradientStart, gradientEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
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
    final isMobile = context.isMobile;

    return Scaffold(
      backgroundColor: _T.bg,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(isMobile ? 16 : 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                SizedBox(height: isMobile ? 24 : 28),
                if (isMobile) _buildMobileLayout() else _buildDesktopLayout(),
                SizedBox(height: isMobile ? 24 : 28),
                _buildActionButtons(),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: [
              _buildContactInfoCard(),
              const SizedBox(height: 20),
              _buildAddressCard(),
            ],
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            children: [
              _buildGstLocationCard(),
              const SizedBox(height: 20),
              _buildStatusCard(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        _buildContactInfoCard(),
        const SizedBox(height: 16),
        _buildGstLocationCard(),
        const SizedBox(height: 16),
        _buildAddressCard(),
        const SizedBox(height: 16),
        _buildStatusCard(),
      ],
    );
  }

  Widget _buildHeader() {
    final title = _isEditMode ? 'Edit Customer' : 'Add Customer';
    final subtitle = _isEditMode
        ? 'Modify customer contact and location details'
        : 'Enter customer information and contact details';

    return Row(
      children: [
        _BackButton(onTap: () => context.pop()),
        const SizedBox(width: 14),
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: _T.brandGradient,
            borderRadius: BorderRadius.circular(12),
          ),
          child:
              const Icon(Icons.person_rounded, color: Colors.white, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: _T.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 13,
                  color: _T.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContactInfoCard() {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            icon: Icons.person_rounded,
            title: 'Contact Information',
            subtitle: 'Basic customer contact details',
          ),
          const SizedBox(height: 20),
          _responsiveGrid(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: _inputDecoration(
                  label: 'Name',
                  hint: 'e.g. ABC Enterprises',
                  required: true,
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Customer name is required';
                  }
                  if (v.trim().length < 2) {
                    return 'Name must be at least 2 characters';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _emailController,
                decoration: _inputDecoration(
                  label: 'Email',
                  hint: 'e.g. contact@abc.com',
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v != null && v.isNotEmpty) {
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v)) {
                      return 'Enter a valid email address';
                    }
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _phoneController,
                decoration: _inputDecoration(
                  label: 'Phone',
                  hint: 'e.g. 9876543210',
                ),
                keyboardType: TextInputType.phone,
                validator: (v) {
                  if (v != null &&
                      v.isNotEmpty &&
                      !RegExp(r'^\d{6,15}$').hasMatch(v)) {
                    return 'Enter a valid phone number (digits only)';
                  }
                  return null;
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGstLocationCard() {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            icon: Icons.receipt_rounded,
            title: 'GST & Location',
            subtitle: 'Tax and address details',
          ),
          const SizedBox(height: 20),
          _responsiveGrid(
            children: [
              TextFormField(
                controller: _gstController,
                decoration: _inputDecoration(
                  label: 'GST Number',
                  hint: 'e.g. 27AABCU9603R1ZX',
                ),
              ),
              TextFormField(
                controller: _cityController,
                decoration: _inputDecoration(
                  label: 'City',
                  hint: 'e.g. Mumbai',
                ),
              ),
              TextFormField(
                controller: _stateController,
                decoration: _inputDecoration(
                  label: 'State',
                  hint: 'e.g. Maharashtra',
                ),
              ),
              TextFormField(
                controller: _pincodeController,
                decoration: _inputDecoration(
                  label: 'Pincode',
                  hint: 'e.g. 400001',
                ),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v != null &&
                      v.isNotEmpty &&
                      !RegExp(r'^\d{5,10}$').hasMatch(v)) {
                    return 'Enter a valid pincode';
                  }
                  return null;
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard() {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            icon: Icons.location_on_rounded,
            title: 'Address',
            subtitle: 'Full customer address',
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _addressController,
            decoration: _inputDecoration(
              label: 'Address',
              hint: 'e.g. 123, Main Street, Landmark',
            ),
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            icon: Icons.toggle_on_rounded,
            title: 'Status',
            subtitle: 'Customer account visibility',
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _isActive
                  ? _T.success.withOpacity(0.08)
                  : _T.textDisabled.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color:
                    _isActive ? _T.success.withOpacity(0.2) : _T.border,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _isActive
                      ? Icons.check_circle_rounded
                      : Icons.cancel_rounded,
                  color: _isActive ? _T.success : _T.textTertiary,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isActive ? 'Active' : 'Inactive',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: _T.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _isActive
                            ? 'Visible in customer listings and invoices'
                            : 'Hidden from all listings',
                        style: const TextStyle(
                          fontSize: 11,
                          color: _T.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _isActive,
                  onChanged: (v) => setState(() => _isActive = v),
                  activeColor: _T.gradientStart,
                  activeTrackColor: _T.gradientStart.withOpacity(0.25),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    final provider = context.read<CustomerProvider>();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 520;

        final cancelButton = OutlinedButton(
          onPressed: () => context.pop(),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            side: const BorderSide(color: _T.border),
            backgroundColor: _T.white,
          ),
          child: const Text(
            'Cancel',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: _T.textSecondary,
            ),
          ),
        );

        final saveButton = Container(
          decoration: BoxDecoration(
            gradient: _T.brandGradient,
            borderRadius: BorderRadius.circular(12),
            boxShadow: _isSaving
                ? null
                : [
                    BoxShadow(
                      color: _T.gradientStart.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isSaving ? null : () => _submitForm(provider),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isSaving
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      _isEditMode ? 'Save Changes' : 'Create Customer',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        );

        if (isNarrow) {
          return Column(
            children: [
              saveButton,
              const SizedBox(height: 12),
              cancelButton,
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: cancelButton),
            const SizedBox(width: 16),
            Expanded(child: saveButton),
          ],
        );
      },
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            gradient: _T.brandGradient,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: _T.textPrimary,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: _T.textTertiary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _responsiveGrid({required List<Widget> children, int columns = 2}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 520;
        if (!isWide || columns <= 1) {
          return Column(
            children: children.asMap().entries.map((e) {
              return Padding(
                padding: EdgeInsets.only(
                  bottom: e.key < children.length - 1 ? 16 : 0,
                ),
                child: e.value,
              );
            }).toList(),
          );
        }

        final rows = <List<Widget>>[];
        for (var i = 0; i < children.length; i += columns) {
          rows.add(
            children.sublist(i, (i + columns).clamp(0, children.length)),
          );
        }

        return Column(
          children: rows.map((row) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: rows.last == row ? 0 : 16,
              ),
              child: Row(
                children: () {
                  final tiles = <Widget>[];
                  for (var i = 0; i < row.length; i++) {
                    if (i > 0) tiles.add(const SizedBox(width: 16));
                    tiles.add(Expanded(child: row[i]));
                  }
                  return tiles;
                }(),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    bool required = false,
  }) {
    return InputDecoration(
      labelText: required ? '$label *' : label,
      hintText: hint,
      filled: true,
      fillColor: _T.white,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _T.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _T.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _T.gradientStart, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _T.danger),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _T.danger, width: 1.5),
      ),
      labelStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: _T.textSecondary,
      ),
      hintStyle: const TextStyle(
        fontSize: 14,
        color: _T.textDisabled,
      ),
    );
  }

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
        context.pop();
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

class _Card extends StatelessWidget {
  final Widget child;

  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _T.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _T.border),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _BackButton extends StatefulWidget {
  final VoidCallback onTap;

  const _BackButton({required this.onTap});

  @override
  State<_BackButton> createState() => _BackButtonState();
}

class _BackButtonState extends State<_BackButton> {
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
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _hovered ? _T.indigo50 : _T.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: _hovered ? _T.indigo100 : _T.border,
            ),
          ),
          child: Icon(
            Icons.arrow_back_rounded,
            size: 20,
            color: _hovered ? _T.gradientStart : _T.textPrimary,
          ),
        ),
      ),
    );
  }
}
