import 'package:hive/hive.dart';

part 'salary_model.g.dart';

@HiveType(typeId: 15)
class SalaryModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String employeeId;

  @HiveField(2)
  final String employeeName;

  @HiveField(3)
  final int month;

  @HiveField(4)
  final int year;

  @HiveField(5)
  final double basicSalary;

  @HiveField(6)
  final double bonus;

  @HiveField(7)
  final double overtime;

  @HiveField(8)
  final double deductions;

  @HiveField(9)
  final double netSalary;

  @HiveField(10)
  final double paidAmount;

  @HiveField(11)
  final SalaryStatus status;

  @HiveField(12)
  final DateTime? paymentDate;

  @HiveField(13)
  final String? notes;

  @HiveField(14)
  final DateTime createdAt;

  @HiveField(15)
  final DateTime updatedAt;

  SalaryModel({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.month,
    required this.year,
    required this.basicSalary,
    this.bonus = 0,
    this.overtime = 0,
    this.deductions = 0,
    required this.netSalary,
    this.paidAmount = 0,
    this.status = SalaryStatus.pending,
    this.paymentDate,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SalaryModel.create({
    required String employeeId,
    required String employeeName,
    required int month,
    required int year,
    required double basicSalary,
    double bonus = 0,
    double overtime = 0,
    double deductions = 0,
    String? notes,
  }) {
    final netSalary = basicSalary + bonus + overtime - deductions;
    final now = DateTime.now();
    return SalaryModel(
      id: _generateId(),
      employeeId: employeeId,
      employeeName: employeeName,
      month: month,
      year: year,
      basicSalary: basicSalary,
      bonus: bonus,
      overtime: overtime,
      deductions: deductions,
      netSalary: netSalary < 0 ? 0 : netSalary,
      notes: notes,
      createdAt: now,
      updatedAt: now,
    );
  }

  static String _generateId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp % 10000).toString().padLeft(4, '0');
    return 'SAL-$timestamp-$random';
  }

  factory SalaryModel.fromJson(Map<String, dynamic> json) {
    return SalaryModel(
      id: json['id'] as String,
      employeeId: json['employeeId'] as String,
      employeeName: json['employeeName'] as String,
      month: json['month'] as int,
      year: json['year'] as int,
      basicSalary: (json['basicSalary'] as num).toDouble(),
      bonus: (json['bonus'] as num?)?.toDouble() ?? 0,
      overtime: (json['overtime'] as num?)?.toDouble() ?? 0,
      deductions: (json['deductions'] as num?)?.toDouble() ?? 0,
      netSalary: (json['netSalary'] as num).toDouble(),
      paidAmount: (json['paidAmount'] as num?)?.toDouble() ?? 0,
      status: SalaryStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => SalaryStatus.pending,
      ),
      paymentDate: json['paymentDate'] != null ? DateTime.parse(json['paymentDate'] as String) : null,
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
      'month': month,
      'year': year,
      'basicSalary': basicSalary,
      'bonus': bonus,
      'overtime': overtime,
      'deductions': deductions,
      'netSalary': netSalary,
      'paidAmount': paidAmount,
      'status': status.name,
      'paymentDate': paymentDate?.toIso8601String(),
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  SalaryModel copyWith({
    String? id,
    String? employeeId,
    String? employeeName,
    int? month,
    int? year,
    double? basicSalary,
    double? bonus,
    double? overtime,
    double? deductions,
    double? netSalary,
    double? paidAmount,
    SalaryStatus? status,
    DateTime? paymentDate,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SalaryModel(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      employeeName: employeeName ?? this.employeeName,
      month: month ?? this.month,
      year: year ?? this.year,
      basicSalary: basicSalary ?? this.basicSalary,
      bonus: bonus ?? this.bonus,
      overtime: overtime ?? this.overtime,
      deductions: deductions ?? this.deductions,
      netSalary: netSalary ?? this.netSalary,
      paidAmount: paidAmount ?? this.paidAmount,
      status: status ?? this.status,
      paymentDate: paymentDate ?? this.paymentDate,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  double get pendingAmount => netSalary - paidAmount;
  bool get isFullyPaid => paidAmount >= netSalary;
  bool get isPartiallyPaid => paidAmount > 0 && paidAmount < netSalary;
  bool get isOverdue => status == SalaryStatus.pending && _isPastDueDate;

  bool get _isPastDueDate {
    final dueDate = DateTime(year, month + 1, 10);
    return DateTime.now().isAfter(dueDate);
  }
}

@HiveType(typeId: 20)
enum SalaryStatus {
  @HiveField(0)
  paid,
  @HiveField(1)
  pending,
  @HiveField(2)
  partiallyPaid,
  @HiveField(3)
  overdue,
}

extension SalaryStatusExtension on SalaryStatus {
  String get displayName {
    switch (this) {
      case SalaryStatus.paid:
        return 'Paid';
      case SalaryStatus.pending:
        return 'Pending';
      case SalaryStatus.partiallyPaid:
        return 'Partially Paid';
      case SalaryStatus.overdue:
        return 'Overdue';
    }
  }
}
