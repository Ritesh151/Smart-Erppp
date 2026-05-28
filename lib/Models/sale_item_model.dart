class SaleItemModel {
  final String productId;
  final String productName;
  final String? hsnCode;
  final double quantity;
  final double price;
  final double amount;
  final double gstRate;
  final double gstAmount;
  final double totalAmount;

  SaleItemModel({
    required this.productId,
    required this.productName,
    this.hsnCode,
    required this.quantity,
    required this.price,
    required this.amount,
    this.gstRate = 0,
    this.gstAmount = 0,
    this.totalAmount = 0,
  });

  factory SaleItemModel.fromJson(Map<String, dynamic> json) {
    return SaleItemModel(
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      hsnCode: json['hsnCode'] as String?,
      quantity: (json['quantity'] as num).toDouble(),
      price: (json['price'] as num).toDouble(),
      amount: (json['amount'] as num).toDouble(),
      gstRate: (json['gstRate'] as num?)?.toDouble() ?? 0,
      gstAmount: (json['gstAmount'] as num?)?.toDouble() ?? 0,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'hsnCode': hsnCode,
      'quantity': quantity,
      'price': price,
      'amount': amount,
      'gstRate': gstRate,
      'gstAmount': gstAmount,
      'totalAmount': totalAmount,
    };
  }

  SaleItemModel copyWith({
    String? productId,
    String? productName,
    String? hsnCode,
    double? quantity,
    double? price,
    double? amount,
    double? gstRate,
    double? gstAmount,
    double? totalAmount,
  }) {
    return SaleItemModel(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      hsnCode: hsnCode ?? this.hsnCode,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      amount: amount ?? this.amount,
      gstRate: gstRate ?? this.gstRate,
      gstAmount: gstAmount ?? this.gstAmount,
      totalAmount: totalAmount ?? this.totalAmount,
    );
  }
}
