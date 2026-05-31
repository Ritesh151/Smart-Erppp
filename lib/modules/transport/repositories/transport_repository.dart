import '../../../core/storage/storage_service.dart';
import '../../../core/utils/logger.dart';
import '../models/transport_screen_model.dart';

class TransportRepository {
  TransportRepository({
    required StorageService<Map<dynamic, dynamic>> transportStorage,
  }) : _transportStorage = transportStorage;

  final StorageService<Map<dynamic, dynamic>> _transportStorage;

  Future<List<TransportModel>> getAll() async {
    try {
      final data = _transportStorage.getAll();
      return data
          .map((item) =>
              TransportModel.fromMap(Map<String, dynamic>.from(item)))
          .toList();
    } on Exception catch (e, stackTrace) {
      Logger.error('Failed to get all transports', e, stackTrace);
      return [];
    }
  }

  Future<TransportModel?> getById(String id) async {
    try {
      final data = _transportStorage.get(id);
      if (data == null) {
        return null;
      }
      return TransportModel.fromMap(Map<String, dynamic>.from(data));
    } on Exception catch (e, stackTrace) {
      Logger.error('Failed to get transport by id: $id', e, stackTrace);
      return null;
    }
  }

  Future<void> save(TransportModel transport) async {
    try {
      await _transportStorage.save(
          transport.transportId, transport.toMap());
      Logger.success('Transport saved: ${transport.transportId}');
    } on Exception catch (e, stackTrace) {
      Logger.error('Failed to save transport', e, stackTrace);
      rethrow;
    }
  }

  Future<void> update(TransportModel transport) async {
    try {
      await _transportStorage.update(
          transport.transportId, transport.toMap());
      Logger.success('Transport updated: ${transport.transportId}');
    } on Exception catch (e, stackTrace) {
      Logger.error('Failed to update transport', e, stackTrace);
      rethrow;
    }
  }

  Future<void> delete(String id) async {
    try {
      await _transportStorage.delete(id);
      Logger.success('Transport deleted: $id');
    } on Exception catch (e, stackTrace) {
      Logger.error('Failed to delete transport', e, stackTrace);
      rethrow;
    }
  }

  Future<List<TransportModel>> search(String query) async {
    try {
      final all = await getAll();
      final q = query.toLowerCase();
      return all.where((t) =>
          t.transportName.toLowerCase().contains(q) ||
          t.destinationLocation.toLowerCase().contains(q) ||
          t.driverName.toLowerCase().contains(q) ||
          (t.vehicleNumber?.toLowerCase().contains(q) ?? false) ||
          t.products.any((p) => p.productName.toLowerCase().contains(q))).toList();
    } on Exception catch (e, stackTrace) {
      Logger.error('Failed to search transports', e, stackTrace);
      return [];
    }
  }
}
