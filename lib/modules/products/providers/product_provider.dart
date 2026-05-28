import 'package:flutter/foundation.dart';
import 'package:SmartERP/core/exceptions/app_exception.dart';
import 'package:SmartERP/core/models/product_model.dart';
import 'package:SmartERP/core/utils/logger.dart';
import 'package:SmartERP/modules/products/services/product_service.dart';
import 'package:SmartERP/modules/products/services/product_seed_service.dart';

class ProductProvider extends ChangeNotifier {
  final ProductService _service;
  final ProductSeedService _seedService;
  bool _initialized = false;
  VoidCallback? onDataChanged;

  ProductProvider(this._service, this._seedService, {VoidCallback? onDataChanged})
      : onDataChanged = onDataChanged;

  List<ProductModel> _products = [];
  List<ProductModel> _filteredProducts = [];
  ProductModel? _selectedProduct;

  bool _isLoading = false;
  bool _isSearching = false;
  String? _errorMessage;
  String _searchQuery = '';
  StockStatus? _selectedStockStatus;
  ProductSortOption _sortOption = ProductSortOption.name;
  bool _sortAscending = true;

  List<ProductModel> get products => _filteredProducts.isEmpty && _searchQuery.isEmpty
      ? _products
      : _filteredProducts;
  
  ProductModel? get selectedProduct => _selectedProduct;
  bool get isLoading => _isLoading;
  bool get isSearching => _isSearching;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  StockStatus? get selectedStockStatus => _selectedStockStatus;
  ProductSortOption get sortOption => _sortOption;
  bool get sortAscending => _sortAscending;

  int get totalProducts => _products.length;
  int get lowStockCount => _products.where((p) => p.isLowStock).length;
  int get outOfStockCount => _products.where((p) => p.isOutOfStock).length;
  double get totalInventoryValue =>
      _products.fold(0.0, (sum, p) => sum + p.inventoryValue);

  Future<void> initializeProducts() async {
    if (_initialized) return;
    _initialized = true;

    try {
      await _seedService.seedProducts();
      await loadProducts();
    } catch (e, stackTrace) {
      Logger.error('Failed to initialize products', e, stackTrace);
      _initialized = false;
    }
  }

  Future<void> loadProducts() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _products = await _service.getAllProducts();
      _applyFiltersAndSort();

      _isLoading = false;
      notifyListeners();
      onDataChanged?.call();
      Logger.success('Products loaded: ${_products.length}');
    } catch (e, stackTrace) {
      _isLoading = false;
      _errorMessage = 'Failed to load products';
      notifyListeners();
      Logger.error('Failed to load products', e, stackTrace);
    }
  }

  Future<void> createProduct({
    required String productName,
    String? hsnCode,
    required double price,
    required int stockQuantity,
    String? description,
    String? imagePath,
    required int minStockLevel,
    required String unit,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final product = await _service.createProduct(
        productName: productName,
        hsnCode: hsnCode,
        price: price,
        stockQuantity: stockQuantity,
        description: description,
        imagePath: imagePath,
        minStockLevel: minStockLevel,
        unit: unit,
      );

      _products.add(product);
      _applyFiltersAndSort();

      _isLoading = false;
      notifyListeners();
      onDataChanged?.call();
      Logger.success('Product created successfully');
    } on ValidationException catch (e) {
      _isLoading = false;
      _errorMessage = e.message;
      notifyListeners();
      rethrow;
    } catch (e, stackTrace) {
      _isLoading = false;
      _errorMessage = 'Failed to create product';
      notifyListeners();
      Logger.error('Failed to create product', e, stackTrace);
      rethrow;
    }
  }

  Future<void> updateProduct({
    required String id,
    required String productName,
    String? hsnCode,
    required double price,
    required int stockQuantity,
    String? description,
    String? imagePath,
    required int minStockLevel,
    required String unit,
    required bool isActive,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final updatedProduct = await _service.updateProduct(
        id: id,
        productName: productName,
        hsnCode: hsnCode,
        price: price,
        stockQuantity: stockQuantity,
        description: description,
        imagePath: imagePath,
        minStockLevel: minStockLevel,
        unit: unit,
        isActive: isActive,
      );

      final index = _products.indexWhere((p) => p.id == id);
      if (index != -1) {
        _products[index] = updatedProduct;
        _applyFiltersAndSort();
      }

      _isLoading = false;
      notifyListeners();
      onDataChanged?.call();
      Logger.success('Product updated successfully');
    } on ValidationException catch (e) {
      _isLoading = false;
      _errorMessage = e.message;
      notifyListeners();
      rethrow;
    } catch (e, stackTrace) {
      _isLoading = false;
      _errorMessage = 'Failed to update product';
      notifyListeners();
      Logger.error('Failed to update product', e, stackTrace);
      rethrow;
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _service.deleteProduct(id);
      _products.removeWhere((p) => p.id == id);
      _applyFiltersAndSort();

      if (_selectedProduct?.id == id) {
        _selectedProduct = null;
      }

      _isLoading = false;
      notifyListeners();
      onDataChanged?.call();
      Logger.success('Product deleted successfully');
    } catch (e, stackTrace) {
      _isLoading = false;
      _errorMessage = 'Failed to delete product';
      notifyListeners();
      Logger.error('Failed to delete product', e, stackTrace);
      rethrow;
    }
  }

  Future<void> searchProducts(String query) async {
    try {
      _isSearching = true;
      _searchQuery = query;
      notifyListeners();

      if (query.trim().isEmpty) {
        _filteredProducts = [];
      } else {
        _filteredProducts = await _service.searchProducts(query);
        _filteredProducts = _service.sortProducts(
          _filteredProducts,
          _sortOption,
          _sortAscending,
        );
      }

      _isSearching = false;
      notifyListeners();
    } catch (e, stackTrace) {
      _isSearching = false;
      notifyListeners();
      Logger.error('Failed to search products', e, stackTrace);
    }
  }

  void clearSearch() {
    _searchQuery = '';
    _filteredProducts = [];
    _applyFiltersAndSort();
    notifyListeners();
  }

  Future<void> filterByStockStatus(StockStatus? status) async {
    _selectedStockStatus = status;
    _applyFiltersAndSort();
    notifyListeners();
  }

  void setSortOption(ProductSortOption option, bool ascending) {
    _sortOption = option;
    _sortAscending = ascending;
    _applyFiltersAndSort();
    notifyListeners();
  }

  void clearFilters() {
    _selectedStockStatus = null;
    _searchQuery = '';
    _filteredProducts = [];
    _applyFiltersAndSort();
    notifyListeners();
  }

  void selectProduct(ProductModel? product) {
    _selectedProduct = product;
    notifyListeners();
  }

  Future<void> updateStock(String id, int newQuantity) async {
    try {
      await _service.updateStock(id, newQuantity);
      await loadProducts();
    } catch (e, stackTrace) {
      _errorMessage = 'Failed to update stock';
      notifyListeners();
      Logger.error('Failed to update stock', e, stackTrace);
      rethrow;
    }
  }

  void _applyFiltersAndSort() {
    var filtered = List<ProductModel>.from(_products);

    if (_selectedStockStatus != null) {
      filtered = filtered.where((p) => p.stockStatus == _selectedStockStatus).toList();
    }

    _filteredProducts = _service.sortProducts(
      filtered,
      _sortOption,
      _sortAscending,
    );
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
