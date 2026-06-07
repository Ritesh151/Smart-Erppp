import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:siddhivinayak_enterprise/core/extensions/context_extensions.dart';
import 'package:siddhivinayak_enterprise/core/widgets/app_text_field.dart';
import 'package:siddhivinayak_enterprise/core/widgets/product_selector_dialog.dart';
import 'package:siddhivinayak_enterprise/modules/products/providers/product_provider.dart';
import 'package:siddhivinayak_enterprise/modules/finance/providers/purchase_entry_provider.dart';

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
            color: Color(0xFF1E2A6E).withOpacity(0.06),
            blurRadius: 20,
            spreadRadius: 0,
            offset: Offset(0, 4),
          ),
        ],
      );
}

class PurchaseEntryScreen extends StatefulWidget {
  const PurchaseEntryScreen({super.key});

  @override
  State<PurchaseEntryScreen> createState() => _PurchaseEntryScreenState();
}

class _PurchaseEntryScreenState extends State<PurchaseEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _supplierNameCtrl = TextEditingController();
  final _supplierMobileCtrl = TextEditingController();
  final _supplierGstCtrl = TextEditingController();
  final _invoiceNumberCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  bool _isEditMode = false;
  bool _isSaving = false;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final pathParams = GoRouterState.of(context).pathParameters;
      final id = pathParams['id'];
      context.read<ProductProvider>().loadProducts();
      if (id != null && id.isNotEmpty) {
        setState(() => _isEditMode = true);
        _loadPurchaseForEdit(id);
      } else {
        final provider = context.read<PurchaseEntryProvider>();
        provider.resetEditingState();
        provider.generatePurchaseNumber();
      }
      _initialized = true;
    });
  }

  Future<void> _loadPurchaseForEdit(String id) async {
    final provider = context.read<PurchaseEntryProvider>();
    await provider.loadPurchaseById(id);
    _syncControllersFromProvider(provider);
  }

  void _syncControllersFromProvider(PurchaseEntryProvider provider) {
    _supplierNameCtrl.text = provider.supplierName;
    _supplierMobileCtrl.text = provider.supplierMobile;
    _supplierGstCtrl.text = provider.supplierGst;
    _invoiceNumberCtrl.text = provider.invoiceNumberValue;
    _notesCtrl.text = provider.notes;
  }

  @override
  void dispose() {
    _supplierNameCtrl.dispose();
    _supplierMobileCtrl.dispose();
    _supplierGstCtrl.dispose();
    _invoiceNumberCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pad = context.isMobile ? 16.0 : 24.0;
    final gap = context.isMobile ? 16.0 : 20.0;

    if (_isEditMode && !_initialized) {
      return const Center(child: CircularProgressIndicator());
    }

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

  Widget _buildDesktopLayout(double gap) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 5,
          child: Column(
            children: [
              _buildSupplierCard().animate().fadeIn(delay: 60.ms, duration: 300.ms).slideY(begin: 0.06, end: 0),
              SizedBox(height: gap),
              _buildDateCard().animate().fadeIn(delay: 100.ms, duration: 300.ms).slideY(begin: 0.06, end: 0),
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
              _buildNotesCard().animate().fadeIn(delay: 160.ms, duration: 300.ms).slideY(begin: 0.06, end: 0),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(double gap) {
    return Column(
      children: [
        _buildSupplierCard().animate().fadeIn(delay: 60.ms, duration: 280.ms).slideY(begin: 0.06, end: 0),
        SizedBox(height: gap),
        _buildDateCard().animate().fadeIn(delay: 90.ms, duration: 280.ms).slideY(begin: 0.06, end: 0),
        SizedBox(height: gap),
        _buildItemsCard().animate().fadeIn(delay: 120.ms, duration: 280.ms).slideY(begin: 0.06, end: 0),
        SizedBox(height: gap),
        _buildTotalsCard().animate().fadeIn(delay: 150.ms, duration: 280.ms).slideY(begin: 0.06, end: 0),
        SizedBox(height: gap),
        _buildNotesCard().animate().fadeIn(delay: 180.ms, duration: 280.ms).slideY(begin: 0.06, end: 0),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    final backBtn = _BackButton(onTap: () => context.pop());
    final provider = context.watch<PurchaseEntryProvider>();

    final titleBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _isEditMode ? 'Update Purchase' : 'Purchase Entry',
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
              ? 'Modify purchase order details.'
              : 'Record supplier and product purchase information.',
          style: const TextStyle(fontSize: 13, color: _T.textMuted),
        ),
      ],
    );

    final numberChip = provider.purchaseNumber.isNotEmpty
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
                    color: _T.gradientStart,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  provider.purchaseNumber,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: _T.textDark),
                ),
              ],
            ),
          )
        : null;

    if (context.isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [backBtn, const SizedBox(width: 14), Expanded(child: titleBlock)]),
          if (numberChip != null) ...[const SizedBox(height: 12), numberChip],
        ],
      );
    }

    return Row(
      children: [
        backBtn,
        const SizedBox(width: 16),
        Expanded(child: titleBlock),
        if (numberChip != null) numberChip,
      ],
    );
  }

  Widget _buildSupplierCard() {
    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            title: 'Supplier Information',
            subtitle: 'Enter supplier/vendor details',
            icon: Icons.business_rounded,
          ),
          const SizedBox(height: 20),
          AppTextField(
            controller: _supplierNameCtrl,
            label: 'Supplier Name *',
            hintText: 'Enter supplier name',
            prefixIcon: const Icon(Icons.person_outline_rounded),
            onChanged: (v) => context.read<PurchaseEntryProvider>().setSupplierName(v),
            validator: (v) => v == null || v.trim().isEmpty ? 'Supplier name is required' : null,
          ),
          const SizedBox(height: 14),
          AppTextField(
            controller: _supplierMobileCtrl,
            label: 'Mobile Number',
            hintText: 'Enter mobile number',
            prefixIcon: const Icon(Icons.phone_rounded),
            keyboardType: TextInputType.phone,
            onChanged: (v) => context.read<PurchaseEntryProvider>().setSupplierMobile(v),
          ),
          const SizedBox(height: 14),
          AppTextField(
            controller: _supplierGstCtrl,
            label: 'GST Number',
            hintText: 'Enter GST number',
            prefixIcon: const Icon(Icons.description_rounded),
            onChanged: (v) => context.read<PurchaseEntryProvider>().setSupplierGst(v),
          ),
        ],
      ),
    );
  }

  Widget _buildDateCard() {
    return Consumer<PurchaseEntryProvider>(
      builder: (context, provider, _) {
        return _CardShell(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionHeader(
                title: 'Purchase & Invoice',
                subtitle: 'Set purchase and invoice details',
                icon: Icons.calendar_month_rounded,
              ),
              const SizedBox(height: 20),
              _DatePickerField(
                label: 'Purchase Date',
                value: provider.purchaseDate,
                icon: Icons.event_rounded,
                onTap: () => _pickDate(context, provider.purchaseDate, provider.setPurchaseDate),
              ),
              const SizedBox(height: 14),
              AppTextField(
                controller: _invoiceNumberCtrl,
                label: 'Invoice Number',
                hintText: 'Enter supplier invoice number',
                prefixIcon: const Icon(Icons.receipt_rounded),
                onChanged: (v) => context.read<PurchaseEntryProvider>().setInvoiceNumber(v),
              ),
              const SizedBox(height: 14),
              _DatePickerField(
                label: 'Invoice Date',
                value: provider.invoiceDate,
                icon: Icons.event_note_rounded,
                onTap: () => _pickDate(context, provider.invoiceDate, provider.setInvoiceDate),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickDate(BuildContext context, DateTime current, ValueChanged<DateTime> onPicked) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(primary: _T.gradientStart),
        ),
        child: child!,
      ),
    );
    if (picked != null) onPicked(picked);
  }

  Widget _buildItemsCard() {
    return Consumer<PurchaseEntryProvider>(
      builder: (context, provider, _) {
        return _CardShell(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _SectionHeader(
                      title: 'Purchase Items',
                      subtitle: 'Add products with purchase details',
                      icon: Icons.shopping_cart_rounded,
                    ),
                  ),
                  const SizedBox(width: 12),
                  _GradientButton(
                    label: 'Add Product',
                    icon: Icons.add_rounded,
                    onTap: () => _showAddItemDialog(context, provider),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (provider.items.isEmpty)
                _EmptyItemsPlaceholder()
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: provider.items.length,
                  separatorBuilder: (_, __) => const Divider(height: 1, thickness: 1, color: _T.divider),
                  itemBuilder: (context, index) {
                    final item = provider.items[index];
                    return _buildItemRow(context, provider, item, index)
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

  Widget _buildItemRow(BuildContext context, PurchaseEntryProvider provider, PurchaseItemModel item, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  color: _T.gradientStart.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(Icons.inventory_2_rounded, size: 16, color: _T.gradientStart),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.productName,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: _T.textDark)),
                    if (item.hsnCode != null)
                      Text('HSN: ${item.hsnCode}', style: const TextStyle(fontSize: 11, color: _T.textLight)),
                  ],
                ),
              ),
              InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => provider.removeItem(index),
                child: Container(
                  width: 34, height: 34,
                  decoration: BoxDecoration(
                    color: _T.danger.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.delete_outline_rounded, size: 17, color: _T.danger),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 560;
              if (isNarrow) {
                return Column(
                  children: [
                    _ItemInputField(label: 'Qty', initialValue: item.quantity.toString(),
                        onChanged: (v) { final q = double.tryParse(v); if (q != null) provider.updateItemQuantity(index, q); }),
                    const SizedBox(height: 10),
                    _ItemInputField(label: 'Purchase Price', initialValue: item.purchasePrice.toString(),
                        onChanged: (v) { final p = double.tryParse(v); if (p != null) provider.updateItemPrice(index, p); }),
                    const SizedBox(height: 10),
                    _ItemInputField(label: 'GST %', initialValue: item.gstRate.toString(),
                        onChanged: (v) { final g = double.tryParse(v); if (g != null) provider.updateItemGst(index, g); }),
                    const SizedBox(height: 10),
                    _ItemInputField(label: 'Discount %', initialValue: item.discountPercent.toString(),
                        onChanged: (v) { final d = double.tryParse(v); if (d != null) provider.updateItemDiscount(index, d); }),
                    const SizedBox(height: 10),
                    _ItemReadonlyField(label: 'Total', value: '₹${item.total.toStringAsFixed(2)}'),
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(child: _ItemInputField(label: 'Qty', initialValue: item.quantity.toString(),
                      onChanged: (v) { final q = double.tryParse(v); if (q != null) provider.updateItemQuantity(index, q); })),
                  const SizedBox(width: 8),
                  Expanded(child: _ItemInputField(label: 'Price', initialValue: item.purchasePrice.toString(),
                      onChanged: (v) { final p = double.tryParse(v); if (p != null) provider.updateItemPrice(index, p); })),
                  const SizedBox(width: 8),
                  Expanded(child: _ItemInputField(label: 'GST %', initialValue: item.gstRate.toString(),
                      onChanged: (v) { final g = double.tryParse(v); if (g != null) provider.updateItemGst(index, g); })),
                  const SizedBox(width: 8),
                  Expanded(child: _ItemInputField(label: 'Disc %', initialValue: item.discountPercent.toString(),
                      onChanged: (v) { final d = double.tryParse(v); if (d != null) provider.updateItemDiscount(index, d); })),
                  const SizedBox(width: 8),
                  SizedBox(width: 100, child: _ItemReadonlyField(label: 'Total', value: '₹${item.total.toStringAsFixed(2)}')),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _showAddItemDialog(BuildContext context, PurchaseEntryProvider provider) async {
    final product = await ProductSelectorDialog.show(context);
    if (product == null || !mounted) return;

    final qtyCtrl = TextEditingController(text: '1');
    final priceCtrl = TextEditingController(text: product.price.toString());
    final gstCtrl = TextEditingController(text: '18');
    final discCtrl = TextEditingController();

    return showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
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
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [_T.gradientStart.withOpacity(0.05), _T.gradientEnd.withOpacity(0.03)],
                    ),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
                    border: Border(bottom: BorderSide(color: _T.divider)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 38, height: 38,
                        decoration: BoxDecoration(
                          gradient: _T.brandGradient,
                          borderRadius: BorderRadius.circular(11),
                          boxShadow: [BoxShadow(color: _T.gradientStart.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3))],
                        ),
                        child: const Icon(Icons.add_shopping_cart_rounded, color: _T.white, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(product.productName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: _T.textDark),
                                maxLines: 1, overflow: TextOverflow.ellipsis),
                            const Text('Configure purchase details',
                                style: TextStyle(fontSize: 11, color: _T.textMuted)),
                          ],
                        ),
                      ),
                      InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () => Navigator.pop(ctx),
                        child: Container(
                          width: 30, height: 30,
                          decoration: BoxDecoration(
                            color: _T.divider.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.close_rounded, size: 16, color: _T.textMuted),
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
                      if (product.hsnCode != null)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: _T.bg,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: _T.divider),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.qr_code_rounded, size: 14, color: _T.textMuted),
                              const SizedBox(width: 8),
                              Text('HSN: ${product.hsnCode}  •  Unit: ${product.unit}',
                                  style: const TextStyle(fontSize: 12, color: _T.textMuted, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      if (product.hsnCode != null) const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _T.success.withOpacity(0.15)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.inventory_2_rounded, size: 16, color: _T.success),
                            const SizedBox(width: 8),
                            Text('Current Stock: ${product.stockQuantity} ${product.unit}',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _T.success)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      AppTextField(controller: qtyCtrl, label: 'Quantity *', hintText: '1',
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          prefixIcon: const Icon(Icons.numbers_rounded)),
                      const SizedBox(height: 14),
                      AppTextField(controller: priceCtrl, label: 'Purchase Price *', hintText: '0.00',
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          prefixIcon: const Icon(Icons.currency_rupee_rounded)),
                      const SizedBox(height: 14),
                      AppTextField(controller: gstCtrl, label: 'GST Rate %', hintText: 'e.g. 18',
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          prefixIcon: const Icon(Icons.percent_rounded)),
                      const SizedBox(height: 14),
                      AppTextField(controller: discCtrl, label: 'Discount %', hintText: 'e.g. 5',
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          prefixIcon: const Icon(Icons.discount_rounded)),
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
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            foregroundColor: _T.textMuted,
                            side: const BorderSide(color: _T.divider),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w600)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: _T.brandGradient,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [BoxShadow(color: _T.gradientStart.withOpacity(0.28), blurRadius: 12, offset: const Offset(0, 4))],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(14),
                              onTap: () {
                                final qty = double.tryParse(qtyCtrl.text) ?? 1;
                                final price = double.tryParse(priceCtrl.text) ?? product.price;
                                if (qty <= 0) { context.showSnackBar('Quantity must be > 0', isError: true); return; }
                                if (price <= 0) { context.showSnackBar('Purchase price must be > 0', isError: true); return; }
                                provider.addItem(
                                  productId: product.id, productName: product.productName,
                                  hsnCode: product.hsnCode, quantity: qty,
                                  purchasePrice: price,
                                  gstRate: double.tryParse(gstCtrl.text) ?? 0,
                                  discountPercent: double.tryParse(discCtrl.text) ?? 0,
                                );
                                Navigator.pop(ctx);
                              },
                              child: const Padding(
                                padding: EdgeInsets.symmetric(vertical: 14),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_rounded, color: _T.white, size: 18),
                                    SizedBox(width: 6),
                                    Text('Add to Purchase',
                                        style: TextStyle(color: _T.white, fontWeight: FontWeight.w700, fontSize: 13)),
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

  Widget _buildTotalsCard() {
    return Consumer<PurchaseEntryProvider>(
      builder: (context, provider, _) {
        return _CardShell(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionHeader(title: 'Totals', subtitle: 'Purchase amount summary', icon: Icons.calculate_rounded),
              const SizedBox(height: 20),
              _TotalRow(label: 'Subtotal', value: '₹${provider.subtotal.toStringAsFixed(2)}'),
              const SizedBox(height: 8),
              _TotalRow(label: 'GST Amount', value: '₹${provider.gstAmount.toStringAsFixed(2)}'),
              const SizedBox(height: 8),
              _TotalRow(label: 'Discount Amount', value: '-₹${provider.discountAmount.toStringAsFixed(2)}'),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  gradient: _T.brandGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: _T.gradientStart.withOpacity(0.25), blurRadius: 16, offset: const Offset(0, 6))],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.receipt_long_rounded, color: Colors.white70, size: 20),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text('Grand Total',
                          style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white, fontSize: 15)),
                    ),
                    Text('₹${provider.grandTotal.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 22, letterSpacing: -0.5)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNotesCard() {
    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(title: 'Notes', subtitle: 'Additional purchase information', icon: Icons.note_alt_rounded),
          const SizedBox(height: 20),
          AppTextField(
            controller: _notesCtrl,
            label: 'Notes',
            hintText: 'Additional notes about this purchase...',
            prefixIcon: const Icon(Icons.note_outlined),
            maxLines: 3,
            onChanged: (v) => context.read<PurchaseEntryProvider>().setNotes(v),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final provider = context.read<PurchaseEntryProvider>();

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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.close_rounded, size: 17),
                SizedBox(width: 6),
                Text('Cancel', style: TextStyle(fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        );

        final saveBtn = _PrimaryActionButton(
          label: _isEditMode ? 'Update Purchase' : 'Save Purchase',
          icon: Icons.save_rounded,
          isLoading: _isSaving,
          onTap: () => _submitForm(provider),
        );

        if (isNarrow) {
          return Column(
            children: [
              SizedBox(width: double.infinity, child: cancelBtn),
              const SizedBox(height: 12),
              SizedBox(width: double.infinity, child: saveBtn),
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: cancelBtn),
            const SizedBox(width: 14),
            Expanded(flex: 2, child: saveBtn),
          ],
        );
      },
    );
  }

  Future<void> _submitForm(PurchaseEntryProvider provider) async {
    if (!_formKey.currentState!.validate()) return;
    if (provider.items.isEmpty) {
      context.showSnackBar('Please add at least one product', isError: true);
      return;
    }

    setState(() => _isSaving = true);
    try {
      if (_isEditMode) {
        await provider.updatePurchase();
      } else {
        await provider.savePurchase();
      }
      if (mounted) {
        context.showSnackBar(_isEditMode ? 'Purchase updated successfully' : 'Purchase saved successfully');
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        context.showSnackBar(e.toString().replaceFirst('Exception: ', ''), isError: true);
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}

class _CardShell extends StatelessWidget {
  final Widget child;
  const _CardShell({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _T.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _T.divider, width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E2A6E).withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _SectionHeader({required this.title, required this.subtitle, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            gradient: _T.brandGradient,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [BoxShadow(color: _T.gradientStart.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: Icon(icon, color: _T.white, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: _T.textDark)),
              const SizedBox(height: 2),
              Text(subtitle, style: const TextStyle(fontSize: 11, color: _T.textMuted)),
            ],
          ),
        ),
      ],
    );
  }
}

class _BackButton extends StatelessWidget {
  final VoidCallback onTap;
  const _BackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: _T.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _T.divider),
        ),
        child: const Icon(Icons.arrow_back_rounded, size: 18, color: _T.textDark),
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _GradientButton({required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: _T.brandGradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: _T.gradientStart.withOpacity(0.25), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: _T.white, size: 17),
                const SizedBox(width: 6),
                Text(label, style: const TextStyle(color: _T.white, fontWeight: FontWeight.w700, fontSize: 12)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PrimaryActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isLoading;
  final VoidCallback onTap;

  const _PrimaryActionButton({
    required this.label, required this.icon, required this.isLoading, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: Container(
        decoration: BoxDecoration(
          gradient: _T.brandGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: _T.gradientStart.withOpacity(0.28), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: isLoading ? null : onTap,
            child: Center(
              child: isLoading
                  ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: _T.white))
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(icon, color: _T.white, size: 18),
                        const SizedBox(width: 8),
                        Text(label, style: const TextStyle(color: _T.white, fontWeight: FontWeight.w700, fontSize: 14)),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DatePickerField extends StatelessWidget {
  final String label;
  final DateTime value;
  final IconData icon;
  final VoidCallback onTap;

  const _DatePickerField({required this.label, required this.value, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: _T.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _T.divider),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: _T.textMuted),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontSize: 11, color: _T.textMuted)),
                  const SizedBox(height: 2),
                  Text(DateFormat('dd MMM yyyy').format(value),
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _T.textDark)),
                ],
              ),
            ),
            const Icon(Icons.calendar_today_rounded, size: 16, color: _T.textLight),
          ],
        ),
      ),
    );
  }
}

class _ItemInputField extends StatefulWidget {
  final String label;
  final String initialValue;
  final IconData? icon;
  final ValueChanged<String> onChanged;

  const _ItemInputField({
    required this.label, required this.initialValue, this.icon, required this.onChanged,
  });

  @override
  State<_ItemInputField> createState() => _ItemInputFieldState();
}

class _ItemInputFieldState extends State<_ItemInputField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(_ItemInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue && _controller.text != widget.initialValue) {
      _controller.text = widget.initialValue;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _T.textDark),
      decoration: InputDecoration(
        labelText: widget.label,
        labelStyle: const TextStyle(fontSize: 10, color: _T.textMuted),
        isDense: true,
        prefixIcon: widget.icon != null ? Icon(widget.icon, size: 14, color: _T.textMuted) : null,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _T.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _T.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _T.gradientStart, width: 1.4),
        ),
      ),
      onChanged: widget.onChanged,
    );
  }
}

class _ItemReadonlyField extends StatelessWidget {
  final String label;
  final String value;
  const _ItemReadonlyField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: _T.bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _T.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: _T.textMuted)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _T.textDark)),
        ],
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  final String label;
  final String value;
  const _TotalRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: _T.textMuted)),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _T.textDark)),
      ],
    );
  }
}

class _EmptyItemsPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Icon(Icons.add_shopping_cart_rounded, size: 40, color: _T.textLight.withOpacity(0.5)),
          const SizedBox(height: 12),
          const Text('No items added yet',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _T.textMuted)),
          const SizedBox(height: 4),
          const Text('Click "Add Product" to add items',
              style: TextStyle(fontSize: 11, color: _T.textLight)),
        ],
      ),
    );
  }
}
