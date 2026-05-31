import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:SmartERP/core/extensions/context_extensions.dart';
import 'package:SmartERP/core/models/expense_model.dart';
import 'package:SmartERP/modules/expenses/providers/expense_provider.dart';

// ── Shared brand tokens (aligned with dashboard_screen.dart) ─────────────────
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
  static const danger        = Color(0xFFEF4444);
  static const success       = Color(0xFF10B981);

  static const Gradient brandGradient = LinearGradient(
    colors: [gradientStart, gradientEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static BoxDecoration card({double radius = 16}) => BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: divider),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E2A6E).withOpacity(0.06),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      );

  // Input decoration factory
  static InputDecoration inputDecoration({
    required String label,
    required IconData icon,
    String? prefix,
    String? hint,
    Widget? suffix,
  }) =>
      InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Icon(icon, size: 18, color: textMuted),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 48),
        prefixText: prefix,
        prefixStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textDark,
        ),
        suffix: suffix,
        labelStyle: const TextStyle(fontSize: 13, color: textMuted),
        hintStyle: const TextStyle(fontSize: 13, color: textLight),
        filled: true,
        fillColor: const Color(0xFFFAFAFB),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: gradientStart, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: danger, width: 1.5),
        ),
        errorStyle: const TextStyle(fontSize: 11, color: danger),
      );
}

class AddExpenseScreen extends StatefulWidget {
  final ExpenseModel? expense;

  const AddExpenseScreen({super.key, this.expense});

  bool get isEditing => expense != null;

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _vendorCtrl;
  late final TextEditingController _notesCtrl;
  String   _category = ExpenseProvider.categories.first;
  DateTime _date      = DateTime.now();

  bool get _isEditing => widget.isEditing;

  @override
  void initState() {
    super.initState();
    _amountCtrl = TextEditingController(
        text: _isEditing ? widget.expense!.amount.toString() : null);
    _descCtrl   = TextEditingController(
        text: _isEditing ? widget.expense!.description : null);
    _vendorCtrl = TextEditingController(
        text: _isEditing ? widget.expense!.vendor ?? '' : null);
    _notesCtrl  = TextEditingController(
        text: _isEditing ? widget.expense!.notes ?? '' : null);
    if (_isEditing) {
      _category = widget.expense!.category;
      _date = widget.expense!.expenseDate;
    }
  }

  // Category icon map for visual richness
  static const Map<String, IconData> _categoryIcons = {
    'Raw Materials'    : Icons.inventory_2_rounded,
    'Transportation'   : Icons.local_shipping_rounded,
    'Utilities'        : Icons.bolt_rounded,
    'Salaries'         : Icons.people_rounded,
    'Maintenance'      : Icons.build_rounded,
    'Office Supplies'  : Icons.work_rounded,
    'Marketing'        : Icons.campaign_rounded,
    'Other'            : Icons.category_rounded,
  };

  static const List<Color> _categoryColors = [
    Color(0xFF4F6EF7),
    Color(0xFF10B981),
    Color(0xFFF59E0B),
    Color(0xFF7C3AED),
    Color(0xFFEC4899),
    Color(0xFF64748B),
    Color(0xFF0D9488),
    Color(0xFFEF4444),
  ];

  Color get _selectedCategoryColor {
    final idx = ExpenseProvider.categories.indexOf(_category);
    return _categoryColors[idx % _categoryColors.length];
  }

  IconData get _selectedCategoryIcon =>
      _categoryIcons[_category] ?? Icons.category_rounded;

  @override
  void dispose() {
    _amountCtrl.dispose();
    _descCtrl.dispose();
    _vendorCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    final parsedAmount = double.tryParse(_amountCtrl.text.trim());
    if (parsedAmount == null || parsedAmount <= 0) {
      _showSnack('Please enter a valid amount');
      return;
    }

    try {
      final provider = context.read<ExpenseProvider>();
      if (_isEditing) {
        await provider.updateExpense(
          id         : widget.expense!.id,
          category   : _category,
          description: _descCtrl.text.trim(),
          amount     : parsedAmount,
          expenseDate: _date,
          vendor     : _vendorCtrl.text.trim().isEmpty ? null : _vendorCtrl.text.trim(),
          notes      : _notesCtrl.text.trim().isEmpty  ? null : _notesCtrl.text.trim(),
        );
        if (mounted) {
          context.showSnackBar('Expense updated successfully');
          context.pop();
        }
      } else {
        await provider.addExpense(
          category   : _category,
          description: _descCtrl.text.trim(),
          amount     : parsedAmount,
          expenseDate: _date,
          vendor     : _vendorCtrl.text.trim().isEmpty ? null : _vendorCtrl.text.trim(),
          notes      : _notesCtrl.text.trim().isEmpty  ? null : _notesCtrl.text.trim(),
        );
        if (mounted) _showSuccessDialog();
      }
    } catch (e) {
      if (mounted) _showSnack('Failed to save expense: $e');
    }
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.info_outline_rounded,
                  color: _T.white, size: 16),
              const SizedBox(width: 8),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: _T.textDark,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
  }

  Future<void> _showSuccessDialog() async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        elevation: 0,
        backgroundColor: _T.white,
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color       : _T.success.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(Icons.check_circle_rounded,
                    color: _T.success, size: 30),
              ),
              const SizedBox(height: 16),
              const Text(
                'Expense Saved!',
                style: TextStyle(
                  fontSize  : 18,
                  fontWeight: FontWeight.w800,
                  color     : _T.textDark,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your expense has been recorded successfully.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color   : _T.textMuted,
                  height  : 1.5,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: Container(
                  decoration: BoxDecoration(
                    gradient    : _T.brandGradient,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow   : [
                      BoxShadow(
                        color     : _T.gradientStart.withOpacity(0.28),
                        blurRadius: 10,
                        offset    : const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      context.pop();
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text(
                      'Done',
                      style: TextStyle(
                        color     : _T.white,
                        fontWeight: FontWeight.w700,
                        fontSize  : 14,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formattedDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/'
      '${date.year}';

  @override
  Widget build(BuildContext context) {
    final provider  = context.watch<ExpenseProvider>();
    final isLoading = provider.isLoading;
    final isMobile  = MediaQuery.of(context).size.width < 600;

    return Container(
      color: _T.bg,
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.all(isMobile ? 16 : 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Page header ──────────────────────────────────────────
                  _buildPageHeader(context, isMobile)
                      .animate()
                      .fadeIn(duration: 380.ms)
                      .slideX(begin: -0.04, end: 0),

                  SizedBox(height: isMobile ? 20 : 28),

                  // ── Form card ────────────────────────────────────────────
                  Container(
                    decoration: _T.card(radius: 20),
                    padding: EdgeInsets.all(isMobile ? 18 : 24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Section: Basic Info
                          _sectionLabel('Basic Information',
                              Icons.info_outline_rounded),
                          const SizedBox(height: 14),

                          // Category picker
                          _buildCategoryPicker(isMobile)
                              .animate()
                              .fadeIn(delay: 60.ms, duration: 280.ms),

                          const SizedBox(height: 14),

                          // Amount field
                          TextFormField(
                            controller   : _amountCtrl,
                            keyboardType : const TextInputType.numberWithOptions(decimal: true),
                            style        : const TextStyle(
                              fontSize  : 14,
                              fontWeight: FontWeight.w600,
                              color     : _T.textDark,
                            ),
                            decoration: _T.inputDecoration(
                              label : 'Amount (₹) *',
                              icon  : Icons.currency_rupee_rounded,
                              hint  : '0.00',
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Amount is required';
                              }
                              final val = double.tryParse(v.trim());
                              if (val == null || val <= 0) {
                                return 'Enter a valid amount';
                              }
                              return null;
                            },
                          ).animate().fadeIn(delay: 90.ms, duration: 280.ms),

                          const SizedBox(height: 14),

                          // Description field
                          TextFormField(
                            controller: _descCtrl,
                            style: const TextStyle(
                              fontSize: 14,
                              color: _T.textDark,
                            ),
                            decoration: _T.inputDecoration(
                              label: 'Description *',
                              icon : Icons.notes_rounded,
                              hint : 'Brief description of expense',
                            ),
                            validator: (v) => v == null || v.trim().isEmpty
                                ? 'Description is required'
                                : null,
                          ).animate().fadeIn(delay: 110.ms, duration: 280.ms),

                          const SizedBox(height: 24),

                          // Section: Additional Details
                          _sectionLabel('Additional Details',
                              Icons.tune_rounded),
                          const SizedBox(height: 14),

                          // Vendor field
                          TextFormField(
                            controller: _vendorCtrl,
                            style: const TextStyle(
                              fontSize: 14,
                              color: _T.textDark,
                            ),
                            decoration: _T.inputDecoration(
                              label: 'Vendor / Payee',
                              icon : Icons.storefront_rounded,
                              hint : 'Optional',
                            ),
                          ).animate().fadeIn(delay: 130.ms, duration: 280.ms),

                          const SizedBox(height: 14),

                          // Notes field
                          TextFormField(
                            controller : _notesCtrl,
                            maxLines   : 3,
                            style: const TextStyle(
                              fontSize: 14,
                              color: _T.textDark,
                            ),
                            decoration: _T.inputDecoration(
                              label: 'Notes',
                              icon : Icons.sticky_note_2_outlined,
                              hint : 'Any additional notes (optional)',
                            ),
                          ).animate().fadeIn(delay: 150.ms, duration: 280.ms),

                          const SizedBox(height: 14),

                          // Date picker
                          _buildDatePicker(isMobile)
                              .animate()
                              .fadeIn(delay: 170.ms, duration: 280.ms),

                          const SizedBox(height: 28),

                          // ── Action buttons ───────────────────────────────
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => context.pop(),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    side: const BorderSide(color: _T.divider),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text(
                                    'Cancel',
                                    style: TextStyle(
                                      color     : _T.textMid,
                                      fontWeight: FontWeight.w600,
                                      fontSize  : 14,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 2,
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient    : isLoading ? null : _T.brandGradient,
                                    color       : isLoading
                                        ? const Color(0xFFE5E7EB)
                                        : null,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow   : isLoading
                                        ? []
                                        : [
                                            BoxShadow(
                                              color: _T.gradientStart
                                                  .withOpacity(0.28),
                                              blurRadius: 12,
                                              offset: const Offset(0, 5),
                                            ),
                                          ],
                                  ),
                                  child: TextButton(
                                    onPressed: isLoading ? null : _handleSubmit,
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 14),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: isLoading
                                        ? const SizedBox(
                                            height: 18,
                                            width : 18,
                                            child : CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: _T.white,
                                            ),
                                          )
                                        : Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.save_rounded,
                                                color: _T.white,
                                                size: 17,
                                              ),
                                              SizedBox(width: 7),
                                              Text(
                                                _isEditing
                                                    ? 'Update Expense'
                                                    : 'Save Expense',
                                                style: TextStyle(
                                                  color     : _T.white,
                                                  fontWeight: FontWeight.w700,
                                                  fontSize  : 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                  ),
                                ),
                              ),
                            ],
                          ).animate().fadeIn(delay: 200.ms, duration: 280.ms),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(delay: 50.ms, duration: 350.ms)
                   .slideY(begin: 0.06, end: 0),

                  SizedBox(height: isMobile ? 16 : 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Page header ────────────────────────────────────────────────────────────
  Widget _buildPageHeader(BuildContext context, bool isMobile) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width : 42,
          height: 42,
          decoration: BoxDecoration(
            gradient    : _T.brandGradient,
            borderRadius: BorderRadius.circular(12),
            boxShadow   : [
              BoxShadow(
                color     : _T.gradientStart.withOpacity(0.28),
                blurRadius: 10,
                offset    : const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.receipt_long_rounded,
              color: _T.white, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                Text(
                  _isEditing ? 'Edit Expense' : 'Add New Expense',
                  style: TextStyle(
                    fontSize    : isMobile ? 20 : 24,
                    fontWeight  : FontWeight.w800,
                    color       : _T.textDark,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _isEditing
                      ? 'Update the details of this expense.'
                      : 'Record a business expense to your ledger.',
                  style: const TextStyle(fontSize: 12, color: _T.textMuted),
                ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Section label ──────────────────────────────────────────────────────────
  Widget _sectionLabel(String title, IconData icon) {
    return Row(
      children: [
        Container(
          width : 26,
          height: 26,
          decoration: BoxDecoration(
            gradient    : _T.brandGradient,
            borderRadius: BorderRadius.circular(7),
          ),
          child: Icon(icon, color: _T.white, size: 13),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize  : 13,
            fontWeight: FontWeight.w700,
            color     : _T.textDark,
          ),
        ),
      ],
    );
  }

  // ── Category picker ────────────────────────────────────────────────────────
  Widget _buildCategoryPicker(bool isMobile) {
    return DropdownButtonFormField<String>(
      value    : _category,
      style    : const TextStyle(
        fontSize  : 14,
        fontWeight: FontWeight.w600,
        color     : _T.textDark,
      ),
      icon: const Icon(Icons.keyboard_arrow_down_rounded,
          color: _T.textMuted, size: 20),
      dropdownColor: _T.white,
      decoration: _T.inputDecoration(
        label: 'Category *',
        icon : _selectedCategoryIcon,
      ).copyWith(
        prefixIcon: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Container(
            width : 28,
            height: 28,
            decoration: BoxDecoration(
              color       : _selectedCategoryColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Icon(_selectedCategoryIcon,
                size: 15, color: _selectedCategoryColor),
          ),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 56),
      ),
      items: ExpenseProvider.categories.asMap().entries.map((entry) {
        final idx   = entry.key;
        final cat   = entry.value;
        final color = _categoryColors[idx % _categoryColors.length];
        final icon  = _categoryIcons[cat] ?? Icons.category_rounded;
        return DropdownMenuItem(
          value: cat,
          child: Row(
            children: [
              Container(
                width : 28,
                height: 28,
                decoration: BoxDecoration(
                  color       : color.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Icon(icon, size: 14, color: color),
              ),
              const SizedBox(width: 10),
              Text(
                cat,
                style: const TextStyle(
                  fontSize  : 13,
                  fontWeight: FontWeight.w600,
                  color     : _T.textDark,
                ),
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: (v) => setState(() => _category = v!),
    );
  }

  // ── Date picker tile ───────────────────────────────────────────────────────
  Widget _buildDatePicker(bool isMobile) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context  : context,
          initialDate: _date,
          firstDate: DateTime(2020),
          lastDate : DateTime.now(),
          builder  : (context, child) => Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary  : _T.gradientStart,
                onPrimary: _T.white,
                surface  : _T.white,
              ),
              dialogBackgroundColor: _T.white,
            ),
            child: child!,
          ),
        );
        if (picked != null) setState(() => _date = picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color       : const Color(0xFFFAFAFB),
          borderRadius: BorderRadius.circular(12),
          border      : Border.all(color: _T.divider),
        ),
        child: Row(
          children: [
            Container(
              width : 28,
              height: 28,
              decoration: BoxDecoration(
                gradient    : _T.brandGradient,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.calendar_today_rounded,
                  color: _T.white, size: 14),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Expense Date',
                    style: TextStyle(fontSize: 11, color: _T.textMuted),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formattedDate(_date),
                    style: const TextStyle(
                      fontSize  : 14,
                      fontWeight: FontWeight.w700,
                      color     : _T.textDark,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color       : _T.gradientStart.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Change',
                style: TextStyle(
                  fontSize  : 11,
                  fontWeight: FontWeight.w600,
                  color     : _T.gradientStart,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
