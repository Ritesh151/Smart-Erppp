import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

enum ExportStatus {
  planned,
  inTransit,
  delivered,
  cancelled;

  String get displayName {
    switch (this) {
      case ExportStatus.planned:
        return 'Planned';
      case ExportStatus.inTransit:
        return 'In Transit';
      case ExportStatus.delivered:
        return 'Delivered';
      case ExportStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color get statusColor {
    switch (this) {
      case ExportStatus.planned:
        return Colors.orange;
      case ExportStatus.inTransit:
        return Colors.blue;
      case ExportStatus.delivered:
        return Colors.green;
      case ExportStatus.cancelled:
        return Colors.red;
    }
  }
}

enum TransportType {
  truck,
  van,
  trailer,
  container,
  tempo,
  other;

  String get displayName {
    switch (this) {
      case TransportType.truck:
        return 'Truck';
      case TransportType.van:
        return 'Van';
      case TransportType.trailer:
        return 'Trailer';
      case TransportType.container:
        return 'Container';
      case TransportType.tempo:
        return 'Tempo';
      case TransportType.other:
        return 'Other';
    }
  }
}

class ProductLineItem {
  final String productId;
  final String productName;
  final String hsnCode;
  final double unitPrice;
  final double quantity;
  final String unit;

  const ProductLineItem({
    required this.productId,
    required this.productName,
    this.hsnCode = '',
    this.unitPrice = 0,
    this.quantity = 0,
    this.unit = 'PCS',
  });

  double get totalAmount => unitPrice * quantity;

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'hsnCode': hsnCode,
      'unitPrice': unitPrice,
      'quantity': quantity,
      'unit': unit,
    };
  }

  factory ProductLineItem.fromMap(Map<String, dynamic> map) {
    return ProductLineItem(
      productId: map['productId'] as String? ?? '',
      productName: map['productName'] as String? ?? '',
      hsnCode: map['hsnCode'] as String? ?? '',
      unitPrice: (map['unitPrice'] as num?)?.toDouble() ?? 0,
      quantity: (map['quantity'] as num?)?.toDouble() ?? 0,
      unit: map['unit'] as String? ?? 'PCS',
    );
  }

  ProductLineItem copyWith({
    String? productId,
    String? productName,
    String? hsnCode,
    double? unitPrice,
    double? quantity,
    String? unit,
  }) {
    return ProductLineItem(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      hsnCode: hsnCode ?? this.hsnCode,
      unitPrice: unitPrice ?? this.unitPrice,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
    );
  }
}

class TransportModel {
  final String transportId;
  final String? transportNumber;
  final String transportName;
  final String driverName;
  final List<ProductLineItem> products;
  final String sourceLocation;
  final String destinationLocation;
  final ExportStatus status;
  final DateTime transportDate;
  final TransportType transportType;
  final String? vehicleNumber;
  final String? transportCompany;
  final String? invoiceId;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TransportModel({
    required this.transportId,
    this.transportNumber,
    required this.transportName,
    required this.driverName,
    required this.products,
    required this.sourceLocation,
    required this.destinationLocation,
    required this.status,
    required this.transportDate,
    required this.transportType,
    this.vehicleNumber,
    this.transportCompany,
    this.invoiceId,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  double get totalQuantity =>
      products.fold<double>(0, (sum, p) => sum + p.quantity);

  bool get isEditable =>
      status != ExportStatus.delivered && status != ExportStatus.cancelled;

  Map<String, dynamic> toMap() {
    return {
      'transportId': transportId,
      'transportNumber': transportNumber,
      'transportName': transportName,
      'driverName': driverName,
      'products': products.map((p) => p.toMap()).toList(),
      'sourceLocation': sourceLocation,
      'destinationLocation': destinationLocation,
      'status': status.index,
      'transportDate': transportDate.toIso8601String(),
      'transportType': transportType.index,
      'vehicleNumber': vehicleNumber,
      'transportCompany': transportCompany,
      'invoiceId': invoiceId,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory TransportModel.fromMap(Map<String, dynamic> map) {
    return TransportModel(
      transportId: map['transportId'] as String? ?? '',
      transportNumber: map['transportNumber'] as String?,
      transportName: map['transportName'] as String? ?? '',
      driverName: map['driverName'] as String? ?? '',
      products: (map['products'] as List<dynamic>?)
              ?.map((p) => ProductLineItem.fromMap(Map<String, dynamic>.from(p as Map)))
              .toList() ??
          [],
      sourceLocation: map['sourceLocation'] as String? ?? '',
      destinationLocation: map['destinationLocation'] as String? ?? '',
      status: ExportStatus.values[map['status'] as int? ?? 0],
      transportDate: DateTime.tryParse(map['transportDate'] as String? ?? '') ??
          DateTime.now(),
      transportType:
          TransportType.values[map['transportType'] as int? ?? 0],
      vehicleNumber: map['vehicleNumber'] as String?,
      transportCompany: map['transportCompany'] as String?,
      invoiceId: map['invoiceId'] as String?,
      notes: map['notes'] as String?,
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(map['updatedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  TransportModel copyWith({
    String? transportId,
    String? transportNumber,
    String? transportName,
    String? driverName,
    List<ProductLineItem>? products,
    String? sourceLocation,
    String? destinationLocation,
    ExportStatus? status,
    DateTime? transportDate,
    TransportType? transportType,
    String? vehicleNumber,
    String? transportCompany,
    String? invoiceId,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TransportModel(
      transportId: transportId ?? this.transportId,
      transportNumber: transportNumber ?? this.transportNumber,
      transportName: transportName ?? this.transportName,
      driverName: driverName ?? this.driverName,
      products: products ?? this.products,
      sourceLocation: sourceLocation ?? this.sourceLocation,
      destinationLocation: destinationLocation ?? this.destinationLocation,
      status: status ?? this.status,
      transportDate: transportDate ?? this.transportDate,
      transportType: transportType ?? this.transportType,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      transportCompany: transportCompany ?? this.transportCompany,
      invoiceId: invoiceId ?? this.invoiceId,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory TransportModel.create({
    required String transportName,
    required String driverName,
    required List<ProductLineItem> products,
    required String sourceLocation,
    required String destinationLocation,
    required ExportStatus status,
    required DateTime transportDate,
    required TransportType transportType,
    String? vehicleNumber,
    String? transportCompany,
    String? invoiceId,
    String? notes,
  }) {
    final now = DateTime.now();
    return TransportModel(
      transportId: const Uuid().v4(),
      transportNumber: 'TRN-${now.millisecondsSinceEpoch.toString().substring(5)}',
      transportName: transportName,
      driverName: driverName,
      products: products,
      sourceLocation: sourceLocation,
      destinationLocation: destinationLocation,
      status: status,
      transportDate: transportDate,
      transportType: transportType,
      vehicleNumber: vehicleNumber,
      transportCompany: transportCompany,
      invoiceId: invoiceId,
      notes: notes,
      createdAt: now,
      updatedAt: now,
    );
  }
}
