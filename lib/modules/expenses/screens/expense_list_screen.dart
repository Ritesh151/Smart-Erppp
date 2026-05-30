import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:SmartERP/core/extensions/context_extensions.dart';
import 'package:SmartERP/core/widgets/empty_state_widget.dart';
import 'package:SmartERP/core/models/expense_model.dart';
import 'package:SmartERP/modules/expenses/providers/expense_provider.dart';

// ── Shared brand tokens (aligned with dashboard_screen.dart) ─────────────────
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
  static const danger        = Color(0xFFEF4444);
  static const success       = Color(0xFF10B981);
  static const warning       = Color(0xFFF59E0B);

  static const Gradient brandGradient = LinearGradient(
    colors: [gradientStart, gradientEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static BoxDecoration card({double radius = 16, bool hover = false}) =>
      BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: hover ? gradientStart.withOpacity(0.18) : divider,
        ),
        boxShadow: [
          BoxShadow(
            color: hover
                ? gradientStart.withOpacity(0.10)
                : const Color(0xFF1E2A6E).withOpacity(0.06),
            blurRadius: hover ? 22 : 16,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      );
}

// ── Category metadata ─────────────────────────────────────────────────────────
const Map<String, IconData> _kCategoryIcons = {
  'Food & Beverage' : Icons.restaurant_rounded,
  'Transport'       : Icons.directions_car_rounded,
  'Utilities'       : Icons.bolt_rounded,
  'Office Supplies' : Icons.work_rounded,
  'Marketing'       : Icons.campaign_rounded,
  'Salaries'        : Icons.people_rounded,
  'Rent'            : Icons.home_rounded,
  'Maintenance'     : Icons.build_rounded,
  'Travel'          : Icons.flight_rounded,
  'Miscellaneous'   : Icons.category_rounded,
};

const List<Color> _kCategoryColors = [
  Color(0xFF4F6EF7),
  Color(0xFF10B981),
  Color(0xFFF59E0B),
  Color(0xFF7C3AED),
  Color(0xFFEC4899),
  Color(0xFF64748B),
  Color(0xFF0D9488),
  Color(0xFFEF4444),
  Color(0xFF06B6D4),
  Color(0xFF8B5CF6),
];

Color _categoryColor(String category) {
  final cats = ExpenseProvider.categories;
  final idx  = cats.indexOf(category);
  return _kCategoryColors[(idx < 0 ? 0 : idx) % _kCategoryColors.length];
}

IconData _categoryIcon(String category) =>
    _kCategoryIcons[category] ?? Icons.receipt_rounded;

// ── Main screen ───────────────────────────────────────────────────────────────
class ExpenseListScreen extends StatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExpenseProvider>().loadExpenses();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  String _formatAmount(double amount) {
    if (amount >= 10000000) return '₹${(amount / 10000000).toStringAsFixed(1)}Cr';
    if (amount >= 100000)   return '₹${(amount / 100000).toStringAsFixed(1)}L';
    if (amount >= 1000)     return '₹${(amount / 1000).toStringAsFixed(1)}K';
    return '₹${amount.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final padding  = isMobile ? 16.0 : 24.0;

    return Consumer<ExpenseProvider>(
      builder: (context, provider, _) {
        // ── Loading state ──────────────────────────────────────────────────
        if (provider.isLoading && provider.expenses.isEmpty) {
          return Container(
            color: _T.bg,
            child: SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(padding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context, provider, isMobile),
                    SizedBox(height: isMobile ? 18 : 24),
                    _buildShimmerAnalytics(isMobile),
                    SizedBox(height: isMobile ? 18 : 24),
                    _buildShimmerList(),
                  ],
                ),
              ),
            ),
          );
        }

        // ── Error state ────────────────────────────────────────────────────
        if (provider.errorMessage != null && provider.expenses.isEmpty) {
          return Container(
            color: _T.bg,
            child: SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(padding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context, provider, isMobile),
                    SizedBox(height: isMobile ? 18 : 24),
                    _buildErrorCard(context, provider),
                  ],
                ),
              ),
            ),
          );
        }

        // ── Empty state ────────────────────────────────────────────────────
        if (provider.expenses.isEmpty) {
          return Container(
            color: _T.bg,
            child: SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(padding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context, provider, isMobile),
                    SizedBox(height: isMobile ? 18 : 24),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: _T.card(),
                      child: EmptyStateWidget(
                        icon       : Icons.account_balance_wallet_outlined,
                        title      : 'No Expenses Yet',
                        message    : 'Start tracking your factory expenses here.',
                        actionLabel: 'Add Expense',
                        onAction   : () => context.go('/expenses/add'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // ── Data state ─────────────────────────────────────────────────────
        final totalSpend   = provider.expenses.fold<double>(0, (s, e) => s + e.amount);
        final thisMonth    = _thisMonthExpenses(provider.expenses);
        final thisMonthAmt = thisMonth.fold<double>(0, (s, e) => s + e.amount);
        final topCategory  = _topCategory(provider.expenses);

        return Container(
          color: _T.bg,
          child: SafeArea(
            child: RefreshIndicator(
              color    : _T.gradientStart,
              onRefresh: () async => provider.loadExpenses(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(padding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    _buildHeader(context, provider, isMobile)
                        .animate()
                        .fadeIn(duration: 380.ms)
                        .slideX(begin: -0.04, end: 0),

                    SizedBox(height: isMobile ? 18 : 24),

                    // Analytics cards
                    _buildAnalyticsRow(
                      context,
                      isMobile     : isMobile,
                      totalSpend   : totalSpend,
                      totalCount   : provider.expenses.length,
                      thisMonthAmt : thisMonthAmt,
                      thisMonthCnt : thisMonth.length,
                      topCategory  : topCategory,
                    ).animate().fadeIn(delay: 60.ms, duration: 320.ms)
                     .slideY(begin: 0.08, end: 0),

                    SizedBox(height: isMobile ? 18 : 24),

                    // Search bar
                    _buildSearchBar(context, provider, isMobile)
                        .animate()
                        .fadeIn(delay: 100.ms, duration: 280.ms),

                    SizedBox(height: isMobile ? 14 : 18),

                    // Results info
                    _buildResultsInfo(provider, isMobile)
                        .animate()
                        .fadeIn(delay: 130.ms, duration: 260.ms),

                    SizedBox(height: isMobile ? 10 : 12),

                    // Expense list
                    provider.expenses.isEmpty
                        ? _buildNoResults(context, provider)
                        : _buildExpenseList(context, provider, isMobile),

                    SizedBox(height: isMobile ? 16 : 24),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────
  Widget _buildHeader(
      BuildContext context, ExpenseProvider provider, bool isMobile) {
    final addButton = Container(
      decoration: BoxDecoration(
        gradient    : _T.brandGradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow   : [
          BoxShadow(
            color     : _T.gradientStart.withOpacity(0.28),
            blurRadius: 12,
            offset    : const Offset(0, 5),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: () => context.go('/expenses/add'),
        icon : const Icon(Icons.add_rounded, size: 17),
        label: const Text('Add Expense',
            style: TextStyle(fontWeight: FontWeight.w700)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: _T.white,
          shadowColor    : Colors.transparent,
          padding        : EdgeInsets.symmetric(
            horizontal: isMobile ? 14 : 18,
            vertical  : 13,
          ),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );

    final titleCol = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width : 40,
              height: 40,
              decoration: BoxDecoration(
                gradient    : _T.brandGradient,
                borderRadius: BorderRadius.circular(11),
                boxShadow   : [
                  BoxShadow(
                    color     : _T.gradientStart.withOpacity(0.28),
                    blurRadius: 10,
                    offset    : const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.account_balance_wallet_rounded,
                  color: _T.white, size: 19),
            ),
            const SizedBox(width: 12),
            Text(
              'Expenses',
              style: TextStyle(
                fontSize    : isMobile ? 22 : 26,
                fontWeight  : FontWeight.w800,
                color       : _T.textDark,
                letterSpacing: -0.4,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        const Text(
          'Monitor and manage all your business expenses.',
          style: TextStyle(fontSize: 12, color: _T.textMuted),
        ),
      ],
    );

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          titleCol,
          const SizedBox(height: 14),
          addButton,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: titleCol),
        const SizedBox(width: 16),
        addButton,
      ],
    );
  }

  // ── Analytics row ──────────────────────────────────────────────────────────
  Widget _buildAnalyticsRow(
    BuildContext context, {
    required bool isMobile,
    required double totalSpend,
    required int totalCount,
    required double thisMonthAmt,
    required int thisMonthCnt,
    required String topCategory,
  }) {
    final metrics = [
      {
        'title'   : 'Total Spend',
        'value'   : _formatAmount(totalSpend),
        'subtitle': '$totalCount expenses logged',
        'icon'    : Icons.payments_rounded,
        'gradient': const LinearGradient(
          colors: [Color(0xFF4F6EF7), Color(0xFF7C3AED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      },
      {
        'title'   : 'This Month',
        'value'   : _formatAmount(thisMonthAmt),
        'subtitle': '$thisMonthCnt expenses',
        'icon'    : Icons.calendar_month_rounded,
        'gradient': const LinearGradient(
          colors: [Color(0xFF10B981), Color(0xFF059669)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      },
      {
        'title'   : 'Top Category',
        'value'   : topCategory.isEmpty ? '—' : topCategory,
        'subtitle': 'Highest spend area',
        'icon'    : Icons.bar_chart_rounded,
        'gradient': const LinearGradient(
          colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      },
    ];

    final crossAxisCount = isMobile ? 1 : 3;
    final spacing        = isMobile ? 10.0 : 16.0;

    if (isMobile) {
      return Column(
        children: metrics.asMap().entries.map((entry) {
          return Padding(
            padding: EdgeInsets.only(
                bottom: entry.key < metrics.length - 1 ? spacing : 0),
            child: _buildAnalyticCard(entry.value, isMobile: isMobile),
          );
        }).toList(),
      );
    }

    return Row(
      children: metrics.asMap().entries.map((entry) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
                right: entry.key < metrics.length - 1 ? spacing : 0),
            child: _buildAnalyticCard(entry.value, isMobile: isMobile),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAnalyticCard(Map<String, dynamic> m,
      {required bool isMobile}) {
    final gradient = m['gradient'] as LinearGradient;
    return Container(
      padding: EdgeInsets.all(isMobile ? 14 : 16),
      decoration: BoxDecoration(
        color       : _T.white,
        borderRadius: BorderRadius.circular(16),
        border      : Border.all(color: _T.divider),
        boxShadow   : [
          BoxShadow(
            color     : const Color(0xFF1E2A6E).withOpacity(0.06),
            blurRadius: 16,
            offset    : const Offset(0, 4),
          ),
        ],
      ),
      child: isMobile
          ? Row(
              children: [
                Container(
                  width : 42,
                  height: 42,
                  decoration: BoxDecoration(
                    gradient    : gradient,
                    borderRadius: BorderRadius.circular(11),
                    boxShadow   : [
                      BoxShadow(
                        color     : gradient.colors.first.withOpacity(0.28),
                        blurRadius: 8,
                        offset    : const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(m['icon'] as IconData,
                      color: _T.white, size: 19),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        m['value'] as String,
                        style: const TextStyle(
                          fontSize    : 18,
                          fontWeight  : FontWeight.w800,
                          color       : _T.textDark,
                          letterSpacing: -0.4,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(m['title'] as String,
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _T.textMuted)),
                    ],
                  ),
                ),
                Text(m['subtitle'] as String,
                    style: const TextStyle(
                        fontSize: 10, color: _T.textLight)),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width : 38,
                      height: 38,
                      decoration: BoxDecoration(
                        gradient    : gradient,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow   : [
                          BoxShadow(
                            color     : gradient.colors.first.withOpacity(0.28),
                            blurRadius: 8,
                            offset    : const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Icon(m['icon'] as IconData,
                          color: _T.white, size: 17),
                    ),
                    const Icon(Icons.arrow_outward_rounded,
                        size: 13, color: _T.textLight),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  m['value'] as String,
                  style: const TextStyle(
                    fontSize    : 20,
                    fontWeight  : FontWeight.w800,
                    color       : _T.textDark,
                    letterSpacing: -0.4,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(m['title'] as String,
                    style: const TextStyle(
                        fontSize  : 12,
                        fontWeight: FontWeight.w600,
                        color     : _T.textMuted)),
                const SizedBox(height: 1),
                Text(m['subtitle'] as String,
                    style: const TextStyle(
                        fontSize: 10, color: _T.textLight)),
              ],
            ),
    );
  }

  // ── Search bar ─────────────────────────────────────────────────────────────
  Widget _buildSearchBar(
      BuildContext context, ExpenseProvider provider, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 14 : 16),
      decoration: _T.card(),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color       : const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(11),
                border      : Border.all(color: _T.divider),
              ),
              child: TextField(
                controller: _searchCtrl,
                onChanged : (v) => provider.searchExpenses(v),
                style: const TextStyle(
                  fontSize  : 13,
                  color     : _T.textDark,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText       : 'Search expenses…',
                  hintStyle      : const TextStyle(
                      fontSize: 13, color: _T.textLight),
                  prefixIcon     : const Icon(Icons.search_rounded,
                      size: 17, color: _T.textMuted),
                  border         : InputBorder.none,
                  contentPadding : const EdgeInsets.symmetric(
                      vertical: 12),
                  suffixIcon: _searchCtrl.text.isNotEmpty
                      ? GestureDetector(
                          onTap: () {
                            _searchCtrl.clear();
                            provider.searchExpenses('');
                            setState(() {});
                          },
                          child: const Icon(Icons.close_rounded,
                              size: 16, color: _T.textMuted),
                        )
                      : null,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Results info bar ────────────────────────────────────────────────────────
  Widget _buildResultsInfo(ExpenseProvider provider, bool isMobile) {
    final count = provider.expenses.length;
    return Row(
      children: [
        Container(
          width : 26,
          height: 26,
          decoration: BoxDecoration(
            gradient    : _T.brandGradient,
            borderRadius: BorderRadius.circular(7),
          ),
          child: const Icon(Icons.list_alt_rounded,
              color: _T.white, size: 13),
        ),
        const SizedBox(width: 8),
        Text(
          '$count expense${count != 1 ? 's' : ''}',
          style: const TextStyle(
            fontSize  : 13,
            fontWeight: FontWeight.w700,
            color     : _T.textDark,
          ),
        ),
      ],
    );
  }

  // ── Expense list ────────────────────────────────────────────────────────────
  Widget _buildExpenseList(
      BuildContext context, ExpenseProvider provider, bool isMobile) {
    return ListView.builder(
      shrinkWrap: true,
      physics   : const NeverScrollableScrollPhysics(),
      itemCount : provider.expenses.length,
      itemBuilder: (ctx, i) {
        final expense = provider.expenses[i];
        return _ExpenseTile(expense: expense, isMobile: isMobile)
            .animate()
            .fadeIn(delay: (i * 35).ms, duration: 220.ms)
            .slideY(begin: 0.06, end: 0);
      },
    );
  }

  // ── No results (filtered) ──────────────────────────────────────────────────
  Widget _buildNoResults(BuildContext context, ExpenseProvider provider) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: _T.card(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width : 56,
            height: 56,
            decoration: BoxDecoration(
              color       : _T.textLight.withOpacity(0.10),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.search_off_rounded,
                size: 26, color: _T.textLight),
          ),
          const SizedBox(height: 14),
          const Text(
            'No matching expenses',
            style: TextStyle(
              fontSize  : 15,
              fontWeight: FontWeight.w700,
              color     : _T.textDark,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Try a different keyword or clear the search.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: _T.textMuted),
          ),
          const SizedBox(height: 18),
          OutlinedButton(
            onPressed: () {
              _searchCtrl.clear();
              provider.searchExpenses('');
              setState(() {});
            },
            style: OutlinedButton.styleFrom(
              side : const BorderSide(color: _T.divider),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 11),
            ),
            child: const Text(
              'Clear Search',
              style: TextStyle(
                color     : _T.textMid,
                fontWeight: FontWeight.w600,
                fontSize  : 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Error card ─────────────────────────────────────────────────────────────
  Widget _buildErrorCard(BuildContext context, ExpenseProvider provider) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: _T.card(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width : 54,
            height: 54,
            decoration: BoxDecoration(
              color       : _T.danger.withOpacity(0.10),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(Icons.error_outline_rounded,
                color: _T.danger, size: 26),
          ),
          const SizedBox(height: 14),
          const Text(
            'Failed to load expenses',
            style: TextStyle(
              fontSize  : 15,
              fontWeight: FontWeight.w700,
              color     : _T.textDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            provider.errorMessage ?? 'An unexpected error occurred.',
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 12, color: _T.textMuted, height: 1.5),
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              gradient    : _T.brandGradient,
              borderRadius: BorderRadius.circular(11),
              boxShadow   : [
                BoxShadow(
                  color     : _T.gradientStart.withOpacity(0.25),
                  blurRadius: 10,
                  offset    : const Offset(0, 4),
                ),
              ],
            ),
            child: TextButton.icon(
              onPressed: () => provider.loadExpenses(),
              icon : const Icon(Icons.refresh_rounded,
                  color: _T.white, size: 16),
              label: const Text(
                'Retry',
                style: TextStyle(
                  color     : _T.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                    horizontal: 22, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(11)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Shimmer skeletons ──────────────────────────────────────────────────────
  Widget _buildShimmerAnalytics(bool isMobile) {
    return Shimmer.fromColors(
      baseColor     : const Color(0xFFEAECF0),
      highlightColor: const Color(0xFFF8F9FA),
      child: isMobile
          ? Column(
              children: List.generate(
                3,
                (i) => Container(
                  height: 68,
                  margin: EdgeInsets.only(bottom: i < 2 ? 10 : 0),
                  decoration: BoxDecoration(
                    color       : _T.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            )
          : Row(
              children: List.generate(
                3,
                (i) => Expanded(
                  child: Container(
                    height: 100,
                    margin: EdgeInsets.only(right: i < 2 ? 16 : 0),
                    decoration: BoxDecoration(
                      color       : _T.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildShimmerList() {
    return Shimmer.fromColors(
      baseColor     : const Color(0xFFEAECF0),
      highlightColor: const Color(0xFFF8F9FA),
      child: Column(
        children: List.generate(
          6,
          (i) => Container(
            height: 76,
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color       : _T.white,
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  List<ExpenseModel> _thisMonthExpenses(List<ExpenseModel> expenses) {
    final now = DateTime.now();
    return expenses
        .where((e) =>
            e.expenseDate.year == now.year &&
            e.expenseDate.month == now.month)
        .toList();
  }

  String _topCategory(List<ExpenseModel> expenses) {
    if (expenses.isEmpty) return '';
    final Map<String, double> totals = {};
    for (final e in expenses) {
      totals[e.category] = (totals[e.category] ?? 0) + e.amount;
    }
    return totals.entries
        .reduce((a, b) => a.value >= b.value ? a : b)
        .key;
  }

}

// ── Expense tile ──────────────────────────────────────────────────────────────
class _ExpenseTile extends StatefulWidget {
  final ExpenseModel expense;
  final bool isMobile;

  const _ExpenseTile({required this.expense, required this.isMobile});

  @override
  State<_ExpenseTile> createState() => _ExpenseTileState();
}

class _ExpenseTileState extends State<_ExpenseTile> {
  bool _hovered = false;

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/'
      '${date.year}';

  String _formatAmount(double amount) {
    if (amount >= 10000000) {
      return '₹${(amount / 10000000).toStringAsFixed(1)}Cr';
    }
    if (amount >= 100000) return '₹${(amount / 100000).toStringAsFixed(1)}L';
    if (amount >= 1000)   return '₹${(amount / 1000).toStringAsFixed(1)}K';
    return '₹${amount.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final expense  = widget.expense;
    final color    = _categoryColor(expense.category);
    final icon     = _categoryIcon(expense.category);
    final isMobile = widget.isMobile;

    return MouseRegion(
      cursor : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit : (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        transform: Matrix4.identity()
          ..translate(0.0, _hovered ? -2.0 : 0.0),
        margin: const EdgeInsets.only(bottom: 10),
        padding: EdgeInsets.all(isMobile ? 13 : 15),
        decoration: BoxDecoration(
          color: _T.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _hovered
                ? color.withOpacity(0.22)
                : _T.divider,
          ),
          boxShadow: [
            BoxShadow(
              color: _hovered
                  ? color.withOpacity(0.10)
                  : const Color(0xFF1E2A6E).withOpacity(0.05),
              blurRadius: _hovered ? 20 : 12,
              offset    : const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Category icon badge
            Container(
              width : isMobile ? 44 : 48,
              height: isMobile ? 44 : 48,
              decoration: BoxDecoration(
                color       : color.withOpacity(0.10),
                borderRadius: BorderRadius.circular(13),
                border      : Border.all(
                    color: color.withOpacity(0.18)),
              ),
              child: Icon(icon, color: color,
                  size: isMobile ? 20 : 22),
            ),

            SizedBox(width: isMobile ? 12 : 14),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          expense.category,
                          style: TextStyle(
                            fontSize  : isMobile ? 13 : 14,
                            fontWeight: FontWeight.w700,
                            color     : _T.textDark,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Amount badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color       : color.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(20),
                          border      : Border.all(
                              color: color.withOpacity(0.18)),
                        ),
                        child: Text(
                          _formatAmount(expense.amount),
                          style: TextStyle(
                            fontSize  : isMobile ? 12 : 13,
                            fontWeight: FontWeight.w800,
                            color     : color,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 5),

                  // Description + date row
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          expense.description,
                          style: const TextStyle(
                            fontSize: 11,
                            color   : _T.textMuted,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.calendar_today_rounded,
                              size: 10, color: _T.textLight),
                          const SizedBox(width: 3),
                          Text(
                            _formatDate(expense.expenseDate),
                            style: const TextStyle(
                              fontSize: 10,
                              color   : _T.textLight,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Vendor pill (if available)
                  if (expense.vendor != null &&
                      expense.vendor!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.storefront_rounded,
                            size: 10, color: _T.textLight),
                        const SizedBox(width: 4),
                        Text(
                          expense.vendor!,
                          style: const TextStyle(
                            fontSize  : 10,
                            color     : _T.textLight,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
