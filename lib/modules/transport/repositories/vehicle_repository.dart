import '../../../core/models/vehicle_model.dart';
import '../../../core/storage/storage_service.dart';
import '../../../core/utils/logger.dart';

class VehicleRepository {
  VehicleRepository(this._storage);

  final StorageService<Map<dynamic, dynamic>> _storage;

  Future<List<VehicleModel>> getAll() async {
    try {
      final data = _storage.getAll();
      return data
          .map((item) =>
              VehicleModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } on Exception catch (e, stackTrace) {
      Logger.error('Failed to get all vehicles', e, stackTrace);
      return [];
    }
  }

  Future<VehicleModel?> getById(String id) async {
    try {
      final data = _storage.get(id);
      if (data == null) {
        return null;
      }
      return VehicleModel.fromJson(Map<String, dynamic>.from(data));
    } on Exception catch (e, stackTrace) {
      Logger.error('Failed to get vehicle by id: $id', e, stackTrace);
      return null;
    }
  }

  Future<void> save(VehicleModel vehicle) async {
    try {
      await _storage.save(vehicle.id, vehicle.toJson());
      Logger.success('Vehicle saved: ${vehicle.id}');
    } on Exception catch (e, stackTrace) {
      Logger.error('Failed to save vehicle', e, stackTrace);
      rethrow;
    }
  }

  Future<void> update(VehicleModel vehicle) async {
    try {
      await _storage.update(vehicle.id, vehicle.toJson());
      Logger.success('Vehicle updated: ${vehicle.id}');
    } on Exception catch (e, stackTrace) {
      Logger.error('Failed to update vehicle', e, stackTrace);
      rethrow;
    }
  }

  Future<void> delete(String id) async {
    try {
      await _storage.delete(id);
      Logger.success('Vehicle deleted: $id');
    } on Exception catch (e, stackTrace) {
      Logger.error('Failed to delete vehicle', e, stackTrace);
      rethrow;
    }
  }
}
