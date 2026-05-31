import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:SmartERP/Providers/sale_provider.dart';
import 'package:SmartERP/core/utils/currency_formatter.dart';
import 'package:SmartERP/core/utils/date_helper.dart';
import 'package:SmartERP/core/widgets/empty_state_widget.dart';
import 'package:SmartERP/core/widgets/loading_widget.dart';

class FinanceSalesTab extends ConsumerWidget {
  const FinanceSalesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final salesAsync = ref.watch(salesStreamProvider);

    return salesAsync.when(
      loading: () => const LoadingWidget(),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (sales) {
        final invoiceSales = sales.where((s) => !s.isReturn).toList();
        final returns = sales.where((s) => s.isReturn).toList();

        if (invoiceSales.isEmpty) {
          return EmptyStateWidget(
            icon: Icons.receipt_long_outlined,
            title: 'No Sales Records Found',
            message: 'Sales will automatically appear when invoices are created.',
          );
        }

        final total = invoiceSales.fold<double>(0, (s, sale) => s + sale.total);
        final totalReturns = returns.fold<double>(0, (s, r) => s + r.total.abs());
        final effectiveTotal = total - totalReturns;

        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.green.shade50,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Sales',
                          style: TextStyle(fontWeight: FontWeight.w500)),
                      Text(CurrencyFormatter.format(effectiveTotal),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  if (totalReturns > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Returns',
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.red.shade700)),
                          Text('-${CurrencyFormatter.format(totalReturns)}',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red.shade700)),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: invoiceSales.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (ctx, i) {
                  final sale = invoiceSales[i];
                  final returnedAmount = returns
                      .where((r) => r.invoiceId == sale.invoiceId)
                      .fold<double>(0, (sum, r) => sum + r.total.abs());
                  return Card(
                    margin: EdgeInsets.zero,
                    child: ExpansionTile(
                      tilePadding: const EdgeInsets.symmetric(horizontal: 12),
                      leading: CircleAvatar(
                        backgroundColor: sale.invoiceStatus == 'cancelled'
                            ? Colors.grey.shade200
                            : Colors.green.shade100,
                        child: Icon(
                          Icons.receipt_outlined,
                          color: sale.invoiceStatus == 'cancelled'
                              ? Colors.grey.shade700
                              : Colors.green.shade700,
                        ),
                      ),
                      title: Text(
                        '${sale.invoiceNumber} · ${sale.customerName}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        '${DateHelper.display(sale.createdAt)} · ${sale.paymentStatus} · ${sale.invoiceStatus}'
                        '${returnedAmount > 0 ? ' · Returned ${CurrencyFormatter.format(returnedAmount)}' : ''}',
                      ),
                      trailing: Text(
                        CurrencyFormatter.format(sale.total - returnedAmount),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                      children: [
                        for (final item in sale.items)
                          _SaleItemRow(
                            productName: item.productName,
                            quantity: item.quantity,
                            unitPrice: item.price,
                            gst: item.gstAmount,
                            total: item.totalAmount,
                          ),
                        const Divider(height: 16),
                        _InfoRow('Invoice Number', sale.invoiceNumber),
                        _InfoRow('Customer Name', sale.customerName),
                        _InfoRow('Payment Status', sale.paymentStatus),
                        _InfoRow('Invoice Status', sale.invoiceStatus),
                        _InfoRow(
                          'Created Date',
                          DateHelper.display(sale.createdAt),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SaleItemRow extends StatelessWidget {
  const _SaleItemRow({
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.gst,
    required this.total,
  });

  final String productName;
  final double quantity;
  final double unitPrice;
  final double gst;
  final double total;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              productName,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              'Qty ${quantity.toStringAsFixed(quantity.truncateToDouble() == quantity ? 0 : 2)}',
            ),
          ),
          Expanded(child: Text(CurrencyFormatter.format(unitPrice))),
          Expanded(child: Text(CurrencyFormatter.format(gst))),
          Expanded(
            child: Text(
              CurrencyFormatter.format(total),
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
