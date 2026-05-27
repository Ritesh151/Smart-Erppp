import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'payment_model.g.dart';

@HiveType(typeId: 6)
class PaymentModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String invoiceId;

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final DateTime paymentDate;

  @HiveField(4)
  final PaymentMode mode;

  @HiveField(5)
  final String? reference;

  @HiveField(6)
  final String? notes;

  @HiveField(7)
  final DateTime createdAt;

  PaymentModel({
    required this.id,
    required this.invoiceId,
    required this.amount,
    required this.paymentDate,
    required this.mode,
    this.reference,
    this.notes,
    required this.createdAt,
  });

  factory PaymentModel.create({
    required String invoiceId,
    required double amount,
    required DateTime paymentDate,
    PaymentMode mode = PaymentMode.cash,
    String? reference,
    String? notes,
  }) {
    return PaymentModel(
      id: const Uuid().v4(),
      invoiceId: invoiceId,
      amount: amount,
      paymentDate: paymentDate,
      mode: mode,
      reference: reference,
      notes: notes,
      createdAt: DateTime.now(),
    );
  }

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] as String,
      invoiceId: json['invoiceId'] as String,
      amount: (json['amount'] as num).toDouble(),
      paymentDate: DateTime.parse(json['paymentDate'] as String),
      mode: PaymentMode.values.firstWhere(
        (e) => e.name == json['mode'],
        orElse: () => PaymentMode.cash,
      ),
      reference: json['reference'] as String?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'invoiceId': invoiceId,
      'amount': amount,
      'paymentDate': paymentDate.toIso8601String(),
      'mode': mode.name,
      'reference': reference,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  PaymentModel copyWith({
    String? id,
    String? invoiceId,
    double? amount,
    DateTime? paymentDate,
    PaymentMode? mode,
    String? reference,
    String? notes,
    DateTime? createdAt,
  }) {
    return PaymentModel(
      id: id ?? this.id,
      invoiceId: invoiceId ?? this.invoiceId,
      amount: amount ?? this.amount,
      paymentDate: paymentDate ?? this.paymentDate,
      mode: mode ?? this.mode,
      reference: reference ?? this.reference,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

@HiveType(typeId: 8)
enum PaymentMode {
  @HiveField(0)
  cash,
  @HiveField(1)
  bankTransfer,
  @HiveField(2)
  cheque,
  @HiveField(3)
  card,
  @HiveField(4)
  upi,
  @HiveField(5)
  online,
}
