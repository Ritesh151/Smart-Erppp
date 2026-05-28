import 'package:SmartERP/core/models/product_model.dart';
import 'package:SmartERP/core/utils/logger.dart';
import 'package:SmartERP/modules/products/services/product_service.dart';
import 'package:SmartERP/modules/settings/services/settings_service.dart';

class LowStockItem {
  final ProductModel product;
  final bool isOutOfStock;
  final int deficit;

  LowStockItem({
    required this.product,
    required this.isOutOfStock,
    required this.deficit,
  });

  String get alertMessage {
    if (isOutOfStock) return '${product.productName} is out of stock';
    return '${product.productName} has only ${product.stockQuantity} units (min: ${product.minStockLevel})';
  }
}

class LowStockService {
  final ProductService _productService;
  final SettingsService _settingsService;

  LowStockService({
    required ProductService productService,
    required SettingsService settingsService,
  })  : _productService = productService,
        _settingsService = settingsService;

  Future<List<LowStockItem>> getLowStockItems() async {
    try {
      final threshold = await _settingsService.getLowStockThreshold();
      final allProducts = await _productService.getAllProducts();

      final items = <LowStockItem>[];
      for (final product in allProducts) {
        if (!product.isActive) continue;
        if (product.isOutOfStock) {
          items.add(LowStockItem(
            product: product,
            isOutOfStock: true,
            deficit: product.minStockLevel,
          ));
        } else if (product.stockQuantity <= threshold && product.stockQuantity <= product.minStockLevel) {
          items.add(LowStockItem(
            product: product,
            isOutOfStock: false,
            deficit: product.minStockLevel - product.stockQuantity,
          ));
        }
      }
      return items;
    } catch (e, stackTrace) {
      Logger.error('Failed to get low stock items', e, stackTrace);
      return [];
    }
  }

  Future<List<LowStockItem>> getOutOfStockItems() async {
    try {
      final allProducts = await _productService.getAllProducts();
      return allProducts
          .where((p) => p.isActive && p.isOutOfStock)
          .map((p) => LowStockItem(
            product: p,
            isOutOfStock: true,
            deficit: p.minStockLevel,
          ))
          .toList();
    } catch (e, stackTrace) {
      Logger.error('Failed to get out of stock items', e, stackTrace);
      return [];
    }
  }

  Future<int> getLowStockCount() async {
    try {
      final items = await getLowStockItems();
      return items.where((i) => !i.isOutOfStock).length;
    } catch (e) {
      return 0;
    }
  }

  Future<int> getOutOfStockCount() async {
    try {
      return await _productService.getOutOfStockCount();
    } catch (e) {
      return 0;
    }
  }

  Future<bool> hasStockIssues() async {
    try {
      final items = await getLowStockItems();
      return items.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<int> getTotalStockIssueCount() async {
    try {
      final items = await getLowStockItems();
      return items.length;
    } catch (e) {
      return 0;
    }
  }

  Future<List<LowStockItem>> getCriticalItems() async {
    try {
      final items = await getLowStockItems();
      items.sort((a, b) {
        if (a.isOutOfStock && !b.isOutOfStock) return -1;
        if (!a.isOutOfStock && b.isOutOfStock) return 1;
        return a.deficit.compareTo(b.deficit);
      });
      return items;
    } catch (e, stackTrace) {
      Logger.error('Failed to get critical items', e, stackTrace);
      return [];
    }
  }

  Future<void> updateThreshold(int newThreshold) async {
    await _settingsService.updateLowStockThreshold(newThreshold);
    Logger.info('Low stock threshold updated to: $newThreshold');
  }

  Future<int> getEffectiveThreshold() async {
    return await _settingsService.getLowStockThreshold();
  }
}
