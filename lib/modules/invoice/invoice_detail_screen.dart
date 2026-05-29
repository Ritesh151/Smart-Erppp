import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:SmartERP/modules/invoice/providers/invoice_screen_provider.dart';
import 'package:SmartERP/core/utils/currency_formatter.dart';
import 'package:SmartERP/core/utils/date_helper.dart';
import 'package:SmartERP/core/widgets/app_scaffold.dart';
import 'package:SmartERP/core/widgets/gst_breakdown_tile.dart';
import 'package:SmartERP/core/widgets/loading_widget.dart';

class InvoiceDetailScreen extends ConsumerWidget {
  final String invoiceId;
  const InvoiceDetailScreen({super.key, required this.invoiceId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invoicesAsync = ref.watch(invoicesStreamProvider);

    return invoicesAsync.when(
      loading: () => const AppScaffold(title: 'Invoice', body: LoadingWidget()),
      error: (e, _) => AppScaffold(
        title: 'Invoice',
        backRoute: '/invoices',
        body: Center(child: Text('Error: $e')),
      ),
      data: (invoices) {
        final invoice =
            invoices.where((inv) => inv.id == invoiceId).firstOrNull;

        if (invoice == null) {
          return const AppScaffold(
            title: 'Invoice',
            body: Center(child: Text('Invoice not found.')),
          );
        }

        return AppScaffold(
          title: invoice.invoiceNumber,
          backRoute: '/invoices',
          actions: [
            IconButton(
              icon: const Icon(Icons.share_outlined),
              onPressed: () {},
            ),
          ],
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  border: Border.all(color: Colors.green.shade200),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.lock_outline,
                        size: 14, color: Colors.green.shade700),
                    const SizedBox(width: 4),
                    Text('Invoice Locked — Immutable',
                        style: TextStyle(
                            fontSize: 12, color: Colors.green.shade700)),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              _Card(children: [
                _Row('Invoice Number', invoice.invoiceNumber),
                _Row('Date', DateHelper.display(invoice.invoiceDate)),
                _Row('Due Date', DateHelper.display(invoice.dueDate)),
                _Row('Customer', invoice.customerName),
                if (invoice.customerAddress != null)
                  _Row('Address', invoice.customerAddress!),
                if (invoice.customerGst != null)
                  _Row('GSTIN', invoice.customerGst!),
                if (invoice.customerPhone != null) _Row('Phone', invoice.customerPhone!),
                _Row('Status', invoice.status.name.toUpperCase()),
              ]),

              const SizedBox(height: 12),

              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Items',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      const Divider(),
                      if (invoice.itemIds.isEmpty)
                        const Text('No items.',
                            style: TextStyle(color: Colors.grey, fontSize: 13))
                      else
                        ...invoice.itemIds.map(
                          (id) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                const Icon(Icons.inventory_2_outlined,
                                    size: 20, color: Colors.grey),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(id,
                                      style: const TextStyle(fontSize: 13)),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              GstBreakdownTile(
                subtotal: invoice.subtotal,
                cgst: invoice.taxAmount / 2,
                sgst: invoice.taxAmount / 2,
                igst: invoice.igstAmount,
                roundOff: invoice.roundOff,
                totalAmount: invoice.grandTotalRounded,
              ),

              const SizedBox(height: 12),

              _Card(children: [
                _Row('Discount',
                    CurrencyFormatter.format(invoice.discountAmount)),
                _Row('Tax', CurrencyFormatter.format(invoice.taxAmount)),
                _Row('Total', CurrencyFormatter.format(invoice.totalAmount),
                    isBold: true),
                _Row('Paid', CurrencyFormatter.format(invoice.paidAmount)),
                _Row('Balance', CurrencyFormatter.format(invoice.balanceAmount),
                    isBold: true),
              ]),

              if (invoice.notes != null && invoice.notes!.isNotEmpty) ...[
                const SizedBox(height: 12),
                _Card(children: [
                  const Text('Notes',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(invoice.notes!),
                ]),
              ],

              if (invoice.termsAndConditions != null &&
                  invoice.termsAndConditions!.isNotEmpty) ...[
                const SizedBox(height: 12),
                _Card(children: [
                  const Text('Terms & Conditions',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(invoice.termsAndConditions!),
                ]),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _Card extends StatelessWidget {
  final List<Widget> children;
  const _Card({required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: children),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  const _Row(this.label, this.value, {this.isBold = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(width: 12),
          Flexible(
            child: Text(value,
                textAlign: TextAlign.end,
                style: TextStyle(
                    fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
                    fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
