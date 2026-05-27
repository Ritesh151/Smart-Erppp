import 'package:smarterp/core/utils/logger.dart';
import 'package:smarterp/data/mock/default_products.dart';
import 'package:smarterp/modules/products/repositories/product_repository.dart';

class ProductSeedService {
  final ProductRepository _repository;
  bool _seedAttempted = false;

  ProductSeedService({
    required ProductRepository repository,
  }) : _repository = repository;

  Future<void> seedProducts() async {
    if (_seedAttempted) {
      Logger.debug('Seed already attempted this session, skipping');
      return;
    }
    _seedAttempted = true;

    try {
      final hasExisting = await checkExistingProducts();
      if (hasExisting) {
        Logger.info('Products already exist, skipping seed');
        return;
      }

      final alreadySeeded = await preventDuplicateSeed();
      if (alreadySeeded) {
        Logger.info('Duplicate seed prevented');
        return;
      }

      await insertDefaultProducts();
    } catch (e, stackTrace) {
      Logger.error('Product seeding failed', e, stackTrace);
    }
  }

  Future<bool> checkExistingProducts() async {
    try {
      final count = await _repository.getTotalCount();
      return count > 0;
    } catch (e, stackTrace) {
      Logger.error('Failed to check existing products', e, stackTrace);
      return true;
    }
  }

  Future<bool> preventDuplicateSeed() async {
    try {
      bool hasDuplicate = false;
      for (final product in defaultProducts) {
        final idExists = await _repository.exists(product.id);
        if (idExists) {
          hasDuplicate = true;
          break;
        }
        final nameExists = await _repository.productNameExists(product.productName);
        if (nameExists) {
          hasDuplicate = true;
          break;
        }
      }
      return hasDuplicate;
    } catch (e, stackTrace) {
      Logger.error('Failed to validate duplicate seed', e, stackTrace);
      return true;
    }
  }

  Future<void> insertDefaultProducts() async {
    try {
      int inserted = 0;
      for (final product in defaultProducts) {
        final idExists = await _repository.exists(product.id);
        if (idExists) continue;

        final nameExists = await _repository.productNameExists(product.productName);
        if (nameExists) continue;

        await _repository.save(product);
        inserted++;
      }
      Logger.success('Seeded $inserted default automotive products');
    } catch (e, stackTrace) {
      Logger.error('Failed to insert default products', e, stackTrace);
      rethrow;
    }
  }
}
