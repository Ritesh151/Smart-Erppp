import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:SmartERP/modules/transport/models/transport_screen_model.dart';
import 'package:SmartERP/modules/transport/repositories/transport_repository.dart';
import 'package:SmartERP/modules/transport/services/transport_service.dart';
import 'package:SmartERP/modules/transport/services/transport_status_service.dart';
import 'package:SmartERP/core/storage/storage_service.dart';
import 'package:SmartERP/core/constants/storage_keys.dart';
import 'package:SmartERP/modules/products/repositories/product_repository.dart';
import 'package:SmartERP/modules/finance/repositories/finance_repository.dart';

// Filter state providers
final transportDateFilterProvider = StateProvider<DateTimeRange?>((ref) => null);
final transportProductFilterProvider = StateProvider<String>((ref) => '');
final transportDestinationFilterProvider = StateProvider<String>((ref) => '');
final transportStatusFilterProvider = StateProvider<ExportStatus?>((ref) => null);

// Core service providers (Riverpod-scoped, separate from Provider package DI)
final _transportStorageProvider = Provider<StorageService<Map<dynamic, dynamic>>>((ref) {
  final s = StorageService<Map<dynamic, dynamic>>(StorageKeys.transportBox)..init();
  return s;
});

final _transportItemStorageProvider = Provider<StorageService<Map<dynamic, dynamic>>>((ref) {
  final s = StorageService<Map<dynamic, dynamic>>(StorageKeys.transportItemBox)..init();
  return s;
});

final _transportRepoProvider = Provider<TransportRepository>((ref) {
  return TransportRepository(
    transportStorage: ref.read(_transportStorageProvider),
    itemStorage: ref.read(_transportItemStorageProvider),
  );
});

final transportServiceProvider = Provider<TransportService>((ref) {
  return TransportService(
    transportRepository: ref.read(_transportRepoProvider),
    productRepository: ref.read(_productRepoProvider),
  );
});

final _productRepoProvider = Provider<ProductRepository>((ref) {
  final s = StorageService<Map<dynamic, dynamic>>(StorageKeys.productsBox)..init();
  return ProductRepository(s);
});

final transportStatusServiceProvider = Provider<TransportStatusService>((ref) {
  return TransportStatusService(
    transportRepository: ref.read(_transportRepoProvider),
    productRepository: ref.read(_productRepoProvider),
    financeRepository: ref.read(_financeRepoProvider),
  );
});

final _financeRepoProvider = Provider<FinanceRepository>((ref) {
  return FinanceRepository(
    salesStorage: StorageService<Map<dynamic, dynamic>>(StorageKeys.salesBox)..init(),
    purchaseStorage: StorageService<Map<dynamic, dynamic>>(StorageKeys.purchaseBox)..init(),
    expensesStorage: StorageService<Map<dynamic, dynamic>>(StorageKeys.expensesBox)..init(),
  );
});

// Transport list stream
final transportsStreamProvider = FutureProvider<List<TransportModel>>((ref) async {
  final service = ref.read(transportServiceProvider);
  return service.getAllTransports();
});

// Filtered transports
final filteredTransportsProvider = Provider<List<TransportModel>>((ref) {
  final transportsAsync = ref.watch(transportsStreamProvider);
  final dateRange = ref.watch(transportDateFilterProvider);
  final productFilter = ref.watch(transportProductFilterProvider);
  final destinationFilter = ref.watch(transportDestinationFilterProvider);
  final statusFilter = ref.watch(transportStatusFilterProvider);

  return transportsAsync.when(
    data: (transports) {
      var filtered = List<TransportModel>.from(transports);

      if (dateRange != null) {
        filtered = filtered.where((t) {
          return t.transportDate.isAfter(dateRange.start.subtract(const Duration(days: 1))) &&
              t.transportDate.isBefore(dateRange.end.add(const Duration(days: 1)));
        }).toList();
      }

      if (productFilter.isNotEmpty) {
        final q = productFilter.toLowerCase();
        filtered = filtered
            .where((t) => t.products
                .any((p) => p.productName.toLowerCase().contains(q)))
            .toList();
      }

      if (destinationFilter.isNotEmpty) {
        final q = destinationFilter.toLowerCase();
        filtered = filtered
            .where((t) => t.destinationLocation.toLowerCase().contains(q))
            .toList();
      }

      if (statusFilter != null) {
        filtered = filtered.where((t) => t.status == statusFilter).toList();
      }

      return filtered;
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

// Transport state
class TransportState {
  final bool isLoading;
  final String? error;

  TransportState({this.isLoading = false, this.error});

  TransportState copyWith({bool? isLoading, String? error}) {
    return TransportState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Transport notifier
class TransportNotifier extends StateNotifier<TransportState> {
  final TransportService _service;
  final TransportStatusService _statusService;
  final Ref _ref;

  TransportNotifier(this._service, this._statusService, this._ref)
      : super(TransportState());

  Future<bool> addTransport(TransportModel transport) async {
    state = state.copyWith(isLoading: true);
    try {
      await _service.saveTransport(transport);
      _ref.invalidate(transportsStreamProvider);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> updateTransport(String id, TransportModel transport) async {
    state = state.copyWith(isLoading: true);
    try {
      await _service.updateTransport(transport);
      _ref.invalidate(transportsStreamProvider);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> deleteTransport(String id) async {
    state = state.copyWith(isLoading: true);
    try {
      await _service.deleteTransport(id);
      _ref.invalidate(transportsStreamProvider);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> updateStatus(String id, ExportStatus status) async {
    state = state.copyWith(isLoading: true);
    try {
      await _statusService.updateStatus(id, status);
      _ref.invalidate(transportsStreamProvider);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}

final transportNotifierProvider =
    StateNotifierProvider<TransportNotifier, TransportState>((ref) {
  return TransportNotifier(
    ref.read(transportServiceProvider),
    ref.read(transportStatusServiceProvider),
    ref,
  );
});
