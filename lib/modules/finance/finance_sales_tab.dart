import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
        if (sales.isEmpty) {
          return EmptyStateWidget(
            icon: Icons.point_of_sale_outlined,
            title: 'No Sales',
            message: 'Record your first sale by creating a sales transaction.',
            actionLabel: 'Create Sale',
            onAction: () => context.go('/finance/create-sale'),
          );
        }

        final total = sales.fold<double>(0, (s, sale) => s + sale.total);

        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.green.shade50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Sales',
                      style: TextStyle(fontWeight: FontWeight.w500)),
                  Text(CurrencyFormatter.format(total),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: sales.length,
                separatorBuilder: (_, __) => const SizedBox(height: 4),
                itemBuilder: (ctx, i) {
                  final sale = sales[i];
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
                          '${sale.customerName} · ${sale.items.length} item(s) · ${DateHelper.display(sale.createdAt)}'),
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
