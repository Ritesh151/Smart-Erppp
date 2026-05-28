import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import 'package:SmartERP/core/constants/app_constants.dart';
import 'package:SmartERP/core/extensions/context_extensions.dart';
import 'package:SmartERP/core/models/customer_model.dart';
import 'package:SmartERP/core/theme/theme_extensions.dart';
import 'package:SmartERP/core/widgets/empty_state_widget.dart';
import 'package:SmartERP/core/widgets/search_filter_bar.dart';
import 'package:SmartERP/modules/invoice/providers/customer_provider.dart';
import 'package:SmartERP/modules/invoice/services/customer_service.dart';

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

  static BoxDecoration card({double radius = 18, bool hover = false}) {
    return BoxDecoration(
      color: white,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: hover ? gradientStart.withOpacity(0.12) : divider.withOpacity(0.8),
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
              onRefresh: () async {
                await provider.loadCustomers();
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
                        : customersList.isEmpty
                            ? _buildEmptyState(provider)
                            : _buildCustomersLayout(context, customersList, provider),
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
                        child: const Icon(Icons.people_rounded, color: Colors.white),
                      ),
                      Text(
                        'Manage Customers',
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
                    'View and manage your customer database and contacts.',
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
                  onPressed: () => context.push('/customers/create'),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Add Customer'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shadowColor: Colors.transparent,
                    padding: EdgeInsets.symmetric(
                      horizontal: context.isMobile ? 18 : 22,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
                        child: const Icon(Icons.people_rounded, color: Colors.white),
                      ),
                      Text(
                        'Manage Customers',
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
                    'View and manage your customer database and contacts.',
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
                onPressed: () => context.push('/customers/create'),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add Customer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  padding: EdgeInsets.symmetric(
                    horizontal: context.isMobile ? 18 : 22,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTopAnalytics(CustomerProvider provider) {
    final totalCustomers = provider.totalCustomers;
    final active = provider.customers.where((c) => c.isActive).length;
    final inactive = totalCustomers - active;

    final items = [
      {
        'title': 'Total Customers',
        'value': '$totalCustomers',
        'icon': Icons.people_rounded,
        'color': const Color(0xFF4F6EF7),
      },
      {
        'title': 'Active',
        'value': '$active',
        'icon': Icons.check_circle_rounded,
        'color': const Color(0xFF10B981),
      },
      {
        'title': 'Inactive',
        'value': '$inactive',
        'icon': Icons.cancel_outlined,
        'color': const Color(0xFFEF4444),
      },
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = context.isMobile ? 3 : 3;
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
                      color: (item['color'] as Color).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(item['icon'] as IconData, color: item['color'] as Color),
                  ),
                  const Spacer(),
                  Text(
                    item['value'] as String,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: _T.textDark),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item['title'] as String,
                    style: const TextStyle(fontSize: 12, color: _T.textMuted, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFilterContainer(BuildContext context, CustomerProvider provider) {
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

  Widget _buildEmptyState(CustomerProvider provider) {
    final hasFilters = provider.searchQuery.isNotEmpty;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: _T.card(),
      child: EmptyStateWidget(
        icon: hasFilters ? Icons.search_off_rounded : Icons.people_outline_rounded,
        title: hasFilters ? 'No Matching Customers Found' : 'No Customers Yet',
        message: hasFilters
            ? 'Try expanding your keywords or adjusting filters.'
            : 'Add your first customer to start building your database.',
        actionLabel: hasFilters ? 'Reset Filters' : 'Create First Customer',
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

  Widget _buildShimmerLoading(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFEAECEF),
      highlightColor: Colors.white,
      child: Column(
        children: List.generate(6, (index) => Container(
          height: 100,
          margin: const EdgeInsets.only(bottom: 14),
          decoration: _T.card(),
        )),
      ),
    );
  }

  Widget _buildCustomersLayout(
    BuildContext context,
    List<CustomerModel> list,
    CustomerProvider provider,
  ) {
    final totalItems = list.length;
    final totalPages = (totalItems / _pageSize).ceil();
    final startIdx = (_currentPage - 1) * _pageSize;
    final endIdx = startIdx + _pageSize > totalItems ? totalItems : startIdx + _pageSize;
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
    List<CustomerModel> list,
    CustomerProvider provider,
  ) {
    return Container(
      decoration: _T.card(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: _T.divider),
            child: DataTable(
              horizontalMargin: 20,
              columnSpacing: 26,
              headingRowHeight: 56,
              dataRowMinHeight: 64,
              dataRowMaxHeight: 72,
              headingRowColor: MaterialStateProperty.all(const Color(0xFFF8FAFC)),
              columns: const [
                DataColumn(label: Text('Name')),
                DataColumn(label: Text('Email')),
                DataColumn(label: Text('Phone')),
                DataColumn(label: Text('GST')),
                DataColumn(label: Text('City')),
                DataColumn(label: Text('Status')),
                DataColumn(label: Text('Actions')),
              ],
              rows: list.map((customer) {
                return DataRow(cells: [
                  DataCell(
                    SizedBox(
                      width: 160,
                      child: InkWell(
                        onTap: () => context.push('/customers/${customer.id}'),
                        child: Text(
                          customer.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w700, color: _T.textDark),
                        ),
                      ),
                    ),
                  ),
                  DataCell(SizedBox(
                    width: 160,
                    child: Text(customer.email ?? 'N/A', maxLines: 1, overflow: TextOverflow.ellipsis),
                  )),
                  DataCell(Text(customer.phone ?? 'N/A')),
                  DataCell(Text(customer.gstNumber ?? 'N/A')),
                  DataCell(Text(customer.city ?? 'N/A')),
                  DataCell(_buildActiveChip(customer.isActive)),
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _tableActionButton(
                          icon: Icons.visibility_outlined,
                          color: _T.gradientStart,
                          onTap: () => context.push('/customers/${customer.id}'),
                        ),
                        const SizedBox(width: 8),
                        _tableActionButton(
                          icon: Icons.edit_outlined,
                          color: _T.warning,
                          onTap: () => context.push('/customers/${customer.id}/edit'),
                        ),
                        const SizedBox(width: 8),
                        _tableActionButton(
                          icon: Icons.delete_outline_rounded,
                          color: _T.danger,
                          onTap: () => _confirmDeleteCustomer(context, customer, provider),
                        ),
                      ],
                    ),
                  ),
                ]);
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
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }

  Widget _buildMobileSlidableList(
    BuildContext context,
    List<CustomerModel> list,
    CustomerProvider provider,
  ) {
    return SlidableAutoCloseBehavior(
      child: ListView.builder(
        itemCount: list.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          final customer = list[index];
          return _HoverCustomerCard(
            child: Slidable(
              key: ValueKey(customer.id),
              endActionPane: ActionPane(
                motion: const DrawerMotion(),
                children: [
                  SlidableAction(
                    onPressed: (_) => context.push('/customers/${customer.id}/edit'),
                    backgroundColor: _T.warning,
                    foregroundColor: Colors.white,
                    icon: Icons.edit,
                    label: 'Edit',
                  ),
                  SlidableAction(
                    onPressed: (_) => _confirmDeleteCustomer(context, customer, provider),
                    backgroundColor: _T.danger,
                    foregroundColor: Colors.white,
                    icon: Icons.delete,
                    label: 'Delete',
                  ),
                ],
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () => context.push('/customers/${customer.id}'),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(16),
                  decoration: _T.card(),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              customer.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: context.isMobile ? 14 : 15,
                                fontWeight: FontWeight.w700,
                                color: _T.textDark,
                              ),
                            ),
                            const SizedBox(height: 6),
                            if (customer.email != null && customer.email!.isNotEmpty)
                              Text(
                                customer.email!,
                                style: const TextStyle(fontSize: 12, color: _T.textMuted),
                              ),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 10,
                              runSpacing: 6,
                              children: [
                                if (customer.phone != null)
                                  _infoPill(Icons.phone_rounded, customer.phone!),
                                if (customer.city != null)
                                  _infoPill(Icons.location_city_rounded, customer.city!),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _buildActiveChip(customer.isActive),
                          const SizedBox(height: 10),
                          const Icon(Icons.chevron_right_rounded, color: _T.textLight),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ).animate().fadeIn(delay: (index * 40).ms, duration: 240.ms);
        },
      ),
    );
  }

  Widget _buildActiveChip(bool isActive) {
    final color = isActive ? _T.success : _T.textMuted;
    final label = isActive ? 'ACTIVE' : 'INACTIVE';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.3),
      ),
    );
  }

  Widget _infoPill(IconData icon, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _T.gradientStart.withOpacity(0.06),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: _T.gradientStart),
          const SizedBox(width: 5),
          Text(value, style: const TextStyle(fontSize: 11, color: _T.textDark, fontWeight: FontWeight.w600)),
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
          onTap: () => setState(() => _currentPage--),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: _T.card(radius: 14),
          child: Text(
            'Page $_currentPage of $totalPages',
            style: const TextStyle(fontWeight: FontWeight.w700, color: _T.textDark),
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
        child: Icon(icon, color: Colors.white),
      ),
    );
  }

  void _confirmDeleteCustomer(BuildContext context, CustomerModel customer, CustomerProvider provider) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          title: const Text('Delete Customer?', style: TextStyle(fontWeight: FontWeight.w800)),
          content: Text(
            'Are you sure you want to permanently delete "${customer.name}"? This action cannot be undone.',
            style: const TextStyle(height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
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
                    await provider.deleteCustomer(customer.id);
                    if (dialogContext.mounted) {
                      Navigator.pop(dialogContext);
                    }
                    if (context.mounted) {
                      context.showSnackBar('Customer deleted successfully');
                    }
                  } catch (e) {
                    if (dialogContext.mounted) {
                      Navigator.pop(dialogContext);
                    }
                    if (context.mounted) {
                      context.showSnackBar('Failed to delete customer: $e', isError: true);
                    }
                  }
                },
                child: const Text('Delete', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        );
      },
    );
  }
}

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
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        transform: Matrix4.identity()..translate(0.0, _hovered ? -2.0 : 0.0),
        child: widget.child,
      ),
    );
  }
}
