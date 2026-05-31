import 'package:siddhivinayak_enterprise/core/models/attendance_model.dart';
import 'package:siddhivinayak_enterprise/core/storage/storage_service.dart';
import 'package:siddhivinayak_enterprise/core/utils/logger.dart';

class AttendanceRepository {
  final StorageService<Map<dynamic, dynamic>> _storage;

  AttendanceRepository(this._storage);

  Future<List<AttendanceModel>> getAll() async {
    try {
      final data = _storage.getAll();
      return data
          .map((item) =>
              AttendanceModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } catch (e, stackTrace) {
      Logger.error('Failed to get all attendance records', e, stackTrace);
      return [];
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

  Future<void> save(AttendanceModel record) async {
    try {
      await _storage.save(record.id, record.toJson());
      Logger.success('Attendance saved: ${record.id}');
    } catch (e, stackTrace) {
      Logger.error('Failed to save attendance', e, stackTrace);
      rethrow;
    }
  }

  Future<void> delete(String id) async {
    try {
      await _storage.delete(id);
      Logger.success('Attendance deleted: $id');
    } catch (e, stackTrace) {
      Logger.error('Failed to delete attendance', e, stackTrace);
      rethrow;
    }
  }

  Future<Map<String, AttendanceModel>> getForDate(String uid, DateTime date) async {
    try {
      final all = await getAll();
      final dateStr =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final map = <String, AttendanceModel>{};
      for (final record in all) {
        final recordDateStr =
            '${record.date.year}-${record.date.month.toString().padLeft(2, '0')}-${record.date.day.toString().padLeft(2, '0')}';
        if (recordDateStr == dateStr) {
          map[record.employeeId] = record;
        }
      }
      return map;
    } catch (e, stackTrace) {
      Logger.error('Failed to get attendance for date', e, stackTrace);
      return {};
    }
  }
}
