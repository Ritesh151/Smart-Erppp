import 'package:flutter/foundation.dart';
import '../models/transport_screen_model.dart';
import '../services/transport_service.dart';
import '../services/transport_status_service.dart';

class TransportProvider extends ChangeNotifier {
  TransportProvider({
    required this.service,
    required this.statusService,
  });

  final TransportService service;
  final TransportStatusService statusService;

  List<TransportModel> _transports = [];
  bool _isLoading = false;
  String? _error;

  List<TransportModel> get transports => _transports;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadTransports() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _transports = await service.getAllTransports();
    } on Exception catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addTransport(TransportModel transport) async {
    try {
      await service.saveTransport(transport);
      await loadTransports();
      return true;
    } on Exception catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateTransport(String id, TransportModel transport) async {
    try {
      await service.updateTransport(transport);
      await loadTransports();
      return true;
    } on Exception catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteTransport(String id) async {
    try {
      await service.deleteTransport(id);
      await loadTransports();
      return true;
    } on Exception catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateStatus(String id, ExportStatus status) async {
    try {
      await statusService.updateStatus(id, status);
      await loadTransports();
      return true;
    } on Exception catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
