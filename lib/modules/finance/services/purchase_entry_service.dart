import 'package:siddhivinayak_enterprise/core/exceptions/app_exception.dart';
import 'package:siddhivinayak_enterprise/core/models/product_model.dart';
import 'package:siddhivinayak_enterprise/core/utils/logger.dart';
import 'package:siddhivinayak_enterprise/modules/products/repositories/product_repository.dart';
import 'package:siddhivinayak_enterprise/modules/finance/repositories/purchase_entry_repository.dart';
import 'package:uuid/uuid.dart';

class PurchaseEntryService {
  final PurchaseEntryRepository _repository;
  final ProductRepository _productRepository;

  PurchaseEntryService({
    required PurchaseEntryRepository repository,
    required ProductRepository productRepository,
  })  : _repository = repository,
        _productRepository = productRepository;

  Future<List<Map<String, dynamic>>> getAll() async {
    return _repository.getAll();
  }

  Map<String, dynamic>? getById(String id) {
    return _repository.getById(id);
  }

  Future<String> getNextPurchaseNumber() async {
    final count = _repository.getTotalCount();
    final year = DateTime.now().year;
    return 'PUR-$year-${(count + 1).toString().padLeft(4, '0')}';
  }

  Future<List<ProductModel>> getAllProducts() async {
    return _productRepository.getAll();
  }

  Future<void> savePurchase(Map<String, dynamic> purchase) async {
    final items = purchase['items'] as List<dynamic>? ?? [];
    if (items.isEmpty) {
      throw ValidationException('Purchase must have at least one item');
    }
    final supplierName = purchase['supplierName'] as String? ?? '';
    if (supplierName.trim().isEmpty) {
      throw ValidationException('Supplier name is required');
    }

    final updateStock = purchase['updateStock'] as bool? ?? true;
    if (updateStock) {
      for (final item in items) {
        final productId = item['productId'] as String?;
        final qty = (item['quantity'] as num?)?.toInt() ?? 0;
        if (productId != null && productId.isNotEmpty && qty > 0) {
          await _increaseStock(productId, qty);
        }
      }
    }

    final id = purchase['id'] as String? ?? const Uuid().v4();
    purchase['id'] = id;
    purchase['createdAt'] = DateTime.now().toIso8601String();
    purchase['updatedAt'] = DateTime.now().toIso8601String();
    purchase.remove('updateStock');

    await _repository.save(purchase);
  }

  Future<void> updatePurchase(Map<String, dynamic> purchase) async {
    final existing = _repository.getById(purchase['id'] as String);
    if (existing == null) {
      throw NotFoundException('Purchase not found');
    }

    final items = purchase['items'] as List<dynamic>? ?? [];
    if (items.isEmpty) {
      throw ValidationException('Purchase must have at least one item');
    }

    final oldItems = existing['items'] as List<dynamic>? ?? [];
    final updateStock = purchase['updateStock'] as bool? ?? true;
    if (updateStock) {
      for (final oldItem in oldItems) {
        final productId = oldItem['productId'] as String?;
        final oldQty = (oldItem['quantity'] as num?)?.toInt() ?? 0;
        if (productId != null && productId.isNotEmpty && oldQty > 0) {
          await _decreaseStock(productId, oldQty);
        }
      }
      for (final item in items) {
        final productId = item['productId'] as String?;
        final qty = (item['quantity'] as num?)?.toInt() ?? 0;
        if (productId != null && productId.isNotEmpty && qty > 0) {
          await _increaseStock(productId, qty);
        }
      }
    }

    purchase['updatedAt'] = DateTime.now().toIso8601String();
    purchase.remove('updateStock');

    await _repository.update(purchase);
  }

  Future<void> deletePurchase(String id) async {
    final existing = _repository.getById(id);
    if (existing == null) {
      throw NotFoundException('Purchase not found');
    }

    final items = existing['items'] as List<dynamic>? ?? [];
    for (final item in items) {
      final productId = item['productId'] as String?;
      final qty = (item['quantity'] as num?)?.toInt() ?? 0;
      if (productId != null && productId.isNotEmpty && qty > 0) {
        await _decreaseStock(productId, qty);
      }
    }

    await _repository.delete(id);
  }

  Future<List<Map<String, dynamic>>> search(String query) async {
    return _repository.search(query);
  }

  Future<List<Map<String, dynamic>>> getByDateRange(DateTime start, DateTime end) async {
    return _repository.getByDateRange(start, end);
  }

  Future<void> _increaseStock(String productId, int qty) async {
    final product = await _productRepository.getById(productId);
    if (product == null) return;
    final updated = product.copyWith(
      stockQuantity: product.stockQuantity + qty,
      updatedAt: DateTime.now(),
    );
    await _productRepository.update(updated);
  }

  Future<void> _decreaseStock(String productId, int qty) async {
    final product = await _productRepository.getById(productId);
    if (product == null) return;
    final newQty = (product.stockQuantity - qty).clamp(0, product.stockQuantity);
    final updated = product.copyWith(
      stockQuantity: newQty,
      updatedAt: DateTime.now(),
    );
    await _productRepository.update(updated);
  }
}
