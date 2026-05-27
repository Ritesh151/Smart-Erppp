import 'package:smarterp/core/exceptions/app_exception.dart';
import 'package:smarterp/core/models/attendance_model.dart';
import 'package:smarterp/core/storage/storage_service.dart';
import 'package:smarterp/core/utils/logger.dart';

class AttendanceRepository {
  final StorageService<Map<dynamic, dynamic>> _storage;

  AttendanceRepository(this._storage);

  Future<List<AttendanceModel>> getAll() async {
    try {
      final data = _storage.getAll();
      return data
          .map((item) => AttendanceModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } catch (e, stackTrace) {
      Logger.error('Failed to get all attendance records', e, stackTrace);
      throw StorageException('Failed to retrieve attendance records');
    }
  }

  Future<AttendanceModel?> getById(String id) async {
    try {
      final data = _storage.get(id);
      if (data == null) return null;
      return AttendanceModel.fromJson(Map<String, dynamic>.from(data));
    } catch (e, stackTrace) {
      Logger.error('Failed to get attendance by id: $id', e, stackTrace);
      return null;
    }
  }

  Future<void> save(AttendanceModel attendance) async {
    try {
      await _storage.save(attendance.id, attendance.toJson());
      Logger.success('Attendance saved: ${attendance.employeeName} - ${attendance.date}');
    } catch (e, stackTrace) {
      Logger.error('Failed to save attendance', e, stackTrace);
      throw StorageException('Failed to save attendance');
    }
  }

  Future<void> update(AttendanceModel attendance) async {
    try {
      await _storage.save(attendance.id, attendance.toJson());
      Logger.success('Attendance updated: ${attendance.employeeName} - ${attendance.date}');
    } catch (e, stackTrace) {
      Logger.error('Failed to update attendance', e, stackTrace);
      throw StorageException('Failed to update attendance');
    }
  }

  Future<void> delete(String id) async {
    try {
      await _storage.delete(id);
      Logger.success('Attendance deleted: $id');
    } catch (e, stackTrace) {
      Logger.error('Failed to delete attendance', e, stackTrace);
      throw StorageException('Failed to delete attendance');
    }
  }

  Future<List<AttendanceModel>> getByEmployeeId(String employeeId) async {
    try {
      final all = await getAll();
      return all.where((a) => a.employeeId == employeeId).toList();
    } catch (e, stackTrace) {
      Logger.error('Failed to get attendance by employee', e, stackTrace);
      return [];
    }
  }

  Future<List<AttendanceModel>> getByDate(DateTime date) async {
    try {
      final all = await getAll();
      return all.where((a) =>
          a.date.year == date.year &&
          a.date.month == date.month &&
          a.date.day == date.day).toList();
    } catch (e, stackTrace) {
      Logger.error('Failed to get attendance by date', e, stackTrace);
      return [];
    }
  }

  Future<List<AttendanceModel>> getByMonth(int month, int year) async {
    try {
      final all = await getAll();
      return all.where((a) => a.date.month == month && a.date.year == year).toList();
    } catch (e, stackTrace) {
      Logger.error('Failed to get attendance by month', e, stackTrace);
      return [];
    }
  }

  Future<List<AttendanceModel>> getByEmployeeAndMonth(
    String employeeId, int month, int year,
  ) async {
    try {
      final all = await getAll();
      return all.where((a) =>
          a.employeeId == employeeId &&
          a.date.month == month &&
          a.date.year == year).toList();
    } catch (e, stackTrace) {
      Logger.error('Failed to get attendance by employee and month', e, stackTrace);
      return [];
    }
  }

  Future<AttendanceModel?> getByEmployeeAndDate(
    String employeeId, DateTime date,
  ) async {
    try {
      final all = await getAll();
      return all.cast<AttendanceModel?>().firstWhere(
        (a) =>
            a!.employeeId == employeeId &&
            a.date.year == date.year &&
            a.date.month == date.month &&
            a.date.day == date.day,
        orElse: () => null,
      );
    } catch (e, stackTrace) {
      Logger.error('Failed to get attendance by employee and date', e, stackTrace);
      return null;
    }
  }

  Future<List<AttendanceModel>> getByStatus(AttendanceStatus status) async {
    try {
      final all = await getAll();
      return all.where((a) => a.status == status).toList();
    } catch (e, stackTrace) {
      Logger.error('Failed to get attendance by status', e, stackTrace);
      return [];
    }
  }

  Future<Map<AttendanceStatus, int>> getStatusCountsForMonth(
    String employeeId, int month, int year,
  ) async {
    try {
      final records = await getByEmployeeAndMonth(employeeId, month, year);
      final counts = <AttendanceStatus, int>{};
      for (final status in AttendanceStatus.values) {
        counts[status] = records.where((a) => a.status == status).length;
      }
      return counts;
    } catch (e, stackTrace) {
      Logger.error('Failed to get status counts', e, stackTrace);
      return {};
    }
  }

  Future<int> getPresentCountForMonth(String employeeId, int month, int year) async {
    try {
      final records = await getByEmployeeAndMonth(employeeId, month, year);
      return records.where((a) => a.isPresent || a.isHalfDay).length;
    } catch (e, stackTrace) {
      Logger.error('Failed to get present count', e, stackTrace);
      return 0;
    }
  }
}
