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
  final double gstRate;

  @HiveField(6)
  final String? description;

  @HiveField(7)
  final String? imagePath;

  @HiveField(8)
  final String category;

  @HiveField(9)
  final double costPrice;

  @HiveField(10)
  final int minStockLevel;

  @HiveField(11)
  final String unit;

  @HiveField(12)
  final String? sku;

  @HiveField(13)
  final String? barcode;

  @HiveField(14)
  final bool isActive;

  @HiveField(15)
  final DateTime createdAt;

  @HiveField(16)
  final DateTime updatedAt;

  @HiveField(17)
  final bool isFixed;

  ProductModel({
    required this.id,
    required this.productName,
    this.hsnCode,
    required this.price,
    required this.stockQuantity,
    required this.gstRate,
    this.description,
    this.imagePath,
    required this.category,
    required this.costPrice,
    required this.minStockLevel,
    required this.unit,
    this.sku,
    this.barcode,
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
      gstRate: (json['gstRate'] as num).toDouble(),
      description: json['description'] as String?,
      imagePath: json['imagePath'] as String?,
      category: json['category'] as String,
      costPrice: (json['costPrice'] as num).toDouble(),
      minStockLevel: json['minStockLevel'] as int,
      unit: json['unit'] as String,
      sku: json['sku'] as String?,
      barcode: json['barcode'] as String?,
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
      'gstRate': gstRate,
      'description': description,
      'imagePath': imagePath,
      'category': category,
      'costPrice': costPrice,
      'minStockLevel': minStockLevel,
      'unit': unit,
      'sku': sku,
      'barcode': barcode,
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
    double? gstRate,
    String? description,
    String? imagePath,
    String? category,
    double? costPrice,
    int? minStockLevel,
    String? unit,
    String? sku,
    String? barcode,
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
      gstRate: gstRate ?? this.gstRate,
      description: description ?? this.description,
      imagePath: imagePath ?? this.imagePath,
      category: category ?? this.category,
      costPrice: costPrice ?? this.costPrice,
      minStockLevel: minStockLevel ?? this.minStockLevel,
      unit: unit ?? this.unit,
      sku: sku ?? this.sku,
      barcode: barcode ?? this.barcode,
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

  double get profitMargin => price - costPrice;

  double get profitMarginPercentage =>
      costPrice > 0 ? ((price - costPrice) / costPrice) * 100 : 0;

  double get inventoryValue => price * stockQuantity;

  double get priceWithGst => price + (price * gstRate / 100);
}

enum StockStatus {
  inStock,
  lowStock,
  outOfStock,
}
