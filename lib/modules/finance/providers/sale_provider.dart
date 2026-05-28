import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:SmartERP/core/constants/storage_keys.dart';
import 'package:SmartERP/core/models/product_model.dart';
import 'package:SmartERP/core/storage/storage_service.dart';
import 'package:SmartERP/Models/sale_model.dart';
import 'package:SmartERP/Models/sale_item_model.dart';
import 'package:uuid/uuid.dart';

class SaleRecord {
  final String saleId;
  final String customerName;
  final String customerPhone;
  final String customerAddress;
  final double total;
  final List<SaleItemModel> items;
  final DateTime createdAt;
  final String? invoiceNumber;

  SaleRecord({
    required this.saleId,
    required this.customerName,
    this.customerPhone = '',
    this.customerAddress = '',
    required this.total,
    required this.items,
    required this.createdAt,
    this.invoiceNumber,
  });

  factory SaleRecord.fromMap(Map<String, dynamic> map) {
    final itemsList = (map['items'] as List<dynamic>?)
            ?.map((e) => SaleItemModel.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList() ??
        [];
    return SaleRecord(
      saleId: map['saleId'] as String? ?? map['id'] as String,
      customerName: map['customerName'] as String? ?? '',
      customerPhone: map['customerPhone'] as String? ?? '',
      customerAddress: map['customerAddress'] as String? ?? '',
      total: (map['total'] as num?)?.toDouble() ??
          itemsList.fold<double>(0, (sum, i) => sum + i.totalAmount),
      items: itemsList,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
      invoiceNumber: map['invoiceNumber'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'saleId': saleId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'customerAddress': customerAddress,
      'total': total,
      'items': items.map((e) => e.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'invoiceNumber': invoiceNumber,
    };
  }
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

class SaleService {
  final StorageService<Map<dynamic, dynamic>> _salesStorage;
  final StorageService<Map<dynamic, dynamic>> _productsStorage;

  SaleService()
      : _salesStorage =
            StorageService<Map<dynamic, dynamic>>(StorageKeys.salesBox),
        _productsStorage =
            StorageService<Map<dynamic, dynamic>>(StorageKeys.productsBox);

  Future<void> saveSaleWithStockUpdate({required SaleModel sale}) async {
    final id = const Uuid().v4();
    final saleMap = {
      'id': id,
      'saleId': id,
      'customerName': sale.customerName,
      'customerPhone': sale.customerPhone,
      'customerAddress': sale.customerAddress,
      'items': sale.items.map((e) => e.toJson()).toList(),
      'total': sale.total,
      'createdAt': DateTime.now().toIso8601String(),
    };

    final productsBox = _getProductsBox();
    for (final item in sale.items) {
      final existingRaw = productsBox.get(item.productId);
      if (existingRaw != null) {
        if (existingRaw is ProductModel) {
          final newQty = existingRaw.stockQuantity - item.quantity.toInt();
          final updated = existingRaw.copyWith(
            stockQuantity: newQty < 0 ? 0 : newQty,
            updatedAt: DateTime.now(),
          );
          await productsBox.put(item.productId, updated);
        } else if (existingRaw is Map) {
          final raw = Map<String, dynamic>.from(existingRaw as Map<dynamic, dynamic>);
          final currentStock = (raw['stockQuantity'] as num?)?.toInt() ?? 0;
          final newQty = currentStock - item.quantity.toInt();
          raw['stockQuantity'] = newQty < 0 ? 0 : newQty;
          raw['updatedAt'] = DateTime.now().toIso8601String();
          await productsBox.put(item.productId, raw);
        }
      }
    }

    await _salesStorage.save(id, saleMap);
  }

  Box<dynamic> _getProductsBox() {
    if (Hive.isBoxOpen(StorageKeys.productsBox)) {
      return Hive.box(StorageKeys.productsBox);
    }
    throw Exception('Products box not initialized');
  }
}

final _saleStorageProvider = Provider<StorageService<Map<dynamic, dynamic>>>((ref) {
  return StorageService<Map<dynamic, dynamic>>(StorageKeys.salesBox);
});

final salesStreamProvider = StreamProvider<List<SaleRecord>>((ref) {
  final storage = ref.read(_saleStorageProvider);
  final controller = StreamController<List<SaleRecord>>();

  void emit() {
    if (controller.isClosed) return;
    try {
      final data = storage.getAll()
          .map((e) => SaleRecord.fromMap(Map<String, dynamic>.from(e)))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      controller.add(data);
    } catch (e) {
      controller.add([]);
    }
  }

  emit();

  try {
    if (Hive.isBoxOpen(StorageKeys.salesBox)) {
      final box = Hive.box(StorageKeys.salesBox);
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

final productsStreamProvider = StreamProvider<List<ProductInfo>>((ref) {
  final storage = StorageService<Map<dynamic, dynamic>>(StorageKeys.productsBox);
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

final saleServiceProvider = Provider<SaleService>((ref) {
  return SaleService();
});
