import 'package:smarterp/core/exceptions/app_exception.dart';
import 'package:smarterp/core/models/customer_model.dart';
import 'package:smarterp/core/storage/storage_service.dart';
import 'package:smarterp/core/utils/logger.dart';

class CustomerRepository {
  final StorageService<Map<dynamic, dynamic>> _storage;

  CustomerRepository(this._storage);

  Future<List<CustomerModel>> getAll() async {
    try {
      final data = _storage.getAll();
      return data
          .map((item) => CustomerModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } catch (e, stackTrace) {
      Logger.error('Failed to get all customers', e, stackTrace);
      throw StorageException('Failed to retrieve customers');
    }
  }

  Future<CustomerModel?> getById(String id) async {
    try {
      final data = _storage.get(id);
      if (data == null) return null;
      return CustomerModel.fromJson(Map<String, dynamic>.from(data));
    } catch (e, stackTrace) {
      Logger.error('Failed to get customer by id: $id', e, stackTrace);
      return null;
    }
  }

  Future<void> save(CustomerModel customer) async {
    try {
      await _storage.save(customer.id, customer.toJson());
      Logger.success('Customer saved: ${customer.id}');
    } catch (e, stackTrace) {
      Logger.error('Failed to save customer', e, stackTrace);
      throw StorageException('Failed to save customer');
    }
  }

  Future<void> update(CustomerModel customer) async {
    try {
      await _storage.update(customer.id, customer.toJson());
      Logger.success('Customer updated: ${customer.id}');
    } catch (e, stackTrace) {
      Logger.error('Failed to update customer', e, stackTrace);
      throw StorageException('Failed to update customer');
    }
  }

  Future<void> delete(String id) async {
    try {
      await _storage.delete(id);
      Logger.success('Customer deleted: $id');
    } catch (e, stackTrace) {
      Logger.error('Failed to delete customer', e, stackTrace);
      throw StorageException('Failed to delete customer');
    }
  }

  Future<List<CustomerModel>> search(String query) async {
    try {
      final customers = await getAll();
      final lowerQuery = query.toLowerCase();
      return customers.where((c) {
        return c.name.toLowerCase().contains(lowerQuery) ||
            (c.email?.toLowerCase().contains(lowerQuery) ?? false) ||
            (c.phone?.contains(lowerQuery) ?? false) ||
            (c.gstNumber?.toLowerCase().contains(lowerQuery) ?? false);
      }).toList();
    } catch (e, stackTrace) {
      Logger.error('Failed to search customers', e, stackTrace);
      return [];
    }
  }

  Future<bool> exists(String id) async {
    try {
      return _storage.containsKey(id);
    } catch (e, stackTrace) {
      Logger.error('Failed to check customer existence', e, stackTrace);
      return false;
    }
  }

  Future<int> getTotalCount() async {
    try {
      return _storage.length;
    } catch (e, stackTrace) {
      Logger.error('Failed to get total customer count', e, stackTrace);
      return 0;
    }
  }
}
