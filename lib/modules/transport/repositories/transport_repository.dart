import 'package:smarterp/core/exceptions/app_exception.dart';
import 'package:smarterp/core/models/transport_model.dart';
import 'package:smarterp/core/models/transport_item_model.dart';
import 'package:smarterp/core/models/transport_status_model.dart';
import 'package:smarterp/core/storage/storage_service.dart';
import 'package:smarterp/core/utils/logger.dart';

class TransportRepository {
  final StorageService<Map<dynamic, dynamic>> _transportStorage;
  final StorageService<Map<dynamic, dynamic>> _itemStorage;

  TransportRepository({
    required StorageService<Map<dynamic, dynamic>> transportStorage,
    required StorageService<Map<dynamic, dynamic>> itemStorage,
  })  : _transportStorage = transportStorage,
        _itemStorage = itemStorage;

  Future<List<TransportModel>> getAll() async {
    try {
      final data = _transportStorage.getAll();
      return data
          .map((item) => TransportModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } catch (e, stackTrace) {
      Logger.error('Failed to get all transports', e, stackTrace);
      throw StorageException('Failed to retrieve transports');
    }
  }

  Future<TransportModel?> getById(String id) async {
    try {
      final data = _transportStorage.get(id);
      if (data == null) return null;
      return TransportModel.fromJson(Map<String, dynamic>.from(data));
    } catch (e, stackTrace) {
      Logger.error('Failed to get transport by id: $id', e, stackTrace);
      return null;
    }
  }

  Future<void> save(TransportModel transport) async {
    try {
      await _transportStorage.save(transport.id, transport.toJson());
      Logger.success('Transport saved: ${transport.transportNumber}');
    } catch (e, stackTrace) {
      Logger.error('Failed to save transport', e, stackTrace);
      throw StorageException('Failed to save transport');
    }
  }

  Future<void> update(TransportModel transport) async {
    try {
      await _transportStorage.save(transport.id, transport.toJson());
      Logger.success('Transport updated: ${transport.transportNumber}');
    } catch (e, stackTrace) {
      Logger.error('Failed to update transport', e, stackTrace);
      throw StorageException('Failed to update transport');
    }
  }

  Future<void> delete(String id) async {
    try {
      final transport = await getById(id);
      if (transport != null) {
        for (final itemId in transport.itemIds) {
          await _itemStorage.delete(itemId);
        }
      }
      await _transportStorage.delete(id);
      Logger.success('Transport deleted: $id');
    } catch (e, stackTrace) {
      Logger.error('Failed to delete transport', e, stackTrace);
      throw StorageException('Failed to delete transport');
    }
  }

  Future<List<TransportItemModel>> getItemsByIds(List<String> ids) async {
    try {
      if (ids.isEmpty) return [];
      final result = <TransportItemModel>[];
      for (final id in ids) {
        final data = _itemStorage.get(id);
        if (data != null) {
          result.add(TransportItemModel.fromJson(Map<String, dynamic>.from(data)));
        }
      }
      return result;
    } catch (e, stackTrace) {
      Logger.error('Failed to get transport items', e, stackTrace);
      return [];
    }
  }

  Future<void> saveItem(TransportItemModel item) async {
    try {
      await _itemStorage.save(item.id, item.toJson());
    } catch (e, stackTrace) {
      Logger.error('Failed to save transport item', e, stackTrace);
      throw StorageException('Failed to save transport item');
    }
  }

  Future<void> deleteItem(String id) async {
    try {
      await _itemStorage.delete(id);
    } catch (e, stackTrace) {
      Logger.error('Failed to delete transport item', e, stackTrace);
      throw StorageException('Failed to delete transport item');
    }
  }

  Future<String> getNextTransportNumber() async {
    try {
      final all = await getAll();
      if (all.isEmpty) return 'TRP-0001';
      final maxNumber = all.map((t) {
        final parts = t.transportNumber.split('-');
        if (parts.length == 2) {
          return int.tryParse(parts[1]) ?? 0;
        }
        return 0;
      }).reduce((a, b) => a > b ? a : b);
      return 'TRP-${(maxNumber + 1).toString().padLeft(4, '0')}';
    } catch (e, stackTrace) {
      Logger.error('Failed to generate transport number', e, stackTrace);
      return 'TRP-0001';
    }
  }

  Future<List<TransportModel>> getByStatus(TransportStatus status) async {
    try {
      final all = await getAll();
      return all.where((t) => t.status == status).toList();
    } catch (e, stackTrace) {
      Logger.error('Failed to get transports by status', e, stackTrace);
      return [];
    }
  }

  Future<List<TransportModel>> getByVehicleId(String vehicleId) async {
    try {
      final all = await getAll();
      return all.where((t) => t.vehicleId == vehicleId).toList();
    } catch (e, stackTrace) {
      Logger.error('Failed to get transports by vehicle', e, stackTrace);
      return [];
    }
  }

  Future<List<TransportModel>> getByDateRange(DateTime start, DateTime end) async {
    try {
      final all = await getAll();
      return all.where((t) =>
          t.departureDate.isAfter(start.subtract(const Duration(days: 1))) &&
          t.departureDate.isBefore(end.add(const Duration(days: 1)))).toList();
    } catch (e, stackTrace) {
      Logger.error('Failed to get transports by date range', e, stackTrace);
      return [];
    }
  }

  Future<int> getTotalCount() async {
    try {
      return _transportStorage.getAll().length;
    } catch (e, stackTrace) {
      Logger.error('Failed to get transport count', e, stackTrace);
      return 0;
    }
  }
}
