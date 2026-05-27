import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:smarterp/core/constants/app_constants.dart';
import 'package:smarterp/core/extensions/context_extensions.dart';
import 'package:smarterp/core/extensions/date_extensions.dart';
import 'package:smarterp/core/theme/theme_extensions.dart';
import 'package:smarterp/core/widgets/app_shell.dart';
import 'package:smarterp/core/widgets/app_card.dart';
import 'package:smarterp/core/widgets/app_button.dart';
import 'package:smarterp/core/models/product_model.dart';
import 'package:smarterp/modules/products/providers/product_provider.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;

  const ProductDetailScreen({
    super.key,
    required this.productId,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ProductProvider>();
      final product = provider.products.firstWhere(
        (p) => p.id == widget.productId,
        orElse: () => ProductModel(
          id: '',
          productName: '',
          price: 0,
          stockQuantity: 0,
          gstRate: 0,
          category: '',
          costPrice: 0,
          minStockLevel: 0,
          unit: '',
          isActive: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
      if (product.id.isNotEmpty) {
        provider.selectProduct(product);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final theme = context.theme;
    final appTheme = context.appTheme;

    return AppShell(
      title: 'Product Details',
      child: Consumer<ProductProvider>(
        builder: (context, provider, _) {
          final product = provider.selectedProduct;

          if (product == null || product.id.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final isDesktop = context.isDesktop;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBreadcrumbs(context, product.productName),
                const SizedBox(height: 24),
                if (isDesktop)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 4,
                        child: _buildImageSection(product),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        flex: 6,
                        child: Column(
                          children: [
                            _buildMainDetailsCard(product, appTheme),
                            const SizedBox(height: 16),
                            _buildPricingCard(product, appTheme),
                            const SizedBox(height: 16),
                            _buildStockCard(product, provider, appTheme),
                          ],
                        ),
                      ),
                    ],
                  )
                else
                  Column(
                    children: [
                      _buildImageSection(product),
                      const SizedBox(height: 16),
                      _buildMainDetailsCard(product, appTheme),
                      const SizedBox(height: 16),
                      _buildPricingCard(product, appTheme),
                      const SizedBox(height: 16),
                      _buildStockCard(product, provider, appTheme),
                    ],
                  ),
                const SizedBox(height: 24),
                _buildActionPanel(context, product, provider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBreadcrumbs(BuildContext context, String productName) {
    final colorScheme = context.colorScheme;
    return Row(
      children: [
        InkWell(
          onTap: () => context.go('/products'),
          child: Text(
            'Products',
            style: TextStyle(
              color: colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const Icon(Icons.chevron_right, size: 16),
        Expanded(
          child: Text(
            productName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageSection(ProductModel product) {
    final colorScheme = context.colorScheme;
    final hasImage = product.imagePath != null && product.imagePath!.isNotEmpty;

    return Container(
      height: context.isDesktop ? 450 : 250,
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
        child: hasImage
            ? File(product.imagePath!).existsSync()
                ? Image.file(
                    File(product.imagePath!),
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
                  )
                : _buildPlaceholder()
            : _buildPlaceholder(),
      ),
    );
  }

  Widget _buildPlaceholder() {
    final colorScheme = context.colorScheme;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primary.withOpacity(0.05),
            colorScheme.secondary.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2,
              size: 64,
              color: colorScheme.primary.withOpacity(0.4),
            ),
            const SizedBox(height: 16),
            Text(
              'No Product Image Available',
              style: TextStyle(
                color: colorScheme.onSurface.withOpacity(0.4),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainDetailsCard(ProductModel product, AppThemeExtension appTheme) {
    final theme = context.theme;
    final colorScheme = context.colorScheme;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
                ),
                child: Text(
                  product.category,
                  style: TextStyle(
                    color: colorScheme.onSecondaryContainer,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _buildStockBadge(product.stockStatus, appTheme),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            product.productName,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          if (product.description != null && product.description!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              product.description!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.7),
                height: 1.4,
              ),
            ),
          ],
          const Divider(height: 32),
          _buildInfoRow('HSN Code', product.hsnCode ?? 'N/A'),
          const SizedBox(height: 12),
          _buildInfoRow('SKU Code', product.sku ?? 'N/A'),
          const SizedBox(height: 12),
          _buildInfoRow('Barcode', product.barcode ?? 'N/A'),
          const SizedBox(height: 12),
          _buildInfoRow('Created On', product.createdAt.toFormattedDateTime()),
          const SizedBox(height: 12),
          _buildInfoRow('Last Updated', product.updatedAt.toFormattedDateTime()),
        ],
      ),
    );
  }

  Widget _buildPricingCard(ProductModel product, AppThemeExtension appTheme) {
    final colorScheme = context.colorScheme;
    final profitMargin = product.profitMargin;
    final profitPercentage = product.profitMarginPercentage;
    final isProfitable = profitMargin >= 0;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Financials & Pricing',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildFinancialMetric(
                  'Cost Price',
                  '₹${product.costPrice.toStringAsFixed(2)}',
                  colorScheme.onSurface.withOpacity(0.8),
                ),
              ),
              Expanded(
                child: _buildFinancialMetric(
                  'Selling Price (Excl. GST)',
                  '₹${product.price.toStringAsFixed(2)}',
                  colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildFinancialMetric(
                  'GST Rate',
                  '${product.gstRate.toStringAsFixed(0)}%',
                  colorScheme.secondary,
                ),
              ),
              Expanded(
                child: _buildFinancialMetric(
                  'Price (Incl. GST)',
                  '₹${product.priceWithGst.toStringAsFixed(2)}',
                  colorScheme.onSurface,
                  isBold: true,
                ),
              ),
            ],
          ),
          const Divider(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Net Profit Margin',
                    style: TextStyle(
                      fontSize: 13,
                      color: colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₹${profitMargin.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isProfitable ? appTheme.successColor : colorScheme.error,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: (isProfitable ? appTheme.successColor : colorScheme.error)?.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
                ),
                child: Text(
                  '${isProfitable ? '+' : ''}${profitPercentage.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isProfitable ? appTheme.successColor : colorScheme.error,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStockCard(
    ProductModel product,
    ProductProvider provider,
    AppThemeExtension appTheme,
  ) {
    final colorScheme = context.colorScheme;
    final totalInventoryValue = product.inventoryValue;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Stock & Inventory Control',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_calendar),
                tooltip: 'Quick Adjust Stock',
                color: colorScheme.primary,
                onPressed: () => _showQuickStockDialog(context, product, provider),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildFinancialMetric(
                  'Current Stock',
                  '${product.stockQuantity} ${product.unit}(s)',
                  product.stockQuantity <= product.minStockLevel
                      ? appTheme.warningColor ?? Colors.orange
                      : colorScheme.primary,
                  isBold: true,
                ),
              ),
              Expanded(
                child: _buildFinancialMetric(
                  'Min. Reorder Level',
                  '${product.minStockLevel} ${product.unit}(s)',
                  colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
          const Divider(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Inventory Asset Value',
                style: TextStyle(
                  fontSize: 13,
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              Text(
                '₹${totalInventoryValue.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionPanel(
    BuildContext context,
    ProductModel product,
    ProductProvider provider,
  ) {
    return Row(
      children: [
        Expanded(
          child: AppButton(
            text: 'Delete Product',
            variant: AppButtonVariant.outline,
            onPressed: () => _confirmDelete(context, product, provider),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: AppButton(
            text: 'Edit Product Details',
            variant: AppButtonVariant.primary,
            onPressed: () {
              context.go('/products/${product.id}/edit');
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStockBadge(StockStatus status, AppThemeExtension appTheme) {
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
        label = 'OUT OF STOCK';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color?.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
        border: Border.all(color: color?.withOpacity(0.3) ?? Colors.transparent),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    final colorScheme = context.colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: colorScheme.onSurface.withOpacity(0.5),
            fontSize: 13,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildFinancialMetric(
    String label,
    String value,
    Color? valueColor, {
    bool isBold = false,
  }) {
    final colorScheme = context.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: colorScheme.onSurface.withOpacity(0.5),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  void _showQuickStockDialog(
    BuildContext context,
    ProductModel product,
    ProductProvider provider,
  ) {
    final controller = TextEditingController(text: product.stockQuantity.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Adjust Stock: ${product.productName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Enter new stock quantity in ${product.unit}(s):'),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Quantity',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newQty = int.tryParse(controller.text);
              if (newQty != null && newQty >= 0) {
                try {
                  await provider.updateStock(product.id, newQty);
                  if (context.mounted) {
                    Navigator.pop(context);
                    context.showSnackBar('Stock updated successfully');
                  }
                } catch (e) {
                  if (context.mounted) {
                    context.showSnackBar('Failed to update stock: $e', isError: true);
                  }
                }
              } else {
                context.showSnackBar('Please enter a valid non-negative quantity', isError: true);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(
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
                  context.go('/products'); 
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
