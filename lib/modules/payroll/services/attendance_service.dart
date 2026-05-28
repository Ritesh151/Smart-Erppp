import 'package:SmartERP/core/models/attendance_model.dart';
import 'package:SmartERP/modules/payroll/repositories/attendance_repository.dart';

class AttendanceService {
  final AttendanceRepository _repository;

  AttendanceService(this._repository);

  Future<List<AttendanceModel>> getAllRecords() => _repository.getAll();

  Future<void> markAttendance(AttendanceModel record) =>
      _repository.save(record);

  Future<Map<String, AttendanceModel>> fetchAttendanceForDate(
          String uid, DateTime date) =>
      _repository.getForDate(uid, date);

  Future<void> deleteRecord(String id) => _repository.delete(id);
}
