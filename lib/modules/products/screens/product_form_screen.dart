import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:smarterp/core/constants/app_constants.dart';
import 'package:smarterp/core/extensions/context_extensions.dart';
import 'package:smarterp/core/theme/theme_extensions.dart';
import 'package:smarterp/core/widgets/app_shell.dart';
import 'package:smarterp/core/widgets/app_card.dart';
import 'package:smarterp/core/widgets/app_text_field.dart';
import 'package:smarterp/core/widgets/app_button.dart';
import 'package:smarterp/core/models/product_model.dart';
import 'package:smarterp/core/services/image_service.dart';
import 'package:smarterp/modules/products/providers/product_provider.dart';

class ProductFormScreen extends StatefulWidget {
  final String? productId;

  const ProductFormScreen({
    super.key,
    this.productId,
  });

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _imageService = ImageService();

  // Controllers
  late TextEditingController _nameController;
  late TextEditingController _hsnController;
  late TextEditingController _priceController;
  late TextEditingController _costPriceController;
  late TextEditingController _stockController;
  late TextEditingController _minStockController;
  late TextEditingController _skuController;
  late TextEditingController _barcodeController;
  late TextEditingController _descriptionController;

  // Selected values
  String? _selectedCategory;
  double _selectedGstRate = 18.0;
  String _selectedUnit = 'Piece';
  String? _imagePath;
  bool _isActive = true;
  bool _isEditMode = false;
  ProductModel? _existingProduct;

  final List<String> _categories = [
    'Building Materials',
    'Steel',
    'Tiles',
    'Electrical',
    'Paints',
    'Plumbing',
    'Hardware',
    'Other'
  ];

  final List<double> _gstRates = [0.0, 5.0, 12.0, 18.0, 28.0];
  final List<String> _units = ['Piece', 'Bag', 'Kg', 'Ton', 'Box', 'Liter', 'Meter', 'Box'];

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.productId != null;

    _nameController = TextEditingController();
    _hsnController = TextEditingController();
    _priceController = TextEditingController();
    _costPriceController = TextEditingController();
    _stockController = TextEditingController();
    _minStockController = TextEditingController();
    _skuController = TextEditingController();
    _barcodeController = TextEditingController();
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
      setState(() {
        _existingProduct = product;
        _nameController.text = product.productName;
        _hsnController.text = product.hsnCode ?? '';
        _priceController.text = product.price.toString();
        _costPriceController.text = product.costPrice.toString();
        _stockController.text = product.stockQuantity.toString();
        _minStockController.text = product.minStockLevel.toString();
        _skuController.text = product.sku ?? '';
        _barcodeController.text = product.barcode ?? '';
        _descriptionController.text = product.description ?? '';
        
        _selectedCategory = _categories.contains(product.category) ? product.category : 'Other';
        _selectedGstRate = _gstRates.contains(product.gstRate) ? product.gstRate : 18.0;
        _selectedUnit = _units.contains(product.unit) ? product.unit : 'Piece';
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
    _costPriceController.dispose();
    _stockController.dispose();
    _minStockController.dispose();
    _skuController.dispose();
    _barcodeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final theme = context.theme;

    return AppShell(
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFormHeader(context),
              const SizedBox(height: 24),
              if (context.isDesktop)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 4,
                      child: Column(
                        children: [
                          _buildImagePickerCard(),
                          const SizedBox(height: 16),
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
                          const SizedBox(height: 16),
                          _buildPricingCard(),
                          const SizedBox(height: 16),
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
                    const SizedBox(height: 16),
                    _buildGeneralInfoCard(),
                    const SizedBox(height: 16),
                    _buildPricingCard(),
                    const SizedBox(height: 16),
                    _buildInventoryCard(),
                    const SizedBox(height: 16),
                    _buildStatusCard(),
                  ],
                ),
              const SizedBox(height: 32),
              _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormHeader(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        const SizedBox(width: 8),
        Text(
          _isEditMode ? 'Modify Product Specifications' : 'Enter Product Information',
          style: context.textTheme.titleMedium?.copyWith(
            color: context.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePickerCard() {
    final colorScheme = context.colorScheme;
    final hasImage = _imagePath != null && _imagePath!.isNotEmpty;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Product Image',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: colorScheme.surfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
              child: hasImage
                  ? File(_imagePath!).existsSync()
                      ? Image.file(
                          File(_imagePath!),
                          fit: BoxFit.cover,
                          width: double.infinity,
                        )
                      : _buildImagePlaceholder()
                  : _buildImagePlaceholder(),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Camera'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Gallery'),
                ),
              ),
            ],
          ),
          if (hasImage) ...[
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _imagePath = null;
                });
              },
              icon: Icon(Icons.delete_outline, color: colorScheme.error, size: 18),
              label: Text('Remove Image', style: TextStyle(color: colorScheme.error)),
              style: TextButton.styleFrom(
                minimumSize: const Size(double.infinity, 36),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    final colorScheme = context.colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_photo_alternate_outlined,
            size: 48,
            color: colorScheme.onSurfaceVariant.withOpacity(0.5),
          ),
          const SizedBox(height: 12),
          Text(
            'Upload a product image',
            style: TextStyle(
              fontSize: 13,
              color: colorScheme.onSurfaceVariant.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneralInfoCard() {
    final colorScheme = context.colorScheme;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'General Information',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
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
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'Category *',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
              ),
              prefixIcon: const Icon(Icons.category_outlined),
            ),
            value: _selectedCategory,
            hint: const Text('Select Category'),
            validator: (value) => value == null ? 'Category is required' : null,
            onChanged: (value) {
              setState(() {
                _selectedCategory = value;
              });
            },
            items: _categories.map((cat) {
              return DropdownMenuItem(
                value: cat,
                child: Text(cat),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: _hsnController,
            label: 'HSN Code',
            hintText: 'e.g. 25232910',
            prefixIcon: const Icon(Icons.tag),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                final digits = RegExp(r'^\d+$');
                if (!digits.hasMatch(value)) {
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
            label: 'Product Description',
            hintText: 'Describe physical properties, grades, packaging...',
            prefixIcon: const Icon(Icons.description_outlined),
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildPricingCard() {
    final colorScheme = context.colorScheme;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pricing details',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  controller: _costPriceController,
                  label: 'Cost Price *',
                  hintText: '0.00',
                  prefixIcon: const Icon(Icons.payments_outlined),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Cost Price is required';
                    }
                    final val = double.tryParse(value);
                    if (val == null || val < 0) {
                      return 'Must be >= 0';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AppTextField(
                  controller: _priceController,
                  label: 'Selling Price (Excl. GST) *',
                  hintText: '0.00',
                  prefixIcon: const Icon(Icons.sell_outlined),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Selling Price is required';
                    }
                    final val = double.tryParse(value);
                    if (val == null || val <= 0) {
                      return 'Must be > 0';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<double>(
            decoration: InputDecoration(
              labelText: 'GST Rate *',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
              ),
              prefixIcon: const Icon(Icons.percent),
            ),
            value: _selectedGstRate,
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedGstRate = value;
                });
              }
            },
            items: _gstRates.map((rate) {
              return DropdownMenuItem(
                value: rate,
                child: Text('${rate.toStringAsFixed(0)}%'),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryCard() {
    final colorScheme = context.colorScheme;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Inventory & Packaging',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  controller: _stockController,
                  label: 'Current Stock *',
                  hintText: '0',
                  prefixIcon: const Icon(Icons.inventory_outlined),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                    final val = int.tryParse(value);
                    if (val == null || val < 0) {
                      return 'Must be >= 0';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AppTextField(
                  controller: _minStockController,
                  label: 'Min Reorder Threshold *',
                  hintText: '0',
                  prefixIcon: const Icon(Icons.notifications_active_outlined),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                    final val = int.tryParse(value);
                    if (val == null || val < 0) {
                      return 'Must be >= 0';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Stock Unit *',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                    ),
                    prefixIcon: const Icon(Icons.scale_outlined),
                  ),
                  value: _selectedUnit,
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
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AppTextField(
                  controller: _skuController,
                  label: 'SKU Code',
                  hintText: 'e.g. CEM-OPC-53',
                  prefixIcon: const Icon(Icons.qr_code_outlined),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: _barcodeController,
            label: 'Barcode',
            hintText: 'e.g. 890123456001',
            prefixIcon: const Icon(Icons.qr_code_scanner),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    final colorScheme = context.colorScheme;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Product Status',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Is Active'),
            subtitle: const Text('Inactive products are hidden from lists'),
            value: _isActive,
            onChanged: (value) {
              setState(() {
                _isActive = value;
              });
            },
            activeColor: colorScheme.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final provider = context.read<ProductProvider>();

    return Row(
      children: [
        Expanded(
          child: AppButton(
            text: 'Cancel',
            variant: AppButtonVariant.outline,
            onPressed: () => context.pop(),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: AppButton(
            text: _isEditMode ? 'Update Product' : 'Create Product',
            variant: AppButtonVariant.primary,
            onPressed: () => _submitForm(provider),
          ),
        ),
      ],
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final String? path = source == ImageSource.camera
        ? await _imageService.pickFromCamera()
        : await _imageService.pickFromGallery();

    if (path != null) {
      setState(() {
        _imagePath = path;
      });
    }
  }

  Future<void> _submitForm(ProductProvider provider) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      final name = _nameController.text.trim();
      final hsn = _hsnController.text.trim().isEmpty ? null : _hsnController.text.trim();
      final price = double.parse(_priceController.text);
      final costPrice = double.parse(_costPriceController.text);
      final stock = int.parse(_stockController.text);
      final minStock = int.parse(_minStockController.text);
      final sku = _skuController.text.trim().isEmpty ? null : _skuController.text.trim();
      final barcode = _barcodeController.text.trim().isEmpty ? null : _barcodeController.text.trim();
      final desc = _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim();

      if (_isEditMode) {
        await provider.updateProduct(
          id: widget.productId!,
          productName: name,
          hsnCode: hsn,
          price: price,
          stockQuantity: stock,
          gstRate: _selectedGstRate,
          description: desc,
          imagePath: _imagePath,
          category: _selectedCategory!,
          costPrice: costPrice,
          minStockLevel: minStock,
          unit: _selectedUnit,
          sku: sku,
          barcode: barcode,
          isActive: _isActive,
        );
        if (mounted) {
          context.showSnackBar('Product updated successfully');
          context.pop();
        }
      } else {
        await provider.createProduct(
          productName: name,
          hsnCode: hsn,
          price: price,
          stockQuantity: stock,
          gstRate: _selectedGstRate,
          description: desc,
          imagePath: _imagePath,
          category: _selectedCategory!,
          costPrice: costPrice,
          minStockLevel: minStock,
          unit: _selectedUnit,
          sku: sku,
          barcode: barcode,
        );
        if (mounted) {
          context.showSnackBar('Product created successfully');
          context.pop();
        }
      }
    } catch (e) {
      context.showSnackBar('Failed to save product: $e', isError: true);
    }
  }
}
