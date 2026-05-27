import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:smarterp/core/constants/app_constants.dart';
import 'package:smarterp/core/extensions/context_extensions.dart';
import 'package:smarterp/core/extensions/date_extensions.dart';
import 'package:smarterp/core/theme/theme_extensions.dart';
import 'package:smarterp/core/widgets/app_shell.dart';
import 'package:smarterp/core/widgets/app_card.dart';
import 'package:smarterp/core/widgets/app_button.dart';
import 'package:smarterp/core/widgets/status_badge.dart';
import 'package:smarterp/core/models/invoice_model.dart';
import 'package:smarterp/modules/invoice/providers/invoice_provider.dart';
import 'package:smarterp/modules/invoice/services/pdf_service.dart';

class InvoiceDetailScreen extends StatefulWidget {
  final String invoiceId;

  const InvoiceDetailScreen({super.key, required this.invoiceId});

  @override
  State<InvoiceDetailScreen> createState() => _InvoiceDetailScreenState();
}

class _InvoiceDetailScreenState extends State<InvoiceDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InvoiceProvider>().loadInvoiceDetails(widget.invoiceId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final theme = context.theme;

    return AppShell(
      child: Consumer<InvoiceProvider>(
        builder: (context, provider, _) {
          final invoice = provider.selectedInvoice;

          if (provider.isLoading || invoice == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, invoice, provider),
                const SizedBox(height: 24),
                _buildCustomerInfo(context, invoice),
                const SizedBox(height: 16),
                _buildItemsTable(context, provider),
                const SizedBox(height: 16),
                _buildTotals(context, invoice),
                const SizedBox(height: 16),
                _buildNotes(context, invoice),
                const SizedBox(height: 24),
                _buildActions(context, invoice, provider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, InvoiceModel invoice, InvoiceProvider provider) {
    final statusColor = _getStatusColor(invoice.status);

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                invoice.invoiceNumber,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  StatusBadge(
                    label: invoice.status.name,
                    color: statusColor,
                    icon: _getStatusIcon(invoice.status),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Created: ${invoice.createdAt.toFormattedDate()}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '₹${invoice.totalAmount.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 4),
            if (invoice.paidAmount > 0)
              Text(
                'Paid: ₹${invoice.paidAmount.toStringAsFixed(2)}',
                style: TextStyle(color: Colors.green.shade700),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildCustomerInfo(BuildContext context, InvoiceModel invoice) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Customer Details', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          _infoRow(Icons.person_outline, invoice.customerName),
          if (invoice.customerPhone != null && invoice.customerPhone!.isNotEmpty)
            _infoRow(Icons.phone_outlined, invoice.customerPhone!),
          if (invoice.customerEmail != null && invoice.customerEmail!.isNotEmpty)
            _infoRow(Icons.email_outlined, invoice.customerEmail!),
          if (invoice.customerAddress != null && invoice.customerAddress!.isNotEmpty)
            _infoRow(Icons.location_on_outlined, invoice.customerAddress!),
          if (invoice.customerGst != null && invoice.customerGst!.isNotEmpty)
            _infoRow(Icons.receipt_outlined, 'GST: ${invoice.customerGst!}'),
          const SizedBox(height: 8),
          Row(
            children: [
              _infoRow(Icons.calendar_today, 'Invoice: ${invoice.invoiceDate.toFormattedDate()}'),
              const SizedBox(width: 24),
              _infoRow(Icons.event, 'Due: ${invoice.dueDate.toFormattedDate()}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItemsTable(BuildContext context, InvoiceProvider provider) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Items', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          if (provider.selectedInvoiceItems.isEmpty)
            const Text('No items found')
          else
            Table(
              columnWidths: const {
                0: FlexColumnWidth(3),
                1: FlexColumnWidth(1),
                2: FlexColumnWidth(1.5),
                3: FlexColumnWidth(1),
                4: FlexColumnWidth(1.5),
              },
              children: [
                TableRow(
                 decoration: BoxDecoration(
                     border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
                   ),
                  children: const [
                    _TableHeader('Item'),
                    _TableHeader('Qty'),
                    _TableHeader('Price'),
                    _TableHeader('GST'),
                    _TableHeader('Total'),
                  ],
                ),
                ...provider.selectedInvoiceItems.map((item) {
                  return TableRow(
                    children: [
                      _TableCell(item.productName),
                      _TableCell(item.quantity.toString()),
                      _TableCell('₹${item.unitPrice.toStringAsFixed(2)}'),
                      _TableCell('${item.taxRate.toStringAsFixed(0)}%'),
                      _TableCell('₹${item.subtotal.toStringAsFixed(2)}'),
                    ],
                  );
                }),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildTotals(BuildContext context, InvoiceModel invoice) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Summary', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          _totalRow('Subtotal', invoice.subtotal),
          _totalRow('Tax', invoice.taxAmount),
          if (invoice.discountAmount > 0)
            _totalRow('Discount', -invoice.discountAmount),
          const Divider(height: 24),
          Row(
            children: [
              const Text('Total', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const Spacer(),
              Text(
                '₹${invoice.totalAmount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotes(BuildContext context, InvoiceModel invoice) {
    if ((invoice.notes == null || invoice.notes!.isEmpty) &&
        (invoice.termsAndConditions == null || invoice.termsAndConditions!.isEmpty)) {
      return const SizedBox.shrink();
    }

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (invoice.notes != null && invoice.notes!.isNotEmpty) ...[
            Text('Notes', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(invoice.notes!, style: Theme.of(context).textTheme.bodyMedium),
          ],
          if (invoice.termsAndConditions != null && invoice.termsAndConditions!.isNotEmpty) ...[
            if (invoice.notes != null && invoice.notes!.isNotEmpty)
              const SizedBox(height: 16),
            Text('Terms & Conditions', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(invoice.termsAndConditions!, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context, InvoiceModel invoice, InvoiceProvider provider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (invoice.status == InvoiceStatus.draft)
          FilledButton.icon(
            onPressed: () => provider.markAsSent(invoice.id),
            icon: const Icon(Icons.send, size: 18),
            label: const Text('Send Invoice'),
          ),
        if (invoice.status == InvoiceStatus.sent || invoice.status == InvoiceStatus.partiallyPaid)
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: FilledButton.tonalIcon(
              onPressed: () => _showPaymentDialog(context, provider, invoice),
              icon: const Icon(Icons.payments, size: 18),
              label: const Text('Record Payment'),
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(left: 12),
          child: OutlinedButton.icon(
            onPressed: () => _downloadPdf(context, provider, invoice),
            icon: const Icon(Icons.download, size: 18),
            label: const Text('Download PDF'),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 12),
          child: OutlinedButton.icon(
            onPressed: () => context.push('/invoices/${invoice.id}/payments'),
            icon: const Icon(Icons.history, size: 18),
            label: const Text('Payment History'),
          ),
        ),
        if (invoice.status != InvoiceStatus.cancelled)
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: OutlinedButton.icon(
              onPressed: () => _confirmCancel(context, provider, invoice),
              icon: const Icon(Icons.cancel_outlined, size: 18),
              label: const Text('Cancel'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
      ],
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Text(text, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }

  Widget _totalRow(String label, double amount) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          const Spacer(),
          Text(
            '₹${amount.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.draft:
        return Colors.grey;
      case InvoiceStatus.sent:
        return Colors.blue;
      case InvoiceStatus.paid:
        return Colors.green;
      case InvoiceStatus.partiallyPaid:
        return Colors.orange;
      case InvoiceStatus.overdue:
        return Colors.red;
      case InvoiceStatus.cancelled:
        return Colors.grey.shade700;
    }
  }

  IconData? _getStatusIcon(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.draft:
        return Icons.edit_note;
      case InvoiceStatus.sent:
        return Icons.send;
      case InvoiceStatus.paid:
        return Icons.check_circle;
      case InvoiceStatus.partiallyPaid:
        return Icons.payments;
      case InvoiceStatus.overdue:
        return Icons.warning;
      case InvoiceStatus.cancelled:
        return Icons.cancel;
    }
  }

  void _showPaymentDialog(BuildContext context, InvoiceProvider provider, InvoiceModel invoice) {
    final amountController = TextEditingController();
    final remaining = invoice.totalAmount - invoice.paidAmount;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Record Payment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Total: ₹${invoice.totalAmount.toStringAsFixed(2)}'),
            Text('Paid: ₹${invoice.paidAmount.toStringAsFixed(2)}'),
            Text('Remaining: ₹${remaining.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: amountController,
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixText: '₹ ',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final amount = double.tryParse(amountController.text) ?? 0;
              if (amount > 0) {
                Navigator.pop(ctx);
                provider.markAsPaid(invoice.id, amount);
              }
            },
            child: const Text('Record'),
          ),
        ],
      ),
    );
  }

  Future<void> _downloadPdf(BuildContext context, InvoiceProvider provider, InvoiceModel invoice) async {
    final pdfService = PdfService();
    try {
      final items = provider.selectedInvoiceItems;
      if (items.isEmpty) return;

      final path = await pdfService.saveHtmlToFile(invoice: invoice, items: items);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invoice saved to: $path')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to generate invoice'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _confirmCancel(BuildContext context, InvoiceProvider provider, InvoiceModel invoice) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Invoice'),
        content: Text('Cancel invoice ${invoice.invoiceNumber}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('No'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              provider.cancelInvoice(invoice.id);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  final String text;
  const _TableHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _TableCell extends StatelessWidget {
  final String text;
  const _TableCell(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Text(text, style: const TextStyle(fontSize: 13)),
    );
  }
}
