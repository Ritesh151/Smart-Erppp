import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import 'package:SmartERP/core/extensions/context_extensions.dart';
import 'package:SmartERP/core/extensions/date_extensions.dart';
import 'package:SmartERP/core/models/invoice_model.dart';
import 'package:SmartERP/core/widgets/empty_state_widget.dart';
import 'package:SmartERP/core/widgets/search_filter_bar.dart';
import 'package:SmartERP/modules/invoice/providers/invoice_provider.dart';

// ── Shared brand tokens (mirrors dashboard_screen.dart) ──────────────────────
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

  static BoxDecoration card({double radius = 16, bool hover = false}) =>
      BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: hover
              ? gradientStart.withOpacity(0.18)
              : divider,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: hover
                ? gradientStart.withOpacity(0.10)
                : const Color(0xFF1E2A6E).withOpacity(0.06),
            blurRadius: hover ? 24 : 18,
            spreadRadius: 0,
            offset: Offset(0, hover ? 8 : 4),
          ),
        ],
      );
}

// ── Status config helper ─────────────────────────────────────────────────────
({Color color, String label, IconData icon}) _statusConfig(
    InvoiceStatus status) {
  switch (status) {
    case InvoiceStatus.draft:
      return (
        color: _T.textMuted,
        label: 'DRAFT',
        icon: Icons.drafts_rounded
      );
    case InvoiceStatus.sent:
      return (
        color: _T.gradientStart,
        label: 'SENT',
        icon: Icons.send_rounded
      );
    case InvoiceStatus.paid:
      return (
        color: _T.success,
        label: 'PAID',
        icon: Icons.check_circle_rounded
      );
    case InvoiceStatus.partiallyPaid:
      return (
        color: _T.warning,
        label: 'PARTIAL',
        icon: Icons.access_time_rounded
      );
    case InvoiceStatus.overdue:
      return (
        color: _T.danger,
        label: 'OVERDUE',
        icon: Icons.error_outline_rounded
      );
    case InvoiceStatus.cancelled:
      return (
        color: _T.textMuted,
        label: 'CANCELLED',
        icon: Icons.cancel_outlined
      );
  }
}

// ── Main screen ───────────────────────────────────────────────────────────────
class InvoicesScreen extends StatefulWidget {
  const InvoicesScreen({super.key});

  @override
  State<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends State<InvoicesScreen> {
  int _currentPage = 1;
  static const int _pageSize = 10;

  final List<Map<String, dynamic>> _statusOptions = [
    {'label': 'Draft',          'value': 'draft'},
    {'label': 'Sent',           'value': 'sent'},
    {'label': 'Paid',           'value': 'paid'},
    {'label': 'Partially Paid', 'value': 'partiallyPaid'},
    {'label': 'Overdue',        'value': 'overdue'},
    {'label': 'Cancelled',      'value': 'cancelled'},
  ];

  String? _selectedStatusValue;

  // ── Lifecycle ───────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InvoiceProvider>().loadInvoices();
    });
  }

  // ── Build ───────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final pad = context.isMobile ? 16.0 : 24.0;
    final gap = context.isMobile ? 18.0 : 24.0;

    return Consumer<InvoiceProvider>(
      builder: (context, provider, _) {
        return Container(
          color: _T.bg,
          child: SafeArea(
            child: RefreshIndicator(
              color: _T.gradientStart,
              onRefresh: () => provider.loadInvoices(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(pad),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Page header
                    _buildHeader(context)
                        .animate()
                        .fadeIn(duration: 350.ms)
                        .slideX(begin: -0.04, end: 0),

                    SizedBox(height: gap),

                    // ── Analytics strip
                    _buildAnalyticsStrip(provider)
                        .animate()
                        .fadeIn(delay: 60.ms, duration: 300.ms)
                        .slideY(begin: 0.06, end: 0),

                    SizedBox(height: gap),

                    // ── Search + filter bar
                    _buildFilterCard(context, provider)
                        .animate()
                        .fadeIn(delay: 100.ms, duration: 280.ms)
                        .slideY(begin: 0.06, end: 0),

                    SizedBox(height: gap),

                    // ── Content area
                    provider.isLoading
                        ? _buildShimmer()
                        : provider.invoices.isEmpty
                            ? _buildEmptyState(provider)
                                .animate()
                                .fadeIn(duration: 260.ms)
                            : _buildInvoicesLayout(
                                context,
                                provider.invoices,
                                provider,
                              ),

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

  // ── Header ──────────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    final iconBox = Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        gradient: _T.brandGradient,
        borderRadius: BorderRadius.circular(13),
        boxShadow: [
          BoxShadow(
            color: _T.gradientStart.withOpacity(0.28),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Icon(Icons.receipt_long_rounded,
          color: Colors.white, size: 22),
    );

    final titleCol = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Manage Invoices',
          style: TextStyle(
            fontSize: context.isMobile ? 22 : 28,
            fontWeight: FontWeight.w800,
            color: _T.textDark,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 3),
        const Text(
          'Create, send, and track your business invoices.',
          style: TextStyle(fontSize: 13, color: _T.textMuted),
        ),
      ],
    );

    final createBtn = Container(
      decoration: BoxDecoration(
        gradient: _T.brandGradient,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: _T.gradientStart.withOpacity(0.28),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => context.push('/invoices/create'),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: context.isMobile ? 16 : 22,
              vertical: 13,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.add_rounded, color: Colors.white, size: 19),
                SizedBox(width: 7),
                Text(
                  'Create Invoice',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (context.isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              iconBox,
              const SizedBox(width: 12),
              Expanded(child: titleCol),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(width: double.infinity, child: createBtn),
        ],
      );
    }

    return Row(
      children: [
        iconBox,
        const SizedBox(width: 14),
        Expanded(child: titleCol),
        const SizedBox(width: 18),
        createBtn,
      ],
    );
  }

  // ── Analytics strip ─────────────────────────────────────────────────────────
  Widget _buildAnalyticsStrip(InvoiceProvider provider) {
    final invoices       = provider.invoices;
    final totalInvoices  = invoices.length;
    final totalAmount    =
        invoices.fold<double>(0, (s, i) => s + i.totalAmount);
    final overdueCount   = invoices.where((i) => i.isOverdue).length;
    final paidThisMonth  = invoices
        .where((i) =>
            i.status == InvoiceStatus.paid &&
            i.updatedAt.month == DateTime.now().month &&
            i.updatedAt.year == DateTime.now().year)
        .length;

    final metrics = [
      {
        'title'   : 'Total Invoices',
        'value'   : '$totalInvoices',
        'icon'    : Icons.receipt_long_rounded,
        'gradient': const LinearGradient(
          colors: [Color(0xFF4F6EF7), Color(0xFF7C3AED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        'bg'      : const Color(0xFFEEF2FF),
      },
      {
        'title'   : 'Total Amount',
        'value'   : '₹${_compact(totalAmount)}',
        'icon'    : Icons.account_balance_wallet_rounded,
        'gradient': const LinearGradient(
          colors: [Color(0xFF10B981), Color(0xFF059669)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        'bg'      : const Color(0xFFECFDF5),
      },
      {
        'title'   : 'Overdue',
        'value'   : '$overdueCount',
        'icon'    : Icons.warning_amber_rounded,
        'gradient': const LinearGradient(
          colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        'bg'      : const Color(0xFFFEF2F2),
      },
      {
        'title'   : 'Paid This Month',
        'value'   : '$paidThisMonth',
        'icon'    : Icons.check_circle_rounded,
        'gradient': const LinearGradient(
          colors: [Color(0xFF10B981), Color(0xFF059669)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        'bg'      : const Color(0xFFECFDF5),
      },
    ];

    final crossAxisCount = context.isMobile ? 2 : 4;
    final spacing        = context.isMobile ? 12.0 : 16.0;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: metrics.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: context.isMobile ? 1.5 : 1.95,
      ),
      itemBuilder: (context, index) {
        final m = metrics[index];
        return _MetricCard(
          title   : m['title']    as String,
          value   : m['value']    as String,
          icon    : m['icon']     as IconData,
          gradient: m['gradient'] as LinearGradient,
          bgColor : m['bg']       as Color,
        )
            .animate()
            .fadeIn(delay: (index * 60).ms, duration: 260.ms)
            .slideY(begin: 0.08, end: 0);
      },
    );
  }

  String _compact(double v) {
    if (v >= 10000000) return '${(v / 10000000).toStringAsFixed(1)}Cr';
    if (v >= 100000)   return '${(v / 100000).toStringAsFixed(1)}L';
    if (v >= 1000)     return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toStringAsFixed(0);
  }

  // ── Filter card ─────────────────────────────────────────────────────────────
  Widget _buildFilterCard(BuildContext context, InvoiceProvider provider) {
    return Container(
      padding: EdgeInsets.all(context.isMobile ? 14 : 18),
      decoration: _T.card(),
      child: SearchFilterBar(
        hintText: 'Search by invoice number, customer name...',
        searchQuery: provider.searchQuery,
        onSearchChanged: (query) {
          setState(() => _currentPage = 1);
          provider.searchInvoices(query);
        },
        statusOptions: _statusOptions,
        selectedStatus: _selectedStatusValue,
        onStatusChanged: (val) {
          setState(() {
            _selectedStatusValue = val;
            _currentPage = 1;
          });

          InvoiceStatus? status;
          if (val == 'draft')         status = InvoiceStatus.draft;
          if (val == 'sent')          status = InvoiceStatus.sent;
          if (val == 'paid')          status = InvoiceStatus.paid;
          if (val == 'partiallyPaid') status = InvoiceStatus.partiallyPaid;
          if (val == 'overdue')       status = InvoiceStatus.overdue;
          if (val == 'cancelled')     status = InvoiceStatus.cancelled;

          provider.filterByStatus(status);
        },
        onClearAll: () {
          setState(() {
            _selectedStatusValue = null;
            _currentPage = 1;
          });
          provider.clearSearch();
        },
      ),
    );
  }

  // ── Empty state ─────────────────────────────────────────────────────────────
  Widget _buildEmptyState(InvoiceProvider provider) {
    final hasFilters =
        provider.searchQuery.isNotEmpty || provider.filterStatus != null;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: _T.card(),
      child: EmptyStateWidget(
        icon: hasFilters
            ? Icons.search_off_rounded
            : Icons.receipt_long_outlined,
        title: hasFilters
            ? 'No Matching Invoices Found'
            : 'No Invoices Yet',
        message: hasFilters
            ? 'Try expanding your keywords or adjusting filters.'
            : 'Create your first invoice to start billing your customers.',
        actionLabel:
            hasFilters ? 'Reset Filters' : 'Create First Invoice',
        onAction: () {
          if (hasFilters) {
            setState(() {
              _selectedStatusValue = null;
              _currentPage = 1;
            });
            provider.clearSearch();
          } else {
            context.go('/invoices/create');
          }
        },
      ),
    );
  }

  // ── Shimmer skeleton ────────────────────────────────────────────────────────
  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFEAECF0),
      highlightColor: const Color(0xFFF8F9FC),
      child: Column(
        children: List.generate(
          6,
          (i) => Container(
            height: 96,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }

  // ── Layout router ───────────────────────────────────────────────────────────
  Widget _buildInvoicesLayout(
    BuildContext context,
    List<InvoiceModel> list,
    InvoiceProvider provider,
  ) {
    final totalPages = (list.length / _pageSize).ceil();
    final start      = (_currentPage - 1) * _pageSize;
    final end        = (start + _pageSize).clamp(0, list.length);
    final pageList   = list.sublist(start, end);

    return Column(
      children: [
        context.isDesktop
            ? _buildDesktopTable(context, pageList, provider)
            : _buildMobileList(context, pageList, provider),

        if (totalPages > 1) ...[
          const SizedBox(height: 24),
          _buildPagination(totalPages),
        ],
      ],
    );
  }

  // ── Desktop table ───────────────────────────────────────────────────────────
  Widget _buildDesktopTable(
    BuildContext context,
    List<InvoiceModel> list,
    InvoiceProvider provider,
  ) {
    return Container(
      decoration: _T.card(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Theme(
            data: Theme.of(context)
                .copyWith(dividerColor: _T.divider),
            child: DataTable(
              horizontalMargin: 20,
              columnSpacing: 24,
              headingRowHeight: 52,
              dataRowMinHeight: 72,
              dataRowMaxHeight: 82,
              headingRowColor: MaterialStateProperty.all(
                  const Color(0xFFF8FAFC)),
              headingTextStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: _T.textMuted,
                letterSpacing: 0.3,
              ),
              columns: const [
                DataColumn(label: Text('Invoice #')),
                DataColumn(label: Text('Customer')),
                DataColumn(label: Text('Date')),
                DataColumn(label: Text('Due Date')),
                DataColumn(label: Text('Total')),
                DataColumn(label: Text('Paid')),
                DataColumn(label: Text('Balance')),
                DataColumn(label: Text('Status')),
                DataColumn(label: Text('Actions')),
              ],
              rows: list.asMap().entries.map((entry) {
                final idx     = entry.key;
                final invoice = entry.value;
                return _buildDataRow(
                    context, invoice, provider, idx);
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  DataRow _buildDataRow(
    BuildContext context,
    InvoiceModel invoice,
    InvoiceProvider provider,
    int idx,
  ) {
    return DataRow(
      cells: [
        // Invoice number — clickable
        DataCell(
          InkWell(
            onTap: () => context.push('/invoices/${invoice.id}'),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: _T.gradientStart.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.receipt_rounded,
                      size: 14, color: _T.gradientStart),
                ),
                const SizedBox(width: 8),
                Text(
                  invoice.invoiceNumber,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: _T.textDark,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Customer
        DataCell(
          SizedBox(
            width: 150,
            child: Text(
              invoice.customerName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontSize: 13, color: _T.textMid),
            ),
          ),
        ),

        // Invoice date
        DataCell(Text(invoice.invoiceDate.toFormattedDate(),
            style: const TextStyle(
                fontSize: 12, color: _T.textMuted))),

        // Due date
        DataCell(Text(invoice.dueDate.toFormattedDate(),
            style: const TextStyle(
                fontSize: 12, color: _T.textMuted))),

        // Total
        DataCell(Text(
          '₹${invoice.totalAmount.toStringAsFixed(2)}',
          style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: _T.textDark),
        )),

        // Paid
        DataCell(Text(
          '₹${invoice.paidAmount.toStringAsFixed(2)}',
          style: const TextStyle(
              fontSize: 13, color: _T.textMuted),
        )),

        // Balance
        DataCell(Text(
          '₹${invoice.balanceAmount.toStringAsFixed(2)}',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13,
            color: invoice.balanceAmount > 0
                ? _T.danger
                : _T.success,
          ),
        )),

        // Status chip
        DataCell(_StatusChip(invoice: invoice)),

        // Actions
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ActionIconButton(
                icon: Icons.visibility_outlined,
                color: _T.gradientStart,
                tooltip: 'View',
                onTap: () =>
                    context.push('/invoices/${invoice.id}'),
              ),
              const SizedBox(width: 7),
              _ActionIconButton(
                icon: Icons.edit_outlined,
                color: _T.warning,
                tooltip: 'Edit',
                onTap: () {
                  if (invoice.status == InvoiceStatus.draft ||
                      invoice.status == InvoiceStatus.sent) {
                    context.push(
                        '/invoices/${invoice.id}/edit');
                  }
                },
              ),
              const SizedBox(width: 7),
              _ActionIconButton(
                icon: Icons.delete_outline_rounded,
                color: _T.danger,
                tooltip: 'Delete',
                onTap: () => _confirmDelete(
                    context, invoice, provider),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Mobile slidable list ────────────────────────────────────────────────────
  Widget _buildMobileList(
    BuildContext context,
    List<InvoiceModel> list,
    InvoiceProvider provider,
  ) {
    return SlidableAutoCloseBehavior(
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: list.length,
        itemBuilder: (context, index) {
          final invoice = list[index];
          return _HoverInvoiceCard(
            child: Slidable(
              key: ValueKey(invoice.id),
              endActionPane: ActionPane(
                motion: const DrawerMotion(),
                extentRatio: 0.42,
                children: [
                  SlidableAction(
                    onPressed: (_) {
                      if (invoice.status == InvoiceStatus.draft ||
                          invoice.status == InvoiceStatus.sent) {
                        context.push(
                            '/invoices/${invoice.id}/edit');
                      }
                    },
                    backgroundColor: _T.warning,
                    foregroundColor: Colors.white,
                    borderRadius: const BorderRadius.horizontal(
                        left: Radius.circular(14)),
                    icon: Icons.edit_rounded,
                    label: 'Edit',
                  ),
                  SlidableAction(
                    onPressed: (_) =>
                        _confirmDelete(context, invoice, provider),
                    backgroundColor: _T.danger,
                    foregroundColor: Colors.white,
                    borderRadius: const BorderRadius.horizontal(
                        right: Radius.circular(14)),
                    icon: Icons.delete_rounded,
                    label: 'Delete',
                  ),
                ],
              ),
              child: _InvoiceMobileCard(
                invoice: invoice,
                onTap: () =>
                    context.push('/invoices/${invoice.id}'),
              ),
            ),
          )
              .animate()
              .fadeIn(
                  delay: (index * 40).ms, duration: 220.ms)
              .slideY(begin: 0.05, end: 0);
        },
      ),
    );
  }

  // ── Pagination ──────────────────────────────────────────────────────────────
  Widget _buildPagination(int totalPages) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _PaginationButton(
          icon: Icons.chevron_left_rounded,
          enabled: _currentPage > 1,
          onTap: () => setState(() => _currentPage--),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 18, vertical: 11),
          decoration: _T.card(radius: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.pages_rounded,
                  size: 14, color: _T.textMuted),
              const SizedBox(width: 6),
              Text(
                'Page $_currentPage of $totalPages',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: _T.textDark,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        _PaginationButton(
          icon: Icons.chevron_right_rounded,
          enabled: _currentPage < totalPages,
          onTap: () => setState(() => _currentPage++),
        ),
      ],
    );
  }

  // ── Delete confirmation dialog ───────────────────────────────────────────────
  void _confirmDelete(
    BuildContext context,
    InvoiceModel invoice,
    InvoiceProvider provider,
  ) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (ctx) => _DeleteDialog(
        invoice: invoice,
        provider: provider,
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// ── Sub-widgets ──────────────────────────────────────────────────────────────
// ────────────────────────────────────────────────────────────────────────────

/// Analytics metric card — mirrors dashboard MetricCard style
class _MetricCard extends StatelessWidget {
  final String        title;
  final String        value;
  final IconData      icon;
  final LinearGradient gradient;
  final Color         bgColor;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.gradient,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.isMobile ? 10 : 14),
      decoration: BoxDecoration(
        color: _T.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _T.divider),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E2A6E).withOpacity(0.06),
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
                width: context.isMobile ? 30 : 34,
                height: context.isMobile ? 30 : 34,
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(9),
                  boxShadow: [
                    BoxShadow(
                      color: gradient.colors.first.withOpacity(0.28),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(icon,
                    color: Colors.white,
                    size: context.isMobile ? 15 : 17),
              ),
              Icon(Icons.arrow_outward_rounded,
                  size: 13, color: _T.textLight),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: context.isMobile ? 17 : 21,
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
        ],
      ),
    );
  }
}

/// Status chip used in table and mobile card
class _StatusChip extends StatelessWidget {
  final InvoiceModel invoice;
  const _StatusChip({required this.invoice});

  @override
  Widget build(BuildContext context) {
    final cfg       = _statusConfig(invoice.status);
    final cancelled = invoice.status == InvoiceStatus.cancelled;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: cfg.color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: cfg.color.withOpacity(0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(cfg.icon, size: 11, color: cfg.color),
          const SizedBox(width: 5),
          Text(
            cfg.label,
            style: TextStyle(
              color: cfg.color,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
              decoration: cancelled
                  ? TextDecoration.lineThrough
                  : TextDecoration.none,
            ),
          ),
        ],
      ),
    );
  }
}

/// Small icon action button for table rows
class _ActionIconButton extends StatelessWidget {
  final IconData     icon;
  final Color        color;
  final String       tooltip;
  final VoidCallback onTap;

  const _ActionIconButton({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          width: 33,
          height: 33,
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
      ),
    );
  }
}

/// Mobile invoice card (used inside Slidable)
class _InvoiceMobileCard extends StatelessWidget {
  final InvoiceModel invoice;
  final VoidCallback onTap;

  const _InvoiceMobileCard({
    required this.invoice,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: _T.card(),
        child: Row(
          children: [
            // Icon box
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _T.gradientStart.withOpacity(0.12),
                    _T.gradientEnd.withOpacity(0.06),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(Icons.receipt_rounded,
                  color: _T.gradientStart.withOpacity(0.7),
                  size: 22),
            ),
            const SizedBox(width: 12),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    invoice.invoiceNumber,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _T.textDark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    invoice.customerName,
                    style: const TextStyle(
                        fontSize: 12, color: _T.textMuted),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 9),
                  Wrap(
                    spacing: 8,
                    runSpacing: 5,
                    children: [
                      _InfoPill(
                        icon: Icons.currency_rupee_rounded,
                        label:
                            '₹${invoice.totalAmount.toStringAsFixed(2)}',
                      ),
                      _InfoPill(
                        icon: Icons.event_rounded,
                        label: invoice.dueDate.toFormattedDate(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),

            // Right column
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _StatusChip(invoice: invoice),
                const SizedBox(height: 12),
                const Icon(Icons.chevron_right_rounded,
                    color: _T.textLight, size: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Small pill chip with icon + text used in mobile cards
class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String   label;

  const _InfoPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: _T.gradientStart.withOpacity(0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: _T.gradientStart.withOpacity(0.08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: _T.gradientStart),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _T.textDark,
            ),
          ),
        ],
      ),
    );
  }
}

/// Pagination nav button
class _PaginationButton extends StatelessWidget {
  final IconData     icon;
  final bool         enabled;
  final VoidCallback onTap;

  const _PaginationButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          gradient: enabled ? _T.brandGradient : null,
          color: enabled ? null : _T.divider,
          borderRadius: BorderRadius.circular(12),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: _T.gradientStart.withOpacity(0.22),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Icon(
          icon,
          color:
              enabled ? Colors.white : _T.textLight,
          size: 22,
        ),
      ),
    );
  }
}

/// Hover lift effect wrapper for mobile invoice cards
class _HoverInvoiceCard extends StatefulWidget {
  final Widget child;
  const _HoverInvoiceCard({required this.child});

  @override
  State<_HoverInvoiceCard> createState() =>
      _HoverInvoiceCardState();
}

class _HoverInvoiceCardState
    extends State<_HoverInvoiceCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        transform: Matrix4.identity()
          ..translate(0.0, _hovered ? -2.5 : 0.0),
        child: widget.child,
      ),
    );
  }
}

/// Styled delete confirmation dialog
class _DeleteDialog extends StatelessWidget {
  final InvoiceModel   invoice;
  final InvoiceProvider provider;

  const _DeleteDialog({
    required this.invoice,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding:
          const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        decoration: BoxDecoration(
          color: _T.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1E2A6E).withOpacity(0.12),
              blurRadius: 40,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _T.danger.withOpacity(0.04),
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(22)),
                border: Border(
                    bottom: BorderSide(
                        color: _T.danger.withOpacity(0.1))),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _T.danger.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                        Icons.delete_outline_rounded,
                        color: _T.danger,
                        size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Delete Invoice?',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: _T.textDark,
                          ),
                        ),
                        Text(
                          'This action cannot be undone.',
                          style: TextStyle(
                              fontSize: 11, color: _T.textMuted),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: _T.divider.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.close_rounded,
                          size: 14, color: _T.textMuted),
                    ),
                  ),
                ],
              ),
            ),

            // Body
            Padding(
              padding: const EdgeInsets.all(20),
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 13,
                    color: _T.textMuted,
                    height: 1.6,
                  ),
                  children: [
                    const TextSpan(
                        text:
                            'Are you sure you want to permanently delete invoice '),
                    TextSpan(
                      text: '"${invoice.invoiceNumber}"',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: _T.textDark,
                      ),
                    ),
                    const TextSpan(
                        text:
                            '? All associated data will be permanently removed.'),
                  ],
                ),
              ),
            ),

            // Actions
            Padding(
              padding:
                  const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            vertical: 13),
                        foregroundColor: _T.textMuted,
                        side:
                            const BorderSide(color: _T.divider),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(13),
                        ),
                      ),
                      child: const Text('Cancel',
                          style: TextStyle(
                              fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: _T.danger,
                        borderRadius:
                            BorderRadius.circular(13),
                        boxShadow: [
                          BoxShadow(
                            color:
                                _T.danger.withOpacity(0.25),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius:
                              BorderRadius.circular(13),
                          onTap: () async {
                            try {
                              await provider.deleteInvoice(
                                  invoice.id);
                              if (context.mounted) {
                                Navigator.pop(context);
                                context.showSnackBar(
                                    'Invoice deleted successfully');
                              }
                            } catch (e) {
                              if (context.mounted) {
                                Navigator.pop(context);
                                context.showSnackBar(
                                    'Failed to delete invoice: $e',
                                    isError: true);
                              }
                            }
                          },
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(
                                    vertical: 13),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              children: const [
                                Icon(
                                    Icons
                                        .delete_outline_rounded,
                                    color: Colors.white,
                                    size: 16),
                                SizedBox(width: 6),
                                Text(
                                  'Delete',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
