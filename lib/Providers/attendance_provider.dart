import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:siddhivinayak_enterprise/core/models/attendance_model.dart';
import 'package:siddhivinayak_enterprise/core/storage/storage_service.dart';
import 'package:siddhivinayak_enterprise/core/constants/storage_keys.dart';
import 'package:siddhivinayak_enterprise/modules/payroll/repositories/attendance_repository.dart';
import 'package:siddhivinayak_enterprise/modules/payroll/services/attendance_service.dart';

final _attendanceStorageProvider = Provider<StorageService<Map<dynamic, dynamic>>>((ref) {
  return StorageService<Map<dynamic, dynamic>>(StorageKeys.attendanceBox);
});

final _attendanceRepoProvider = Provider<AttendanceRepository>((ref) {
  return AttendanceRepository(ref.read(_attendanceStorageProvider));
});

final attendanceServiceProvider = Provider<AttendanceService>((ref) {
  return AttendanceService(ref.read(_attendanceRepoProvider));
});

class AttendanceController {
  final AttendanceService _service;

  AttendanceController(this._service);

  Future<void> markAttendance(AttendanceModel record) async {
    await _service.markAttendance(record);
  }
}

final attendanceControllerProvider = Provider<AttendanceController>((ref) {
  return AttendanceController(ref.read(attendanceServiceProvider));
});
