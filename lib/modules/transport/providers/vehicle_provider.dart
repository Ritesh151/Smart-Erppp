import 'package:flutter/foundation.dart';
import 'package:smarterp/core/exceptions/app_exception.dart';
import 'package:smarterp/core/models/vehicle_model.dart';
import 'package:smarterp/core/utils/logger.dart';
import 'package:smarterp/modules/transport/services/vehicle_service.dart';

class VehicleProvider extends ChangeNotifier {
  final VehicleService _service;

  VehicleProvider(this._service);

  List<VehicleModel> _vehicles = [];
  List<VehicleModel> _filteredVehicles = [];
  VehicleModel? _selectedVehicle;

  bool _isLoading = false;
  bool _isSearching = false;
  String? _errorMessage;
  String _searchQuery = '';

  List<VehicleModel> get vehicles =>
      _filteredVehicles.isEmpty && _searchQuery.isEmpty
          ? _vehicles
          : _filteredVehicles;

  VehicleModel? get selectedVehicle => _selectedVehicle;
  bool get isLoading => _isLoading;
  bool get isSearching => _isSearching;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;

  int get totalVehicles => _vehicles.length;
  int get activeVehicles => _vehicles.where((v) => v.isActive).length;

  Future<void> loadVehicles() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _vehicles = await _service.getAllVehicles();

      _isLoading = false;
      notifyListeners();
      Logger.success('Vehicles loaded: ${_vehicles.length}');
    } catch (e, stackTrace) {
      _isLoading = false;
      _errorMessage = 'Failed to load vehicles';
      notifyListeners();
      Logger.error('Failed to load vehicles', e, stackTrace);
    }
  }

  Future<void> createVehicle({
    required String vehicleNumber,
    required String vehicleType,
    required double capacity,
    String capacityUnit = 'Ton',
    String? driverName,
    String? driverPhone,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final vehicle = await _service.createVehicle(
        vehicleNumber: vehicleNumber,
        vehicleType: vehicleType,
        capacity: capacity,
        capacityUnit: capacityUnit,
        driverName: driverName,
        driverPhone: driverPhone,
      );

      _vehicles.add(vehicle);

      _isLoading = false;
      notifyListeners();
      Logger.success('Vehicle created successfully');
    } on ValidationException catch (e) {
      _isLoading = false;
      _errorMessage = e.message;
      notifyListeners();
      rethrow;
    } catch (e, stackTrace) {
      _isLoading = false;
      _errorMessage = 'Failed to create vehicle';
      notifyListeners();
      Logger.error('Failed to create vehicle', e, stackTrace);
      rethrow;
    }
  }

  Future<void> updateVehicle({
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
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final updated = await _service.updateVehicle(
        id: id,
        vehicleNumber: vehicleNumber,
        vehicleType: vehicleType,
        capacity: capacity,
        capacityUnit: capacityUnit,
        driverName: driverName,
        driverPhone: driverPhone,
        isActive: isActive,
      );

      final index = _vehicles.indexWhere((v) => v.id == id);
      if (index != -1) {
        _vehicles[index] = updated;
      }

      _isLoading = false;
      notifyListeners();
      Logger.success('Vehicle updated successfully');
    } on ValidationException catch (e) {
      _isLoading = false;
      _errorMessage = e.message;
      notifyListeners();
      rethrow;
    } catch (e, stackTrace) {
      _isLoading = false;
      _errorMessage = 'Failed to update vehicle';
      notifyListeners();
      Logger.error('Failed to update vehicle', e, stackTrace);
      rethrow;
    }
  }

  Future<void> deleteVehicle(String id) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _service.deleteVehicle(id);
      _vehicles.removeWhere((v) => v.id == id);

      if (_selectedVehicle?.id == id) {
        _selectedVehicle = null;
      }

      _isLoading = false;
      notifyListeners();
      Logger.success('Vehicle deleted successfully');
    } catch (e, stackTrace) {
      _isLoading = false;
      _errorMessage = 'Failed to delete vehicle';
      notifyListeners();
      Logger.error('Failed to delete vehicle', e, stackTrace);
      rethrow;
    }
  }

  Future<void> searchVehicles(String query) async {
    try {
      _isSearching = true;
      _searchQuery = query;
      notifyListeners();

      if (query.trim().isEmpty) {
        _filteredVehicles = [];
      } else {
        _filteredVehicles = await _service.searchVehicles(query);
      }

      _isSearching = false;
      notifyListeners();
    } catch (e, stackTrace) {
      _isSearching = false;
      notifyListeners();
      Logger.error('Failed to search vehicles', e, stackTrace);
    }
  }

  void clearSearch() {
    _searchQuery = '';
    _filteredVehicles = [];
    notifyListeners();
  }

  void selectVehicle(VehicleModel? vehicle) {
    _selectedVehicle = vehicle;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
