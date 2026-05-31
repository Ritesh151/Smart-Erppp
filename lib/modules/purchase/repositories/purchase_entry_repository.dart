import 'package:siddhivinayak_enterprise/core/storage/storage_service.dart';
import 'package:siddhivinayak_enterprise/core/utils/logger.dart';

class PurchaseEntryRepository {
  final StorageService<Map<dynamic, dynamic>> _storage;

  PurchaseEntryRepository(this._storage);

  List<Map<String, dynamic>> getAll() {
    try {
      return _storage.getAll()
          .map((e) => Map<String, dynamic>.from(e))
          .toList()
        ..sort((a, b) {
          final ad = DateTime.tryParse(a['purchaseDate'] as String? ?? '');
          final bd = DateTime.tryParse(b['purchaseDate'] as String? ?? '');
          return (bd ?? DateTime(2000)).compareTo(ad ?? DateTime(2000));
        });
    } catch (e, stackTrace) {
      Logger.error('Failed to get all purchases', e, stackTrace);
      return [];
    }
  }

  Map<String, dynamic>? getById(String id) {
    try {
      final data = _storage.get(id);
      if (data == null) return null;
      return Map<String, dynamic>.from(data);
    } catch (e, stackTrace) {
      Logger.error('Failed to get purchase by id: $id', e, stackTrace);
      return null;
    }
  }

  Future<void> save(Map<String, dynamic> purchase) async {
    try {
      await _storage.save(purchase['id'] as String, purchase);
      Logger.success('Purchase saved: ${purchase['purchaseNumber']}');
    } catch (e, stackTrace) {
      Logger.error('Failed to save purchase', e, stackTrace);
      rethrow;
    }
  }

  Future<void> update(Map<String, dynamic> purchase) async {
    try {
      await _storage.update(purchase['id'] as String, purchase);
      Logger.success('Purchase updated: ${purchase['purchaseNumber']}');
    } catch (e, stackTrace) {
      Logger.error('Failed to update purchase', e, stackTrace);
      rethrow;
    }
  }

  Future<void> delete(String id) async {
    try {
      await _storage.delete(id);
      Logger.success('Purchase deleted: $id');
    } catch (e, stackTrace) {
      Logger.error('Failed to delete purchase', e, stackTrace);
      rethrow;
    }
  }

  List<Map<String, dynamic>> getByDateRange(DateTime start, DateTime end) {
    return getAll().where((p) {
      final date = DateTime.tryParse(p['purchaseDate'] as String? ?? '');
      if (date == null) return false;
      return !date.isBefore(start) && !date.isAfter(end);
    }).toList();
  }

  List<Map<String, dynamic>> search(String query) {
    if (query.trim().isEmpty) return getAll();
    final lower = query.toLowerCase();
    return getAll().where((p) {
      final number = (p['purchaseNumber'] as String? ?? '').toLowerCase();
      final supplier = (p['supplierName'] as String? ?? '').toLowerCase();
      final items = p['items'] as List<dynamic>? ?? [];
      final hasProduct = items.any((item) {
        final name = (item['productName'] as String? ?? '').toLowerCase();
        return name.contains(lower);
      });
      return number.contains(lower) || supplier.contains(lower) || hasProduct;
    }).toList();
  }

  int getTotalCount() {
    try {
      return _storage.length;
    } catch (_) {
      return 0;
    }
  }
}
