import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:smarterp/core/constants/app_constants.dart';
import 'package:smarterp/core/extensions/context_extensions.dart';
import 'package:smarterp/core/extensions/date_extensions.dart';
import 'package:smarterp/core/theme/theme_extensions.dart';
import 'package:smarterp/core/widgets/app_shell.dart';
import 'package:smarterp/core/widgets/app_card.dart';
import 'package:smarterp/core/widgets/dashboard_card.dart';
import 'package:smarterp/core/models/product_model.dart';
import 'package:smarterp/core/models/transaction_model.dart';
import 'package:smarterp/modules/products/providers/product_provider.dart';
import 'package:smarterp/modules/finance/providers/finance_provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colorScheme = context.colorScheme;
    final appTheme = context.appTheme;

    // Listen to providers for live recalculation
    final productProvider = context.watch<ProductProvider>();
    final financeProvider = context.watch<FinanceProvider>();

    final totalInventory = productProvider.totalInventoryValue;
    final financeSummary = financeProvider.summary;

    final recentTransactions = financeProvider.transactions.take(5).toList();
    final recentProducts = productProvider.products.take(5).toList();

    return AppShell(
      child: RefreshIndicator(
        onRefresh: () async {
          await productProvider.loadProducts();
          await financeProvider.loadTransactions();
        },
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(context.isMobile ? 16.0 : 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildWelcomeSection(context),
                SizedBox(height: context.isMobile ? 16 : 24),
                _buildMetricsGrid(context, financeSummary, totalInventory, appTheme),
                SizedBox(height: context.isMobile ? 16 : 24),
                _buildQuickAccessSection(context),
                SizedBox(height: context.isMobile ? 16 : 24),
                _buildPaymentDueMonitoring(context, appTheme),
                SizedBox(height: context.isMobile ? 16 : 24),
                if (context.isDesktop)
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 6,
                          child: _buildChartsSection(context, financeProvider.transactions, productProvider.products, appTheme),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          flex: 4,
                          child: _buildRecentActivities(context, recentTransactions, recentProducts, appTheme),
                        ),
                      ],
                    ),
                  )
                else ...[
                  _buildChartsSection(context, financeProvider.transactions, productProvider.products, appTheme),
                  SizedBox(height: context.isMobile ? 16 : 24),
                  _buildRecentActivities(context, recentTransactions, recentProducts, appTheme),
                ],
                // Add bottom padding for safe scrolling
                SizedBox(height: context.isMobile ? 16 : 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome back, Ritesh!',
          style: context.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Here\'s the status of your business and inventory summary today.',
          style: context.textTheme.bodyLarge?.copyWith(
            color: context.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.05, end: 0);
  }

  Widget _buildMetricsGrid(
    BuildContext context,
    dynamic financeSummary,
    double totalInventoryValue,
    AppThemeExtension appTheme,
  ) {
    final double sales = financeSummary.totalSales;
    final double profit = financeSummary.netProfit;
    final double purchases = financeSummary.totalPurchases;
    final margin = financeSummary.profitMargin;

    final metrics = [
      {
        'title': 'Total Sales',
        'value': '₹${sales.toStringAsFixed(0)}',
        'icon': Icons.trending_up,
        'color': appTheme.successColor,
        'subtitle': 'Total sales invoices',
      },
      {
        'title': 'Net Profit',
        'value': '₹${profit.toStringAsFixed(0)}',
        'icon': Icons.account_balance_wallet,
        'color': profit >= 0 ? appTheme.successColor : Colors.red,
        'subtitle': '${profit >= 0 ? '+' : ''}${margin.toStringAsFixed(1)}% margin',
      },
      {
        'title': 'Total Inventory Value',
        'value': '₹${totalInventoryValue.toStringAsFixed(0)}',
        'icon': Icons.inventory_2,
        'color': Colors.purple,
        'subtitle': 'Asset stock price x qty',
      },
      {
        'title': 'Total Purchases',
        'value': '₹${purchases.toStringAsFixed(0)}',
        'icon': Icons.shopping_cart,
        'color': appTheme.warningColor,
        'subtitle': 'Bulk supplier purchases',
      },
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = context.isMobile ? 2 : 4;
        final spacing = context.isMobile ? 12.0 : 16.0;
        final availableWidth = constraints.maxWidth - (spacing * (crossAxisCount - 1));
        final itemWidth = availableWidth / crossAxisCount;
        
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 4,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            childAspectRatio: _calculateMetricCardAspectRatio(context, itemWidth),
          ),
          itemBuilder: (context, index) {
            final metric = metrics[index];
            return DashboardCard(
              title: metric['title'] as String,
              value: metric['value'] as String,
              icon: metric['icon'] as IconData,
              iconColor: metric['color'] as Color,
              backgroundColor: metric['color'] as Color,
              subtitle: metric['subtitle'] as String,
              onTap: () {},
            ).animate().fadeIn(delay: (index * 80).ms, duration: 300.ms).slideY(begin: 0.1, end: 0);
          },
        );
      },
    );
  }

  double _calculateMetricCardAspectRatio(BuildContext context, double itemWidth) {
    // Calculate aspect ratio based on content requirements
    if (context.isMobile) {
      return itemWidth > 150 ? 1.1 : 0.9;
    } else if (context.isTablet) {
      return 1.2;
    } else {
      return 1.3;
    }
  }

  Widget _buildQuickAccessSection(BuildContext context) {
    final theme = context.theme;
    final colorScheme = context.colorScheme;

    final items = [
      {'title': 'Create Invoice', 'icon': Icons.receipt_long, 'route': '/invoices', 'color': colorScheme.primary, 'desc': 'Bill customers'},
      {'title': 'Manage Products', 'icon': Icons.inventory_2_outlined, 'route': '/products', 'color': Colors.teal, 'desc': 'Adjust inventory'},
      {'title': 'Purchase', 'icon': Icons.shopping_bag_outlined, 'route': '/finance', 'color': Colors.orange, 'desc': 'Log supplier stock'},
      {'title': 'Transport', 'icon': Icons.local_shipping_outlined, 'route': '/transport', 'color': Colors.indigo, 'desc': 'Logistics & fuel'},
      {'title': 'Reports', 'icon': Icons.assessment_outlined, 'route': '/reports', 'color': Colors.pink, 'desc': 'Business analysis'},
      {'title': 'Payroll', 'icon': Icons.people_outline, 'route': '/payroll', 'color': Colors.blueGrey, 'desc': 'Staff salaries'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Quick Access Engine',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: context.isMobile ? 8 : 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = _getQuickAccessCrossAxisCount(context);
            final spacing = context.isMobile ? 12.0 : 16.0;
            final availableWidth = constraints.maxWidth - (spacing * (crossAxisCount - 1));
            final itemWidth = availableWidth / crossAxisCount;
            
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: spacing,
                mainAxisSpacing: spacing,
                childAspectRatio: _calculateQuickAccessAspectRatio(context, itemWidth),
              ),
              itemBuilder: (context, index) {
                final item = items[index];
                return _HoverQuickActionCard(
                  title: item['title'] as String,
                  description: item['desc'] as String,
                  icon: item['icon'] as IconData,
                  color: item['color'] as Color,
                  onTap: () => context.go(item['route'] as String),
                );
              },
            );
          },
        ),
      ],
    );
  }

  int _getQuickAccessCrossAxisCount(BuildContext context) {
    if (context.isMobile) return 2;
    if (context.isTablet) return 3;
    return 6;
  }

  double _calculateQuickAccessAspectRatio(BuildContext context, double itemWidth) {
    if (context.isMobile) {
      return itemWidth > 140 ? 1.3 : 1.1;
    } else if (context.isTablet) {
      return 1.4;
    } else {
      return 1.5;
    }
  }

  Widget _buildPaymentDueMonitoring(BuildContext context, AppThemeExtension appTheme) {
    final theme = context.theme;
    final colorScheme = context.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Payment Due Monitoring',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: context.isMobile ? 8 : 12),
        LayoutBuilder(
          builder: (context, constraints) {
            if (context.isMobile) {
              return Column(
                children: [
                  _buildDueCard(
                    context,
                    title: 'Overdue Payments',
                    amount: '₹1,23,450',
                    count: '5 invoices',
                    icon: Icons.error_outline,
                    color: Colors.red,
                    progress: 0.25,
                  ),
                  const SizedBox(height: 12),
                  _buildDueCard(
                    context,
                    title: 'Due Soon (7 Days)',
                    amount: '₹2,45,670',
                    count: '12 invoices',
                    icon: Icons.warning_amber_outlined,
                    color: Colors.orange,
                    progress: 0.50,
                  ),
                  const SizedBox(height: 12),
                  _buildDueCard(
                    context,
                    title: 'Paid This Month',
                    amount: '₹8,90,120',
                    count: '45 invoices',
                    icon: Icons.check_circle_outline,
                    color: appTheme.successColor ?? Colors.green,
                    progress: 0.78,
                  ),
                ],
              );
            } else {
              return IntrinsicHeight(
                child: Row(
                  children: [
                    Expanded(
                      child: _buildDueCard(
                        context,
                        title: 'Overdue Payments',
                        amount: '₹1,23,450',
                        count: '5 invoices',
                        icon: Icons.error_outline,
                        color: Colors.red,
                        progress: 0.25,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildDueCard(
                        context,
                        title: 'Due Soon (7 Days)',
                        amount: '₹2,45,670',
                        count: '12 invoices',
                        icon: Icons.warning_amber_outlined,
                        color: Colors.orange,
                        progress: 0.50,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildDueCard(
                        context,
                        title: 'Paid This Month',
                        amount: '₹8,90,120',
                        count: '45 invoices',
                        icon: Icons.check_circle_outline,
                        color: appTheme.successColor ?? Colors.green,
                        progress: 0.78,
                      ),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildDueCard(
    BuildContext context, {
    required String title,
    required String amount,
    required String count,
    required IconData icon,
    required Color color,
    required double progress,
  }) {
    final colorScheme = context.colorScheme;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              Flexible(
                child: Text(
                  count,
                  style: TextStyle(fontSize: 11, color: colorScheme.onSurface.withOpacity(0.5)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: context.isMobile ? 12 : 16),
          Text(
            title,
            style: TextStyle(fontSize: 13, color: colorScheme.onSurface.withOpacity(0.6)),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            amount,
            style: TextStyle(
              fontSize: context.isMobile ? 16 : 18, 
              fontWeight: FontWeight.bold
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: context.isMobile ? 8 : 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: progress,
              color: color,
              backgroundColor: color.withOpacity(0.1),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivities(
    BuildContext context,
    List<TransactionModel> txs,
    List<ProductModel> products,
    AppThemeExtension appTheme,
  ) {
    final theme = context.theme;
    final colorScheme = context.colorScheme;

    // Combine recent items chronologically
    final List<Map<String, dynamic>> activities = [];
    
    for (final tx in txs) {
      activities.add({
        'title': tx.description,
        'subtitle': 'Ref: ${tx.referenceId ?? 'N/A'} | ₹${tx.amount.toStringAsFixed(2)}',
        'time': tx.date,
        'icon': tx.type == TransactionType.sale ? Icons.add_shopping_cart : Icons.payments,
        'color': tx.type == TransactionType.sale ? appTheme.successColor : colorScheme.error,
      });
    }

    for (final p in products) {
      activities.add({
        'title': 'New product cataloged: ${p.productName}',
        'subtitle': '${p.category} | Price: ₹${p.price.toStringAsFixed(2)}',
        'time': p.createdAt,
        'icon': Icons.inventory_2,
        'color': Colors.purple,
      });
    }

    activities.sort((a, b) => (b['time'] as DateTime).compareTo(a['time'] as DateTime));
    final displayList = activities.take(6).toList();

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  'Recent Activities',
                  style: TextStyle(
                    fontSize: context.isMobile ? 15 : 16, 
                    fontWeight: FontWeight.bold
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Flexible(
                child: Text(
                  'Real-time logs',
                  style: TextStyle(
                    fontSize: 11, 
                    color: colorScheme.onSurface.withOpacity(0.4)
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: context.isMobile ? 12 : 16),
          if (displayList.isEmpty)
            SizedBox(
              height: context.isMobile ? 120 : 200,
              child: const Center(
                child: Text(
                  'No activities recorded yet.',
                  textAlign: TextAlign.center,
                )
              ),
            )
          else
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: displayList.length,
                separatorBuilder: (context, index) => Divider(
                  height: context.isMobile ? 16 : 24
                ),
                itemBuilder: (context, index) {
                  final act = displayList[index];
                  final timeVal = act['time'] as DateTime;
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: context.isMobile ? 14 : 16,
                        backgroundColor: (act['color'] as Color?)?.withOpacity(0.1),
                        child: Icon(
                          act['icon'] as IconData, 
                          size: context.isMobile ? 14 : 16, 
                          color: act['color'] as Color?
                        ),
                      ),
                      SizedBox(width: context.isMobile ? 8 : 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              act['title'] as String,
                              style: TextStyle(
                                fontSize: context.isMobile ? 12 : 13, 
                                fontWeight: FontWeight.w600
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              act['subtitle'] as String,
                              style: TextStyle(
                                fontSize: context.isMobile ? 10 : 11, 
                                color: colorScheme.onSurface.withOpacity(0.5)
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        timeVal.toRelativeTime(),
                        style: TextStyle(
                          fontSize: 10, 
                          color: colorScheme.onSurface.withOpacity(0.4)
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildChartsSection(
    BuildContext context,
    List<TransactionModel> txs,
    List<ProductModel> products,
    AppThemeExtension appTheme,
  ) {
    final isMobile = context.isMobile;

    return Column(
      children: [
        if (isMobile) ...[
          _buildSalesTrendLineChart(context, txs, appTheme),
          const SizedBox(height: 16),
          _buildInventoryPieChart(context, products, appTheme),
        ] else ...[
          Row(
            children: [
              Expanded(child: _buildSalesTrendLineChart(context, txs, appTheme)),
              const SizedBox(width: 16),
              Expanded(child: _buildInventoryPieChart(context, products, appTheme)),
            ],
          ),
        ]
      ],
    );
  }

  Widget _buildSalesTrendLineChart(
    BuildContext context,
    List<TransactionModel> txs,
    AppThemeExtension appTheme,
  ) {
    final colorScheme = context.colorScheme;

    // Sales over last 7 days
    final now = DateTime.now();
    final Map<int, double> dailySales = {};
    for (int i = 0; i < 7; i++) {
      dailySales[i] = 0.0;
    }

    for (final tx in txs) {
      if (tx.type == TransactionType.sale) {
        final diff = now.difference(tx.date).inDays;
        if (diff >= 0 && diff < 7) {
          dailySales[6 - diff] = (dailySales[6 - diff] ?? 0.0) + tx.amount;
        }
      }
    }

    final spots = dailySales.entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value / 1000); // in thousands
    }).toList();

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Sales Trend (Last 7 Days)',
            style: TextStyle(
              fontSize: context.isMobile ? 14 : 15, 
              fontWeight: FontWeight.bold
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            'Figures in thousands (₹)',
            style: TextStyle(
              fontSize: 11, 
              color: colorScheme.onSurface.withOpacity(0.4)
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: context.isMobile ? 16 : 24),
          LayoutBuilder(
            builder: (context, constraints) {
              final chartHeight = context.isMobile ? 150.0 : 200.0;
              return SizedBox(
                height: chartHeight,
                child: LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: false),
                    titlesData: FlTitlesData(
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final date = now.subtract(Duration(days: 6 - value.toInt()));
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                '${date.day}/${date.month}',
                                style: const TextStyle(fontSize: 10),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        color: colorScheme.primary,
                        barWidth: 3,
                        dotData: const FlDotData(show: true),
                        belowBarData: BarAreaData(
                          show: true,
                          color: colorScheme.primary.withOpacity(0.1),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryPieChart(
    BuildContext context,
    List<ProductModel> products,
    AppThemeExtension appTheme,
  ) {
    final colorScheme = context.colorScheme;

    final Map<String, double> categoryValues = {};
    double totalVal = 0.0;
    for (final p in products) {
      final val = p.price * p.stockQuantity;
      categoryValues[p.category] = (categoryValues[p.category] ?? 0.0) + val;
      totalVal += val;
    }

    final pieSections = categoryValues.entries.map((entry) {
      final idx = categoryValues.keys.toList().indexOf(entry.key);
      final colors = [
        colorScheme.primary,
        colorScheme.secondary,
        colorScheme.tertiary,
        appTheme.warningColor ?? Colors.orange,
        Colors.purple,
        Colors.teal,
      ];
      final color = colors[idx % colors.length];
      final percent = totalVal > 0 ? (entry.value / totalVal) * 100 : 0.0;

      return PieChartSectionData(
        color: color,
        value: entry.value,
        title: '${percent.toStringAsFixed(0)}%',
        radius: context.isMobile ? 30 : 40,
        titleStyle: TextStyle(
          fontSize: context.isMobile ? 9 : 10, 
          fontWeight: FontWeight.bold, 
          color: Colors.white
        ),
      );
    }).toList();

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Inventory Distribution (Asset Value)',
            style: TextStyle(
              fontSize: context.isMobile ? 14 : 15, 
              fontWeight: FontWeight.bold
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            'Asset share percentage per material type',
            style: TextStyle(
              fontSize: 11, 
              color: colorScheme.onSurface.withOpacity(0.4)
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: context.isMobile ? 16 : 24),
          if (categoryValues.isEmpty)
            SizedBox(
              height: context.isMobile ? 120 : 150,
              child: const Center(
                child: Text(
                  'No product assets in inventory.',
                  textAlign: TextAlign.center,
                )
              ),
            )
          else ...[
            LayoutBuilder(
              builder: (context, constraints) {
                final chartHeight = context.isMobile ? 120.0 : 150.0;
                return SizedBox(
                  height: chartHeight,
                  child: PieChart(
                    PieChartData(
                      sections: pieSections,
                      centerSpaceRadius: context.isMobile ? 20 : 30,
                      sectionsSpace: 2,
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: context.isMobile ? 8 : 12),
            Flexible(
              child: Wrap(
                spacing: 8,
                runSpacing: 4,
                children: categoryValues.keys.map((cat) {
                  final idx = categoryValues.keys.toList().indexOf(cat);
                  final colors = [
                    colorScheme.primary,
                    colorScheme.secondary,
                    colorScheme.tertiary,
                    appTheme.warningColor ?? Colors.orange,
                    Colors.purple,
                    Colors.teal,
                  ];
                  final color = colors[idx % colors.length];
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(width: 8, height: 8, color: color),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          cat, 
                          style: const TextStyle(fontSize: 10),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ]
        ],
      ),
    );
  }
}

class _HoverQuickActionCard extends StatefulWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _HoverQuickActionCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  State<_HoverQuickActionCard> createState() => _HoverQuickActionCardState();
}

class _HoverQuickActionCardState extends State<_HoverQuickActionCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final theme = context.theme;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()..scale(_isHovered ? 1.03 : 1.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: widget.color.withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  )
                ]
              : [],
        ),
        child: AppCard(
          padding: EdgeInsets.zero,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
            child: Padding(
              padding: EdgeInsets.all(context.isMobile ? 8.0 : 12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(context.isMobile ? 6 : 8),
                        decoration: BoxDecoration(
                          color: widget.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
                        ),
                        child: Icon(
                          widget.icon, 
                          color: widget.color, 
                          size: context.isMobile ? 18 : 22
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: context.isMobile ? 8 : 12),
                  Flexible(
                    child: Text(
                      widget.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold, 
                        fontSize: context.isMobile ? 11 : 13
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(height: context.isMobile ? 2 : 4),
                  Flexible(
                    child: Text(
                      widget.description,
                      style: TextStyle(
                        fontSize: context.isMobile ? 9 : 10,
                        color: colorScheme.onSurface.withOpacity(0.5),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
