import '../../../core/models/product_model.dart';
import '../../../core/utils/logger.dart';
import '../../../modules/products/services/product_service.dart';
import '../../../modules/settings/services/settings_service.dart';

class LowStockItem {
  LowStockItem({
    required this.product,
    required this.isOutOfStock,
    required this.deficit,
  });

  final ProductModel product;
  final bool isOutOfStock;
  final int deficit;

  String get alertMessage {
    if (isOutOfStock) {
      return '${product.productName} is out of stock';
    }
    return '${product.productName} has only ${product.stockQuantity} units (min: ${product.minStockLevel})';
  }
}

class LowStockService {
  LowStockService({
    required ProductService productService,
    required SettingsService settingsService,
  })  : _productService = productService,
        _settingsService = settingsService;

  final ProductService _productService;
  final SettingsService _settingsService;

  Future<List<LowStockItem>> getLowStockItems() async {
    try {
      final threshold = await _settingsService.getLowStockThreshold();
      final allProducts = await _productService.getAllProducts();

      final items = <LowStockItem>[];
      for (final product in allProducts) {
        if (!product.isActive) {
          continue;
        }
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
    } on Exception catch (e, stackTrace) {
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
    } on Exception catch (e, stackTrace) {
      Logger.error('Failed to get out of stock items', e, stackTrace);
      return [];
    }
  }

  Future<int> getLowStockCount() async {
    try {
      final items = await getLowStockItems();
      return items.where((i) => !i.isOutOfStock).length;
    } on Exception catch (_) {
      return 0;
    }
  }

  Future<int> getOutOfStockCount() async {
    try {
      return await _productService.getOutOfStockCount();
    } on Exception catch (_) {
      return 0;
    }
  }

  Future<bool> hasStockIssues() async {
    try {
      final items = await getLowStockItems();
      return items.isNotEmpty;
    } on Exception catch (_) {
      return false;
    }
  }

  Future<int> getTotalStockIssueCount() async {
    try {
      final items = await getLowStockItems();
      return items.length;
    } on Exception catch (_) {
      return 0;
    }
  }

  Future<List<LowStockItem>> getCriticalItems() async {
    try {
      final items = await getLowStockItems();
      items.sort((a, b) {
        if (a.isOutOfStock && !b.isOutOfStock) {
          return -1;
        }
        if (!a.isOutOfStock && b.isOutOfStock) {
          return 1;
        }
        return a.deficit.compareTo(b.deficit);
      });
      return items;
    } on Exception catch (e, stackTrace) {
      Logger.error('Failed to get critical items', e, stackTrace);
      return [];
    }
  }

  Future<void> updateThreshold(int newThreshold) async {
    await _settingsService.updateLowStockThreshold(newThreshold);
    Logger.info('Low stock threshold updated to: $newThreshold');
  }

  Future<int> getEffectiveThreshold() => _settingsService.getLowStockThreshold();
}
