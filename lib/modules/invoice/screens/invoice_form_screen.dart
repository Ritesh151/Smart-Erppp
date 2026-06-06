import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:siddhivinayak_enterprise/core/constants/app_constants.dart';
import 'package:siddhivinayak_enterprise/core/extensions/context_extensions.dart';
import 'package:siddhivinayak_enterprise/core/models/invoice_item_model.dart';
import 'package:siddhivinayak_enterprise/core/models/invoice_model.dart';
import 'package:siddhivinayak_enterprise/core/models/product_model.dart';
import 'package:siddhivinayak_enterprise/core/widgets/app_button.dart';
import 'package:siddhivinayak_enterprise/core/widgets/app_text_field.dart';
import 'package:siddhivinayak_enterprise/core/widgets/product_selector_dialog.dart';
import 'package:siddhivinayak_enterprise/modules/invoice/providers/customer_provider.dart';
import 'package:siddhivinayak_enterprise/modules/invoice/providers/invoice_provider.dart';
import 'package:siddhivinayak_enterprise/modules/products/providers/product_provider.dart';

// ── Shared brand tokens (mirrors dashboard_screen.dart) ──────────────────────
class _T {
  static const gradientStart = Color(0xFF4F6EF7);
  static const gradientEnd   = Color(0xFF7C3AED);
  static const bg            = Color(0xFFF5F7FA);
  static const white         = Colors.white;
  static const textDark      = Color(0xFF111827);
  static const textMid       = Color(0xFF374151);
  static const textMuted     = Color(0xFF6B7280);
  static const textLight     = Color(0xFF9CA3AF);
  static const divider       = Color(0xFFE5E7EB);
  static const success       = Color(0xFF10B981);
  static const warning       = Color(0xFFF59E0B);
  static const danger        = Color(0xFFEF4444);

  static const Gradient brandGradient = LinearGradient(
    colors: [gradientStart, gradientEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static BoxDecoration card({double radius = 16}) => BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: divider, width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E2A6E).withOpacity(0.06),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      );

  static InputDecoration inputDecoration(String label, IconData icon) =>
      InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 13, color: textMuted),
        filled: true,
        fillColor: white,
        prefixIcon: Icon(icon, size: 18, color: textMuted),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: gradientStart, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: danger, width: 1.5),
        ),
      );
}

class InvoiceFormScreen extends StatefulWidget {
  const InvoiceFormScreen({super.key});

  @override
  State<InvoiceFormScreen> createState() => _InvoiceFormScreenState();
}

class _InvoiceFormScreenState extends State<InvoiceFormScreen> {
  final _formKey          = GlobalKey<FormState>();
  final _notesController  = TextEditingController();
  final _termsController  = TextEditingController();
  final _customPaymentNotesController = TextEditingController();
  final _bankNameController = TextEditingController(text: 'Indian Bank');
  final _branchNameController = TextEditingController(text: 'Usmanpura');
  final _ifscCodeController = TextEditingController(text: 'IDIB000A666');
  final _accountNumberController = TextEditingController(text: '7648102905');

  bool    _isEditMode       = false;
  String? _editInvoiceId;
  String? _editInvoiceNumber;
  bool    _isSaving         = false;

  // ── Lifecycle ──────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final pathParams = GoRouterState.of(context).pathParameters;
      final id         = pathParams['id'];

      context.read<ProductProvider>().loadProducts();

      if (id != null && id.isNotEmpty) {
        setState(() {
          _isEditMode    = true;
          _editInvoiceId = id;
        });
        _loadInvoiceForEdit(id);
      } else {
        context.read<InvoiceProvider>().resetEditingState();
        _bankNameController.text = 'Indian Bank';
        _branchNameController.text = 'Usmanpura';
        _ifscCodeController.text = 'IDIB000A666';
        _accountNumberController.text = '7648102905';
      }

      context.read<CustomerProvider>().loadCustomers();
    });
  }

  Future<void> _loadInvoiceForEdit(String id) async {
    final provider = context.read<InvoiceProvider>();
    await provider.loadInvoiceDetails(id);
    if (!mounted) return;
    final invoice = provider.selectedInvoice;
    if (invoice != null && invoice.id.isNotEmpty) {
      provider.populateEditingFromInvoice(
        invoice,
        items: provider.selectedInvoiceItems,
      );
      setState(() => _editInvoiceNumber = invoice.invoiceNumber);
      _notesController.text = invoice.notes ?? '';
      _termsController.text = invoice.termsAndConditions ?? '';
      _bankNameController.text = invoice.bankName ?? 'Indian Bank';
      _branchNameController.text = invoice.branchName ?? 'Usmanpura';
      _ifscCodeController.text = invoice.ifscCode ?? 'IDIB000A666';
      _accountNumberController.text = invoice.accountNumber ?? '7648102905';
      _customPaymentNotesController.text = invoice.customPaymentNotes ?? '';
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    _termsController.dispose();
    _customPaymentNotesController.dispose();
    _bankNameController.dispose();
    _branchNameController.dispose();
    _ifscCodeController.dispose();
    _accountNumberController.dispose();
    super.dispose();
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final pad = context.isMobile ? 16.0 : 24.0;
    final gap = context.isMobile ? 16.0 : 20.0;

    return Container(
      color: _T.bg,
      child: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(pad),
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context)
                    .animate()
                    .fadeIn(duration: 350.ms)
                    .slideX(begin: -0.04, end: 0),

                SizedBox(height: gap),

                if (context.isDesktop)
                  _buildDesktopLayout(gap)
                else
                  _buildMobileLayout(gap),

                SizedBox(height: gap + 8),
                _buildActionButtons(context),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Desktop two-column layout ──────────────────────────────────────────────
  Widget _buildDesktopLayout(double gap) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 5,
          child: Column(
            children: [
              _buildCustomerCard().animate().fadeIn(delay: 60.ms, duration: 300.ms).slideY(begin: 0.06, end: 0),
              SizedBox(height: gap),
              _buildDateCard().animate().fadeIn(delay: 100.ms, duration: 300.ms).slideY(begin: 0.06, end: 0),
              SizedBox(height: gap),
              _buildPaymentTermsCard().animate().fadeIn(delay: 110.ms, duration: 300.ms).slideY(begin: 0.06, end: 0),
              SizedBox(height: gap),
              _buildInternalChargesCard().animate().fadeIn(delay: 115.ms, duration: 300.ms).slideY(begin: 0.06, end: 0),
            ],
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          flex: 7,
          child: Column(
            children: [
              _buildItemsCard().animate().fadeIn(delay: 80.ms, duration: 300.ms).slideY(begin: 0.06, end: 0),
              SizedBox(height: gap),
              _buildTotalsCard().animate().fadeIn(delay: 120.ms, duration: 300.ms).slideY(begin: 0.06, end: 0),
              SizedBox(height: gap),
              _buildBankDetailsCard().animate().fadeIn(delay: 140.ms, duration: 300.ms).slideY(begin: 0.06, end: 0),
              SizedBox(height: gap),
              _buildNotesCard().animate().fadeIn(delay: 160.ms, duration: 300.ms).slideY(begin: 0.06, end: 0),
            ],
          ),
        ),
      ],
    );
  }

  // ── Mobile single-column layout ────────────────────────────────────────────
  Widget _buildMobileLayout(double gap) {
    return Column(
      children: [
        _buildCustomerCard().animate().fadeIn(delay: 60.ms, duration: 280.ms).slideY(begin: 0.06, end: 0),
        SizedBox(height: gap),
        _buildDateCard().animate().fadeIn(delay: 90.ms, duration: 280.ms).slideY(begin: 0.06, end: 0),
        SizedBox(height: gap),
        _buildPaymentTermsCard().animate().fadeIn(delay: 100.ms, duration: 280.ms).slideY(begin: 0.06, end: 0),
        SizedBox(height: gap),
        _buildInternalChargesCard().animate().fadeIn(delay: 110.ms, duration: 280.ms).slideY(begin: 0.06, end: 0),
        SizedBox(height: gap),
        _buildItemsCard().animate().fadeIn(delay: 120.ms, duration: 280.ms).slideY(begin: 0.06, end: 0),
        SizedBox(height: gap),
        _buildTotalsCard().animate().fadeIn(delay: 150.ms, duration: 280.ms).slideY(begin: 0.06, end: 0),
        SizedBox(height: gap),
        _buildBankDetailsCard().animate().fadeIn(delay: 170.ms, duration: 280.ms).slideY(begin: 0.06, end: 0),
        SizedBox(height: gap),
        _buildNotesCard().animate().fadeIn(delay: 180.ms, duration: 280.ms).slideY(begin: 0.06, end: 0),
      ],
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    final backBtn = _BackButton(onTap: () => context.pop());

    final titleBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _isEditMode ? 'Update Invoice' : 'Create Invoice',
          style: TextStyle(
            fontSize: context.isMobile ? 22 : 26,
            fontWeight: FontWeight.w800,
            color: _T.textDark,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          _isEditMode
              ? 'Modify invoice details and line items.'
              : 'Enter customer and billing information.',
          style: const TextStyle(fontSize: 13, color: _T.textMuted),
        ),
      ],
    );

    final editBadge = _isEditMode
        ? Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: _T.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _T.divider),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1E2A6E).withOpacity(0.05),
                  blurRadius: 10,
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
                  decoration: const BoxDecoration(
                    color: _T.success,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Editing: ${_editInvoiceNumber ?? '—'}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: _T.textDark,
                  ),
                ),
              ],
            ),
          )
        : null;

    if (context.isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              backBtn,
              const SizedBox(width: 14),
              Expanded(child: titleBlock),
            ],
          ),
          if (editBadge != null) ...[
            const SizedBox(height: 12),
            editBadge,
          ],
        ],
      );
    }

    return Row(
      children: [
        backBtn,
        const SizedBox(width: 16),
        Expanded(child: titleBlock),
        if (editBadge != null) editBadge,
      ],
    );
  }

  // ── Customer card ──────────────────────────────────────────────────────────
  Widget _buildCustomerCard() {
    return Consumer2<CustomerProvider, InvoiceProvider>(
      builder: (context, customerProvider, provider, _) {
        return _CardShell(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionHeader(
                title: 'Customer Information',
                subtitle: 'Select or enter customer details',
                icon: Icons.person_outline_rounded,
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: provider.editingCustomerId.isNotEmpty
                    ? provider.editingCustomerId
                    : null,
                borderRadius: BorderRadius.circular(16),
                decoration: _T.inputDecoration(
                    'Select Customer *', Icons.business_rounded),
                hint: const Text('Choose Customer',
                    style: TextStyle(color: _T.textLight, fontSize: 13)),
                validator: (v) =>
                    v == null ? 'Customer is required' : null,
                onChanged: (value) {
                  if (value != null) {
                    final customer = customerProvider.customers
                        .firstWhere((c) => c.id == value);
                    provider.setEditingCustomerId(customer.id);
                    provider.setEditingCustomerName(customer.name);
                    provider.setEditingCustomerEmail(customer.email ?? '');
                    provider.setEditingCustomerPhone(customer.phone ?? '');
                    provider.setEditingCustomerAddress(
                        customer.address ?? '');
                    provider.setEditingCustomerGst(
                        customer.gstNumber ?? '');
                  }
                },
                items: customerProvider.customers.map((c) {
                  return DropdownMenuItem(
                    value: c.id,
                    child: Text(c.name,
                        style: const TextStyle(
                            fontSize: 13, color: _T.textDark)),
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),
              _AddNewLink(
                label: 'Add New Customer',
                onTap: () => context.push('/customers/create'),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Date card ──────────────────────────────────────────────────────────────
  Widget _buildDateCard() {
    return Consumer<InvoiceProvider>(
      builder: (context, provider, _) {
        return _CardShell(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionHeader(
                title: 'Invoice Dates',
                subtitle: 'Set invoice and due dates',
                icon: Icons.calendar_month_rounded,
              ),
              const SizedBox(height: 20),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isNarrow = constraints.maxWidth < 480;
                  final invoiceField = _DatePickerField(
                    label: 'Invoice Date',
                    value: provider.editingInvoiceDate,
                    icon: Icons.event_rounded,
                    onTap: () => _pickDate(
                      context,
                      provider.editingInvoiceDate,
                      provider.setEditingInvoiceDate,
                    ),
                  );
                  final dueField = _DatePickerField(
                    label: 'Due Date',
                    value: provider.editingDueDate,
                    icon: Icons.event_note_rounded,
                    onTap: () => _pickDate(
                      context,
                      provider.editingDueDate,
                      provider.setEditingDueDate,
                    ),
                  );

                  if (isNarrow) {
                    return Column(
                      children: [
                        invoiceField,
                        const SizedBox(height: 14),
                        dueField,
                      ],
                    );
                  }
                  return Row(
                    children: [
                      Expanded(child: invoiceField),
                      const SizedBox(width: 14),
                      Expanded(child: dueField),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickDate(
    BuildContext context,
    DateTime current,
    ValueChanged<DateTime> onPicked,
  ) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context)
              .colorScheme
              .copyWith(primary: _T.gradientStart),
        ),
        child: child!,
      ),
    );
    if (picked != null) onPicked(picked);
  }

  // ── Payment Terms card ──────────────────────────────────────────────────────
  Widget _buildPaymentTermsCard() {
    return Consumer<InvoiceProvider>(
      builder: (context, provider, _) {
        return _CardShell(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionHeader(
                title: 'Payment Terms',
                subtitle: 'Set payment due conditions',
                icon: Icons.payment_rounded,
              ),
              const SizedBox(height: 20),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isNarrow = constraints.maxWidth < 480;
                  final daysField = TextFormField(
                    initialValue:
                        provider.editingPaymentDays > 0 ? provider.editingPaymentDays.toString() : '',
                    keyboardType: TextInputType.number,
                    style: const TextStyle(fontSize: 13, color: _T.textDark),
                    decoration: _T.inputDecoration('Days', Icons.calendar_today_rounded),
                    onChanged: (v) {
                      final val = int.tryParse(v) ?? 0;
                      provider.setEditingPaymentDays(val < 0 ? 0 : val);
                    },
                  );
                  final monthsField = TextFormField(
                    initialValue:
                        provider.editingPaymentMonths > 0 ? provider.editingPaymentMonths.toString() : '',
                    keyboardType: TextInputType.number,
                    style: const TextStyle(fontSize: 13, color: _T.textDark),
                    decoration: _T.inputDecoration('Months', Icons.date_range_rounded),
                    onChanged: (v) {
                      final val = int.tryParse(v) ?? 0;
                      provider.setEditingPaymentMonths(val < 0 ? 0 : val);
                    },
                  );

                  return Column(
                    children: [
                      if (isNarrow) ...[
                        daysField,
                        const SizedBox(height: 14),
                        monthsField,
                      ] else ...[
                        Row(
                          children: [
                            Expanded(child: daysField),
                            const SizedBox(width: 14),
                            Expanded(child: monthsField),
                          ],
                        ),
                      ],
                      if (provider.editingPaymentTermDescription.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                _T.gradientStart.withOpacity(0.05),
                                _T.gradientEnd.withOpacity(0.03),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: _T.gradientStart.withOpacity(0.12)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.info_outline_rounded,
                                  size: 16, color: _T.gradientStart),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  provider.editingPaymentTermDescription,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: _T.textDark,
                                    height: 1.5,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 14),
                      AppTextField(
                        controller: _customPaymentNotesController,
                        label: 'Custom Terms',
                        hintText: 'e.g. 50% advance payment required...',
                        prefixIcon: const Icon(Icons.edit_note_rounded),
                        maxLines: 3,
                        onChanged: (v) => provider.setEditingCustomPaymentNotes(v),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Internal Charges card ───────────────────────────────────────────────────
  Widget _buildInternalChargesCard() {
    return Consumer<InvoiceProvider>(
      builder: (context, provider, _) {
        final charges = provider.editingInternalCharges;
        return _CardShell(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _SectionHeader(
                      title: 'Internal Charges',
                      subtitle: 'Additional charges applicable to this invoice',
                      icon: Icons.monetization_on_rounded,
                    ),
                  ),
                  const SizedBox(width: 12),
                  _GradientButton(
                    label: 'Add Charge',
                    icon: Icons.add_rounded,
                    onTap: () => _showAddChargeDialog(context, provider),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Additional charges applicable to this invoice.',
                style: TextStyle(fontSize: 11, color: _T.textMuted),
              ),
              const SizedBox(height: 16),
              if (charges.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  decoration: BoxDecoration(
                    color: _T.gradientStart.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _T.divider),
                  ),
                  child: const Center(
                    child: Text(
                      'No internal charges added',
                      style: TextStyle(
                        color: _T.textMuted,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: charges.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, thickness: 1, color: _T.divider),
                  itemBuilder: (context, index) {
                    final charge = charges[index];
                    return _buildChargeRow(context, provider, charge, index);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChargeRow(
    BuildContext context,
    InvoiceProvider provider,
    InternalCharge charge,
    int index,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _T.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Icon(Icons.receipt_rounded,
                size: 16, color: _T.warning),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  charge.chargeName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: _T.textDark,
                  ),
                ),
                if (charge.chargeDescription != null &&
                    charge.chargeDescription!.trim().isNotEmpty)
                  Text(
                    charge.chargeDescription!,
                    style: const TextStyle(fontSize: 11, color: _T.textLight),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '₹${charge.chargeAmount.toStringAsFixed(2)}',
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 13,
              color: _T.textDark,
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () => _showEditChargeDialog(context, provider, index),
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: _T.gradientStart.withOpacity(0.07),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.edit_outlined,
                  size: 14, color: _T.gradientStart),
            ),
          ),
          const SizedBox(width: 6),
          InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () => provider.removeInternalCharge(index),
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: _T.danger.withOpacity(0.07),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.delete_outline_rounded,
                  size: 14, color: _T.danger),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddChargeDialog(
      BuildContext context, InvoiceProvider provider) async {
    final nameController = TextEditingController();
    final amountController = TextEditingController();
    final descriptionController = TextEditingController();
    String? validationError;

    return showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 420),
                decoration: BoxDecoration(
                  color: _T.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1E2A6E).withOpacity(0.12),
                      blurRadius: 40,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _T.gradientStart.withOpacity(0.05),
                            _T.gradientEnd.withOpacity(0.03),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(22)),
                        border: Border(bottom: BorderSide(color: _T.divider)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              gradient: _T.brandGradient,
                              borderRadius: BorderRadius.circular(11),
                              boxShadow: [
                                BoxShadow(
                                  color: _T.gradientStart.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Icon(Icons.add_card_rounded,
                                color: _T.white, size: 18),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Add Internal Charge',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: _T.textDark,
                                  ),
                                ),
                                const Text('Enter charge details',
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: _T.textMuted)),
                              ],
                            ),
                          ),
                          InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () => Navigator.pop(ctx),
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: _T.divider.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.close_rounded,
                                  size: 16, color: _T.textMuted),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppTextField(
                            controller: nameController,
                            label: 'Charge Name *',
                            hintText: 'e.g. Transportation, Packing...',
                            prefixIcon: const Icon(Icons.label_outline_rounded),
                          ),
                          const SizedBox(height: 14),
                          AppTextField(
                            controller: amountController,
                            label: 'Charge Amount *',
                            hintText: 'e.g. 500',
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            prefixIcon: const Icon(Icons.currency_rupee_rounded),
                          ),
                          const SizedBox(height: 14),
                          AppTextField(
                            controller: descriptionController,
                            label: 'Charge Description',
                            hintText: 'Optional description...',
                            prefixIcon: const Icon(Icons.description_outlined),
                            maxLines: 3,
                          ),
                          if (validationError != null) ...[
                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: _T.danger.withOpacity(0.07),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: _T.danger.withOpacity(0.15)),
                              ),
                              child: Text(
                                validationError!,
                                style: const TextStyle(
                                    color: _T.danger,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(ctx),
                              style: OutlinedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                foregroundColor: _T.textMuted,
                                side: const BorderSide(color: _T.divider),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: const Text('Cancel',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: _T.brandGradient,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: _T.gradientStart.withOpacity(0.28),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(14),
                                  onTap: () {
                                    final name = nameController.text.trim();
                                    final amountText = amountController.text.trim();
                                    final amount = double.tryParse(amountText);
                                    final description =
                                        descriptionController.text.trim();

                                    if (name.isEmpty) {
                                      setDialogState(() => validationError =
                                          'Charge name is required');
                                      return;
                                    }
                                    if (amount == null || amountText.isEmpty) {
                                      setDialogState(() => validationError =
                                          'Please enter a valid amount');
                                      return;
                                    }
                                    if (amount < 0) {
                                      setDialogState(() => validationError =
                                          'Amount cannot be negative');
                                      return;
                                    }
                                    if (amount.isNaN || amount.isInfinite) {
                                      setDialogState(() => validationError =
                                          'Invalid amount');
                                      return;
                                    }

                                    provider.addInternalCharge(
                                      name,
                                      amount,
                                      description.isNotEmpty ? description : null,
                                    );
                                    Navigator.pop(ctx);
                                  },
                                  child: const Padding(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 14),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.add_rounded,
                                            color: _T.white, size: 18),
                                        SizedBox(width: 6),
                                        Text(
                                          'Add Charge',
                                          style: TextStyle(
                                            color: _T.white,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showEditChargeDialog(
      BuildContext context, InvoiceProvider provider, int index) async {
    final charge = provider.editingInternalCharges[index];
    final nameController = TextEditingController(text: charge.chargeName);
    final amountController =
        TextEditingController(text: charge.chargeAmount.toString());
    final descriptionController =
        TextEditingController(text: charge.chargeDescription ?? '');
    String? validationError;

    return showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 420),
                decoration: BoxDecoration(
                  color: _T.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1E2A6E).withOpacity(0.12),
                      blurRadius: 40,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _T.gradientStart.withOpacity(0.05),
                            _T.gradientEnd.withOpacity(0.03),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(22)),
                        border: Border(bottom: BorderSide(color: _T.divider)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              gradient: _T.brandGradient,
                              borderRadius: BorderRadius.circular(11),
                              boxShadow: [
                                BoxShadow(
                                  color: _T.gradientStart.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Icon(Icons.edit_rounded,
                                color: _T.white, size: 18),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Edit Internal Charge',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: _T.textDark,
                                  ),
                                ),
                                const Text('Update charge details',
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: _T.textMuted)),
                              ],
                            ),
                          ),
                          InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () => Navigator.pop(ctx),
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: _T.divider.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.close_rounded,
                                  size: 16, color: _T.textMuted),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppTextField(
                            controller: nameController,
                            label: 'Charge Name *',
                            hintText: 'e.g. Transportation, Packing...',
                            prefixIcon:
                                const Icon(Icons.label_outline_rounded),
                          ),
                          const SizedBox(height: 14),
                          AppTextField(
                            controller: amountController,
                            label: 'Charge Amount *',
                            hintText: 'e.g. 500',
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            prefixIcon:
                                const Icon(Icons.currency_rupee_rounded),
                          ),
                          const SizedBox(height: 14),
                          AppTextField(
                            controller: descriptionController,
                            label: 'Charge Description',
                            hintText: 'Optional description...',
                            prefixIcon:
                                const Icon(Icons.description_outlined),
                            maxLines: 3,
                          ),
                          if (validationError != null) ...[
                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: _T.danger.withOpacity(0.07),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: _T.danger.withOpacity(0.15)),
                              ),
                              child: Text(
                                validationError!,
                                style: const TextStyle(
                                    color: _T.danger,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(ctx),
                              style: OutlinedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                foregroundColor: _T.textMuted,
                                side: const BorderSide(color: _T.divider),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: const Text('Cancel',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: _T.brandGradient,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: _T.gradientStart.withOpacity(0.28),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(14),
                                  onTap: () {
                                    final name = nameController.text.trim();
                                    final amountText =
                                        amountController.text.trim();
                                    final amount = double.tryParse(amountText);
                                    final description =
                                        descriptionController.text.trim();

                                    if (name.isEmpty) {
                                      setDialogState(() => validationError =
                                          'Charge name is required');
                                      return;
                                    }
                                    if (amount == null || amountText.isEmpty) {
                                      setDialogState(() => validationError =
                                          'Please enter a valid amount');
                                      return;
                                    }
                                    if (amount < 0) {
                                      setDialogState(() => validationError =
                                          'Amount cannot be negative');
                                      return;
                                    }
                                    if (amount.isNaN || amount.isInfinite) {
                                      setDialogState(() => validationError =
                                          'Invalid amount');
                                      return;
                                    }

                                    provider.updateInternalCharge(
                                      index,
                                      name,
                                      amount,
                                      description.isNotEmpty ? description : null,
                                    );
                                    Navigator.pop(ctx);
                                  },
                                  child: const Padding(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 14),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.save_rounded,
                                            color: _T.white, size: 18),
                                        SizedBox(width: 6),
                                        Text(
                                          'Update Charge',
                                          style: TextStyle(
                                            color: _T.white,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ── Items card ─────────────────────────────────────────────────────────────
  Widget _buildItemsCard() {
    return Consumer<InvoiceProvider>(
      builder: (context, provider, _) {
        return _CardShell(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _SectionHeader(
                      title: 'Invoice Items',
                      subtitle: 'Add products and services',
                      icon: Icons.receipt_rounded,
                    ),
                  ),
                  const SizedBox(width: 12),
                  _GradientButton(
                    label: 'Add Item',
                    icon: Icons.add_rounded,
                    onTap: () => _showAddItemDialog(context, provider),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              if (provider.editingItems.isEmpty)
                _EmptyItemsPlaceholder()
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: provider.editingItems.length,
                  separatorBuilder: (_, __) => const Divider(
                      height: 1, thickness: 1, color: _T.divider),
                  itemBuilder: (context, index) {
                    final item = provider.editingItems[index];
                    return _buildItemRow(
                        context, provider, item, index)
                        .animate()
                        .fadeIn(duration: 200.ms)
                        .slideX(begin: 0.04, end: 0);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildItemRow(
    BuildContext context,
    InvoiceProvider provider,
    InvoiceItemModel item,
    int index,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product name + delete
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: _T.gradientStart.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(Icons.inventory_2_rounded,
                    size: 16, color: _T.gradientStart),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.productName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: _T.textDark,
                      ),
                    ),
                    if (item.hsnCode != null)
                      Text(
                        'HSN: ${item.hsnCode}  •  ${item.unit}',
                        style: const TextStyle(
                            fontSize: 11, color: _T.textLight),
                      ),
                  ],
                ),
              ),
              InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => provider.removeItem(index),
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: _T.danger.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.delete_outline_rounded,
                      size: 17, color: _T.danger),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Qty / Price / Amount fields
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 480;

              final qtyField = _ItemInputField(
                label: 'Qty',
                initialValue: item.quantity.toString(),
                icon: Icons.numbers_rounded,
                onChanged: (v) {
                  final qty = double.tryParse(v);
                  if (qty != null) provider.updateItemQuantity(index, qty);
                },
              );
              final priceField = _ItemInputField(
                label: 'Unit Price',
                initialValue: item.unitPrice.toString(),
                icon: Icons.currency_rupee_rounded,
                onChanged: (v) {
                  final price = double.tryParse(v);
                  if (price != null) provider.updateItemPrice(index, price);
                },
              );
              final amountField = _ItemReadonlyField(
                label: 'Amount',
                value: '₹${item.amount.toStringAsFixed(2)}',
              );

              if (isNarrow) {
                return Column(
                  children: [
                    qtyField,
                    const SizedBox(height: 10),
                    priceField,
                    const SizedBox(height: 10),
                    amountField,
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(child: qtyField),
                  const SizedBox(width: 10),
                  Expanded(child: priceField),
                  const SizedBox(width: 10),
                  Expanded(child: amountField),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // ── Add item dialog ────────────────────────────────────────────────────────
  Future<void> _showAddItemDialog(
      BuildContext context, InvoiceProvider provider) async {
    final product = await ProductSelectorDialog.show(context);
    if (product == null || !mounted) return;

    final qtyController      = TextEditingController(text: '1');
    final discountController = TextEditingController();
    final priceController    =
        TextEditingController(text: product.price.toString());

    return showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(
              horizontal: 20, vertical: 40),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 480),
            decoration: BoxDecoration(
              color: _T.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1E2A6E).withOpacity(0.12),
                  blurRadius: 40,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dialog header with gradient strip
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _T.gradientStart.withOpacity(0.05),
                        _T.gradientEnd.withOpacity(0.03),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(22)),
                    border: Border(
                        bottom: BorderSide(color: _T.divider)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          gradient: _T.brandGradient,
                          borderRadius: BorderRadius.circular(11),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  _T.gradientStart.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Icon(
                            Icons.add_shopping_cart_rounded,
                            color: _T.white,
                            size: 18),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.productName,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: _T.textDark,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const Text('Configure item details',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: _T.textMuted)),
                          ],
                        ),
                      ),
                      InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () => Navigator.pop(ctx),
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: _T.divider.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.close_rounded,
                              size: 16, color: _T.textMuted),
                        ),
                      ),
                    ],
                  ),
                ),

                // Dialog body
                SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // HSN info chip
                      if (product.hsnCode != null)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: _T.bg,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: _T.divider),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.qr_code_rounded,
                                  size: 14, color: _T.textMuted),
                              const SizedBox(width: 8),
                              Text(
                                'HSN: ${product.hsnCode}  •  Unit: ${product.unit}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: _T.textMuted,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (product.hsnCode != null)
                        const SizedBox(height: 10),

                      // Stock badge
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: product.isOutOfStock
                              ? const Color(0xFFFEF2F2)
                              : product.isLowStock
                                  ? const Color(0xFFFFFBEB)
                                  : const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: product.isOutOfStock
                                ? _T.danger.withOpacity(0.15)
                                : product.isLowStock
                                    ? _T.warning.withOpacity(0.15)
                                    : _T.success.withOpacity(0.15),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              product.isOutOfStock
                                  ? Icons.error_outline_rounded
                                  : product.isLowStock
                                      ? Icons.warning_amber_rounded
                                      : Icons.check_circle_outline_rounded,
                              size: 16,
                              color: product.isOutOfStock
                                  ? _T.danger
                                  : product.isLowStock
                                      ? _T.warning
                                      : _T.success,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Available Stock: ${product.stockQuantity} ${product.unit}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: product.isOutOfStock
                                    ? _T.danger
                                    : product.isLowStock
                                        ? _T.warning
                                        : _T.success,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      AppTextField(
                        controller: qtyController,
                        label: 'Quantity *',
                        hintText: '1',
                        keyboardType:
                            const TextInputType.numberWithOptions(
                                decimal: true),
                        prefixIcon:
                            const Icon(Icons.numbers_rounded),
                      ),
                      const SizedBox(height: 14),
                      AppTextField(
                        controller: priceController,
                        label: 'Unit Price *',
                        hintText: '0.00',
                        keyboardType:
                            const TextInputType.numberWithOptions(
                                decimal: true),
                        prefixIcon: const Icon(
                            Icons.currency_rupee_rounded),
                      ),
                      const SizedBox(height: 14),
                      AppTextField(
                        controller: discountController,
                        label: 'Discount Rate %',
                        hintText: 'e.g. 5',
                        keyboardType:
                            const TextInputType.numberWithOptions(
                                decimal: true),
                        prefixIcon:
                            const Icon(Icons.discount_rounded),
                      ),
                    ],
                  ),
                ),

                // Dialog actions
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                vertical: 14),
                            foregroundColor: _T.textMuted,
                            side: const BorderSide(color: _T.divider),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text('Cancel',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: _T.brandGradient,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: _T.gradientStart
                                    .withOpacity(0.28),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius:
                                  BorderRadius.circular(14),
                              onTap: () {
                                final qty = double.tryParse(
                                        qtyController.text) ??
                                    1;
                                final price = double.tryParse(
                                        priceController.text) ??
                                    product.price;

                                if (qty <= 0) {
                                  context.showSnackBar(
                                    'Quantity must be > 0',
                                    isError: true,
                                  );
                                  return;
                                }
                                if (qty > product.stockQuantity) {
                                  context.showSnackBar(
                                    'Insufficient stock. Available: ${product.stockQuantity}',
                                    isError: true,
                                  );
                                  return;
                                }
                                if (price <= 0) {
                                  context.showSnackBar(
                                    'Unit price must be > 0',
                                    isError: true,
                                  );
                                  return;
                                }

                                provider.addItem(
                                  productId: product.id,
                                  productName: product.productName,
                                  hsnCode: product.hsnCode,
                                  quantity: qty,
                                  unit: product.unit,
                                  unitPrice: price,
                                  taxRate: 18.0,
                                  discountRate: double.tryParse(
                                          discountController.text) ??
                                      0,
                                  imagePath: product.imagePath,
                                );

                                Navigator.pop(ctx);
                              },
                              child: const Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 14),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_rounded,
                                        color: _T.white, size: 18),
                                    SizedBox(width: 6),
                                    Text(
                                      'Add to Invoice',
                                      style: TextStyle(
                                        color: _T.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Totals card ────────────────────────────────────────────────────────────
  Widget _buildTotalsCard() {
    return Consumer<InvoiceProvider>(
      builder: (context, provider, _) {
        return _CardShell(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionHeader(
                title: 'Totals',
                subtitle: 'Invoice amount summary',
                icon: Icons.calculate_rounded,
              ),
              const SizedBox(height: 20),

              _TotalRow(label: 'Subtotal',
                  value: '₹${provider.editingSubtotal.toStringAsFixed(2)}'),
              const SizedBox(height: 8),
              _TotalRow(label: 'CGST @ 9%',
                  value: '₹${provider.editingCgstAmount.toStringAsFixed(2)}'),
              const SizedBox(height: 8),
              _TotalRow(label: 'SGST @ 9%',
                  value: '₹${provider.editingSgstAmount.toStringAsFixed(2)}'),
              const SizedBox(height: 8),
              _TotalRow(label: 'IGST @ 18%',
                  value: '₹${provider.editingIgstAmount.toStringAsFixed(2)}'),
              const SizedBox(height: 8),
              _TotalRow(label: 'Internal Charges',
                  value: '₹${provider.editingInternalChargesTotal.toStringAsFixed(2)}'),
              const SizedBox(height: 14),

              // Discount row
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: _T.warning.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: _T.warning.withOpacity(0.15)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.discount_rounded,
                        size: 17, color: _T.warning),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Discount',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: _T.textDark,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 110,
                      child: TextFormField(
                        initialValue:
                            provider.editingDiscount.toString(),
                        keyboardType:
                            const TextInputType.numberWithOptions(
                                decimal: true),
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _T.textDark,
                        ),
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding:
                              const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 9),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(10),
                            borderSide: const BorderSide(
                                color: _T.divider),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(10),
                            borderSide: const BorderSide(
                                color: _T.divider),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(10),
                            borderSide: const BorderSide(
                                color: _T.warning, width: 1.4),
                          ),
                          prefixText: '₹ ',
                          prefixStyle: const TextStyle(
                            color: _T.textMuted,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                        onChanged: (v) {
                          final d = double.tryParse(v) ?? 0;
                          provider.setEditingDiscount(d);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              _TotalRow(
                label: 'Round Off',
                value:
                    '₹${provider.editingRoundOff.toStringAsFixed(2)}',
              ),
              const SizedBox(height: 16),

              // Grand total banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  gradient: _T.brandGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: _T.gradientStart.withOpacity(0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.receipt_long_rounded,
                        color: Colors.white70, size: 20),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Grand Total',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    Text(
                      '₹${provider.editingGrandTotal.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        fontSize: 22,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Bank Details card ───────────────────────────────────────────────────────
  Widget _buildBankDetailsCard() {
    return Consumer<InvoiceProvider>(
      builder: (context, provider, _) {
        return _CardShell(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionHeader(
                title: 'Bank Details',
                subtitle: 'Your company bank account information',
                icon: Icons.account_balance_rounded,
              ),
              const SizedBox(height: 20),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isNarrow = constraints.maxWidth < 500;
                  final fields = <Widget>[
                    AppTextField(
                      controller: _bankNameController,
                      label: 'Bank Name *',
                      hintText: 'e.g. Indian Bank',
                      prefixIcon: const Icon(Icons.account_balance_outlined),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Bank name is required' : null,
                      onChanged: (v) => provider.setEditingBankName(v),
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      controller: _branchNameController,
                      label: 'Branch Name *',
                      hintText: 'e.g. Usmanpura',
                      prefixIcon: const Icon(Icons.location_on_outlined),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Branch name is required' : null,
                      onChanged: (v) => provider.setEditingBranchName(v),
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      controller: _ifscCodeController,
                      label: 'IFSC Code *',
                      hintText: 'e.g. IDIB000A666',
                      prefixIcon: const Icon(Icons.qr_code_rounded),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'IFSC code is required';
                        final ifsc = v.trim().toUpperCase();
                        if (!RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$').hasMatch(ifsc)) {
                          return 'Invalid IFSC format (e.g. IDIB000A666)';
                        }
                        return null;
                      },
                      onChanged: (v) => provider.setEditingIfscCode(v),
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      controller: _accountNumberController,
                      label: 'Account Number *',
                      hintText: 'e.g. 7648102905',
                      keyboardType: TextInputType.number,
                      prefixIcon: const Icon(Icons.numbers_rounded),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Account number is required' : null,
                      onChanged: (v) => provider.setEditingAccountNumber(v),
                    ),
                  ];
                  if (isNarrow) {
                    return Column(children: fields);
                  }
                  return Wrap(
                    spacing: 14,
                    runSpacing: 14,
                    children: fields.map((f) => SizedBox(width: 280, child: f)).toList(),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Notes card ─────────────────────────────────────────────────────────────
  Widget _buildNotesCard() {
    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            title: 'Notes & Terms',
            subtitle: 'Additional invoice information',
            icon: Icons.note_alt_rounded,
          ),
          const SizedBox(height: 20),
          AppTextField(
            controller: _notesController,
            label: 'Notes',
            hintText: 'Additional notes for the customer...',
            prefixIcon: const Icon(Icons.note_outlined),
            maxLines: 3,
            onChanged: (v) =>
                context.read<InvoiceProvider>().setEditingNotes(v),
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: _termsController,
            label: 'Terms & Conditions',
            hintText: 'Payment terms, delivery conditions...',
            prefixIcon: const Icon(Icons.article_outlined),
            maxLines: 3,
            onChanged: (v) =>
                context.read<InvoiceProvider>().setEditingTerms(v),
          ),
        ],
      ),
    );
  }

  // ── Action buttons ─────────────────────────────────────────────────────────
  Widget _buildActionButtons(BuildContext context) {
    final provider = context.read<InvoiceProvider>();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 580;

        final cancelBtn = SizedBox(
          height: 52,
          child: OutlinedButton(
            onPressed: () => context.pop(),
            style: OutlinedButton.styleFrom(
              foregroundColor: _T.textMid,
              side: const BorderSide(color: _T.divider, width: 1.2),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                      AppConstants.defaultBorderRadius)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.close_rounded, size: 17),
                SizedBox(width: 6),
                Text('Cancel',
                    style: TextStyle(fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        );

        final draftBtn = _PrimaryActionButton(
          label: _isEditMode ? 'Update Invoice' : 'Save Draft',
          icon: _isEditMode
              ? Icons.save_rounded
              : Icons.drafts_rounded,
          isLoading: _isSaving,
          onTap: () => _submitForm(provider, InvoiceStatus.draft),
        );

        final sendBtn = _PrimaryActionButton(
          label: 'Save & Send',
          icon: Icons.send_rounded,
          isLoading: _isSaving,
          onTap: () => _submitForm(provider, InvoiceStatus.sent),
        );

        if (isNarrow) {
          return Column(
            children: [
              SizedBox(width: double.infinity, child: cancelBtn),
              const SizedBox(height: 12),
              SizedBox(width: double.infinity, child: draftBtn),
              if (!_isEditMode) ...[
                const SizedBox(height: 12),
                SizedBox(width: double.infinity, child: sendBtn),
              ],
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: cancelBtn),
            const SizedBox(width: 14),
            Expanded(child: draftBtn),
            if (!_isEditMode) ...[
              const SizedBox(width: 14),
              Expanded(child: sendBtn),
            ],
          ],
        );
      },
    );
  }

  // ── Form submission ────────────────────────────────────────────────────────
  Future<void> _submitForm(
      InvoiceProvider provider, InvoiceStatus status) async {
    if (!_formKey.currentState!.validate()) return;

    if (provider.editingCustomerId.isEmpty) {
      context.showSnackBar('Please select a customer', isError: true);
      return;
    }
    if (provider.editingItems.isEmpty) {
      context.showSnackBar('Please add at least one item',
          isError: true);
      return;
    }
    final stockError = provider.validateStockForItems();
    if (stockError != null) {
      context.showSnackBar(stockError, isError: true);
      return;
    }

    setState(() => _isSaving = true);
    try {
      if (_isEditMode && _editInvoiceId != null) {
        await provider.updateInvoice(_editInvoiceId!);
      } else if (status == InvoiceStatus.draft) {
        await provider.saveDraft();
      } else {
        await provider.createInvoice();
      }
      if (mounted) {
        context.showSnackBar(
          _isEditMode
              ? 'Invoice updated successfully'
              : 'Invoice created successfully',
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        context.showSnackBar('Failed to save invoice: $e',
            isError: true);
      }
    }
  }
}

// ────────────────────────────────────────────────────────────────────────────
// ── Shared sub-widgets ───────────────────────────────────────────────────────
// ────────────────────────────────────────────────────────────────────────────

/// White card with consistent shadow/border from design system
class _CardShell extends StatelessWidget {
  final Widget child;
  const _CardShell({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(context.isMobile ? 16 : 20),
      decoration: _T.card(),
      child: child,
    );
  }
}

/// Gradient icon + title/subtitle section header
class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
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
                color: _T.gradientStart.withOpacity(0.22),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 19),
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
                    color: _T.textDark,
                    letterSpacing: -0.2,
                  )),
              const SizedBox(height: 1),
              Text(subtitle,
                  style: const TextStyle(
                      fontSize: 11, color: _T.textMuted)),
            ],
          ),
        ),
      ],
    );
  }
}

/// Gradient CTA button used in toolbar areas
class _GradientButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _GradientButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: _T.brandGradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: _T.gradientStart.withOpacity(0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: Colors.white, size: 17),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Full-width gradient action button for form submit
class _PrimaryActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isLoading;

  const _PrimaryActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        gradient: _T.brandGradient,
        borderRadius:
            BorderRadius.circular(AppConstants.defaultBorderRadius),
        boxShadow: [
          BoxShadow(
            color: _T.gradientStart.withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius:
              BorderRadius.circular(AppConstants.defaultBorderRadius),
          onTap: isLoading ? null : onTap,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isLoading)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              else ...[
                Icon(icon, color: Colors.white, size: 17),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Back navigation button
class _BackButton extends StatelessWidget {
  final VoidCallback onTap;
  const _BackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: _T.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _T.divider),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1E2A6E).withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(Icons.arrow_back_rounded,
            color: _T.textDark, size: 20),
      ),
    );
  }
}

/// Label + value row for totals section
class _TotalRow extends StatelessWidget {
  final String label;
  final String value;
  const _TotalRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(label,
              style: const TextStyle(
                  color: _T.textMuted,
                  fontSize: 13,
                  fontWeight: FontWeight.w500)),
        ),
        Text(value,
            style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: _T.textDark)),
      ],
    );
  }
}

/// Date picker tappable field
class _DatePickerField extends StatelessWidget {
  final String label;
  final DateTime value;
  final IconData icon;
  final VoidCallback onTap;

  const _DatePickerField({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: InputDecorator(
        decoration: _T.inputDecoration(label, icon),
        child: Text(
          DateFormat('dd/MM/yyyy').format(value),
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: _T.textDark,
          ),
        ),
      ),
    );
  }
}

/// Editable field for item rows
class _ItemInputField extends StatelessWidget {
  final String label;
  final String initialValue;
  final IconData icon;
  final ValueChanged<String> onChanged;

  const _ItemInputField({
    required this.label,
    required this.initialValue,
    required this.icon,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initialValue,
      keyboardType:
          const TextInputType.numberWithOptions(decimal: true),
      style:
          const TextStyle(fontSize: 13, color: _T.textDark),
      decoration: _T.inputDecoration(label, icon),
      onChanged: onChanged,
    );
  }
}

/// Read-only display field for item amount
class _ItemReadonlyField extends StatelessWidget {
  final String label;
  final String value;
  const _ItemReadonlyField(
      {required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration:
          _T.inputDecoration(label, Icons.receipt_rounded),
      child: Text(
        value,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 13,
          color: _T.textDark,
        ),
      ),
    );
  }
}

/// Empty state placeholder for items list
class _EmptyItemsPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        color: _T.gradientStart.withOpacity(0.03),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: _T.divider, style: BorderStyle.solid),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: _T.gradientStart.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.add_shopping_cart_outlined,
                size: 26, color: _T.gradientStart),
          ),
          const SizedBox(height: 12),
          const Text(
            'No items added yet',
            style: TextStyle(
              color: _T.textMuted,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Tap "Add Item" to add products to this invoice',
            style: TextStyle(fontSize: 11, color: _T.textLight),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Inline "Add new …" link with icon
class _AddNewLink extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _AddNewLink({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.add_circle_outline_rounded,
              size: 15, color: _T.gradientStart),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: _T.gradientStart,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
