// lib/Pages/Reports/reports_home_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:SmartERP/core/widgets/app_scaffold.dart';

class ReportsHomeScreen extends StatelessWidget {
  const ReportsHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const reports = [
      _ReportItem(
        icon: Icons.trending_up,
        color: Colors.green,
        title: 'Sales Register',
        subtitle: 'Invoice-wise sales summary',
        route: '/reports/sales',
      ),
      _ReportItem(
        icon: Icons.shopping_cart_outlined,
        color: Colors.blue,
        title: 'Purchase Register',
        subtitle: 'Supplier-wise purchase summary',
        route: '/reports/purchases',
      ),
      _ReportItem(
        icon: Icons.account_balance_wallet_outlined,
        color: Colors.orange,
        title: 'Expense Statement',
        subtitle: 'Category-wise expenses',
        route: '/reports/expenses',
      ),
      _ReportItem(
        icon: Icons.receipt_long_outlined,
        color: Colors.deepPurple,
        title: 'GST Summary',
        subtitle: 'Output vs Input GST, Net payable',
        route: '/reports/gst',
      ),
      _ReportItem(
        icon: Icons.inventory_2_outlined,
        color: Colors.teal,
        title: 'Stock Statement',
        subtitle: 'Current stock levels',
        route: '/reports/stock',
      ),
      _ReportItem(
        icon: Icons.bar_chart,
        color: Colors.red,
        title: 'Profit & Loss',
        subtitle: 'Net profit for fiscal year',
        route: '/reports/profit',
      ),
      _ReportItem(
        icon: Icons.people_outline,
        color: Colors.indigo,
        title: 'Payroll Report',
        subtitle: 'Monthly salary payments & department breakdown',
        route: '/reports/payroll',
      ),
    ];

    return AppScaffold(
      title: 'Reports',
      showBackButton: false,
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: reports.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (ctx, i) {
          final r = reports[i];
          return Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              onTap: () => context.go(r.route),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: r.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(r.icon, color: r.color),
              ),
              title: Text(r.title,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(r.subtitle,
                  style: TextStyle(
                      color: Colors.grey.shade600, fontSize: 12)),
              trailing: const Icon(Icons.chevron_right),
            ),
          );
        },
      ),
    );
  }
}

class _ReportItem {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final String route;
  const _ReportItem(
      {required this.icon,
      required this.color,
      required this.title,
      required this.subtitle,
      required this.route});
}
