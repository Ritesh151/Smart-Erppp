import 'package:flutter/foundation.dart';
import 'package:smarterp/core/exceptions/app_exception.dart';
import 'package:smarterp/core/models/transport_model.dart';
import 'package:smarterp/core/models/transport_item_model.dart';
import 'package:smarterp/core/models/transport_status_model.dart';
import 'package:smarterp/core/utils/logger.dart';
import 'package:smarterp/modules/transport/services/transport_service.dart';
import 'package:smarterp/modules/transport/services/transport_status_service.dart';

class TransportProvider extends ChangeNotifier {
  final TransportService _service;
  final TransportStatusService _statusService;

  TransportProvider({
    required TransportService service,
    required TransportStatusService statusService,
  })  : _service = service,
        _statusService = statusService;

  List<TransportModel> _transports = [];
  List<TransportModel> _filteredTransports = [];
  TransportModel? _selectedTransport;
  List<TransportItemModel> _selectedTransportItems = [];

  List<TransportItemModel> _editingItems = [];
  String _editingOrigin = '';
  String _editingDestination = '';
  DateTime _editingDepartureDate = DateTime.now();
  DateTime? _editingEstimatedArrival;
  String _editingNotes = '';
  String _editingVehicleId = '';
  String _editingVehicleNumber = '';
  String _editingDriverName = '';
  String _editingDriverPhone = '';

  bool _isLoading = false;
  bool _isSearching = false;
  String? _errorMessage;
  String _searchQuery = '';
  TransportStatus? _selectedStatus;

  List<TransportModel> get transports =>
      _filteredTransports.isEmpty && _searchQuery.isEmpty
          ? _transports
          : _filteredTransports;

  TransportModel? get selectedTransport => _selectedTransport;
  List<TransportItemModel> get selectedTransportItems => _selectedTransportItems;

  List<TransportItemModel> get editingItems => _editingItems;
  String get editingOrigin => _editingOrigin;
  String get editingDestination => _editingDestination;
  DateTime get editingDepartureDate => _editingDepartureDate;
  DateTime? get editingEstimatedArrival => _editingEstimatedArrival;
  String get editingNotes => _editingNotes;
  String get editingVehicleId => _editingVehicleId;
  String get editingVehicleNumber => _editingVehicleNumber;
  String get editingDriverName => _editingDriverName;
  String get editingDriverPhone => _editingDriverPhone;

  bool get isLoading => _isLoading;
  bool get isSearching => _isSearching;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  TransportStatus? get selectedStatus => _selectedStatus;

  int get totalTransports => _transports.length;
  int get plannedCount => _transports.where((t) => t.isPlanned).length;
  int get onTheWayCount => _transports.where((t) => t.isOnTheWay).length;
  int get deliveredCount => _transports.where((t) => t.isDelivered).length;
  int get cancelledCount => _transports.where((t) => t.isCancelled).length;
  int get activeCount => _transports.where((t) => t.isActive).length;

  Future<void> loadTransports() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _transports = await _service.getAllTransports();

      _isLoading = false;
      notifyListeners();
      Logger.success('Transports loaded: ${_transports.length}');
    } catch (e, stackTrace) {
      _isLoading = false;
      _errorMessage = 'Failed to load transports';
      notifyListeners();
      Logger.error('Failed to load transports', e, stackTrace);
    }
  }

  Future<void> loadTransportDetails(String id) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _selectedTransport = await _service.getTransportById(id);
      if (_selectedTransport != null) {
        _selectedTransportItems = await _service.getTransportItems(_selectedTransport!);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e, stackTrace) {
      _isLoading = false;
      _errorMessage = 'Failed to load transport details';
      notifyListeners();
      Logger.error('Failed to load transport details', e, stackTrace);
    }
  }

  void resetEditingState() {
    _editingItems.clear();
    _editingOrigin = '';
    _editingDestination = '';
    _editingDepartureDate = DateTime.now();
    _editingEstimatedArrival = null;
    _editingNotes = '';
    _editingVehicleId = '';
    _editingVehicleNumber = '';
    _editingDriverName = '';
    _editingDriverPhone = '';
    notifyListeners();
  }

  void addItem(TransportItemModel item) {
    _editingItems.add(item);
    notifyListeners();
  }

  void removeItem(int index) {
    if (index >= 0 && index < _editingItems.length) {
      _editingItems.removeAt(index);
      notifyListeners();
    }
  }

  void setEditingOrigin(String v) { _editingOrigin = v; notifyListeners(); }
  void setEditingDestination(String v) { _editingDestination = v; notifyListeners(); }
  void setEditingDepartureDate(DateTime v) { _editingDepartureDate = v; notifyListeners(); }
  void setEditingEstimatedArrival(DateTime? v) { _editingEstimatedArrival = v; notifyListeners(); }
  void setEditingNotes(String v) { _editingNotes = v; notifyListeners(); }
  void setEditingVehicleId(String v) { _editingVehicleId = v; notifyListeners(); }
  void setEditingVehicleNumber(String v) { _editingVehicleNumber = v; notifyListeners(); }
  void setEditingDriverName(String v) { _editingDriverName = v; notifyListeners(); }
  void setEditingDriverPhone(String v) { _editingDriverPhone = v; notifyListeners(); }

  Future<void> createTransport() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final transport = await _service.createTransport(
        vehicleId: _editingVehicleId,
        vehicleNumber: _editingVehicleNumber,
        driverName: _editingDriverName.isNotEmpty ? _editingDriverName : null,
        driverPhone: _editingDriverPhone.isNotEmpty ? _editingDriverPhone : null,
        origin: _editingOrigin,
        destination: _editingDestination,
        departureDate: _editingDepartureDate,
        estimatedArrival: _editingEstimatedArrival,
        items: List.from(_editingItems),
        notes: _editingNotes.isNotEmpty ? _editingNotes : null,
      );

      _transports.add(transport);

      _isLoading = false;
      notifyListeners();
      Logger.success('Transport created: ${transport.transportNumber}');
    } on ValidationException catch (e) {
      _isLoading = false;
      _errorMessage = e.message;
      notifyListeners();
      rethrow;
    } catch (e, stackTrace) {
      _isLoading = false;
      _errorMessage = 'Failed to create transport';
      notifyListeners();
      Logger.error('Failed to create transport', e, stackTrace);
      rethrow;
    }
  }

  Future<void> advanceStatus(String id) async {
    try {
      final updated = await _statusService.advanceStatus(id);
      await _refreshTransport(id);
      Logger.success('Transport status advanced');
    } catch (e, stackTrace) {
      _errorMessage = 'Failed to advance status';
      notifyListeners();
      Logger.error('Failed to advance status', e, stackTrace);
      rethrow;
    }
  }

  Future<void> cancelTransport(String id) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _statusService.cancelTransport(id);
      await _refreshTransport(id);

      _isLoading = false;
      notifyListeners();
      Logger.success('Transport cancelled');
    } catch (e, stackTrace) {
      _isLoading = false;
      _errorMessage = 'Failed to cancel transport';
      notifyListeners();
      Logger.error('Failed to cancel transport', e, stackTrace);
      rethrow;
    }
  }

  Future<void> deleteTransport(String id) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _service.deleteTransport(id);
      _transports.removeWhere((t) => t.id == id);
      _filteredTransports.removeWhere((t) => t.id == id);

      if (_selectedTransport?.id == id) {
        _selectedTransport = null;
        _selectedTransportItems = [];
      }

      _isLoading = false;
      notifyListeners();
      Logger.success('Transport deleted');
    } catch (e, stackTrace) {
      _isLoading = false;
      _errorMessage = 'Failed to delete transport';
      notifyListeners();
      Logger.error('Failed to delete transport', e, stackTrace);
      rethrow;
    }
  }

  Future<void> _refreshTransport(String id) async {
    final index = _transports.indexWhere((t) => t.id == id);
    if (index != -1) {
      final refreshed = await _service.getTransportById(id);
      if (refreshed != null) {
        _transports[index] = refreshed;
      }
    }
    if (_selectedTransport?.id == id) {
      _selectedTransport = await _service.getTransportById(id);
      if (_selectedTransport != null) {
        _selectedTransportItems = await _service.getTransportItems(_selectedTransport!);
      }
    }
    notifyListeners();
  }

  void selectTransport(TransportModel? transport) {
    _selectedTransport = transport;
    if (transport != null) {
      loadTransportDetails(transport.id);
    } else {
      _selectedTransportItems = [];
      notifyListeners();
    }
  }

  Future<void> searchTransports(String query) async {
    try {
      _isSearching = true;
      _searchQuery = query;
      notifyListeners();

      if (query.trim().isEmpty) {
        _filteredTransports = [];
      } else {
        final q = query.toLowerCase();
        _filteredTransports = _transports.where((t) {
          return t.transportNumber.toLowerCase().contains(q) ||
              t.origin.toLowerCase().contains(q) ||
              t.destination.toLowerCase().contains(q) ||
              t.vehicleNumber.toLowerCase().contains(q);
        }).toList();
      }

      _isSearching = false;
      notifyListeners();
    } catch (e, stackTrace) {
      _isSearching = false;
      notifyListeners();
      Logger.error('Failed to search transports', e, stackTrace);
    }
  }

  void filterByStatus(TransportStatus? status) {
    _selectedStatus = status;
    _applyFilters();
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    _filteredTransports = [];
    notifyListeners();
  }

  void clearFilters() {
    _selectedStatus = null;
    _searchQuery = '';
    _filteredTransports = [];
    notifyListeners();
  }

  void _applyFilters() {
    var filtered = List<TransportModel>.from(_transports);
    if (_selectedStatus != null) {
      filtered = filtered.where((t) => t.status == _selectedStatus).toList();
    }
    _filteredTransports = filtered;
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
