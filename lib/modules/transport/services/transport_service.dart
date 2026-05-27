import 'package:smarterp/core/exceptions/app_exception.dart';
import 'package:smarterp/core/models/transport_model.dart';
import 'package:smarterp/core/models/transport_item_model.dart';
import 'package:smarterp/core/models/transport_status_model.dart';
import 'package:smarterp/core/utils/logger.dart';
import 'package:smarterp/modules/products/repositories/product_repository.dart';
import 'package:smarterp/modules/transport/repositories/transport_repository.dart';

class TransportService {
  final TransportRepository _repository;
  final ProductRepository _productRepository;

  TransportService({
    required TransportRepository transportRepository,
    required ProductRepository productRepository,
  })  : _repository = transportRepository,
        _productRepository = productRepository;

  Future<List<TransportModel>> getAllTransports() async {
    try {
      return await _repository.getAll();
    } catch (e, stackTrace) {
      Logger.error('Failed to get all transports', e, stackTrace);
      rethrow;
    }
  }

  Future<TransportModel?> getTransportById(String id) async {
    try {
      return await _repository.getById(id);
    } catch (e, stackTrace) {
      Logger.error('Failed to get transport by id', e, stackTrace);
      return null;
    }
  }

  Future<List<TransportItemModel>> getTransportItems(TransportModel transport) async {
    try {
      return await _repository.getItemsByIds(transport.itemIds);
    } catch (e, stackTrace) {
      Logger.error('Failed to get items for transport: ${transport.id}', e, stackTrace);
      return [];
    }
  }

  Future<TransportModel> createTransport({
    required String vehicleId,
    required String vehicleNumber,
    String? driverName,
    String? driverPhone,
    required String origin,
    required String destination,
    required DateTime departureDate,
    DateTime? estimatedArrival,
    required List<TransportItemModel> items,
    String? notes,
  }) async {
    try {
      if (items.isEmpty) {
        throw ValidationException('Transport must have at least one item');
      }
      if (origin.trim().isEmpty) {
        throw ValidationException('Origin is required');
      }
      if (destination.trim().isEmpty) {
        throw ValidationException('Destination is required');
      }

      final itemIds = <String>[];
      double totalWeight = 0;

      for (final item in items) {
        if (item.quantity <= 0) {
          throw ValidationException('Quantity must be greater than 0 for ${item.productName}');
        }
        await _repository.saveItem(item);
        itemIds.add(item.id);
        totalWeight += item.quantity;
        await _reserveProductStock(item);
      }

      final transportNumber = await _repository.getNextTransportNumber();

      final transport = TransportModel(
        id: _generateId(),
        transportNumber: transportNumber,
        vehicleId: vehicleId,
        vehicleNumber: vehicleNumber,
        driverName: driverName,
        driverPhone: driverPhone,
        origin: origin.trim(),
        destination: destination.trim(),
        departureDate: departureDate,
        estimatedArrival: estimatedArrival,
        itemIds: itemIds,
        status: TransportStatus.planned,
        totalWeight: totalWeight,
        totalItems: items.length,
        notes: notes?.trim(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _repository.save(transport);
      Logger.success('Transport created: ${transport.transportNumber}');
      return transport;
    } catch (e, stackTrace) {
      Logger.error('Failed to create transport', e, stackTrace);
      rethrow;
    }
  }

  Future<TransportModel> updateTransport({
    required String id,
    required String vehicleId,
    required String vehicleNumber,
    String? driverName,
    String? driverPhone,
    required String origin,
    required String destination,
    required DateTime departureDate,
    DateTime? estimatedArrival,
    String? notes,
  }) async {
    try {
      final existing = await _repository.getById(id);
      if (existing == null) {
        throw NotFoundException('Transport not found');
      }
      if (existing.isTerminal) {
        throw ValidationException('Cannot edit a transport in terminal state');
      }
      if (origin.trim().isEmpty) {
        throw ValidationException('Origin is required');
      }
      if (destination.trim().isEmpty) {
        throw ValidationException('Destination is required');
      }

      final updated = existing.copyWith(
        vehicleId: vehicleId,
        vehicleNumber: vehicleNumber,
        driverName: driverName?.trim(),
        driverPhone: driverPhone?.trim(),
        origin: origin.trim(),
        destination: destination.trim(),
        departureDate: departureDate,
        estimatedArrival: estimatedArrival,
        notes: notes?.trim(),
        updatedAt: DateTime.now(),
      );

      await _repository.update(updated);
      Logger.success('Transport updated: ${updated.transportNumber}');
      return updated;
    } catch (e, stackTrace) {
      Logger.error('Failed to update transport', e, stackTrace);
      rethrow;
    }
  }

  Future<void> deleteTransport(String id) async {
    try {
      final transport = await _repository.getById(id);
      if (transport == null) {
        throw NotFoundException('Transport not found');
      }

      if (!transport.isTerminal) {
        final items = await _repository.getItemsByIds(transport.itemIds);
        for (final item in items) {
          await _restoreProductStock(item);
        }
      }

      await _repository.delete(id);
      Logger.success('Transport deleted: ${transport.transportNumber}');
    } catch (e, stackTrace) {
      Logger.error('Failed to delete transport', e, stackTrace);
      rethrow;
    }
  }

  Future<List<TransportModel>> getTransportsByStatus(TransportStatus status) async {
    try {
      return await _repository.getByStatus(status);
    } catch (e, stackTrace) {
      Logger.error('Failed to get transports by status', e, stackTrace);
      return [];
    }
  }

  Future<List<TransportModel>> getTransportsByVehicleId(String vehicleId) async {
    try {
      return await _repository.getByVehicleId(vehicleId);
    } catch (e, stackTrace) {
      Logger.error('Failed to get transports by vehicle', e, stackTrace);
      return [];
    }
  }

  Future<List<TransportModel>> getTransportsByDateRange(DateTime start, DateTime end) async {
    try {
      return await _repository.getByDateRange(start, end);
    } catch (e, stackTrace) {
      Logger.error('Failed to get transports by date range', e, stackTrace);
      return [];
    }
  }

  Future<void> _reserveProductStock(TransportItemModel item) async {
    try {
      final product = await _productRepository.getById(item.productId);
      if (product != null) {
        if (product.stockQuantity < item.quantity.toInt()) {
          throw ValidationException(
            'Insufficient stock for ${item.productName}. Available: ${product.stockQuantity}, Required: ${item.quantity.toInt()}',
          );
        }
        final updated = product.copyWith(
          stockQuantity: product.stockQuantity - item.quantity.toInt(),
          updatedAt: DateTime.now(),
        );
        await _productRepository.update(updated);
      }
    } catch (e) {
      if (e is ValidationException) rethrow;
      Logger.warning('Failed to reserve stock for product: ${item.productId}', e);
    }
  }

  Future<void> _restoreProductStock(TransportItemModel item) async {
    try {
      final product = await _productRepository.getById(item.productId);
      if (product != null) {
        final updated = product.copyWith(
          stockQuantity: product.stockQuantity + item.quantity.toInt(),
          updatedAt: DateTime.now(),
        );
        await _productRepository.update(updated);
      }
    } catch (e) {
      Logger.warning('Failed to restore stock for product: ${item.productId}', e);
    }
  }

  String _generateId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp % 10000).toString().padLeft(4, '0');
    return 'TRP-$timestamp-$random';
  }
}
