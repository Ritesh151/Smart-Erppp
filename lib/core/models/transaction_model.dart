import 'package:hive/hive.dart';

part 'transaction_model.g.dart';

@HiveType(typeId: 1)
class TransactionModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final TransactionType type;

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final DateTime date;

  @HiveField(4)
  final String description;

  @HiveField(5)
  final String? referenceId;

  @HiveField(6)
  final String? category;

  @HiveField(7)
  final DateTime createdAt;

  @HiveField(8)
  final DateTime updatedAt;

  TransactionModel({
    required this.id,
    required this.type,
    required this.amount,
    required this.date,
    required this.description,
    this.referenceId,
    this.category,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      type: TransactionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => TransactionType.sale,
      ),
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      description: json['description'] as String,
      referenceId: json['referenceId'] as String?,
      category: json['category'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'amount': amount,
      'date': date.toIso8601String(),
      'description': description,
      'referenceId': referenceId,
      'category': category,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  TransactionModel copyWith({
    String? id,
    TransactionType? type,
    double? amount,
    DateTime? date,
    String? description,
    String? referenceId,
    String? category,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      description: description ?? this.description,
      referenceId: referenceId ?? this.referenceId,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

@HiveType(typeId: 2)
enum TransactionType {
  @HiveField(0)
  sale,

  @HiveField(1)
  purchase,

  @HiveField(2)
  expense,

  @HiveField(3)
  income,
}
