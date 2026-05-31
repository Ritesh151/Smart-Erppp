import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import 'package:siddhivinayak_enterprise/core/constants/app_constants.dart';
import 'package:siddhivinayak_enterprise/core/extensions/context_extensions.dart';
import 'package:siddhivinayak_enterprise/core/models/customer_model.dart';
import 'package:siddhivinayak_enterprise/core/theme/theme_extensions.dart';
import 'package:siddhivinayak_enterprise/core/widgets/empty_state_widget.dart';
import 'package:siddhivinayak_enterprise/core/widgets/search_filter_bar.dart';
import 'package:siddhivinayak_enterprise/modules/invoice/providers/customer_provider.dart';
import 'package:siddhivinayak_enterprise/modules/invoice/services/customer_service.dart';

class _T {
  static const gradientStart = Color(0xFF4F6EF7);
  static const gradientEnd = Color(0xFF7C3AED);
  static const bg = Color(0xFFF5F7FA);
  static const white = Colors.white;
  static const textDark = Color(0xFF111827);
  static const textMid = Color(0xFF374151);
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

  static BoxDecoration card({double radius = 16, bool hover = false}) =>
      BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(radius),
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

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  int _currentPage = 1;
  static const int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CustomerProvider>().loadCustomers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final padding = context.isMobile ? 16.0 : 24.0;

    return Consumer<CustomerProvider>(
      builder: (context, provider, _) {
        final customersList = provider.customers;

        return Container(
          color: _T.bg,
          child: SafeArea(
            child: RefreshIndicator(
              color: _T.gradientStart,
              onRefresh: () async => provider.loadCustomers(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(padding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context)
                        .animate()
                        .fadeIn(duration: 280.ms)
                        .slideX(begin: -0.04, end: 0),
                    SizedBox(height: context.isMobile ? 18 : 24),
                    _buildTopAnalytics(provider)
                        .animate()
                        .fadeIn(delay: 60.ms, duration: 280.ms)
                        .slideY(begin: 0.08, end: 0),
                    SizedBox(height: context.isMobile ? 18 : 24),
                    _buildFilterContainer(context, provider)
                        .animate()
                        .fadeIn(delay: 100.ms, duration: 280.ms)
                        .slideY(begin: 0.08, end: 0),
                    SizedBox(height: context.isMobile ? 18 : 24),
                    provider.isLoading
                        ? _buildShimmerLoading(context)
                        : customersList.isEmpty
                            ? _buildEmptyState(provider)
                            : _buildCustomersLayout(
                                context, customersList, provider),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    final titleBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: _T.brandGradient,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: _T.gradientStart.withOpacity(0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(Icons.people_rounded,
                  color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              'Manage Customers',
              style: TextStyle(
                fontSize: context.isMobile ? 22 : 28,
                fontWeight: FontWeight.w800,
                color: _T.textDark,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'View and manage your customer database and contacts.',
          style: TextStyle(
            fontSize: context.isMobile ? 13 : 14,
            color: _T.textMuted,
            height: 1.5,
          ),
        ),
      ],
    );

    final addBtn = Container(
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
      child: ElevatedButton.icon(
        onPressed: () => context.push('/customers/create'),
        icon: const Icon(Icons.add_rounded, size: 18),
        label: const Text(
          'Add Customer',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.symmetric(
            horizontal: context.isMobile ? 18 : 22,
            vertical: 14,
          ),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );

    return LayoutBuilder(builder: (context, constraints) {
      final isNarrow = constraints.maxWidth < 640;
      if (isNarrow) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            titleBlock,
            const SizedBox(height: 16),
            addBtn,
          ],
        );
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: titleBlock),
          const SizedBox(width: 18),
          addBtn,
        ],
      );
    });
  }

  // ── Top analytics ─────────────────────────────────────────────────────────
  Widget _buildTopAnalytics(CustomerProvider provider) {
    final totalCustomers = provider.totalCustomers;
    final active = provider.customers.where((c) => c.isActive).length;
    final inactive = totalCustomers - active;

    final items = [
      {
        'title': 'Total Customers',
        'value': '$totalCustomers',
        'icon': Icons.people_rounded,
        'color': _T.gradientStart,
        'bg': const Color(0xFFEEF2FF),
      },
      {
        'title': 'Active',
        'value': '$active',
        'icon': Icons.check_circle_outline_rounded,
        'color': _T.success,
        'bg': const Color(0xFFECFDF5),
      },
      {
        'title': 'Inactive',
        'value': '$inactive',
        'icon': Icons.cancel_outlined,
        'color': _T.danger,
        'bg': const Color(0xFFFEF2F2),
      },
    ];

    return LayoutBuilder(builder: (context, constraints) {
      final spacing = context.isMobile ? 12.0 : 16.0;
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: spacing,
          mainAxisSpacing: spacing,
          childAspectRatio: context.isMobile ? 1.35 : 2.8,
        ),
        itemBuilder: (context, index) {
          final item = items[index];
          final color = item['color'] as Color;
          final bg = item['bg'] as Color;
          return Container(
            padding: EdgeInsets.all(context.isMobile ? 10 : 14),
            decoration: BoxDecoration(
              color: _T.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _T.divider, width: 1),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1E2A6E).withOpacity(0.05),
                  blurRadius: 14,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: context.isMobile
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: bg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(item['icon'] as IconData,
                            color: color, size: 14),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item['value'] as String,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: _T.textDark,
                          letterSpacing: -0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 1),
                      Text(
                        item['title'] as String,
                        style: const TextStyle(
                            fontSize: 10,
                            color: _T.textMuted,
                            fontWeight: FontWeight.w500),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: bg,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(item['icon'] as IconData,
                            color: color, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              item['value'] as String,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: _T.textDark,
                                letterSpacing: -0.3,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 1),
                            Text(
                              item['title'] as String,
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: _T.textMuted,
                                  fontWeight: FontWeight.w500),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
          )
              .animate()
              .fadeIn(delay: (index * 60).ms, duration: 260.ms)
              .slideY(begin: 0.1, end: 0);
        },
      );
    });
  }

  // ── Filter bar ────────────────────────────────────────────────────────────
  Widget _buildFilterContainer(
      BuildContext context, CustomerProvider provider) {
    return Container(
      padding: EdgeInsets.all(context.isMobile ? 16 : 20),
      decoration: _T.card(),
      child: SearchFilterBar(
        hintText: 'Search by name, email, phone, or city...',
        searchQuery: provider.searchQuery,
        onSearchChanged: (query) {
          setState(() => _currentPage = 1);
          provider.searchCustomers(query);
        },
        onClearAll: () {
          setState(() => _currentPage = 1);
          provider.clearSearch();
        },
      ),
    );
  }

  // ── Empty state ───────────────────────────────────────────────────────────
  Widget _buildEmptyState(CustomerProvider provider) {
    final hasFilters = provider.searchQuery.isNotEmpty;
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: _T.card(),
      child: EmptyStateWidget(
        icon: hasFilters
            ? Icons.search_off_rounded
            : Icons.people_outline_rounded,
        title: hasFilters
            ? 'No Matching Customers Found'
            : 'No Customers Yet',
        message: hasFilters
            ? 'Try expanding your keywords or adjusting filters.'
            : 'Add your first customer to start building your database.',
        actionLabel:
            hasFilters ? 'Reset Filters' : 'Create First Customer',
        onAction: () {
          if (hasFilters) {
            setState(() => _currentPage = 1);
            provider.clearSearch();
          } else {
            context.go('/customers/create');
          }
        },
      ),
    );
  }

  // ── Shimmer ───────────────────────────────────────────────────────────────
  Widget _buildShimmerLoading(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFEAECEF),
      highlightColor: Colors.white,
      child: Column(
        children: List.generate(
          6,
          (i) => Container(
            height: 90,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: _T.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }

  // ── Layout dispatcher ─────────────────────────────────────────────────────
  Widget _buildCustomersLayout(
    BuildContext context,
    List<CustomerModel> list,
    CustomerProvider provider,
  ) {
    final totalItems = list.length;
    final totalPages = (totalItems / _pageSize).ceil();
    final startIdx = (_currentPage - 1) * _pageSize;
    final endIdx = (startIdx + _pageSize).clamp(0, totalItems);
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

  // ── Desktop table ─────────────────────────────────────────────────────────
  Widget _buildDesktopTable(
    BuildContext context,
    List<CustomerModel> list,
    CustomerProvider provider,
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
              columnSpacing: 26,
              headingRowHeight: 52,
              dataRowMinHeight: 62,
              dataRowMaxHeight: 70,
              headingRowColor: MaterialStateProperty.all(
                  const Color(0xFFF8FAFC)),
              headingTextStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: _T.textMuted,
                letterSpacing: 0.3,
              ),
              columns: const [
                DataColumn(label: Text('CUSTOMER')),
                DataColumn(label: Text('EMAIL')),
                DataColumn(label: Text('PHONE')),
                DataColumn(label: Text('GST')),
                DataColumn(label: Text('CITY')),
                DataColumn(label: Text('STATUS')),
                DataColumn(label: Text('ACTIONS')),
              ],
              rows: list.map((customer) {
                return DataRow(
                  cells: [
                    DataCell(
                      SizedBox(
                        width: 160,
                        child: InkWell(
                          onTap: () =>
                              context.push('/customers/${customer.id}'),
                          child: Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  gradient: _T.brandGradient,
                                  borderRadius:
                                      BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Text(
                                    customer.name
                                        .substring(0, 1)
                                        .toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  customer.name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: _T.textDark,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    DataCell(SizedBox(
                      width: 155,
                      child: Text(
                        customer.email ?? 'N/A',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 12, color: _T.textMuted),
                      ),
                    )),
                    DataCell(Text(
                      customer.phone ?? 'N/A',
                      style: const TextStyle(
                          fontSize: 12, color: _T.textMid),
                    )),
                    DataCell(Text(
                      customer.gstNumber ?? 'N/A',
                      style: const TextStyle(
                          fontSize: 12, color: _T.textMid),
                    )),
                    DataCell(Text(
                      customer.city ?? 'N/A',
                      style: const TextStyle(
                          fontSize: 12, color: _T.textMid),
                    )),
                    DataCell(_buildActiveChip(customer.isActive)),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _tableActionButton(
                            icon: Icons.visibility_outlined,
                            color: _T.gradientStart,
                            tooltip: 'View',
                            onTap: () => context
                                .push('/customers/${customer.id}'),
                          ),
                          const SizedBox(width: 6),
                          _tableActionButton(
                            icon: Icons.edit_outlined,
                            color: _T.warning,
                            tooltip: 'Edit',
                            onTap: () => context.push(
                                '/customers/${customer.id}/edit'),
                          ),
                          const SizedBox(width: 6),
                          _tableActionButton(
                            icon: Icons.delete_outline_rounded,
                            color: _T.danger,
                            tooltip: 'Delete',
                            onTap: () => _confirmDeleteCustomer(
                                context, customer, provider),
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
    String? tooltip,
  }) {
    return Tooltip(
      message: tooltip ?? '',
      child: _HoverActionBtn(
        icon: icon,
        color: color,
        onTap: onTap,
      ),
    );
  }

  // ── Mobile slidable list ──────────────────────────────────────────────────
  Widget _buildMobileSlidableList(
    BuildContext context,
    List<CustomerModel> list,
    CustomerProvider provider,
  ) {
    return SlidableAutoCloseBehavior(
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: list.length,
        itemBuilder: (context, index) {
          final customer = list[index];
          return _HoverCustomerCard(
            child: Slidable(
              key: ValueKey(customer.id),
              endActionPane: ActionPane(
                motion: const DrawerMotion(),
                children: [
                  SlidableAction(
                    onPressed: (_) => context
                        .push('/customers/${customer.id}/edit'),
                    backgroundColor: _T.warning,
                    foregroundColor: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                    icon: Icons.edit_rounded,
                    label: 'Edit',
                  ),
                  SlidableAction(
                    onPressed: (_) => _confirmDeleteCustomer(
                        context, customer, provider),
                    backgroundColor: _T.danger,
                    foregroundColor: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                    icon: Icons.delete_rounded,
                    label: 'Delete',
                  ),
                ],
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => context.push('/customers/${customer.id}'),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: _T.card(),
                  child: Row(
                    children: [
                      // Avatar
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: _T.brandGradient,
                          borderRadius: BorderRadius.circular(13),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  _T.gradientStart.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            customer.name
                                .substring(0, 1)
                                .toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              customer.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize:
                                    context.isMobile ? 14 : 15,
                                fontWeight: FontWeight.w700,
                                color: _T.textDark,
                              ),
                            ),
                            if (customer.email != null &&
                                customer.email!.isNotEmpty) ...[
                              const SizedBox(height: 3),
                              Text(
                                customer.email!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: _T.textMuted),
                              ),
                            ],
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 5,
                              children: [
                                if (customer.phone != null)
                                  _infoPill(Icons.phone_rounded,
                                      customer.phone!),
                                if (customer.city != null)
                                  _infoPill(
                                      Icons.location_city_rounded,
                                      customer.city!),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildActiveChip(customer.isActive),
                          const SizedBox(height: 8),
                          const Icon(Icons.chevron_right_rounded,
                              color: _T.textLight, size: 18),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
              .animate()
              .fadeIn(delay: (index * 40).ms, duration: 240.ms)
              .slideY(begin: 0.06, end: 0);
        },
      ),
    );
  }

  Widget _buildActiveChip(bool isActive) {
    final color = isActive ? _T.success : _T.textMuted;
    final label = isActive ? 'ACTIVE' : 'INACTIVE';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
                color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3),
          ),
        ],
      ),
    );
  }

  Widget _infoPill(IconData icon, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: _T.gradientStart.withOpacity(0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: _T.gradientStart.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: _T.gradientStart),
          const SizedBox(width: 5),
          Text(
            value,
            style: const TextStyle(
                fontSize: 10,
                color: _T.textDark,
                fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  // ── Pagination ─────────────────────────────────────────────────────────────
  Widget _buildPaginationControls(int totalPages) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 10,
      runSpacing: 10,
      children: [
        _paginationButton(
          icon: Icons.chevron_left_rounded,
          enabled: _currentPage > 1,
          onTap: () => setState(() => _currentPage--),
        ),
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
          decoration: BoxDecoration(
            color: _T.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _T.divider),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1E2A6E).withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            'Page $_currentPage of $totalPages',
            style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: _T.textDark,
                fontSize: 13),
          ),
        ),
        _paginationButton(
          icon: Icons.chevron_right_rounded,
          enabled: _currentPage < totalPages,
          onTap: () => setState(() => _currentPage++),
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
      borderRadius: BorderRadius.circular(12),
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          gradient: enabled ? _T.brandGradient : null,
          color: enabled ? null : const Color(0xFFE5E7EB),
          borderRadius: BorderRadius.circular(12),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: _T.gradientStart.withOpacity(0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Icon(
          icon,
          color: enabled ? Colors.white : _T.textLight,
          size: 20,
        ),
      ),
    );
  }

  // ── Delete dialog ─────────────────────────────────────────────────────────
  void _confirmDeleteCustomer(BuildContext context, CustomerModel customer,
      CustomerProvider provider) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: _T.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22)),
          title: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _T.danger.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.delete_outline_rounded,
                    color: _T.danger, size: 18),
              ),
              const SizedBox(width: 12),
              const Text('Delete Customer?',
                  style: TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 17)),
            ],
          ),
          content: Text(
            'Are you sure you want to permanently delete "${customer.name}"? This action cannot be undone.',
            style: const TextStyle(
                color: _T.textMuted, fontSize: 14, height: 1.6),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel',
                  style: TextStyle(color: _T.textMuted)),
            ),
            Container(
              decoration: BoxDecoration(
                color: _T.danger,
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextButton(
                onPressed: () async {
                  try {
                    await provider.deleteCustomer(customer.id);
                    if (dialogContext.mounted) {
                      Navigator.pop(dialogContext);
                    }
                    if (context.mounted) {
                      context.showSnackBar(
                          'Customer deleted successfully');
                    }
                  } catch (e) {
                    if (dialogContext.mounted) {
                      Navigator.pop(dialogContext);
                    }
                    if (context.mounted) {
                      context.showSnackBar(
                          'Failed to delete customer: $e',
                          isError: true);
                    }
                  }
                },
                child: const Text('Delete',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ── Hover customer card ────────────────────────────────────────────────────
class _HoverCustomerCard extends StatefulWidget {
  final Widget child;
  const _HoverCustomerCard({required this.child});

  @override
  State<_HoverCustomerCard> createState() => _HoverCustomerCardState();
}

class _HoverCustomerCardState extends State<_HoverCustomerCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        transform: Matrix4.identity()
          ..translate(0.0, _hovered ? -2.0 : 0.0),
        child: widget.child,
      ),
    );
  }
}

// ── Hover action button (desktop table) ───────────────────────────────────
class _HoverActionBtn extends StatefulWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _HoverActionBtn({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  State<_HoverActionBtn> createState() => _HoverActionBtnState();
}

class _HoverActionBtnState extends State<_HoverActionBtn> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: _hovered
                ? widget.color.withOpacity(0.15)
                : widget.color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: _hovered
                  ? widget.color.withOpacity(0.3)
                  : Colors.transparent,
            ),
          ),
          child: Icon(widget.icon, size: 17, color: widget.color),
        ),
      ),
    );
  }
}
