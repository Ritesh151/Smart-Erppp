import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:SmartERP/core/constants/app_constants.dart';
import 'package:SmartERP/core/extensions/context_extensions.dart';
import 'package:SmartERP/core/extensions/date_extensions.dart';
import 'package:SmartERP/core/models/product_model.dart';
import 'package:SmartERP/core/theme/theme_extensions.dart';
import 'package:SmartERP/core/utils/platform_image_provider.dart';
import 'package:SmartERP/core/widgets/app_button.dart';
import 'package:SmartERP/modules/products/providers/product_provider.dart';

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
    double radius = 20,
  }) {
    return BoxDecoration(
      color: white,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: divider.withOpacity(0.8),
      ),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF1E2A6E).withOpacity(0.06),
          blurRadius: 20,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }
}

class ProductDetailScreen extends StatefulWidget {
  final String productId;

  const ProductDetailScreen({
    super.key,
    required this.productId,
  });

  @override
  State<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState
    extends State<ProductDetailScreen> {
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
    final appTheme = context.appTheme;

    return Consumer<ProductProvider>(
      builder: (context, provider, _) {
        final product = provider.selectedProduct;

        if (product == null || product.id.isEmpty) {
          return Container(
            color: _T.bg,
            child: const Center(
              child: CircularProgressIndicator(
                color: _T.gradientStart,
              ),
            ),
          );
        }

        return Container(
          color: _T.bg,
          child: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(
                context.isMobile ? 16 : 24,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, product)
                      .animate()
                      .fadeIn(duration: 280.ms)
                      .slideX(begin: -0.04, end: 0),

                  SizedBox(
                    height:
                        context.isMobile ? 18 : 26,
                  ),

                  if (context.isDesktop)
                    Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 4,
                          child:
                              _buildImageSection(
                            product,
                          ),
                        ),

                        const SizedBox(width: 24),

                        Expanded(
                          flex: 6,
                          child: Column(
                            children: [
                              _buildMainDetailsCard(
                                product,
                                appTheme,
                              ),

                              const SizedBox(
                                  height: 18),

                              _buildPricingCard(
                                product,
                              ),

                              const SizedBox(
                                  height: 18),

                              _buildStockCard(
                                product,
                                provider,
                                appTheme,
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  else
                    Column(
                      children: [
                        _buildImageSection(
                          product,
                        ),

                        const SizedBox(height: 18),

                        _buildMainDetailsCard(
                          product,
                          appTheme,
                        ),

                        const SizedBox(height: 18),

                        _buildPricingCard(
                          product,
                        ),

                        const SizedBox(height: 18),

                        _buildStockCard(
                          product,
                          provider,
                          appTheme,
                        ),
                      ],
                    ),

                  const SizedBox(height: 28),

                  _buildActionPanel(
                    context,
                    product,
                    provider,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(
    BuildContext context,
    ProductModel product,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final vertical =
            constraints.maxWidth < 700;

        if (vertical) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  InkWell(
                    borderRadius:
                        BorderRadius.circular(14),
                    onTap: () {
                      context.go('/products');
                    },
                    child: Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(
                                14),
                        border: Border.all(
                          color: _T.divider,
                        ),
                      ),
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        color: _T.textDark,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.productName,
                          maxLines: 2,
                          overflow:
                              TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize:
                                context.isMobile
                                    ? 24
                                    : 30,
                            fontWeight:
                                FontWeight.w800,
                            color:
                                _T.textDark,
                            letterSpacing:
                                -0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 10,
                          runSpacing: 8,
                          children: [

                            _topPill(
                              icon: Icons.tag,
                              value:
                                  product.hsnCode ??
                                      'No HSN',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _buildStockBadge(
                product.stockStatus,
                context.appTheme,
              ),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Row(
                children: [
                  InkWell(
                    borderRadius:
                        BorderRadius.circular(14),
                    onTap: () {
                      context.go('/products');
                    },
                    child: Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(
                                14),
                        border: Border.all(
                          color: _T.divider,
                        ),
                      ),
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        color: _T.textDark,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.productName,
                          maxLines: 2,
                          overflow:
                              TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize:
                                context.isMobile
                                    ? 24
                                    : 30,
                            fontWeight:
                                FontWeight.w800,
                            color:
                                _T.textDark,
                            letterSpacing:
                                -0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 10,
                          runSpacing: 8,
                          children: [

                            _topPill(
                              icon: Icons.tag,
                              value:
                                  product.hsnCode ??
                                      'No HSN',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 18),
            _buildStockBadge(
              product.stockStatus,
              context.appTheme,
            ),
          ],
        );
      },
    );
  }

  Widget _topPill({
    required IconData icon,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: _T.gradientStart.withOpacity(
          0.06,
        ),
        borderRadius:
            BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: _T.gradientStart,
          ),
          const SizedBox(width: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: _T.textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection(
    ProductModel product,
  ) {
    final hasImage =
        product.imagePath != null &&
            product.imagePath!.trim().isNotEmpty;

    final imageProvider = hasImage
        ? platformImageProvider(
            product.imagePath!,
          )
        : null;

    return Container(
      width: double.infinity,
      decoration: _T.card(),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: _sectionHeader(
              title: 'Product Preview',
              subtitle:
                  'High resolution inventory image',
              icon: Icons.image_rounded,
            ),
          ),

          Container(
            height:
                context.isDesktop ? 480 : 300,
            width: double.infinity,
            margin:
                const EdgeInsets.fromLTRB(
              20,
              0,
              20,
              20,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _T.gradientStart
                      .withOpacity(0.05),
                  _T.gradientEnd
                      .withOpacity(0.03),
                ],
              ),
              borderRadius:
                  BorderRadius.circular(24),
            ),
            child: ClipRRect(
              borderRadius:
                  BorderRadius.circular(24),
              child: hasImage &&
                      imageProvider != null
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        Image(
                          image: imageProvider,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (_, __, ___) {
                            return _buildPlaceholder();
                          },
                          loadingBuilder: (
                            context,
                            child,
                            loadingProgress,
                          ) {
                            if (loadingProgress ==
                                null) {
                              return child;
                            }

                            return const Center(
                              child:
                                  CircularProgressIndicator(
                                color:
                                    _T.gradientStart,
                              ),
                            );
                          },
                        ),

                        Positioned(
                          top: 16,
                          right: 16,
                          child: Container(
                            padding:
                                const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black
                                  .withOpacity(
                                      0.5),
                              borderRadius:
                                  BorderRadius.circular(
                                      20),
                            ),
                            child: const Row(
                              mainAxisSize:
                                  MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons
                                      .check_circle_rounded,
                                  size: 14,
                                  color:
                                      Colors.white,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  'Image Available',
                                  style:
                                      TextStyle(
                                    color: Colors
                                        .white,
                                    fontSize: 11,
                                    fontWeight:
                                        FontWeight
                                            .w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  : _buildPlaceholder(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _T.gradientStart.withOpacity(
              0.06,
            ),
            _T.gradientEnd.withOpacity(
              0.03,
            ),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _T.gradientStart
                        .withOpacity(0.14),
                    _T.gradientEnd
                        .withOpacity(0.08),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.inventory_2_rounded,
                size: 52,
                color: _T.gradientStart,
              ),
            ),

            const SizedBox(height: 18),

            const Text(
              'No Product Image Available',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: _T.textDark,
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              'Upload image from edit product section',
              style: TextStyle(
                fontSize: 12,
                color: _T.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainDetailsCard(
    ProductModel product,
    AppThemeExtension appTheme,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: _T.card(),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _sectionHeader(
                  title: 'Product Details',
                  subtitle:
                      'Core inventory specifications',
                  icon:
                      Icons.inventory_2_rounded,
                ),
              ),

              _buildStockBadge(
                product.stockStatus,
                appTheme,
              ),
            ],
          ),

          const SizedBox(height: 24),

          Text(
            product.productName,
            style: TextStyle(
              fontSize:
                  context.isMobile ? 22 : 28,
              fontWeight: FontWeight.w800,
              color: _T.textDark,
              letterSpacing: -0.4,
            ),
          ),

          if (product.description != null &&
              product.description!
                  .trim()
                  .isNotEmpty) ...[
            const SizedBox(height: 16),

            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(
                  0xFFF8FAFC,
                ),
                borderRadius:
                    BorderRadius.circular(
                        18),
              ),
              child: Text(
                product.description!,
                style: const TextStyle(
                  height: 1.7,
                  fontSize: 13,
                  color: _T.textMuted,
                ),
              ),
            ),
          ],

          const SizedBox(height: 26),

          _buildInfoRow(
            'HSN Code',
            product.hsnCode ?? 'N/A',
          ),

          const SizedBox(height: 16),

          _buildInfoRow(
            'Created On',
            product.createdAt
                .toFormattedDateTime(),
          ),

          const SizedBox(height: 16),

          _buildInfoRow(
            'Last Updated',
            product.updatedAt
                .toFormattedDateTime(),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingCard(
    ProductModel product,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: _T.card(),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            title: 'Pricing',
            subtitle:
                'Commercial pricing structure',
            icon:
                Icons.currency_rupee_rounded,
          ),

          const SizedBox(height: 24),

          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient:
                  const LinearGradient(
                colors: [
                  _T.gradientStart,
                  _T.gradientEnd,
                ],
              ),
              borderRadius:
                  BorderRadius.circular(
                      22),
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'Selling Price',
                  style: TextStyle(
                    fontSize: 13,
                    color:
                        Colors.white70,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  '₹${product.price.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize:
                        context.isMobile
                            ? 30
                            : 38,
                    fontWeight:
                        FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
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
    final totalInventoryValue =
        product.inventoryValue;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: _T.card(),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _sectionHeader(
                  title:
                      'Stock & Inventory',
                  subtitle:
                      'Inventory monitoring and controls',
                  icon:
                      Icons.inventory_outlined,
                ),
              ),

              InkWell(
                borderRadius:
                    BorderRadius.circular(
                        14),
                onTap: () {
                  _showQuickStockDialog(
                    context,
                    product,
                    provider,
                  );
                },
                child: Container(
                  padding:
                      const EdgeInsets.all(
                    12,
                  ),
                  decoration: BoxDecoration(
                    color: _T.gradientStart
                        .withOpacity(0.08),
                    borderRadius:
                        BorderRadius.circular(
                            14),
                  ),
                  child: const Icon(
                    Icons.edit_rounded,
                    color:
                        _T.gradientStart,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          LayoutBuilder(
            builder:
                (context, constraints) {
              final vertical =
                  constraints.maxWidth <
                      620;

              if (vertical) {
                return Column(
                  children: [
                    _inventoryMetric(
                      title:
                          'Current Stock',
                      value:
                          '${product.stockQuantity} ${product.unit}(s)',
                      color: product.stockQuantity <=
                              product
                                  .minStockLevel
                          ? _T.warning
                          : _T.success,
                    ),
                    const SizedBox(height: 18),
                    _inventoryMetric(
                      title:
                          'Minimum Reorder',
                      value:
                          '${product.minStockLevel} ${product.unit}(s)',
                      color:
                          _T.gradientStart,
                    ),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(
                    child:
                        _inventoryMetric(
                      title:
                          'Current Stock',
                      value:
                          '${product.stockQuantity} ${product.unit}(s)',
                      color: product.stockQuantity <=
                              product
                                  .minStockLevel
                          ? _T.warning
                          : _T.success,
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child:
                        _inventoryMetric(
                      title:
                          'Minimum Reorder',
                      value:
                          '${product.minStockLevel} ${product.unit}(s)',
                      color:
                          _T.gradientStart,
                    ),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 24),

          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(
                0xFFF8FAFC,
              ),
              borderRadius:
                  BorderRadius.circular(
                      18),
            ),
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment
                      .spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    'Total Inventory Asset Value',
                    style: TextStyle(
                      fontSize: 13,
                      color:
                          _T.textMuted,
                    ),
                  ),
                ),

                Text(
                  '₹${totalInventoryValue.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight:
                        FontWeight.w800,
                    color: _T.textDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _inventoryMetric({
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: color.withOpacity(0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: _T.textMuted,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: color,
            ),
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final vertical =
            constraints.maxWidth < 560;

        if (vertical) {
          return Column(
            children: [
              SizedBox(
                height: 54,
                child: AppButton(
                  text: 'Delete Product',
                  variant:
                      AppButtonVariant.outline,
                  onPressed: () {
                    _confirmDelete(
                      context,
                      product,
                      provider,
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  gradient:
                      _T.brandGradient,
                  borderRadius:
                      BorderRadius.circular(
                    AppConstants
                        .defaultBorderRadius,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _T.gradientStart
                          .withOpacity(0.25),
                      blurRadius: 16,
                      offset:
                          const Offset(0, 6),
                    ),
                  ],
                ),
                child: SizedBox(
                  height: 54,
                  child: AppButton(
                    text:
                        'Edit Product Details',
                    variant:
                        AppButtonVariant.primary,
                    onPressed: () {
                      context.push(
                        '/products/${product.id}/edit',
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 54,
                child: AppButton(
                  text: 'Delete Product',
                  variant:
                      AppButtonVariant.outline,
                  onPressed: () {
                    _confirmDelete(
                      context,
                      product,
                      provider,
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  gradient:
                      _T.brandGradient,
                  borderRadius:
                      BorderRadius.circular(
                    AppConstants
                        .defaultBorderRadius,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _T.gradientStart
                          .withOpacity(0.25),
                      blurRadius: 16,
                      offset:
                          const Offset(0, 6),
                    ),
                  ],
                ),
                child: SizedBox(
                  height: 54,
                  child: AppButton(
                    text:
                        'Edit Product Details',
                    variant:
                        AppButtonVariant.primary,
                    onPressed: () {
                      context.push(
                        '/products/${product.id}/edit',
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStockBadge(
    StockStatus status,
    AppThemeExtension appTheme,
  ) {
    late Color color;
    late String label;

    switch (status) {
      case StockStatus.inStock:
        color =
            appTheme.successColor ??
                _T.success;
        label = 'IN STOCK';
        break;

      case StockStatus.lowStock:
        color =
            appTheme.warningColor ??
                _T.warning;
        label = 'LOW STOCK';
        break;

      case StockStatus.outOfStock:
        color =
            appTheme.errorColor ??
                _T.danger;
        label = 'OUT OF STOCK';
        break;
    }

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius:
            BorderRadius.circular(30),
        border: Border.all(
          color: color.withOpacity(0.18),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
  ) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        vertical: 12,
      ),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: _T.divider,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: _T.textMuted,
                fontSize: 13,
              ),
            ),
          ),

          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: _T.textDark,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            gradient: _T.brandGradient,
            borderRadius:
                BorderRadius.circular(14),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 20,
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight:
                      FontWeight.w800,
                  color: _T.textDark,
                ),
              ),

              const SizedBox(height: 2),

              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 11,
                  color: _T.textMuted,
                ),
              ),
            ],
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
    final controller =
        TextEditingController(
      text:
          product.stockQuantity.toString(),
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(
                    22),
          ),
          title: Text(
            'Adjust Stock',
            style: const TextStyle(
              fontWeight:
                  FontWeight.w800,
            ),
          ),
          content: Column(
            mainAxisSize:
                MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                product.productName,
                style: const TextStyle(
                  fontWeight:
                      FontWeight.w700,
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: controller,
                keyboardType:
                    TextInputType.number,
                decoration:
                    InputDecoration(
                  labelText:
                      'Stock Quantity',
                  prefixIcon:
                      const Icon(
                    Icons.inventory,
                  ),
                  border:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(
                            16),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                    context);
              },
              child: const Text(
                'Cancel',
              ),
            ),
            ElevatedButton(
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    _T.gradientStart,
                foregroundColor:
                    Colors.white,
              ),
              onPressed: () async {
                final newQty =
                    int.tryParse(
                  controller.text,
                );

                if (newQty != null &&
                    newQty >= 0) {
                  try {
                    await provider
                        .updateStock(
                      product.id,
                      newQty,
                    );

                    if (context
                        .mounted) {
                      Navigator.pop(
                          context);

                      context
                          .showSnackBar(
                        'Stock updated successfully',
                      );
                    }
                  } catch (e) {
                    if (context
                        .mounted) {
                      context
                          .showSnackBar(
                        'Failed to update stock: $e',
                        isError: true,
                      );
                    }
                  }
                } else {
                  context
                      .showSnackBar(
                    'Please enter valid quantity',
                    isError: true,
                  );
                }
              },
              child: const Text(
                'Save',
              ),
            ),
          ],
        );
      },
    );
  }

  void _confirmDelete(
    BuildContext context,
    ProductModel product,
    ProductProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(
                    22),
          ),
          title: const Text(
            'Delete Product?',
            style: TextStyle(
              fontWeight:
                  FontWeight.w800,
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
                Navigator.pop(
                    context);
              },
              child: const Text(
                'Cancel',
              ),
            ),
            Container(
              decoration:
                  BoxDecoration(
                color: _T.danger,
                borderRadius:
                    BorderRadius.circular(
                        12),
              ),
              child: TextButton(
                onPressed: () async {
                  try {
                    await provider
                        .deleteProduct(
                      product.id,
                    );

                    if (context
                        .mounted) {
                      Navigator.pop(
                          context);

                      context.go(
                        '/products',
                      );

                      context
                          .showSnackBar(
                        'Product deleted successfully',
                      );
                    }
                  } catch (e) {
                    if (context
                        .mounted) {
                      Navigator.pop(
                          context);

                      context
                          .showSnackBar(
                        'Failed to delete product: $e',
                        isError: true,
                      );
                    }
                  }
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(
                    color:
                        Colors.white,
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
