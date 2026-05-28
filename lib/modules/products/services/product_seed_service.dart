import 'package:SmartERP/core/utils/logger.dart';
import 'package:SmartERP/core/models/product_model.dart';
import 'package:SmartERP/modules/products/repositories/product_repository.dart';

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

      await _insertRequiredDefaultProduct();
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

  Future<void> _insertRequiredDefaultProduct() async {
    try {
      const defaultId = 'default-product';
      const defaultName = 'Default Product';

      final idExists = await _repository.exists(defaultId);
      if (idExists) return;

      final nameExists = await _repository.productNameExists(defaultName);
      if (nameExists) return;

      final now = DateTime.now();
      await _repository.save(
        ProductModel(
          id: defaultId,
          productName: defaultName,
          hsnCode: null,
          price: 0,
          stockQuantity: 0,
          description: 'Create your first product by editing this default product or adding a new one.',
          imagePath: null,
          minStockLevel: 0,
          unit: 'Unit',
          isActive: true,
          isFixed: true,
          createdAt: now,
          updatedAt: now,
        ),
      );
      Logger.success('Inserted required default product');
    } catch (e, stackTrace) {
      Logger.error('Failed to insert required default product', e, stackTrace);
      rethrow;
    }
  }
}
