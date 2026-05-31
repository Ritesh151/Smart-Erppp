import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:siddhivinayak_enterprise/core/constants/app_constants.dart';
import 'package:siddhivinayak_enterprise/core/extensions/context_extensions.dart';
import 'package:siddhivinayak_enterprise/core/extensions/date_extensions.dart';
import 'package:siddhivinayak_enterprise/core/models/product_model.dart';
import 'package:siddhivinayak_enterprise/core/theme/theme_extensions.dart';
import 'package:siddhivinayak_enterprise/core/utils/platform_image_provider.dart';
import 'package:siddhivinayak_enterprise/core/widgets/app_button.dart';
import 'package:siddhivinayak_enterprise/modules/products/providers/product_provider.dart';

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

  static BoxDecoration card({double radius = 16}) => BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E2A6E).withOpacity(0.06),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      );
}

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
    return Consumer<ProductProvider>(
      builder: (context, provider, _) {
        final product = provider.selectedProduct;

        if (product == null || product.id.isEmpty) {
          return Container(
            color: _T.bg,
            child: const Center(
              child: CircularProgressIndicator(
                color: _T.gradientStart,
                strokeWidth: 2.5,
              ),
            ),
          );
        }

        return Container(
          color: _T.bg,
          child: SafeArea(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(context.isMobile ? 16.0 : 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, product)
                      .animate()
                      .fadeIn(duration: 350.ms)
                      .slideX(begin: -0.05, end: 0),
                  SizedBox(height: context.isMobile ? 20 : 28),
                  if (context.isDesktop)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 4,
                          child: _buildImageSection(context, product)
                              .animate()
                              .fadeIn(delay: 60.ms, duration: 320.ms)
                              .slideY(begin: 0.06, end: 0),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          flex: 6,
                          child: Column(
                            children: [
                              _buildMainDetailsCard(context, product)
                                  .animate()
                                  .fadeIn(delay: 80.ms, duration: 320.ms)
                                  .slideY(begin: 0.06, end: 0),
                              const SizedBox(height: 20),
                              _buildPricingCard(context, product)
                                  .animate()
                                  .fadeIn(delay: 120.ms, duration: 320.ms)
                                  .slideY(begin: 0.06, end: 0),
                              const SizedBox(height: 20),
                              _buildStockCard(context, product, provider)
                                  .animate()
                                  .fadeIn(delay: 160.ms, duration: 320.ms)
                                  .slideY(begin: 0.06, end: 0),
                            ],
                          ),
                        ),
                      ],
                    )
                  else
                    Column(
                      children: [
                        _buildImageSection(context, product)
                            .animate()
                            .fadeIn(delay: 60.ms, duration: 300.ms)
                            .slideY(begin: 0.08, end: 0),
                        const SizedBox(height: 16),
                        _buildMainDetailsCard(context, product)
                            .animate()
                            .fadeIn(delay: 100.ms, duration: 300.ms)
                            .slideY(begin: 0.08, end: 0),
                        const SizedBox(height: 16),
                        _buildPricingCard(context, product)
                            .animate()
                            .fadeIn(delay: 140.ms, duration: 300.ms)
                            .slideY(begin: 0.08, end: 0),
                        const SizedBox(height: 16),
                        _buildStockCard(context, product, provider)
                            .animate()
                            .fadeIn(delay: 180.ms, duration: 300.ms)
                            .slideY(begin: 0.08, end: 0),
                      ],
                    ),
                  const SizedBox(height: 32),
                  _buildActionPanel(context, product, provider)
                      .animate()
                      .fadeIn(delay: 220.ms, duration: 300.ms)
                      .slideY(begin: 0.08, end: 0),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context, ProductModel product) {
    final backBtn = _PressableButton(
      onTap: () => context.go('/products'),
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: _T.white,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: _T.divider),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1E2A6E).withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(Icons.arrow_back_rounded, color: _T.textDark, size: 20),
      ),
    );

    final hsnPill = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _T.gradientStart.withOpacity(0.07),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: _T.gradientStart.withOpacity(0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.tag_rounded, size: 13, color: _T.gradientStart),
          const SizedBox(width: 5),
          Text(
            product.hsnCode ?? 'No HSN',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: _T.textDark,
            ),
          ),
        ],
      ),
    );

    final stockBadge = _buildStockBadge(product.stockStatus, context.appTheme);

    final titleBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product.productName,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: context.isMobile ? 22 : 28,
            fontWeight: FontWeight.w800,
            color: _T.textDark,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        hsnPill,
      ],
    );

    if (context.isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              backBtn,
              const SizedBox(width: 14),
              Expanded(child: titleBlock),
            ],
          ),
          const SizedBox(height: 14),
          stockBadge,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        backBtn,
        const SizedBox(width: 14),
        Expanded(child: titleBlock),
        const SizedBox(width: 16),
        stockBadge,
      ],
    );
  }

  // ── Image Section ──────────────────────────────────────────────────────────
  Widget _buildImageSection(BuildContext context, ProductModel product) {
    final hasImage = product.imagePath != null && product.imagePath!.trim().isNotEmpty;
    final imageProvider = hasImage ? platformImageProvider(product.imagePath!) : null;

    return Container(
      width: double.infinity,
      decoration: _T.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(context.isMobile ? 16 : 20),
            child: _sectionHeader(
              title: 'Product Preview',
              subtitle: 'High resolution inventory image',
              icon: Icons.image_rounded,
            ),
          ),
          Container(
            height: context.isDesktop ? 460 : 260,
            width: double.infinity,
            margin: EdgeInsets.fromLTRB(
              context.isMobile ? 16 : 20,
              0,
              context.isMobile ? 16 : 20,
              context.isMobile ? 16 : 20,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _T.gradientStart.withOpacity(0.05),
                  _T.gradientEnd.withOpacity(0.03),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _T.divider),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: hasImage && imageProvider != null
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        Image(
                          image: imageProvider,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
                          loadingBuilder: (ctx, child, progress) {
                            if (progress == null) return child;
                            return Container(
                              color: _T.white,
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: _T.gradientStart,
                                  strokeWidth: 2.5,
                                ),
                              ),
                            );
                          },
                        ),
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.52),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.check_circle_rounded,
                                    size: 13, color: Colors.white),
                                SizedBox(width: 5),
                                Text(
                                  'Image Available',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  : _buildImagePlaceholder(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: _T.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _T.gradientStart.withOpacity(0.1),
                    _T.gradientEnd.withOpacity(0.07),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.inventory_2_rounded,
                size: 42,
                color: _T.gradientStart,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No Product Image Available',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: _T.textDark,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'Upload image from edit product section',
              style: TextStyle(fontSize: 12, color: _T.textMuted),
            ),
          ],
        ),
      ),
    );
  }

  // ── Main Details Card ──────────────────────────────────────────────────────
  Widget _buildMainDetailsCard(BuildContext context, ProductModel product) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(context.isMobile ? 16 : 20),
      decoration: _T.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _sectionHeader(
                  title: 'Product Details',
                  subtitle: 'Core inventory specifications',
                  icon: Icons.inventory_2_rounded,
                ),
              ),
              _buildStockBadge(product.stockStatus, context.appTheme),
            ],
          ),
          const SizedBox(height: 22),
          Text(
            product.productName,
            style: TextStyle(
              fontSize: context.isMobile ? 20 : 26,
              fontWeight: FontWeight.w800,
              color: _T.textDark,
              letterSpacing: -0.4,
            ),
          ),
          if (product.description != null &&
              product.description!.trim().isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _T.divider),
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
          const SizedBox(height: 22),
          _buildInfoRow('HSN Code', product.hsnCode ?? 'N/A'),
          _buildInfoRow('Created On', product.createdAt.toFormattedDateTime()),
          _buildInfoRow('Last Updated', product.updatedAt.toFormattedDateTime(),
              isLast: true),
        ],
      ),
    );
  }

  // ── Pricing Card ───────────────────────────────────────────────────────────
  Widget _buildPricingCard(BuildContext context, ProductModel product) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(context.isMobile ? 16 : 20),
      decoration: _T.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            title: 'Pricing',
            subtitle: 'Commercial pricing structure',
            icon: Icons.currency_rupee_rounded,
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(context.isMobile ? 18 : 22),
            decoration: BoxDecoration(
              gradient: _T.brandGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: _T.gradientStart.withOpacity(0.25),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Selling Price',
                  style: TextStyle(fontSize: 12, color: Colors.white70),
                ),
                const SizedBox(height: 8),
                Text(
                  '₹${product.price.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: context.isMobile ? 28 : 36,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'per ${product.unit}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Stock Card ─────────────────────────────────────────────────────────────
  Widget _buildStockCard(
      BuildContext context, ProductModel product, ProductProvider provider) {
    final totalInventoryValue = product.inventoryValue;
    final isLowOrOut =
        product.stockQuantity <= product.minStockLevel;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(context.isMobile ? 16 : 20),
      decoration: _T.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _sectionHeader(
                  title: 'Stock & Inventory',
                  subtitle: 'Inventory monitoring and controls',
                  icon: Icons.inventory_outlined,
                ),
              ),
              _PressableButton(
                onTap: () => _showQuickStockDialog(context, product, provider),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _T.gradientStart.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: _T.gradientStart.withOpacity(0.18)),
                  ),
                  child: const Icon(Icons.edit_rounded,
                      color: _T.gradientStart, size: 18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final vertical = constraints.maxWidth < 560;
              final currentStockWidget = _inventoryMetricTile(
                title: 'Current Stock',
                value: '${product.stockQuantity}',
                unit: product.unit,
                color: isLowOrOut ? _T.warning : _T.success,
                icon: isLowOrOut
                    ? Icons.warning_amber_rounded
                    : Icons.check_circle_rounded,
              );
              final minStockWidget = _inventoryMetricTile(
                title: 'Min Reorder Level',
                value: '${product.minStockLevel}',
                unit: product.unit,
                color: _T.gradientStart,
                icon: Icons.notifications_active_rounded,
              );
              if (vertical) {
                return Column(
                  children: [
                    currentStockWidget,
                    const SizedBox(height: 12),
                    minStockWidget,
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(child: currentStockWidget),
                  const SizedBox(width: 14),
                  Expanded(child: minStockWidget),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          // Inventory value banner
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(context.isMobile ? 14 : 18),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _T.divider),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: _T.gradientStart.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet_rounded,
                        color: _T.gradientStart,
                        size: 17,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Total Inventory Value',
                      style: TextStyle(
                        fontSize: 13,
                        color: _T.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Text(
                  '₹${totalInventoryValue.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: _T.textDark,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _inventoryMetricTile({
    required String title,
    required String value,
    required String unit,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 15),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 11,
                  color: _T.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: color,
                    letterSpacing: -0.3,
                  ),
                ),
                TextSpan(
                  text: ' $unit(s)',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: color.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Action Panel ───────────────────────────────────────────────────────────
  Widget _buildActionPanel(
      BuildContext context, ProductModel product, ProductProvider provider) {
    final deleteBtn = _PressableButton(
      onTap: () => _confirmDelete(context, product, provider),
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          color: _T.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _T.danger.withOpacity(0.35), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: _T.danger.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: const Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.delete_outline_rounded, color: _T.danger, size: 18),
              SizedBox(width: 8),
              Text(
                'Delete Product',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: _T.danger,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    final editBtn = _PressableButton(
      onTap: () => context.push('/products/${product.id}/edit'),
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          gradient: _T.brandGradient,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: _T.gradientStart.withOpacity(0.28),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.edit_rounded, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text(
                'Edit Product Details',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (context.isMobile) {
      return Column(
        children: [
          editBtn,
          const SizedBox(height: 12),
          deleteBtn,
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: deleteBtn),
        const SizedBox(width: 16),
        Expanded(flex: 2, child: editBtn),
      ],
    );
  }

  // ── Stock Badge ────────────────────────────────────────────────────────────
  Widget _buildStockBadge(StockStatus status, AppThemeExtension appTheme) {
    late Color color;
    late String label;
    late IconData icon;

    switch (status) {
      case StockStatus.inStock:
        color = appTheme.successColor ?? _T.success;
        label = 'IN STOCK';
        icon = Icons.check_circle_rounded;
        break;
      case StockStatus.lowStock:
        color = appTheme.warningColor ?? _T.warning;
        label = 'LOW STOCK';
        icon = Icons.warning_amber_rounded;
        break;
      case StockStatus.outOfStock:
        color = appTheme.errorColor ?? _T.danger;
        label = 'OUT OF STOCK';
        icon = Icons.cancel_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withOpacity(0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  // ── Info Row ───────────────────────────────────────────────────────────────
  Widget _buildInfoRow(String label, String value, {bool isLast = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(bottom: BorderSide(color: _T.divider)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: _T.textMuted, fontSize: 13),
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

  // ── Section Header ─────────────────────────────────────────────────────────
  Widget _sectionHeader({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: _T.brandGradient,
            borderRadius: BorderRadius.circular(11),
            boxShadow: [
              BoxShadow(
                color: _T.gradientStart.withOpacity(0.22),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: _T.textDark,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 11, color: _T.textMuted),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Quick Stock Dialog ─────────────────────────────────────────────────────
  void _showQuickStockDialog(
      BuildContext context, ProductModel product, ProductProvider provider) {
    final controller =
        TextEditingController(text: product.stockQuantity.toString());

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: _T.white,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: _T.brandGradient,
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: const Icon(Icons.inventory_rounded,
                          color: Colors.white, size: 18),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Adjust Stock',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: _T.textDark,
                        ),
                      ),
                    ),
                    _PressableButton(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: const Icon(Icons.close_rounded,
                            color: _T.textMuted, size: 17),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.only(left: 52),
                  child: Text(
                    product.productName,
                    style: const TextStyle(fontSize: 12, color: _T.textMuted),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 22),
                TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  autofocus: true,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: _T.textDark,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Stock Quantity',
                    labelStyle:
                        const TextStyle(color: _T.textMuted, fontSize: 13),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    prefixIcon: const Icon(Icons.inventory_2_outlined,
                        color: _T.textMuted, size: 20),
                    suffixText: product.unit,
                    suffixStyle: const TextStyle(
                        color: _T.textMuted, fontWeight: FontWeight.w600),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: _T.divider),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: _T.divider),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide:
                          const BorderSide(color: _T.gradientStart, width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: _PressableButton(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: _T.white,
                            borderRadius: BorderRadius.circular(13),
                            border: Border.all(color: _T.divider, width: 1.5),
                          ),
                          child: const Center(
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: _T.textMid,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _PressableButton(
                        onTap: () async {
                          final newQty = int.tryParse(controller.text);
                          if (newQty != null && newQty >= 0) {
                            try {
                              await provider.updateStock(product.id, newQty);
                              if (context.mounted) {
                                Navigator.pop(context);
                                context.showSnackBar(
                                    'Stock updated successfully');
                              }
                            } catch (e) {
                              if (context.mounted) {
                                context.showSnackBar(
                                    'Failed to update stock: $e',
                                    isError: true);
                              }
                            }
                          } else {
                            context.showSnackBar(
                                'Please enter valid quantity',
                                isError: true);
                          }
                        },
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: _T.brandGradient,
                            borderRadius: BorderRadius.circular(13),
                            boxShadow: [
                              BoxShadow(
                                color: _T.gradientStart.withOpacity(0.25),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text(
                              'Save Changes',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                fontSize: 14,
                              ),
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
        );
      },
    );
  }

  // ── Confirm Delete Dialog ──────────────────────────────────────────────────
  void _confirmDelete(
      BuildContext context, ProductModel product, ProductProvider provider) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: _T.white,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _T.danger.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(11),
                        border: Border.all(
                            color: _T.danger.withOpacity(0.2)),
                      ),
                      child: const Icon(Icons.delete_outline_rounded,
                          color: _T.danger, size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Delete Product?',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: _T.textDark,
                        ),
                      ),
                    ),
                    _PressableButton(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: const Icon(Icons.close_rounded,
                            color: _T.textMuted, size: 17),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _T.danger.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _T.danger.withOpacity(0.12)),
                  ),
                  child: Text(
                    'Are you sure you want to permanently delete "${product.productName}"? This action cannot be undone.',
                    style: const TextStyle(
                      height: 1.6,
                      fontSize: 13,
                      color: _T.textMuted,
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: _PressableButton(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: _T.white,
                            borderRadius: BorderRadius.circular(13),
                            border: Border.all(color: _T.divider, width: 1.5),
                          ),
                          child: const Center(
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: _T.textMid,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _PressableButton(
                        onTap: () async {
                          try {
                            await provider.deleteProduct(product.id);
                            if (context.mounted) {
                              Navigator.pop(context);
                              context.go('/products');
                              context.showSnackBar(
                                  'Product deleted successfully');
                            }
                          } catch (e) {
                            if (context.mounted) {
                              Navigator.pop(context);
                              context.showSnackBar(
                                  'Failed to delete product: $e',
                                  isError: true);
                            }
                          }
                        },
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: _T.danger,
                            borderRadius: BorderRadius.circular(13),
                            boxShadow: [
                              BoxShadow(
                                color: _T.danger.withOpacity(0.25),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.delete_rounded,
                                    color: Colors.white, size: 16),
                                SizedBox(width: 6),
                                Text(
                                  'Delete',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
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
        );
      },
    );
  }
}

// ── Pressable Button (micro-interaction) ─────────────────────────────────────
class _PressableButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _PressableButton({required this.child, required this.onTap});

  @override
  State<_PressableButton> createState() => _PressableButtonState();
}

class _PressableButtonState extends State<_PressableButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}