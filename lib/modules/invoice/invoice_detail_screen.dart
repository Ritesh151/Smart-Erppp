// lib/Pages/Bill_Invoice/invoice_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:SmartERP/modules/invoice/providers/invoice_screen_provider.dart';
import 'package:SmartERP/core/utils/currency_formatter.dart';
import 'package:SmartERP/core/utils/date_helper.dart';
import 'package:SmartERP/core/widgets/app_scaffold.dart';
import 'package:SmartERP/core/widgets/gst_breakdown_tile.dart';
import 'package:SmartERP/core/widgets/loading_widget.dart';
import 'package:SmartERP/core/widgets/product_image_thumbnail.dart';

class InvoiceDetailScreen extends ConsumerWidget {
  final String saleId;
  const InvoiceDetailScreen({super.key, required this.saleId});

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
            invoices.where((inv) => inv.saleId == saleId).firstOrNull;

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
              onPressed: () {
                // TODO: Share PDF
              },
            ),
          ],
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Locked badge
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

              // Customer info
              _Card(children: [
                _Row('Invoice Number', invoice.invoiceNumber),
                _Row('Date', DateHelper.display(invoice.invoiceDate)),
                _Row('Customer', invoice.customer.name),
                _Row('Address', invoice.customer.address),
                if (invoice.customer.gstin != null)
                  _Row('GSTIN', invoice.customer.gstin!),
              ]),

              const SizedBox(height: 12),

              // Line items
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
                      ...invoice.lineItems.map(
                        (item) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ProductImageThumbnail(
                                imageData: item.productImage,
                                size: 52,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.productName,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w500)),
                                    Text(
                                        'Qty: ${item.quantity} · Price: ${CurrencyFormatter.format(item.rate)}',
                                        style: const TextStyle(
                                            fontSize: 12, color: Colors.grey)),
                                    Text(
                                      'Subtotal: ${CurrencyFormatter.format(item.totalAmount)}',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
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

              // GST breakdown
              GstBreakdownTile(
                subtotal: invoice.summary.subtotal,
                cgst: invoice.summary.totalCgst,
                sgst: invoice.summary.totalSgst,
                igst: invoice.summary.totalIgst,
                roundOff: invoice.summary.roundOff,
                totalAmount: invoice.summary.totalAmount,
              ),

              const SizedBox(height: 12),

              // Amount in words
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(invoice.summary.amountInWords,
                    style: const TextStyle(
                        fontStyle: FontStyle.italic, fontSize: 13)),
              ),

              if (invoice.notes != null && invoice.notes!.isNotEmpty) ...[
                const SizedBox(height: 12),
                _Card(children: [
                  const Text('Notes',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(invoice.notes!),
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
  const _Row(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(width: 12),
          Flexible(
            child: Text(value,
                textAlign: TextAlign.end,
                style:
                    const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
