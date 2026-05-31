import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:siddhivinayak_enterprise/core/extensions/context_extensions.dart';
import 'package:siddhivinayak_enterprise/core/models/expense_model.dart';
import 'package:siddhivinayak_enterprise/modules/expenses/providers/expense_provider.dart';

class _T {
  static const gradientStart = Color(0xFF4F6EF7);
  static const gradientEnd   = Color(0xFF7C3AED);
  static const bg            = Color(0xFFF5F7FA);
  static const white         = Colors.white;
  static const textDark      = Color(0xFF111827);
  static const textMid       = Color(0xFF374151);
  static const textMuted     = Color(0xFF6B7280);
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
        border: Border.all(color: divider),
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

const Map<String, IconData> _kCategoryIcons = {
  'Raw Materials'    : Icons.inventory_2_rounded,
  'Transportation'   : Icons.local_shipping_rounded,
  'Utilities'        : Icons.bolt_rounded,
  'Salaries'         : Icons.people_rounded,
  'Maintenance'      : Icons.build_rounded,
  'Office Supplies'  : Icons.work_rounded,
  'Marketing'        : Icons.campaign_rounded,
  'Other'            : Icons.category_rounded,
};

const List<Color> _kCategoryColors = [
  Color(0xFF4F6EF7),
  Color(0xFF10B981),
  Color(0xFFF59E0B),
  Color(0xFF7C3AED),
  Color(0xFFEC4899),
  Color(0xFF64748B),
  Color(0xFF0D9488),
  Color(0xFFEF4444),
];

Color _catColor(String category) {
  final idx = ExpenseProvider.categories.indexOf(category);
  return _kCategoryColors[(idx < 0 ? 0 : idx) % _kCategoryColors.length];
}

IconData _catIcon(String category) =>
    _kCategoryIcons[category] ?? Icons.receipt_rounded;

class ExpenseDetailScreen extends StatefulWidget {
  final String expenseId;

  const ExpenseDetailScreen({super.key, required this.expenseId});

  @override
  State<ExpenseDetailScreen> createState() => _ExpenseDetailScreenState();
}

class _ExpenseDetailScreenState extends State<ExpenseDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExpenseProvider>().loadExpenseById(widget.expenseId);
    });
  }

  String _formatAmount(double amount) {
    if (amount >= 10000000) return '₹${(amount / 10000000).toStringAsFixed(1)}Cr';
    if (amount >= 100000) return '₹${(amount / 100000).toStringAsFixed(1)}L';
    if (amount >= 1000) return '₹${(amount / 1000).toStringAsFixed(1)}K';
    return '₹${amount.toStringAsFixed(2)}';
  }

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/'
      '${date.year}';

  String _formatDateTime(DateTime date) =>
      '${_formatDate(date)} ${date.hour.toString().padLeft(2, '0')}:'
      '${date.minute.toString().padLeft(2, '0')}';

  Color _statusColor(String status) {
    switch (status) {
      case 'approved':
        return _T.success;
      case 'rejected':
        return _T.danger;
      case 'paid':
        return _T.success;
      default:
        return _T.warning;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'approved':
        return 'Approved';
      case 'rejected':
        return 'Rejected';
      case 'paid':
        return 'Paid';
      default:
        return 'Pending';
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                  color: _T.danger.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(Icons.delete_forever_rounded,
                    color: _T.danger, size: 30),
              ),
              const SizedBox(height: 16),
              const Text(
                'Delete Expense?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: _T.textDark,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'This action cannot be undone. The expense will be permanently removed.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 13, color: _T.textMuted, height: 1.5),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        side: const BorderSide(color: _T.divider),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                            color: _T.textMid,
                            fontWeight: FontWeight.w600,
                            fontSize: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: Container(
                      decoration: BoxDecoration(
                        color: _T.danger,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: _T.danger.withOpacity(0.28),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextButton(
                        onPressed: () => Navigator.of(ctx).pop(true),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text(
                          'Delete',
                          style: TextStyle(
                              color: _T.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed == true && mounted) {
      await context.read<ExpenseProvider>().deleteExpense(widget.expenseId);
      if (mounted) {
        context.showSnackBar('Expense deleted');
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Consumer<ExpenseProvider>(
      builder: (context, provider, _) {
        final expense = provider.selectedExpense;

        if (provider.isLoading || expense == null) {
          return Container(
            color: _T.bg,
            child: SafeArea(
              child: Center(
                child: CircularProgressIndicator(
                    color: _T.gradientStart, strokeWidth: 2.5),
              ),
            ),
          );
        }

        final color = _catColor(expense.category);
        final icon = _catIcon(expense.category);

        return Container(
          color: _T.bg,
          child: SafeArea(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(isMobile ? 16 : 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(context, expense, color, icon, isMobile)
                          .animate()
                          .fadeIn(duration: 280.ms)
                          .slideX(begin: -0.04, end: 0),
                      SizedBox(height: isMobile ? 20 : 28),
                      _buildExpenseInfoCard(
                          context, expense, color, icon, isMobile)
                          .animate()
                          .fadeIn(delay: 80.ms, duration: 280.ms)
                          .slideY(begin: 0.06, end: 0),
                      SizedBox(height: isMobile ? 14 : 18),
                      _buildDetailCard(context, expense, isMobile)
                          .animate()
                          .fadeIn(delay: 120.ms, duration: 280.ms)
                          .slideY(begin: 0.06, end: 0),
                      SizedBox(height: isMobile ? 14 : 18),
                      _buildMetadataCard(context, expense, isMobile)
                          .animate()
                          .fadeIn(delay: 140.ms, duration: 280.ms)
                          .slideY(begin: 0.06, end: 0),
                      SizedBox(height: isMobile ? 24 : 32),
                      _buildActionRow(context, provider, expense, isMobile)
                          .animate()
                          .fadeIn(delay: 180.ms, duration: 280.ms)
                          .slideY(begin: 0.08, end: 0),
                      const SizedBox(height: 16),
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

  Widget _buildHeader(
      BuildContext context,
      ExpenseModel expense,
      Color color,
      IconData icon,
      bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _IconBtn(
                icon: Icons.arrow_back_rounded,
                onTap: () => context.pop()),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.expenseNumber,
                    style: TextStyle(
                      fontSize: isMobile ? 18 : 22,
                      fontWeight: FontWeight.w800,
                      color: _T.textDark,
                      letterSpacing: -0.4,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatDateTime(expense.createdAt),
                    style: const TextStyle(
                        fontSize: 11, color: _T.textMuted),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _statusColor(expense.status.name).withOpacity(0.10),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: _statusColor(expense.status.name)
                        .withOpacity(0.20)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: _statusColor(expense.status.name),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _statusLabel(expense.status.name),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: _statusColor(expense.status.name),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildExpenseInfoCard(
      BuildContext context,
      ExpenseModel expense,
      Color color,
      IconData icon,
      bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 20 : 24),
      decoration: _T.card(radius: 20),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: color.withOpacity(0.18)),
                ),
                child: Icon(icon, color: color, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      expense.category,
                      style: TextStyle(
                        fontSize: isMobile ? 15 : 17,
                        fontWeight: FontWeight.w700,
                        color: _T.textDark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      expense.description,
                      style: const TextStyle(
                          fontSize: 13,
                          color: _T.textMid,
                          height: 1.4),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: _T.brandGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: _T.gradientStart.withOpacity(0.28),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Amount',
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatAmount(expense.amount),
                  style: TextStyle(
                    fontSize: isMobile ? 28 : 34,
                    fontWeight: FontWeight.w800,
                    color: _T.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  expense.vendor != null && expense.vendor!.isNotEmpty
                      ? 'Paid to ${expense.vendor}'
                      : 'No vendor recorded',
                  style: const TextStyle(
                      fontSize: 12, color: Colors.white60),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard(
      BuildContext context, ExpenseModel expense, bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 18 : 22),
      decoration: _T.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(Icons.info_outline_rounded, 'Expense Details'),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _T.divider),
            ),
            child: Column(
              children: [
                _buildDetailRow('Category', expense.category,
                    color: _catColor(expense.category)),
                _buildDivider(),
                _buildDetailRow(
                    'Description', expense.description),
                _buildDivider(),
                _buildDetailRow('Expense Date',
                    _formatDate(expense.expenseDate)),
                if (expense.vendor != null &&
                    expense.vendor!.isNotEmpty) ...[
                  _buildDivider(),
                  _buildDetailRow('Vendor / Payee', expense.vendor!),
                ],
                if (expense.referenceNumber != null &&
                    expense.referenceNumber!.isNotEmpty) ...[
                  _buildDivider(),
                  _buildDetailRow(
                      'Reference #', expense.referenceNumber!),
                ],
                if (expense.paymentMethod != null &&
                    expense.paymentMethod!.isNotEmpty) ...[
                  _buildDivider(),
                  _buildDetailRow(
                      'Payment Method', expense.paymentMethod!),
                ],
              ],
            ),
          ),
          if (expense.notes != null && expense.notes!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _T.divider),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.sticky_note_2_outlined,
                          size: 14, color: _T.textMuted),
                      SizedBox(width: 6),
                      Text(
                        'Notes',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _T.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    expense.notes!,
                    style: const TextStyle(
                        fontSize: 13,
                        color: _T.textMid,
                        height: 1.5),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetadataCard(
      BuildContext context, ExpenseModel expense, bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 18 : 22),
      decoration: _T.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
              Icons.access_time_rounded, 'Timeline'),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _T.divider),
            ),
            child: Column(
              children: [
                _buildDetailRow('Created',
                    _formatDateTime(expense.createdAt)),
                _buildDivider(),
                _buildDetailRow('Last Updated',
                    _formatDateTime(expense.updatedAt)),
                _buildDivider(),
                _buildDetailRow('Status',
                    _statusLabel(expense.status.name),
                    color: _statusColor(expense.status.name)),
                if (expense.approvedBy != null) ...[
                  _buildDivider(),
                  _buildDetailRow(
                      'Approved By', expense.approvedBy!),
                  _buildDivider(),
                  _buildDetailRow('Approved At',
                      _formatDateTime(expense.approvedAt!)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionRow(
      BuildContext context,
      ExpenseProvider provider,
      ExpenseModel expense,
      bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 18 : 22),
      decoration: _T.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(Icons.bolt_rounded, 'Actions'),
          const SizedBox(height: 16),
          if (isMobile)
            Column(
              children: [
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: _ActionBtn(
                      label: 'Edit Expense',
                      icon: Icons.edit_rounded,
                      color: _T.gradientStart,
                      onTap: () => context.push(
                        '/expenses/${expense.id}/edit',
                        extra: expense,
                      ),
                    ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: _ActionBtn(
                    label: 'Delete Expense',
                    icon: Icons.delete_rounded,
                    color: _T.danger,
                    outlined: true,
                    onTap: _confirmDelete,
                  ),
                ),
              ],
            )
          else
            Row(
              children: [
                  SizedBox(
                    height: 50,
                    child: _ActionBtn(
                      label: 'Edit Expense',
                      icon: Icons.edit_rounded,
                      color: _T.gradientStart,
                      onTap: () => context.push(
                        '/expenses/${expense.id}/edit',
                        extra: expense,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    height: 50,
                    child: _ActionBtn(
                      label: 'Delete Expense',
                      icon: Icons.delete_rounded,
                      color: _T.danger,
                      outlined: true,
                      onTap: _confirmDelete,
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _sectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            gradient: _T.brandGradient,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: _T.white, size: 14),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: _T.textDark,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                  fontSize: 12, color: _T.textMuted),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: color ?? _T.textDark,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, color: _T.divider);
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _IconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _T.white,
      borderRadius: BorderRadius.circular(12),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            border: Border.all(color: _T.divider),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 18, color: _T.textDark),
        ),
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool outlined;

  const _ActionBtn({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    if (outlined) {
      return OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 16),
        label: Text(label,
            style: const TextStyle(fontWeight: FontWeight.w700)),
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color.withOpacity(0.25)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.28),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextButton.icon(
        onPressed: onTap,
        icon: const Icon(Icons.edit_rounded, color: _T.white, size: 16),
        label: Text(label,
            style: const TextStyle(
                color: _T.white,
                fontWeight: FontWeight.w700,
                fontSize: 13)),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
