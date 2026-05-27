import 'package:smarterp/core/exceptions/app_exception.dart';
import 'package:smarterp/core/models/attendance_model.dart';
import 'package:smarterp/core/utils/logger.dart';
import 'package:smarterp/modules/payroll/repositories/attendance_repository.dart';

class AttendanceService {
  final AttendanceRepository _repository;

  AttendanceService(this._repository);

  Future<List<AttendanceModel>> getAllRecords() async {
    try {
      return await _repository.getAll();
    } catch (e, stackTrace) {
      Logger.error('Failed to get all attendance records', e, stackTrace);
      rethrow;
    }
  }

  Future<AttendanceModel?> getRecordById(String id) async {
    try {
      return await _repository.getById(id);
    } catch (e, stackTrace) {
      Logger.error('Failed to get attendance record', e, stackTrace);
      return null;
    }
  }

  Future<AttendanceModel> markAttendance({
    required String employeeId,
    required String employeeName,
    required DateTime date,
    required AttendanceStatus status,
    DateTime? checkIn,
    DateTime? checkOut,
    String? notes,
  }) async {
    try {
      final existing = await _repository.getByEmployeeAndDate(employeeId, date);

      if (existing != null) {
        final updated = existing.copyWith(
          status: status,
          checkIn: checkIn,
          checkOut: checkOut,
          notes: notes,
          updatedAt: DateTime.now(),
        );
        await _repository.update(updated);
        Logger.success('Attendance updated: $employeeName - ${date.toIso8601String()}');
        return updated;
      }

      final record = AttendanceModel.create(
        employeeId: employeeId,
        employeeName: employeeName,
        date: date,
        status: status,
        checkIn: checkIn,
        checkOut: checkOut,
        notes: notes,
      );

      await _repository.save(record);
      Logger.success('Attendance marked: $employeeName - ${status.displayName}');
      return record;
    } on AppException {
      rethrow;
    } catch (e, stackTrace) {
      Logger.error('Failed to mark attendance', e, stackTrace);
      rethrow;
    }
  }

  Future<void> deleteRecord(String id) async {
    try {
      await _repository.delete(id);
      Logger.success('Attendance record deleted');
    } catch (e, stackTrace) {
      Logger.error('Failed to delete attendance record', e, stackTrace);
      rethrow;
    }
  }

  Future<List<AttendanceModel>> getRecordsByEmployeeId(String employeeId) async {
    try {
      return await _repository.getByEmployeeId(employeeId);
    } catch (e, stackTrace) {
      Logger.error('Failed to get records by employee', e, stackTrace);
      return [];
    }
  }

  Future<List<AttendanceModel>> getRecordsByDate(DateTime date) async {
    try {
      return await _repository.getByDate(date);
    } catch (e, stackTrace) {
      Logger.error('Failed to get records by date', e, stackTrace);
      return [];
    }
  }

  Future<List<AttendanceModel>> getRecordsByMonth(int month, int year) async {
    try {
      return await _repository.getByMonth(month, year);
    } catch (e, stackTrace) {
      Logger.error('Failed to get records by month', e, stackTrace);
      return [];
    }
  }

  Future<List<AttendanceModel>> getRecordsByEmployeeAndMonth(
    String employeeId, int month, int year,
  ) async {
    try {
      return await _repository.getByEmployeeAndMonth(employeeId, month, year);
    } catch (e, stackTrace) {
      Logger.error('Failed to get records by employee and month', e, stackTrace);
      return [];
    }
  }

  Future<AttendanceModel?> getRecordByEmployeeAndDate(
    String employeeId, DateTime date,
  ) async {
    try {
      return await _repository.getByEmployeeAndDate(employeeId, date);
    } catch (e, stackTrace) {
      Logger.error('Failed to get record by employee and date', e, stackTrace);
      return null;
    }
  }

  Future<Map<AttendanceStatus, int>> getStatusCountsForMonth(
    String employeeId, int month, int year,
  ) async {
    try {
      return await _repository.getStatusCountsForMonth(employeeId, month, year);
    } catch (e, stackTrace) {
      Logger.error('Failed to get status counts', e, stackTrace);
      return {};
    }
  }

  Future<int> getPresentDaysForMonth(String employeeId, int month, int year) async {
    try {
      return await _repository.getPresentCountForMonth(employeeId, month, year);
    } catch (e, stackTrace) {
      Logger.error('Failed to get present days', e, stackTrace);
      return 0;
    }
  }

  Future<void> markBulkAttendance({
    required List<String> employeeIds,
    required List<String> employeeNames,
    required DateTime date,
    required AttendanceStatus status,
  }) async {
    try {
      for (var i = 0; i < employeeIds.length; i++) {
        await markAttendance(
          employeeId: employeeIds[i],
          employeeName: employeeNames[i],
          date: date,
          status: status,
        );
      }
      Logger.success('Bulk attendance marked for ${employeeIds.length} employees');
    } catch (e, stackTrace) {
      Logger.error('Failed to mark bulk attendance', e, stackTrace);
      rethrow;
    }
  }
}
