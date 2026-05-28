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

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  int _currentPage = 1;
  static const int _pageSize = 10;

  final List<Map<String, dynamic>> _sortOptions = [
    {
      'label': 'Name (A-Z)',
      'option': ProductSortOption.name,
      'ascending': true
    },
    {
      'label': 'Name (Z-A)',
      'option': ProductSortOption.name,
      'ascending': false
    },
    {
      'label': 'Price (Low to High)',
      'option': ProductSortOption.price,
      'ascending': true
    },
    {
      'label': 'Price (High to Low)',
      'option': ProductSortOption.price,
      'ascending': false
    },
    {
      'label': 'Stock (Low to High)',
      'option': ProductSortOption.stock,
      'ascending': true
    },
    {
      'label': 'Stock (High to Low)',
      'option': ProductSortOption.stock,
      'ascending': false
    },
    {
      'label': 'Newest first',
      'option': ProductSortOption.createdDate,
      'ascending': false
    },
    {
      'label': 'Oldest first',
      'option': ProductSortOption.createdDate,
      'ascending': true
    },
  ];

  late Map<String, dynamic> _selectedSort;

  final List<Map<String, dynamic>> _statusOptions = [
    {'label': 'In Stock', 'value': 'inStock'},
    {'label': 'Low Stock', 'value': 'lowStock'},
    {'label': 'Out Of Stock', 'value': 'outOfStock'},
  ];

  String? _selectedStatusValue;

  @override
  void initState() {
    super.initState();

    _selectedSort = _sortOptions.first;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().initializeProducts();
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
                await provider.initializeProducts();
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

                    _buildFilterContainer(
                      context,
                      provider,
                    ),

                    SizedBox(height: context.isMobile ? 18 : 24),

                    provider.isLoading
                        ? _buildShimmerLoading(context)
                        : productsList.isEmpty
                            ? _buildEmptyState(provider)
                            : _buildProductsLayout(
                                context,
                                productsList,
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
                          Icons.inventory_2_rounded,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Manage Products',
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
                    'View, update, and manage your inventory stock and pricing.',
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
                  onPressed: () => context.push('/products/create'),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Add Product'),
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
                          Icons.inventory_2_rounded,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Manage Products',
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
                    'View, update, and manage your inventory stock and pricing.',
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
                onPressed: () => context.push('/products/create'),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add Product'),
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

  Widget _buildTopAnalytics(ProductProvider provider) {
    final totalProducts = provider.products.length;

    final totalValue = provider.products.fold<double>(
      0,
      (prev, item) => prev + (item.price * item.stockQuantity),
    );

    final lowStock = provider.products
        .where((e) => e.stockStatus == StockStatus.lowStock)
        .length;

    final outOfStock = provider.products
        .where((e) => e.stockStatus == StockStatus.outOfStock)
        .length;

    final items = [
      {
        'title': 'Total Products',
        'value': '$totalProducts',
        'icon': Icons.widgets_rounded,
        'color': const Color(0xFF4F6EF7),
      },
      {
        'title': 'Inventory Value',
        'value': '₹${totalValue.toStringAsFixed(0)}',
        'icon': Icons.account_balance_wallet_rounded,
        'color': const Color(0xFF10B981),
      },
      {
        'title': 'Low Stock',
        'value': '$lowStock',
        'icon': Icons.warning_amber_rounded,
        'color': const Color(0xFFF59E0B),
      },
      {
        'title': 'Out Of Stock',
        'value': '$outOfStock',
        'icon': Icons.error_outline_rounded,
        'color': const Color(0xFFEF4444),
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
    ProductProvider provider,
  ) {
    return Container(
      padding: EdgeInsets.all(context.isMobile ? 16 : 20),
      decoration: _T.card(),
      child: SearchFilterBar(
        hintText: 'Search by Product-Name, HSN...',
        searchQuery: provider.searchQuery,
        onSearchChanged: (query) {
          setState(() => _currentPage = 1);
          provider.searchProducts(query);
        },
        statusOptions: _statusOptions,
        selectedStatus: _selectedStatusValue,
        onStatusChanged: (val) {
          setState(() {
            _selectedStatusValue = val;
            _currentPage = 1;
          });

          StockStatus? status;

          if (val == 'inStock') status = StockStatus.inStock;
          if (val == 'lowStock') status = StockStatus.lowStock;
          if (val == 'outOfStock') {
            status = StockStatus.outOfStock;
          }

          provider.filterByStockStatus(status);
        },
        sortOptions: _sortOptions,
        selectedSort: _selectedSort,
        onSortChanged: (sort) {
          setState(() {
            _selectedSort = sort;
            _currentPage = 1;
          });

          provider.setSortOption(
            sort['option'] as ProductSortOption,
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

  Widget _buildEmptyState(ProductProvider provider) {
    final hasFilters = provider.searchQuery.isNotEmpty ||
        provider.selectedStockStatus != null;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: _T.card(),
      child: EmptyStateWidget(
        icon: hasFilters
            ? Icons.search_off_rounded
            : Icons.inventory_2_outlined,
        title: hasFilters
            ? 'No Matching Products Found'
            : 'Inventory is Empty',
        message: hasFilters
            ? 'Try expanding your keywords or adjusting filters.'
            : 'Add your first product to begin tracking catalog assets.',
        actionLabel:
            hasFilters ? 'Reset Filters' : 'Create First Product',
        onAction: () {
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

  Widget _buildProductsLayout(
    BuildContext context,
    List<ProductModel> list,
    ProductProvider provider,
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
            ? _buildDesktopGridTable(
                context,
                pageList,
                provider,
              )
            : _buildMobileSlidableList(
                context,
                pageList,
                provider,
              ),

        if (totalPages > 1) ...[
          const SizedBox(height: 24),
          _buildPaginationControls(totalPages),
        ],
      ],
    );
  }

  Widget _buildDesktopGridTable(
    BuildContext context,
    List<ProductModel> list,
    ProductProvider provider,
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
                DataColumn(label: Text('Image')),
                DataColumn(label: Text('Product')),
                DataColumn(label: Text('HSN')),
                DataColumn(label: Text('Price')),
                DataColumn(label: Text('Stock')),
                DataColumn(label: Text('Status')),
                DataColumn(label: Text('Actions')),
              ],
              rows: list.map((product) {
                final hasImage =
                    product.imagePath != null &&
                        product.imagePath!.isNotEmpty;

                final imageProvider = hasImage
                    ? platformImageProvider(product.imagePath!)
                    : null;

                return DataRow(
                  cells: [
                    DataCell(
                      _buildProductImage(imageProvider),
                    ),
                      DataCell(
                        SizedBox(
                          width: 180,
                          child: InkWell(
                            onTap: () =>
                                context.push('/products/${product.id}'),
                            child: Text(
                              product.productName,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: _T.textDark,
                              ),
                            ),
                          ),
                        ),
                      ),
                      DataCell(Text(product.hsnCode ?? 'N/A')),
                    DataCell(
                      Text(
                        '₹${product.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        '${product.stockQuantity} ${product.unit}',
                      ),
                    ),
                    DataCell(
                      _buildStatusChip(product.stockStatus),
                    ),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _tableActionButton(
                            icon: Icons.visibility_outlined,
                            color: _T.gradientStart,
                            onTap: () => context.push(
                              '/products/${product.id}',
                            ),
                          ),
                          const SizedBox(width: 8),
                          _tableActionButton(
                            icon: Icons.edit_outlined,
                            color: _T.warning,
                            onTap: () => context.push(
                              '/products/${product.id}/edit',
                            ),
                          ),
                          const SizedBox(width: 8),
                          _tableActionButton(
                            icon: Icons.delete_outline_rounded,
                            color: _T.danger,
                            onTap: () => _confirmDeleteProduct(
                              context,
                              product,
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
    List<ProductModel> list,
    ProductProvider provider,
  ) {
    return SlidableAutoCloseBehavior(
      child: ListView.builder(
        itemCount: list.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          final product = list[index];

          final hasImage =
              product.imagePath != null &&
                  product.imagePath!.isNotEmpty;

          final imageProvider = hasImage
              ? platformImageProvider(product.imagePath!)
              : null;

          return _HoverProductCard(
            child: Slidable(
              key: ValueKey(product.id),
              endActionPane: ActionPane(
                motion: const DrawerMotion(),
                children: [
                  SlidableAction(
                    onPressed: (_) {
                      context.push('/products/${product.id}/edit');
                    },
                    backgroundColor: _T.warning,
                    foregroundColor: Colors.white,
                    icon: Icons.edit,
                    label: 'Edit',
                  ),
                  SlidableAction(
                    onPressed: (_) {
                      _confirmDeleteProduct(
                        context,
                        product,
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
                onTap: () => context.push('/products/${product.id}'),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(16),
                  decoration: _T.card(),
                  child: Row(
                    children: [
                      _buildProductImage(imageProvider),

                      const SizedBox(width: 14),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.productName,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize:
                                    context.isMobile ? 14 : 15,
                                fontWeight: FontWeight.w700,
                                color: _T.textDark,
                              ),
                            ),

                            const SizedBox(height: 10),

                            Wrap(
                              spacing: 10,
                              runSpacing: 8,
                              children: [
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
                        crossAxisAlignment:
                            CrossAxisAlignment.end,
                        children: [
                          _buildStatusChip(
                            product.stockStatus,
                          ),
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

  Widget _buildProductImage(ImageProvider? imageProvider) {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: imageProvider != null
            ? Image(
                image: imageProvider,
                fit: BoxFit.cover,
              )
            : const Icon(
                Icons.inventory_2_outlined,
                color: _T.gradientStart,
              ),
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

  Widget _buildStatusChip(StockStatus status) {
    late Color color;
    late String label;

    switch (status) {
      case StockStatus.inStock:
        color = _T.success;
        label = 'IN STOCK';
        break;

      case StockStatus.lowStock:
        color = _T.warning;
        label = 'LOW STOCK';
        break;

      case StockStatus.outOfStock:
        color = _T.danger;
        label = 'OUT';
        break;
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
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  void _confirmDeleteProduct(
    BuildContext context,
    ProductModel product,
    ProductProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Text(
            'Delete Product?',
            style: TextStyle(
              fontWeight: FontWeight.w800,
            ),
          ),
          content: Text(
            'Are you sure you want to permanently delete "${product.productName}"? This action cannot be undone.',
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
                    await provider.deleteProduct(product.id);

                    if (context.mounted) {
                      Navigator.pop(context);

                      context.showSnackBar(
                        'Product deleted successfully',
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      Navigator.pop(context);

                      context.showSnackBar(
                        'Failed to delete product: $e',
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

class _HoverProductCard extends StatefulWidget {
  final Widget child;

  const _HoverProductCard({
    required this.child,
  });

  @override
  State<_HoverProductCard> createState() =>
      _HoverProductCardState();
}

class _HoverProductCardState
    extends State<_HoverProductCard> {
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
