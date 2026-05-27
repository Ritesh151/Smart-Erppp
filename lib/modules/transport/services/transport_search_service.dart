import 'package:smarterp/core/models/transport_model.dart';
import 'package:smarterp/core/models/transport_status_model.dart';
import 'package:smarterp/core/utils/logger.dart';
import 'package:smarterp/modules/transport/repositories/transport_repository.dart';

class TransportFilter {
  final String? keyword;
  final TransportStatus? status;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? vehicleId;
  final String? vehicleNumber;

  TransportFilter({
    this.keyword,
    this.status,
    this.startDate,
    this.endDate,
    this.vehicleId,
    this.vehicleNumber,
  });

  bool get hasActiveFilters =>
      keyword != null ||
      status != null ||
      startDate != null ||
      endDate != null ||
      vehicleId != null ||
      vehicleNumber != null;
}

class TransportSearchService {
  final TransportRepository _repository;

  TransportSearchService(this._repository);

  Future<List<TransportModel>> search(TransportFilter filter) async {
    try {
      List<TransportModel> results = await _repository.getAll();

      if (filter.status != null) {
        results = results.where((t) => t.status == filter.status).toList();
      }

      if (filter.startDate != null || filter.endDate != null) {
        final start = filter.startDate ?? DateTime(2020);
        final end = filter.endDate ?? DateTime(2030);
        results = results.where((t) =>
            t.departureDate.isAfter(start.subtract(const Duration(days: 1))) &&
            t.departureDate.isBefore(end.add(const Duration(days: 1)))).toList();
      }

      if (filter.vehicleId != null && filter.vehicleId!.isNotEmpty) {
        results = results.where((t) => t.vehicleId == filter.vehicleId).toList();
      }

      if (filter.vehicleNumber != null && filter.vehicleNumber!.isNotEmpty) {
        final q = filter.vehicleNumber!.toLowerCase();
        results = results.where((t) => t.vehicleNumber.toLowerCase().contains(q)).toList();
      }

      if (filter.keyword != null && filter.keyword!.trim().isNotEmpty) {
        final q = filter.keyword!.trim().toLowerCase();
        results = results.where((t) =>
            t.transportNumber.toLowerCase().contains(q) ||
            t.origin.toLowerCase().contains(q) ||
            t.destination.toLowerCase().contains(q) ||
            t.vehicleNumber.toLowerCase().contains(q) ||
            (t.driverName?.toLowerCase().contains(q) ?? false)).toList();
      }

      return results;
    } catch (e, stackTrace) {
      Logger.error('Failed to search transports', e, stackTrace);
      return [];
    }
  }

  Future<List<TransportModel>> searchByKeyword(String keyword) async {
    return search(TransportFilter(keyword: keyword));
  }

  Future<List<TransportModel>> searchByDateRange(DateTime start, DateTime end) async {
    return search(TransportFilter(startDate: start, endDate: end));
  }

  Future<List<TransportModel>> searchByVehicleNumber(String vehicleNumber) async {
    return search(TransportFilter(vehicleNumber: vehicleNumber));
  }

  Future<List<TransportModel>> searchByStatus(TransportStatus status) async {
    return search(TransportFilter(status: status));
  }

  Future<Map<String, int>> getStatusCounts() async {
    try {
      final all = await _repository.getAll();
      return {
        'planned': all.where((t) => t.isPlanned).length,
        'onTheWay': all.where((t) => t.isOnTheWay).length,
        'delivered': all.where((t) => t.isDelivered).length,
        'cancelled': all.where((t) => t.isCancelled).length,
      };
    } catch (e, stackTrace) {
      Logger.error('Failed to get status counts', e, stackTrace);
      return {};
    }
  }

  Future<List<TransportModel>> getRecentTransports({int limit = 10}) async {
    try {
      final all = await _repository.getAll();
      all.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return all.take(limit).toList();
    } catch (e, stackTrace) {
      Logger.error('Failed to get recent transports', e, stackTrace);
      return [];
    }
  }
}
