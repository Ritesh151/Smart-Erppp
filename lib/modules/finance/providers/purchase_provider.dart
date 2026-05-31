import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:siddhivinayak_enterprise/core/constants/storage_keys.dart';
import 'package:siddhivinayak_enterprise/core/storage/storage_service.dart';

class SupplierInfo {
  final String name;
  final String? phone;
  final String? address;

  SupplierInfo({
    required this.name,
    this.phone,
    this.address,
  });

  factory SupplierInfo.fromMap(Map<String, dynamic> map) {
    return SupplierInfo(
      name: map['name'] as String? ?? '',
      phone: map['phone'] as String?,
      address: map['address'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'address': address,
    };
  }
}

class PurchaseRecord {
  final String id;
  final String purchaseNumber;
  final SupplierInfo supplier;
  final double totalAmount;
  final DateTime purchaseDate;
  final List<Map<String, dynamic>> items;
  final DateTime createdAt;

  PurchaseRecord({
    required this.id,
    required this.purchaseNumber,
    required this.supplier,
    required this.totalAmount,
    required this.purchaseDate,
    required this.items,
    required this.createdAt,
  });

  factory PurchaseRecord.fromMap(Map<String, dynamic> map) {
    return PurchaseRecord(
      id: map['id'] as String? ?? '',
      purchaseNumber: map['purchaseNumber'] as String? ?? '',
      supplier: map['supplier'] != null
          ? SupplierInfo.fromMap(Map<String, dynamic>.from(map['supplier'] as Map))
          : SupplierInfo(name: 'Unknown'),
      totalAmount: (map['totalAmount'] as num?)?.toDouble() ?? 0,
      purchaseDate: map['purchaseDate'] != null
          ? DateTime.parse(map['purchaseDate'] as String)
          : DateTime.now(),
      items: map['items'] != null
          ? (map['items'] as List)
              .map((e) => Map<String, dynamic>.from(e as Map<dynamic, dynamic>))
              .toList()
          : [],
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'purchaseNumber': purchaseNumber,
      'supplier': supplier.toMap(),
      'totalAmount': totalAmount,
      'purchaseDate': purchaseDate.toIso8601String(),
      'items': items,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

final _purchaseStorageProvider = Provider<StorageService<Map<dynamic, dynamic>>>((ref) {
  return StorageService<Map<dynamic, dynamic>>(StorageKeys.purchaseBox);
});

final purchasesStreamProvider = StreamProvider<List<PurchaseRecord>>((ref) {
  final storage = ref.read(_purchaseStorageProvider);
  final controller = StreamController<List<PurchaseRecord>>();

  void emit() {
    if (controller.isClosed) return;
    try {
      final data = storage.getAll()
          .map((e) => PurchaseRecord.fromMap(Map<String, dynamic>.from(e)))
          .toList()
        ..sort((a, b) => b.purchaseDate.compareTo(a.purchaseDate));
      controller.add(data);
    } catch (e) {
      controller.add([]);
    }
  }

  emit();

  try {
    if (Hive.isBoxOpen(StorageKeys.purchaseBox)) {
      final box = Hive.box(StorageKeys.purchaseBox);
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
