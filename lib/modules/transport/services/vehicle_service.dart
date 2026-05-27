import 'package:smarterp/core/exceptions/app_exception.dart';
import 'package:smarterp/core/models/vehicle_model.dart';
import 'package:smarterp/core/utils/logger.dart';
import 'package:smarterp/modules/transport/repositories/vehicle_repository.dart';

class VehicleService {
  final VehicleRepository _repository;

  VehicleService(this._repository);

  Future<List<VehicleModel>> getAllVehicles() async {
    try {
      return await _repository.getAll();
    } catch (e, stackTrace) {
      Logger.error('Failed to get all vehicles', e, stackTrace);
      rethrow;
    }
  }

  Future<VehicleModel?> getVehicleById(String id) async {
    try {
      return await _repository.getById(id);
    } catch (e, stackTrace) {
      Logger.error('Failed to get vehicle by id', e, stackTrace);
      return null;
    }
  }

  Future<VehicleModel> createVehicle({
    required String vehicleNumber,
    required String vehicleType,
    required double capacity,
    String capacityUnit = 'Ton',
    String? driverName,
    String? driverPhone,
  }) async {
    try {
      _validateVehicleData(
        vehicleNumber: vehicleNumber,
        capacity: capacity,
      );

      final exists = await _repository.vehicleNumberExists(vehicleNumber);
      if (exists) {
        throw ValidationException('Vehicle with this number already exists');
      }

      final vehicle = VehicleModel.create(
        vehicleNumber: vehicleNumber.trim().toUpperCase(),
        vehicleType: vehicleType,
        capacity: capacity,
        capacityUnit: capacityUnit,
        driverName: driverName?.trim(),
        driverPhone: driverPhone?.trim(),
      );

      await _repository.save(vehicle);
      Logger.success('Vehicle created: ${vehicle.vehicleNumber}');
      return vehicle;
    } catch (e, stackTrace) {
      Logger.error('Failed to create vehicle', e, stackTrace);
      rethrow;
    }
  }

  Future<VehicleModel> updateVehicle({
    required String id,
    required String vehicleNumber,
    required String vehicleType,
    required double capacity,
    String capacityUnit = 'Ton',
    String? driverName,
    String? driverPhone,
    required bool isActive,
  }) async {
    try {
      _validateVehicleData(
        vehicleNumber: vehicleNumber,
        capacity: capacity,
      );

      final existing = await _repository.getById(id);
      if (existing == null) {
        throw NotFoundException('Vehicle not found');
      }

      final updated = existing.copyWith(
        vehicleNumber: vehicleNumber.trim().toUpperCase(),
        vehicleType: vehicleType,
        capacity: capacity,
        capacityUnit: capacityUnit,
        driverName: driverName?.trim(),
        driverPhone: driverPhone?.trim(),
        isActive: isActive,
        updatedAt: DateTime.now(),
      );

      await _repository.update(updated);
      Logger.success('Vehicle updated: ${updated.vehicleNumber}');
      return updated;
    } catch (e, stackTrace) {
      Logger.error('Failed to update vehicle', e, stackTrace);
      rethrow;
    }
  }

  Future<void> deleteVehicle(String id) async {
    try {
      final vehicle = await _repository.getById(id);
      if (vehicle == null) {
        throw NotFoundException('Vehicle not found');
      }
      await _repository.delete(id);
      Logger.success('Vehicle deleted: ${vehicle.vehicleNumber}');
    } catch (e, stackTrace) {
      Logger.error('Failed to delete vehicle', e, stackTrace);
      rethrow;
    }
  }

  Future<List<VehicleModel>> searchVehicles(String query) async {
    try {
      if (query.trim().isEmpty) {
        return await getAllVehicles();
      }
      return await _repository.search(query);
    } catch (e, stackTrace) {
      Logger.error('Failed to search vehicles', e, stackTrace);
      return [];
    }
  }

  void _validateVehicleData({
    required String vehicleNumber,
    required double capacity,
  }) {
    if (vehicleNumber.trim().isEmpty) {
      throw ValidationException('Vehicle number is required');
    }
    if (capacity <= 0) {
      throw ValidationException('Capacity must be greater than 0');
    }
  }
}
