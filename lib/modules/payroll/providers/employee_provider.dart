import 'package:flutter/foundation.dart';
import 'package:smarterp/core/exceptions/app_exception.dart';
import 'package:smarterp/core/models/employee_model.dart';
import 'package:smarterp/core/utils/logger.dart';
import 'package:smarterp/modules/payroll/services/employee_service.dart';

class EmployeeProvider extends ChangeNotifier {
  final EmployeeService _service;

  EmployeeProvider(this._service);

  List<EmployeeModel> _employees = [];
  List<EmployeeModel> _filteredEmployees = [];
  EmployeeModel? _selectedEmployee;

  bool _isLoading = false;
  bool _isSearching = false;
  String? _errorMessage;
  String _searchQuery = '';
  String? _selectedDepartment;
  EmployeeStatus? _selectedStatus;

  List<EmployeeModel> get employees =>
      _filteredEmployees.isEmpty && _searchQuery.isEmpty &&
              _selectedDepartment == null && _selectedStatus == null
          ? _employees
          : _filteredEmployees;

  EmployeeModel? get selectedEmployee => _selectedEmployee;
  bool get isLoading => _isLoading;
  bool get isSearching => _isSearching;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String? get selectedDepartment => _selectedDepartment;
  EmployeeStatus? get selectedStatus => _selectedStatus;

  int get totalEmployees => _employees.length;
  int get activeEmployees => _employees.where((e) => e.status == EmployeeStatus.active).length;

  List<String> get departments =>
      _employees.map((e) => e.department).toSet().toList()..sort();

  Future<void> loadEmployees() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _employees = await _service.getAllEmployees();

      _isLoading = false;
      notifyListeners();
      Logger.success('Employees loaded: ${_employees.length}');
    } catch (e, stackTrace) {
      _isLoading = false;
      _errorMessage = 'Failed to load employees';
      notifyListeners();
      Logger.error('Failed to load employees', e, stackTrace);
    }
  }

  Future<void> createEmployee({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    String? address,
    required String department,
    required String designation,
    required DateTime dateOfJoining,
    DateTime? dateOfBirth,
    required double salary,
    required EmploymentType employmentType,
    String? bankAccountNumber,
    String? bankName,
    String? ifscCode,
    String? panNumber,
    String? aadharNumber,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final employee = await _service.createEmployee(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
        address: address,
        department: department,
        designation: designation,
        dateOfJoining: dateOfJoining,
        dateOfBirth: dateOfBirth,
        salary: salary,
        employmentType: employmentType,
        bankAccountNumber: bankAccountNumber,
        bankName: bankName,
        ifscCode: ifscCode,
        panNumber: panNumber,
        aadharNumber: aadharNumber,
      );

      _employees.add(employee);
      _applyFilters();

      _isLoading = false;
      notifyListeners();
      Logger.success('Employee created: ${employee.fullName}');
    } on ValidationException catch (e) {
      _isLoading = false;
      _errorMessage = e.message;
      notifyListeners();
      rethrow;
    } catch (e, stackTrace) {
      _isLoading = false;
      _errorMessage = 'Failed to create employee';
      notifyListeners();
      Logger.error('Failed to create employee', e, stackTrace);
      rethrow;
    }
  }

  Future<void> updateEmployee({
    required String id,
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    String? address,
    required String department,
    required String designation,
    required DateTime dateOfJoining,
    DateTime? dateOfBirth,
    required double salary,
    required EmploymentType employmentType,
    required EmployeeStatus status,
    String? bankAccountNumber,
    String? bankName,
    String? ifscCode,
    String? panNumber,
    String? aadharNumber,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final updated = await _service.updateEmployee(
        id: id,
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
        address: address,
        department: department,
        designation: designation,
        dateOfJoining: dateOfJoining,
        dateOfBirth: dateOfBirth,
        salary: salary,
        employmentType: employmentType,
        status: status,
        bankAccountNumber: bankAccountNumber,
        bankName: bankName,
        ifscCode: ifscCode,
        panNumber: panNumber,
        aadharNumber: aadharNumber,
      );

      final index = _employees.indexWhere((e) => e.id == id);
      if (index != -1) _employees[index] = updated;
      _applyFilters();

      _isLoading = false;
      notifyListeners();
      Logger.success('Employee updated: ${updated.fullName}');
    } on ValidationException catch (e) {
      _isLoading = false;
      _errorMessage = e.message;
      notifyListeners();
      rethrow;
    } catch (e, stackTrace) {
      _isLoading = false;
      _errorMessage = 'Failed to update employee';
      notifyListeners();
      Logger.error('Failed to update employee', e, stackTrace);
      rethrow;
    }
  }

  Future<void> deleteEmployee(String id) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _service.deleteEmployee(id);
      _employees.removeWhere((e) => e.id == id);
      _filteredEmployees.removeWhere((e) => e.id == id);

      if (_selectedEmployee?.id == id) _selectedEmployee = null;

      _isLoading = false;
      notifyListeners();
      Logger.success('Employee deleted');
    } catch (e, stackTrace) {
      _isLoading = false;
      _errorMessage = 'Failed to delete employee';
      notifyListeners();
      Logger.error('Failed to delete employee', e, stackTrace);
      rethrow;
    }
  }

  Future<void> searchEmployees(String query) async {
    try {
      _isSearching = true;
      _searchQuery = query;
      notifyListeners();

      if (query.trim().isEmpty) {
        _filteredEmployees = [];
      } else {
        final results = await _service.searchEmployees(query);
        _filteredEmployees = results;
      }

      _isSearching = false;
      notifyListeners();
    } catch (e, stackTrace) {
      _isSearching = false;
      Logger.error('Failed to search employees', e, stackTrace);
    }
  }

  void filterByDepartment(String? department) {
    _selectedDepartment = department;
    _applyFilters();
    notifyListeners();
  }

  void filterByStatus(EmployeeStatus? status) {
    _selectedStatus = status;
    _applyFilters();
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    _filteredEmployees = [];
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedDepartment = null;
    _selectedStatus = null;
    _filteredEmployees = [];
    notifyListeners();
  }

  void selectEmployee(EmployeeModel? employee) {
    _selectedEmployee = employee;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _applyFilters() {
    var filtered = List<EmployeeModel>.from(_employees);
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      filtered = filtered.where((e) =>
          e.fullName.toLowerCase().contains(q) ||
          e.employeeCode.toLowerCase().contains(q) ||
          e.phone.toLowerCase().contains(q) ||
          e.designation.toLowerCase().contains(q)).toList();
    }
    if (_selectedDepartment != null) {
      filtered = filtered.where((e) => e.department == _selectedDepartment).toList();
    }
    if (_selectedStatus != null) {
      filtered = filtered.where((e) => e.status == _selectedStatus).toList();
    }
    _filteredEmployees = filtered;
  }
}
