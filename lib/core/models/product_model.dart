import 'package:hive/hive.dart';

part 'product_model.g.dart';

@HiveType(typeId: 0)
class ProductModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String productName;

  @HiveField(2)
  final String? hsnCode;

  @HiveField(3)
  final double price;

  @HiveField(4)
  final int stockQuantity;

  @HiveField(5)
  final String? description;

  @HiveField(6)
  final String? imagePath;

  @HiveField(7)
  @Deprecated('Category field is no longer used. Kept for Hive backward compatibility.')
  final String? category;

  @HiveField(8)
  final int minStockLevel;

  @HiveField(9)
  final String unit;

  @HiveField(10)
  final bool isActive;

  @HiveField(11)
  final DateTime createdAt;

  @HiveField(12)
  final DateTime updatedAt;

  @HiveField(13)
  final bool isFixed;

  ProductModel({
    required this.id,
    required this.productName,
    this.hsnCode,
    required this.price,
    required this.stockQuantity,
    this.description,
    this.imagePath,
    this.category,
    required this.minStockLevel,
    required this.unit,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.isFixed = false,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      productName: json['productName'] as String,
      hsnCode: json['hsnCode'] as String?,
      price: (json['price'] as num).toDouble(),
      stockQuantity: json['stockQuantity'] as int,
      description: json['description'] as String?,
      imagePath: json['imagePath'] as String?,
      minStockLevel: json['minStockLevel'] as int,
      unit: json['unit'] as String,
      isActive: json['isActive'] as bool,
      isFixed: json['isFixed'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productName': productName,
      'hsnCode': hsnCode,
      'price': price,
      'stockQuantity': stockQuantity,
      'description': description,
      'imagePath': imagePath,
      'minStockLevel': minStockLevel,
      'unit': unit,
      'isActive': isActive,
      'isFixed': isFixed,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  ProductModel copyWith({
    String? id,
    String? productName,
    String? hsnCode,
    double? price,
    int? stockQuantity,
    String? description,
    String? imagePath,
    int? minStockLevel,
    String? unit,
    bool? isActive,
    bool? isFixed,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      productName: productName ?? this.productName,
      hsnCode: hsnCode ?? this.hsnCode,
      price: price ?? this.price,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      description: description ?? this.description,
      imagePath: imagePath ?? this.imagePath,
      minStockLevel: minStockLevel ?? this.minStockLevel,
      unit: unit ?? this.unit,
      isActive: isActive ?? this.isActive,
      isFixed: isFixed ?? this.isFixed,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isLowStock => stockQuantity <= minStockLevel && stockQuantity > 0;

  bool get isOutOfStock => stockQuantity == 0;

  bool get isInStock => stockQuantity > minStockLevel;

  StockStatus get stockStatus {
    if (isOutOfStock) return StockStatus.outOfStock;
    if (isLowStock) return StockStatus.lowStock;
    return StockStatus.inStock;
  }

  double get inventoryValue => price * stockQuantity;
}

enum StockStatus {
  inStock,
  lowStock,
  outOfStock,
}
