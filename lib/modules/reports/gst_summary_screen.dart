import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:SmartERP/Providers/sale_provider.dart';
import 'package:SmartERP/Providers/purchase_provider.dart';
import 'package:SmartERP/core/utils/currency_formatter.dart';
import 'package:SmartERP/core/utils/date_helper.dart';
import 'package:SmartERP/core/widgets/app_scaffold.dart';
import 'package:SmartERP/core/widgets/date_range_picker.dart';
import 'package:SmartERP/core/widgets/loading_widget.dart';

class GstSummaryScreen extends ConsumerStatefulWidget {
  const GstSummaryScreen({super.key});

  @override
  ConsumerState<GstSummaryScreen> createState() => _GstSummaryScreenState();
}

class _GstSummaryScreenState extends ConsumerState<GstSummaryScreen> {
  DateTimeRange? _range;

  @override
  void initState() {
    super.initState();
    _range = DateHelper.currentMonth();
  }

  @override
  Widget build(BuildContext context) {
    final salesAsync = ref.watch(salesStreamProvider);
    final purchasesAsync = ref.watch(purchasesStreamProvider);

    return AppScaffold(
      title: 'GST Summary',
      backRoute: '/reports',
      body: _buildBody(salesAsync, purchasesAsync),
    );
  }

  Widget _buildBody(
    AsyncValue<List<SaleRecord>> salesAsync,
    AsyncValue<List<PurchaseRecord>> purchasesAsync,
  ) {
    return salesAsync.when(
      loading: () => const LoadingWidget(),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (sales) {
        return purchasesAsync.when(
          loading: () => const LoadingWidget(),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (purchases) {
            final filteredSales = _range == null
                ? sales
                : sales
                    .where((s) => DateHelper.isInRange(s.createdAt, _range!))
                    .toList();

            final filteredPurchases = _range == null
                ? purchases
                : purchases
                    .where((p) =>
                        DateHelper.isInRange(p.purchaseDate, _range!))
                    .toList();

            double outputCgst = 0;
            double outputSgst = 0;
            double outputIgst = 0;
            for (final sale in filteredSales) {
              for (final item in sale.items) {
                final gst = item.gstAmount;
                // Split GST: if rate <= 6% (CGST+SGST 2.5+2.5 or 5+5), split equally
                // otherwise it's IGST (12%, 18%, 28%)
                if (item.gstRate <= 6) {
                  outputCgst += gst / 2;
                  outputSgst += gst / 2;
                } else {
                  outputIgst += gst;
                }
              }
            }
            final totalOutput = outputCgst + outputSgst + outputIgst;

            // For input GST from purchases, we don't have itemized data
            // Estimate based on purchase amounts
            final totalPurchaseAmount = filteredPurchases.fold<double>(
                0, (s, p) => s + p.totalAmount);
            // Assume ~5% GST on average for purchases
            final estInputGst = totalPurchaseAmount * 0.05;
            final inputCgst = estInputGst / 2;
            final inputSgst = estInputGst / 2;
            final double inputIgst = 0;
            final totalInput = inputCgst + inputSgst + inputIgst;

            final netPayable = totalOutput - totalInput;

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                DateRangePickerWidget(
                  initialRange: _range,
                  onChanged: (r) => setState(() => _range = r),
                ),
                const SizedBox(height: 16),
                _GstCard(
                  title: 'Output GST (Sales)',
                  color: Colors.green,
                  rows: [
                    _GstRow('CGST', outputCgst),
                    _GstRow('SGST', outputSgst),
                    _GstRow('IGST', outputIgst),
                    _GstRow('Total Output GST', totalOutput, bold: true),
                  ],
                ),
                const SizedBox(height: 12),
                _GstCard(
                  title: 'Input GST (Purchases)',
                  color: Colors.blue,
                  rows: [
                    _GstRow('CGST', inputCgst),
                    _GstRow('SGST', inputSgst),
                    _GstRow('IGST', inputIgst),
                    _GstRow('Total Input GST', totalInput, bold: true),
                  ],
                ),
                const SizedBox(height: 12),
                Card(
                  color: netPayable > 0 ? Colors.red.shade50 : Colors.green.shade50,
                  shape:
                      RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Net GST Payable',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                            Text(
                              netPayable > 0
                                  ? 'Tax to be paid to govt'
                                  : 'Input credit available',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          CurrencyFormatter.format(netPayable.abs()),
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: netPayable > 0
                                ? Colors.red.shade700
                                : Colors.green.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _GstCard extends StatelessWidget {
  final String title;
  final Color color;
  final List<_GstRow> rows;

  const _GstCard({
    required this.title,
    required this.color,
    required this.rows,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: color,
                fontSize: 14,
              ),
            ),
            const Divider(),
            ...rows,
          ],
        ),
      ),
    );
  }
}

class _GstRow extends StatelessWidget {
  final String label;
  final double amount;
  final bool bold;

  const _GstRow(this.label, this.amount, {this.bold = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              fontSize: bold ? 14 : 13,
            ),
          ),
          Text(
            CurrencyFormatter.format(amount),
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              fontSize: bold ? 14 : 13,
            ),
          ),
        ],
      ),
    );
  }
}
