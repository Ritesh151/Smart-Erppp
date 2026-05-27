import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:smarterp/core/widgets/app_card.dart';
import 'package:smarterp/modules/reports/services/analytics_service.dart';

class AnalyticsCards extends StatelessWidget {
  final SalesKpi? sales;
  final ExpenseKpi? expenses;
  final InventoryKpi? inventory;
  final PayrollKpi? payroll;
  final ProfitKpi? profit;
  final bool isLoading;

  const AnalyticsCards({
    super.key,
    this.sales,
    this.expenses,
    this.inventory,
    this.payroll,
    this.profit,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: Padding(
        padding: EdgeInsets.all(40),
        child: CircularProgressIndicator(),
      ));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 800 ? 5 : constraints.maxWidth > 500 ? 3 : 2;
        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.3,
          children: [
            _buildCard(
              context,
              title: 'Sales',
              value: sales != null ? '₹${sales!.totalSales.toStringAsFixed(0)}' : '--',
              subtitle: sales != null ? '${sales!.totalOrders} orders' : null,
              icon: Icons.trending_up,
              color: Colors.blue,
              change: sales != null ? '${sales!.salesGrowth.toStringAsFixed(1)}%' : null,
              isPositive: (sales?.salesGrowth ?? 0) >= 0,
            ),
            _buildCard(
              context,
              title: 'Expenses',
              value: expenses != null ? '₹${expenses!.totalExpenses.toStringAsFixed(0)}' : '--',
              subtitle: expenses != null ? '${expenses!.expenseCount} items' : null,
              icon: Icons.money_off,
              color: Colors.red,
              change: expenses != null ? '${expenses!.expenseGrowth.toStringAsFixed(1)}%' : null,
              isPositive: (expenses?.expenseGrowth ?? 0) <= 0,
            ),
            _buildCard(
              context,
              title: 'Inventory',
              value: inventory != null ? '₹${inventory!.totalValue.toStringAsFixed(0)}' : '--',
              subtitle: inventory != null ? '${inventory!.totalProducts} products' : null,
              icon: Icons.inventory_2,
              color: Colors.orange,
              change: inventory != null ? '${inventory!.stockHealthPercentage.toStringAsFixed(0)}% healthy' : null,
              isPositive: (inventory?.stockHealthPercentage ?? 0) >= 70,
            ),
            _buildCard(
              context,
              title: 'Payroll',
              value: payroll != null ? '₹${payroll!.totalPayable.toStringAsFixed(0)}' : '--',
              subtitle: payroll != null ? '${payroll!.totalEmployees} employees' : null,
              icon: Icons.people,
              color: Colors.purple,
              change: payroll != null ? '${payroll!.paymentRate.toStringAsFixed(0)}% paid' : null,
              isPositive: (payroll?.paymentRate ?? 0) >= 80,
            ),
            _buildCard(
              context,
              title: 'Profit',
              value: profit != null ? '₹${profit!.netProfit.toStringAsFixed(0)}' : '--',
              subtitle: profit != null ? '${profit!.profitMargin.toStringAsFixed(1)}% margin' : null,
              icon: Icons.account_balance,
              color: (profit?.netProfit ?? 0) >= 0 ? Colors.green : Colors.red,
              change: profit != null ? '${profit!.profitGrowth.toStringAsFixed(1)}%' : null,
              isPositive: (profit?.profitGrowth ?? 0) >= 0,
            ),
          ],
        );
      },
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required String title,
    required String value,
    String? subtitle,
    required IconData icon,
    required Color color,
    String? change,
    bool isPositive = true,
    int index = 0,
  }) {
    final theme = Theme.of(context);

    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, size: 16, color: color),
              ),
              const Spacer(),
              if (change != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: (isPositive ? Colors.green : Colors.red).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(change,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: isPositive ? Colors.green : Colors.red,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(title,
            style: TextStyle(
              fontSize: 10,
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 2),
          Text(value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 1),
            Text(subtitle,
              style: TextStyle(
                fontSize: 9,
                color: theme.colorScheme.onSurface.withOpacity(0.4),
              ),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(delay: (index * 80).ms, duration: 300.ms).slideY(begin: 0.1, end: 0);
  }
}
