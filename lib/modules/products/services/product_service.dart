import 'package:smarterp/core/exceptions/app_exception.dart';
import 'package:smarterp/core/models/product_model.dart';
import 'package:smarterp/core/utils/logger.dart';
import 'package:smarterp/modules/products/repositories/product_repository.dart';
import 'package:uuid/uuid.dart';

class ProductService {
  final ProductRepository _repository;

  ProductService(this._repository);

  Future<List<ProductModel>> getAllProducts() async {
    try {
      return await _repository.getAll();
    } catch (e, stackTrace) {
      Logger.error('Failed to get all products', e, stackTrace);
      rethrow;
    }
  }

  Future<ProductModel?> getProductById(String id) async {
    try {
      return await _repository.getById(id);
    } catch (e, stackTrace) {
      Logger.error('Failed to get product by id', e, stackTrace);
      return null;
    }
  }

  Future<ProductModel> createProduct({
    required String productName,
    String? hsnCode,
    required double price,
    required int stockQuantity,
    required double gstRate,
    String? description,
    String? imagePath,
    required String category,
    required double costPrice,
    required int minStockLevel,
    required String unit,
    String? sku,
    String? barcode,
  }) async {
    try {
      _validateProductData(
        productName: productName,
        price: price,
        stockQuantity: stockQuantity,
        gstRate: gstRate,
        costPrice: costPrice,
        minStockLevel: minStockLevel,
      );

      final nameExists = await _repository.productNameExists(productName);
      if (nameExists) {
        throw ValidationException('Product with this name already exists');
      }

      final product = ProductModel(
        id: const Uuid().v4(),
        productName: productName.trim(),
        hsnCode: hsnCode?.trim(),
        price: price,
        stockQuantity: stockQuantity,
        gstRate: gstRate,
        description: description?.trim(),
        imagePath: imagePath,
        category: category.trim(),
        costPrice: costPrice,
        minStockLevel: minStockLevel,
        unit: unit.trim(),
        sku: sku?.trim(),
        barcode: barcode?.trim(),
        isActive: true,
        isFixed: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _repository.save(product);
      Logger.success('Product created: ${product.productName}');
      return product;
    } catch (e, stackTrace) {
      Logger.error('Failed to create product', e, stackTrace);
      rethrow;
    }
  }

  Future<ProductModel> updateProduct({
    required String id,
    required String productName,
    String? hsnCode,
    required double price,
    required int stockQuantity,
    required double gstRate,
    String? description,
    String? imagePath,
    required String category,
    required double costPrice,
    required int minStockLevel,
    required String unit,
    String? sku,
    String? barcode,
    required bool isActive,
  }) async {
    try {
      _validateProductData(
        productName: productName,
        price: price,
        stockQuantity: stockQuantity,
        gstRate: gstRate,
        costPrice: costPrice,
        minStockLevel: minStockLevel,
      );

      final existingProduct = await _repository.getById(id);
      if (existingProduct == null) {
        throw NotFoundException('Product not found');
      }

      final nameExists = await _repository.productNameExists(
        productName,
        excludeId: id,
      );
      if (nameExists) {
        throw ValidationException('Product with this name already exists');
      }

      final updatedProduct = existingProduct.copyWith(
        productName: productName.trim(),
        hsnCode: hsnCode?.trim(),
        price: price,
        stockQuantity: stockQuantity,
        gstRate: gstRate,
        description: description?.trim(),
        imagePath: imagePath,
        category: category.trim(),
        costPrice: costPrice,
        minStockLevel: minStockLevel,
        unit: unit.trim(),
        sku: sku?.trim(),
        barcode: barcode?.trim(),
        isActive: isActive,
        updatedAt: DateTime.now(),
      );

      await _repository.update(updatedProduct);
      Logger.success('Product updated: ${updatedProduct.productName}');
      return updatedProduct;
    } catch (e, stackTrace) {
      Logger.error('Failed to update product', e, stackTrace);
      rethrow;
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      final product = await _repository.getById(id);
      if (product == null) {
        throw NotFoundException('Product not found');
      }

      await _repository.delete(id);
      Logger.success('Product deleted: ${product.productName}');
    } catch (e, stackTrace) {
      Logger.error('Failed to delete product', e, stackTrace);
      rethrow;
    }
  }

  Future<void> updateStock(String id, int newQuantity) async {
    try {
      if (newQuantity < 0) {
        throw ValidationException('Stock quantity cannot be negative');
      }

      final product = await _repository.getById(id);
      if (product == null) {
        throw NotFoundException('Product not found');
      }

      final updatedProduct = product.copyWith(
        stockQuantity: newQuantity,
        updatedAt: DateTime.now(),
      );

      await _repository.update(updatedProduct);
      Logger.success('Stock updated for: ${product.productName}');
    } catch (e, stackTrace) {
      Logger.error('Failed to update stock', e, stackTrace);
      rethrow;
    }
  }

  Future<List<ProductModel>> searchProducts(String query) async {
    try {
      if (query.trim().isEmpty) {
        return await getAllProducts();
      }
      return await _repository.search(query);
    } catch (e, stackTrace) {
      Logger.error('Failed to search products', e, stackTrace);
      return [];
    }
  }

  Future<List<ProductModel>> filterByCategory(String category) async {
    try {
      return await _repository.filterByCategory(category);
    } catch (e, stackTrace) {
      Logger.error('Failed to filter by category', e, stackTrace);
      return [];
    }
  }

  Future<List<ProductModel>> filterByStockStatus(StockStatus status) async {
    try {
      return await _repository.filterByStockStatus(status);
    } catch (e, stackTrace) {
      Logger.error('Failed to filter by stock status', e, stackTrace);
      return [];
    }
  }

  Future<List<ProductModel>> filterByPriceRange(
    double minPrice,
    double maxPrice,
  ) async {
    try {
      if (minPrice < 0 || maxPrice < 0 || minPrice > maxPrice) {
        throw ValidationException('Invalid price range');
      }
      return await _repository.filterByPriceRange(minPrice, maxPrice);
    } catch (e, stackTrace) {
      Logger.error('Failed to filter by price range', e, stackTrace);
      return [];
    }
  }

  Future<List<ProductModel>> getLowStockProducts() async {
    try {
      return await filterByStockStatus(StockStatus.lowStock);
    } catch (e, stackTrace) {
      Logger.error('Failed to get low stock products', e, stackTrace);
      return [];
    }
  }

  Future<List<ProductModel>> getOutOfStockProducts() async {
    try {
      return await filterByStockStatus(StockStatus.outOfStock);
    } catch (e, stackTrace) {
      Logger.error('Failed to get out of stock products', e, stackTrace);
      return [];
    }
  }

  Future<int> getTotalProductCount() async {
    try {
      return await _repository.getTotalCount();
    } catch (e, stackTrace) {
      Logger.error('Failed to get total product count', e, stackTrace);
      return 0;
    }
  }

  Future<int> getLowStockCount() async {
    try {
      return await _repository.getLowStockCount();
    } catch (e, stackTrace) {
      Logger.error('Failed to get low stock count', e, stackTrace);
      return 0;
    }
  }

  Future<int> getOutOfStockCount() async {
    try {
      return await _repository.getOutOfStockCount();
    } catch (e, stackTrace) {
      Logger.error('Failed to get out of stock count', e, stackTrace);
      return 0;
    }
  }

  Future<double> getTotalInventoryValue() async {
    try {
      return await _repository.getTotalInventoryValue();
    } catch (e, stackTrace) {
      Logger.error('Failed to get total inventory value', e, stackTrace);
      return 0.0;
    }
  }

  Future<List<String>> getAllCategories() async {
    try {
      return await _repository.getAllCategories();
    } catch (e, stackTrace) {
      Logger.error('Failed to get all categories', e, stackTrace);
      return [];
    }
  }

  List<ProductModel> sortProducts(
    List<ProductModel> products,
    ProductSortOption sortOption,
    bool ascending,
  ) {
    final sorted = List<ProductModel>.from(products);

    switch (sortOption) {
      case ProductSortOption.name:
        sorted.sort((a, b) => a.productName.compareTo(b.productName));
        break;
      case ProductSortOption.price:
        sorted.sort((a, b) => a.price.compareTo(b.price));
        break;
      case ProductSortOption.stock:
        sorted.sort((a, b) => a.stockQuantity.compareTo(b.stockQuantity));
        break;
      case ProductSortOption.category:
        sorted.sort((a, b) => a.category.compareTo(b.category));
        break;
      case ProductSortOption.createdDate:
        sorted.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case ProductSortOption.updatedDate:
        sorted.sort((a, b) => a.updatedAt.compareTo(b.updatedAt));
        break;
    }

    return ascending ? sorted : sorted.reversed.toList();
  }

  void _validateProductData({
    required String productName,
    required double price,
    required int stockQuantity,
    required double gstRate,
    required double costPrice,
    required int minStockLevel,
  }) {
    if (productName.trim().isEmpty) {
      throw ValidationException('Product name is required');
    }

    if (price <= 0) {
      throw ValidationException('Price must be greater than 0');
    }

    if (stockQuantity < 0) {
      throw ValidationException('Stock quantity cannot be negative');
    }

    if (gstRate < 0 || gstRate > 100) {
      throw ValidationException('GST rate must be between 0 and 100');
    }

    if (costPrice < 0) {
      throw ValidationException('Cost price cannot be negative');
    }

    if (minStockLevel < 0) {
      throw ValidationException('Minimum stock level cannot be negative');
    }

    if (costPrice > price) {
      Logger.warning('Cost price is greater than selling price');
    }
  }
}

enum ProductSortOption {
  name,
  price,
  stock,
  category,
  createdDate,
  updatedDate,
}
