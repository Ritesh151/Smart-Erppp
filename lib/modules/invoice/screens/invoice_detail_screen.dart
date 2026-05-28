import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:SmartERP/core/extensions/context_extensions.dart';
import 'package:SmartERP/core/extensions/date_extensions.dart';
import 'package:SmartERP/core/models/invoice_model.dart';
import 'package:SmartERP/core/models/payment_model.dart';
import 'package:SmartERP/core/utils/download_helper.dart';
import 'package:SmartERP/core/widgets/app_button.dart';
import 'package:SmartERP/modules/invoice/providers/invoice_provider.dart';
import 'package:SmartERP/modules/invoice/providers/payment_provider.dart';
import 'package:SmartERP/modules/invoice/services/pdf_service.dart';

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

  static BoxDecoration card({
    double radius = 20,
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
          blurRadius: 20,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }
}

class InvoiceDetailScreen extends StatefulWidget {
  final String invoiceId;

  const InvoiceDetailScreen({
    super.key,
    required this.invoiceId,
  });

  @override
  State<InvoiceDetailScreen> createState() =>
      _InvoiceDetailScreenState();
}

class _InvoiceDetailScreenState
    extends State<InvoiceDetailScreen> {
  final _pdfService = PdfService();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final invoiceProvider = context.read<InvoiceProvider>();
      invoiceProvider.loadInvoiceDetails(widget.invoiceId);

      final paymentProvider = context.read<PaymentProvider>();
      paymentProvider.loadPaymentsForInvoice(widget.invoiceId);
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
                color: _T.gradientStart,
              ),
            ),
          );
        }

        return Container(
          color: _T.bg,
          child: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(
                context.isMobile ? 16 : 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, invoice)
                      .animate()
                      .fadeIn(duration: 280.ms)
                      .slideX(begin: -0.04, end: 0),

                  SizedBox(
                    height: context.isMobile ? 18 : 26,
                  ),

                  if (context.isDesktop)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 5,
                          child: _buildCustomerInfoCard(
                            invoice,
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          flex: 7,
                          child: Column(
                            children: [
                              _buildInvoiceDetailsCard(
                                invoice,
                              ),
                              const SizedBox(height: 18),
                              _buildItemsTable(invoice, provider),
                              const SizedBox(height: 18),
                              _buildTotalsCard(invoice),
                            ],
                          ),
                        ),
                      ],
                    )
                  else
                    Column(
                      children: [
                        _buildCustomerInfoCard(invoice),
                        const SizedBox(height: 18),
                        _buildInvoiceDetailsCard(invoice),
                        const SizedBox(height: 18),
                        _buildItemsTable(invoice, provider),
                        const SizedBox(height: 18),
                        _buildTotalsCard(invoice),
                      ],
                    ),

                  const SizedBox(height: 28),

                  _buildActionPanel(
                    context,
                    invoice,
                    provider,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(
    BuildContext context,
    InvoiceModel invoice,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final vertical = constraints.maxWidth < 700;

        if (vertical) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () {
                      context.go('/invoices');
                    },
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
                          invoice.invoiceNumber,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: context.isMobile ? 24 : 30,
                            fontWeight: FontWeight.w800,
                            color: _T.textDark,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Created ${invoice.createdAt.toFormattedDate()}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: _T.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _buildStatusBadge(invoice),
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
                    onTap: () {
                      context.go('/invoices');
                    },
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
                          invoice.invoiceNumber,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: context.isMobile ? 24 : 30,
                            fontWeight: FontWeight.w800,
                            color: _T.textDark,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Created ${invoice.createdAt.toFormattedDate()}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: _T.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 18),
            _buildStatusBadge(invoice),
          ],
        );
      },
    );
  }

  Widget _buildStatusBadge(InvoiceModel invoice) {
    late Color color;
    late String label;

    switch (invoice.status) {
      case InvoiceStatus.draft:
        color = _T.textMuted;
        label = 'DRAFT';
        break;
      case InvoiceStatus.sent:
        color = _T.gradientStart;
        label = 'SENT';
        break;
      case InvoiceStatus.paid:
        color = _T.success;
        label = 'PAID';
        break;
      case InvoiceStatus.partiallyPaid:
        color = _T.warning;
        label = 'PARTIALLY PAID';
        break;
      case InvoiceStatus.overdue:
        color = _T.danger;
        label = 'OVERDUE';
        break;
      case InvoiceStatus.cancelled:
        color = _T.textMuted;
        label = 'CANCELLED';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: color.withOpacity(0.18),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.3,
          decoration: invoice.status == InvoiceStatus.cancelled
              ? TextDecoration.lineThrough
              : null,
        ),
      ),
    );
  }

  Widget _buildCustomerInfoCard(InvoiceModel invoice) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: _T.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            title: 'Customer Details',
            subtitle: 'Billing information',
            icon: Icons.person_rounded,
          ),
          const SizedBox(height: 24),
          Text(
            invoice.customerName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: _T.textDark,
            ),
          ),
          const SizedBox(height: 16),
          if (invoice.customerEmail != null) ...[
            _buildInfoRow(
              Icons.email_outlined,
              invoice.customerEmail!,
            ),
            const SizedBox(height: 12),
          ],
          if (invoice.customerPhone != null) ...[
            _buildInfoRow(
              Icons.phone_outlined,
              invoice.customerPhone!,
            ),
            const SizedBox(height: 12),
          ],
          if (invoice.customerAddress != null) ...[
            _buildInfoRow(
              Icons.location_on_outlined,
              invoice.customerAddress!,
            ),
            const SizedBox(height: 12),
          ],
          if (invoice.customerGst != null) ...[
            _buildInfoRow(
              Icons.badge_outlined,
              'GST: ${invoice.customerGst}',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: _T.textMuted,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: _T.textMid,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInvoiceDetailsCard(InvoiceModel invoice) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: _T.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            title: 'Invoice Details',
            subtitle: 'Billing summary',
            icon: Icons.receipt_rounded,
          ),
          const SizedBox(height: 24),
          _buildDetailRow('Invoice Number', invoice.invoiceNumber),
          const SizedBox(height: 16),
          _buildDetailRow(
            'Invoice Date',
            invoice.invoiceDate.toFormattedDate(),
          ),
          const SizedBox(height: 16),
          _buildDetailRow(
            'Due Date',
            invoice.dueDate.toFormattedDate(),
          ),
          const SizedBox(height: 16),
          _buildDetailRow(
            'Status',
            invoice.status.name.toUpperCase(),
            valueColor: invoice.status == InvoiceStatus.paid
                ? _T.success
                : invoice.status == InvoiceStatus.overdue
                    ? _T.danger
                    : null,
          ),
          const SizedBox(height: 16),
          _buildDetailRow(
            'Balance',
            '₹${invoice.balanceAmount.toStringAsFixed(2)}',
            valueColor: invoice.balanceAmount > 0
                ? _T.danger
                : _T.success,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: _T.divider,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: _T.textMuted,
                fontSize: 13,
              ),
            ),
          ),
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

  Widget _buildItemsTable(
    InvoiceModel invoice,
    InvoiceProvider provider,
  ) {
    final items = provider.selectedInvoiceItems;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: _T.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            title: 'Invoice Items',
            subtitle: '${items.length} item(s)',
            icon: Icons.receipt_long_rounded,
          ),
          const SizedBox(height: 24),
          if (items.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: Text(
                  'No items loaded',
                  style: TextStyle(
                    color: _T.textMuted,
                  ),
                ),
              ),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                horizontalMargin: 16,
                columnSpacing: 20,
                headingRowHeight: 44,
                dataRowMinHeight: 48,
                headingRowColor: MaterialStateProperty.all(
                  const Color(0xFFF8FAFC),
                ),
                columns: const [
                  DataColumn(label: Text('Product')),
                  DataColumn(label: Text('HSN')),
                  DataColumn(label: Text('Qty')),
                  DataColumn(label: Text('Price')),
                  DataColumn(label: Text('GST%')),
                  DataColumn(label: Text('Amount')),
                ],
                rows: items.map((item) {
                  return DataRow(
                    cells: [
                      DataCell(
                        SizedBox(
                          width: 140,
                          child: Text(
                            item.productName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      DataCell(Text(item.hsnCode ?? '-')),
                      DataCell(Text('${item.quantity} ${item.unit}')),
                      DataCell(
                        Text(
                          '₹${item.unitPrice.toStringAsFixed(2)}',
                        ),
                      ),
                      DataCell(Text('${item.taxRate}%')),
                      DataCell(
                        Text(
                          '₹${item.amount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTotalsCard(InvoiceModel invoice) {
    final cgst = invoice.taxAmount / 2;
    final sgst = invoice.taxAmount / 2;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: _T.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            title: 'Payment Summary',
            subtitle: 'Invoice amount breakdown',
            icon: Icons.account_balance_wallet_rounded,
          ),
          const SizedBox(height: 24),
          _buildTotalRow('Subtotal', '₹${invoice.subtotal.toStringAsFixed(2)}'),
          const SizedBox(height: 8),
          _buildTotalRow('CGST @ 9%', '₹${cgst.toStringAsFixed(2)}'),
          const SizedBox(height: 8),
          _buildTotalRow('SGST @ 9%', '₹${sgst.toStringAsFixed(2)}'),
          const SizedBox(height: 8),
          _buildTotalRow(
            'Discount',
            '-₹${invoice.discountAmount.toStringAsFixed(2)}',
            valueColor: _T.warning,
          ),
          const SizedBox(height: 8),
          _buildTotalRow('Round Off', '₹${invoice.roundOff.toStringAsFixed(2)}'),
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
                  '₹${invoice.grandTotalRounded.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _buildTotalRow(
            'Paid Amount',
            '₹${invoice.paidAmount.toStringAsFixed(2)}',
            valueColor: _T.success,
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: (invoice.balanceAmount > 0
                      ? _T.danger
                      : _T.success)
                  .withOpacity(0.06),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: (invoice.balanceAmount > 0
                        ? _T.danger
                        : _T.success)
                    .withOpacity(0.15),
              ),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Balance Due',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: _T.textDark,
                    ),
                  ),
                ),
                Text(
                  '₹${invoice.balanceAmount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
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

  Widget _buildTotalRow(
    String label,
    String value, {
    Color? valueColor,
  }) {
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
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: valueColor ?? _T.textDark,
          ),
        ),
      ],
    );
  }

  Widget _buildActionPanel(
    BuildContext context,
    InvoiceModel invoice,
    InvoiceProvider provider,
  ) {
    final paymentProvider = context.read<PaymentProvider>();
    final recentPayments = paymentProvider.payments.take(3).toList();

    return Column(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final vertical = constraints.maxWidth < 620;

            if (vertical) {
              return Column(
                children: [
                  if (invoice.status == InvoiceStatus.draft) ...[
                    SizedBox(
                      height: 54,
                      child: AppButton(
                        text: 'Mark as Sent',
                        variant: AppButtonVariant.primary,
                        onPressed: () =>
                            _markAsSent(context, invoice, provider),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (!invoice.isPaid &&
                      !invoice.isCancelled) ...[
                    SizedBox(
                      height: 54,
                      child: AppButton(
                        text: 'Record Payment',
                        variant: AppButtonVariant.secondary,
                        onPressed: () =>
                            _showRecordPaymentDialog(
                          context,
                          invoice,
                          provider,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  SizedBox(
                    height: 54,
                    child: AppButton(
                      text: 'Download PDF',
                      variant: AppButtonVariant.outline,
                      icon: Icons.download_rounded,
                      onPressed: () =>
                          _downloadPdf(context, invoice, provider),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (invoice.status == InvoiceStatus.draft ||
                      invoice.status == InvoiceStatus.sent) ...[
                    SizedBox(
                      height: 54,
                      child: AppButton(
                        text: 'Edit Invoice',
                        variant: AppButtonVariant.outline,
                        onPressed: () {
                          context.push('/invoices/${invoice.id}/edit');
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (!invoice.isCancelled) ...[
                    SizedBox(
                      height: 54,
                      child: AppButton(
                        text: 'Cancel Invoice',
                        variant: AppButtonVariant.danger,
                        onPressed: () =>
                            _confirmCancel(context, invoice, provider),
                      ),
                    ),
                  ],
                ],
              );
            }

            return Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.start,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                if (invoice.status == InvoiceStatus.draft)
                  SizedBox(
                    height: 54,
                    child: AppButton(
                      text: 'Mark as Sent',
                      variant: AppButtonVariant.primary,
                      onPressed: () =>
                          _markAsSent(context, invoice, provider),
                    ),
                  ),
                if (!invoice.isPaid && !invoice.isCancelled)
                  SizedBox(
                    height: 54,
                    child: AppButton(
                      text: 'Record Payment',
                      variant: AppButtonVariant.secondary,
                      onPressed: () =>
                          _showRecordPaymentDialog(
                        context,
                        invoice,
                        provider,
                      ),
                    ),
                  ),
                SizedBox(
                  height: 54,
                  child: AppButton(
                    text: 'Download PDF',
                    variant: AppButtonVariant.outline,
                    icon: Icons.download_rounded,
                    onPressed: () =>
                        _downloadPdf(context, invoice, provider),
                  ),
                ),
                if (invoice.status == InvoiceStatus.draft ||
                    invoice.status == InvoiceStatus.sent)
                  SizedBox(
                    height: 54,
                    child: AppButton(
                      text: 'Edit Invoice',
                      variant: AppButtonVariant.outline,
                      onPressed: () {
                        context.push('/invoices/${invoice.id}/edit');
                      },
                    ),
                  ),
                if (!invoice.isCancelled)
                  SizedBox(
                    height: 54,
                    child: AppButton(
                      text: 'Cancel Invoice',
                      variant: AppButtonVariant.danger,
                      onPressed: () =>
                          _confirmCancel(context, invoice, provider),
                    ),
                  ),
              ],
            );
          },
        ),
        if (recentPayments.isNotEmpty) ...[
          const SizedBox(height: 28),
          _buildPaymentHistory(context, recentPayments, invoice),
        ],
      ],
    );
  }

  Widget _buildPaymentHistory(
    BuildContext context,
    List<PaymentModel> recentPayments,
    InvoiceModel invoice,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
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
                borderRadius: BorderRadius.circular(14),
                onTap: () {
                  context.push('/invoices/${invoice.id}/payments');
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: _T.gradientStart.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(14),
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
          const SizedBox(height: 20),
          ...recentPayments.map((payment) {
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: _T.divider,
                  ),
                ),
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
                    child: const Icon(
                      Icons.check_circle_rounded,
                      color: _T.success,
                      size: 20,
                    ),
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
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${payment.mode.name.toUpperCase()} - ${payment.paymentDate.toFormattedDate()}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: _T.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (payment.reference != null)
                    Text(
                      payment.reference!,
                      style: const TextStyle(
                        fontSize: 11,
                        color: _T.textLight,
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

  Widget _sectionHeader({
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

  Future<void> _markAsSent(
    BuildContext context,
    InvoiceModel invoice,
    InvoiceProvider provider,
  ) async {
    try {
      await provider.markAsSent(invoice.id);
      if (mounted) {
        context.showSnackBar('Invoice marked as sent');
      }
    } catch (e) {
      if (mounted) {
        context.showSnackBar(
          'Failed to mark as sent: $e',
          isError: true,
        );
      }
    }
  }

  Future<void> _downloadPdf(
    BuildContext context,
    InvoiceModel invoice,
    InvoiceProvider provider,
  ) async {
    try {
      final items = provider.selectedInvoiceItems;
      final htmlContent = _pdfService.generateInvoiceHtml(
        invoice: invoice,
        items: items,
      );

      final fileName = 'invoice_${invoice.invoiceNumber.replaceAll('/', '_')}.html';

      await downloadInvoiceHtml(
        htmlContent: htmlContent,
        fileName: fileName,
      );

      if (mounted) {
        context.showSnackBar('Invoice downloaded successfully');
      }
    } catch (e) {
      if (mounted) {
        context.showSnackBar(
          'Failed to download invoice: $e',
          isError: true,
        );
      }
    }
  }

  void _showRecordPaymentDialog(
    BuildContext context,
    InvoiceModel invoice,
    InvoiceProvider provider,
  ) {
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              title: const Text(
                'Record Payment',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Invoice: ${invoice.invoiceNumber}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: _T.textMuted,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Balance Due: ₹${invoice.balanceAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: _T.danger,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: amountController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Amount *',
                        prefixIcon: const Icon(Icons.currency_rupee_rounded),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: paymentDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2035),
                        );
                        if (picked != null) {
                          setDialogState(() {
                            paymentDate = picked;
                          });
                        }
                      },
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Payment Date',
                          prefixIcon: const Icon(Icons.calendar_month_rounded),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          DateFormat('dd/MM/yyyy').format(paymentDate),
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<PaymentMode>(
                      value: selectedMode,
                      borderRadius: BorderRadius.circular(16),
                      decoration: InputDecoration(
                        labelText: 'Payment Mode',
                        prefixIcon: const Icon(Icons.payment_rounded),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() {
                            selectedMode = value;
                          });
                        }
                      },
                      items: PaymentMode.values.map((mode) {
                        return DropdownMenuItem(
                          value: mode,
                          child: Text(mode.name.toUpperCase()),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: referenceController,
                      decoration: InputDecoration(
                        labelText: 'Reference',
                        hintText: 'e.g. Transaction ID',
                        prefixIcon: const Icon(Icons.tag),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: notesController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: 'Notes',
                        hintText: 'Optional notes...',
                        prefixIcon: const Icon(Icons.note_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
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
                    onPressed: () async {
                      final amount =
                          double.tryParse(amountController.text);

                      if (amount == null || amount <= 0) {
                        context.showSnackBar(
                          'Please enter a valid amount',
                          isError: true,
                        );
                        return;
                      }

                      if (amount > invoice.balanceAmount) {
                        context.showSnackBar(
                          'Amount exceeds balance due',
                          isError: true,
                        );
                        return;
                      }

                      try {
                        await context
                            .read<PaymentProvider>()
                            .recordPayment(
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

                          await provider.loadInvoiceDetails(invoice.id);

                          context.showSnackBar(
                            'Payment recorded successfully',
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          context.showSnackBar(
                            'Failed to record payment: $e',
                            isError: true,
                          );
                        }
                      }
                    },
                    child: const Text(
                      'Record',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmCancel(
    BuildContext context,
    InvoiceModel invoice,
    InvoiceProvider provider,
  ) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Text(
            'Cancel Invoice?',
            style: TextStyle(
              fontWeight: FontWeight.w800,
            ),
          ),
          content: Text(
            'Are you sure you want to cancel invoice "${invoice.invoiceNumber}"? This action cannot be undone.',
            style: const TextStyle(
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('No, Keep It'),
            ),
            Container(
              decoration: BoxDecoration(
                color: _T.danger,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextButton(
                onPressed: () async {
                  try {
                    await provider.cancelInvoice(invoice.id);

                    if (context.mounted) {
                      Navigator.pop(context);
                      context.showSnackBar(
                        'Invoice cancelled successfully',
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      Navigator.pop(context);
                      context.showSnackBar(
                        'Failed to cancel invoice: $e',
                        isError: true,
                      );
                    }
                  }
                },
                child: const Text(
                  'Cancel Invoice',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
