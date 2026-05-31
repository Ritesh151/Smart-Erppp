import 'package:flutter/foundation.dart';
import '../../../core/models/vehicle_model.dart';
import '../services/vehicle_service.dart';

class VehicleProvider extends ChangeNotifier {
  VehicleProvider(this._service);

  final VehicleService _service;

  List<VehicleModel> _vehicles = [];
  bool _isLoading = false;
  String? _error;

  List<VehicleModel> get vehicles => _vehicles;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadVehicles() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _vehicles = await _service.getAllVehicles();
    } on Exception catch (e) {
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
    } on Exception catch (e) {
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
    } on Exception catch (e) {
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
    } on Exception catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
