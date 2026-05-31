import 'package:flutter/foundation.dart';
import 'package:siddhivinayak_enterprise/core/models/employee_model.dart';
import 'package:siddhivinayak_enterprise/modules/payroll/services/employee_service.dart';

class EmployeeProvider extends ChangeNotifier {
  final EmployeeService _service;

  List<EmployeeModel> _employees = [];
  bool _isLoading = false;
  String? _error;

  List<EmployeeModel> get employees => _employees;
  bool get isLoading => _isLoading;
  String? get error => _error;

  EmployeeProvider(this._service);

  Future<void> loadEmployees() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _employees = await _service.getAllEmployees();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addEmployee(EmployeeModel employee) async {
    try {
      await _service.saveEmployee(employee);
      await loadEmployees();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateEmployee(EmployeeModel employee) async {
    try {
      await _service.updateEmployee(employee);
      await loadEmployees();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteEmployee(String id) async {
    try {
      await _service.deleteEmployee(id);
      await loadEmployees();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
