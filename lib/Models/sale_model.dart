import 'sale_item_model.dart';

class SaleModel {
  final String saleId;
  final String customerName;
  final String customerPhone;
  final String customerAddress;
  final List<SaleItemModel> items;
  final DateTime createdAt;
  final DateTime? dueDate;
  final double total;

  SaleModel({
    required this.saleId,
    required this.customerName,
    this.customerPhone = '',
    this.customerAddress = '',
    required this.items,
    required this.createdAt,
    this.dueDate,
    double? total,
  }) : total = total ?? items.fold<double>(0, (sum, item) => sum + item.totalAmount);

  factory SaleModel.fromJson(Map<String, dynamic> json) {
    return SaleModel(
      saleId: json['saleId'] as String,
      customerName: json['customerName'] as String,
      customerPhone: json['customerPhone'] as String? ?? '',
      customerAddress: json['customerAddress'] as String? ?? '',
      items: (json['items'] as List<dynamic>)
          .map((e) => SaleItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate'] as String) : null,
      total: (json['total'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'saleId': saleId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'customerAddress': customerAddress,
      'items': items.map((e) => e.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'total': total,
    };
  }
}
