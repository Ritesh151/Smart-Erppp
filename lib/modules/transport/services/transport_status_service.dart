import 'package:smarterp/core/exceptions/app_exception.dart';
import 'package:smarterp/core/models/transport_model.dart';
import 'package:smarterp/core/models/transport_item_model.dart';
import 'package:smarterp/core/models/transport_status_model.dart';
import 'package:smarterp/core/utils/logger.dart';
import 'package:smarterp/modules/products/repositories/product_repository.dart';
import 'package:smarterp/modules/finance/repositories/finance_repository.dart';
import 'package:smarterp/modules/transport/repositories/transport_repository.dart';

class TransportStatusService {
  final TransportRepository _transportRepository;
  final ProductRepository _productRepository;
  final FinanceRepository _financeRepository;

  TransportStatusService({
    required TransportRepository transportRepository,
    required ProductRepository productRepository,
    required FinanceRepository financeRepository,
  })  : _transportRepository = transportRepository,
        _productRepository = productRepository,
        _financeRepository = financeRepository;

  Future<TransportModel> advanceStatus(String transportId) async {
    try {
      final transport = await _transportRepository.getById(transportId);
      if (transport == null) {
        throw NotFoundException('Transport not found');
      }

      final nextStatus = transport.status.nextStatus;
      if (nextStatus == transport.status) {
        throw ValidationException('Transport is already in its final state');
      }

      TransportModel updated;
      switch (nextStatus) {
        case TransportStatus.onTheWay:
          updated = transport.copyWith(
            status: TransportStatus.onTheWay,
            updatedAt: DateTime.now(),
          );
          break;
        case TransportStatus.delivered:
          updated = transport.copyWith(
            status: TransportStatus.delivered,
            actualArrival: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          await _handleDelivery(transport);
          break;
        case TransportStatus.cancelled:
          updated = transport.copyWith(
            status: TransportStatus.cancelled,
            updatedAt: DateTime.now(),
          );
          await _handleCancellation(transport);
          break;
        default:
          updated = transport.copyWith(
            status: nextStatus,
            updatedAt: DateTime.now(),
          );
      }

      await _transportRepository.update(updated);
      Logger.success('Transport ${transport.transportNumber} status: ${nextStatus.displayName}');
      return updated;
    } catch (e, stackTrace) {
      Logger.error('Failed to advance transport status', e, stackTrace);
      rethrow;
    }
  }

  Future<TransportModel> cancelTransport(String transportId) async {
    try {
      final transport = await _transportRepository.getById(transportId);
      if (transport == null) {
        throw NotFoundException('Transport not found');
      }

      if (transport.isTerminal) {
        throw ValidationException('Cannot cancel a transport in terminal state');
      }

      final items = await _transportRepository.getItemsByIds(transport.itemIds);
      for (final item in items) {
        await _restoreProductStock(item);
      }

      final updated = transport.copyWith(
        status: TransportStatus.cancelled,
        updatedAt: DateTime.now(),
      );

      await _transportRepository.update(updated);
      Logger.success('Transport cancelled: ${transport.transportNumber}');
      return updated;
    } catch (e, stackTrace) {
      Logger.error('Failed to cancel transport', e, stackTrace);
      rethrow;
    }
  }

  Future<void> _handleDelivery(TransportModel transport) async {
    try {
      final items = await _transportRepository.getItemsByIds(transport.itemIds);
      for (final item in items) {
        final delivered = item.copyWith(deliveredQuantity: item.allocatedQuantity);
        await _transportRepository.saveItem(delivered);
        await _reduceInventoryPermanently(item);
      }
      await _updateFinanceOnDelivery(transport);
    } catch (e, stackTrace) {
      Logger.error('Failed to handle delivery for transport: ${transport.id}', e, stackTrace);
    }
  }

  Future<void> _handleCancellation(TransportModel transport) async {
    try {
      final items = await _transportRepository.getItemsByIds(transport.itemIds);
      for (final item in items) {
        await _restoreProductStock(item);
      }
    } catch (e, stackTrace) {
      Logger.error('Failed to handle cancellation for transport: ${transport.id}', e, stackTrace);
    }
  }

  Future<void> _reduceInventoryPermanently(TransportItemModel item) async {
    try {
      final product = await _productRepository.getById(item.productId);
      if (product != null) {
        final newStock = product.stockQuantity - item.allocatedQuantity.toInt();
        final updated = product.copyWith(
          stockQuantity: newStock < 0 ? 0 : newStock,
          updatedAt: DateTime.now(),
        );
        await _productRepository.update(updated);
      }
    } catch (e, stackTrace) {
      Logger.warning('Failed to reduce inventory for product: ${item.productId}', e);
    }
  }

  Future<void> _restoreProductStock(TransportItemModel item) async {
    try {
      final product = await _productRepository.getById(item.productId);
      if (product != null) {
        final restored = product.copyWith(
          stockQuantity: product.stockQuantity + item.allocatedQuantity.toInt(),
          updatedAt: DateTime.now(),
        );
        await _productRepository.update(restored);
      }
    } catch (e, stackTrace) {
      Logger.warning('Failed to restore stock for product: ${item.productId}', e);
    }
  }

  Future<void> _updateFinanceOnDelivery(TransportModel transport) async {
    try {
      // TODO: Record transport as finance transaction
      Logger.info('Finance update for transport: ${transport.transportNumber}');
    } catch (e, stackTrace) {
      Logger.warning('Failed to update finance for transport', e);
    }
  }
}
