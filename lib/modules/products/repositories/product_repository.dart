import 'package:siddhivinayak_enterprise/core/exceptions/app_exception.dart';
import 'package:siddhivinayak_enterprise/core/models/product_model.dart';
import 'package:siddhivinayak_enterprise/core/storage/storage_service.dart';
import 'package:siddhivinayak_enterprise/core/utils/logger.dart';

class ProductRepository {
  final StorageService<Map<dynamic, dynamic>> _storage;

  ProductRepository(this._storage);

  Future<List<ProductModel>> getAll() async {
    try {
      final data = _storage.getAll();
      return data
          .map((item) => ProductModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } catch (e, stackTrace) {
      Logger.error('Failed to get all products', e, stackTrace);
      throw StorageException('Failed to retrieve products');
    }
  }

  Future<ProductModel?> getById(String id) async {
    try {
      final data = _storage.get(id);
      if (data == null) return null;
      return ProductModel.fromJson(Map<String, dynamic>.from(data));
    } catch (e, stackTrace) {
      Logger.error('Failed to get product by id: $id', e, stackTrace);
      return null;
    }
  }

  Future<void> save(ProductModel product) async {
    try {
      await _storage.save(product.id, product.toJson());
      Logger.success('Product saved: ${product.id}');
    } catch (e, stackTrace) {
      Logger.error('Failed to save product', e, stackTrace);
      throw StorageException('Failed to save product');
    }
  }

  Future<void> update(ProductModel product) async {
    try {
      await _storage.update(product.id, product.toJson());
      Logger.success('Product updated: ${product.id}');
    } catch (e, stackTrace) {
      Logger.error('Failed to update product', e, stackTrace);
      throw StorageException('Failed to update product');
    }
  }

  Future<void> delete(String id) async {
    try {
      await _storage.delete(id);
      Logger.success('Product deleted: $id');
    } catch (e, stackTrace) {
      Logger.error('Failed to delete product', e, stackTrace);
      throw StorageException('Failed to delete product');
    }
  }

  Future<List<ProductModel>> search(String query) async {
    try {
      final products = await getAll();
      final lowerQuery = query.toLowerCase();
      
      return products.where((product) {
        return product.productName.toLowerCase().contains(lowerQuery) ||
            (product.hsnCode?.toLowerCase().contains(lowerQuery) ?? false);
      }).toList();
    } catch (e, stackTrace) {
      Logger.error('Failed to search products', e, stackTrace);
      return [];
    }
  }

  Future<List<ProductModel>> filterByStockStatus(StockStatus status) async {
    try {
      final products = await getAll();
      return products.where((p) => p.stockStatus == status).toList();
    } catch (e, stackTrace) {
      Logger.error('Failed to filter products by stock status', e, stackTrace);
      return [];
    }
  }

  Future<List<ProductModel>> filterByPriceRange(
    double minPrice,
    double maxPrice,
  ) async {
    try {
      final products = await getAll();
      return products
          .where((p) => p.price >= minPrice && p.price <= maxPrice)
          .toList();
    } catch (e, stackTrace) {
      Logger.error('Failed to filter products by price range', e, stackTrace);
      return [];
    }
  }

  Future<bool> exists(String id) async {
    try {
      return _storage.containsKey(id);
    } catch (e, stackTrace) {
      Logger.error('Failed to check product existence', e, stackTrace);
      return false;
    }
  }

  Future<bool> productNameExists(String name, {String? excludeId}) async {
    try {
      final products = await getAll();
      return products.any((p) =>
          p.productName.toLowerCase() == name.toLowerCase() &&
          p.id != excludeId);
    } catch (e, stackTrace) {
      Logger.error('Failed to check product name existence', e, stackTrace);
      return false;
    }
  }

  Future<int> getTotalCount() async {
    try {
      return _storage.length;
    } catch (e, stackTrace) {
      Logger.error('Failed to get total product count', e, stackTrace);
      return 0;
    }
  }

  Future<int> getLowStockCount() async {
    try {
      final products = await getAll();
      return products.where((p) => p.isLowStock).length;
    } catch (e, stackTrace) {
      Logger.error('Failed to get low stock count', e, stackTrace);
      return 0;
    }
  }

  Future<int> getOutOfStockCount() async {
    try {
      final products = await getAll();
      return products.where((p) => p.isOutOfStock).length;
    } catch (e, stackTrace) {
      Logger.error('Failed to get out of stock count', e, stackTrace);
      return 0;
    }
  }

  Future<double> getTotalInventoryValue() async {
    try {
      final List<ProductModel> products = await getAll();
      return products.fold<double>(0.0, (double sum, ProductModel product) => sum + product.inventoryValue);
    } catch (e, stackTrace) {
      Logger.error('Failed to calculate total inventory value', e, stackTrace);
      return 0.0;
    }
  }

}
