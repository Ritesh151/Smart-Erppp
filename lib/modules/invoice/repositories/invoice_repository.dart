import 'package:smarterp/core/exceptions/app_exception.dart';
import 'package:smarterp/core/models/invoice_model.dart';
import 'package:smarterp/core/models/invoice_item_model.dart';
import 'package:smarterp/core/storage/storage_service.dart';
import 'package:smarterp/core/utils/logger.dart';

class InvoiceRepository {
  final StorageService<Map<dynamic, dynamic>> _invoiceStorage;
  final StorageService<Map<dynamic, dynamic>> _itemStorage;

  InvoiceRepository({
    required StorageService<Map<dynamic, dynamic>> invoiceStorage,
    required StorageService<Map<dynamic, dynamic>> itemStorage,
  })  : _invoiceStorage = invoiceStorage,
        _itemStorage = itemStorage;

  Future<List<InvoiceModel>> getAll() async {
    try {
      final data = _invoiceStorage.getAll();
      return data
          .map((item) => InvoiceModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } catch (e, stackTrace) {
      Logger.error('Failed to get all invoices', e, stackTrace);
      throw StorageException('Failed to retrieve invoices');
    }
  }

  Future<InvoiceModel?> getById(String id) async {
    try {
      final data = _invoiceStorage.get(id);
      if (data == null) return null;
      return InvoiceModel.fromJson(Map<String, dynamic>.from(data));
    } catch (e, stackTrace) {
      Logger.error('Failed to get invoice by id: $id', e, stackTrace);
      return null;
    }
  }

  Future<void> save(InvoiceModel invoice) async {
    try {
      await _invoiceStorage.save(invoice.id, invoice.toJson());
      Logger.success('Invoice saved: ${invoice.id}');
    } catch (e, stackTrace) {
      Logger.error('Failed to save invoice', e, stackTrace);
      throw StorageException('Failed to save invoice');
    }
  }

  Future<void> update(InvoiceModel invoice) async {
    try {
      await _invoiceStorage.update(invoice.id, invoice.toJson());
      Logger.success('Invoice updated: ${invoice.id}');
    } catch (e, stackTrace) {
      Logger.error('Failed to update invoice', e, stackTrace);
      throw StorageException('Failed to update invoice');
    }
  }

  Future<void> delete(String id) async {
    try {
      final invoice = await getById(id);
      if (invoice != null) {
        for (final itemId in invoice.itemIds) {
          await _deleteItem(itemId);
        }
      }
      await _invoiceStorage.delete(id);
      Logger.success('Invoice deleted: $id');
    } catch (e, stackTrace) {
      Logger.error('Failed to delete invoice', e, stackTrace);
      throw StorageException('Failed to delete invoice');
    }
  }

  Future<void> saveItem(InvoiceItemModel item) async {
    try {
      await _itemStorage.save(item.id, item.toJson());
    } catch (e, stackTrace) {
      Logger.error('Failed to save invoice item', e, stackTrace);
      throw StorageException('Failed to save invoice item');
    }
  }

  Future<InvoiceItemModel?> getItemById(String id) async {
    try {
      final data = _itemStorage.get(id);
      if (data == null) return null;
      return InvoiceItemModel.fromJson(Map<String, dynamic>.from(data));
    } catch (e, stackTrace) {
      Logger.error('Failed to get invoice item by id: $id', e, stackTrace);
      return null;
    }
  }

  Future<List<InvoiceItemModel>> getItemsByIds(List<String> ids) async {
    try {
      final items = <InvoiceItemModel>[];
      for (final id in ids) {
        final item = await getItemById(id);
        if (item != null) items.add(item);
      }
      return items;
    } catch (e, stackTrace) {
      Logger.error('Failed to get invoice items by ids', e, stackTrace);
      return [];
    }
  }

  Future<void> _deleteItem(String id) async {
    try {
      await _itemStorage.delete(id);
    } catch (e, stackTrace) {
      Logger.warning('Failed to delete invoice item: $id', e);
    }
  }

  Future<String> getNextInvoiceNumber() async {
    try {
      final invoices = await getAll();
      final numbers = invoices
          .map((inv) => int.tryParse(
              inv.invoiceNumber.replaceAll(RegExp(r'[^0-9]'), '')))
          .whereType<int>()
          .toList();
      final max = numbers.isEmpty ? 0 : numbers.reduce((a, b) => a > b ? a : b);
      return 'INV-${(max + 1).toString().padLeft(4, '0')}';
    } catch (e, stackTrace) {
      Logger.error('Failed to generate next invoice number', e, stackTrace);
      return 'INV-0001';
    }
  }

  Future<bool> exists(String id) async {
    try {
      return _invoiceStorage.containsKey(id);
    } catch (e, stackTrace) {
      Logger.error('Failed to check invoice existence', e, stackTrace);
      return false;
    }
  }

  Future<int> getTotalCount() async {
    try {
      return _invoiceStorage.length;
    } catch (e, stackTrace) {
      Logger.error('Failed to get total invoice count', e, stackTrace);
      return 0;
    }
  }

  Future<List<InvoiceModel>> getByStatus(InvoiceStatus status) async {
    try {
      final invoices = await getAll();
      return invoices.where((inv) => inv.status == status).toList();
    } catch (e, stackTrace) {
      Logger.error('Failed to get invoices by status', e, stackTrace);
      return [];
    }
  }

  Future<List<InvoiceModel>> getByCustomerId(String customerId) async {
    try {
      final invoices = await getAll();
      return invoices.where((inv) => inv.customerId == customerId).toList();
    } catch (e, stackTrace) {
      Logger.error('Failed to get invoices by customer', e, stackTrace);
      return [];
    }
  }

  Future<List<InvoiceModel>> getOverdueInvoices() async {
    try {
      final invoices = await getAll();
      return invoices.where((inv) => inv.isOverdue).toList();
    } catch (e, stackTrace) {
      Logger.error('Failed to get overdue invoices', e, stackTrace);
      return [];
    }
  }
}
