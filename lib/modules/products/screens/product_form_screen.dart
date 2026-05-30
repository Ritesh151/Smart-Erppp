import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:SmartERP/core/constants/app_constants.dart';
import 'package:SmartERP/core/extensions/context_extensions.dart';
import 'package:SmartERP/core/models/product_model.dart';
import 'package:SmartERP/core/routes/app_routes.dart';
import 'package:SmartERP/core/services/image_service.dart';
import 'package:SmartERP/core/theme/theme_extensions.dart';
import 'package:SmartERP/core/utils/platform_image_provider.dart';
import 'package:SmartERP/core/widgets/app_button.dart';
import 'package:SmartERP/core/widgets/app_text_field.dart';
import 'package:SmartERP/modules/products/providers/product_provider.dart';

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

class ProductFormScreen extends StatefulWidget {
  final String? productId;

  const ProductFormScreen({
    super.key,
    this.productId,
  });

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _imageService = ImageService();

  late TextEditingController _nameController;
  late TextEditingController _hsnController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;
  late TextEditingController _minStockController;
  late TextEditingController _descriptionController;
  late AnimationController _saveAnimController;

  String _selectedUnit = 'Piece';
  String? _imagePath;
  bool _isActive = true;
  bool _isEditMode = false;
  ProductModel? _existingProduct;
  bool _imageLoading = false;
  bool _isSaving = false;

  final List<String> _units = [
    'Piece',
    'Bag',
    'Kg',
    'Ton',
    'Box',
    'Liter',
    'Meter',
  ];

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.productId != null;
    _nameController        = TextEditingController();
    _hsnController         = TextEditingController();
    _priceController       = TextEditingController();
    _stockController       = TextEditingController();
    _minStockController    = TextEditingController();
    _descriptionController = TextEditingController();
    _saveAnimController    = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    if (_isEditMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadExistingProduct());
    }
  }

  void _loadExistingProduct() {
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
      setState(() {
        _existingProduct           = product;
        _nameController.text       = product.productName;
        _hsnController.text        = product.hsnCode ?? '';
        _priceController.text      = product.price.toString();
        _stockController.text      = product.stockQuantity.toString();
        _minStockController.text   = product.minStockLevel.toString();
        _descriptionController.text = product.description ?? '';
        _selectedUnit              = _units.contains(product.unit) ? product.unit : 'Piece';
        _imagePath                 = product.imagePath;
        _isActive                  = product.isActive;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _hsnController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _minStockController.dispose();
    _descriptionController.dispose();
    _saveAnimController.dispose();
    super.dispose();
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Container(
      color: _T.bg,
      child: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(context.isMobile ? 16.0 : 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFormHeader(context)
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
                        child: Column(
                          children: [
                            _buildImagePickerCard()
                                .animate()
                                .fadeIn(delay: 60.ms, duration: 320.ms)
                                .slideY(begin: 0.06, end: 0),
                            const SizedBox(height: 20),
                            _buildStatusCard()
                                .animate()
                                .fadeIn(delay: 120.ms, duration: 320.ms)
                                .slideY(begin: 0.06, end: 0),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        flex: 6,
                        child: Column(
                          children: [
                            _buildGeneralInfoCard()
                                .animate()
                                .fadeIn(delay: 80.ms, duration: 320.ms)
                                .slideY(begin: 0.06, end: 0),
                            const SizedBox(height: 20),
                            _buildPricingCard()
                                .animate()
                                .fadeIn(delay: 140.ms, duration: 320.ms)
                                .slideY(begin: 0.06, end: 0),
                            const SizedBox(height: 20),
                            _buildInventoryCard()
                                .animate()
                                .fadeIn(delay: 180.ms, duration: 320.ms)
                                .slideY(begin: 0.06, end: 0),
                          ],
                        ),
                      ),
                    ],
                  )
                else
                  Column(
                    children: [
                      _buildImagePickerCard()
                          .animate()
                          .fadeIn(delay: 60.ms, duration: 300.ms)
                          .slideY(begin: 0.08, end: 0),
                      const SizedBox(height: 16),
                      _buildGeneralInfoCard()
                          .animate()
                          .fadeIn(delay: 100.ms, duration: 300.ms)
                          .slideY(begin: 0.08, end: 0),
                      const SizedBox(height: 16),
                      _buildPricingCard()
                          .animate()
                          .fadeIn(delay: 140.ms, duration: 300.ms)
                          .slideY(begin: 0.08, end: 0),
                      const SizedBox(height: 16),
                      _buildInventoryCard()
                          .animate()
                          .fadeIn(delay: 180.ms, duration: 300.ms)
                          .slideY(begin: 0.08, end: 0),
                      const SizedBox(height: 16),
                      _buildStatusCard()
                          .animate()
                          .fadeIn(delay: 220.ms, duration: 300.ms)
                          .slideY(begin: 0.08, end: 0),
                    ],
                  ),
                const SizedBox(height: 32),
                _buildActionButtons(context)
                    .animate()
                    .fadeIn(delay: 260.ms, duration: 300.ms)
                    .slideY(begin: 0.08, end: 0),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Form Header ────────────────────────────────────────────────────────────
  Widget _buildFormHeader(BuildContext context) {
    final modeBadge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: _T.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _T.divider),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E2A6E).withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              gradient: _isEditMode
                  ? const LinearGradient(
                      colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : const LinearGradient(
                      colors: [_T.gradientStart, _T.gradientEnd],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _isEditMode ? Icons.edit_rounded : Icons.add_rounded,
              color: _T.white,
              size: 14,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            _isEditMode ? 'Editing Mode' : 'New Product',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _T.textDark,
            ),
          ),
        ],
      ),
    );

    final backBtn = _PressableIconButton(
      onTap: () => context.pop(),
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

    final titleBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _isEditMode ? 'Update Product' : 'Create Product',
          style: TextStyle(
            fontSize: context.isMobile ? 22 : 26,
            fontWeight: FontWeight.w800,
            color: _T.textDark,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _isEditMode
              ? 'Modify product specifications and inventory details.'
              : 'Enter product information and inventory specifications.',
          style: const TextStyle(fontSize: 13, color: _T.textMuted),
        ),
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
          const SizedBox(height: 16),
          modeBadge,
        ],
      );
    }

    return Row(
      children: [
        backBtn,
        const SizedBox(width: 14),
        Expanded(child: titleBlock),
        const SizedBox(width: 16),
        modeBadge,
      ],
    );
  }

  // ── Image Picker Card ──────────────────────────────────────────────────────
  Widget _buildImagePickerCard() {
    final hasImage = _imagePath != null && _imagePath!.trim().isNotEmpty;
    final imageProvider = hasImage ? platformImageProvider(_imagePath!) : null;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(context.isMobile ? 16 : 20),
      decoration: _T.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            title: 'Product Image',
            subtitle: 'Upload high quality product visuals',
            icon: Icons.image_rounded,
          ),
          const SizedBox(height: 20),

          // Image preview area
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            height: context.isMobile ? 230 : 300,
            width: double.infinity,
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
                        // Overlay badge
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
                                  'Image Ready',
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
                  : _imageLoading
                      ? Container(
                          color: _T.white,
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: _T.gradientStart,
                              strokeWidth: 2.5,
                            ),
                          ),
                        )
                      : _buildImagePlaceholder(),
            ),
          ),

          const SizedBox(height: 16),

          // Action buttons
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _imageActionButton(
                label: 'Camera',
                icon: Icons.camera_alt_rounded,
                color: _T.gradientStart,
                onTap: () => _pickImage(ImageSource.camera),
              ),
              _imageActionButton(
                label: 'Gallery',
                icon: Icons.photo_library_rounded,
                color: _T.gradientEnd,
                onTap: () => _pickImage(ImageSource.gallery),
              ),
              if (hasImage)
                _imageActionButton(
                  label: 'Remove',
                  icon: Icons.delete_outline_rounded,
                  color: _T.danger,
                  onTap: () => setState(() => _imagePath = null),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _imageActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return _PressableIconButton(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        decoration: BoxDecoration(
          color: color.withOpacity(0.07),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.18)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 7),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ],
        ),
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
              width: 80,
              height: 80,
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
                Icons.add_photo_alternate_outlined,
                size: 38,
                color: _T.gradientStart,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Upload Product Image',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: _T.textDark,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'Supports camera & gallery uploads',
              style: TextStyle(fontSize: 12, color: _T.textMuted),
            ),
          ],
        ),
      ),
    );
  }

  // ── General Info Card ──────────────────────────────────────────────────────
  Widget _buildGeneralInfoCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(context.isMobile ? 16 : 20),
      decoration: _T.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            title: 'General Information',
            subtitle: 'Basic product identity and classification',
            icon: Icons.inventory_2_rounded,
          ),
          const SizedBox(height: 22),
          AppTextField(
            controller: _nameController,
            label: 'Product Name *',
            hintText: 'e.g. Portland Cement Grade 53',
            prefixIcon: const Icon(Icons.shopping_bag_outlined),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Product name is required';
              }
              if (value.trim().length < 2) {
                return 'Name must be at least 2 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: _hsnController,
            label: 'HSN Code',
            hintText: 'e.g. 25232910',
            prefixIcon: const Icon(Icons.tag_rounded),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                if (!RegExp(r'^\d+$').hasMatch(value)) {
                  return 'HSN must contain digits only';
                }
                if (value.length < 4 || value.length > 8) {
                  return 'HSN must be 4 to 8 digits long';
                }
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: _descriptionController,
            label: 'Description',
            hintText: 'Describe material properties, packaging, usage...',
            prefixIcon: const Icon(Icons.description_outlined),
            maxLines: 4,
          ),
        ],
      ),
    );
  }

  // ── Pricing Card ───────────────────────────────────────────────────────────
  Widget _buildPricingCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(context.isMobile ? 16 : 20),
      decoration: _T.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            title: 'Pricing Details',
            subtitle: 'Commercial pricing configuration',
            icon: Icons.currency_rupee_rounded,
          ),
          const SizedBox(height: 22),
          AppTextField(
            controller: _priceController,
            label: 'Selling Price *',
            hintText: '0.00',
            prefixIcon: const Icon(Icons.sell_outlined),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Selling Price is required';
              final val = double.tryParse(value);
              if (val == null || val <= 0) return 'Must be > 0';
              return null;
            },
          ),
        ],
      ),
    );
  }

  // ── Inventory Card ─────────────────────────────────────────────────────────
  Widget _buildInventoryCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(context.isMobile ? 16 : 20),
      decoration: _T.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            title: 'Inventory & Packaging',
            subtitle: 'Stock levels and packaging configuration',
            icon: Icons.inventory_outlined,
          ),
          const SizedBox(height: 22),
          LayoutBuilder(
            builder: (context, constraints) {
              final vertical = constraints.maxWidth < 600;
              final stockField = AppTextField(
                controller: _stockController,
                label: 'Current Stock *',
                hintText: '0',
                prefixIcon: const Icon(Icons.inventory_2_outlined),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Required';
                  final val = int.tryParse(value);
                  if (val == null || val < 0) return 'Must be ≥ 0';
                  return null;
                },
              );
              final minStockField = AppTextField(
                controller: _minStockController,
                label: 'Min Reorder Threshold *',
                hintText: '0',
                prefixIcon: const Icon(Icons.notifications_active_outlined),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Required';
                  final val = int.tryParse(value);
                  if (val == null || val < 0) return 'Must be ≥ 0';
                  return null;
                },
              );
              if (vertical) {
                return Column(
                  children: [
                    stockField,
                    const SizedBox(height: 16),
                    minStockField,
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(child: stockField),
                  const SizedBox(width: 16),
                  Expanded(child: minStockField),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedUnit,
            borderRadius: BorderRadius.circular(16),
            decoration: _dropdownDecoration('Stock Unit *', Icons.scale_outlined),
            onChanged: (value) {
              if (value != null) setState(() => _selectedUnit = value);
            },
            items: _units
                .map((unit) => DropdownMenuItem(value: unit, child: Text(unit)))
                .toList(),
          ),
        ],
      ),
    );
  }

  // ── Status Card ────────────────────────────────────────────────────────────
  Widget _buildStatusCard() {
    final activeColor = _isActive ? _T.success : _T.warning;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(context.isMobile ? 16 : 20),
      decoration: _T.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            title: 'Product Status',
            subtitle: 'Visibility and operational state',
            icon: Icons.toggle_on_rounded,
          ),
          const SizedBox(height: 20),
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: activeColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: activeColor.withOpacity(0.18)),
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: activeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(
                    _isActive
                        ? Icons.check_circle_rounded
                        : Icons.pause_circle_rounded,
                    color: activeColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isActive ? 'Product Active' : 'Product Inactive',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: _T.textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _isActive
                            ? 'Visible in product listings'
                            : 'Hidden from listings',
                        style: const TextStyle(
                          fontSize: 12,
                          color: _T.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _isActive,
                  onChanged: (value) => setState(() => _isActive = value),
                  activeColor: _T.gradientStart,
                  activeTrackColor: _T.gradientStart.withOpacity(0.25),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Action Buttons ─────────────────────────────────────────────────────────
  Widget _buildActionButtons(BuildContext context) {
    final provider = context.read<ProductProvider>();

    final cancelBtn = _PressableIconButton(
      onTap: () => context.pop(),
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          color: _T.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _T.divider, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1E2A6E).withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: const Center(
          child: Text(
            'Cancel',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: _T.textMid,
            ),
          ),
        ),
      ),
    );

    final saveBtn = _PressableIconButton(
      onTap: () => _submitForm(provider),
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          gradient: _isSaving ? null : _T.brandGradient,
          color: _isSaving ? Colors.grey.shade400 : null,
          borderRadius: BorderRadius.circular(14),
          boxShadow: _isSaving
              ? null
              : [
                  BoxShadow(
                    color: _T.gradientStart.withOpacity(0.28),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        child: Center(
          child: _isSaving
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _isEditMode ? Icons.save_rounded : Icons.add_circle_rounded,
                      color: _T.white,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isEditMode ? 'Update Product' : 'Create Product',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: _T.white,
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
          saveBtn,
          const SizedBox(height: 12),
          cancelBtn,
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: cancelBtn),
        const SizedBox(width: 16),
        Expanded(flex: 2, child: saveBtn),
      ],
    );
  }

  // ── Section Header ─────────────────────────────────────────────────────────
  Widget _buildSectionHeader({
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
          child: Icon(icon, color: _T.white, size: 18),
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

  // ── Dropdown Decoration ────────────────────────────────────────────────────
  InputDecoration _dropdownDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: _T.white,
      prefixIcon: Icon(icon, color: _T.textMuted, size: 20),
      labelStyle: const TextStyle(color: _T.textMuted, fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
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
        borderSide: const BorderSide(color: _T.gradientStart, width: 1.5),
      ),
    );
  }

  // ── Image Picker ───────────────────────────────────────────────────────────
  Future<void> _pickImage(ImageSource source) async {
    try {
      setState(() => _imageLoading = true);
      final String? path = source == ImageSource.camera
          ? await _imageService.pickFromCamera()
          : await _imageService.pickFromGallery();
      if (path != null && path.trim().isNotEmpty) {
        if (!mounted) return;
        setState(() => _imagePath = path);
        if (mounted) context.showSnackBar('Product image uploaded successfully');
      }
    } catch (e) {
      if (mounted) context.showSnackBar('Failed to upload image: $e', isError: true);
    } finally {
      if (mounted) setState(() => _imageLoading = false);
    }
  }

  // ── Submit ─────────────────────────────────────────────────────────────────
  Future<void> _submitForm(ProductProvider provider) async {
    if (_isSaving) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final name     = _nameController.text.trim();
      final hsn      = _hsnController.text.trim().isEmpty ? null : _hsnController.text.trim();
      final price    = double.parse(_priceController.text);
      final stock    = int.parse(_stockController.text);
      final minStock = int.parse(_minStockController.text);
      final desc     = _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim();

      if (_isEditMode) {
        await provider.updateProduct(
          id: widget.productId!,
          productName: name,
          hsnCode: hsn,
          price: price,
          stockQuantity: stock,
          description: desc,
          imagePath: _imagePath,
          minStockLevel: minStock,
          unit: _selectedUnit,
          isActive: _isActive,
        );
      } else {
        await provider.createProduct(
          productName: name,
          hsnCode: hsn,
          price: price,
          stockQuantity: stock,
          description: desc,
          imagePath: _imagePath,
          minStockLevel: minStock,
          unit: _selectedUnit,
        );
      }

      if (!mounted) return;

      context.showSnackBar(
        _isEditMode ? 'Product updated successfully' : 'Product added successfully',
      );

      _nameController.clear();
      _hsnController.clear();
      _priceController.clear();
      _stockController.clear();
      _minStockController.clear();
      _descriptionController.clear();

      context.go(AppRoutes.products);
    } catch (e) {
      if (mounted) {
        context.showSnackBar('Failed to save product: $e', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}

// ── Pressable Icon Button (micro-interaction) ─────────────────────────────────
class _PressableIconButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _PressableIconButton({required this.child, required this.onTap});

  @override
  State<_PressableIconButton> createState() => _PressableIconButtonState();
}

class _PressableIconButtonState extends State<_PressableIconButton> {
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
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
