import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:siddhivinayak_enterprise/core/constants/storage_keys.dart';
import 'package:siddhivinayak_enterprise/core/models/invoice_item_model.dart';
import 'package:siddhivinayak_enterprise/core/models/invoice_model.dart';
import 'package:siddhivinayak_enterprise/core/models/product_model.dart';
import 'package:siddhivinayak_enterprise/Models/sale_item_model.dart';

class SaleRecord {
  final String saleId;
  final String invoiceId;
  final String customerName;
  final String customerPhone;
  final String customerAddress;
  final double total;
  final double gst;
  final List<SaleItemModel> items;
  final DateTime createdAt;
  final String invoiceNumber;
  final String paymentStatus;
  final String invoiceStatus;
  final bool isReturn;

  const SaleRecord({
    required this.saleId,
    required this.invoiceId,
    required this.customerName,
    this.customerPhone = '',
    this.customerAddress = '',
    required this.total,
    required this.gst,
    required this.items,
    required this.createdAt,
    required this.invoiceNumber,
    required this.paymentStatus,
    required this.invoiceStatus,
    this.isReturn = false,
  });

  factory SaleRecord.fromInvoice(
    InvoiceModel invoice,
    List<InvoiceItemModel> invoiceItems,
  ) {
    final saleItems = invoiceItems.map((item) {
      return SaleItemModel(
        productId: item.productId,
        productName: item.productName,
        hsnCode: item.hsnCode,
        quantity: item.quantity,
        price: item.unitPrice,
        amount: item.taxableAmount,
        gstRate: item.taxRate,
        gstAmount: item.taxAmount,
        totalAmount: item.amount,
      );
    }).toList();

    return SaleRecord(
      saleId: invoice.id,
      invoiceId: invoice.id,
      customerName: invoice.customerName,
      customerPhone: invoice.customerPhone ?? '',
      customerAddress: invoice.customerAddress ?? '',
      total: invoice.status == InvoiceStatus.cancelled ? 0 : invoice.totalAmount,
      gst: invoice.status == InvoiceStatus.cancelled ? 0 : invoice.taxAmount,
      items: saleItems,
      createdAt: invoice.invoiceDate,
      invoiceNumber: invoice.invoiceNumber,
      paymentStatus: _paymentStatus(invoice),
      invoiceStatus: invoice.status.name,
    );
  }

  factory SaleRecord.fromReturn(Map<String, dynamic> map) {
    final refundAmount = (map['refundAmount'] as num?)?.toDouble() ?? 0;
    final rawItems = map['items'] as List<dynamic>? ?? const [];
    final items = rawItems.map((entry) {
      final item = Map<String, dynamic>.from(entry as Map);
      final quantity = (item['quantity'] as num?)?.toDouble() ?? 0;
      final unitPrice = (item['unitPrice'] as num?)?.toDouble() ??
          (item['price'] as num?)?.toDouble() ??
          0;
      final taxRate = (item['taxRate'] as num?)?.toDouble() ??
          (item['gstRate'] as num?)?.toDouble() ??
          0;
      final taxableAmount = unitPrice * quantity;
      final gstAmount =
          (item['gstAmount'] as num?)?.toDouble() ?? taxableAmount * taxRate / 100;
      return SaleItemModel(
        productId: item['productId'] as String? ?? '',
        productName: item['productName'] as String? ?? '',
        hsnCode: item['hsnCode'] as String?,
        quantity: quantity,
        price: unitPrice,
        amount: taxableAmount,
        gstRate: taxRate,
        gstAmount: gstAmount,
        totalAmount: taxableAmount + gstAmount,
      );
    }).toList();

    return SaleRecord(
      saleId: map['id'] as String? ?? '',
      invoiceId: map['invoiceId'] as String? ?? '',
      customerName: map['customerName'] as String? ?? '',
      total: -refundAmount,
      gst: -items.fold<double>(0, (sum, item) => sum + item.gstAmount),
      items: items,
      createdAt: DateTime.tryParse(
            map['returnDate'] as String? ?? map['createdAt'] as String? ?? '',
          ) ??
          DateTime.now(),
      invoiceNumber: map['invoiceNumber'] as String? ?? '',
      paymentStatus: 'Refunded',
      invoiceStatus: 'returned',
      isReturn: true,
    );
  }
}

String _paymentStatus(InvoiceModel invoice) {
  if (invoice.status == InvoiceStatus.cancelled) return 'Cancelled';
  if (invoice.paidAmount <= 0) return 'Unpaid';
  if (invoice.paidAmount >= invoice.totalAmount) return 'Paid';
  return 'Partially Paid';
}

class ProductInfo {
  final String productId;
  final String name;
  final String? hsnCode;
  final double price;
  final int stock;

  ProductInfo({
    required this.productId,
    required this.name,
    this.hsnCode,
    required this.price,
    required this.stock,
  });

  factory ProductInfo.fromProductModel(ProductModel model) {
    return ProductInfo(
      productId: model.id,
      name: model.productName,
      hsnCode: model.hsnCode,
      price: model.price,
      stock: model.stockQuantity,
    );
  }

  factory ProductInfo.fromMap(Map<String, dynamic> map) {
    return ProductInfo(
      productId: map['id'] as String? ?? map['productId'] as String,
      name: map['productName'] as String? ?? map['name'] as String,
      hsnCode: map['hsnCode'] as String?,
      price: (map['price'] as num?)?.toDouble() ?? 0,
      stock: (map['stockQuantity'] as int?) ?? (map['stock'] as int?) ?? 0,
    );
  }
}

final salesStreamProvider = StreamProvider<List<SaleRecord>>((ref) {
  final controller = StreamController<List<SaleRecord>>();
  final subscriptions = <StreamSubscription<dynamic>>[];

  void emit() {
    if (controller.isClosed) return;
    try {
      final invoiceBox = Hive.box(StorageKeys.invoicesBox);
      final itemBox = Hive.box(StorageKeys.invoiceItemsBox);
      final returnsBox = Hive.box(StorageKeys.returnsBox);
      final records = <SaleRecord>[];

      for (final value in invoiceBox.values) {
        if (value is! Map) continue;
        final invoice = InvoiceModel.fromJson(Map<String, dynamic>.from(value));
        final items = <InvoiceItemModel>[];
        for (final itemId in invoice.itemIds) {
          final rawItem = itemBox.get(itemId);
          if (rawItem is Map) {
            items.add(InvoiceItemModel.fromJson(Map<String, dynamic>.from(rawItem)));
          }
        }
        records.add(SaleRecord.fromInvoice(invoice, items));
      }

      for (final value in returnsBox.values) {
        if (value is Map) {
          records.add(SaleRecord.fromReturn(Map<String, dynamic>.from(value)));
        }
      }

      records.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      controller.add(records);
    } catch (e) {
      controller.add([]);
    }
  }

  emit();

  try {
    for (final boxName in [
      StorageKeys.invoicesBox,
      StorageKeys.invoiceItemsBox,
      StorageKeys.returnsBox,
    ]) {
      if (Hive.isBoxOpen(boxName)) {
        subscriptions.add(Hive.box(boxName).watch().listen((_) => emit()));
      }
    }
  } catch (_) {}

  final timer = subscriptions.isEmpty
      ? Timer.periodic(const Duration(seconds: 5), (_) => emit())
      : null;
  ref.onDispose(() {
    for (final sub in subscriptions) {
      sub.cancel();
    }
    timer?.cancel();
    if (!controller.isClosed) controller.close();
  });

  return controller.stream;
});

final productsStreamProvider = StreamProvider<List<ProductInfo>>((ref) {
  final controller = StreamController<List<ProductInfo>>();

  void emit() {
    if (controller.isClosed) return;
    try {
      final data = <ProductInfo>[];
      if (Hive.isBoxOpen(StorageKeys.productsBox)) {
        final box = Hive.box(StorageKeys.productsBox);
        for (final key in box.keys) {
          final value = box.get(key);
          if (value is ProductModel) {
            data.add(ProductInfo.fromProductModel(value));
          } else if (value is Map) {
            data.add(ProductInfo.fromMap(Map<String, dynamic>.from(value)));
          }
        }
      }
      controller.add(data);
    } catch (e) {
      controller.add([]);
    }
  }

  emit();

  try {
    if (Hive.isBoxOpen(StorageKeys.productsBox)) {
      final box = Hive.box(StorageKeys.productsBox);
      final sub = box.watch().listen((_) => emit());
      ref.onDispose(() {
        sub.cancel();
        if (!controller.isClosed) controller.close();
      });
      return controller.stream;
    }
  } catch (_) {}

  final timer = Timer.periodic(const Duration(seconds: 5), (_) => emit());
  ref.onDispose(() {
    timer.cancel();
    if (!controller.isClosed) controller.close();
  });

  return controller.stream;
});
