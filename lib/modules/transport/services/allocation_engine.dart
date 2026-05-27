import 'package:smarterp/core/exceptions/app_exception.dart';
import 'package:smarterp/core/models/product_model.dart';
import 'package:smarterp/core/models/transport_item_model.dart';
import 'package:smarterp/core/utils/logger.dart';
import 'package:smarterp/modules/products/repositories/product_repository.dart';
import 'package:smarterp/modules/transport/repositories/transport_repository.dart';

class AllocationResult {
  final bool success;
  final String? errorMessage;
  final int availableStock;
  final int requestedQuantity;

  AllocationResult({
    required this.success,
    this.errorMessage,
    required this.availableStock,
    required this.requestedQuantity,
  });
}

class AllocationEngine {
  final ProductRepository _productRepository;
  final TransportRepository _transportRepository;

  AllocationEngine({
    required ProductRepository productRepository,
    required TransportRepository transportRepository,
  })  : _productRepository = productRepository,
        _transportRepository = transportRepository;

  Future<AllocationResult> checkAvailability({
    required String productId,
    required double quantity,
  }) async {
    try {
      final product = await _productRepository.getById(productId);
      if (product == null) {
        return AllocationResult(
          success: false,
          errorMessage: 'Product not found',
          availableStock: 0,
          requestedQuantity: quantity.toInt(),
        );
      }

      final allocated = await getAllocatedQuantityByTransport(productId);
      final availableStock = product.stockQuantity;
      final effectivelyAvailable = availableStock - allocated;

      return AllocationResult(
        success: effectivelyAvailable >= quantity,
        errorMessage: effectivelyAvailable < quantity
            ? 'Insufficient stock. Available: $effectivelyAvailable (${availableStock - effectivelyAvailable} already allocated to other transports)'
            : null,
        availableStock: effectivelyAvailable,
        requestedQuantity: quantity.toInt(),
      );
    } catch (e, stackTrace) {
      Logger.error('Failed to check availability', e, stackTrace);
      return AllocationResult(
        success: false,
        errorMessage: 'Failed to check availability',
        availableStock: 0,
        requestedQuantity: quantity.toInt(),
      );
    }
  }

  Future<bool> allocateStock(TransportItemModel item) async {
    try {
      final check = await checkAvailability(
        productId: item.productId,
        quantity: item.quantity,
      );

      if (!check.success) {
        throw ValidationException(check.errorMessage ?? 'Insufficient stock');
      }

      final product = await _productRepository.getById(item.productId);
      if (product == null) {
        throw NotFoundException('Product not found: ${item.productId}');
      }

      final updated = product.copyWith(
        stockQuantity: product.stockQuantity - item.quantity.toInt(),
        updatedAt: DateTime.now(),
      );

      await _productRepository.update(updated);
      Logger.info('Allocated ${item.quantity} of ${item.productName} to transport');
      return true;
    } catch (e) {
      if (e is AppException) rethrow;
      Logger.warning('Failed to allocate stock for product: ${item.productId}', e);
      return false;
    }
  }

  Future<bool> finalizeAllocation(TransportItemModel item) async {
    try {
      Logger.info('Allocation finalized for ${item.productName} (${item.quantity})');
      return true;
    } catch (e) {
      Logger.warning('Failed to finalize allocation for product: ${item.productId}', e);
      return false;
    }
  }

  Future<bool> releaseAllocation(TransportItemModel item) async {
    try {
      final product = await _productRepository.getById(item.productId);
      if (product == null) {
        Logger.warning('Product not found for stock release: ${item.productId}');
        return false;
      }

      final updated = product.copyWith(
        stockQuantity: product.stockQuantity + item.quantity.toInt(),
        updatedAt: DateTime.now(),
      );

      await _productRepository.update(updated);
      Logger.info('Released ${item.quantity} of ${item.productName} back to inventory');
      return true;
    } catch (e) {
      Logger.warning('Failed to release stock for product: ${item.productId}', e);
      return false;
    }
  }

  Future<int> getAllocatedQuantityByTransport(String productId) async {
    try {
      final transports = await _transportRepository.getAll();
      int total = 0;

      for (final transport in transports) {
        if (!transport.isCancelled && !transport.isDelivered) {
          final items = await _transportRepository.getItemsByIds(transport.itemIds);
          for (final item in items) {
            if (item.productId == productId && item.allocatedQuantity > 0) {
              final undelivered = item.allocatedQuantity - item.deliveredQuantity;
              total += undelivered.toInt();
            }
          }
        }
      }

      return total;
    } catch (e, stackTrace) {
      Logger.error('Failed to calculate allocated quantity', e, stackTrace);
      return 0;
    }
  }


}
