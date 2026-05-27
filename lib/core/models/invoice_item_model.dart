import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'invoice_item_model.g.dart';

@HiveType(typeId: 4)
class InvoiceItemModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String productId;

  @HiveField(2)
  final String productName;

  @HiveField(3)
  final String? hsnCode;

  @HiveField(4)
  final String? description;

  @HiveField(5)
  final double quantity;

  @HiveField(6)
  final String unit;

  @HiveField(7)
  final double unitPrice;

  @HiveField(8)
  final double taxRate;

  @HiveField(9)
  final double discountRate;

  @HiveField(10)
  final double amount;

  InvoiceItemModel({
    required this.id,
    required this.productId,
    required this.productName,
    this.hsnCode,
    this.description,
    required this.quantity,
    required this.unit,
    required this.unitPrice,
    required this.taxRate,
    required this.discountRate,
    required this.amount,
  });

  factory InvoiceItemModel.create({
    required String productId,
    required String productName,
    String? hsnCode,
    String? description,
    required double quantity,
    required String unit,
    required double unitPrice,
    double taxRate = 0,
    double discountRate = 0,
  }) {
    final subtotal = unitPrice * quantity;
    final discountAmount = subtotal * (discountRate / 100);
    final taxableAmount = subtotal - discountAmount;
    final amount = taxableAmount + (taxableAmount * taxRate / 100);
    return InvoiceItemModel(
      id: const Uuid().v4(),
      productId: productId,
      productName: productName,
      hsnCode: hsnCode,
      description: description,
      quantity: quantity,
      unit: unit,
      unitPrice: unitPrice,
      taxRate: taxRate,
      discountRate: discountRate,
      amount: amount,
    );
  }

  factory InvoiceItemModel.fromJson(Map<String, dynamic> json) {
    return InvoiceItemModel(
      id: json['id'] as String,
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      hsnCode: json['hsnCode'] as String?,
      description: json['description'] as String?,
      quantity: (json['quantity'] as num).toDouble(),
      unit: json['unit'] as String,
      unitPrice: (json['unitPrice'] as num).toDouble(),
      taxRate: (json['taxRate'] as num).toDouble(),
      discountRate: (json['discountRate'] as num).toDouble(),
      amount: (json['amount'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'hsnCode': hsnCode,
      'description': description,
      'quantity': quantity,
      'unit': unit,
      'unitPrice': unitPrice,
      'taxRate': taxRate,
      'discountRate': discountRate,
      'amount': amount,
    };
  }

  InvoiceItemModel copyWith({
    String? id,
    String? productId,
    String? productName,
    String? hsnCode,
    String? description,
    double? quantity,
    String? unit,
    double? unitPrice,
    double? taxRate,
    double? discountRate,
    double? amount,
  }) {
    return InvoiceItemModel(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      hsnCode: hsnCode ?? this.hsnCode,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      unitPrice: unitPrice ?? this.unitPrice,
      taxRate: taxRate ?? this.taxRate,
      discountRate: discountRate ?? this.discountRate,
      amount: amount ?? this.amount,
    );
  }

  double get subtotal => unitPrice * quantity;
  double get discountAmount => subtotal * (discountRate / 100);
  double get taxableAmount => subtotal - discountAmount;
  double get taxAmount => taxableAmount * (taxRate / 100);
}
