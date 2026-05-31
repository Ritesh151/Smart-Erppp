import 'package:flutter/foundation.dart';
import 'package:siddhivinayak_enterprise/core/models/employee_model.dart';
import 'package:siddhivinayak_enterprise/modules/payroll/services/payroll_service.dart';

class PayrollProvider extends ChangeNotifier {
  final PayrollService _service;

  List<EmployeeModel> _employees = [];
  bool _isLoading = false;
  String? _error;

  List<EmployeeModel> get employees => _employees;
  bool get isLoading => _isLoading;
  String? get error => _error;

  PayrollProvider(this._service);

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

  Future<bool> deleteEmployee(String employeeId) async {
    try {
      await _service.deleteEmployee(employeeId);
      await loadEmployees();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> generateSalariesForMonth(int month, int year) async {
    try {
      await _service.generateSalariesForMonth(month, year);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
