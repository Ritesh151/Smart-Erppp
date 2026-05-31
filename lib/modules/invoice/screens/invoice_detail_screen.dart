import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:siddhivinayak_enterprise/core/extensions/context_extensions.dart';
import 'package:siddhivinayak_enterprise/core/extensions/date_extensions.dart';
import 'package:siddhivinayak_enterprise/core/models/invoice_model.dart';
import 'package:siddhivinayak_enterprise/core/models/payment_model.dart';
import 'package:siddhivinayak_enterprise/core/utils/download_helper.dart';
import 'package:siddhivinayak_enterprise/core/widgets/app_button.dart';
import 'package:siddhivinayak_enterprise/modules/invoice/providers/invoice_provider.dart';
import 'package:siddhivinayak_enterprise/modules/invoice/providers/payment_provider.dart';
import 'package:siddhivinayak_enterprise/modules/invoice/services/pdf_service.dart';

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

class InvoiceDetailScreen extends StatefulWidget {
  final String invoiceId;

  const InvoiceDetailScreen({super.key, required this.invoiceId});

  @override
  State<InvoiceDetailScreen> createState() => _InvoiceDetailScreenState();
}

class _InvoiceDetailScreenState extends State<InvoiceDetailScreen> {
  final _pdfService = PdfService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InvoiceProvider>().loadInvoiceDetails(widget.invoiceId);
      context.read<PaymentProvider>().loadPaymentsForInvoice(widget.invoiceId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<InvoiceProvider>(
      builder: (context, provider, _) {
        final invoice = provider.selectedInvoice;

        if (invoice == null || provider.isLoading) {
          return Container(
            color: _T.bg,
            child: const Center(
              child: CircularProgressIndicator(
                  color: _T.gradientStart, strokeWidth: 2.5),
            ),
          );
        }

        return Container(
          color: _T.bg,
          child: SafeArea(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(context.isMobile ? 16 : 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, invoice)
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
                          child: _buildCustomerInfoCard(invoice)
                              .animate()
                              .fadeIn(delay: 80.ms, duration: 280.ms)
                              .slideY(begin: 0.08, end: 0),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          flex: 7,
                          child: Column(
                            children: [
                              _buildInvoiceDetailsCard(invoice)
                                  .animate()
                                  .fadeIn(delay: 100.ms, duration: 280.ms)
                                  .slideY(begin: 0.08, end: 0),
                              const SizedBox(height: 18),
                              _buildItemsTable(invoice, provider)
                                  .animate()
                                  .fadeIn(delay: 120.ms, duration: 280.ms)
                                  .slideY(begin: 0.08, end: 0),
                              const SizedBox(height: 18),
                              _buildTotalsCard(invoice)
                                  .animate()
                                  .fadeIn(delay: 140.ms, duration: 280.ms)
                                  .slideY(begin: 0.08, end: 0),
                            ],
                          ),
                        ),
                      ],
                    )
                  else
                    Column(
                      children: [
                        _buildCustomerInfoCard(invoice)
                            .animate()
                            .fadeIn(delay: 80.ms, duration: 280.ms)
                            .slideY(begin: 0.08, end: 0),
                        const SizedBox(height: 18),
                        _buildInvoiceDetailsCard(invoice)
                            .animate()
                            .fadeIn(delay: 100.ms, duration: 280.ms)
                            .slideY(begin: 0.08, end: 0),
                        const SizedBox(height: 18),
                        _buildItemsTable(invoice, provider)
                            .animate()
                            .fadeIn(delay: 120.ms, duration: 280.ms)
                            .slideY(begin: 0.08, end: 0),
                        const SizedBox(height: 18),
                        _buildTotalsCard(invoice)
                            .animate()
                            .fadeIn(delay: 140.ms, duration: 280.ms)
                            .slideY(begin: 0.08, end: 0),
                      ],
                    ),
                  const SizedBox(height: 28),
                  _buildActionPanel(context, invoice, provider)
                      .animate()
                      .fadeIn(delay: 180.ms, duration: 280.ms)
                      .slideY(begin: 0.08, end: 0),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context, InvoiceModel invoice) {
    final titleBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          invoice.invoiceNumber,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: context.isMobile ? 22 : 28,
            fontWeight: FontWeight.w800,
            color: _T.textDark,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 5),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.calendar_today_rounded,
                size: 12, color: _T.textMuted),
            const SizedBox(width: 5),
            Text(
              'Created ${invoice.createdAt.toFormattedDate()}',
              style: const TextStyle(fontSize: 12, color: _T.textMuted),
            ),
          ],
        ),
      ],
    );

    return LayoutBuilder(builder: (context, constraints) {
      final isNarrow = constraints.maxWidth < 600;
      if (isNarrow) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _IconBtn(
                    icon: Icons.arrow_back_rounded,
                    onTap: () => context.go('/invoices')),
                const SizedBox(width: 14),
                Expanded(child: titleBlock),
              ],
            ),
            const SizedBox(height: 14),
            _buildStatusBadge(invoice),
          ],
        );
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _IconBtn(
              icon: Icons.arrow_back_rounded,
              onTap: () => context.go('/invoices')),
          const SizedBox(width: 16),
          Expanded(child: titleBlock),
          const SizedBox(width: 16),
          _buildStatusBadge(invoice),
        ],
      );
    });
  }

  Widget _buildStatusBadge(InvoiceModel invoice) {
    late Color color;
    late String label;
    late IconData icon;

    switch (invoice.status) {
      case InvoiceStatus.draft:
        color = _T.textMuted;
        label = 'DRAFT';
        icon = Icons.edit_outlined;
        break;
      case InvoiceStatus.sent:
        color = _T.gradientStart;
        label = 'SENT';
        icon = Icons.send_outlined;
        break;
      case InvoiceStatus.paid:
        color = _T.success;
        label = 'PAID';
        icon = Icons.check_circle_outline_rounded;
        break;
      case InvoiceStatus.partiallyPaid:
        color = _T.warning;
        label = 'PARTIALLY PAID';
        icon = Icons.timelapse_rounded;
        break;
      case InvoiceStatus.overdue:
        color = _T.danger;
        label = 'OVERDUE';
        icon = Icons.error_outline_rounded;
        break;
      case InvoiceStatus.cancelled:
        color = _T.textMuted;
        label = 'CANCELLED';
        icon = Icons.cancel_outlined;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration:
                BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 7),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.4,
              decoration: invoice.status == InvoiceStatus.cancelled
                  ? TextDecoration.lineThrough
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  // ── Customer info card ────────────────────────────────────────────────────
  Widget _buildCustomerInfoCard(InvoiceModel invoice) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _T.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            title: 'Customer Details',
            subtitle: 'Billing information',
            icon: Icons.person_rounded,
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _T.gradientStart.withOpacity(0.06),
                  _T.gradientEnd.withOpacity(0.04),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: _T.gradientStart.withOpacity(0.1)),
            ),
            child: Row(
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
                  child: Center(
                    child: Text(
                      invoice.customerName.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    invoice.customerName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: _T.textDark,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (invoice.customerEmail != null) ...[
            _buildInfoRow(Icons.email_outlined, invoice.customerEmail!),
            const SizedBox(height: 10),
          ],
          if (invoice.customerPhone != null) ...[
            _buildInfoRow(Icons.phone_outlined, invoice.customerPhone!),
            const SizedBox(height: 10),
          ],
          if (invoice.customerAddress != null) ...[
            _buildInfoRow(
                Icons.location_on_outlined, invoice.customerAddress!),
            const SizedBox(height: 10),
          ],
          if (invoice.customerGst != null)
            _buildInfoRow(
                Icons.badge_outlined, 'GST: ${invoice.customerGst}'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: _T.gradientStart.withOpacity(0.07),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 14, color: _T.gradientStart),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Text(
              text,
              style: const TextStyle(
                  fontSize: 13, color: _T.textMid, height: 1.4),
            ),
          ),
        ),
      ],
    );
  }

  // ── Invoice details card ──────────────────────────────────────────────────
  Widget _buildInvoiceDetailsCard(InvoiceModel invoice) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _T.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            title: 'Invoice Details',
            subtitle: 'Billing summary',
            icon: Icons.receipt_rounded,
          ),
          Container(height: 1, margin: const EdgeInsets.symmetric(vertical: 16), color: _T.divider),
          _buildDetailRow('Invoice Number', invoice.invoiceNumber),
          _buildDetailRow('Invoice Date', invoice.invoiceDate.toFormattedDate()),
          _buildDetailRow('Due Date', invoice.dueDate.toFormattedDate()),
          _buildDetailRow(
            'Status',
            invoice.status.name.toUpperCase(),
            valueColor: invoice.status == InvoiceStatus.paid
                ? _T.success
                : invoice.status == InvoiceStatus.overdue
                    ? _T.danger
                    : null,
          ),
          _buildDetailRow(
            'Balance',
            '₹${invoice.balanceAmount.toStringAsFixed(2)}',
            valueColor:
                invoice.balanceAmount > 0 ? _T.danger : _T.success,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value,
      {Color? valueColor, bool isLast = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 11),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(
                bottom: BorderSide(color: _T.divider, width: 0.8)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(label,
                style: const TextStyle(
                    color: _T.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w500)),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: valueColor ?? _T.textDark,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Items table ───────────────────────────────────────────────────────────
  Widget _buildItemsTable(InvoiceModel invoice, InvoiceProvider provider) {
    final items = provider.selectedInvoiceItems;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _T.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            title: 'Invoice Items',
            subtitle: '${items.length} item(s)',
            icon: Icons.receipt_long_rounded,
          ),
          const SizedBox(height: 20),
          if (items.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text('No items loaded',
                    style: TextStyle(color: _T.textMuted)),
              ),
            )
          else
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Theme(
                  data: Theme.of(context)
                      .copyWith(dividerColor: _T.divider),
                  child: DataTable(
                    horizontalMargin: 16,
                    columnSpacing: 20,
                    headingRowHeight: 46,
                    dataRowMinHeight: 52,
                    dataRowMaxHeight: 60,
                    headingRowColor: MaterialStateProperty.all(
                        const Color(0xFFF8FAFC)),
                    headingTextStyle: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: _T.textMuted,
                      letterSpacing: 0.3,
                    ),
                    columns: const [
                      DataColumn(label: Text('PRODUCT')),
                      DataColumn(label: Text('HSN')),
                      DataColumn(label: Text('QTY')),
                      DataColumn(label: Text('PRICE')),
                      DataColumn(label: Text('GST%')),
                      DataColumn(label: Text('AMOUNT')),
                    ],
                    rows: items.map((item) {
                      return DataRow(cells: [
                        DataCell(SizedBox(
                          width: 140,
                          child: Text(
                            item.productName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: _T.textDark,
                              fontSize: 13,
                            ),
                          ),
                        )),
                        DataCell(Text(item.hsnCode ?? '-',
                            style: const TextStyle(
                                fontSize: 12, color: _T.textMuted))),
                        DataCell(Text(
                          '${item.quantity} ${item.unit}',
                          style: const TextStyle(
                              fontSize: 12, color: _T.textMid),
                        )),
                        DataCell(Text(
                          '₹${item.unitPrice.toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontSize: 12, color: _T.textMid),
                        )),
                        DataCell(Text(
                          '${item.taxRate}%',
                          style: const TextStyle(
                              fontSize: 12, color: _T.textMid),
                        )),
                        DataCell(Text(
                          '₹${item.amount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: _T.textDark,
                            fontSize: 13,
                          ),
                        )),
                      ]);
                    }).toList(),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Totals card ───────────────────────────────────────────────────────────
  Widget _buildTotalsCard(InvoiceModel invoice) {
    final cgst = invoice.taxAmount / 2;
    final sgst = invoice.taxAmount / 2;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _T.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            title: 'Payment Summary',
            subtitle: 'Invoice amount breakdown',
            icon: Icons.account_balance_wallet_rounded,
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _T.divider),
            ),
            child: Column(
              children: [
                _buildTotalRow(
                    'Subtotal',
                    '₹${invoice.subtotal.toStringAsFixed(2)}'),
                const SizedBox(height: 10),
                _buildTotalRow(
                    'CGST @ 9%', '₹${cgst.toStringAsFixed(2)}'),
                const SizedBox(height: 10),
                _buildTotalRow(
                    'SGST @ 9%', '₹${sgst.toStringAsFixed(2)}'),
                const SizedBox(height: 10),
                _buildTotalRow(
                  'Discount',
                  '-₹${invoice.discountAmount.toStringAsFixed(2)}',
                  valueColor: _T.warning,
                ),
                const SizedBox(height: 10),
                _buildTotalRow(
                    'Round Off',
                    '₹${invoice.roundOff.toStringAsFixed(2)}'),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
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
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Grand Total',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      fontSize: 15,
                    ),
                  ),
                ),
                Text(
                  '₹${invoice.grandTotalRounded.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    fontSize: 22,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _T.success.withOpacity(0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _T.success.withOpacity(0.15)),
            ),
            child: _buildTotalRow(
              'Paid Amount',
              '₹${invoice.paidAmount.toStringAsFixed(2)}',
              valueColor: _T.success,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: (invoice.balanceAmount > 0 ? _T.danger : _T.success)
                  .withOpacity(0.06),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: (invoice.balanceAmount > 0 ? _T.danger : _T.success)
                    .withOpacity(0.15),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  invoice.balanceAmount > 0
                      ? Icons.error_outline_rounded
                      : Icons.check_circle_outline_rounded,
                  color: invoice.balanceAmount > 0 ? _T.danger : _T.success,
                  size: 20,
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Balance Due',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: _T.textDark,
                    ),
                  ),
                ),
                Text(
                  '₹${invoice.balanceAmount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                    letterSpacing: -0.5,
                    color: invoice.balanceAmount > 0
                        ? _T.danger
                        : _T.success,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow(String label, String value, {Color? valueColor}) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
                color: _T.textMuted,
                fontWeight: FontWeight.w500,
                fontSize: 13),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: valueColor ?? _T.textDark,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  // ── Action panel ──────────────────────────────────────────────────────────
  Widget _buildActionPanel(
      BuildContext context, InvoiceModel invoice, InvoiceProvider provider) {
    final paymentProvider = context.read<PaymentProvider>();
    final recentPayments = paymentProvider.payments.take(3).toList();

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: _T.card(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionHeader(
                title: 'Actions',
                subtitle: 'Manage this invoice',
                icon: Icons.bolt_rounded,
              ),
              const SizedBox(height: 20),
              LayoutBuilder(builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 560;

                final buttons = <Widget>[
                  if (invoice.status == InvoiceStatus.draft)
                    _ActionBtn(
                      label: 'Mark as Sent',
                      icon: Icons.send_rounded,
                      gradient: _T.brandGradient,
                      shadowColor: _T.gradientStart.withOpacity(0.3),
                      onTap: () =>
                          _markAsSent(context, invoice, provider),
                    ),
                  if (!invoice.isPaid && !invoice.isCancelled)
                    _ActionBtn(
                      label: 'Record Payment',
                      icon: Icons.payments_rounded,
                      color: _T.success,
                      onTap: () => _showRecordPaymentDialog(
                          context, invoice, provider),
                    ),
                  _ActionBtn(
                    label: 'Download PDF',
                    icon: Icons.download_rounded,
                    color: _T.gradientStart,
                    outlined: true,
                    onTap: () => _downloadPdf(context, invoice, provider),
                  ),
                  if (invoice.status == InvoiceStatus.draft ||
                      invoice.status == InvoiceStatus.sent)
                    _ActionBtn(
                      label: 'Edit Invoice',
                      icon: Icons.edit_rounded,
                      color: _T.warning,
                      outlined: true,
                      onTap: () =>
                          context.push('/invoices/${invoice.id}/edit'),
                    ),
                  if (!invoice.isCancelled)
                    _ActionBtn(
                      label: 'Cancel Invoice',
                      icon: Icons.cancel_rounded,
                      color: _T.danger,
                      outlined: true,
                      onTap: () =>
                          _confirmCancel(context, invoice, provider),
                    ),
                ];

                if (isNarrow) {
                  return Column(
                    children: buttons
                        .map((b) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: b)))
                        .toList(),
                  );
                }

                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: buttons
                      .map((b) => SizedBox(height: 50, child: b))
                      .toList(),
                );
              }),
            ],
          ),
        ),
        if (recentPayments.isNotEmpty) ...[
          const SizedBox(height: 20),
          _buildPaymentHistory(context, recentPayments, invoice)
              .animate()
              .fadeIn(delay: 220.ms, duration: 280.ms)
              .slideY(begin: 0.08, end: 0),
        ],
      ],
    );
  }

  // ── Payment history ───────────────────────────────────────────────────────
  Widget _buildPaymentHistory(BuildContext context,
      List<PaymentModel> recentPayments, InvoiceModel invoice) {
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
                child: _sectionHeader(
                  title: 'Payment History',
                  subtitle: 'Recent payments received',
                  icon: Icons.payments_rounded,
                ),
              ),
              InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () =>
                    context.push('/invoices/${invoice.id}/payments'),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: _T.gradientStart.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: _T.gradientStart.withOpacity(0.15)),
                  ),
                  child: const Text(
                    'View All',
                    style: TextStyle(
                      color: _T.gradientStart,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ...recentPayments.asMap().entries.map((entry) {
            final i = entry.key;
            final payment = entry.value;
            final isLast = i == recentPayments.length - 1;
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                border: isLast
                    ? null
                    : const Border(
                        bottom:
                            BorderSide(color: _T.divider, width: 0.8)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _T.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.check_circle_rounded,
                        color: _T.success, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '₹${payment.amount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: _T.textDark,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${payment.mode.name.toUpperCase()} · ${payment.paymentDate.toFormattedDate()}',
                          style: const TextStyle(
                              fontSize: 11, color: _T.textMuted),
                        ),
                      ],
                    ),
                  ),
                  if (payment.reference != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _T.gradientStart.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        payment.reference!,
                        style: const TextStyle(
                            fontSize: 10,
                            color: _T.gradientStart,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ── Section header ────────────────────────────────────────────────────────
  Widget _sectionHeader({
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

  // ── Business logic ────────────────────────────────────────────────────────
  Future<void> _markAsSent(BuildContext context, InvoiceModel invoice,
      InvoiceProvider provider) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await provider.markAsSent(invoice.id);
      if (mounted) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Invoice marked as sent'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('Failed to mark as sent: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _downloadPdf(BuildContext context, InvoiceModel invoice,
      InvoiceProvider provider) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final items = provider.selectedInvoiceItems;
      final htmlContent =
          _pdfService.generateInvoiceHtml(invoice: invoice, items: items);
      final fileName =
          'invoice_${invoice.invoiceNumber.replaceAll('/', '_')}.html';
      await downloadInvoiceHtml(htmlContent: htmlContent, fileName: fileName);
      if (mounted) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Invoice downloaded successfully'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('Failed to download invoice: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showRecordPaymentDialog(BuildContext context, InvoiceModel invoice,
      InvoiceProvider provider) {
    final amountController = TextEditingController();
    final referenceController = TextEditingController();
    final notesController = TextEditingController();
    PaymentMode selectedMode = PaymentMode.cash;
    DateTime paymentDate = DateTime.now();

    showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: _T.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22)),
              title: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: _T.brandGradient,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.payments_rounded,
                        color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 12),
                  const Text('Record Payment',
                      style: TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 17)),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _T.danger.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: _T.danger.withOpacity(0.15)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline_rounded,
                              size: 14, color: _T.danger),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Balance Due: ₹${invoice.balanceAmount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: _T.danger,
                                  fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: amountController,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Amount *',
                        prefixIcon:
                            const Icon(Icons.currency_rupee_rounded),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: _T.divider),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: paymentDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2035),
                        );
                        if (picked != null) {
                          setDialogState(() => paymentDate = picked);
                        }
                      },
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Payment Date',
                          prefixIcon:
                              const Icon(Icons.calendar_month_rounded),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14)),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide:
                                const BorderSide(color: _T.divider),
                          ),
                        ),
                        child: Text(
                          DateFormat('dd/MM/yyyy').format(paymentDate),
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<PaymentMode>(
                      value: selectedMode,
                      borderRadius: BorderRadius.circular(14),
                      decoration: InputDecoration(
                        labelText: 'Payment Mode',
                        prefixIcon: const Icon(Icons.payment_rounded),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: _T.divider),
                        ),
                      ),
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() => selectedMode = value);
                        }
                      },
                      items: PaymentMode.values.map((mode) {
                        return DropdownMenuItem(
                          value: mode,
                          child: Text(mode.name.toUpperCase()),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: referenceController,
                      decoration: InputDecoration(
                        labelText: 'Reference',
                        hintText: 'e.g. Transaction ID',
                        prefixIcon: const Icon(Icons.tag),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: _T.divider),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: notesController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: 'Notes',
                        hintText: 'Optional notes...',
                        prefixIcon: const Icon(Icons.note_outlined),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: _T.divider),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel',
                      style: TextStyle(color: _T.textMuted)),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: _T.brandGradient,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: _T.gradientStart.withOpacity(0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: TextButton(
                    onPressed: () async {
                      final amount =
                          double.tryParse(amountController.text);
                      if (amount == null || amount <= 0) {
                        context.showSnackBar(
                            'Please enter a valid amount',
                            isError: true);
                        return;
                      }
                      if (amount > invoice.balanceAmount) {
                        context.showSnackBar(
                            'Amount exceeds balance due',
                            isError: true);
                        return;
                      }
                      try {
                        await context.read<PaymentProvider>().recordPayment(
                              invoiceId: invoice.id,
                              amount: amount,
                              paymentDate: paymentDate,
                              mode: selectedMode,
                              reference: referenceController.text
                                      .trim()
                                      .isEmpty
                                  ? null
                                  : referenceController.text.trim(),
                              notes: notesController.text.trim().isEmpty
                                  ? null
                                  : notesController.text.trim(),
                            );
                        if (context.mounted) {
                          Navigator.pop(context);
                          await provider
                              .loadInvoiceDetails(invoice.id);
                          context.showSnackBar(
                              'Payment recorded successfully');
                        }
                      } catch (e) {
                        if (context.mounted) {
                          context.showSnackBar(
                              'Failed to record payment: $e',
                              isError: true);
                        }
                      }
                    },
                    child: const Text('Record',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmCancel(BuildContext context, InvoiceModel invoice,
      InvoiceProvider provider) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: _T.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22)),
          title: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _T.danger.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.cancel_outlined,
                    color: _T.danger, size: 18),
              ),
              const SizedBox(width: 12),
              const Text('Cancel Invoice?',
                  style: TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 17)),
            ],
          ),
          content: Text(
            'Are you sure you want to cancel invoice "${invoice.invoiceNumber}"? This action cannot be undone.',
            style: const TextStyle(
                color: _T.textMuted, fontSize: 14, height: 1.6),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('No, Keep It',
                  style: TextStyle(color: _T.textMuted)),
            ),
            Container(
              decoration: BoxDecoration(
                color: _T.danger,
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextButton(
                onPressed: () async {
                  try {
                    await provider.cancelInvoice(invoice.id);
                    if (context.mounted) {
                      Navigator.pop(context);
                      context.showSnackBar(
                          'Invoice cancelled successfully');
                    }
                  } catch (e) {
                    if (context.mounted) {
                      Navigator.pop(context);
                      context.showSnackBar(
                          'Failed to cancel invoice: $e',
                          isError: true);
                    }
                  }
                },
                child: const Text('Cancel Invoice',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ── Icon button ───────────────────────────────────────────────────────────
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
            color: _hovered
                ? _T.gradientStart.withOpacity(0.06)
                : _T.white,
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

// ── Action button ─────────────────────────────────────────────────────────
class _ActionBtn extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Gradient? gradient;
  final Color? color;
  final Color? shadowColor;
  final bool outlined;

  const _ActionBtn({
    required this.label,
    required this.icon,
    required this.onTap,
    this.gradient,
    this.color,
    this.shadowColor,
    this.outlined = false,
  });

  @override
  State<_ActionBtn> createState() => _ActionBtnState();
}

class _ActionBtnState extends State<_ActionBtn> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final baseColor = widget.color ?? _T.gradientStart;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          transform: Matrix4.identity()
            ..scale(_hovered ? 1.02 : 1.0),
          transformAlignment: Alignment.center,
          padding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
          decoration: BoxDecoration(
            gradient: widget.outlined ? null : widget.gradient,
            color: widget.outlined
                ? (_hovered
                    ? baseColor.withOpacity(0.08)
                    : _T.white)
                : (widget.gradient == null ? baseColor : null),
            borderRadius: BorderRadius.circular(13),
            border: widget.outlined
                ? Border.all(
                    color: _hovered
                        ? baseColor.withOpacity(0.5)
                        : baseColor.withOpacity(0.3),
                  )
                : null,
            boxShadow: !widget.outlined
                ? [
                    BoxShadow(
                      color: widget.shadowColor ??
                          baseColor.withOpacity(0.28),
                      blurRadius: _hovered ? 16 : 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                size: 16,
                color: widget.outlined ? baseColor : Colors.white,
              ),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: widget.outlined ? baseColor : Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
