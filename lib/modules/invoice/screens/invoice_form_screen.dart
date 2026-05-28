import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:SmartERP/core/constants/app_constants.dart';
import 'package:SmartERP/core/extensions/context_extensions.dart';
import 'package:SmartERP/core/models/invoice_item_model.dart';
import 'package:SmartERP/core/models/invoice_model.dart';
import 'package:SmartERP/core/models/product_model.dart';
import 'package:SmartERP/core/widgets/app_button.dart';
import 'package:SmartERP/core/widgets/app_text_field.dart';
import 'package:SmartERP/core/widgets/product_selector_dialog.dart';
import 'package:SmartERP/modules/invoice/providers/customer_provider.dart';
import 'package:SmartERP/modules/invoice/providers/invoice_provider.dart';
import 'package:SmartERP/modules/products/providers/product_provider.dart';

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

  static BoxDecoration card({
    double radius = 18,
  }) {
    return BoxDecoration(
      color: white,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: divider.withOpacity(0.8),
      ),
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

class InvoiceFormScreen extends StatefulWidget {
  const InvoiceFormScreen({super.key});

  @override
  State<InvoiceFormScreen> createState() => _InvoiceFormScreenState();
}

class _InvoiceFormScreenState extends State<InvoiceFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _notesController = TextEditingController();
  final _termsController = TextEditingController();

  bool _isEditMode = false;
  String? _editInvoiceId;
  String? _editInvoiceNumber;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final pathParams = GoRouterState.of(context).pathParameters;
      final id = pathParams['id'];

      context.read<ProductProvider>().loadProducts();

      if (id != null && id.isNotEmpty) {
        _isEditMode = true;
        _editInvoiceId = id;
        _loadInvoiceForEdit(id);
      } else {
        context.read<InvoiceProvider>().resetEditingState();
      }

      context.read<CustomerProvider>().loadCustomers();
    });
  }

  void _loadInvoiceForEdit(String id) async {
    final provider = context.read<InvoiceProvider>();
    
    await provider.loadInvoiceDetails(id);
    
    final invoice = provider.selectedInvoice;
    if (invoice != null && invoice.id.isNotEmpty) {
      provider.populateEditingFromInvoice(
        invoice,
        items: provider.selectedInvoiceItems,
      );
      _editInvoiceNumber = invoice.invoiceNumber;
      _notesController.text = invoice.notes ?? '';
      _termsController.text = invoice.termsAndConditions ?? '';
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    _termsController.dispose();
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
            padding: EdgeInsets.all(
              context.isMobile ? 16 : 24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFormHeader(context)
                    .animate()
                    .fadeIn(duration: 260.ms)
                    .slideX(begin: -0.05, end: 0),

                SizedBox(
                  height: context.isMobile ? 18 : 24,
                ),

                if (context.isDesktop)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 5,
                        child: Column(
                          children: [
                            _buildCustomerCard(),
                            const SizedBox(height: 18),
                            _buildDateCard(),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        flex: 7,
                        child: Column(
                          children: [
                            _buildItemsCard(),
                            const SizedBox(height: 18),
                            _buildTotalsCard(),
                            const SizedBox(height: 18),
                            _buildNotesCard(),
                          ],
                        ),
                      ),
                    ],
                  )
                else
                  Column(
                    children: [
                      _buildCustomerCard(),
                      const SizedBox(height: 18),
                      _buildDateCard(),
                      const SizedBox(height: 18),
                      _buildItemsCard(),
                      const SizedBox(height: 18),
                      _buildTotalsCard(),
                      const SizedBox(height: 18),
                      _buildNotesCard(),
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
                        border: Border.all(
                          color: _T.divider,
                        ),
                      ),
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        color: _T.textDark,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isEditMode
                              ? 'Update Invoice'
                              : 'Create Invoice',
                          style: TextStyle(
                            fontSize: context.isMobile ? 24 : 28,
                            fontWeight: FontWeight.w800,
                            color: _T.textDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _isEditMode
                              ? 'Modify invoice details and line items.'
                              : 'Enter customer and billing information.',
                          style: const TextStyle(
                            fontSize: 13,
                            color: _T.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (_isEditMode) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _T.divider,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: _T.success,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Editing: ${_editInvoiceNumber ?? ''}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: _T.textDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
                        border: Border.all(
                          color: _T.divider,
                        ),
                      ),
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        color: _T.textDark,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isEditMode
                              ? 'Update Invoice'
                              : 'Create Invoice',
                          style: TextStyle(
                            fontSize: context.isMobile ? 24 : 28,
                            fontWeight: FontWeight.w800,
                            color: _T.textDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _isEditMode
                              ? 'Modify invoice details and line items.'
                              : 'Enter customer and billing information.',
                          style: const TextStyle(
                            fontSize: 13,
                            color: _T.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (_isEditMode) ...[
              const SizedBox(width: 18),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _T.divider,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: _T.success,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Editing: ${_editInvoiceNumber ?? ''}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: _T.textDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildCustomerCard() {
    return Consumer<CustomerProvider>(
      builder: (context, customerProvider, _) {
        return Consumer<InvoiceProvider>(
          builder: (context, provider, _) {
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: _T.card(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(
                    title: 'Customer Information',
                    subtitle: 'Select or enter customer details',
                    icon: Icons.person_outline_rounded,
                  ),
                  const SizedBox(height: 22),
                  DropdownButtonFormField<String>(
                    value: provider.editingCustomerId.isNotEmpty
                        ? provider.editingCustomerId
                        : null,
                    borderRadius: BorderRadius.circular(16),
                    decoration: _inputDecoration(
                      'Select Customer *',
                      Icons.business_rounded,
                    ),
                    hint: const Text('Choose Customer'),
                    validator: (value) {
                      if (value == null) {
                        return 'Customer is required';
                      }
                      return null;
                    },
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
                        child: Text(c.name),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      const Icon(Icons.add_circle_outline,
                          size: 16, color: _T.gradientStart),
                      const SizedBox(width: 6),
                      InkWell(
                        onTap: () => context.push('/customers/create'),
                        child: const Text(
                          'Add New Customer',
                          style: TextStyle(
                            color: _T.gradientStart,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDateCard() {
    return Consumer<InvoiceProvider>(
      builder: (context, provider, _) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: _T.card(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader(
                title: 'Invoice Dates',
                subtitle: 'Set invoice and due dates',
                icon: Icons.calendar_month_rounded,
              ),
              const SizedBox(height: 22),
              LayoutBuilder(
                builder: (context, constraints) {
                  final vertical = constraints.maxWidth < 500;

                  if (vertical) {
                    return Column(
                      children: [
                        _datePickerField(
                          label: 'Invoice Date',
                          value: provider.editingInvoiceDate,
                          icon: Icons.event_rounded,
                          onTap: () => _pickDate(
                            context,
                            provider.editingInvoiceDate,
                            (d) => provider.setEditingInvoiceDate(d),
                          ),
                        ),
                        const SizedBox(height: 18),
                        _datePickerField(
                          label: 'Due Date',
                          value: provider.editingDueDate,
                          icon: Icons.event_note_rounded,
                          onTap: () => _pickDate(
                            context,
                            provider.editingDueDate,
                            (d) => provider.setEditingDueDate(d),
                          ),
                        ),
                      ],
                    );
                  }

                  return Row(
                    children: [
                      Expanded(
                        child: _datePickerField(
                          label: 'Invoice Date',
                          value: provider.editingInvoiceDate,
                          icon: Icons.event_rounded,
                          onTap: () => _pickDate(
                            context,
                            provider.editingInvoiceDate,
                            (d) => provider.setEditingInvoiceDate(d),
                          ),
                        ),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: _datePickerField(
                          label: 'Due Date',
                          value: provider.editingDueDate,
                          icon: Icons.event_note_rounded,
                          onTap: () => _pickDate(
                            context,
                            provider.editingDueDate,
                            (d) => provider.setEditingDueDate(d),
                          ),
                        ),
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

  Widget _datePickerField({
    required String label,
    required DateTime value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: InputDecorator(
        decoration: _inputDecoration(label, icon),
        child: Text(
          DateFormat('dd/MM/yyyy').format(value),
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: _T.textDark,
          ),
        ),
      ),
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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: _T.gradientStart,
                ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      onPicked(picked);
    }
  }

  Widget _buildItemsCard() {
    return Consumer<InvoiceProvider>(
      builder: (context, provider, _) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: _T.card(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildSectionHeader(
                      title: 'Invoice Items',
                      subtitle: 'Add products and services',
                      icon: Icons.receipt_rounded,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: _T.brandGradient,
                      borderRadius: BorderRadius.circular(14),
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
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => _showAddItemDialog(context, provider),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.add_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Add Item',
                                style: TextStyle(
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
                  ),
                ],
              ),
              const SizedBox(height: 22),

              if (provider.editingItems.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: _T.gradientStart.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _T.divider,
                    ),
                  ),
                  child: const Column(
                    children: [
                      Icon(
                        Icons.add_shopping_cart_outlined,
                        size: 40,
                        color: _T.textLight,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'No items added yet',
                        style: TextStyle(
                          color: _T.textMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Tap "Add Item" to add products',
                        style: TextStyle(
                          fontSize: 12,
                          color: _T.textLight,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: provider.editingItems.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, color: _T.divider),
                  itemBuilder: (context, index) {
                    final item = provider.editingItems[index];
                    return _buildItemRow(context, provider, item, index);
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
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.productName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: _T.textDark,
                  ),
                ),
              ),
              InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => provider.removeItem(index),
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: _T.danger.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.delete_outline_rounded,
                    size: 18,
                    color: _T.danger,
                  ),
                ),
              ),
            ],
          ),
          if (item.hsnCode != null) ...[
            const SizedBox(height: 4),
            Text(
              'HSN: ${item.hsnCode}',
              style: const TextStyle(fontSize: 11, color: _T.textMuted),
            ),
          ],
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final vertical = constraints.maxWidth < 500;

              if (vertical) {
                return Column(
                  children: [
                    _buildItemField(
                      label: 'Qty',
                      value: item.quantity.toString(),
                      icon: Icons.numbers_rounded,
                      onChanged: (v) {
                        final qty = double.tryParse(v);
                        if (qty != null) provider.updateItemQuantity(index, qty);
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildItemField(
                      label: 'Unit Price',
                      value: item.unitPrice.toString(),
                      icon: Icons.currency_rupee_rounded,
                      onChanged: (v) {
                        final price = double.tryParse(v);
                        if (price != null) provider.updateItemPrice(index, price);
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildReadonlyField(
                      label: 'Amount',
                      value: '₹${item.amount.toStringAsFixed(2)}',
                    ),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(
                    child: _buildItemField(
                      label: 'Qty',
                      value: item.quantity.toString(),
                      icon: Icons.numbers_rounded,
                      onChanged: (v) {
                        final qty = double.tryParse(v);
                        if (qty != null) provider.updateItemQuantity(index, qty);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildItemField(
                      label: 'Unit Price',
                      value: item.unitPrice.toString(),
                      icon: Icons.currency_rupee_rounded,
                      onChanged: (v) {
                        final price = double.tryParse(v);
                        if (price != null) provider.updateItemPrice(index, price);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildReadonlyField(
                      label: 'Amount',
                      value: '₹${item.amount.toStringAsFixed(2)}',
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

  Widget _buildItemField({
    required String label,
    required String value,
    required IconData icon,
    required ValueChanged<String> onChanged,
  }) {
    return TextFormField(
      initialValue: value,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: _inputDecoration(label, icon),
      onChanged: onChanged,
    );
  }

  Widget _buildReadonlyField({
    required String label,
    required String value,
  }) {
    return InputDecorator(
      decoration: _inputDecoration(label, Icons.receipt_rounded),
      child: Text(
        value,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          color: _T.textDark,
        ),
      ),
    );
  }

  Future<void> _showAddItemDialog(
    BuildContext context,
    InvoiceProvider provider,
  ) async {
    final product = await ProductSelectorDialog.show(context);
    if (product == null || !mounted) return;

    final qtyController = TextEditingController(text: '1');
    final discountController = TextEditingController();
    final priceController = TextEditingController(text: product.price.toString());

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  product.productName,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (product.hsnCode != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F7FA),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'HSN: ${product.hsnCode}  |  Unit: ${product.unit}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: product.isOutOfStock
                        ? const Color(0xFFFEF2F2)
                        : product.isLowStock
                            ? const Color(0xFFFFFBEB)
                            : const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        product.isOutOfStock
                            ? Icons.error_outline
                            : product.isLowStock
                                ? Icons.warning_amber_rounded
                                : Icons.check_circle_outline,
                        size: 16,
                        color: product.isOutOfStock
                            ? const Color(0xFFEF4444)
                            : product.isLowStock
                                ? const Color(0xFFF59E0B)
                                : const Color(0xFF10B981),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Available Stock: ${product.stockQuantity} ${product.unit}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: product.isOutOfStock
                              ? const Color(0xFFEF4444)
                              : product.isLowStock
                                  ? const Color(0xFFF59E0B)
                                  : const Color(0xFF10B981),
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
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  prefixIcon: const Icon(Icons.numbers_rounded),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: priceController,
                  label: 'Unit Price *',
                  hintText: '0.00',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  prefixIcon: const Icon(Icons.currency_rupee_rounded),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: discountController,
                  label: 'Discount Rate %',
                  hintText: 'e.g. 5',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  prefixIcon: const Icon(Icons.discount_rounded),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: _T.brandGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextButton(
                onPressed: () {
                  final qty = double.tryParse(qtyController.text) ?? 1;
                  final price =
                      double.tryParse(priceController.text) ?? product.price;

                  if (qty <= 0) {
                    context.showSnackBar(
                      'Quantity must be greater than 0',
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
                      'Unit price must be greater than 0',
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
                    discountRate:
                        double.tryParse(discountController.text) ?? 0,
                  );

                  Navigator.pop(context);
                },
                child: const Text(
                  'Add',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTotalsCard() {
    return Consumer<InvoiceProvider>(
      builder: (context, provider, _) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: _T.card(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader(
                title: 'Totals',
                subtitle: 'Invoice amount summary',
                icon: Icons.calculate_rounded,
              ),
              const SizedBox(height: 22),

              _buildTotalRow('Subtotal', '₹${provider.editingSubtotal.toStringAsFixed(2)}'),
              const SizedBox(height: 8),
              _buildTotalRow('CGST @ 9%', '₹${provider.editingCgstAmount.toStringAsFixed(2)}'),
              const SizedBox(height: 8),
              _buildTotalRow('SGST @ 9%', '₹${provider.editingSgstAmount.toStringAsFixed(2)}'),
              const SizedBox(height: 8),
              _buildTotalRow('IGST @ 18%', '₹${provider.editingIgstAmount.toStringAsFixed(2)}'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: _T.warning.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _T.warning.withOpacity(0.15),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.discount_rounded,
                      size: 18,
                      color: _T.warning,
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Discount',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: _T.textDark,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 100,
                      child: TextFormField(
                        initialValue: provider.editingDiscount.toString(),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        textAlign: TextAlign.right,
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: _T.divider,
                            ),
                          ),
                          prefixText: '₹ ',
                          prefixStyle: const TextStyle(
                            color: _T.textMuted,
                            fontWeight: FontWeight.w600,
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
              const SizedBox(height: 8),
              _buildTotalRow(
                'Round Off',
                '₹${provider.editingRoundOff.toStringAsFixed(2)}',
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: _T.brandGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Grand Total',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Text(
                      '₹${provider.editingGrandTotal.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        fontSize: 20,
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

  Widget _buildTotalRow(String label, String value) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: _T.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: _T.textDark,
          ),
        ),
      ],
    );
  }

  Widget _buildNotesCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _T.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            title: 'Notes & Terms',
            subtitle: 'Additional invoice information',
            icon: Icons.note_alt_rounded,
          ),
          const SizedBox(height: 22),
          AppTextField(
            controller: _notesController,
            label: 'Notes',
            hintText: 'Additional notes for the customer...',
            prefixIcon: const Icon(Icons.note_outlined),
            maxLines: 3,
            onChanged: (v) {
              context.read<InvoiceProvider>().setEditingNotes(v);
            },
          ),
          const SizedBox(height: 18),
          AppTextField(
            controller: _termsController,
            label: 'Terms & Conditions',
            hintText: 'Payment terms, delivery conditions...',
            prefixIcon: const Icon(Icons.article_outlined),
            maxLines: 3,
            onChanged: (v) {
              context.read<InvoiceProvider>().setEditingTerms(v);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final provider = context.read<InvoiceProvider>();

    return LayoutBuilder(
      builder: (context, constraints) {
        final vertical = constraints.maxWidth < 620;

        if (vertical) {
          return Column(
            children: [
              SizedBox(
                height: 54,
                child: AppButton(
                  text: 'Cancel',
                  variant: AppButtonVariant.outline,
                  onPressed: () {
                    context.pop();
                  },
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  gradient: _T.brandGradient,
                  borderRadius: BorderRadius.circular(
                    AppConstants.defaultBorderRadius,
                  ),
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
                    text: _isEditMode ? 'Update Invoice' : 'Save Draft',
                    variant: AppButtonVariant.primary,
                    onPressed: () {
                      _submitForm(provider, InvoiceStatus.draft);
                    },
                  ),
                ),
              ),
              if (!_isEditMode) ...[
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    gradient: _T.brandGradient,
                    borderRadius: BorderRadius.circular(
                      AppConstants.defaultBorderRadius,
                    ),
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
                      text: 'Save & Send',
                      variant: AppButtonVariant.primary,
                      onPressed: () {
                        _submitForm(provider, InvoiceStatus.sent);
                      },
                    ),
                  ),
                ),
              ],
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
                  onPressed: () {
                    context.pop();
                  },
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  gradient: _T.brandGradient,
                  borderRadius: BorderRadius.circular(
                    AppConstants.defaultBorderRadius,
                  ),
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
                    text: _isEditMode ? 'Update Invoice' : 'Save Draft',
                    variant: AppButtonVariant.primary,
                    onPressed: () {
                      _submitForm(provider, InvoiceStatus.draft);
                    },
                  ),
                ),
              ),
            ),
            if (!_isEditMode) ...[
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: _T.brandGradient,
                    borderRadius: BorderRadius.circular(
                      AppConstants.defaultBorderRadius,
                    ),
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
                      text: 'Save & Send',
                      variant: AppButtonVariant.primary,
                      onPressed: () {
                        _submitForm(provider, InvoiceStatus.sent);
                      },
                    ),
                  ),
                ),
              ),
            ],
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
          child: Icon(
            icon,
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: _T.textDark,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 11,
                  color: _T.textMuted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(
    String label,
    IconData icon,
  ) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: _T.divider,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: _T.divider,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: _T.gradientStart,
          width: 1.4,
        ),
      ),
    );
  }

  Future<void> _submitForm(
    InvoiceProvider provider,
    InvoiceStatus status,
  ) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (provider.editingCustomerId.isEmpty) {
      context.showSnackBar(
        'Please select a customer',
        isError: true,
      );
      return;
    }

    if (provider.editingItems.isEmpty) {
      context.showSnackBar(
        'Please add at least one item',
        isError: true,
      );
      return;
    }

    final stockError = provider.validateStockForItems();
    if (stockError != null) {
      context.showSnackBar(stockError, isError: true);
      return;
    }

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
        context.showSnackBar(
          'Failed to save invoice: $e',
          isError: true,
        );
      }
    }
  }
}
