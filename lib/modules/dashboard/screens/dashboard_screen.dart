import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:SmartERP/core/extensions/context_extensions.dart';
import 'package:SmartERP/core/extensions/date_extensions.dart';
import 'package:SmartERP/core/routes/app_routes.dart';
import 'package:SmartERP/core/theme/theme_extensions.dart';
import 'package:SmartERP/core/models/product_model.dart';
import 'package:SmartERP/core/models/transaction_model.dart';
import 'package:SmartERP/modules/dashboard/providers/dashboard_provider.dart';
import 'package:SmartERP/modules/products/providers/product_provider.dart';
import 'package:SmartERP/modules/finance/providers/finance_provider.dart';
import 'package:SmartERP/modules/settings/providers/settings_provider.dart';

// ── Shared brand tokens (same as LoginScreen & SidebarMenu) ──────────────────
class _T {
  static const gradientStart = Color(0xFF4F6EF7);
  static const gradientEnd   = Color(0xFF7C3AED);
  static const bg            = Color(0xFFF5F7FA);
  static const white         = Colors.white;
  static const textDark      = Color(0xFF111827);
  static const textMid       = Color(0xFF374151);
  static const textMuted     = Color(0xFF6B7280);
  static const textLight     = Color(0xFF9CA3AF);
  static const divider       = Color(0xFFE5E7EB);

  static const Gradient brandGradient = LinearGradient(
    colors: [gradientStart, gradientEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Card decoration used everywhere
  static BoxDecoration card({double radius = 16}) => BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E2A6E).withOpacity(0.06),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
    );
}

// ── Hover card with subtle elevation animation ──────────────────
class _HoverCard extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final bool isMobile;

  const _HoverCard({
    required this.child,
    required this.onTap,
    required this.isMobile,
  });

  @override
  State<_HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<_HoverCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: EdgeInsets.all(widget.isMobile ? 14 : 18),
          decoration: BoxDecoration(
            color: _T.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _hovered ? _T.gradientStart.withOpacity(0.15) : _T.divider,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1E2A6E).withOpacity(_hovered ? 0.10 : 0.06),
                blurRadius: _hovered ? 24 : 16,
                offset: Offset(0, _hovered ? 8 : 4),
              ),
            ],
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appTheme          = context.appTheme;
    final totalInventory    = context.select<ProductProvider, double>((p) => p.totalInventoryValue);
    final financeSummary    = context.select<FinanceProvider, dynamic>((p) => p.summary);
    final transactions      = context.select<FinanceProvider, List<TransactionModel>>((p) => p.transactions);
    final products          = context.select<ProductProvider, List<ProductModel>>((p) => p.products);
    final recentTransactions = transactions.take(5).toList();
    final recentProducts    = products.take(5).toList();

    return RefreshIndicator(
      color: _T.gradientStart,
      onRefresh: () async {
        await Future.wait([
          context.read<ProductProvider>().loadProducts(),
          context.read<FinanceProvider>().loadTransactions(),
          context.read<DashboardProvider>().refresh(),
        ]);
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
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 6,
                      child: _buildChartsSection(
                        context,
                        transactions,
                        products,
                        appTheme,
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      flex: 4,
                      child: _buildRecentActivities(
                        context,
                        recentTransactions,
                        recentProducts,
                        appTheme,
                      ),
                    ),
                  ],
                )
              else ...[
                _buildChartsSection(
                  context,
                  transactions,
                  products,
                  appTheme,
                ),
                SizedBox(height: context.isMobile ? 16 : 24),
                _buildRecentActivities(
                  context,
                  recentTransactions,
                  recentProducts,
                  appTheme,
                ),
              ],
              SizedBox(height: context.isMobile ? 16 : 24),
            ],
          ),
        ),
      ),
    );
  }

  // ── Welcome section ─────────────────────────────────────────────────────────
  Widget _buildWelcomeSection(BuildContext context) {
    final now  = DateTime.now();
    final hour = now.hour;
    final greeting = hour < 12
        ? 'Good morning'
        : hour < 17
            ? 'Good afternoon'
            : 'Good evening';

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '$greeting, ',
                      style: TextStyle(
                        fontSize: context.isMobile ? 20 : 24,
                        fontWeight: FontWeight.w400,
                        color: _T.textMuted,
                      ),
                    ),
                    const TextSpan(
                      text: 'Siddhivinayak Enterprise',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: _T.textDark,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const TextSpan(
                      text: ' 👋',
                      style: TextStyle(fontSize: 22),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "Here's the status of your business and inventory summary today.",
                style: TextStyle(
                  fontSize: 13,
                  color: _T.textMuted,
                ),
              ),
            ],
          ),
        ),

        // Date badge
        if (!context.isMobile)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: _T.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _T.divider),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1E2A6E).withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [_T.gradientStart, _T.gradientEnd],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                    child: Icon(Icons.calendar_today_rounded,
                        color: _T.white, size: 14),
                ),
                const SizedBox(width: 10),
                Text(
                  '${now.day} ${_monthName(now.month)}, ${now.year}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _T.textDark,
                  ),
                ),
              ],
            ),
          ),
      ],
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .slideX(begin: -0.05, end: 0);
  }

  String _monthName(int m) => const [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ][m];

  String _formatAmount(double amount) {
    if (amount >= 10000000) {
      return '${(amount / 10000000).toStringAsFixed(1)}Cr';
    } else if (amount >= 100000) {
      return '${(amount / 100000).toStringAsFixed(1)}L';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    }
    return amount.toStringAsFixed(0);
  }

  String _formatCompact(double amount) {
    if (amount.abs() >= 10000000) {
      return '${(amount / 10000000).toStringAsFixed(2)}Cr';
    } else if (amount.abs() >= 100000) {
      return '${(amount / 100000).toStringAsFixed(2)}L';
    } else if (amount.abs() >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    }
    return amount.toStringAsFixed(0);
  }

  // ── Metrics grid ─────────────────────────────────────────────────────────────
  Widget _buildMetricsGrid(
    BuildContext context,
    dynamic financeSummary,
    double totalInventoryValue,
    AppThemeExtension appTheme,
  ) {
    final totalSales   = context.select<DashboardProvider, double>((p) => p.totalSales);
    final netProfit    = context.select<DashboardProvider, double>((p) => p.netProfit);
    final lowStockCount = context.select<DashboardProvider, int>((p) => p.lowStockCount);
    final lowStockEnabled = context.select<SettingsProvider, bool>((p) => p.lowStockAlertsEnabled);
    final sales     = totalSales > 0 ? totalSales : (financeSummary.totalSales as double);
    final profit    = netProfit;
    final purchases = financeSummary.totalPurchases as double;
    final margin    = sales > 0 ? (profit / sales) * 100 : 0;

    final metrics = [
      {
        'title'   : 'Total Sales',
        'value'   : '₹${_formatCompact(sales)}',
        'icon'    : Icons.trending_up_rounded,
        'gradient': const LinearGradient(
          colors: [Color(0xFF10B981), Color(0xFF059669)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        'bg'      : const Color(0xFFECFDF5),
        'subtitle': 'From paid invoices',
      },
      {
        'title'   : 'Net Profit',
        'value'   : '₹${_formatCompact(profit)}',
        'icon'    : Icons.account_balance_wallet_rounded,
        'gradient': profit >= 0
            ? const LinearGradient(
                colors: [Color(0xFF4F6EF7), Color(0xFF7C3AED)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : const LinearGradient(
                colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        'bg'      : profit >= 0
            ? const Color(0xFFEEF2FF)
            : const Color(0xFFFEF2F2),
        'subtitle': '${profit >= 0 ? '+' : ''}${margin.toStringAsFixed(1)}% margin',
      },
      {
        'title'   : 'Inventory Value',
        'value'   : '₹${_formatCompact(totalInventoryValue)}',
        'icon'    : Icons.inventory_2_rounded,
        'gradient': const LinearGradient(
          colors: [Color(0xFF7C3AED), Color(0xFF6D28D9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        'bg'      : const Color(0xFFF5F3FF),
        'subtitle': lowStockEnabled
            ? '$lowStockCount low stock items'
            : '$lowStockCount items below threshold',
      },
      {
        'title'   : 'Total Purchases',
        'value'   : '₹${purchases.toStringAsFixed(0)}',
        'icon'    : Icons.shopping_cart_rounded,
        'gradient': const LinearGradient(
          colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        'bg'      : const Color(0xFFFFFBEB),
        'subtitle': 'Bulk supplier purchases',
      },
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = context.isMobile ? 2 : 4;
        final spacing        = context.isMobile ? 12.0 : 16.0;
        final availableWidth = constraints.maxWidth - (spacing * (crossAxisCount - 1));
        final itemWidth      = availableWidth / crossAxisCount;

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
            final m = metrics[index];
            return _buildMetricCard(
              context: context,
              title   : m['title']    as String,
              value   : m['value']    as String,
              subtitle: m['subtitle'] as String,
              icon    : m['icon']     as IconData,
              gradient: m['gradient'] as LinearGradient,
              bgColor : m['bg']       as Color,
              onTap   : () {
                switch (index) {
                  case 0: context.go(AppRoutes.invoices); break;
                  case 1: context.go(AppRoutes.finance);  break;
                  case 2: context.go(AppRoutes.products); break;
                  case 3: context.go(AppRoutes.finance);  break;
                }
              },
            )
                .animate()
                .fadeIn(delay: (index * 80).ms, duration: 300.ms)
                .slideY(begin: 0.12, end: 0);
          },
        );
      },
    );
  }

  Widget _buildMetricCard({
    required BuildContext context,
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required LinearGradient gradient,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return _HoverCard(
      onTap: onTap,
      isMobile: context.isMobile,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: context.isMobile ? 36 : 42,
                height: context.isMobile ? 36 : 42,
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(11),
                  boxShadow: [
                    BoxShadow(
                      color: gradient.colors.first.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(icon,
                    color: _T.white,
                    size: context.isMobile ? 18 : 20),
              ),
              Icon(Icons.arrow_outward_rounded,
                  size: 14, color: _T.textLight),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: context.isMobile ? 18 : 22,
              fontWeight: FontWeight.w800,
              color: _T.textDark,
              letterSpacing: -0.5,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              fontSize: context.isMobile ? 11 : 12,
              fontWeight: FontWeight.w600,
              color: _T.textMuted,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 10, color: _T.textLight),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  double _calculateMetricCardAspectRatio(BuildContext context, double itemWidth) {
    if (context.isMobile) return itemWidth > 150 ? 1.1 : 0.9;
    if (context.isTablet) return 1.2;
    return 1.3;
  }

  // ── Quick access ─────────────────────────────────────────────────────────────
  Widget _buildQuickAccessSection(BuildContext context) {
    const items = [
      {'title': 'Create Invoice',    'icon': Icons.receipt_long_rounded,       'route': '/invoices',  'color': _T.gradientStart,        'desc': 'Bill customers'},
      {'title': 'Manage Products',   'icon': Icons.inventory_2_rounded,        'route': '/products',  'color': const Color(0xFF0D9488), 'desc': 'Adjust inventory'},
      {'title': 'Purchase',          'icon': Icons.shopping_bag_rounded,       'route': '/finance',   'color': const Color(0xFFF59E0B), 'desc': 'Log supplier stock'},
      {'title': 'Reports',           'icon': Icons.assessment_rounded,         'route': '/reports',   'color': const Color(0xFFEC4899), 'desc': 'Business analysis'},
      {'title': 'Payroll',           'icon': Icons.people_rounded,             'route': '/payroll',   'color': const Color(0xFF64748B), 'desc': 'Staff salaries'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildSectionHeader(
          context,
          title   : 'Quick Access',
          subtitle: 'Navigate to key modules instantly',
          icon    : Icons.bolt_rounded,
        ),
        SizedBox(height: context.isMobile ? 10 : 14),
        LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = _getQuickAccessCrossAxisCount(context);
            final spacing        = context.isMobile ? 12.0 : 14.0;
            final availableWidth = constraints.maxWidth - (spacing * (crossAxisCount - 1));
            final itemWidth      = availableWidth / crossAxisCount;

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
                  title      : item['title']       as String,
                  description: item['desc']        as String,
                  icon       : item['icon']        as IconData,
                  color      : item['color']       as Color,
                  onTap      : () => context.go(item['route'] as String),
                );
              },
            );
          },
        ),
      ],
    );
  }

  int    _getQuickAccessCrossAxisCount(BuildContext context) {
    if (context.isMobile) return 2;
    if (context.isTablet) return 3;
    return 6;
  }

  double _calculateQuickAccessAspectRatio(BuildContext context, double itemWidth) {
    if (context.isMobile) return itemWidth > 140 ? 1.1 : 0.9;
    if (context.isTablet) return 1.2;
    return 1.3;
  }

  // ── Payment due monitoring ────────────────────────────────────────────────
  Widget _buildPaymentDueMonitoring(
      BuildContext context, AppThemeExtension appTheme) {
    final dp = context.select<DashboardProvider, DashboardProvider>((p) => p);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildSectionHeader(
          context,
          title   : 'Payment Due Monitoring',
          subtitle: 'Outstanding & upcoming collections',
          icon    : Icons.account_balance_rounded,
        ),
        SizedBox(height: context.isMobile ? 10 : 14),
        LayoutBuilder(
          builder: (context, constraints) {
            final cards = [
              _buildDueCard(
                context,
                title   : 'Overdue Payments',
                amount  : '₹${_formatAmount(dp.overdueAmount)}',
                count   : '${dp.overdueCount} invoices',
                icon    : Icons.error_outline_rounded,
                color   : const Color(0xFFEF4444),
                progress: dp.overdueProgress,
              ),
              
              _buildDueCard(
                context,
                title   : 'Due Soon (7 Days)',
                amount  : '₹${_formatAmount(dp.dueSoonAmount)}',
                count   : '${dp.dueSoonCount} invoices',
                icon    : Icons.warning_amber_rounded,
                color   : const Color(0xFFF59E0B),
                progress: dp.dueSoonProgress,
              ),
              _buildDueCard(
                context,
                title   : 'Paid This Month',
                amount  : '₹${_formatAmount(dp.paidThisMonthAmount)}',
                count   : '${dp.paidThisMonthCount} invoices',
                icon    : Icons.check_circle_outline_rounded,
                color   : const Color(0xFF10B981),
                progress: dp.paidThisMonthProgress,
              ),
            ];

            if (context.isMobile) {
              return Column(
                children: [
                  cards[0],
                  const SizedBox(height: 12),
                  cards[1],
                  const SizedBox(height: 12),
                  cards[2],
                ],
              );
            }
            return Row(
              children: [
                Expanded(child: cards[0]),
                const SizedBox(width: 16),
                Expanded(child: cards[1]),
                const SizedBox(width: 16),
                Expanded(child: cards[2]),
              ],
            );
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
    return Container(
      padding: EdgeInsets.all(context.isMobile ? 14 : 18),
      decoration: BoxDecoration(
        color: _T.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.07),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
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
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  count,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: context.isMobile ? 12 : 16),
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: _T.textMuted),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            amount,
            style: TextStyle(
              fontSize: context.isMobile ? 17 : 20,
              fontWeight: FontWeight.w800,
              color: _T.textDark,
              letterSpacing: -0.5,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: context.isMobile ? 10 : 14),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value           : progress,
              color           : color,
              backgroundColor : color.withOpacity(0.1),
              minHeight       : 5,
            ),
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${(progress * 100).toInt()}%',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Recent activities ─────────────────────────────────────────────────────
  Widget _buildRecentActivities(
    BuildContext context,
    List<TransactionModel> txs,
    List<ProductModel> products,
    AppThemeExtension appTheme,
  ) {
    final List<Map<String, dynamic>> activities = [];

    for (final tx in txs) {
      activities.add({
        'title'   : tx.description,
        'subtitle': 'Ref: ${tx.referenceId ?? 'N/A'} | ₹${tx.amount.toStringAsFixed(2)}',
        'time'    : tx.date,
        'icon'    : tx.type == TransactionType.sale
            ? Icons.add_shopping_cart_rounded
            : Icons.payments_rounded,
        'color'   : tx.type == TransactionType.sale
            ? const Color(0xFF10B981)
            : const Color(0xFFEF4444),
      });
    }

    for (final p in products) {
      activities.add({
        'title'   : 'New product: ${p.productName}',
        'subtitle': '${p.hsnCode ?? 'N/A'} | ₹${p.price.toStringAsFixed(2)}',
        'time'    : p.createdAt,
        'icon'    : Icons.inventory_2_rounded,
        'color'   : _T.gradientEnd,
      });
    }

    activities.sort((a, b) =>
        (b['time'] as DateTime).compareTo(a['time'] as DateTime));
    final displayList = activities.take(6).toList();

    return Container(
      padding: EdgeInsets.all(context.isMobile ? 16 : 20),
      decoration: _T.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSectionHeaderInline(
                context,
                title : 'Recent Activities',
                icon  : Icons.history_rounded,
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _T.gradientStart.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Real-time',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: _T.gradientStart,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: context.isMobile ? 14 : 18),
          if (displayList.isEmpty)
            SizedBox(
              height: 120,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.inbox_rounded,
                        size: 36, color: _T.textLight),
                    const SizedBox(height: 8),
                    const Text('No activities recorded yet.',
                        style: TextStyle(
                            color: _T.textMuted, fontSize: 13)),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: displayList.length,
              separatorBuilder: (_, __) => Divider(
                  height: context.isMobile ? 16 : 20,
                  color: _T.divider),
              itemBuilder: (context, index) {
                final act    = displayList[index];
                final color  = act['color'] as Color;
                final timeVal = act['time'] as DateTime;
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width : context.isMobile ? 34 : 38,
                      height: context.isMobile ? 34 : 38,
                      decoration: BoxDecoration(
                        color        : color.withOpacity(0.1),
                        borderRadius : BorderRadius.circular(10),
                      ),
                      child: Icon(act['icon'] as IconData,
                          size: context.isMobile ? 16 : 18,
                          color: color),
                    ),
                    SizedBox(width: context.isMobile ? 10 : 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            act['title'] as String,
                            style: TextStyle(
                              fontSize    : context.isMobile ? 12 : 13,
                              fontWeight  : FontWeight.w600,
                              color       : _T.textDark,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            act['subtitle'] as String,
                            style: const TextStyle(
                                fontSize: 11, color: _T.textLight),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      timeVal.toRelativeTime(),
                      style: const TextStyle(
                          fontSize: 10, color: _T.textLight),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  // ── Charts section ────────────────────────────────────────────────────────
  Widget _buildChartsSection(
    BuildContext context,
    List<TransactionModel> txs,
    List<ProductModel> products,
    AppThemeExtension appTheme,
  ) {
    return Column(
      children: [
        if (context.isMobile) ...[
          _buildSalesTrendLineChart(context, txs, appTheme),
          const SizedBox(height: 16),
          _buildInventoryPieChart(context, products, appTheme),
        ] else
          Row(
            children: [
              Expanded(child: _buildSalesTrendLineChart(context, txs, appTheme)),
              const SizedBox(width: 16),
              Expanded(child: _buildInventoryPieChart(context, products, appTheme)),
            ],
          ),
      ],
    );
  }

  Widget _buildSalesTrendLineChart(
    BuildContext context,
    List<TransactionModel> txs,
    AppThemeExtension appTheme,
  ) {
    final now = DateTime.now();
    final Map<int, double> dailySales = {for (int i = 0; i < 7; i++) i: 0.0};

    for (final tx in txs) {
      if (tx.type == TransactionType.sale) {
        final diff = now.difference(tx.date).inDays;
        if (diff >= 0 && diff < 7) {
          dailySales[6 - diff] = (dailySales[6 - diff] ?? 0.0) + tx.amount;
        }
      }
    }

    final spots = dailySales.entries
        .map((e) => FlSpot(e.key.toDouble(), e.value / 1000))
        .toList();

    return Container(
      padding: EdgeInsets.all(context.isMobile ? 16 : 20),
      decoration: _T.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSectionHeaderInline(context,
              title: 'Sales Trend (7 Days)',
              icon: Icons.show_chart_rounded),
          const SizedBox(height: 4),
          const Text(
            'Figures in thousands (₹)',
            style: TextStyle(fontSize: 11, color: _T.textLight),
          ),
          SizedBox(height: context.isMobile ? 16 : 24),
          SizedBox(
            height: context.isMobile ? 150 : 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show             : true,
                  drawVerticalLine : false,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color    : _T.divider,
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  topTitles  : const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  leftTitles : AxisTitles(
                    sideTitles: SideTitles(
                      showTitles : true,
                      reservedSize: 32,
                      getTitlesWidget: (val, _) => Text(
                        '₹${val.toInt()}k',
                        style: const TextStyle(
                            fontSize: 9, color: _T.textLight),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, _) {
                        final date = now.subtract(
                            Duration(days: 6 - value.toInt()));
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            '${date.day}/${date.month}',
                            style: const TextStyle(
                                fontSize: 9, color: _T.textMuted),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots     : spots,
                    isCurved  : true,
                    gradient  : const LinearGradient(
                      colors: [_T.gradientStart, _T.gradientEnd],
                    ),
                    barWidth  : 3,
                    dotData   : FlDotData(
                      show           : true,
                      getDotPainter  : (_, __, ___, ____) =>
                          FlDotCirclePainter(
                            radius     : 4,
                            color      : _T.white,
                            strokeWidth: 2,
                            strokeColor: _T.gradientStart,
                          ),
                    ),
                    belowBarData: BarAreaData(
                      show    : true,
                      gradient: LinearGradient(
                        colors : [
                          _T.gradientStart.withOpacity(0.15),
                          _T.gradientStart.withOpacity(0.0),
                        ],
                        begin  : Alignment.topCenter,
                        end    : Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
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
    final inStock = products.where((p) => p.isInStock).length;
    final lowStock = products.where((p) => p.isLowStock).length;
    final outOfStock = products.where((p) => p.isOutOfStock).length;
    final total = products.length;

    const pieColors = [
      Color(0xFF10B981),
      Color(0xFFF59E0B),
      Color(0xFFEF4444),
    ];

    final stockData = <String, double>{
      'In Stock': inStock.toDouble(),
      'Low Stock': lowStock.toDouble(),
      'Out of Stock': outOfStock.toDouble(),
    };

    final pieSections = stockData.entries.toList().asMap().entries.map((entry) {
      final idx = entry.key;
      final e = entry.value;
      final percent = total > 0 ? (e.value / total) * 100 : 0.0;
      return PieChartSectionData(
        color: pieColors[idx],
        value: e.value,
        title: '${percent.toStringAsFixed(0)}%',
        radius: context.isMobile ? 32 : 42,
        titleStyle: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: _T.white),
      );
    }).toList();

    return Container(
      padding: EdgeInsets.all(context.isMobile ? 16 : 20),
      decoration: _T.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSectionHeaderInline(context,
              title: 'Stock Distribution',
              icon: Icons.pie_chart_rounded),
          const SizedBox(height: 4),
          const Text(
            'Product breakdown by stock status',
            style: TextStyle(fontSize: 11, color: _T.textLight),
          ),
          SizedBox(height: context.isMobile ? 16 : 24),
          if (total == 0)
            SizedBox(
              height: 120,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.inventory_2_outlined,
                        size: 36, color: _T.textLight),
                    const SizedBox(height: 8),
                    const Text('No products in inventory.',
                        style: TextStyle(
                            color: _T.textMuted, fontSize: 13)),
                  ],
                ),
              ),
            )
          else ...[
            SizedBox(
              height: context.isMobile ? 130 : 160,
              child: PieChart(
                PieChartData(
                  sections: pieSections,
                  centerSpaceRadius: context.isMobile ? 24 : 32,
                  sectionsSpace: 3,
                ),
              ),
            ),
            SizedBox(height: context.isMobile ? 10 : 14),
            Wrap(
              spacing: 10,
              runSpacing: 6,
              children: stockData.keys.toList().asMap().entries.map((entry) {
                final idx = entry.key;
                final label = entry.value;
                final color = pieColors[idx];
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(label,
                        style: const TextStyle(
                            fontSize: 10, color: _T.textMid)),
                  ],
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  // ── Shared helpers ────────────────────────────────────────────────────────
  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Row(
      children: [
        Container(
          width : 32,
          height: 32,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [_T.gradientStart, _T.gradientEnd],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.all(Radius.circular(9)),
          ),
          child: Icon(icon, color: _T.white, size: 16),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                  fontSize  : 15,
                  fontWeight: FontWeight.w700,
                  color     : _T.textDark,
                )),
            Text(subtitle,
                style: const TextStyle(
                    fontSize: 11, color: _T.textMuted)),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionHeaderInline(
    BuildContext context, {
    required String title,
    required IconData icon,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: _T.gradientStart),
        const SizedBox(width: 6),
        Text(
          title,
          style: TextStyle(
            fontSize  : context.isMobile ? 13 : 14,
            fontWeight: FontWeight.w700,
            color     : _T.textDark,
          ),
        ),
      ],
    );
  }
}

// ── Hover quick action card ──────────────────────────────────────────────────
class _HoverQuickActionCard extends StatefulWidget {
  final String      title;
  final String      description;
  final IconData    icon;
  final Color       color;
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
    return MouseRegion(
      cursor  : SystemMouseCursors.click,
      onEnter : (_) => setState(() => _isHovered = true),
      onExit  : (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration : const Duration(milliseconds: 180),
          transform: Matrix4.identity()..scale(_isHovered ? 1.03 : 1.0),
          padding  : EdgeInsets.all(context.isMobile ? 12 : 14),
          decoration: BoxDecoration(
            color       : _T.white,
            borderRadius: BorderRadius.circular(14),
            border      : Border.all(
              color: _isHovered
                  ? widget.color.withOpacity(0.3)
                  : _T.divider,
            ),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color : widget.color.withOpacity(0.18),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ]
                : [
                    BoxShadow(
                      color : const Color(0xFF1E2A6E).withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Column(
            mainAxisAlignment : MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize      : MainAxisSize.min,
            children: [
              // Icon
              Container(
                padding   : const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color        : widget.color.withOpacity(0.1),
                  borderRadius : BorderRadius.circular(10),
                ),
                child: Icon(widget.icon,
                    color: widget.color,
                    size: context.isMobile ? 18 : 20),
              ),

              const Spacer(),

              // Title
              Text(
                widget.title,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize  : context.isMobile ? 11 : 12,
                  color     : _T.textDark,
                ),
                maxLines : 2,
                overflow : TextOverflow.ellipsis,
              ),

              const SizedBox(height: 2),

              // Description
              Text(
                widget.description,
                style: const TextStyle(
                  fontSize: 10,
                  color   : _T.textLight,
                ),
                maxLines : 1,
                overflow : TextOverflow.ellipsis,
              ),

              // Hover arrow
              if (_isHovered)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Open',
                        style: TextStyle(
                          fontSize  : 10,
                          fontWeight: FontWeight.w600,
                          color     : widget.color,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Icon(Icons.arrow_forward_rounded,
                          size: 10, color: widget.color),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
