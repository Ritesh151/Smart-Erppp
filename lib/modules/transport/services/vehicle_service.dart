import '../../../core/models/vehicle_model.dart';
import '../repositories/vehicle_repository.dart';

class VehicleService {
  VehicleService(this._repository);

  final VehicleRepository _repository;

  Future<List<VehicleModel>> getAllVehicles() => _repository.getAll();

  Future<VehicleModel?> getVehicle(String id) => _repository.getById(id);

  Future<void> saveVehicle(VehicleModel vehicle) =>
      _repository.save(vehicle);

  Future<void> updateVehicle(VehicleModel vehicle) =>
      _repository.update(vehicle);

  Future<void> deleteVehicle(String id) => _repository.delete(id);
}
