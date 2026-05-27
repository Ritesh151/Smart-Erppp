import 'package:hive/hive.dart';

part 'transport_item_model.g.dart';

@HiveType(typeId: 10)
class TransportItemModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String transportId;

  @HiveField(2)
  final String productId;

  @HiveField(3)
  final String productName;

  @HiveField(4)
  final String? hsnCode;

  @HiveField(5)
  final double quantity;

  @HiveField(6)
  final String unit;

  @HiveField(7)
  final double allocatedQuantity;

  @HiveField(8)
  final double deliveredQuantity;

  @HiveField(9)
  final String? notes;

  TransportItemModel({
    required this.id,
    required this.transportId,
    required this.productId,
    required this.productName,
    this.hsnCode,
    required this.quantity,
    this.unit = 'Piece',
    this.allocatedQuantity = 0,
    this.deliveredQuantity = 0,
    this.notes,
  });

  factory TransportItemModel.create({
    required String transportId,
    required String productId,
    required String productName,
    String? hsnCode,
    required double quantity,
    String unit = 'Piece',
    String? notes,
  }) {
    return TransportItemModel(
      id: _generateId(),
      transportId: transportId,
      productId: productId,
      productName: productName,
      hsnCode: hsnCode,
      quantity: quantity,
      unit: unit,
      allocatedQuantity: quantity,
      deliveredQuantity: 0,
      notes: notes,
    );
  }

  static String _generateId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp % 10000).toString().padLeft(4, '0');
    return 'TRI-$timestamp-$random';
  }

  factory TransportItemModel.fromJson(Map<String, dynamic> json) {
    return TransportItemModel(
      id: json['id'] as String,
      transportId: json['transportId'] as String,
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      hsnCode: json['hsnCode'] as String?,
      quantity: (json['quantity'] as num).toDouble(),
      unit: json['unit'] as String? ?? 'Piece',
      allocatedQuantity: (json['allocatedQuantity'] as num?)?.toDouble() ?? 0,
      deliveredQuantity: (json['deliveredQuantity'] as num?)?.toDouble() ?? 0,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'transportId': transportId,
      'productId': productId,
      'productName': productName,
      'hsnCode': hsnCode,
      'quantity': quantity,
      'unit': unit,
      'allocatedQuantity': allocatedQuantity,
      'deliveredQuantity': deliveredQuantity,
      'notes': notes,
    };
  }

  TransportItemModel copyWith({
    String? id,
    String? transportId,
    String? productId,
    String? productName,
    String? hsnCode,
    double? quantity,
    String? unit,
    double? allocatedQuantity,
    double? deliveredQuantity,
    String? notes,
  }) {
    return TransportItemModel(
      id: id ?? this.id,
      transportId: transportId ?? this.transportId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      hsnCode: hsnCode ?? this.hsnCode,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      allocatedQuantity: allocatedQuantity ?? this.allocatedQuantity,
      deliveredQuantity: deliveredQuantity ?? this.deliveredQuantity,
      notes: notes ?? this.notes,
    );
  }

  double get remainingToDeliver => allocatedQuantity - deliveredQuantity;
  bool get isFullyDelivered => deliveredQuantity >= allocatedQuantity;
}
