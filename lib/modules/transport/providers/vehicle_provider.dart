import 'package:flutter/foundation.dart';
import 'package:SmartERP/core/models/vehicle_model.dart';
import 'package:SmartERP/modules/transport/services/vehicle_service.dart';

class VehicleProvider extends ChangeNotifier {
  final VehicleService _service;

  List<VehicleModel> _vehicles = [];
  bool _isLoading = false;
  String? _error;

  List<VehicleModel> get vehicles => _vehicles;
  bool get isLoading => _isLoading;
  String? get error => _error;

  VehicleProvider(this._service);

  Future<void> loadVehicles() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _vehicles = await _service.getAllVehicles();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addVehicle(VehicleModel vehicle) async {
    try {
      await _service.saveVehicle(vehicle);
      await loadVehicles();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateVehicle(VehicleModel vehicle) async {
    try {
      await _service.updateVehicle(vehicle);
      await loadVehicles();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteVehicle(String id) async {
    try {
      await _service.deleteVehicle(id);
      await loadVehicles();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
