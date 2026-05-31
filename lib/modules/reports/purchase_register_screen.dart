import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:siddhivinayak_enterprise/Providers/purchase_provider.dart';
import 'package:siddhivinayak_enterprise/core/utils/currency_formatter.dart';
import 'package:siddhivinayak_enterprise/core/utils/date_helper.dart';
import 'package:siddhivinayak_enterprise/core/widgets/app_scaffold.dart';
import 'package:siddhivinayak_enterprise/core/widgets/date_range_picker.dart';
import 'package:siddhivinayak_enterprise/core/widgets/empty_state_widget.dart';
import 'package:siddhivinayak_enterprise/core/widgets/loading_widget.dart';

class PurchaseRegisterScreen extends ConsumerStatefulWidget {
  const PurchaseRegisterScreen({super.key});

  @override
  ConsumerState<PurchaseRegisterScreen> createState() =>
      _PurchaseRegisterScreenState();
}

class _PurchaseRegisterScreenState
    extends ConsumerState<PurchaseRegisterScreen> {
  DateTimeRange? _range;

  @override
  void initState() {
    super.initState();
    _range = DateHelper.currentMonth();
  }

  @override
  Widget build(BuildContext context) {
    final purchasesAsync = ref.watch(purchasesStreamProvider);

    return AppScaffold(
      title: 'Purchase Register',
      backRoute: '/reports',
      body: purchasesAsync.when(
        loading: () => const LoadingWidget(),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (all) {
          final purchases = _range == null
              ? all
              : all
                  .where((p) =>
                      DateHelper.isInRange(p.purchaseDate, _range!))
                  .toList();

          final totalAmount = purchases.fold<double>(
              0, (s, p) => s + p.totalAmount);

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: DateRangePickerWidget(
                  initialRange: _range,
                  onChanged: (r) => setState(() => _range = r),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Purchases (${purchases.length})',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Text(
                      CurrencyFormatter.format(totalAmount),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: purchases.isEmpty
                    ? const EmptyStateWidget(
                        icon: Icons.shopping_cart_outlined,
                        title: 'No Purchases',
                        message: 'No purchases in the selected period.',
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                        itemCount: purchases.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 4),
                        itemBuilder: (ctx, i) {
                          final purchase = purchases[i];
                          return Card(
                            margin: EdgeInsets.zero,
                            child: ListTile(
                              title: Text(
                                purchase.purchaseNumber,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500),
                              ),
                              subtitle: Text(
                                '${purchase.supplier.name} · ${DateHelper.display(purchase.purchaseDate)}',
                              ),
                              trailing: Text(
                                CurrencyFormatter.format(purchase.totalAmount),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
