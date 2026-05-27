import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smarterp/core/constants/app_constants.dart';
import 'package:smarterp/core/extensions/context_extensions.dart';
import 'package:smarterp/core/theme/theme_extensions.dart';
import 'package:smarterp/core/widgets/app_shell.dart';
import 'package:smarterp/core/widgets/app_card.dart';
import 'package:smarterp/core/widgets/empty_state_widget.dart';
import 'package:smarterp/core/widgets/search_filter_bar.dart';
import 'package:smarterp/core/models/product_model.dart';
import 'package:smarterp/modules/products/providers/product_provider.dart';
import 'package:smarterp/modules/products/services/product_service.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  int _currentPage = 1;
  static const int _pageSize = 10; 

  // Sort states
  final List<Map<String, dynamic>> _sortOptions = [
    {'label': 'Name (A-Z)', 'option': ProductSortOption.name, 'ascending': true},
    {'label': 'Name (Z-A)', 'option': ProductSortOption.name, 'ascending': false},
    {'label': 'Price (Low to High)', 'option': ProductSortOption.price, 'ascending': true},
    {'label': 'Price (High to Low)', 'option': ProductSortOption.price, 'ascending': false},
    {'label': 'Stock (Low to High)', 'option': ProductSortOption.stock, 'ascending': true},
    {'label': 'Stock (High to Low)', 'option': ProductSortOption.stock, 'ascending': false},
    {'label': 'Newest first', 'option': ProductSortOption.createdDate, 'ascending': false},
    {'label': 'Oldest first', 'option': ProductSortOption.createdDate, 'ascending': true},
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
    _selectedSort = _sortOptions[0];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().initializeProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final theme = context.theme;

    return AppShell(
      title: 'Product Inventory',
      child: Consumer<ProductProvider>(
        builder: (context, provider, _) {
          final productsList = provider.products;
          final categories = provider.products.map((p) => p.category).toSet().toList()..sort();

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: 20),
                _buildFilterBar(context, provider, categories),
                const SizedBox(height: 20),
                Expanded(
                  child: provider.isLoading
                      ? _buildShimmerLoading()
                      : productsList.isEmpty
                          ? _buildEmptyState(provider)
                          : _buildProductsLayout(context, productsList, provider),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final colorScheme = context.colorScheme;
    final theme = context.theme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Manage Products',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'View, update, and manage your inventory stock and pricing.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: () => context.go('/products/create'),
          icon: const Icon(Icons.add),
          label: const Text('Add Product'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterBar(
    BuildContext context,
    ProductProvider provider,
    List<String> categories,
  ) {
    StockStatus? mappedStatus;
    if (_selectedStatusValue == 'inStock') mappedStatus = StockStatus.inStock;
    if (_selectedStatusValue == 'lowStock') mappedStatus = StockStatus.lowStock;
    if (_selectedStatusValue == 'outOfStock') mappedStatus = StockStatus.outOfStock;

    return SearchFilterBar(
      hintText: 'Search by product name, HSN, SKU, category...',
      searchQuery: provider.searchQuery,
      onSearchChanged: (query) {
        setState(() => _currentPage = 1);
        provider.searchProducts(query);
      },
      categories: categories,
      selectedCategory: provider.selectedCategory,
      onCategoryChanged: (cat) {
        setState(() => _currentPage = 1);
        provider.filterByCategory(cat);
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
        if (val == 'outOfStock') status = StockStatus.outOfStock;
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
          _selectedSort = _sortOptions[0];
          _currentPage = 1;
        });
        provider.clearFilters();
      },
    );
  }

  Widget _buildEmptyState(ProductProvider provider) {
    final hasFilters = provider.searchQuery.isNotEmpty ||
        provider.selectedCategory != null ||
        provider.selectedStockStatus != null;

    if (hasFilters) {
      return EmptyStateWidget(
        icon: Icons.search_off,
        title: 'No Matching Products Found',
        message: 'Try expanding your keywords or adjusting filters.',
        actionLabel: 'Reset Filters',
        onAction: () {
          setState(() {
            _selectedStatusValue = null;
            _selectedSort = _sortOptions[0];
            _currentPage = 1;
          });
          provider.clearFilters();
        },
      );
    }

    return EmptyStateWidget(
      icon: Icons.inventory_2_outlined,
      title: 'Inventory is Empty',
      message: 'Add your first product to begin tracking catalog assets.',
      actionLabel: 'Create First Product',
      onAction: () => context.go('/products/create'),
    );
  }

  Widget _buildShimmerLoading() {
    final colorScheme = context.colorScheme;
    return Shimmer.fromColors(
      baseColor: colorScheme.surfaceVariant.withOpacity(0.4),
      highlightColor: colorScheme.surfaceVariant.withOpacity(0.1),
      child: ListView.builder(
        itemCount: 6,
        itemBuilder: (context, index) => Container(
          height: 80,
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
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
    // Paginate in memory
    final totalItems = list.length;
    final totalPages = (totalItems / _pageSize).ceil();
    final startIdx = (_currentPage - 1) * _pageSize;
    final endIdx = startIdx + _pageSize > totalItems ? totalItems : startIdx + _pageSize;
    final pageList = list.sublist(startIdx, endIdx);

    final appTheme = context.appTheme;

    return Column(
      children: [
        Expanded(
          child: context.isDesktop
              ? _buildDesktopGridTable(context, pageList, provider, appTheme)
              : _buildMobileSlidableList(context, pageList, provider, appTheme),
        ),
        if (totalPages > 1) ...[
          const SizedBox(height: 16),
          _buildPaginationControls(totalPages),
        ],
      ],
    );
  }

  Widget _buildDesktopGridTable(
    BuildContext context,
    List<ProductModel> list,
    ProductProvider provider,
    AppThemeExtension appTheme,
  ) {
    final colorScheme = context.colorScheme;
    final theme = context.theme;

    return AppCard(
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(
            child: DataTable(
              headingRowColor: MaterialStateProperty.all(colorScheme.surfaceVariant.withOpacity(0.2)),
              columns: const [
                DataColumn(label: Text('Image')),
                DataColumn(label: Text('Product Name')),
                DataColumn(label: Text('Category')),
                DataColumn(label: Text('HSN')),
                DataColumn(label: Text('Price (Ex. GST)')),
                DataColumn(label: Text('Price (Inc. GST)')),
                DataColumn(label: Text('Stock')),
                DataColumn(label: Text('Status')),
                DataColumn(label: Text('Actions', textAlign: TextAlign.center)),
              ],
              rows: list.map((product) {
                final hasImage = product.imagePath != null && product.imagePath!.isNotEmpty;
                return DataRow(
                  cells: [
                    DataCell(
                      Container(
                        height: 36,
                        width: 36,
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
                          child: hasImage && File(product.imagePath!).existsSync()
                              ? Image.file(File(product.imagePath!), fit: BoxFit.cover)
                              : Icon(Icons.image_outlined, size: 18, color: colorScheme.primary.withOpacity(0.6)),
                        ),
                      ),
                    ),
                    DataCell(
                      InkWell(
                        onTap: () => context.go('/products/${product.id}'),
                        child: Text(
                          product.productName,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    DataCell(Text(product.category)),
                    DataCell(Text(product.hsnCode ?? 'N/A')),
                    DataCell(Text('₹${product.price.toStringAsFixed(2)}')),
                    DataCell(Text('₹${product.priceWithGst.toStringAsFixed(2)}')),
                    DataCell(Text('${product.stockQuantity} ${product.unit}')),
                    DataCell(_buildStatusChip(product.stockStatus, appTheme)),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.visibility_outlined, size: 18),
                            tooltip: 'View details',
                            onPressed: () => context.go('/products/${product.id}'),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 18),
                            tooltip: 'Edit product',
                            onPressed: () => context.go('/products/${product.id}/edit'),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 18),
                            color: colorScheme.error,
                            tooltip: 'Delete product',
                            onPressed: () => _confirmDeleteProduct(context, product, provider),
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

  Widget _buildMobileSlidableList(
    BuildContext context,
    List<ProductModel> list,
    ProductProvider provider,
    AppThemeExtension appTheme,
  ) {
    final colorScheme = context.colorScheme;

    return SlidableAutoCloseBehavior(
      child: ListView.builder(
        itemCount: list.length,
        itemBuilder: (context, index) {
          final product = list[index];
          final hasImage = product.imagePath != null && product.imagePath!.isNotEmpty;

          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
              side: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.5)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
              child: Slidable(
                key: ValueKey(product.id),
                endActionPane: ActionPane(
                  motion: const DrawerMotion(),
                  children: [
                    SlidableAction(
                      onPressed: (context) => context.go('/products/${product.id}/edit'),
                      backgroundColor: Colors.blue.shade600,
                      foregroundColor: Colors.white,
                      icon: Icons.edit,
                      label: 'Edit',
                    ),
                    SlidableAction(
                      onPressed: (context) => _confirmDeleteProduct(context, product, provider),
                      backgroundColor: colorScheme.error,
                      foregroundColor: Colors.white,
                      icon: Icons.delete,
                      label: 'Delete',
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: Container(
                    height: 48,
                    width: 48,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
                      child: hasImage && File(product.imagePath!).existsSync()
                          ? Image.file(File(product.imagePath!), fit: BoxFit.cover)
                          : Icon(Icons.image_outlined, color: colorScheme.primary.withOpacity(0.6)),
                    ),
                  ),
                  title: Text(
                    product.productName,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '₹${product.priceWithGst.toStringAsFixed(2)} | Stock: ${product.stockQuantity} ${product.unit}',
                      style: TextStyle(fontSize: 12, color: colorScheme.onSurface.withOpacity(0.6)),
                    ),
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildStatusChip(product.stockStatus, appTheme),
                      const SizedBox(height: 4),
                      const Icon(Icons.chevron_right, size: 16),
                    ],
                  ),
                  onTap: () => context.go('/products/${product.id}'),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPaginationControls(int totalPages) {
    final colorScheme = context.colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: _currentPage > 1
              ? () => setState(() => _currentPage--)
              : null,
        ),
        const SizedBox(width: 8),
        Text(
          'Page $_currentPage of $totalPages',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: _currentPage < totalPages
              ? () => setState(() => _currentPage++)
              : null,
        ),
      ],
    );
  }

  Widget _buildStatusChip(StockStatus status, AppThemeExtension appTheme) {
    Color? color;
    String label = '';

    switch (status) {
      case StockStatus.inStock:
        color = appTheme.successColor;
        label = 'IN STOCK';
        break;
      case StockStatus.lowStock:
        color = appTheme.warningColor;
        label = 'LOW STOCK';
        break;
      case StockStatus.outOfStock:
        color = appTheme.errorColor; // fallback
        if (color == null) color = Colors.red.shade600;
        label = 'OUT';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color?.withOpacity(0.08),
        borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
                     border: Border.all(color: color?.withOpacity(0.25) ?? Colors.transparent, width: 0.5),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.bold,
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
      builder: (context) => AlertDialog(
        title: const Text('Delete Product?'),
        content: Text('Are you sure you want to permanently delete "${product.productName}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: context.colorScheme.error,
            ),
            onPressed: () async {
              try {
                await provider.deleteProduct(product.id);
                if (context.mounted) {
                  Navigator.pop(context);
                  context.showSnackBar('Product deleted successfully');
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                  context.showSnackBar('Failed to delete product: $e', isError: true);
                }
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
