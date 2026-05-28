import 'package:SmartERP/core/exceptions/app_exception.dart';
import 'package:SmartERP/core/models/customer_model.dart';
import 'package:SmartERP/core/utils/logger.dart';
import 'package:SmartERP/modules/invoice/repositories/customer_repository.dart';
import 'package:uuid/uuid.dart';

class CustomerService {
  final CustomerRepository _repository;

  CustomerService(this._repository);

  Future<List<CustomerModel>> getAllCustomers() async {
    try {
      return await _repository.getAll();
    } catch (e, stackTrace) {
      Logger.error('Failed to get all customers', e, stackTrace);
      rethrow;
    }
  }

  Future<CustomerModel?> getCustomerById(String id) async {
    try {
      return await _repository.getById(id);
    } catch (e, stackTrace) {
      Logger.error('Failed to get customer by id', e, stackTrace);
      return null;
    }
  }

  Future<CustomerModel> createCustomer({
    required String name,
    String? email,
    String? phone,
    String? address,
    String? gstNumber,
    String? city,
    String? state,
    String? pincode,
  }) async {
    try {
      if (name.trim().isEmpty) {
        throw ValidationException('Customer name is required');
      }

      final nameExists = await _repository.customerNameExists(name);
      if (nameExists) {
        throw ValidationException('Customer with this name already exists');
      }

      final customer = CustomerModel.create(
        name: name.trim(),
        email: email?.trim(),
        phone: phone?.trim(),
        address: address?.trim(),
        gstNumber: gstNumber?.trim(),
        city: city?.trim(),
        state: state?.trim(),
        pincode: pincode?.trim(),
      );

      await _repository.save(customer);
      Logger.success('Customer created: ${customer.name}');
      return customer;
    } catch (e, stackTrace) {
      Logger.error('Failed to create customer', e, stackTrace);
      rethrow;
    }
  }

  Future<CustomerModel> updateCustomer({
    required String id,
    required String name,
    String? email,
    String? phone,
    String? address,
    String? gstNumber,
    String? city,
    String? state,
    String? pincode,
    required bool isActive,
  }) async {
    try {
      if (name.trim().isEmpty) {
        throw ValidationException('Customer name is required');
      }

      final existingCustomer = await _repository.getById(id);
      if (existingCustomer == null) {
        throw NotFoundException('Customer not found');
      }

      final nameExists = await _repository.customerNameExists(
        name,
        excludeId: id,
      );
      if (nameExists) {
        throw ValidationException('Customer with this name already exists');
      }

      final updatedCustomer = existingCustomer.copyWith(
        name: name.trim(),
        email: email?.trim(),
        phone: phone?.trim(),
        address: address?.trim(),
        gstNumber: gstNumber?.trim(),
        city: city?.trim(),
        state: state?.trim(),
        pincode: pincode?.trim(),
        isActive: isActive,
        updatedAt: DateTime.now(),
      );

      await _repository.update(updatedCustomer);
      Logger.success('Customer updated: ${updatedCustomer.name}');
      return updatedCustomer;
    } catch (e, stackTrace) {
      Logger.error('Failed to update customer', e, stackTrace);
      rethrow;
    }
  }

  Future<void> deleteCustomer(String id) async {
    try {
      final customer = await _repository.getById(id);
      if (customer == null) {
        throw NotFoundException('Customer not found');
      }

      await _repository.delete(id);
      Logger.success('Customer deleted: ${customer.name}');
    } catch (e, stackTrace) {
      Logger.error('Failed to delete customer', e, stackTrace);
      rethrow;
    }
  }

  Future<List<CustomerModel>> searchCustomers(String query) async {
    try {
      if (query.trim().isEmpty) {
        return await getAllCustomers();
      }
      return await _repository.search(query);
    } catch (e, stackTrace) {
      Logger.error('Failed to search customers', e, stackTrace);
      return [];
    }
  }

  Future<bool> exists(String id) async {
    try {
      return await _repository.exists(id);
    } catch (e, stackTrace) {
      Logger.error('Failed to check customer existence', e, stackTrace);
      return false;
    }
  }

  Future<bool> customerNameExists(String name, {String? excludeId}) async {
    try {
      return await _repository.customerNameExists(name, excludeId: excludeId);
    } catch (e, stackTrace) {
      Logger.error('Failed to check customer name existence', e, stackTrace);
      return false;
    }
  }
}
