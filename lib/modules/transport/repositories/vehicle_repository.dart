import 'package:smarterp/core/exceptions/app_exception.dart';
import 'package:smarterp/core/models/vehicle_model.dart';
import 'package:smarterp/core/storage/storage_service.dart';
import 'package:smarterp/core/utils/logger.dart';

class VehicleRepository {
  final StorageService<Map<dynamic, dynamic>> _storage;

  VehicleRepository(this._storage);

  Future<List<VehicleModel>> getAll() async {
    try {
      final data = _storage.getAll();
      return data
          .map((item) => VehicleModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } catch (e, stackTrace) {
      Logger.error('Failed to get all vehicles', e, stackTrace);
      throw StorageException('Failed to retrieve vehicles');
    }
  }

  Future<VehicleModel?> getById(String id) async {
    try {
      final data = _storage.get(id);
      if (data == null) return null;
      return VehicleModel.fromJson(Map<String, dynamic>.from(data));
    } catch (e, stackTrace) {
      Logger.error('Failed to get vehicle by id: $id', e, stackTrace);
      return null;
    }
  }

  Future<void> save(VehicleModel vehicle) async {
    try {
      await _storage.save(vehicle.id, vehicle.toJson());
      Logger.success('Vehicle saved: ${vehicle.vehicleNumber}');
    } catch (e, stackTrace) {
      Logger.error('Failed to save vehicle', e, stackTrace);
      throw StorageException('Failed to save vehicle');
    }
  }

  Future<void> update(VehicleModel vehicle) async {
    try {
      await _storage.save(vehicle.id, vehicle.toJson());
      Logger.success('Vehicle updated: ${vehicle.vehicleNumber}');
    } catch (e, stackTrace) {
      Logger.error('Failed to update vehicle', e, stackTrace);
      throw StorageException('Failed to update vehicle');
    }
  }

  Future<void> delete(String id) async {
    try {
      await _storage.delete(id);
      Logger.success('Vehicle deleted: $id');
    } catch (e, stackTrace) {
      Logger.error('Failed to delete vehicle', e, stackTrace);
      throw StorageException('Failed to delete vehicle');
    }
  }

  Future<List<VehicleModel>> search(String query) async {
    try {
      final all = await getAll();
      final q = query.toLowerCase();
      return all.where((v) {
        return v.vehicleNumber.toLowerCase().contains(q) ||
            (v.driverName?.toLowerCase().contains(q) ?? false) ||
            v.vehicleType.toLowerCase().contains(q);
      }).toList();
    } catch (e, stackTrace) {
      Logger.error('Failed to search vehicles', e, stackTrace);
      return [];
    }
  }

  Future<bool> vehicleNumberExists(String vehicleNumber) async {
    try {
      final all = await getAll();
      return all.any((v) =>
          v.vehicleNumber.toLowerCase() == vehicleNumber.toLowerCase());
    } catch (e, stackTrace) {
      Logger.error('Failed to check vehicle number', e, stackTrace);
      return false;
    }
  }

  Future<int> getTotalCount() async {
    try {
      return _storage.getAll().length;
    } catch (e, stackTrace) {
      Logger.error('Failed to get vehicle count', e, stackTrace);
      return 0;
    }
  }
}
