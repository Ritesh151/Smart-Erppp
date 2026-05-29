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
        final filteredSales = sales.where((s) => s.total >= 0).toList();
        final returns = sales.where((s) => s.total < 0).toList();

        if (filteredSales.isEmpty) {
          return EmptyStateWidget(
            icon: Icons.receipt_long_outlined,
            title: 'No Sales Records Found',
            message: 'Sales will automatically appear when invoices are created.',
          );
        }

        final total = filteredSales.fold<double>(0, (s, sale) => s + sale.total);
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
                itemCount: filteredSales.length,
                separatorBuilder: (_, __) => const SizedBox(height: 4),
                itemBuilder: (ctx, i) {
                  final sale = filteredSales[i];
                  final hasReturn = returns.any((r) => r.saleId == sale.saleId);
                  return Card(
                    margin: EdgeInsets.zero,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.green.shade100,
                        child: Icon(Icons.receipt_outlined,
                            color: Colors.green.shade700),
                      ),
                      title: Text(
                          sale.invoiceNumber ?? 'Sale ${sale.saleId}',
                          style: const TextStyle(fontWeight: FontWeight.w500)),
                      subtitle: Text(
                          '${sale.customerName} · ${sale.items.length} item(s) · ${DateHelper.display(sale.createdAt)}'
                          '${hasReturn ? ' · Returned' : ''}'),
                      trailing: Text(
                        CurrencyFormatter.format(sale.total),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
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
