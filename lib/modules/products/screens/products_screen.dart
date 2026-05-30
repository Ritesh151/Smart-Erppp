import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import 'package:SmartERP/core/constants/app_constants.dart';
import 'package:SmartERP/core/extensions/context_extensions.dart';
import 'package:SmartERP/core/models/product_model.dart';
import 'package:SmartERP/core/theme/theme_extensions.dart';
import 'package:SmartERP/core/utils/platform_image_provider.dart';
import 'package:SmartERP/core/widgets/empty_state_widget.dart';
import 'package:SmartERP/core/widgets/search_filter_bar.dart';
import 'package:SmartERP/modules/products/providers/product_provider.dart';
import 'package:SmartERP/modules/products/services/product_service.dart';

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

  static BoxDecoration card({double radius = 16, bool hover = false}) =>
      BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: hover
              ? gradientStart.withOpacity(0.18)
              : divider,
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

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  int _currentPage = 1;
  static const int _pageSize = 10;

  final List<Map<String, dynamic>> _sortOptions = [
    {'label': 'Name (A-Z)',           'option': ProductSortOption.name,        'ascending': true},
    {'label': 'Name (Z-A)',           'option': ProductSortOption.name,        'ascending': false},
    {'label': 'Price (Low to High)',  'option': ProductSortOption.price,       'ascending': true},
    {'label': 'Price (High to Low)',  'option': ProductSortOption.price,       'ascending': false},
    {'label': 'Stock (Low to High)',  'option': ProductSortOption.stock,       'ascending': true},
    {'label': 'Stock (High to Low)',  'option': ProductSortOption.stock,       'ascending': false},
    {'label': 'Newest first',         'option': ProductSortOption.createdDate, 'ascending': false},
    {'label': 'Oldest first',         'option': ProductSortOption.createdDate, 'ascending': true},
  ];

  late Map<String, dynamic> _selectedSort;

  final List<Map<String, dynamic>> _statusOptions = [
    {'label': 'In Stock',     'value': 'inStock'},
    {'label': 'Low Stock',    'value': 'lowStock'},
    {'label': 'Out Of Stock', 'value': 'outOfStock'},
  ];

  String? _selectedStatusValue;

  @override
  void initState() {
    super.initState();
    _selectedSort = _sortOptions.first;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final padding = context.isMobile ? 16.0 : 24.0;

    return Consumer<ProductProvider>(
      builder: (context, provider, _) {
        final productsList = provider.products;

        return Container(
          color: _T.bg,
          child: SafeArea(
            child: RefreshIndicator(
              color: _T.gradientStart,
              onRefresh: () async {
                await provider.loadProducts();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(padding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context)
                        .animate()
                        .fadeIn(duration: 400.ms)
                        .slideX(begin: -0.04, end: 0),

                    SizedBox(height: context.isMobile ? 18 : 24),

                    _buildTopAnalytics(context, provider)
                        .animate()
                        .fadeIn(delay: 80.ms, duration: 350.ms)
                        .slideY(begin: 0.08, end: 0),

                    SizedBox(height: context.isMobile ? 18 : 24),

                    _buildFilterContainer(context, provider)
                        .animate()
                        .fadeIn(delay: 140.ms, duration: 300.ms),

                    SizedBox(height: context.isMobile ? 18 : 24),

                    provider.isLoading
                        ? _buildShimmerLoading(context)
                        : productsList.isEmpty
                            ? _buildEmptyState(provider)
                                .animate()
                                .fadeIn(duration: 300.ms)
                            : _buildProductsLayout(
                                context, productsList, provider),

                    SizedBox(height: context.isMobile ? 16 : 24),
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
    final titleWidget = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: _T.brandGradient,
            borderRadius: BorderRadius.circular(11),
            boxShadow: [
              BoxShadow(
                color: _T.gradientStart.withOpacity(0.28),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.inventory_2_rounded, color: _T.white, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          'Manage Products',
          style: TextStyle(
            fontSize: context.isMobile ? 22 : 28,
            fontWeight: FontWeight.w800,
            color: _T.textDark,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );

    final subtitleWidget = Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Text(
        'View, update, and manage your inventory stock and pricing.',
        style: TextStyle(
          fontSize: context.isMobile ? 12 : 13,
          color: _T.textMuted,
          height: 1.5,
        ),
      ),
    );

    final addButton = Container(
      decoration: BoxDecoration(
        gradient: _T.brandGradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: _T.gradientStart.withOpacity(0.28),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: () => context.push('/products/create'),
        icon: const Icon(Icons.add_rounded, size: 18),
        label: const Text('Add Product', style: TextStyle(fontWeight: FontWeight.w700)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: _T.white,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.symmetric(
            horizontal: context.isMobile ? 16 : 20,
            vertical: 14,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );

    if (context.isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          titleWidget,
          subtitleWidget,
          const SizedBox(height: 14),
          addButton,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [titleWidget, subtitleWidget],
          ),
        ),
        const SizedBox(width: 16),
        addButton,
      ],
    );
  }

  // ── Analytics row ─────────────────────────────────────────────────────────
  Widget _buildTopAnalytics(BuildContext context, ProductProvider provider) {
    final totalProducts = provider.products.length;
    final totalValue = provider.products.fold<double>(
      0, (prev, item) => prev + (item.price * item.stockQuantity));
    final lowStock = provider.products
        .where((e) => e.stockStatus == StockStatus.lowStock).length;
    final outOfStock = provider.products
        .where((e) => e.stockStatus == StockStatus.outOfStock).length;

    String _fmt(double v) {
      if (v >= 10000000) return '₹${(v / 10000000).toStringAsFixed(1)}Cr';
      if (v >= 100000)   return '₹${(v / 100000).toStringAsFixed(1)}L';
      if (v >= 1000)     return '₹${(v / 1000).toStringAsFixed(1)}K';
      return '₹${v.toStringAsFixed(0)}';
    }

    final metrics = [
      {
        'title'   : 'Total Products',
        'value'   : '$totalProducts',
        'icon'    : Icons.widgets_rounded,
        'gradient': const LinearGradient(
          colors: [Color(0xFF4F6EF7), Color(0xFF7C3AED)],
          begin: Alignment.topLeft, end: Alignment.bottomRight),
        'bg'      : const Color(0xFFEEF2FF),
        'subtitle': 'Active SKUs',
      },
      {
        'title'   : 'Inventory Value',
        'value'   : _fmt(totalValue),
        'icon'    : Icons.account_balance_wallet_rounded,
        'gradient': const LinearGradient(
          colors: [Color(0xFF10B981), Color(0xFF059669)],
          begin: Alignment.topLeft, end: Alignment.bottomRight),
        'bg'      : const Color(0xFFECFDF5),
        'subtitle': 'Stock × price',
      },
      {
        'title'   : 'Low Stock',
        'value'   : '$lowStock',
        'icon'    : Icons.warning_amber_rounded,
        'gradient': const LinearGradient(
          colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
          begin: Alignment.topLeft, end: Alignment.bottomRight),
        'bg'      : const Color(0xFFFFFBEB),
        'subtitle': 'Needs restocking',
      },
      {
        'title'   : 'Out Of Stock',
        'value'   : '$outOfStock',
        'icon'    : Icons.error_outline_rounded,
        'gradient': const LinearGradient(
          colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
          begin: Alignment.topLeft, end: Alignment.bottomRight),
        'bg'      : const Color(0xFFFEF2F2),
        'subtitle': 'Unavailable items',
      },
    ];

    final crossAxisCount = context.isMobile ? 2 : 4;
    final spacing        = context.isMobile ? 12.0 : 16.0;

    return LayoutBuilder(builder: (context, constraints) {
      final ratio = context.isMobile
          ? 1.3
          : (context.isTablet ? 1.35 : 2.1);

      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: metrics.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: spacing,
          mainAxisSpacing: spacing,
          childAspectRatio: ratio,
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
          ).animate().fadeIn(delay: (index * 70).ms, duration: 280.ms)
           .slideY(begin: 0.1, end: 0);
        },
      );
    });
  }

  Widget _buildMetricCard({
    required BuildContext context,
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required LinearGradient gradient,
    required Color bgColor,
  }) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        context.isMobile ? 10 : 12,
        context.isMobile ? 8 : 10,
        context.isMobile ? 10 : 12,
        context.isMobile ? 6 : 8,
      ),
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
                width : context.isMobile ? 32 : 36,
                height: context.isMobile ? 32 : 36,
                decoration: BoxDecoration(
                  gradient     : gradient,
                  borderRadius : BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: gradient.colors.first.withOpacity(0.28),
                      blurRadius: 7,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(icon, color: _T.white, size: context.isMobile ? 15 : 17),
              ),
              Icon(Icons.arrow_outward_rounded, size: 12, color: _T.textLight),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize    : context.isMobile ? 16 : 19,
              fontWeight  : FontWeight.w800,
              color       : _T.textDark,
              letterSpacing: -0.5,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 0),
          Text(
            title,
            style: TextStyle(
              fontSize  : context.isMobile ? 10 : 11,
              fontWeight: FontWeight.w600,
              color     : _T.textMuted,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 0),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 9, color: _T.textLight),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ── Filter container ──────────────────────────────────────────────────────
  Widget _buildFilterContainer(BuildContext context, ProductProvider provider) {
    return Container(
      padding: EdgeInsets.all(context.isMobile ? 14 : 18),
      decoration: _T.card(),
      child: SearchFilterBar(
        hintText     : 'Search by Product-Name, HSN...',
        searchQuery  : provider.searchQuery,
        onSearchChanged: (query) {
          setState(() => _currentPage = 1);
          provider.searchProducts(query);
        },
        statusOptions   : _statusOptions,
        selectedStatus  : _selectedStatusValue,
        onStatusChanged : (val) {
          setState(() {
            _selectedStatusValue = val;
            _currentPage = 1;
          });
          StockStatus? status;
          if (val == 'inStock')    status = StockStatus.inStock;
          if (val == 'lowStock')   status = StockStatus.lowStock;
          if (val == 'outOfStock') status = StockStatus.outOfStock;
          provider.filterByStockStatus(status);
        },
        sortOptions    : _sortOptions,
        selectedSort   : _selectedSort,
        onSortChanged  : (sort) {
          setState(() {
            _selectedSort = sort;
            _currentPage = 1;
          });
          provider.setSortOption(
            sort['option']    as ProductSortOption,
            sort['ascending'] as bool,
          );
        },
        onClearAll: () {
          setState(() {
            _selectedStatusValue = null;
            _selectedSort = _sortOptions.first;
            _currentPage = 1;
          });
          provider.clearFilters();
        },
      ),
    );
  }

  // ── Empty state ───────────────────────────────────────────────────────────
  Widget _buildEmptyState(ProductProvider provider) {
    final hasFilters = provider.searchQuery.isNotEmpty ||
        provider.selectedStockStatus != null;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: _T.card(),
      child: EmptyStateWidget(
        icon       : hasFilters ? Icons.search_off_rounded : Icons.inventory_2_outlined,
        title      : hasFilters ? 'No Matching Products Found' : 'Inventory is Empty',
        message    : hasFilters
            ? 'Try expanding your keywords or adjusting filters.'
            : 'Add your first product to begin tracking catalog assets.',
        actionLabel: hasFilters ? 'Reset Filters' : 'Create First Product',
        onAction   : () {
          if (hasFilters) {
            setState(() {
              _selectedStatusValue = null;
              _selectedSort = _sortOptions.first;
              _currentPage = 1;
            });
            provider.clearFilters();
          } else {
            context.go('/products/create');
          }
        },
      ),
    );
  }

  // ── Shimmer ───────────────────────────────────────────────────────────────
  Widget _buildShimmerLoading(BuildContext context) {
    return Shimmer.fromColors(
      baseColor     : const Color(0xFFEAECF0),
      highlightColor: const Color(0xFFF8F9FA),
      child: Column(
        children: List.generate(
          5,
          (i) => Container(
            height: context.isMobile ? 80 : 68,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: const BoxDecoration(
              color: _T.white,
              borderRadius: BorderRadius.all(Radius.circular(14)),
            ),
          ),
        ),
      ),
    );
  }

  // ── Products layout ───────────────────────────────────────────────────────
  Widget _buildProductsLayout(
    BuildContext context,
    List<ProductModel> list,
    ProductProvider provider,
  ) {
    final totalItems = list.length;
    final totalPages = (totalItems / _pageSize).ceil();
    final startIdx   = (_currentPage - 1) * _pageSize;
    final endIdx     = (startIdx + _pageSize).clamp(0, totalItems);
    final pageList   = list.sublist(startIdx, endIdx);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Results info bar
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 28, height: 28,
                    decoration: const BoxDecoration(
                      gradient: _T.brandGradient,
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                    child: const Icon(Icons.list_alt_rounded, color: _T.white, size: 14),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$totalItems product${totalItems != 1 ? 's' : ''}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _T.textDark,
                    ),
                  ),
                ],
              ),
              if (totalPages > 1)
                Text(
                  'Page $_currentPage of $totalPages',
                  style: const TextStyle(fontSize: 11, color: _T.textMuted),
                ),
            ],
          ),
        ),

        context.isDesktop
            ? _buildDesktopTable(context, pageList, provider)
            : _buildMobileSlidableList(context, pageList, provider),

        if (totalPages > 1) ...[
          const SizedBox(height: 20),
          _buildPaginationControls(totalPages),
        ],
      ],
    );
  }

  // ── Desktop data table ────────────────────────────────────────────────────
  Widget _buildDesktopTable(
    BuildContext context,
    List<ProductModel> list,
    ProductProvider provider,
  ) {
    const headerStyle = TextStyle(
      fontSize  : 11,
      fontWeight: FontWeight.w700,
      color     : _T.textMuted,
      letterSpacing: 0.4,
    );

    return Container(
      decoration: _T.card(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: _T.divider),
            child: DataTable(
              horizontalMargin : 20,
              columnSpacing    : 24,
              headingRowHeight : 50,
              dataRowMinHeight : 68,
              dataRowMaxHeight : 76,
              headingRowColor  : MaterialStateProperty.all(
                const Color(0xFFF8FAFC)),
              headingTextStyle : headerStyle,
              dividerThickness : 1,
              columns: const [
                DataColumn(label: Text('IMAGE')),
                DataColumn(label: Text('PRODUCT')),
                DataColumn(label: Text('HSN')),
                DataColumn(label: Text('PRICE')),
                DataColumn(label: Text('STOCK')),
                DataColumn(label: Text('STATUS')),
                DataColumn(label: Text('ACTIONS')),
              ],
              rows: list.asMap().entries.map((entry) {
                final index   = entry.key;
                final product = entry.value;
                final hasImage = product.imagePath != null &&
                    product.imagePath!.isNotEmpty;
                final imageProvider =
                    hasImage ? platformImageProvider(product.imagePath!) : null;

                return DataRow(
                  color: MaterialStateProperty.resolveWith<Color?>((states) {
                    if (states.contains(MaterialState.hovered)) {
                      return _T.gradientStart.withOpacity(0.03);
                    }
                    return index.isEven ? null : const Color(0xFFFAFAFB);
                  }),
                  cells: [
                    DataCell(_buildProductImage(imageProvider)),
                    DataCell(
                      SizedBox(
                        width: 190,
                        child: InkWell(
                          onTap: () => context.push('/products/${product.id}'),
                          borderRadius: BorderRadius.circular(6),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  product.productName,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                    color: _T.textDark,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        product.hsnCode ?? 'N/A',
                        style: const TextStyle(
                          fontSize: 12, color: _T.textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        '₹${product.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: _T.textDark,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        '${product.stockQuantity} ${product.unit}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: _T.textMid,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    DataCell(_buildStatusChip(product.stockStatus)),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _actionBtn(
                            icon : Icons.visibility_outlined,
                            color: _T.gradientStart,
                            onTap: () => context.push('/products/${product.id}'),
                          ),
                          const SizedBox(width: 6),
                          _actionBtn(
                            icon : Icons.edit_outlined,
                            color: _T.warning,
                            onTap: () =>
                                context.push('/products/${product.id}/edit'),
                          ),
                          const SizedBox(width: 6),
                          _actionBtn(
                            icon : Icons.delete_outline_rounded,
                            color: _T.danger,
                            onTap: () => _confirmDeleteProduct(
                                context, product, provider),
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

  Widget _actionBtn({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(9),
      onTap: onTap,
      child: Container(
        width : 32,
        height: 32,
        decoration: BoxDecoration(
          color       : color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(9),
        ),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }

  // ── Mobile slidable list ──────────────────────────────────────────────────
  Widget _buildMobileSlidableList(
    BuildContext context,
    List<ProductModel> list,
    ProductProvider provider,
  ) {
    return SlidableAutoCloseBehavior(
      child: ListView.builder(
        itemCount : list.length,
        shrinkWrap: true,
        physics   : const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          final product = list[index];
          final hasImage = product.imagePath != null &&
              product.imagePath!.isNotEmpty;
          final imageProvider =
              hasImage ? platformImageProvider(product.imagePath!) : null;

          return _HoverProductCard(
            child: Slidable(
              key: ValueKey(product.id),
              endActionPane: ActionPane(
                motion: const DrawerMotion(),
                children: [
                  SlidableAction(
                    onPressed: (_) =>
                        context.push('/products/${product.id}/edit'),
                    backgroundColor: _T.warning,
                    foregroundColor: _T.white,
                    icon           : Icons.edit,
                    label          : 'Edit',
                    borderRadius   : const BorderRadius.only(
                      topLeft    : Radius.circular(12),
                      bottomLeft : Radius.circular(12),
                    ),
                  ),
                  SlidableAction(
                    onPressed: (_) =>
                        _confirmDeleteProduct(context, product, provider),
                    backgroundColor: _T.danger,
                    foregroundColor: _T.white,
                    icon           : Icons.delete,
                    label          : 'Delete',
                    borderRadius   : const BorderRadius.only(
                      topRight   : Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                  ),
                ],
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => context.push('/products/${product.id}'),
                child: Container(
                  margin   : const EdgeInsets.only(bottom: 10),
                  padding  : EdgeInsets.all(context.isMobile ? 12 : 14),
                  decoration: _T.card(radius: 14),
                  child: Row(
                    children: [
                      _buildProductImage(imageProvider),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              product.productName,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize  : context.isMobile ? 13 : 14,
                                fontWeight: FontWeight.w700,
                                color     : _T.textDark,
                                height    : 1.3,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing   : 8,
                              runSpacing: 6,
                              children  : [
                                _infoPill(
                                  Icons.currency_rupee_rounded,
                                  '₹${product.price.toStringAsFixed(2)}',
                                ),
                                _infoPill(
                                  Icons.inventory_2_outlined,
                                  '${product.stockQuantity} ${product.unit}',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildStatusChip(product.stockStatus),
                          const SizedBox(height: 8),
                          const Icon(Icons.chevron_right_rounded,
                              size: 18, color: _T.textLight),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
              .animate()
              .fadeIn(delay: (index * 35).ms, duration: 220.ms)
              .slideY(begin: 0.06, end: 0);
        },
      ),
    );
  }

  // ── Product image ─────────────────────────────────────────────────────────
  Widget _buildProductImage(ImageProvider? imageProvider) {
    return Container(
      width : 52,
      height: 52,
      decoration: BoxDecoration(
        color       : const Color(0xFFF3F4F6),
        borderRadius: const BorderRadius.all(Radius.circular(13)),
        border      : Border.all(color: _T.divider),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(13)),
        child: imageProvider != null
            ? Image(image: imageProvider, fit: BoxFit.cover)
            : const Icon(Icons.inventory_2_outlined,
                color: _T.gradientStart, size: 22),
      ),
    );
  }

  // ── Info pill ─────────────────────────────────────────────────────────────
  Widget _infoPill(IconData icon, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color       : _T.gradientStart.withOpacity(0.06),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: _T.gradientStart),
          const SizedBox(width: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize  : 11,
              color     : _T.textDark,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ── Status chip ───────────────────────────────────────────────────────────
  Widget _buildStatusChip(StockStatus status) {
    late Color  color;
    late String label;
    late IconData icon;

    switch (status) {
      case StockStatus.inStock:
        color = _T.success;
        label = 'In Stock';
        icon  = Icons.check_circle_rounded;
        break;
      case StockStatus.lowStock:
        color = _T.warning;
        label = 'Low Stock';
        icon  = Icons.warning_rounded;
        break;
      case StockStatus.outOfStock:
        color = _T.danger;
        label = 'Out';
        icon  = Icons.cancel_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color       : color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border      : Border.all(color: color.withOpacity(0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color      : color,
              fontSize   : 10,
              fontWeight : FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  // ── Pagination ─────────────────────────────────────────────────────────────
  Widget _buildPaginationControls(int totalPages) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _paginationButton(
          icon   : Icons.chevron_left_rounded,
          enabled: _currentPage > 1,
          onTap  : () => setState(() => _currentPage--),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: _T.card(radius: 12),
          child: Text(
            'Page $_currentPage of $totalPages',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize  : 13,
              color     : _T.textDark,
            ),
          ),
        ),
        const SizedBox(width: 12),
        _paginationButton(
          icon   : Icons.chevron_right_rounded,
          enabled: _currentPage < totalPages,
          onTap  : () => setState(() => _currentPage++),
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
        duration: const Duration(milliseconds: 160),
        width : 42,
        height: 42,
        decoration: BoxDecoration(
          gradient    : enabled ? _T.brandGradient : null,
          color       : enabled ? null : const Color(0xFFE5E7EB),
          borderRadius: BorderRadius.circular(12),
          boxShadow   : enabled
              ? [
                  BoxShadow(
                    color     : _T.gradientStart.withOpacity(0.25),
                    blurRadius: 8,
                    offset    : const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Icon(icon,
            color: enabled ? _T.white : _T.textLight,
            size: 20),
      ),
    );
  }

  // ── Delete confirmation dialog ─────────────────────────────────────────────
  void _confirmDeleteProduct(
    BuildContext context,
    ProductModel product,
    ProductProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 0,
        backgroundColor: _T.white,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                width : 56,
                height: 56,
                decoration: BoxDecoration(
                  color       : _T.danger.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.delete_outline_rounded,
                    color: _T.danger, size: 28),
              ),
              const SizedBox(height: 16),
              const Text(
                'Delete Product?',
                style: TextStyle(
                  fontSize  : 17,
                  fontWeight: FontWeight.w800,
                  color     : _T.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Are you sure you want to permanently delete "${product.productName}"? This action cannot be undone.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color   : _T.textMuted,
                  height  : 1.5,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed : () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        side  : const BorderSide(color: _T.divider),
                        shape : RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color     : _T.textMid,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color       : _T.danger,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color     : _T.danger.withOpacity(0.28),
                            blurRadius: 10,
                            offset    : const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextButton(
                        onPressed: () async {
                          try {
                            await provider.deleteProduct(product.id);
                            if (context.mounted) {
                              Navigator.pop(ctx);
                              context.showSnackBar('Product deleted successfully');
                            }
                          } catch (e) {
                            if (context.mounted) {
                              Navigator.pop(ctx);
                              context.showSnackBar(
                                  'Failed to delete product: $e',
                                  isError: true);
                            }
                          }
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text(
                          'Delete',
                          style: TextStyle(
                            color     : _T.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Hover lift card ──────────────────────────────────────────────────────────
class _HoverProductCard extends StatefulWidget {
  final Widget child;
  const _HoverProductCard({required this.child});

  @override
  State<_HoverProductCard> createState() => _HoverProductCardState();
}

class _HoverProductCardState extends State<_HoverProductCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit : (_) => setState(() => _hovered = false),
      child  : AnimatedContainer(
        duration : const Duration(milliseconds: 160),
        transform: Matrix4.identity()
          ..translate(0.0, _hovered ? -2.0 : 0.0),
        child: widget.child,
      ),
    );
  }
}
