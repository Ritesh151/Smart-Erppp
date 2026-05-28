import 'package:flutter/foundation.dart';
import 'package:SmartERP/core/exceptions/app_exception.dart';
import 'package:SmartERP/core/models/customer_model.dart';
import 'package:SmartERP/core/utils/logger.dart';
import 'package:SmartERP/modules/invoice/services/customer_service.dart';

class CustomerProvider extends ChangeNotifier {
  final CustomerService _service;
  VoidCallback? onDataChanged;

  CustomerProvider(this._service, {VoidCallback? onDataChanged})
      : onDataChanged = onDataChanged;

  List<CustomerModel> _customers = [];
  List<CustomerModel> _filteredCustomers = [];
  CustomerModel? _selectedCustomer;

  bool _isLoading = false;
  bool _isSearching = false;
  String? _errorMessage;
  String _searchQuery = '';

  List<CustomerModel> get customers =>
      _filteredCustomers.isEmpty && _searchQuery.isEmpty
          ? _customers
          : _filteredCustomers;

  CustomerModel? get selectedCustomer => _selectedCustomer;
  bool get isLoading => _isLoading;
  bool get isSearching => _isSearching;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  int get totalCustomers => _customers.length;

  Future<void> loadCustomers() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _customers = await _service.getAllCustomers();

      _isLoading = false;
      notifyListeners();
      onDataChanged?.call();
      Logger.success('Customers loaded: ${_customers.length}');
    } catch (e, stackTrace) {
      _isLoading = false;
      _errorMessage = 'Failed to load customers';
      notifyListeners();
      Logger.error('Failed to load customers', e, stackTrace);
    }
  }

  Future<void> createCustomer({
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
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final customer = await _service.createCustomer(
        name: name,
        email: email,
        phone: phone,
        address: address,
        gstNumber: gstNumber,
        city: city,
        state: state,
        pincode: pincode,
      );

      _customers.add(customer);

      _isLoading = false;
      notifyListeners();
      onDataChanged?.call();
      Logger.success('Customer created successfully');
    } on ValidationException catch (e) {
      _isLoading = false;
      _errorMessage = e.message;
      notifyListeners();
      rethrow;
    } catch (e, stackTrace) {
      _isLoading = false;
      _errorMessage = 'Failed to create customer';
      notifyListeners();
      Logger.error('Failed to create customer', e, stackTrace);
      rethrow;
    }
  }

  Future<void> updateCustomer({
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
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final updatedCustomer = await _service.updateCustomer(
        id: id,
        name: name,
        email: email,
        phone: phone,
        address: address,
        gstNumber: gstNumber,
        city: city,
        state: state,
        pincode: pincode,
        isActive: isActive,
      );

      final index = _customers.indexWhere((c) => c.id == id);
      if (index != -1) {
        _customers[index] = updatedCustomer;
      }

      if (_selectedCustomer?.id == id) {
        _selectedCustomer = updatedCustomer;
      }

      _isLoading = false;
      notifyListeners();
      onDataChanged?.call();
      Logger.success('Customer updated successfully');
    } on ValidationException catch (e) {
      _isLoading = false;
      _errorMessage = e.message;
      notifyListeners();
      rethrow;
    } catch (e, stackTrace) {
      _isLoading = false;
      _errorMessage = 'Failed to update customer';
      notifyListeners();
      Logger.error('Failed to update customer', e, stackTrace);
      rethrow;
    }
  }

  Future<void> deleteCustomer(String id) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _service.deleteCustomer(id);
      _customers.removeWhere((c) => c.id == id);

      if (_selectedCustomer?.id == id) {
        _selectedCustomer = null;
      }

      _isLoading = false;
      notifyListeners();
      onDataChanged?.call();
      Logger.success('Customer deleted successfully');
    } catch (e, stackTrace) {
      _isLoading = false;
      _errorMessage = 'Failed to delete customer';
      notifyListeners();
      Logger.error('Failed to delete customer', e, stackTrace);
      rethrow;
    }
  }

  Future<void> searchCustomers(String query) async {
    try {
      _isSearching = true;
      _searchQuery = query;
      notifyListeners();

      if (query.trim().isEmpty) {
        _filteredCustomers = [];
      } else {
        _filteredCustomers = await _service.searchCustomers(query);
      }

      _isSearching = false;
      notifyListeners();
    } catch (e, stackTrace) {
      _isSearching = false;
      notifyListeners();
      Logger.error('Failed to search customers', e, stackTrace);
    }
  }

  void selectCustomer(CustomerModel? customer) {
    _selectedCustomer = customer;
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    _filteredCustomers = [];
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
