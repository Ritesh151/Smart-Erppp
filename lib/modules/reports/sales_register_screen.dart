import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:SmartERP/Providers/sale_provider.dart';
import 'package:SmartERP/core/utils/currency_formatter.dart';
import 'package:SmartERP/core/utils/date_helper.dart';
import 'package:SmartERP/core/widgets/app_scaffold.dart';
import 'package:SmartERP/core/widgets/date_range_picker.dart';
import 'package:SmartERP/core/widgets/empty_state_widget.dart';
import 'package:SmartERP/core/widgets/loading_widget.dart';

class SalesRegisterScreen extends ConsumerStatefulWidget {
  const SalesRegisterScreen({super.key});

  @override
  ConsumerState<SalesRegisterScreen> createState() =>
      _SalesRegisterScreenState();
}

class _SalesRegisterScreenState extends ConsumerState<SalesRegisterScreen> {
  DateTimeRange? _range;

  @override
  void initState() {
    super.initState();
    _range = DateHelper.currentMonth();
  }

  @override
  Widget build(BuildContext context) {
    final salesAsync = ref.watch(salesStreamProvider);

    return AppScaffold(
      title: 'Sales Register',
      backRoute: '/reports',
      body: salesAsync.when(
        loading: () => const LoadingWidget(),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (all) {
          final sales = _range == null
              ? all
              : all
                  .where((s) => DateHelper.isInRange(s.createdAt, _range!))
                  .toList();

          final totalAmount =
              sales.fold<double>(0, (s, sale) => s + sale.total);
          final gstAmount = sales.fold<double>(
              0,
              (s, sale) => s +
                  sale.items.fold<double>(0, (si, item) => si + item.gstAmount));
          final taxableAmount = totalAmount - gstAmount;

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
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _TotalChip(
                      'Taxable',
                      CurrencyFormatter.compact(taxableAmount),
                      Colors.green,
                    ),
                    _TotalChip(
                      'GST',
                      CurrencyFormatter.compact(gstAmount),
                      Colors.orange,
                    ),
                    _TotalChip(
                      'Total',
                      CurrencyFormatter.compact(totalAmount),
                      Colors.blue,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: sales.isEmpty
                    ? const EmptyStateWidget(
                        icon: Icons.receipt_long_outlined,
                        title: 'No Sales',
                        message: 'No sales in the selected period.',
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                        itemCount: sales.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 4),
                        itemBuilder: (ctx, i) {
                          final sale = sales[i];
                          final gst = sale.items.fold<double>(
                              0, (s, item) => s + item.gstAmount);
                          return Card(
                            margin: EdgeInsets.zero,
                            child: ListTile(
                              title: Text(
                                sale.saleId.isEmpty
                                    ? 'Sale ${sale.saleId}'
                                    : sale.saleId,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500),
                              ),
                              subtitle: Text(
                                '${sale.customerName} · ${DateHelper.display(sale.createdAt)}',
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    CurrencyFormatter.format(sale.total),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    'GST: ${CurrencyFormatter.format(gst)}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
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

class _TotalChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _TotalChip(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
