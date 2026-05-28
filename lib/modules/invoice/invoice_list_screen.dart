import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:SmartERP/core/utils/currency_formatter.dart';
import 'package:SmartERP/core/utils/date_helper.dart';
import 'package:SmartERP/core/widgets/app_scaffold.dart';
import 'package:SmartERP/core/widgets/empty_state_widget.dart';
import 'package:SmartERP/local_db/hive_boxes.dart';
import 'package:SmartERP/local_db/models/local_invoice.dart';

class InvoiceListScreen extends ConsumerWidget {
  const InvoiceListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppScaffold(
      title: 'Bills & GST',
      showBackButton: false,
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/invoices/create'),
        child: const Icon(Icons.add),
      ),
      body: ValueListenableBuilder<Box<Map>>(
        valueListenable: HiveBoxes.invoicesBox().listenable(),
        builder: (context, box, _) {
          final invoices = box.values
              .whereType<Map>()
              .map((m) => LocalInvoice.fromMap(m))
              .where((inv) => inv.id.isNotEmpty)
              .toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

          if (invoices.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.receipt_long_outlined,
              title: 'No Invoices',
              message: 'Create your first invoice to see it here.',
              actionLabel: 'Create Invoice',
              onAction: () => context.go('/invoices/create'),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: invoices.length,
            separatorBuilder: (_, __) => const SizedBox(height: 4),
            itemBuilder: (ctx, i) {
              final inv = invoices[i];
              return Card(
                margin: EdgeInsets.zero,
                child: ListTile(
                  onTap: () => context.go('/invoices/${inv.id}/preview'),
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.shade100,
                    child: Icon(Icons.receipt_long_outlined,
                        color: Colors.blue.shade700),
                  ),
                  title: Text(inv.invoiceNumber,
                      style: const TextStyle(fontWeight: FontWeight.w500)),
                  subtitle: Text(
                      '${inv.customerName} · ${DateHelper.display(inv.invoiceDate)}'),
                  trailing: Text(
                    CurrencyFormatter.format(inv.grandTotal),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
