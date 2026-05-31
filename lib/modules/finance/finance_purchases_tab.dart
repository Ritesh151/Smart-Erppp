import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:siddhivinayak_enterprise/Providers/purchase_provider.dart';
import 'package:siddhivinayak_enterprise/core/utils/currency_formatter.dart';
import 'package:siddhivinayak_enterprise/core/utils/date_helper.dart';
import 'package:siddhivinayak_enterprise/core/widgets/empty_state_widget.dart';
import 'package:siddhivinayak_enterprise/core/widgets/loading_widget.dart';

class FinancePurchasesTab extends ConsumerWidget {
  const FinancePurchasesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final purchasesAsync = ref.watch(purchasesStreamProvider);

    return purchasesAsync.when(
      loading: () => const LoadingWidget(),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (purchases) {
        if (purchases.isEmpty) {
          return EmptyStateWidget(
            icon: Icons.shopping_cart_outlined,
            title: 'No Purchases',
            message: 'Record your raw material purchases here.',
            actionLabel: 'Add Purchase',
            onAction: () => context.go('/purchases/create'),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: purchases.length,
          separatorBuilder: (_, __) => const SizedBox(height: 4),
          itemBuilder: (ctx, i) {
            final p = purchases[i];
            return Card(
              margin: EdgeInsets.zero,
              child: ListTile(
                onTap: () => context.go('/purchases/${p.id}'),
                leading: CircleAvatar(
                  backgroundColor: Colors.blue.shade100,
                  child: Icon(Icons.shopping_cart_outlined,
                      color: Colors.blue.shade700),
                ),
                title: Text(p.purchaseNumber,
                    style: const TextStyle(fontWeight: FontWeight.w500)),
                subtitle: Text(
                    '${p.supplier.name} · ${DateHelper.display(p.purchaseDate)}'),
                trailing: Text(
                  CurrencyFormatter.format(p.totalAmount),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
