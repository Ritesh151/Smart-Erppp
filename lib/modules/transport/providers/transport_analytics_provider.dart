import 'package:flutter/foundation.dart';
import 'package:SmartERP/modules/transport/models/transport_screen_model.dart';
import 'package:SmartERP/modules/transport/services/transport_service.dart';

class TransportAnalyticsProvider extends ChangeNotifier {
  final TransportService _service;

  int _totalTransports = 0;
  int _plannedCount = 0;
  int _inTransitCount = 0;
  int _deliveredCount = 0;
  int _cancelledCount = 0;
  double _totalQuantity = 0;
  bool _isLoading = false;

  int get totalTransports => _totalTransports;
  int get plannedCount => _plannedCount;
  int get inTransitCount => _inTransitCount;
  int get deliveredCount => _deliveredCount;
  int get cancelledCount => _cancelledCount;
  double get totalQuantity => _totalQuantity;
  bool get isLoading => _isLoading;

  TransportAnalyticsProvider(this._service);

  Future<void> loadAnalytics() async {
    _isLoading = true;
    notifyListeners();

    try {
      final transports = await _service.getAllTransports();
      _totalTransports = transports.length;
      _plannedCount =
          transports.where((t) => t.status == ExportStatus.planned).length;
      _inTransitCount =
          transports.where((t) => t.status == ExportStatus.inTransit).length;
      _deliveredCount =
          transports.where((t) => t.status == ExportStatus.delivered).length;
      _cancelledCount =
          transports.where((t) => t.status == ExportStatus.cancelled).length;
      _totalQuantity =
          transports.fold<double>(0, (sum, t) => sum + t.totalQuantity);
    } catch (_) {
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
