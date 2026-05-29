import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:SmartERP/core/constants/app_constants.dart';
import 'package:SmartERP/core/extensions/context_extensions.dart';
import 'package:SmartERP/core/extensions/date_extensions.dart';
import 'package:SmartERP/core/models/invoice_model.dart';
import 'package:SmartERP/core/models/payment_model.dart';
import 'package:SmartERP/core/theme/theme_extensions.dart';
import 'package:SmartERP/core/widgets/app_button.dart';
import 'package:SmartERP/core/widgets/empty_state_widget.dart';
import 'package:SmartERP/modules/invoice/providers/invoice_provider.dart';
import 'package:SmartERP/modules/invoice/providers/payment_provider.dart';

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

  static BoxDecoration card({double radius = 16, bool hover = false}) =>
      BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: hover ? gradientStart.withOpacity(0.18) : divider,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: hover
                ? gradientStart.withOpacity(0.10)
                : const Color(0xFF1E2A6E).withOpacity(0.06),
            blurRadius: hover ? 24 : 18,
            spreadRadius: 0,
            offset: Offset(0, hover ? 8 : 4),
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
      );
}

// ── Payment mode config ───────────────────────────────────────────────────────
({Color color, String label, IconData icon}) _modeConfig(PaymentMode mode) {
  switch (mode) {
    case PaymentMode.cash:
      return (color: _T.success,                   label: 'Cash',          icon: Icons.money_rounded);
    case PaymentMode.bankTransfer:
      return (color: _T.gradientStart,              label: 'Bank Transfer', icon: Icons.account_balance_rounded);
    case PaymentMode.cheque:
      return (color: _T.warning,                    label: 'Cheque',        icon: Icons.receipt_rounded);
    case PaymentMode.card:
      return (color: const Color(0xFF8B5CF6),       label: 'Card',          icon: Icons.credit_card_rounded);
    case PaymentMode.upi:
      return (color: const Color(0xFF06B6D4),       label: 'UPI',           icon: Icons.phone_android_rounded);
    case PaymentMode.online:
      return (color: _T.gradientEnd,                label: 'Online',        icon: Icons.language_rounded);
  }
}

// ── Invoice status config ────────────────────────────────────────────────────
({Color color, String label, IconData icon}) _invoiceStatusConfig(
    InvoiceStatus status) {
  switch (status) {
    case InvoiceStatus.draft:
      return (color: _T.textMuted,     label: 'DRAFT',     icon: Icons.drafts_rounded);
    case InvoiceStatus.sent:
      return (color: _T.gradientStart, label: 'SENT',      icon: Icons.send_rounded);
    case InvoiceStatus.paid:
      return (color: _T.success,       label: 'PAID',      icon: Icons.check_circle_rounded);
    case InvoiceStatus.partiallyPaid:
      return (color: _T.warning,       label: 'PARTIAL',   icon: Icons.access_time_rounded);
    case InvoiceStatus.overdue:
      return (color: _T.danger,        label: 'OVERDUE',   icon: Icons.error_outline_rounded);
    case InvoiceStatus.cancelled:
      return (color: _T.danger,        label: 'CANCELLED', icon: Icons.cancel_outlined);
  }
}

// ── Main screen ───────────────────────────────────────────────────────────────
class PaymentHistoryScreen extends StatefulWidget {
  final String invoiceId;
  const PaymentHistoryScreen({super.key, required this.invoiceId});

  @override
  State<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  // ── Lifecycle ───────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PaymentProvider>().loadPaymentsForInvoice(widget.invoiceId);
      context.read<InvoiceProvider>().loadInvoiceDetails(widget.invoiceId);
    });
  }

  // ── Build ───────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final pad = context.isMobile ? 16.0 : 24.0;
    final gap = context.isMobile ? 16.0 : 20.0;

    return Container(
      color: _T.bg,
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(pad),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header
              _buildHeader(context)
                  .animate()
                  .fadeIn(duration: 350.ms)
                  .slideX(begin: -0.04, end: 0),

              SizedBox(height: gap),

              // ── Invoice summary card
              Consumer<InvoiceProvider>(
                builder: (context, invProvider, _) {
                  final invoice = invProvider.selectedInvoice;
                  if (invoice == null) return const SizedBox.shrink();
                  return _buildInvoiceSummary(context, invoice);
                },
              ),

              SizedBox(height: gap),

              // ── Record payment CTA
              _buildRecordPaymentButton(context)
                  .animate()
                  .fadeIn(delay: 120.ms, duration: 280.ms)
                  .slideY(begin: 0.05, end: 0),

              SizedBox(height: gap),

              // ── Payments section header
              _buildSectionLabel(context)
                  .animate()
                  .fadeIn(delay: 150.ms, duration: 260.ms),

              SizedBox(height: gap * 0.7),

              // ── Payment list / table
              Consumer<PaymentProvider>(
                builder: (context, provider, _) {
                  if (provider.isLoading) {
                    return _buildShimmer();
                  }
                  if (provider.payments.isEmpty) {
                    return _buildEmptyState()
                        .animate()
                        .fadeIn(duration: 240.ms);
                  }
                  return context.isDesktop
                      ? _buildDesktopTable(context, provider)
                          .animate()
                          .fadeIn(delay: 80.ms, duration: 280.ms)
                      : _buildMobileList(context, provider);
                },
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    final backBtn = _BackButton(onTap: () => context.pop());

    final titleCol = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment History',
          style: TextStyle(
            fontSize: context.isMobile ? 22 : 26,
            fontWeight: FontWeight.w800,
            color: _T.textDark,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 3),
        const Text(
          'View and manage payments for this invoice',
          style: TextStyle(fontSize: 13, color: _T.textMuted),
        ),
      ],
    );

    if (context.isMobile) {
      return Row(
        children: [
          backBtn,
          const SizedBox(width: 14),
          Expanded(child: titleCol),
        ],
      );
    }

    return Row(
      children: [
        backBtn,
        const SizedBox(width: 16),
        Expanded(child: titleCol),
      ],
    );
  }

  // ── Invoice summary ─────────────────────────────────────────────────────────
  Widget _buildInvoiceSummary(BuildContext context, InvoiceModel invoice) {
    final balance  = invoice.balanceAmount;
    final statusCfg = _invoiceStatusConfig(invoice.status);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(context.isMobile ? 16 : 20),
      decoration: _T.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Invoice number row
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
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
                child: const Icon(Icons.receipt_long_rounded,
                    color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      invoice.invoiceNumber,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: _T.textDark,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _InvoiceStatusChip(status: invoice.status),
                  ],
                ),
              ),
              // Customer name badge
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: _T.bg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _T.divider),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.person_outline_rounded,
                        size: 13, color: _T.textMuted),
                    const SizedBox(width: 6),
                    Text(
                      invoice.customerName,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _T.textMid,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: context.isMobile ? 14 : 18),

          // Summary metric tiles
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 560;

              final totalTile = _SummaryTile(
                label: 'Total Amount',
                value: '₹${invoice.totalAmount.toStringAsFixed(2)}',
                color: _T.gradientStart,
                icon: Icons.receipt_outlined,
              );
              final paidTile = _SummaryTile(
                label: 'Paid Amount',
                value: '₹${invoice.paidAmount.toStringAsFixed(2)}',
                color: _T.success,
                icon: Icons.check_circle_outline_rounded,
              );
              final balanceTile = _SummaryTile(
                label: 'Balance Due',
                value: '₹${balance.toStringAsFixed(2)}',
                color: balance > 0 ? _T.danger : _T.success,
                icon: balance > 0
                    ? Icons.account_balance_wallet_outlined
                    : Icons.verified_outlined,
              );

              if (isNarrow) {
                return Column(
                  children: [
                    totalTile,
                    const SizedBox(height: 10),
                    paidTile,
                    const SizedBox(height: 10),
                    balanceTile,
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: totalTile),
                  const SizedBox(width: 10),
                  Expanded(child: paidTile),
                  const SizedBox(width: 10),
                  Expanded(child: balanceTile),
                ],
              );
            },
          ),

          // Payment progress bar
          SizedBox(height: context.isMobile ? 14 : 18),
          _buildPaymentProgress(invoice),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 60.ms, duration: 300.ms)
        .slideY(begin: 0.06, end: 0);
  }

  Widget _buildPaymentProgress(InvoiceModel invoice) {
    final progress = invoice.totalAmount > 0
        ? (invoice.paidAmount / invoice.totalAmount).clamp(0.0, 1.0)
        : 0.0;
    final pct = (progress * 100).toInt();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Payment Progress',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: _T.textMuted),
            ),
            Text(
              '$pct% paid',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: pct >= 100 ? _T.success : _T.gradientStart,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 7,
            backgroundColor: _T.divider,
            valueColor: AlwaysStoppedAnimation<Color>(
              pct >= 100 ? _T.success : _T.gradientStart,
            ),
          ),
        ),
      ],
    );
  }

  // ── Record payment button ────────────────────────────────────────────────────
  Widget _buildRecordPaymentButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        gradient: _T.brandGradient,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: _T.gradientStart.withOpacity(0.28),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _showRecordPaymentDialog(context),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.add_rounded, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text(
                'Record Payment',
                style: TextStyle(
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

  // ── Section label ────────────────────────────────────────────────────────────
  Widget _buildSectionLabel(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            gradient: _T.brandGradient,
            borderRadius: BorderRadius.circular(9),
          ),
          child:
              const Icon(Icons.history_rounded, color: Colors.white, size: 16),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Payment Records',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: _T.textDark,
              ),
            ),
            Text(
              'All recorded payments for this invoice',
              style: TextStyle(fontSize: 11, color: _T.textMuted),
            ),
          ],
        ),
      ],
    );
  }

  // ── Desktop table ─────────────────────────────────────────────────────────
  Widget _buildDesktopTable(BuildContext context, PaymentProvider provider) {
    return Container(
      decoration: _T.card(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Theme(
            data:
                Theme.of(context).copyWith(dividerColor: _T.divider),
            child: DataTable(
              horizontalMargin: 20,
              columnSpacing: 24,
              headingRowHeight: 52,
              dataRowMinHeight: 66,
              dataRowMaxHeight: 74,
              headingRowColor: MaterialStateProperty.all(
                  const Color(0xFFF8FAFC)),
              headingTextStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: _T.textMuted,
                letterSpacing: 0.3,
              ),
              columns: const [
                DataColumn(label: Text('Date')),
                DataColumn(label: Text('Amount')),
                DataColumn(label: Text('Mode')),
                DataColumn(label: Text('Reference')),
                DataColumn(label: Text('Notes')),
                DataColumn(label: Text('Actions')),
              ],
              rows: provider.payments.asMap().entries.map((entry) {
                final idx     = entry.key;
                final payment = entry.value;

                return DataRow(
                  cells: [
                    // Date
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: _T.gradientStart.withOpacity(0.07),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.event_rounded,
                                size: 14, color: _T.gradientStart),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            payment.paymentDate.toFormattedDate(),
                            style: const TextStyle(
                                fontSize: 13, color: _T.textMid),
                          ),
                        ],
                      ),
                    ),

                    // Amount
                    DataCell(
                      Text(
                        '₹${payment.amount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          color: _T.textDark,
                        ),
                      ),
                    ),

                    // Mode chip
                    DataCell(_PaymentModeChip(mode: payment.mode)),

                    // Reference
                    DataCell(
                      payment.reference != null &&
                              payment.reference!.isNotEmpty
                          ? _InfoPill(
                              icon: Icons.tag_rounded,
                              label: payment.reference!)
                          : const Text('—',
                              style: TextStyle(
                                  color: _T.textLight,
                                  fontSize: 13)),
                    ),

                    // Notes
                    DataCell(
                      SizedBox(
                        width: 150,
                        child: Text(
                          payment.notes ?? '—',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 12, color: _T.textMuted),
                        ),
                      ),
                    ),

                    // Delete action
                    DataCell(
                      _ActionIconButton(
                        icon: Icons.delete_outline_rounded,
                        color: _T.danger,
                        tooltip: 'Delete',
                        onTap: () => _confirmDeletePayment(
                            context, payment, provider),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  // ── Mobile list ─────────────────────────────────────────────────────────────
  Widget _buildMobileList(BuildContext context, PaymentProvider provider) {
    return SlidableAutoCloseBehavior(
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: provider.payments.length,
        itemBuilder: (context, index) {
          final payment = provider.payments[index];
          return _HoverCard(
            child: Slidable(
              key: ValueKey(payment.id),
              endActionPane: ActionPane(
                motion: const DrawerMotion(),
                extentRatio: 0.28,
                children: [
                  SlidableAction(
                    onPressed: (_) =>
                        _confirmDeletePayment(context, payment, provider),
                    backgroundColor: _T.danger,
                    foregroundColor: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    icon: Icons.delete_rounded,
                    label: 'Delete',
                  ),
                ],
              ),
              child: _PaymentMobileCard(
                payment: payment,
              ),
            ),
          )
              .animate()
              .fadeIn(delay: (index * 45).ms, duration: 230.ms)
              .slideY(begin: 0.05, end: 0);
        },
      ),
    );
  }

  // ── Shimmer ──────────────────────────────────────────────────────────────────
  Widget _buildShimmer() {
    return Column(
      children: List.generate(
        4,
        (i) => Container(
          height: 88,
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  // ── Empty state ──────────────────────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: _T.card(),
      child: const EmptyStateWidget(
        icon: Icons.payments_outlined,
        title: 'No Payments Recorded',
        message: 'Record a payment to track payments for this invoice.',
      ),
    );
  }

  // ── Record payment dialog ────────────────────────────────────────────────────
  void _showRecordPaymentDialog(BuildContext context) {
    final invoiceProvider = context.read<InvoiceProvider>();
    final invoice         = invoiceProvider.selectedInvoice;
    if (invoice == null) return;

    final amountController    = TextEditingController();
    final referenceController = TextEditingController();
    final notesController     = TextEditingController();
    DateTime    selectedDate  = DateTime.now();
    PaymentMode selectedMode  = PaymentMode.cash;
    bool        isLoading     = false;

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 40),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 500),
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
                  children: [
                    // ── Dialog header
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
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              gradient: _T.brandGradient,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: _T.gradientStart
                                      .withOpacity(0.28),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Icon(Icons.payments_rounded,
                                color: Colors.white, size: 19),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Record Payment',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: _T.textDark,
                                  ),
                                ),
                                Text(
                                  invoice.invoiceNumber,
                                  style: const TextStyle(
                                      fontSize: 11,
                                      color: _T.textMuted),
                                ),
                              ],
                            ),
                          ),
                          InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () => Navigator.pop(dialogCtx),
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: _T.divider.withOpacity(0.6),
                                borderRadius:
                                    BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                  Icons.close_rounded,
                                  size: 15,
                                  color: _T.textMuted),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ── Balance info strip
                    Container(
                      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: _T.gradientStart.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: _T.gradientStart.withOpacity(0.12)),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                              Icons.account_balance_wallet_outlined,
                              size: 15,
                              color: _T.gradientStart),
                          const SizedBox(width: 8),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: _T.textMuted),
                                children: [
                                  const TextSpan(
                                      text: 'Balance Due:  '),
                                  TextSpan(
                                    text:
                                        '₹${invoice.balanceAmount.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13,
                                      color: _T.textDark,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ── Form fields
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Amount
                          TextField(
                            controller: amountController,
                            keyboardType:
                                const TextInputType.numberWithOptions(
                                    decimal: true),
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: _T.textDark),
                            decoration: _T.inputDecoration(
                                'Amount *',
                                Icons.currency_rupee_rounded),
                          ),
                          const SizedBox(height: 14),

                          // Date picker
                          InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: selectedDate,
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2030),
                                builder: (context, child) => Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: Theme.of(context)
                                        .colorScheme
                                        .copyWith(
                                            primary:
                                                _T.gradientStart),
                                  ),
                                  child: child!,
                                ),
                              );
                              if (date != null) {
                                setDialogState(
                                    () => selectedDate = date);
                              }
                            },
                            child: InputDecorator(
                              decoration: _T.inputDecoration(
                                  'Payment Date *',
                                  Icons.calendar_today_rounded),
                              child: Text(
                                selectedDate.toFormattedDate(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: _T.textDark,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Payment mode dropdown
                          DropdownButtonFormField<PaymentMode>(
                            value: selectedMode,
                            borderRadius: BorderRadius.circular(16),
                            decoration: _T.inputDecoration(
                                'Payment Mode *',
                                Icons.payment_rounded),
                            onChanged: (v) {
                              if (v != null) {
                                setDialogState(
                                    () => selectedMode = v);
                              }
                            },
                            items: PaymentMode.values.map((mode) {
                              final cfg = _modeConfig(mode);
                              return DropdownMenuItem(
                                value: mode,
                                child: Row(
                                  children: [
                                    Icon(cfg.icon,
                                        size: 15, color: cfg.color),
                                    const SizedBox(width: 8),
                                    Text(cfg.label,
                                        style: const TextStyle(
                                            fontSize: 13)),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 14),

                          // Reference
                          TextField(
                            controller: referenceController,
                            decoration: _T.inputDecoration(
                                'Reference', Icons.tag_rounded),
                            style: const TextStyle(
                                fontSize: 13, color: _T.textDark),
                          ),
                          const SizedBox(height: 14),

                          // Notes
                          TextField(
                            controller: notesController,
                            maxLines: 3,
                            style: const TextStyle(
                                fontSize: 13, color: _T.textDark),
                            decoration: _T.inputDecoration(
                                'Notes', Icons.notes_rounded),
                          ),
                        ],
                      ),
                    ),

                    // ── Actions
                    Padding(
                      padding:
                          const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: isLoading
                                  ? null
                                  : () => Navigator.pop(dialogCtx),
                              style: OutlinedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(
                                        vertical: 13),
                                foregroundColor: _T.textMuted,
                                side: const BorderSide(
                                    color: _T.divider),
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(13)),
                              ),
                              child: const Text('Cancel',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: isLoading
                                    ? null
                                    : _T.brandGradient,
                                color: isLoading
                                    ? _T.divider
                                    : null,
                                borderRadius:
                                    BorderRadius.circular(13),
                                boxShadow: isLoading
                                    ? null
                                    : [
                                        BoxShadow(
                                          color: _T.gradientStart
                                              .withOpacity(0.28),
                                          blurRadius: 12,
                                          offset:
                                              const Offset(0, 4),
                                        ),
                                      ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius:
                                      BorderRadius.circular(13),
                                  onTap: isLoading
                                      ? null
                                      : () async {
                                          final amount =
                                              double.tryParse(
                                                  amountController
                                                      .text);
                                          if (amount == null ||
                                              amount <= 0) {
                                            context.showSnackBar(
                                                'Please enter a valid amount',
                                                isError: true);
                                            return;
                                          }
                                          if (amount >
                                              invoice.balanceAmount) {
                                            context.showSnackBar(
                                                'Amount exceeds balance',
                                                isError: true);
                                            return;
                                          }
                                          setDialogState(
                                              () => isLoading = true);
                                          try {
                                            final pp = context.read<
                                                PaymentProvider>();
                                            await pp.recordPayment(
                                              invoiceId:
                                                  widget.invoiceId,
                                              amount: amount,
                                              paymentDate: selectedDate,
                                              mode: selectedMode,
                                              reference: referenceController
                                                      .text
                                                      .trim()
                                                      .isEmpty
                                                  ? null
                                                  : referenceController
                                                      .text
                                                      .trim(),
                                              notes: notesController
                                                      .text
                                                      .trim()
                                                      .isEmpty
                                                  ? null
                                                  : notesController
                                                      .text
                                                      .trim(),
                                            );
                                            if (dialogCtx.mounted) {
                                              Navigator.pop(dialogCtx);
                                              invoiceProvider
                                                  .loadInvoiceDetails(
                                                      widget.invoiceId);
                                            }
                                            if (context.mounted) {
                                              context.showSnackBar(
                                                  'Payment recorded successfully');
                                            }
                                          } catch (e) {
                                            if (context.mounted) {
                                              context.showSnackBar(
                                                  'Failed to record payment: $e',
                                                  isError: true);
                                            }
                                            if (dialogCtx.mounted) {
                                              setDialogState(() =>
                                                  isLoading = false);
                                            }
                                          }
                                        },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 13),
                                    child: isLoading
                                        ? const Center(
                                            child:
                                                SizedBox(
                                              width: 20,
                                              height: 20,
                                              child:
                                                  CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white,
                                              ),
                                            ),
                                          )
                                        : Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment
                                                    .center,
                                            children: const [
                                              Icon(
                                                  Icons
                                                      .check_circle_outline_rounded,
                                                  color: Colors.white,
                                                  size: 17),
                                              SizedBox(width: 6),
                                              Text(
                                                'Record Payment',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight:
                                                      FontWeight.w700,
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

  // ── Delete payment dialog ────────────────────────────────────────────────────
  void _confirmDeletePayment(
    BuildContext context,
    PaymentModel payment,
    PaymentProvider provider,
  ) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (dialogCtx) => _DeletePaymentDialog(
        payment: payment,
        provider: provider,
        invoiceId: widget.invoiceId,
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// ── Sub-widgets ──────────────────────────────────────────────────────────────
// ────────────────────────────────────────────────────────────────────────────

/// Back navigation button — identical style to invoice_form_screen
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

/// Summary metric tile inside invoice summary card
class _SummaryTile extends StatelessWidget {
  final String   label;
  final String   value;
  final Color    color;
  final IconData icon;

  const _SummaryTile({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 13, color: color.withOpacity(0.8)),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color.withOpacity(0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: color,
              letterSpacing: -0.3,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// Invoice status chip with icon prefix
class _InvoiceStatusChip extends StatelessWidget {
  final InvoiceStatus status;
  const _InvoiceStatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final cfg = _invoiceStatusConfig(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: cfg.color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cfg.color.withOpacity(0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(cfg.icon, size: 10, color: cfg.color),
          const SizedBox(width: 4),
          Text(
            cfg.label,
            style: TextStyle(
              color: cfg.color,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}

/// Payment mode chip with icon prefix
class _PaymentModeChip extends StatelessWidget {
  final PaymentMode mode;
  const _PaymentModeChip({required this.mode});

  @override
  Widget build(BuildContext context) {
    final cfg = _modeConfig(mode);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: cfg.color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cfg.color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(cfg.icon, size: 11, color: cfg.color),
          const SizedBox(width: 5),
          Text(
            cfg.label,
            style: TextStyle(
              color: cfg.color,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// Info pill chip (reference tag etc.)
class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String   label;
  const _InfoPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: _T.gradientStart.withOpacity(0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _T.gradientStart.withOpacity(0.08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: _T.gradientStart),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _T.textDark,
            ),
          ),
        ],
      ),
    );
  }
}

/// Small action icon button for table rows
class _ActionIconButton extends StatelessWidget {
  final IconData     icon;
  final Color        color;
  final String       tooltip;
  final VoidCallback onTap;

  const _ActionIconButton({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          width: 33,
          height: 33,
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
      ),
    );
  }
}

/// Mobile payment card used inside Slidable
class _PaymentMobileCard extends StatelessWidget {
  final PaymentModel payment;
  const _PaymentMobileCard({required this.payment});

  @override
  Widget build(BuildContext context) {
    final cfg = _modeConfig(payment.mode);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: _T.card(),
      child: Row(
        children: [
          // Icon box
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: cfg.color.withOpacity(0.09),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(cfg.icon, color: cfg.color, size: 20),
          ),
          const SizedBox(width: 12),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '₹${payment.amount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: _T.textDark,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const Spacer(),
                    _PaymentModeChip(mode: payment.mode),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded,
                        size: 11, color: _T.textLight),
                    const SizedBox(width: 4),
                    Text(
                      payment.paymentDate.toFormattedDate(),
                      style: const TextStyle(
                          fontSize: 11, color: _T.textMuted),
                    ),
                  ],
                ),
                if (payment.reference != null &&
                    payment.reference!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _InfoPill(
                      icon: Icons.tag_rounded,
                      label: payment.reference!),
                ],
                if (payment.notes != null &&
                    payment.notes!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    payment.notes!,
                    style: const TextStyle(
                        fontSize: 11, color: _T.textMuted),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right_rounded,
              color: _T.textLight, size: 18),
        ],
      ),
    );
  }
}

/// Hover lift animation wrapper
class _HoverCard extends StatefulWidget {
  final Widget child;
  const _HoverCard({required this.child});

  @override
  State<_HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<_HoverCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        transform: Matrix4.identity()
          ..translate(0.0, _hovered ? -2.5 : 0.0),
        child: widget.child,
      ),
    );
  }
}

/// Styled delete payment confirmation dialog
class _DeletePaymentDialog extends StatelessWidget {
  final PaymentModel   payment;
  final PaymentProvider provider;
  final String         invoiceId;

  const _DeletePaymentDialog({
    required this.payment,
    required this.provider,
    required this.invoiceId,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding:
          const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
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
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _T.danger.withOpacity(0.04),
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(22)),
                border: Border(
                    bottom: BorderSide(
                        color: _T.danger.withOpacity(0.1))),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _T.danger.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.delete_outline_rounded,
                        color: _T.danger, size: 19),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Delete Payment?',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: _T.textDark,
                          ),
                        ),
                        Text(
                          'This action cannot be undone.',
                          style: TextStyle(
                              fontSize: 11, color: _T.textMuted),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: _T.divider.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.close_rounded,
                          size: 14, color: _T.textMuted),
                    ),
                  ),
                ],
              ),
            ),

            // Body
            Padding(
              padding: const EdgeInsets.all(20),
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 13,
                    color: _T.textMuted,
                    height: 1.6,
                  ),
                  children: [
                    const TextSpan(
                        text:
                            'Are you sure you want to permanently delete the payment of '),
                    TextSpan(
                      text:
                          '₹${payment.amount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: _T.textDark,
                      ),
                    ),
                    const TextSpan(
                        text:
                            '? The invoice balance will be updated accordingly.'),
                  ],
                ),
              ),
            ),

            // Actions
            Padding(
              padding:
                  const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            vertical: 13),
                        foregroundColor: _T.textMuted,
                        side:
                            const BorderSide(color: _T.divider),
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(13)),
                      ),
                      child: const Text('Cancel',
                          style: TextStyle(
                              fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: _T.danger,
                        borderRadius: BorderRadius.circular(13),
                        boxShadow: [
                          BoxShadow(
                            color: _T.danger.withOpacity(0.25),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius:
                              BorderRadius.circular(13),
                          onTap: () async {
                            try {
                              await provider
                                  .deletePayment(payment.id);
                              if (context.mounted) {
                                Navigator.pop(context);
                                context
                                    .read<InvoiceProvider>()
                                    .loadInvoiceDetails(
                                        invoiceId);
                                context.showSnackBar(
                                    'Payment deleted successfully');
                              }
                            } catch (e) {
                              if (context.mounted) {
                                Navigator.pop(context);
                                context.showSnackBar(
                                    'Failed to delete payment: $e',
                                    isError: true);
                              }
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 13),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              children: const [
                                Icon(
                                    Icons.delete_outline_rounded,
                                    color: Colors.white,
                                    size: 16),
                                SizedBox(width: 6),
                                Text(
                                  'Delete',
                                  style: TextStyle(
                                    color: Colors.white,
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
  }
}
