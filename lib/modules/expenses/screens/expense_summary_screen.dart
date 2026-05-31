import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:siddhivinayak_enterprise/core/extensions/context_extensions.dart';
import 'package:siddhivinayak_enterprise/core/widgets/loading_widget.dart';
import 'package:siddhivinayak_enterprise/modules/expenses/providers/expense_provider.dart';

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
  static const success       = Color(0xFF10B981);
  static const warning       = Color(0xFFF59E0B);
  static const danger        = Color(0xFFEF4444);

  static const Gradient brandGradient = LinearGradient(
    colors: [gradientStart, gradientEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

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

// ── Category color palette ────────────────────────────────────────────────────
const List<Color> _kCategoryColors = [
  Color(0xFF4F6EF7),
  Color(0xFF10B981),
  Color(0xFFF59E0B),
  Color(0xFF7C3AED),
  Color(0xFFEC4899),
  Color(0xFF64748B),
  Color(0xFF0D9488),
  Color(0xFFEF4444),
];

class ExpenseSummaryScreen extends StatefulWidget {
  const ExpenseSummaryScreen({super.key});

  @override
  State<ExpenseSummaryScreen> createState() => _ExpenseSummaryScreenState();
}

class _ExpenseSummaryScreenState extends State<ExpenseSummaryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExpenseProvider>().loadExpenses();
    });
  }

  String _formatAmount(double amount) {
    if (amount >= 10000000) return '${(amount / 10000000).toStringAsFixed(2)}Cr';
    if (amount >= 100000)   return '${(amount / 100000).toStringAsFixed(2)}L';
    if (amount >= 1000)     return '${(amount / 1000).toStringAsFixed(1)}K';
    return amount.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.expensesByCategory.isEmpty) {
          return const LoadingWidget();
        }

        final byCategory = provider.expensesByCategory;
        final total      = provider.totalExpenses;

        return RefreshIndicator(
          color: _T.gradientStart,
          onRefresh: () => provider.loadExpenses(),
          child: Container(
            color: _T.bg,
            child: SafeArea(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(context.isMobile ? 16.0 : 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Page header ──────────────────────────────────────
                    _buildPageHeader(context)
                        .animate()
                        .fadeIn(duration: 350.ms)
                        .slideX(begin: -0.05, end: 0),

                    SizedBox(height: context.isMobile ? 20 : 28),

                    // ── Total expenses banner ────────────────────────────
                    _buildTotalBanner(context, total)
                        .animate()
                        .fadeIn(delay: 60.ms, duration: 320.ms)
                        .slideY(begin: 0.06, end: 0),

                    SizedBox(height: context.isMobile ? 16 : 24),

                    // ── Category breakdown header ────────────────────────
                    if (byCategory.isNotEmpty) ...[
                      _buildSectionHeader(
                        title   : 'Category Breakdown',
                        subtitle: 'Spending distribution by category',
                        icon    : Icons.pie_chart_rounded,
                      )
                          .animate()
                          .fadeIn(delay: 100.ms, duration: 300.ms)
                          .slideY(begin: 0.06, end: 0),

                      SizedBox(height: context.isMobile ? 12 : 16),

                      // ── Category cards ───────────────────────────────
                      ...byCategory.entries.toList().asMap().entries.map(
                        (entry) {
                          final idx      = entry.key;
                          final category = entry.value.key;
                          final amount   = entry.value.value;
                          final color    =
                              _kCategoryColors[idx % _kCategoryColors.length];
                          final percent  = total > 0 ? amount / total : 0.0;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildCategoryCard(
                              context  : context,
                              category : category,
                              amount   : amount,
                              percent  : percent,
                              color    : color,
                              rank     : idx + 1,
                            )
                                .animate()
                                .fadeIn(
                                  delay   : (120 + idx * 60).ms,
                                  duration: 280.ms,
                                )
                                .slideY(begin: 0.08, end: 0),
                          );
                        },
                      ),
                    ] else
                      _buildEmptyState(context)
                          .animate()
                          .fadeIn(delay: 100.ms, duration: 300.ms),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Page Header ────────────────────────────────────────────────────────────
  Widget _buildPageHeader(BuildContext context) {
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
                      text: 'Expense ',
                      style: TextStyle(
                        fontSize: context.isMobile ? 22 : 26,
                        fontWeight: FontWeight.w400,
                        color: _T.textMuted,
                        letterSpacing: -0.3,
                      ),
                    ),
                    TextSpan(
                      text: 'Summary',
                      style: TextStyle(
                        fontSize: context.isMobile ? 22 : 26,
                        fontWeight: FontWeight.w800,
                        color: _T.textDark,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Track and analyze your spending across all categories.',
                style: TextStyle(fontSize: 13, color: _T.textMuted),
              ),
            ],
          ),
        ),
        if (!context.isMobile) ...[
          const SizedBox(width: 16),
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
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    gradient: _T.brandGradient,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.receipt_long_rounded,
                      color: _T.white, size: 14),
                ),
                const SizedBox(width: 10),
                const Text(
                  'All Time',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _T.textDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // ── Total Expenses Banner ──────────────────────────────────────────────────
  Widget _buildTotalBanner(BuildContext context, double total) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(context.isMobile ? 20 : 26),
      decoration: BoxDecoration(
        gradient: _T.brandGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _T.gradientStart.withOpacity(0.28),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Total Expenses',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  '₹${total.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: context.isMobile ? 30 : 38,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Across all categories',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Decorative circle
          Container(
            width: context.isMobile ? 70 : 90,
            height: context.isMobile ? 70 : 90,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Container(
                width: context.isMobile ? 50 : 65,
                height: context.isMobile ? 50 : 65,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.trending_up_rounded,
                  color: Colors.white,
                  size: context.isMobile ? 26 : 32,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Category Card ──────────────────────────────────────────────────────────
  Widget _buildCategoryCard({
    required BuildContext context,
    required String category,
    required double amount,
    required double percent,
    required Color color,
    required int rank,
  }) {
    return _PressableCard(
      child: Container(
        padding: EdgeInsets.all(context.isMobile ? 14 : 18),
        decoration: _T.card(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Rank + color dot
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(11),
                    border: Border.all(color: color.withOpacity(0.2)),
                  ),
                  child: Center(
                    child: Text(
                      '#$rank',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: color,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _T.textDark,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${(percent * 100).toStringAsFixed(1)}% of total',
                        style: const TextStyle(
                          fontSize: 11,
                          color: _T.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹${_formatAmount(amount)}',
                      style: TextStyle(
                        fontSize: context.isMobile ? 15 : 17,
                        fontWeight: FontWeight.w800,
                        color: _T.textDark,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '₹${amount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 10,
                        color: _T.textLight,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            // Progress bar with label
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: percent),
                      duration: const Duration(milliseconds: 700),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, _) {
                        return LinearProgressIndicator(
                          value: value,
                          color: color,
                          backgroundColor: color.withOpacity(0.1),
                          minHeight: 6,
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${(percent * 100).toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Section Header ─────────────────────────────────────────────────────────
  Widget _buildSectionHeader({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            gradient: _T.brandGradient,
            borderRadius: BorderRadius.circular(9),
            boxShadow: [
              BoxShadow(
                color: _T.gradientStart.withOpacity(0.22),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(icon, color: _T.white, size: 16),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: _T.textDark,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 11, color: _T.textMuted),
            ),
          ],
        ),
      ],
    );
  }

  // ── Empty State ────────────────────────────────────────────────────────────
  Widget _buildEmptyState(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      decoration: _T.card(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _T.gradientStart.withOpacity(0.1),
                  _T.gradientEnd.withOpacity(0.07),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.receipt_long_rounded,
              size: 34,
              color: _T.gradientStart,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'No Expenses Recorded',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: _T.textDark,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Expense entries will appear here once added.',
            style: TextStyle(fontSize: 13, color: _T.textMuted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ── Pressable card micro-interaction ─────────────────────────────────────────
class _PressableCard extends StatefulWidget {
  final Widget child;

  const _PressableCard({required this.child});

  @override
  State<_PressableCard> createState() => _PressableCardState();
}

class _PressableCardState extends State<_PressableCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.985 : 1.0,
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
