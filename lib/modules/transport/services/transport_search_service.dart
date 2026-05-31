import 'package:flutter/material.dart';
import '../models/transport_screen_model.dart';
import '../repositories/transport_repository.dart';

class TransportSearchService {
  TransportSearchService(this._repository);

  final TransportRepository _repository;

  Future<List<TransportModel>> search(String query) =>
      _repository.search(query);

  Future<List<TransportModel>> filter({
    DateTimeRange? dateRange,
    String? product,
    String? destination,
    ExportStatus? status,
  }) async {
    var results = await _repository.getAll();

    if (dateRange != null) {
      results = results.where((t) =>
          t.transportDate.isAfter(dateRange.start) &&
          t.transportDate.isBefore(dateRange.end.add(const Duration(days: 1)))).toList();
    }

    if (product != null && product.isNotEmpty) {
      final q = product.toLowerCase();
      results = results
          .where((t) => t.products
              .any((p) => p.productName.toLowerCase().contains(q)))
          .toList();
    }

    if (destination != null && destination.isNotEmpty) {
      final q = destination.toLowerCase();
      results = results
          .where((t) => t.destinationLocation.toLowerCase().contains(q))
          .toList();
    }

    if (status != null) {
      results = results.where((t) => t.status == status).toList();
    }

    return results;
  }
}
