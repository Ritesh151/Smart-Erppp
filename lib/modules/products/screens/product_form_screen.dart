import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:SmartERP/core/constants/app_constants.dart';
import 'package:SmartERP/core/extensions/context_extensions.dart';
import 'package:SmartERP/core/models/product_model.dart';
import 'package:SmartERP/core/services/image_service.dart';
import 'package:SmartERP/core/theme/theme_extensions.dart';
import 'package:SmartERP/core/utils/platform_image_provider.dart';
import 'package:SmartERP/core/widgets/app_button.dart';
import 'package:SmartERP/core/widgets/app_text_field.dart';
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
    double radius = 18,
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
          blurRadius: 18,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }
}

class ProductFormScreen extends StatefulWidget {
  final String? productId;

  const ProductFormScreen({
    super.key,
    this.productId,
  });

  @override
  State<ProductFormScreen> createState() =>
      _ProductFormScreenState();
}

class _ProductFormScreenState
    extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _imageService = ImageService();

  late TextEditingController _nameController;
  late TextEditingController _hsnController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;
  late TextEditingController _minStockController;
  late TextEditingController _descriptionController;

  String _selectedUnit = 'Piece';

  String? _imagePath;

  bool _isActive = true;

  bool _isEditMode = false;

  ProductModel? _existingProduct;

  bool _imageLoading = false;

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

    _nameController = TextEditingController();
    _hsnController = TextEditingController();
    _priceController = TextEditingController();
    _stockController = TextEditingController();
    _minStockController = TextEditingController();
    _descriptionController = TextEditingController();

    if (_isEditMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadExistingProduct();
      });
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
        _existingProduct = product;

        _nameController.text = product.productName;
        _hsnController.text = product.hsnCode ?? '';
        _priceController.text = product.price.toString();
        _stockController.text =
            product.stockQuantity.toString();

        _minStockController.text =
            product.minStockLevel.toString();

        _descriptionController.text =
            product.description ?? '';

        _selectedUnit = _units.contains(product.unit)
            ? product.unit
            : 'Piece';

        _imagePath = product.imagePath;

        _isActive = product.isActive;
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

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _T.bg,
      child: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(
              context.isMobile ? 16 : 24,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                _buildFormHeader(context)
                    .animate()
                    .fadeIn(duration: 260.ms)
                    .slideX(begin: -0.05, end: 0),

                SizedBox(
                  height: context.isMobile ? 18 : 24,
                ),

                if (context.isDesktop)
                  Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 4,
                        child: Column(
                          children: [
                            _buildImagePickerCard(),

                            const SizedBox(height: 18),

                            _buildStatusCard(),
                          ],
                        ),
                      ),

                      const SizedBox(width: 24),

                      Expanded(
                        flex: 6,
                        child: Column(
                          children: [
                            _buildGeneralInfoCard(),

                            const SizedBox(height: 18),

                            _buildPricingCard(),

                            const SizedBox(height: 18),

                            _buildInventoryCard(),
                          ],
                        ),
                      ),
                    ],
                  )
                else
                  Column(
                    children: [
                      _buildImagePickerCard(),

                      const SizedBox(height: 18),

                      _buildGeneralInfoCard(),

                      const SizedBox(height: 18),

                      _buildPricingCard(),

                      const SizedBox(height: 18),

                      _buildInventoryCard(),

                      const SizedBox(height: 18),

                      _buildStatusCard(),
                    ],
                  ),

                const SizedBox(height: 30),

                _buildActionButtons(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormHeader(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final vertical = constraints.maxWidth < 620;

        if (vertical) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  InkWell(
                    borderRadius:
                        BorderRadius.circular(14),
                    onTap: () => context.pop(),
                    child: Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(14),
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
                          _isEditMode
                              ? 'Update Product'
                              : 'Create Product',
                          style: TextStyle(
                            fontSize: context.isMobile
                                ? 24
                                : 28,
                            fontWeight:
                                FontWeight.w800,
                            color: _T.textDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _isEditMode
                              ? 'Modify product specifications and inventory details.'
                              : 'Enter product information and inventory specifications.',
                          style: const TextStyle(
                            fontSize: 13,
                            color: _T.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(14),
                  border: Border.all(
                    color: _T.divider,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: _T.success,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isEditMode
                          ? 'Editing Mode'
                          : 'New Product',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: _T.textDark,
                      ),
                    ),
                  ],
                ),
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
                    onTap: () => context.pop(),
                    child: Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(14),
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
                          _isEditMode
                              ? 'Update Product'
                              : 'Create Product',
                          style: TextStyle(
                            fontSize: context.isMobile
                                ? 24
                                : 28,
                            fontWeight:
                                FontWeight.w800,
                            color: _T.textDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _isEditMode
                              ? 'Modify product specifications and inventory details.'
                              : 'Enter product information and inventory specifications.',
                          style: const TextStyle(
                            fontSize: 13,
                            color: _T.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 18),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(14),
                border: Border.all(
                  color: _T.divider,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: _T.success,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isEditMode
                        ? 'Editing Mode'
                        : 'New Product',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: _T.textDark,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildImagePickerCard() {
    final hasImage =
        _imagePath != null &&
            _imagePath!.trim().isNotEmpty;

    final imageProvider = hasImage
        ? platformImageProvider(_imagePath!)
        : null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _T.card(),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            title: 'Product Image',
            subtitle:
                'Upload high quality product visuals',
            icon: Icons.image_rounded,
          ),

          const SizedBox(height: 20),

          AnimatedContainer(
            duration:
                const Duration(milliseconds: 220),
            height: context.isMobile ? 240 : 320,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _T.gradientStart.withOpacity(0.06),
                  _T.gradientEnd.withOpacity(0.03),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius:
                  BorderRadius.circular(22),
              border: Border.all(
                color: _T.divider,
              ),
            ),
            child: ClipRRect(
              borderRadius:
                  BorderRadius.circular(22),
              child: hasImage &&
                      imageProvider != null
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        Image(
                          image: imageProvider,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (_, __, ___) =>
                                  _buildImagePlaceholder(),
                          loadingBuilder: (
                            context,
                            child,
                            loadingProgress,
                          ) {
                            if (loadingProgress ==
                                null) {
                              return child;
                            }

                            return Container(
                              color: Colors.white,
                              child: const Center(
                                child:
                                    CircularProgressIndicator(
                                  color:
                                      _T.gradientStart,
                                ),
                              ),
                            );
                          },
                        ),

                        Positioned(
                          top: 12,
                          right: 12,
                          child: Container(
                            padding:
                                const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black
                                  .withOpacity(0.55),
                              borderRadius:
                                  BorderRadius.circular(
                                      20),
                            ),
                            child: const Row(
                              mainAxisSize:
                                  MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  size: 14,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 5),
                                Text(
                                  'Image Ready',
                                  style: TextStyle(
                                    color: Colors.white,
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
                  : _buildImagePlaceholder(),
            ),
          ),

          const SizedBox(height: 18),

          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _imageButton(
                label: 'Camera',
                icon: Icons.camera_alt_rounded,
                color: _T.gradientStart,
                onTap: () {
                  _pickImage(ImageSource.camera);
                },
              ),

              _imageButton(
                label: 'Gallery',
                icon: Icons.photo_library_rounded,
                color: _T.gradientEnd,
                onTap: () {
                  _pickImage(ImageSource.gallery);
                },
              ),

              if (hasImage)
                _imageButton(
                  label: 'Remove',
                  icon: Icons.delete_outline,
                  color: _T.danger,
                  onTap: () {
                    setState(() {
                      _imagePath = null;
                    });
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _imageButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 14,
        ),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: color.withOpacity(0.15),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: color,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _T.gradientStart.withOpacity(0.12),
                    _T.gradientEnd.withOpacity(0.08),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add_photo_alternate_outlined,
                size: 42,
                color: _T.gradientStart,
              ),
            ),

            const SizedBox(height: 18),

            const Text(
              'Upload Product Image',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: _T.textDark,
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              'Supports camera & gallery uploads',
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

  Widget _buildGeneralInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _T.card(),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            title: 'General Information',
            subtitle:
                'Basic product identity and classification',
            icon: Icons.inventory_2_rounded,
          ),

          const SizedBox(height: 22),

          AppTextField(
            controller: _nameController,
            label: 'Product Name *',
            hintText:
                'e.g. Portland Cement Grade 53',
            prefixIcon: const Icon(
              Icons.shopping_bag_outlined,
            ),
            validator: (value) {
              if (value == null ||
                  value.trim().isEmpty) {
                return 'Product name is required';
              }

              if (value.trim().length < 2) {
                return 'Name must be at least 2 characters';
              }

              return null;
            },
          ),

          const SizedBox(height: 18),

          AppTextField(
            controller: _hsnController,
            label: 'HSN Code',
            hintText: 'e.g. 25232910',
            prefixIcon: const Icon(Icons.tag),
            keyboardType:
                TextInputType.number,
            validator: (value) {
              if (value != null &&
                  value.isNotEmpty) {
                final digits =
                    RegExp(r'^\d+$');

                if (!digits.hasMatch(value)) {
                  return 'HSN must contain digits only';
                }

                if (value.length < 4 ||
                    value.length > 8) {
                  return 'HSN must be 4 to 8 digits long';
                }
              }

              return null;
            },
          ),

          const SizedBox(height: 18),

          AppTextField(
            controller:
                _descriptionController,
            label: 'Description',
            hintText:
                'Describe material properties, packaging, usage...',
            prefixIcon: const Icon(
              Icons.description_outlined,
            ),
            maxLines: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildPricingCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _T.card(),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            title: 'Pricing Details',
            subtitle:
                'Commercial pricing configuration',
            icon: Icons.currency_rupee_rounded,
          ),

          const SizedBox(height: 22),

          AppTextField(
            controller: _priceController,
            label: 'Selling Price *',
            hintText: '0.00',
            prefixIcon: const Icon(
              Icons.sell_outlined,
            ),
            keyboardType:
                const TextInputType.numberWithOptions(
              decimal: true,
            ),
            validator: (value) {
              if (value == null ||
                  value.isEmpty) {
                return 'Selling Price is required';
              }

              final val =
                  double.tryParse(value);

              if (val == null || val <= 0) {
                return 'Must be > 0';
              }

              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _T.card(),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            title: 'Inventory & Packaging',
            subtitle:
                'Stock levels and packaging configuration',
            icon: Icons.inventory_outlined,
          ),

          const SizedBox(height: 22),

          LayoutBuilder(
            builder: (context, constraints) {
              final vertical =
                  constraints.maxWidth < 700;

              if (vertical) {
                return Column(
                  children: [
                    AppTextField(
                      controller:
                          _stockController,
                      label:
                          'Current Stock *',
                      hintText: '0',
                      prefixIcon: const Icon(
                        Icons.inventory_2_outlined,
                      ),
                      keyboardType:
                          TextInputType.number,
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty) {
                          return 'Required';
                        }

                        final val =
                            int.tryParse(
                                value);

                        if (val == null ||
                            val < 0) {
                          return 'Must be >= 0';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 18),
                    AppTextField(
                      controller:
                          _minStockController,
                      label:
                          'Min Reorder Threshold *',
                      hintText: '0',
                      prefixIcon: const Icon(
                        Icons
                            .notifications_active_outlined,
                      ),
                      keyboardType:
                          TextInputType.number,
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty) {
                          return 'Required';
                        }

                        final val =
                            int.tryParse(
                                value);

                        if (val == null ||
                            val < 0) {
                          return 'Must be >= 0';
                        }

                        return null;
                      },
                    ),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      controller:
                          _stockController,
                      label:
                          'Current Stock *',
                      hintText: '0',
                      prefixIcon: const Icon(
                        Icons.inventory_2_outlined,
                      ),
                      keyboardType:
                          TextInputType.number,
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty) {
                          return 'Required';
                        }

                        final val =
                            int.tryParse(
                                value);

                        if (val == null ||
                            val < 0) {
                          return 'Must be >= 0';
                        }

                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: AppTextField(
                      controller:
                          _minStockController,
                      label:
                          'Min Reorder Threshold *',
                      hintText: '0',
                      prefixIcon: const Icon(
                        Icons
                            .notifications_active_outlined,
                      ),
                      keyboardType:
                          TextInputType.number,
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty) {
                          return 'Required';
                        }

                        final val =
                            int.tryParse(
                                value);

                        if (val == null ||
                            val < 0) {
                          return 'Must be >= 0';
                        }

                        return null;
                      },
                    ),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 18),

          DropdownButtonFormField<String>(
            value: _selectedUnit,
            borderRadius:
                BorderRadius.circular(16),
            decoration: _inputDecoration(
              'Stock Unit *',
              Icons.scale_outlined,
            ),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedUnit = value;
                });
              }
            },
            items: _units.map((unit) {
              return DropdownMenuItem(
                value: unit,
                child: Text(unit),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _T.card(),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            title: 'Product Status',
            subtitle:
                'Visibility and operational state',
            icon: Icons.toggle_on_rounded,
          ),

          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _isActive
                  ? _T.success.withOpacity(0.06)
                  : _T.warning.withOpacity(0.06),
              borderRadius:
                  BorderRadius.circular(16),
              border: Border.all(
                color: (_isActive
                        ? _T.success
                        : _T.warning)
                    .withOpacity(0.15),
              ),
            ),
            child: SwitchListTile(
              contentPadding:
                  EdgeInsets.zero,
              title: Text(
                _isActive
                    ? 'Product Active'
                    : 'Product Inactive',
                style: const TextStyle(
                  fontWeight:
                      FontWeight.w700,
                ),
              ),
              subtitle: Text(
                _isActive
                    ? 'Visible in product listings'
                    : 'Hidden from listings',
              ),
              value: _isActive,
              onChanged: (value) {
                setState(() {
                  _isActive = value;
                });
              },
              activeColor:
                  _T.gradientStart,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
      BuildContext context) {
    final provider =
        context.read<ProductProvider>();

    return LayoutBuilder(
      builder: (context, constraints) {
        final vertical =
            constraints.maxWidth < 520;

        if (vertical) {
          return Column(
            children: [
              SizedBox(
                height: 54,
                child: AppButton(
                  text: 'Cancel',
                  variant:
                      AppButtonVariant.outline,
                  onPressed: () {
                    context.pop();
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
                          .withOpacity(0.22),
                      blurRadius: 16,
                      offset:
                          const Offset(0, 6),
                    ),
                  ],
                ),
                child: SizedBox(
                  height: 54,
                  child: AppButton(
                    text: _isEditMode
                        ? 'Update Product'
                        : 'Create Product',
                    variant:
                        AppButtonVariant.primary,
                    onPressed: () {
                      _submitForm(provider);
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
                  text: 'Cancel',
                  variant:
                      AppButtonVariant.outline,
                  onPressed: () {
                    context.pop();
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
                          .withOpacity(0.22),
                      blurRadius: 16,
                      offset:
                          const Offset(0, 6),
                    ),
                  ],
                ),
                child: SizedBox(
                  height: 54,
                  child: AppButton(
                    text: _isEditMode
                        ? 'Update Product'
                        : 'Create Product',
                    variant:
                        AppButtonVariant.primary,
                    onPressed: () {
                      _submitForm(provider);
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

  Widget _buildSectionHeader({
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

  InputDecoration _inputDecoration(
    String label,
    IconData icon,
  ) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(16),
        borderSide: BorderSide(
          color: _T.divider,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(16),
        borderSide: BorderSide(
          color: _T.divider,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: _T.gradientStart,
          width: 1.4,
        ),
      ),
    );
  }

  Future<void> _pickImage(
      ImageSource source) async {
    try {
      setState(() {
        _imageLoading = true;
      });

      final String? path =
          source == ImageSource.camera
              ? await _imageService
                  .pickFromCamera()
              : await _imageService
                  .pickFromGallery();

      if (path != null &&
          path.trim().isNotEmpty) {
        setState(() {
          _imagePath = path;
        });

        if (mounted) {
          context.showSnackBar(
            'Product image uploaded successfully',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        context.showSnackBar(
          'Failed to upload image: $e',
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _imageLoading = false;
        });
      }
    }
  }

  Future<void> _submitForm(
    ProductProvider provider,
  ) async {
    if (!_formKey.currentState!
        .validate()) {
      return;
    }

    try {
      final name =
          _nameController.text.trim();

      final hsn =
          _hsnController.text.trim().isEmpty
              ? null
              : _hsnController.text.trim();

      final price = double.parse(
        _priceController.text,
      );

      final stock = int.parse(
        _stockController.text,
      );

      final minStock = int.parse(
        _minStockController.text,
      );

      final desc =
          _descriptionController.text
                  .trim()
                  .isEmpty
              ? null
              : _descriptionController.text
                  .trim();

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

      if (mounted) {
        context.showSnackBar(
          _isEditMode
              ? 'Product updated successfully'
              : 'Product added successfully',
        );

        context.pop();
      }
    } catch (e) {
      if (mounted) {
        context.showSnackBar(
          'Failed to save product: $e',
          isError: true,
        );
      }
    }
  }
}
