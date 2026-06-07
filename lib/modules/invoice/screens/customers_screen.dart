import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import 'package:siddhivinayak_enterprise/core/extensions/context_extensions.dart';
import 'package:siddhivinayak_enterprise/core/models/customer_model.dart';
import 'package:siddhivinayak_enterprise/core/utils/currency_formatter.dart';
import 'package:siddhivinayak_enterprise/modules/invoice/providers/customer_provider.dart';

class _T {
  static const indigo50 = Color(0xFFEEF2FF);
  static const indigo100 = Color(0xFFE0E7FF);
  static const indigo500 = Color(0xFF6366F1);
  static const indigo600 = Color(0xFF4F46E5);
  static const violet600 = Color(0xFF7C3AED);

  static const emerald50 = Color(0xFFECFDF5);
  static const emerald500 = Color(0xFF10B981);
  static const emerald600 = Color(0xFF059669);

  static const amber50 = Color(0xFFFFFBEB);
  static const amber500 = Color(0xFFF59E0B);
  static const amber600 = Color(0xFFD97706);

  static const rose50 = Color(0xFFFFF1F2);
  static const rose500 = Color(0xFFF43F5E);
  static const rose600 = Color(0xFFE11D48);

  static const sky50 = Color(0xFFF0F9FF);
  static const sky500 = Color(0xFF0EA5E9);
  static const sky600 = Color(0xFF0284C7);

  static const bg = Color(0xFFF8FAFC);
  static const surface = Colors.white;
  static const border = Color(0xFFE2E8F0);
  static const borderLight = Color(0xFFF1F5F9);

  static const textPrimary = Color(0xFF0F172A);
  static const textSecondary = Color(0xFF475569);
  static const textTertiary = Color(0xFF94A3B8);
  static const textDisabled = Color(0xFFCBD5E1);

  static const Gradient primaryGradient = LinearGradient(
    colors: [indigo500, violet600],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient successGradient = LinearGradient(
    colors: [emerald500, Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient warningGradient = LinearGradient(
    colors: [amber500, Color(0xFFD97706)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient dangerGradient = LinearGradient(
    colors: [rose500, Color(0xFFBE123C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient infoGradient = LinearGradient(
    colors: [sky500, Color(0xFF0369A1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static BoxDecoration card() => BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      );

  static BoxDecoration elevatedCard() => BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      );

  static EdgeInsets padding(BuildContext context) => EdgeInsets.all(
        context.isMobile ? 16 : 24,
      );
}

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;
  bool _showFilters = false;
  String? _statusFilter;
  String? _cityFilter;
  int _sortColumn = -1;
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CustomerProvider>().loadCustomers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  List<CustomerModel> _processCustomers(List<CustomerModel> customers) {
    var result = List<CustomerModel>.from(customers);

    if (_statusFilter != null) {
      final isActive = _statusFilter == 'active';
      result = result.where((c) => c.isActive == isActive).toList();
    }

    if (_cityFilter != null && _cityFilter!.isNotEmpty) {
      result = result
          .where((c) => c.city?.toLowerCase() == _cityFilter!.toLowerCase())
          .toList();
    }

    if (_sortColumn >= 0) {
      result.sort((a, b) {
        int cmp;
        switch (_sortColumn) {
          case 0:
            cmp = a.name.toLowerCase().compareTo(b.name.toLowerCase());
          case 1:
            cmp = (a.email ?? '').toLowerCase().compareTo((b.email ?? '').toLowerCase());
          case 2:
            cmp = (a.phone ?? '').compareTo(b.phone ?? '');
          case 3:
            cmp = (a.city ?? '').toLowerCase().compareTo((b.city ?? '').toLowerCase());
          case 4:
            cmp = b.createdAt.compareTo(a.createdAt);
          default:
            cmp = 0;
        }
        return _sortAscending ? cmp : -cmp;
      });
    }

    return result;
  }

  Set<String> _getCities(List<CustomerModel> customers) {
    return customers
        .where((c) => c.city != null && c.city!.isNotEmpty)
        .map((c) => c.city!)
        .toSet();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CustomerProvider>(
      builder: (context, provider, _) {
        final customers = _processCustomers(provider.customers);

        return Scaffold(
          backgroundColor: _T.bg,
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(context, provider),
                if (provider.isLoading)
                  _buildShimmerLoading()
                else if (customers.isEmpty)
                  Expanded(child: _buildEmptyState(context, provider))
                else
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth < 768) {
                          return _buildMobileView(context, customers, provider);
                        }
                        return _buildDesktopView(context, customers, provider);
                      },
                    ),
                  ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => context.push('/customers/create'),
            backgroundColor: _T.indigo600,
            foregroundColor: Colors.white,
            elevation: 4,
            icon: const Icon(Icons.add_rounded, size: 20),
            label: const Text('Add Customer',
                style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, CustomerProvider provider) {
    final isWide = MediaQuery.of(context).size.width >= 768;

    return Container(
      padding: EdgeInsets.fromLTRB(
        _T.padding(context).left,
        _T.padding(context).top,
        _T.padding(context).right,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isWide)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  _BreadcrumbItem(label: 'Home', onTap: () => context.go('/dashboard')),
                  const _BreadcrumbSeparator(),
                  const _BreadcrumbItem(label: 'Customers', isActive: true),
                ],
              ),
            ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            gradient: _T.primaryGradient,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: _T.indigo500.withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.people_rounded,
                              color: Colors.white, size: 22),
                        ),
                        const SizedBox(width: 14),
                        Text(
                          'Customers',
                          style: TextStyle(
                            fontSize: isWide ? 28 : 24,
                            fontWeight: FontWeight.w800,
                            color: _T.textPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Manage your customer relationships and track interactions.',
                      style: TextStyle(
                        fontSize: 13,
                        color: _T.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              if (isWide) ...[
                const SizedBox(width: 16),
                _HeaderActionButton(
                  icon: Icons.download_rounded,
                  label: 'Export',
                  onTap: () {},
                ),
                const SizedBox(width: 10),
                _HeaderActionButton(
                  icon: Icons.refresh_rounded,
                  label: 'Refresh',
                  onTap: () => provider.loadCustomers(),
                ),
              ],
            ],
          ),
          const SizedBox(height: 20),
          _buildAnalyticsRow(provider),
          const SizedBox(height: 20),
          _buildSearchAndFilter(context, provider),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildAnalyticsRow(CustomerProvider provider) {
    final total = provider.totalCustomers;
    final active = provider.customers.where((c) => c.isActive).length;
    final inactive = total - active;
    final newThisMonth = provider.customers.where((c) {
      return c.createdAt.month == DateTime.now().month &&
          c.createdAt.year == DateTime.now().year;
    }).length;

    final cards = [
      _AnalyticsCardData(
        label: 'Total Customers',
        value: '$total',
        icon: Icons.people_rounded,
        gradient: _T.primaryGradient,
        trend: total > 0 ? '+${active} active' : null,
        trendIcon: Icons.trending_up_rounded,
      ),
      _AnalyticsCardData(
        label: 'Active',
        value: '$active',
        icon: Icons.check_circle_rounded,
        gradient: _T.successGradient,
        trend: active > 0 ? '${(active / (total > 0 ? total : 1) * 100).toStringAsFixed(0)}%' : null,
        trendIcon: Icons.trending_up_rounded,
      ),
      _AnalyticsCardData(
        label: 'Inactive',
        value: '$inactive',
        icon: Icons.pause_circle_rounded,
        gradient: _T.warningGradient,
        trend: inactive > 0 ? 'Needs attention' : null,
        trendIcon: Icons.info_rounded,
      ),
      _AnalyticsCardData(
        label: 'New This Month',
        value: '$newThisMonth',
        icon: Icons.person_add_rounded,
        gradient: _T.infoGradient,
        trend: newThisMonth > 0 ? 'This month' : null,
        trendIcon: Icons.calendar_today_rounded,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth < 480
            ? 2
            : constraints.maxWidth < 900
                ? 4
                : 4;
        final childAspectRatio = constraints.maxWidth < 600 ? 1.6 : 2.8;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: childAspectRatio,
          ),
          itemCount: cards.length,
          itemBuilder: (context, index) {
            final card = cards[index];
            return _ModernAnalyticsCard(
              data: card,
              index: index,
            );
          },
        );
      },
    );
  }

  Widget _buildSearchAndFilter(BuildContext context, CustomerProvider provider) {
    final cities = _getCities(provider.customers);

    return Container(
      decoration: _T.elevatedCard(),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: _T.bg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _T.border),
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by name, email, phone, or city...',
                      hintStyle: TextStyle(
                        fontSize: 13,
                        color: _T.textDisabled,
                      ),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Icon(Icons.search_rounded,
                            size: 20, color: _T.textTertiary),
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear_rounded,
                                  size: 18, color: _T.textTertiary),
                              onPressed: () {
                                _searchController.clear();
                                provider.clearSearch();
                                setState(() {});
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                    ),
                    onChanged: (value) {
                      _debounce?.cancel();
                      _debounce = Timer(
                        const Duration(milliseconds: 300),
                        () => provider.searchCustomers(value),
                      );
                      setState(() {});
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _FilterButton(
                label: _statusFilter != null
                    ? _statusFilter == 'active'
                        ? 'Active'
                        : 'Inactive'
                    : 'Status',
                icon: Icons.filter_alt_rounded,
                isActive: _statusFilter != null,
                onTap: () => _showStatusFilter(context),
              ),
              if (cities.isNotEmpty) ...[
                const SizedBox(width: 8),
                _FilterButton(
                  label: _cityFilter ?? 'City',
                  icon: Icons.location_city_rounded,
                  isActive: _cityFilter != null,
                  onTap: () => _showCityFilter(context, cities),
                ),
              ],
              if (_statusFilter != null ||
                  _cityFilter != null ||
                  _searchController.text.isNotEmpty) ...[
                const SizedBox(width: 8),
                InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    setState(() {
                      _statusFilter = null;
                      _cityFilter = null;
                      _searchController.clear();
                    });
                    provider.clearSearch();
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _T.rose50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.clear_all_rounded,
                        size: 18, color: _T.rose500),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  void _showStatusFilter(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const Text('Filter by Status',
                      style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: _T.textPrimary)),
                  const Spacer(),
                  InkWell(
                    onTap: () => Navigator.pop(ctx),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: _T.border.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.close_rounded,
                          size: 18, color: _T.textTertiary),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: _T.border),
            ...[null, 'active', 'inactive'].map((filter) => ListTile(
                  title: Text(
                    filter == null
                        ? 'All'
                        : filter == 'active'
                            ? 'Active'
                            : 'Inactive',
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  trailing: _statusFilter == filter
                      ? const Icon(Icons.check_circle_rounded,
                          color: _T.emerald500, size: 20)
                      : null,
                  onTap: () {
                    setState(() => _statusFilter = filter);
                    Navigator.pop(ctx);
                  },
                )),
          ],
        ),
      ),
    );
  }

  void _showCityFilter(BuildContext context, Set<String> cities) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const Text('Filter by City',
                      style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: _T.textPrimary)),
                  const Spacer(),
                  InkWell(
                    onTap: () => Navigator.pop(ctx),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: _T.border.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.close_rounded,
                          size: 18, color: _T.textTertiary),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: _T.border),
            ListTile(
              title: const Text('All Cities',
                  style:
                      TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              trailing: _cityFilter == null
                  ? const Icon(Icons.check_circle_rounded,
                      color: _T.emerald500, size: 20)
                  : null,
              onTap: () {
                setState(() => _cityFilter = null);
                Navigator.pop(ctx);
              },
            ),
            for (final city in cities)
              ListTile(
                title: Text(city,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600)),
                trailing: _cityFilter == city
                    ? const Icon(Icons.check_circle_rounded,
                        color: _T.emerald500, size: 20)
                    : null,
                onTap: () {
                  setState(() => _cityFilter = city);
                  Navigator.pop(ctx);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopView(
    BuildContext context,
    List<CustomerModel> customers,
    CustomerProvider provider,
  ) {
    return Column(
      children: [
        Expanded(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: _T.padding(context).left),
            decoration: _T.elevatedCard(),
            clipBehavior: Clip.antiAlias,
            child: _buildDataTable(context, customers, provider),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(
            _T.padding(context).left,
            16,
            _T.padding(context).right,
            _T.padding(context).bottom,
          ),
          child: _buildFooter(context, customers),
        ),
      ],
    );
  }

  Widget _buildDataTable(
    BuildContext context,
    List<CustomerModel> customers,
    CustomerProvider provider,
  ) {
    return Scrollbar(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: 1160,
          child: Column(
            children: [
              _buildTableHeader(),
              Expanded(
                child: ListView.builder(
                  itemCount: customers.length,
                  itemBuilder: (context, index) {
                    final customer = customers[index];
                    final isEven = index % 2 == 0;
                    return _CustomerTableRow(
                      customer: customer,
                      isEven: isEven,
                      index: index,
                      onTap: () =>
                          context.push('/customers/${customer.id}'),
                      onEdit: () =>
                          context.push('/customers/${customer.id}/edit'),
                      onDelete: () =>
                          _confirmDelete(context, customer, provider),
                      onCall: () {},
                      onMessage: () {},
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTableHeader() {
    final columns = [
      _ColumnDef(label: 'Customer', width: 220, sortKey: 0),
      _ColumnDef(label: 'Contact', width: 200, sortKey: 1),
      _ColumnDef(label: 'Phone', width: 140, sortKey: 2),
      _ColumnDef(label: 'GST', width: 130),
      _ColumnDef(label: 'City', width: 120, sortKey: 3),
      _ColumnDef(label: 'Status', width: 100),
      _ColumnDef(label: 'Created', width: 110, sortKey: 4),
      _ColumnDef(label: 'Actions', width: 140),
    ];

    return Container(
      decoration: BoxDecoration(
        color: _T.bg,
        border: Border(bottom: BorderSide(color: _T.border)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: columns.map((col) {
          if (col.sortKey != null) {
            return SizedBox(
              width: col.width,
              child: InkWell(
                onTap: () {
                  setState(() {
                    if (_sortColumn == col.sortKey) {
                      _sortAscending = !_sortAscending;
                    } else {
                      _sortColumn = col.sortKey!;
                      _sortAscending = true;
                    }
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        col.label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: _T.textTertiary,
                          letterSpacing: 0.8,
                        ),
                      ),
                      if (_sortColumn == col.sortKey) ...[
                        const SizedBox(width: 4),
                        Icon(
                          _sortAscending
                              ? Icons.arrow_upward_rounded
                              : Icons.arrow_downward_rounded,
                          size: 14,
                          color: _T.indigo500,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }
          return SizedBox(
            width: col.width,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                col.label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: _T.textTertiary,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFooter(BuildContext context, List<CustomerModel> customers) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '${customers.length} customer${customers.length != 1 ? 's' : ''}',
          style: TextStyle(fontSize: 13, color: _T.textTertiary),
        ),
        Row(
          children: [
            Text(
              'Sorted by ${_sortColumn >= 0 ? ['name', 'email', 'phone', 'city', 'created date'][_sortColumn] : 'relevance'}',
              style: TextStyle(fontSize: 12, color: _T.textTertiary),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMobileView(
    BuildContext context,
    List<CustomerModel> customers,
    CustomerProvider provider,
  ) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: _T.padding(context).left),
      itemCount: customers.length,
      itemBuilder: (context, index) {
        final customer = customers[index];
        return _CustomerMobileCard(
          customer: customer,
          index: index,
          onTap: () => context.push('/customers/${customer.id}'),
          onEdit: () => context.push('/customers/${customer.id}/edit'),
          onDelete: () => _confirmDelete(context, customer, provider),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, CustomerProvider provider) {
    final hasFilters = provider.searchQuery.isNotEmpty ||
        _statusFilter != null ||
        _cityFilter != null;

    return Center(
      child: Padding(
        padding: _T.padding(context),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: _T.indigo50,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                hasFilters
                    ? Icons.search_off_rounded
                    : Icons.people_outline_rounded,
                size: 36,
                color: _T.indigo500,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              hasFilters ? 'No Matching Customers' : 'No Customers Yet',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _T.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              hasFilters
                  ? 'Try adjusting your search or filters'
                  : 'Add your first customer to get started',
              style: TextStyle(fontSize: 14, color: _T.textTertiary),
            ),
            const SizedBox(height: 24),
            _GradientButton(
              label: hasFilters ? 'Clear Filters' : 'Add Customer',
              icon: hasFilters ? Icons.clear_all_rounded : Icons.add_rounded,
              onTap: () {
                if (hasFilters) {
                  setState(() {
                    _statusFilter = null;
                    _cityFilter = null;
                    _searchController.clear();
                  });
                  provider.clearSearch();
                } else {
                  context.push('/customers/create');
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return Expanded(
      child: Shimmer.fromColors(
        baseColor: const Color(0xFFE2E8F0),
        highlightColor: const Color(0xFFF8FAFC),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ListView.builder(
            itemCount: 8,
            padding: const EdgeInsets.only(top: 16),
            itemBuilder: (context, index) {
              return Container(
                height: 68,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    CustomerModel customer,
    CustomerProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _T.surface,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _T.rose50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.delete_outline_rounded,
                  color: _T.rose500, size: 20),
            ),
            const SizedBox(width: 12),
            const Text('Delete Customer',
                style: TextStyle(
                    fontWeight: FontWeight.w800, fontSize: 17)),
          ],
        ),
        content: Text(
          'Are you sure you want to permanently delete "${customer.name}"? This action cannot be undone.',
          style: const TextStyle(
              color: _T.textSecondary, fontSize: 14, height: 1.6),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: _T.textTertiary)),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: _T.dangerGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextButton(
              onPressed: () async {
                try {
                  await provider.deleteCustomer(customer.id);
                  if (ctx.mounted) Navigator.pop(ctx);
                  if (context.mounted) {
                    context.showSnackBar('Customer deleted successfully');
                  }
                } catch (e) {
                  if (ctx.mounted) Navigator.pop(ctx);
                  if (context.mounted) {
                    context.showSnackBar('Failed to delete: $e',
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
      ),
    );
  }
}

// ── Data Classes ────────────────────────────────────────────────────────

class _AnalyticsCardData {
  final String label;
  final String value;
  final IconData icon;
  final Gradient gradient;
  final String? trend;
  final IconData? trendIcon;

  const _AnalyticsCardData({
    required this.label,
    required this.value,
    required this.icon,
    required this.gradient,
    this.trend,
    this.trendIcon,
  });
}

class _ColumnDef {
  final String label;
  final double width;
  final int? sortKey;
  const _ColumnDef({required this.label, required this.width, this.sortKey});
}

// ── UI Components ───────────────────────────────────────────────────────

class _BreadcrumbItem extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback? onTap;

  const _BreadcrumbItem({
    required this.label,
    this.isActive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
          color: isActive ? _T.textPrimary : _T.textTertiary,
        ),
      ),
    );
  }
}

class _BreadcrumbSeparator extends StatelessWidget {
  const _BreadcrumbSeparator();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Icon(Icons.chevron_right_rounded,
          size: 14, color: _T.textDisabled),
    );
  }
}

class _HeaderActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _HeaderActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  State<_HeaderActionButton> createState() => _HeaderActionButtonState();
}

class _HeaderActionButtonState extends State<_HeaderActionButton> {
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
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: _hovered ? _T.indigo50 : _T.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _hovered ? _T.indigo100 : _T.border,
            ),
            boxShadow: _hovered
                ? [
                    BoxShadow(
                      color: _T.indigo500.withOpacity(0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon,
                  size: 16,
                  color: _hovered ? _T.indigo500 : _T.textTertiary),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _hovered ? _T.indigo600 : _T.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModernAnalyticsCard extends StatefulWidget {
  final _AnalyticsCardData data;
  final int index;

  const _ModernAnalyticsCard({required this.data, required this.index});

  @override
  State<_ModernAnalyticsCard> createState() => _ModernAnalyticsCardState();
}

class _ModernAnalyticsCardState extends State<_ModernAnalyticsCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final data = widget.data;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: _hovered
            ? Matrix4.translationValues(0, -2, 0)
            : Matrix4.identity(),
        decoration: BoxDecoration(
          color: _T.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _hovered
                ? data.gradient.colors.first.withOpacity(0.3)
                : _T.border,
          ),
          boxShadow: [
            if (_hovered)
              BoxShadow(
                color: data.gradient.colors.first.withOpacity(0.12),
                blurRadius: 16,
                offset: const Offset(0, 6),
              )
            else
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: data.gradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(data.icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 14),
              Flexible(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        data.value,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: _T.textPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        data.label,
                        style: TextStyle(
                          fontSize: 12,
                          color: _T.textTertiary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (data.trend != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: data.gradient.colors.first.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (data.trendIcon != null)
                        Icon(data.trendIcon,
                            size: 10,
                            color: data.gradient.colors.first),
                      if (data.trendIcon != null) const SizedBox(width: 3),
                      Text(
                        data.trend!,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: data.gradient.colors.first,
                        ),
                      ),
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

class _FilterButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _FilterButton({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_FilterButton> createState() => _FilterButtonState();
}

class _FilterButtonState extends State<_FilterButton> {
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
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: widget.isActive
                ? _T.indigo50
                : _hovered
                    ? _T.bg
                    : _T.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.isActive
                  ? _T.indigo100
                  : _hovered
                      ? _T.indigo100
                      : _T.border,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                size: 16,
                color: widget.isActive ? _T.indigo500 : _T.textTertiary,
              ),
              const SizedBox(width: 6),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: widget.isActive ? _T.indigo600 : _T.textSecondary,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.arrow_drop_down_rounded,
                size: 16,
                color: widget.isActive ? _T.indigo500 : _T.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CustomerTableRow extends StatefulWidget {
  final CustomerModel customer;
  final bool isEven;
  final int index;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onCall;
  final VoidCallback onMessage;

  const _CustomerTableRow({
    required this.customer,
    required this.isEven,
    required this.index,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.onCall,
    required this.onMessage,
  });

  @override
  State<_CustomerTableRow> createState() => _CustomerTableRowState();
}

class _CustomerTableRowState extends State<_CustomerTableRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final c = widget.customer;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        color: _hovered
            ? _T.indigo50.withOpacity(0.4)
            : widget.isEven
                ? Colors.white
                : _T.bg.withOpacity(0.5),
        child: InkWell(
          onTap: widget.onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: _T.borderLight),
              ),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 220,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        _CustomerAvatar(name: c.name, isActive: c.isActive),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                c.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                  color: _T.textPrimary,
                                ),
                              ),
                              if (c.email != null &&
                                  c.email!.isNotEmpty)
                                Text(
                                  c.email!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: _T.textTertiary,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: 200,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (c.email != null && c.email!.isNotEmpty)
                          Text(
                            c.email!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: _T.textSecondary,
                            ),
                          )
                        else
                          Text(
                            'No email',
                            style: TextStyle(
                              fontSize: 12,
                              color: _T.textDisabled,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: 140,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      c.phone ?? '—',
                      style: TextStyle(
                        fontSize: 12,
                        color: c.phone != null
                            ? _T.textSecondary
                            : _T.textDisabled,
                        fontWeight:
                            c.phone != null ? FontWeight.w500 : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 130,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildGstBadge(c.gstNumber),
                  ),
                ),
                SizedBox(
                  width: 120,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      c.city ?? '—',
                      style: TextStyle(
                        fontSize: 12,
                        color: c.city != null
                            ? _T.textSecondary
                            : _T.textDisabled,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 100,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _StatusChip(isActive: c.isActive),
                  ),
                ),
                SizedBox(
                  width: 110,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      DateFormat('dd MMM yyyy').format(c.createdAt),
                      style: const TextStyle(
                          fontSize: 11, color: _T.textTertiary),
                    ),
                  ),
                ),
                SizedBox(
                  width: 140,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        _TableActionBtn(
                          icon: Icons.visibility_outlined,
                          color: _T.indigo500,
                          tooltip: 'View',
                          onTap: widget.onTap,
                        ),
                        const SizedBox(width: 6),
                        _TableActionBtn(
                          icon: Icons.edit_outlined,
                          color: _T.amber500,
                          tooltip: 'Edit',
                          onTap: widget.onEdit,
                        ),
                        const SizedBox(width: 6),
                        _TableActionBtn(
                          icon: Icons.delete_outline_rounded,
                          color: _T.rose500,
                          tooltip: 'Delete',
                          onTap: widget.onDelete,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGstBadge(String? gst) {
    if (gst == null || gst.isEmpty) {
      return Text(
        '—',
        style: TextStyle(fontSize: 12, color: _T.textDisabled),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _T.indigo50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: _T.indigo100),
      ),
      child: Text(
        gst,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: _T.indigo600,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _CustomerMobileCard extends StatefulWidget {
  final CustomerModel customer;
  final int index;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CustomerMobileCard({
    required this.customer,
    required this.index,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<_CustomerMobileCard> createState() => _CustomerMobileCardState();
}

class _CustomerMobileCardState extends State<_CustomerMobileCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final c = widget.customer;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        transform: _hovered
            ? (Matrix4.identity()..translate(0, -1))
            : Matrix4.identity(),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: _T.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _hovered ? _T.indigo100 : _T.border,
          ),
          boxShadow: [
            if (_hovered)
              BoxShadow(
                color: _T.indigo500.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: widget.onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _CustomerAvatar(name: c.name, isActive: c.isActive),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            c.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: _T.textPrimary,
                            ),
                          ),
                          if (c.email != null && c.email!.isNotEmpty)
                            Text(
                              c.email!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 12, color: _T.textTertiary),
                            ),
                        ],
                      ),
                    ),
                    _StatusChip(isActive: c.isActive),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (c.phone != null)
                      _MobileInfoPill(
                          icon: Icons.phone_rounded, text: c.phone!),
                    if (c.city != null) ...[
                      const SizedBox(width: 8),
                      _MobileInfoPill(
                          icon: Icons.location_city_rounded,
                          text: c.city!),
                    ],
                    if (c.gstNumber != null) ...[
                      const SizedBox(width: 8),
                      _MobileInfoPill(
                          icon: Icons.badge_rounded, text: c.gstNumber!),
                    ],
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _MobileActionChip(
                      icon: Icons.edit_outlined,
                      label: 'Edit',
                      color: _T.amber500,
                      onTap: widget.onEdit,
                    ),
                    const SizedBox(width: 8),
                    _MobileActionChip(
                      icon: Icons.delete_outline_rounded,
                      label: 'Delete',
                      color: _T.rose500,
                      onTap: widget.onDelete,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CustomerAvatar extends StatelessWidget {
  final String name;
  final bool isActive;

  const _CustomerAvatar({required this.name, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: _T.primaryGradient,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
            ),
          ),
        ),
        if (!isActive)
          Positioned(
            right: -1,
            bottom: -1,
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: _T.surface,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.block_rounded,
                  size: 9, color: _T.rose500),
            ),
          ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  final bool isActive;

  const _StatusChip({required this.isActive});

  @override
  Widget build(BuildContext context) {
    final color = isActive ? _T.emerald500 : _T.textTertiary;
    final label = isActive ? 'Active' : 'Inactive';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _TableActionBtn extends StatefulWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  const _TableActionBtn({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  @override
  State<_TableActionBtn> createState() => _TableActionBtnState();
}

class _TableActionBtnState extends State<_TableActionBtn> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _hovered
                  ? widget.color.withOpacity(0.12)
                  : widget.color.withOpacity(0.06),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _hovered
                    ? widget.color.withOpacity(0.25)
                    : Colors.transparent,
              ),
            ),
            child: Icon(widget.icon, size: 15, color: widget.color),
          ),
        ),
      ),
    );
  }
}

class _MobileInfoPill extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MobileInfoPill({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _T.indigo50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _T.indigo100.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: _T.indigo500),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: _T.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _MobileActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _MobileActionChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.15)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
            Text(label,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: color)),
          ],
        ),
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _GradientButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: _T.primaryGradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: _T.indigo500.withOpacity(0.25),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
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
  }
}
