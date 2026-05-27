import 'package:flutter/foundation.dart';
import 'package:smarterp/core/exceptions/app_exception.dart';
import 'package:smarterp/core/models/attendance_model.dart';
import 'package:smarterp/core/utils/logger.dart';
import 'package:smarterp/modules/payroll/services/attendance_service.dart';

class AttendanceProvider extends ChangeNotifier {
  final AttendanceService _service;

  AttendanceProvider(this._service);

  List<AttendanceModel> _records = [];
  AttendanceModel? _selectedRecord;
  DateTime _selectedDate = DateTime.now();
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;
  String? _selectedEmployeeId;

  bool _isLoading = false;
  String? _errorMessage;

  List<AttendanceModel> get records => _records;
  AttendanceModel? get selectedRecord => _selectedRecord;
  DateTime get selectedDate => _selectedDate;
  int get selectedMonth => _selectedMonth;
  int get selectedYear => _selectedYear;
  String? get selectedEmployeeId => _selectedEmployeeId;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int get totalRecords => _records.length;
  int get presentCount => _records.where((r) => r.isPresent).length;
  int get absentCount => _records.where((r) => r.isAbsent).length;
  int get halfDayCount => _records.where((r) => r.isHalfDay).length;
  int get leaveCount => _records.where((r) => r.isOnLeave).length;
  int get holidayCount => _records.where((r) => r.isHoliday).length;

  List<AttendanceModel> get recordsForSelectedDate =>
      _records.where((r) =>
          r.date.year == _selectedDate.year &&
          r.date.month == _selectedDate.month &&
          r.date.day == _selectedDate.day).toList();

  Map<AttendanceStatus, int> get statusSummary {
    return {
      AttendanceStatus.present: presentCount,
      AttendanceStatus.absent: absentCount,
      AttendanceStatus.halfDay: halfDayCount,
      AttendanceStatus.leave: leaveCount,
      AttendanceStatus.holiday: holidayCount,
    };
  }

  Future<void> loadRecords() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _records = await _service.getRecordsByMonth(_selectedMonth, _selectedYear);

      _isLoading = false;
      notifyListeners();
      Logger.success('Attendance records loaded: ${_records.length}');
    } catch (e, stackTrace) {
      _isLoading = false;
      _errorMessage = 'Failed to load attendance records';
      notifyListeners();
      Logger.error('Failed to load attendance records', e, stackTrace);
    }
  }

  Future<void> loadRecordsForDate(DateTime date) async {
    _selectedDate = date;
    notifyListeners();
    await loadRecords();
  }

  Future<void> loadRecordsForMonth(int month, int year) async {
    _selectedMonth = month;
    _selectedYear = year;
    notifyListeners();
    await loadRecords();
  }

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  void setSelectedMonth(int month, int year) {
    _selectedMonth = month;
    _selectedYear = year;
    notifyListeners();
  }

  void filterByEmployee(String? employeeId) {
    _selectedEmployeeId = employeeId;
    notifyListeners();
  }

  Future<void> markAttendance({
    required String employeeId,
    required String employeeName,
    required DateTime date,
    required AttendanceStatus status,
    DateTime? checkIn,
    DateTime? checkOut,
    String? notes,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final record = await _service.markAttendance(
        employeeId: employeeId,
        employeeName: employeeName,
        date: date,
        status: status,
        checkIn: checkIn,
        checkOut: checkOut,
        notes: notes,
      );

      final existingIndex = _records.indexWhere(
        (r) => r.id == record.id,
      );
      if (existingIndex != -1) {
        _records[existingIndex] = record;
      } else {
        _records.add(record);
      }

      _isLoading = false;
      notifyListeners();
      Logger.success('Attendance marked: $employeeName - ${status.displayName}');
    } on ValidationException catch (e) {
      _isLoading = false;
      _errorMessage = e.message;
      notifyListeners();
      rethrow;
    } catch (e, stackTrace) {
      _isLoading = false;
      _errorMessage = 'Failed to mark attendance';
      notifyListeners();
      Logger.error('Failed to mark attendance', e, stackTrace);
      rethrow;
    }
  }

  Future<void> markBulkAttendance({
    required List<String> employeeIds,
    required List<String> employeeNames,
    required DateTime date,
    required AttendanceStatus status,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _service.markBulkAttendance(
        employeeIds: employeeIds,
        employeeNames: employeeNames,
        date: date,
        status: status,
      );

      await loadRecords();
    } catch (e, stackTrace) {
      _isLoading = false;
      _errorMessage = 'Failed to mark bulk attendance';
      notifyListeners();
      Logger.error('Failed to mark bulk attendance', e, stackTrace);
      rethrow;
    }
  }

  Future<void> deleteRecord(String id) async {
    try {
      await _service.deleteRecord(id);
      _records.removeWhere((r) => r.id == id);
      if (_selectedRecord?.id == id) _selectedRecord = null;
      notifyListeners();
      Logger.success('Attendance record deleted');
    } catch (e, stackTrace) {
      _errorMessage = 'Failed to delete attendance record';
      notifyListeners();
      Logger.error('Failed to delete attendance record', e, stackTrace);
      rethrow;
    }
  }

  void selectRecord(AttendanceModel? record) {
    _selectedRecord = record;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
