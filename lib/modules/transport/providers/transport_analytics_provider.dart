import 'package:flutter/foundation.dart';
import 'package:smarterp/core/models/transport_model.dart';
import 'package:smarterp/core/models/transport_status_model.dart';
import 'package:smarterp/core/utils/logger.dart';
import 'package:smarterp/modules/transport/services/transport_service.dart';

class TransportAnalyticsProvider extends ChangeNotifier {
  final TransportService _service;

  TransportAnalyticsProvider(this._service);

  List<TransportModel> _allTransports = [];
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int get totalTransports => _allTransports.length;
  int get completedTransports =>
      _allTransports.where((t) => t.isDelivered).length;
  int get plannedTransports =>
      _allTransports.where((t) => t.isPlanned).length;
  int get cancelledTransports =>
      _allTransports.where((t) => t.isCancelled).length;
  int get activeTransports =>
      _allTransports.where((t) => t.isActive).length;

  double get completionRate =>
      totalTransports > 0 ? completedTransports / totalTransports : 0;
  double get cancellationRate =>
      totalTransports > 0 ? cancelledTransports / totalTransports : 0;

  Map<TransportStatus, int> get statusDistribution {
    return {
      TransportStatus.planned: plannedTransports,
      TransportStatus.onTheWay: activeTransports - plannedTransports,
      TransportStatus.delivered: completedTransports,
      TransportStatus.cancelled: cancelledTransports,
    };
  }

  List<_DestinationStat> get destinationStats {
    final map = <String, _DestinationStat>{};
    for (final t in _allTransports) {
      final stat = map.putIfAbsent(t.destination, () => _DestinationStat(destination: t.destination));
      stat.count++;
      if (t.isDelivered) stat.delivered++;
      if (t.isCancelled) stat.cancelled++;
    }
    final result = map.values.toList();
    result.sort((a, b) => b.count.compareTo(a.count));
    return result.take(10).toList();
  }

  Map<String, int> get vehicleUsage {
    final map = <String, int>{};
    for (final t in _allTransports) {
      map[t.vehicleNumber] = (map[t.vehicleNumber] ?? 0) + 1;
    }
    return map;
  }

  List<int> get weeklyTrend {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 6));
    final data = <int>[0, 0, 0, 0, 0, 0, 0];
    for (final t in _allTransports) {
      final diff = t.departureDate.difference(weekAgo).inDays;
      if (diff >= 0 && diff < 7) {
        data[diff]++;
      }
    }
    return data;
  }

  List<int> get monthlyTrend {
    final data = <int>[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
    final now = DateTime.now();
    for (final t in _allTransports) {
      if (t.departureDate.year == now.year) {
        data[t.departureDate.month - 1]++;
      }
    }
    return data;
  }

  Future<void> loadAnalytics() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _allTransports = await _service.getAllTransports();

      _isLoading = false;
      notifyListeners();
    } catch (e, stackTrace) {
      _isLoading = false;
      _errorMessage = 'Failed to load analytics';
      notifyListeners();
      Logger.error('Failed to load analytics', e, stackTrace);
    }
  }
}

class _DestinationStat {
  final String destination;
  int count = 0;
  int delivered = 0;
  int cancelled = 0;

  _DestinationStat({required this.destination});
}
