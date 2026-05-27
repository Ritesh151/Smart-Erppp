import 'package:hive/hive.dart';

part 'attendance_model.g.dart';

@HiveType(typeId: 14)
class AttendanceModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String employeeId;

  @HiveField(2)
  final String employeeName;

  @HiveField(3)
  final DateTime date;

  @HiveField(4)
  final AttendanceStatus status;

  @HiveField(5)
  final DateTime? checkIn;

  @HiveField(6)
  final DateTime? checkOut;

  @HiveField(7)
  final String? notes;

  @HiveField(8)
  final DateTime createdAt;

  @HiveField(9)
  final DateTime updatedAt;

  AttendanceModel({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.date,
    required this.status,
    this.checkIn,
    this.checkOut,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AttendanceModel.create({
    required String employeeId,
    required String employeeName,
    required DateTime date,
    required AttendanceStatus status,
    DateTime? checkIn,
    DateTime? checkOut,
    String? notes,
  }) {
    final now = DateTime.now();
    return AttendanceModel(
      id: _generateId(),
      employeeId: employeeId,
      employeeName: employeeName,
      date: date,
      status: status,
      checkIn: checkIn ?? (status == AttendanceStatus.present ? now : null),
      checkOut: checkOut,
      notes: notes,
      createdAt: now,
      updatedAt: now,
    );
  }

  static String _generateId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp % 10000).toString().padLeft(4, '0');
    return 'ATT-$timestamp-$random';
  }

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json['id'] as String,
      employeeId: json['employeeId'] as String,
      employeeName: json['employeeName'] as String,
      date: DateTime.parse(json['date'] as String),
      status: AttendanceStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => AttendanceStatus.present,
      ),
      checkIn: json['checkIn'] != null ? DateTime.parse(json['checkIn'] as String) : null,
      checkOut: json['checkOut'] != null ? DateTime.parse(json['checkOut'] as String) : null,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employeeId': employeeId,
      'employeeName': employeeName,
      'date': date.toIso8601String(),
      'status': status.name,
      'checkIn': checkIn?.toIso8601String(),
      'checkOut': checkOut?.toIso8601String(),
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  AttendanceModel copyWith({
    String? id,
    String? employeeId,
    String? employeeName,
    DateTime? date,
    AttendanceStatus? status,
    DateTime? checkIn,
    DateTime? checkOut,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AttendanceModel(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      employeeName: employeeName ?? this.employeeName,
      date: date ?? this.date,
      status: status ?? this.status,
      checkIn: checkIn ?? this.checkIn,
      checkOut: checkOut ?? this.checkOut,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isPresent => status == AttendanceStatus.present;
  bool get isAbsent => status == AttendanceStatus.absent;
  bool get isHalfDay => status == AttendanceStatus.halfDay;
  bool get isOnLeave => status == AttendanceStatus.leave;
  bool get isHoliday => status == AttendanceStatus.holiday;

  Duration? get workingHours {
    if (checkIn == null || checkOut == null) return null;
    return checkOut!.difference(checkIn!);
  }

  bool get isLate {
    if (checkIn == null) return false;
    final lateThreshold = DateTime(
      checkIn!.year, checkIn!.month, checkIn!.day, 9, 30,
    );
    return checkIn!.isAfter(lateThreshold);
  }
}

@HiveType(typeId: 19)
enum AttendanceStatus {
  @HiveField(0)
  present,
  @HiveField(1)
  absent,
  @HiveField(2)
  halfDay,
  @HiveField(3)
  leave,
  @HiveField(4)
  holiday,
}

extension AttendanceStatusExtension on AttendanceStatus {
  String get displayName {
    switch (this) {
      case AttendanceStatus.present:
        return 'Present';
      case AttendanceStatus.absent:
        return 'Absent';
      case AttendanceStatus.halfDay:
        return 'Half Day';
      case AttendanceStatus.leave:
        return 'Leave';
      case AttendanceStatus.holiday:
        return 'Holiday';
    }
  }
}
