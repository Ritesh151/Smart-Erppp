import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smarterp/core/constants/app_constants.dart';
import 'package:smarterp/core/extensions/context_extensions.dart';
import 'package:smarterp/core/extensions/date_extensions.dart';
import 'package:smarterp/core/theme/theme_extensions.dart';
import 'package:smarterp/core/widgets/app_shell.dart';
import 'package:smarterp/core/widgets/app_card.dart';
import 'package:smarterp/core/widgets/empty_state_widget.dart';
import 'package:smarterp/core/models/payment_model.dart';
import 'package:smarterp/core/models/invoice_model.dart';
import 'package:smarterp/modules/invoice/providers/payment_provider.dart';
import 'package:smarterp/modules/invoice/providers/invoice_provider.dart';

class PaymentHistoryScreen extends StatefulWidget {
  final String invoiceId;

  const PaymentHistoryScreen({
    super.key,
    required this.invoiceId,
  });

  @override
  State<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  String _invoiceNumber = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PaymentProvider>().loadPaymentsForInvoice(widget.invoiceId);
      final provider = context.read<InvoiceProvider>();
      final invoice = provider.invoices.where((i) => i.id == widget.invoiceId).firstOrNull;
      if (invoice != null) {
        setState(() => _invoiceNumber = invoice.invoiceNumber);
      } else {
        provider.loadInvoiceDetails(widget.invoiceId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return AppShell(
      child: Consumer<PaymentProvider>(
        builder: (context, provider, _) {
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Payment History',
                            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _invoiceNumber,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: context.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, size: 18),
                      label: const Text('Back'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                if (provider.isLoading)
                  const Expanded(child: Center(child: CircularProgressIndicator()))
                else if (provider.payments.isEmpty)
                  const Expanded(
                    child: EmptyStateWidget(
                      icon: Icons.payments_outlined,
                      title: 'No Payments',
                      message: 'No payments recorded for this invoice',
                    ),
                  )
                else
                  Expanded(child: _buildPaymentList(context, provider)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPaymentList(BuildContext context, PaymentProvider provider) {
    return ListView.builder(
      itemCount: provider.payments.length,
      itemBuilder: (context, index) {
        final payment = provider.payments[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: AppCard(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: _paymentModeColor(payment.mode).withOpacity(0.1),
                child: Icon(
                  _paymentModeIcon(payment.mode),
                  color: _paymentModeColor(payment.mode),
                  size: 20,
                ),
              ),
              title: Text(
                '₹${payment.amount.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    '${payment.paymentDate.toFormattedDate()} | ${payment.mode.name}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (payment.reference != null && payment.reference!.isNotEmpty)
                    Text(
                      'Ref: ${payment.reference}',
                      style: const TextStyle(fontSize: 12),
                    ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (payment.notes != null && payment.notes!.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.notes, size: 18),
                      onPressed: () => _showNotes(context, payment.notes!),
                      visualDensity: VisualDensity.compact,
                    ),
                  IconButton(
                    icon: Icon(Icons.delete_outline, size: 18, color: Theme.of(context).colorScheme.error),
                    onPressed: () => _confirmDelete(context, provider, payment),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Color _paymentModeColor(PaymentMode mode) {
    switch (mode) {
      case PaymentMode.cash: return Colors.green;
      case PaymentMode.card: return Colors.blue;
      case PaymentMode.bankTransfer: return Colors.purple;
      case PaymentMode.cheque: return Colors.orange;
      case PaymentMode.upi: return Colors.teal;
      case PaymentMode.online: return Colors.indigo;
    }
  }

  IconData _paymentModeIcon(PaymentMode mode) {
    switch (mode) {
      case PaymentMode.cash: return Icons.money;
      case PaymentMode.card: return Icons.credit_card;
      case PaymentMode.bankTransfer: return Icons.account_balance;
      case PaymentMode.cheque: return Icons.receipt;
      case PaymentMode.upi: return Icons.phone_android;
      case PaymentMode.online: return Icons.language;
    }
  }

  void _showNotes(BuildContext context, String notes) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Payment Notes'),
        content: Text(notes),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, PaymentProvider provider, PaymentModel payment) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Payment'),
        content: Text('Delete payment of ₹${payment.amount.toStringAsFixed(2)}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              provider.deletePayment(payment.id, payment.invoiceId);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
