import 'package:smarterp/core/exceptions/app_exception.dart';
import 'package:smarterp/core/models/customer_model.dart';
import 'package:smarterp/core/utils/logger.dart';
import 'package:smarterp/modules/invoice/repositories/customer_repository.dart';

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
      _validateCustomerData(
        name: name,
        email: email,
        gstNumber: gstNumber,
      );

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
      _validateCustomerData(
        name: name,
        email: email,
        gstNumber: gstNumber,
      );

      final existing = await _repository.getById(id);
      if (existing == null) {
        throw NotFoundException('Customer not found');
      }

      final updated = existing.copyWith(
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

      await _repository.update(updated);
      Logger.success('Customer updated: ${updated.name}');
      return updated;
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

  void _validateCustomerData({
    required String name,
    String? email,
    String? gstNumber,
  }) {
    if (name.trim().isEmpty) {
      throw ValidationException('Customer name is required');
    }

    if (email != null && email.isNotEmpty) {
      final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
      if (!emailRegex.hasMatch(email)) {
        throw ValidationException('Invalid email format');
      }
    }

    if (gstNumber != null && gstNumber.isNotEmpty) {
      final gstRegex = RegExp(r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$');
      if (!gstRegex.hasMatch(gstNumber)) {
        throw ValidationException('Invalid GST number format');
      }
    }
  }
}
