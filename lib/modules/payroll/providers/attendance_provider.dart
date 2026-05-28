import 'package:flutter/foundation.dart';
import 'package:SmartERP/core/models/attendance_model.dart';
import 'package:SmartERP/modules/payroll/services/attendance_service.dart';

class AttendanceProvider extends ChangeNotifier {
  final AttendanceService _service;

  List<AttendanceModel> _records = [];
  bool _isLoading = false;
  String? _error;

  List<AttendanceModel> get records => _records;
  bool get isLoading => _isLoading;
  String? get error => _error;

  AttendanceProvider(this._service);

  Future<void> loadRecords() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _records = await _service.getAllRecords();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> markAttendance(AttendanceModel record) async {
    try {
      await _service.markAttendance(record);
      await loadRecords();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
