import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:siddhivinayak_enterprise/core/utils/currency_formatter.dart';
import 'package:siddhivinayak_enterprise/core/utils/date_helper.dart';
import 'package:siddhivinayak_enterprise/core/widgets/app_scaffold.dart';
import 'package:siddhivinayak_enterprise/modules/finance/providers/finance_provider.dart';

class ProfitLossScreen extends StatefulWidget {
  const ProfitLossScreen({super.key});

  @override
  State<ProfitLossScreen> createState() => _ProfitLossScreenState();
}

class _ProfitLossScreenState extends State<ProfitLossScreen> {
  DateTimeRange _range = DateHelper.currentMonth();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FinanceProvider>().loadFinancialSummary(
            startDate: _range.start,
            endDate: _range.end,
          );
    });
  }

  void _updateRange(DateTimeRange range) {
    setState(() => _range = range);
    context.read<FinanceProvider>().loadFinancialSummary(
          startDate: range.start,
          endDate: range.end,
        );
  }

  @override
  Widget build(BuildContext context) {
    final finance = context.watch<FinanceProvider>();
    final totalSales = finance.totalSales;
    final totalPurchases = finance.totalPurchases;
    final totalExpenses = finance.totalExpenses;
    final totalSalary = finance.totalPayroll;
    final grossProfit = totalSales - totalPurchases;
    final netProfit = finance.netProfit;

    return AppScaffold(
      title: 'Profit & Loss',
      backRoute: '/reports',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          OutlinedButton.icon(
            onPressed: () async {
              final selectedRange = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2020),
                lastDate: DateTime.now().add(const Duration(days: 365)),
                initialDateRange: _range,
              );
              if (selectedRange != null) {
                _updateRange(selectedRange);
              }
            },
            icon: const Icon(Icons.date_range),
            label: Text(
              '${DateHelper.display(_range.start)} - ${DateHelper.display(_range.end)}',
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.deepPurple.shade50,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'Reporting Period: ${DateHelper.display(_range.start)} – ${DateHelper.display(_range.end)}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.deepPurple.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _PLCard(
            title: 'Income',
            color: Colors.green,
            rows: [_PLRow('Sales Revenue', totalSales)],
            total: totalSales,
          ),
          const SizedBox(height: 12),
          _PLCard(
            title: 'Cost of Goods',
            color: Colors.blue,
            rows: [_PLRow('Purchases / Raw Material', totalPurchases)],
            total: totalPurchases,
          ),
          const SizedBox(height: 8),
          _HighlightRow(
            'Gross Profit',
            grossProfit,
            grossProfit >= 0,
          ),
          const SizedBox(height: 12),
          _PLCard(
            title: 'Operating Expenses',
            color: Colors.orange,
            rows: [
              _PLRow('Expenses', totalExpenses),
              _PLRow('Salary & Wages', totalSalary),
            ],
            total: totalExpenses + totalSalary,
          ),
          const SizedBox(height: 8),
          _HighlightRow(
            'Net Profit',
            netProfit,
            netProfit >= 0,
            large: true,
          ),
        ],
      ),
    );
  }
}

class _PLCard extends StatelessWidget {
  final String title;
  final Color color;
  final List<_PLRow> rows;
  final double total;

  const _PLCard({
    required this.title,
    required this.color,
    required this.rows,
    required this.total,
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
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total $title',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  CurrencyFormatter.format(total),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PLRow extends StatelessWidget {
  final String label;
  final double amount;

  const _PLRow(this.label, this.amount);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13)),
          Text(
            CurrencyFormatter.format(amount),
            style: const TextStyle(fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _HighlightRow extends StatelessWidget {
  final String label;
  final double amount;
  final bool isProfit;
  final bool large;

  const _HighlightRow(
    this.label,
    this.amount,
    this.isProfit, {
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isProfit ? Colors.green.shade700 : Colors.red.shade700;
    final bg = isProfit ? Colors.green.shade50 : Colors.red.shade50;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isProfit ? Colors.green.shade200 : Colors.red.shade200,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: large ? 16 : 14,
              color: color,
            ),
          ),
          Text(
            CurrencyFormatter.format(amount),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: large ? 20 : 16,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
