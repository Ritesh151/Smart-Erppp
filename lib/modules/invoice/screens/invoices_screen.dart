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

class _T {
  static const gradientStart = Color(0xFF4F6EF7);
  static const gradientEnd = Color(0xFF7C3AED);

  static const bg = Color(0xFFF5F7FA);
  static const white = Colors.white;

  static const textDark = Color(0xFF111827);
  static const textMuted = Color(0xFF6B7280);
  static const textLight = Color(0xFF9CA3AF);

  static const divider = Color(0xFFE5E7EB);

  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFF59E0B);
  static const danger = Color(0xFFEF4444);

  static const Gradient brandGradient = LinearGradient(
    colors: [gradientStart, gradientEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static BoxDecoration card({
    double radius = 18,
    bool hover = false,
  }) {
    return BoxDecoration(
      color: white,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: hover
            ? gradientStart.withOpacity(0.12)
            : divider.withOpacity(0.8),
      ),
      boxShadow: [
        BoxShadow(
          color: hover
              ? gradientStart.withOpacity(0.12)
              : const Color(0xFF1E2A6E).withOpacity(0.06),
          blurRadius: hover ? 22 : 16,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }
}

class InvoicesScreen extends StatefulWidget {
  const InvoicesScreen({super.key});

  @override
  State<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends State<InvoicesScreen> {
  int _currentPage = 1;
  static const int _pageSize = 10;

  final List<Map<String, dynamic>> _statusOptions = [
    {'label': 'Draft', 'value': 'draft'},
    {'label': 'Sent', 'value': 'sent'},
    {'label': 'Paid', 'value': 'paid'},
    {'label': 'Partially Paid', 'value': 'partiallyPaid'},
    {'label': 'Overdue', 'value': 'overdue'},
    {'label': 'Cancelled', 'value': 'cancelled'},
  ];

  String? _selectedStatusValue;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InvoiceProvider>().loadInvoices();
    });
  }

  @override
  Widget build(BuildContext context) {
    final padding = context.isMobile ? 16.0 : 24.0;

    return Consumer<InvoiceProvider>(
      builder: (context, provider, _) {
        final invoicesList = provider.invoices;

        return Container(
          color: _T.bg,
          child: SafeArea(
            child: RefreshIndicator(
              color: _T.gradientStart,
              onRefresh: () async {
                await provider.loadInvoices();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(padding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context),

                    SizedBox(height: context.isMobile ? 18 : 24),

                    _buildTopAnalytics(provider)
                        .animate()
                        .fadeIn(duration: 300.ms)
                        .slideY(begin: 0.08, end: 0),

                    SizedBox(height: context.isMobile ? 18 : 24),

                    _buildFilterContainer(context, provider),

                    SizedBox(height: context.isMobile ? 18 : 24),

                    provider.isLoading
                        ? _buildShimmerLoading(context)
                        : invoicesList.isEmpty
                            ? _buildEmptyState(provider)
                            : _buildInvoicesLayout(
                                context,
                                invoicesList,
                                provider,
                              ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final vertical = constraints.maxWidth < 760;

        if (vertical) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 10,
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          gradient: _T.brandGradient,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.receipt_long_rounded,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Manage Invoices',
                        style: TextStyle(
                          fontSize: context.isMobile ? 24 : 30,
                          fontWeight: FontWeight.w800,
                          color: _T.textDark,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Create, send, and track your business invoices.',
                    style: TextStyle(
                      fontSize: context.isMobile ? 13 : 14,
                      color: _T.textMuted,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Container(
                decoration: BoxDecoration(
                  gradient: _T.brandGradient,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: _T.gradientStart.withOpacity(0.25),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: () => context.push('/invoices/create'),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Create Invoice'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shadowColor: Colors.transparent,
                    padding: EdgeInsets.symmetric(
                      horizontal: context.isMobile ? 18 : 22,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 10,
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          gradient: _T.brandGradient,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.receipt_long_rounded,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Manage Invoices',
                        style: TextStyle(
                          fontSize: context.isMobile ? 24 : 30,
                          fontWeight: FontWeight.w800,
                          color: _T.textDark,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Create, send, and track your business invoices.',
                    style: TextStyle(
                      fontSize: context.isMobile ? 13 : 14,
                      color: _T.textMuted,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 18),
            Container(
              decoration: BoxDecoration(
                gradient: _T.brandGradient,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: _T.gradientStart.withOpacity(0.25),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: () => context.push('/invoices/create'),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Create Invoice'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  padding: EdgeInsets.symmetric(
                    horizontal: context.isMobile ? 18 : 22,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTopAnalytics(InvoiceProvider provider) {
    final invoices = provider.invoices;
    final totalInvoices = invoices.length;
    final totalAmount = invoices.fold<double>(0, (sum, i) => sum + i.totalAmount);
    final overdueCount = invoices.where((i) => i.isOverdue).length;
    final paidThisMonth = invoices.where((i) =>
        i.status == InvoiceStatus.paid &&
        i.updatedAt.month == DateTime.now().month &&
        i.updatedAt.year == DateTime.now().year).length;

    final items = [
      {
        'title': 'Total Invoices',
        'value': '$totalInvoices',
        'icon': Icons.receipt_long_rounded,
        'color': const Color(0xFF4F6EF7),
      },
      {
        'title': 'Total Amount',
        'value': '₹${totalAmount.toStringAsFixed(0)}',
        'icon': Icons.account_balance_wallet_rounded,
        'color': const Color(0xFF10B981),
      },
      {
        'title': 'Overdue',
        'value': '$overdueCount',
        'icon': Icons.warning_amber_rounded,
        'color': const Color(0xFFEF4444),
      },
      {
        'title': 'Paid this Month',
        'value': '$paidThisMonth',
        'icon': Icons.check_circle_rounded,
        'color': const Color(0xFF10B981),
      },
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = context.isMobile ? 2 : 4;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: context.isMobile ? 1.25 : 1.5,
          ),
          itemBuilder: (context, index) {
            final item = items[index];

            return Container(
              padding: const EdgeInsets.all(18),
              decoration: _T.card(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color:
                          (item['color'] as Color).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      item['icon'] as IconData,
                      color: item['color'] as Color,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    item['value'] as String,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: _T.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item['title'] as String,
                    style: const TextStyle(
                      fontSize: 12,
                      color: _T.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFilterContainer(
    BuildContext context,
    InvoiceProvider provider,
  ) {
    return Container(
      padding: EdgeInsets.all(context.isMobile ? 16 : 20),
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
          if (val == 'draft') status = InvoiceStatus.draft;
          if (val == 'sent') status = InvoiceStatus.sent;
          if (val == 'paid') status = InvoiceStatus.paid;
          if (val == 'partiallyPaid') status = InvoiceStatus.partiallyPaid;
          if (val == 'overdue') status = InvoiceStatus.overdue;
          if (val == 'cancelled') status = InvoiceStatus.cancelled;

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

  Widget _buildEmptyState(InvoiceProvider provider) {
    final hasFilters = provider.searchQuery.isNotEmpty ||
        provider.filterStatus != null;

    return Container(
      padding: const EdgeInsets.all(24),
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

  Widget _buildShimmerLoading(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFEAECEF),
      highlightColor: Colors.white,
      child: Column(
        children: List.generate(
          6,
          (index) => Container(
            height: 100,
            margin: const EdgeInsets.only(bottom: 14),
            decoration: _T.card(),
          ),
        ),
      ),
    );
  }

  Widget _buildInvoicesLayout(
    BuildContext context,
    List<InvoiceModel> list,
    InvoiceProvider provider,
  ) {
    final totalItems = list.length;
    final totalPages = (totalItems / _pageSize).ceil();
    final startIdx = (_currentPage - 1) * _pageSize;
    final endIdx =
        startIdx + _pageSize > totalItems ? totalItems : startIdx + _pageSize;
    final pageList = list.sublist(startIdx, endIdx);

    return Column(
      children: [
        context.isDesktop
            ? _buildDesktopTable(context, pageList, provider)
            : _buildMobileSlidableList(context, pageList, provider),

        if (totalPages > 1) ...[
          const SizedBox(height: 24),
          _buildPaginationControls(totalPages),
        ],
      ],
    );
  }

  Widget _buildDesktopTable(
    BuildContext context,
    List<InvoiceModel> list,
    InvoiceProvider provider,
  ) {
    return Container(
      decoration: _T.card(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Theme(
            data: Theme.of(context).copyWith(
              dividerColor: _T.divider,
            ),
            child: DataTable(
              horizontalMargin: 20,
              columnSpacing: 26,
              headingRowHeight: 56,
              dataRowMinHeight: 78,
              dataRowMaxHeight: 86,
              headingRowColor: MaterialStateProperty.all(
                const Color(0xFFF8FAFC),
              ),
              columns: const [
                DataColumn(label: Text('Invoice#')),
                DataColumn(label: Text('Customer')),
                DataColumn(label: Text('Date')),
                DataColumn(label: Text('Due')),
                DataColumn(label: Text('Total')),
                DataColumn(label: Text('Paid')),
                DataColumn(label: Text('Balance')),
                DataColumn(label: Text('Status')),
                DataColumn(label: Text('Actions')),
              ],
              rows: list.map((invoice) {
                return DataRow(
                  cells: [
                    DataCell(
                      InkWell(
                        onTap: () => context.push('/invoices/${invoice.id}'),
                        child: Text(
                          invoice.invoiceNumber,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: _T.textDark,
                          ),
                        ),
                      ),
                    ),
                    DataCell(
                      SizedBox(
                        width: 160,
                        child: Text(
                          invoice.customerName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(invoice.invoiceDate.toFormattedDate()),
                    ),
                    DataCell(
                      Text(invoice.dueDate.toFormattedDate()),
                    ),
                    DataCell(
                      Text(
                        '₹${invoice.totalAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        '₹${invoice.paidAmount.toStringAsFixed(2)}',
                      ),
                    ),
                    DataCell(
                      Text(
                        '₹${invoice.balanceAmount.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: invoice.balanceAmount > 0
                              ? _T.danger
                              : _T.success,
                        ),
                      ),
                    ),
                    DataCell(
                      _buildStatusChip(invoice),
                    ),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _tableActionButton(
                            icon: Icons.visibility_outlined,
                            color: _T.gradientStart,
                            onTap: () => context.push(
                              '/invoices/${invoice.id}',
                            ),
                          ),
                          const SizedBox(width: 8),
                          _tableActionButton(
                            icon: Icons.edit_outlined,
                            color: _T.warning,
                            onTap: () {
                              if (invoice.status == InvoiceStatus.draft ||
                                  invoice.status == InvoiceStatus.sent) {
                                context.push(
                                  '/invoices/${invoice.id}/edit',
                                );
                              }
                            },
                          ),
                          const SizedBox(width: 8),
                          _tableActionButton(
                            icon: Icons.delete_outline_rounded,
                            color: _T.danger,
                            onTap: () => _confirmDeleteInvoice(
                              context,
                              invoice,
                              provider,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _tableActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 18,
          color: color,
        ),
      ),
    );
  }

  Widget _buildMobileSlidableList(
    BuildContext context,
    List<InvoiceModel> list,
    InvoiceProvider provider,
  ) {
    return SlidableAutoCloseBehavior(
      child: ListView.builder(
        itemCount: list.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          final invoice = list[index];

          return _HoverInvoiceCard(
            child: Slidable(
              key: ValueKey(invoice.id),
              endActionPane: ActionPane(
                motion: const DrawerMotion(),
                children: [
                  SlidableAction(
                    onPressed: (_) {
                      if (invoice.status == InvoiceStatus.draft ||
                          invoice.status == InvoiceStatus.sent) {
                        context.push('/invoices/${invoice.id}/edit');
                      }
                    },
                    backgroundColor: _T.warning,
                    foregroundColor: Colors.white,
                    icon: Icons.edit,
                    label: 'Edit',
                  ),
                  SlidableAction(
                    onPressed: (_) {
                      _confirmDeleteInvoice(
                        context,
                        invoice,
                        provider,
                      );
                    },
                    backgroundColor: _T.danger,
                    foregroundColor: Colors.white,
                    icon: Icons.delete,
                    label: 'Delete',
                  ),
                ],
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () => context.push('/invoices/${invoice.id}'),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(16),
                  decoration: _T.card(),
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: _T.gradientStart.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          Icons.receipt_rounded,
                          color: _T.gradientStart.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              invoice.invoiceNumber,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: context.isMobile ? 14 : 15,
                                fontWeight: FontWeight.w700,
                                color: _T.textDark,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              invoice.customerName,
                              style: const TextStyle(
                                fontSize: 12,
                                color: _T.textMuted,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 10,
                              runSpacing: 6,
                              children: [
                                _infoPill(
                                  Icons.currency_rupee_rounded,
                                  '₹${invoice.totalAmount.toStringAsFixed(2)}',
                                ),
                                _infoPill(
                                  Icons.date_range_rounded,
                                  invoice.dueDate.toFormattedDate(),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _buildStatusChip(invoice),
                          const SizedBox(height: 10),
                          const Icon(
                            Icons.chevron_right_rounded,
                            color: _T.textLight,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ).animate().fadeIn(
                delay: (index * 40).ms,
                duration: 240.ms,
              );
        },
      ),
    );
  }

  Widget _infoPill(IconData icon, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: _T.gradientStart.withOpacity(0.06),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 13,
            color: _T.gradientStart,
          ),
          const SizedBox(width: 5),
          Text(
            value,
            style: const TextStyle(
              fontSize: 11,
              color: _T.textDark,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationControls(int totalPages) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 12,
      runSpacing: 12,
      children: [
        _paginationButton(
          icon: Icons.chevron_left_rounded,
          enabled: _currentPage > 1,
          onTap: () {
            setState(() => _currentPage--);
          },
        ),

        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 12,
          ),
          decoration: _T.card(radius: 14),
          child: Text(
            'Page $_currentPage of $totalPages',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: _T.textDark,
            ),
          ),
        ),

        _paginationButton(
          icon: Icons.chevron_right_rounded,
          enabled: _currentPage < totalPages,
          onTap: () {
            setState(() => _currentPage++);
          },
        ),
      ],
    );
  }

  Widget _paginationButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: enabled ? onTap : null,
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          gradient: enabled ? _T.brandGradient : null,
          color: enabled ? null : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(
          icon,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildStatusChip(InvoiceModel invoice) {
    late Color color;
    late String label;
    late TextStyle textStyle;

    switch (invoice.status) {
      case InvoiceStatus.draft:
        color = _T.textMuted;
        label = 'DRAFT';
        break;
      case InvoiceStatus.sent:
        color = _T.gradientStart;
        label = 'SENT';
        break;
      case InvoiceStatus.paid:
        color = _T.success;
        label = 'PAID';
        break;
      case InvoiceStatus.partiallyPaid:
        color = _T.warning;
        label = 'PARTIAL';
        break;
      case InvoiceStatus.overdue:
        color = _T.danger;
        label = 'OVERDUE';
        break;
      case InvoiceStatus.cancelled:
        color = _T.textMuted;
        label = 'CANCELLED';
        break;
    }

    if (invoice.status == InvoiceStatus.cancelled) {
      textStyle = TextStyle(
        color: color,
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.3,
        decoration: TextDecoration.lineThrough,
      );
    } else {
      textStyle = TextStyle(
        color: color,
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.3,
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Text(
        label,
        style: textStyle,
      ),
    );
  }

  void _confirmDeleteInvoice(
    BuildContext context,
    InvoiceModel invoice,
    InvoiceProvider provider,
  ) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Text(
            'Delete Invoice?',
            style: TextStyle(
              fontWeight: FontWeight.w800,
            ),
          ),
          content: Text(
            'Are you sure you want to permanently delete invoice "${invoice.invoiceNumber}"? This action cannot be undone.',
            style: const TextStyle(
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            Container(
              decoration: BoxDecoration(
                color: _T.danger,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextButton(
                onPressed: () async {
                  try {
                    await provider.deleteInvoice(invoice.id);

                    if (context.mounted) {
                      Navigator.pop(context);
                      context.showSnackBar(
                        'Invoice deleted successfully',
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      Navigator.pop(context);
                      context.showSnackBar(
                        'Failed to delete invoice: $e',
                        isError: true,
                      );
                    }
                  }
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _HoverInvoiceCard extends StatefulWidget {
  final Widget child;

  const _HoverInvoiceCard({
    required this.child,
  });

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
      onEnter: (_) {
        setState(() => _hovered = true);
      },
      onExit: (_) {
        setState(() => _hovered = false);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        transform: Matrix4.identity()
          ..translate(0.0, _hovered ? -2.0 : 0.0),
        child: widget.child,
      ),
    );
  }
}
