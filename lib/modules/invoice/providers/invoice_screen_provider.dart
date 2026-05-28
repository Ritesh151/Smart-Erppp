import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:SmartERP/core/models/invoice_model.dart';
import 'package:SmartERP/core/constants/storage_keys.dart';

InvoiceModel? _parseInvoice(Map<String, dynamic> map) {
  try {
    return InvoiceModel.fromJson(map);
  } catch (_) {
    return null;
  }
}

final invoicesStreamProvider = StreamProvider<List<InvoiceModel>>((ref) {
  final controller = StreamController<List<InvoiceModel>>();

  void emit() {
    if (controller.isClosed) return;
    try {
      final box = Hive.box(StorageKeys.invoicesBox);
      final invoices = box.values
          .map((e) => _parseInvoice(Map<String, dynamic>.from(e as Map)))
          .whereType<InvoiceModel>()
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      controller.add(invoices);
    } catch (_) {
      controller.add([]);
    }
  }

  emit();

  try {
    if (Hive.isBoxOpen(StorageKeys.invoicesBox)) {
      final box = Hive.box(StorageKeys.invoicesBox);
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
