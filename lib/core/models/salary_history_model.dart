import 'package:hive/hive.dart';

part 'salary_history_model.g.dart';

@HiveType(typeId: 16)
class SalaryHistoryModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String salaryId;

  @HiveField(2)
  final String employeeId;

  @HiveField(3)
  final String employeeName;

  @HiveField(4)
  final double amount;

  @HiveField(5)
  final PaymentMethod paymentMethod;

  @HiveField(6)
  final DateTime paymentDate;

  @HiveField(7)
  final String? notes;

  @HiveField(8)
  final String? referenceNumber;

  @HiveField(9)
  final PaymentType paymentType;

  @HiveField(10)
  final DateTime createdAt;

  SalaryHistoryModel({
    required this.id,
    required this.salaryId,
    required this.employeeId,
    required this.employeeName,
    required this.amount,
    required this.paymentMethod,
    required this.paymentDate,
    this.notes,
    this.referenceNumber,
    required this.paymentType,
    required this.createdAt,
  });

  factory SalaryHistoryModel.create({
    required String salaryId,
    required String employeeId,
    required String employeeName,
    required double amount,
    required PaymentMethod paymentMethod,
    String? notes,
    String? referenceNumber,
    PaymentType paymentType = PaymentType.full,
  }) {
    return SalaryHistoryModel(
      id: _generateId(),
      salaryId: salaryId,
      employeeId: employeeId,
      employeeName: employeeName,
      amount: amount,
      paymentMethod: paymentMethod,
      paymentDate: DateTime.now(),
      notes: notes,
      referenceNumber: referenceNumber,
      paymentType: paymentType,
      createdAt: DateTime.now(),
    );
  }

  static String _generateId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp % 10000).toString().padLeft(4, '0');
    return 'SH-$timestamp-$random';
  }

  factory SalaryHistoryModel.fromJson(Map<String, dynamic> json) {
    return SalaryHistoryModel(
      id: json['id'] as String,
      salaryId: json['salaryId'] as String,
      employeeId: json['employeeId'] as String,
      employeeName: json['employeeName'] as String,
      amount: (json['amount'] as num).toDouble(),
      paymentMethod: PaymentMethod.values.firstWhere(
        (e) => e.name == json['paymentMethod'],
        orElse: () => PaymentMethod.cash,
      ),
      paymentDate: DateTime.parse(json['paymentDate'] as String),
      notes: json['notes'] as String?,
      referenceNumber: json['referenceNumber'] as String?,
      paymentType: PaymentType.values.firstWhere(
        (e) => e.name == json['paymentType'],
        orElse: () => PaymentType.full,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'salaryId': salaryId,
      'employeeId': employeeId,
      'employeeName': employeeName,
      'amount': amount,
      'paymentMethod': paymentMethod.name,
      'paymentDate': paymentDate.toIso8601String(),
      'notes': notes,
      'referenceNumber': referenceNumber,
      'paymentType': paymentType.name,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  SalaryHistoryModel copyWith({
    String? id,
    String? salaryId,
    String? employeeId,
    String? employeeName,
    double? amount,
    PaymentMethod? paymentMethod,
    DateTime? paymentDate,
    String? notes,
    String? referenceNumber,
    PaymentType? paymentType,
    DateTime? createdAt,
  }) {
    return SalaryHistoryModel(
      id: id ?? this.id,
      salaryId: salaryId ?? this.salaryId,
      employeeId: employeeId ?? this.employeeId,
      employeeName: employeeName ?? this.employeeName,
      amount: amount ?? this.amount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentDate: paymentDate ?? this.paymentDate,
      notes: notes ?? this.notes,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      paymentType: paymentType ?? this.paymentType,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

@HiveType(typeId: 21)
enum PaymentMethod {
  @HiveField(0)
  cash,
  @HiveField(1)
  upi,
  @HiveField(2)
  bankTransfer,
  @HiveField(3)
  cheque,
}

@HiveType(typeId: 22)
enum PaymentType {
  @HiveField(0)
  full,
  @HiveField(1)
  partial,
}

extension PaymentMethodExtension on PaymentMethod {
  String get displayName {
    switch (this) {
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.upi:
        return 'UPI';
      case PaymentMethod.bankTransfer:
        return 'Bank Transfer';
      case PaymentMethod.cheque:
        return 'Cheque';
    }
  }
}

extension PaymentTypeExtension on PaymentType {
  String get displayName {
    switch (this) {
      case PaymentType.full:
        return 'Full Payment';
      case PaymentType.partial:
        return 'Partial Payment';
    }
  }
}
