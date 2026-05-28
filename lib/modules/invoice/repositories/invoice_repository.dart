import 'package:SmartERP/core/exceptions/app_exception.dart';
import 'package:SmartERP/core/models/invoice_item_model.dart';
import 'package:SmartERP/core/models/invoice_model.dart';
import 'package:SmartERP/core/storage/storage_service.dart';
import 'package:SmartERP/core/utils/logger.dart';

class InvoiceRepository {
  final StorageService<Map<dynamic, dynamic>> _invoiceStorage;
  final StorageService<Map<dynamic, dynamic>> _itemStorage;

  InvoiceRepository({required StorageService<Map<dynamic, dynamic>> invoiceStorage, required StorageService<Map<dynamic, dynamic>> itemStorage})
      : _invoiceStorage = invoiceStorage,
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

  Future<void> deleteItem(String id) async {
    try {
      await _itemStorage.delete(id);
    } catch (e, stackTrace) {
      Logger.error('Failed to delete invoice item', e, stackTrace);
      throw StorageException('Failed to delete invoice item');
    }
  }

  Future<List<InvoiceModel>> search(String query) async {
    try {
      final invoices = await getAll();
      final lowerQuery = query.toLowerCase();

      return invoices.where((invoice) {
        return invoice.invoiceNumber.toLowerCase().contains(lowerQuery) ||
            invoice.customerName.toLowerCase().contains(lowerQuery) ||
            (invoice.customerEmail?.toLowerCase().contains(lowerQuery) ?? false);
      }).toList();
    } catch (e, stackTrace) {
      Logger.error('Failed to search invoices', e, stackTrace);
      return [];
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

  Future<List<InvoiceModel>> getByCustomerId(String customerId) async {
    try {
      final invoices = await getAll();
      return invoices.where((i) => i.customerId == customerId).toList();
    } catch (e, stackTrace) {
      Logger.error('Failed to get invoices by customer id', e, stackTrace);
      return [];
    }
  }

  Future<List<InvoiceModel>> getByStatus(InvoiceStatus status) async {
    try {
      final invoices = await getAll();
      return invoices.where((i) => i.status == status).toList();
    } catch (e, stackTrace) {
      Logger.error('Failed to get invoices by status', e, stackTrace);
      return [];
    }
  }

  Future<List<InvoiceModel>> getOverdue() async {
    try {
      final invoices = await getAll();
      return invoices.where((i) => i.isOverdue).toList();
    } catch (e, stackTrace) {
      Logger.error('Failed to get overdue invoices', e, stackTrace);
      return [];
    }
  }

  Future<List<InvoiceModel>> getByDateRange(DateTime start, DateTime end) async {
    try {
      final invoices = await getAll();
      return invoices
          .where((i) => i.invoiceDate.isAfter(start.subtract(const Duration(days: 1))) && i.invoiceDate.isBefore(end.add(const Duration(days: 1))))
          .toList();
    } catch (e, stackTrace) {
      Logger.error('Failed to get invoices by date range', e, stackTrace);
      return [];
    }
  }
}
