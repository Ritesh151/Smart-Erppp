import 'package:SmartERP/core/exceptions/app_exception.dart';
import 'package:SmartERP/core/models/invoice_item_model.dart';
import 'package:SmartERP/core/models/invoice_model.dart';
import 'package:SmartERP/core/utils/logger.dart';
import 'package:SmartERP/modules/invoice/repositories/invoice_repository.dart';
import 'package:SmartERP/modules/products/repositories/product_repository.dart';
import 'package:uuid/uuid.dart';

class InvoiceService {
  final InvoiceRepository _invoiceRepository;
  final ProductRepository _productRepository;

  InvoiceService({required InvoiceRepository invoiceRepository, required ProductRepository productRepository})
      : _invoiceRepository = invoiceRepository,
        _productRepository = productRepository;

  Future<List<InvoiceModel>> getAllInvoices() async {
    try {
      return await _invoiceRepository.getAll();
    } catch (e, stackTrace) {
      Logger.error('Failed to get all invoices', e, stackTrace);
      rethrow;
    }
  }

  Future<InvoiceModel?> getInvoiceById(String id) async {
    try {
      return await _invoiceRepository.getById(id);
    } catch (e, stackTrace) {
      Logger.error('Failed to get invoice by id', e, stackTrace);
      return null;
    }
  }

  Future<InvoiceModel> createInvoice({
    required String customerId,
    required String customerName,
    String? customerEmail,
    String? customerPhone,
    String? customerAddress,
    String? customerGst,
    required DateTime invoiceDate,
    required DateTime dueDate,
    required List<InvoiceItemModel> items,
    double subtotal = 0,
    double taxAmount = 0,
    double discountAmount = 0,
    double totalAmount = 0,
    String? notes,
    String? termsAndConditions,
  }) async {
    try {
      if (customerName.trim().isEmpty) {
        throw ValidationException('Customer name is required');
      }
      if (items.isEmpty) {
        throw ValidationException('Invoice must have at least one item');
      }

      final invoiceNumber = await getNextInvoiceNumber();
      final id = const Uuid().v4();
      final itemIds = <String>[];

      for (final item in items) {
        final itemId = const Uuid().v4();
        itemIds.add(itemId);
        final savedItem = item.copyWith(id: itemId);
        await _invoiceRepository.saveItem(savedItem);
      }

      for (final item in items) {
        final product = await _productRepository.getById(item.productId);
        if (product != null) {
          final newQuantity = product.stockQuantity - item.quantity.toInt();
          if (newQuantity < 0) {
            throw ValidationException(
                'Insufficient stock for ${item.productName}');
          }
          final updatedProduct = product.copyWith(
            stockQuantity: newQuantity,
            updatedAt: DateTime.now(),
          );
          await _productRepository.update(updatedProduct);
        }
      }

      final invoice = InvoiceModel(
        id: id,
        invoiceNumber: invoiceNumber,
        customerId: customerId,
        customerName: customerName.trim(),
        customerEmail: customerEmail?.trim(),
        customerPhone: customerPhone?.trim(),
        customerAddress: customerAddress?.trim(),
        customerGst: customerGst?.trim(),
        invoiceDate: invoiceDate,
        dueDate: dueDate,
        itemIds: itemIds,
        subtotal: subtotal,
        taxAmount: taxAmount,
        discountAmount: discountAmount,
        totalAmount: totalAmount,
        paidAmount: 0,
        status: InvoiceStatus.draft,
        notes: notes?.trim(),
        termsAndConditions: termsAndConditions?.trim(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _invoiceRepository.save(invoice);
      Logger.success('Invoice created: $invoiceNumber');
      return invoice;
    } catch (e, stackTrace) {
      Logger.error('Failed to create invoice', e, stackTrace);
      rethrow;
    }
  }

  Future<InvoiceModel> updateInvoice({
    required String id,
    required String customerId,
    required String customerName,
    String? customerEmail,
    String? customerPhone,
    String? customerAddress,
    String? customerGst,
    required DateTime invoiceDate,
    required DateTime dueDate,
    required List<InvoiceItemModel> items,
    double subtotal = 0,
    double taxAmount = 0,
    double discountAmount = 0,
    double totalAmount = 0,
    String? notes,
    String? termsAndConditions,
  }) async {
    try {
      final existingInvoice = await _invoiceRepository.getById(id);
      if (existingInvoice == null) {
        throw NotFoundException('Invoice not found');
      }
      if (customerName.trim().isEmpty) {
        throw ValidationException('Customer name is required');
      }
      if (items.isEmpty) {
        throw ValidationException('Invoice must have at least one item');
      }

      for (final oldItemId in existingInvoice.itemIds) {
        final oldItem = await _invoiceRepository.getItemById(oldItemId);
        if (oldItem != null) {
          final product =
              await _productRepository.getById(oldItem.productId);
          if (product != null) {
            final restoredQuantity =
                product.stockQuantity + oldItem.quantity.toInt();
            final updatedProduct = product.copyWith(
              stockQuantity: restoredQuantity,
              updatedAt: DateTime.now(),
            );
            await _productRepository.update(updatedProduct);
          }
          await _invoiceRepository.deleteItem(oldItemId);
        }
      }

      final itemIds = <String>[];
      for (final item in items) {
        final itemId = const Uuid().v4();
        itemIds.add(itemId);
        final savedItem = item.copyWith(id: itemId);
        await _invoiceRepository.saveItem(savedItem);
      }

      for (final item in items) {
        final product = await _productRepository.getById(item.productId);
        if (product != null) {
          final newQuantity = product.stockQuantity - item.quantity.toInt();
          if (newQuantity < 0) {
            throw ValidationException(
                'Insufficient stock for ${item.productName}');
          }
          final updatedProduct = product.copyWith(
            stockQuantity: newQuantity,
            updatedAt: DateTime.now(),
          );
          await _productRepository.update(updatedProduct);
        }
      }

      final updatedInvoice = existingInvoice.copyWith(
        customerId: customerId,
        customerName: customerName.trim(),
        customerEmail: customerEmail?.trim(),
        customerPhone: customerPhone?.trim(),
        customerAddress: customerAddress?.trim(),
        customerGst: customerGst?.trim(),
        invoiceDate: invoiceDate,
        dueDate: dueDate,
        itemIds: itemIds,
        subtotal: subtotal,
        taxAmount: taxAmount,
        discountAmount: discountAmount,
        totalAmount: totalAmount,
        notes: notes?.trim(),
        termsAndConditions: termsAndConditions?.trim(),
        updatedAt: DateTime.now(),
      );

      await _invoiceRepository.update(updatedInvoice);
      Logger.success('Invoice updated: ${updatedInvoice.invoiceNumber}');
      return updatedInvoice;
    } catch (e, stackTrace) {
      Logger.error('Failed to update invoice', e, stackTrace);
      rethrow;
    }
  }

  Future<void> deleteInvoice(String id) async {
    try {
      final invoice = await _invoiceRepository.getById(id);
      if (invoice == null) {
        throw NotFoundException('Invoice not found');
      }

      for (final itemId in invoice.itemIds) {
        final item = await _invoiceRepository.getItemById(itemId);
        if (item != null) {
          final product = await _productRepository.getById(item.productId);
          if (product != null) {
            final restoredQuantity =
                product.stockQuantity + item.quantity.toInt();
            final updatedProduct = product.copyWith(
              stockQuantity: restoredQuantity,
              updatedAt: DateTime.now(),
            );
            await _productRepository.update(updatedProduct);
          }
          await _invoiceRepository.deleteItem(itemId);
        }
      }

      await _invoiceRepository.delete(id);
      Logger.success('Invoice deleted: ${invoice.invoiceNumber}');
    } catch (e, stackTrace) {
      Logger.error('Failed to delete invoice', e, stackTrace);
      rethrow;
    }
  }

  Future<void> markAsSent(String id) async {
    try {
      final invoice = await _invoiceRepository.getById(id);
      if (invoice == null) {
        throw NotFoundException('Invoice not found');
      }

      final updatedInvoice = invoice.copyWith(
        status: InvoiceStatus.sent,
        updatedAt: DateTime.now(),
      );

      await _invoiceRepository.update(updatedInvoice);
      Logger.success('Invoice marked as sent: ${invoice.invoiceNumber}');
    } catch (e, stackTrace) {
      Logger.error('Failed to mark invoice as sent', e, stackTrace);
      rethrow;
    }
  }

  Future<void> markAsPaid(String id, double amount) async {
    try {
      if (amount < 0) {
        throw ValidationException('Payment amount cannot be negative');
      }

      final invoice = await _invoiceRepository.getById(id);
      if (invoice == null) {
        throw NotFoundException('Invoice not found');
      }

      final newPaidAmount = invoice.paidAmount + amount;
      final newStatus = newPaidAmount >= invoice.totalAmount
          ? InvoiceStatus.paid
          : InvoiceStatus.partiallyPaid;

      final updatedInvoice = invoice.copyWith(
        paidAmount: newPaidAmount,
        status: newStatus,
        updatedAt: DateTime.now(),
      );

      await _invoiceRepository.update(updatedInvoice);
      Logger.success('Payment recorded for invoice: ${invoice.invoiceNumber}');
    } catch (e, stackTrace) {
      Logger.error('Failed to mark invoice as paid', e, stackTrace);
      rethrow;
    }
  }

  Future<InvoiceItemModel?> getInvoiceItemById(String id) async {
    try {
      return await _invoiceRepository.getItemById(id);
    } catch (e, stackTrace) {
      Logger.error('Failed to get invoice item by id', e, stackTrace);
      return null;
    }
  }

  Future<List<InvoiceItemModel>> getInvoiceItems(String invoiceId) async {
    try {
      final invoice = await _invoiceRepository.getById(invoiceId);
      if (invoice == null) return [];
      final items = <InvoiceItemModel>[];
      for (final itemId in invoice.itemIds) {
        final item = await _invoiceRepository.getItemById(itemId);
        if (item != null) items.add(item);
      }
      return items;
    } catch (e, stackTrace) {
      Logger.error('Failed to get invoice items for invoice: $invoiceId', e, stackTrace);
      return [];
    }
  }

  Future<void> cancelInvoice(String id) async {
    try {
      final invoice = await _invoiceRepository.getById(id);
      if (invoice == null) {
        throw NotFoundException('Invoice not found');
      }

      for (final itemId in invoice.itemIds) {
        final item = await _invoiceRepository.getItemById(itemId);
        if (item != null) {
          final product = await _productRepository.getById(item.productId);
          if (product != null) {
            final restoredQuantity =
                product.stockQuantity + item.quantity.toInt();
            final updatedProduct = product.copyWith(
              stockQuantity: restoredQuantity,
              updatedAt: DateTime.now(),
            );
            await _productRepository.update(updatedProduct);
          }
        }
      }

      final updatedInvoice = invoice.copyWith(
        status: InvoiceStatus.cancelled,
        updatedAt: DateTime.now(),
      );

      await _invoiceRepository.update(updatedInvoice);
      Logger.success('Invoice cancelled: ${invoice.invoiceNumber}');
    } catch (e, stackTrace) {
      Logger.error('Failed to cancel invoice', e, stackTrace);
      rethrow;
    }
  }

  Future<String> getNextInvoiceNumber() async {
    try {
      final count = await _invoiceRepository.getTotalCount();
      final year = DateTime.now().year;
      return 'INV-$year-${(count + 1).toString().padLeft(4, '0')}';
    } catch (e, stackTrace) {
      Logger.error('Failed to generate next invoice number', e, stackTrace);
      rethrow;
    }
  }

  Future<List<InvoiceModel>> getInvoicesByCustomer(String customerId) async {
    try {
      return await _invoiceRepository.getByCustomerId(customerId);
    } catch (e, stackTrace) {
      Logger.error('Failed to get invoices by customer', e, stackTrace);
      return [];
    }
  }

  Future<List<InvoiceModel>> getInvoicesByStatus(InvoiceStatus status) async {
    try {
      return await _invoiceRepository.getByStatus(status);
    } catch (e, stackTrace) {
      Logger.error('Failed to get invoices by status', e, stackTrace);
      return [];
    }
  }

  Future<List<InvoiceModel>> getOverdueInvoices() async {
    try {
      return await _invoiceRepository.getOverdue();
    } catch (e, stackTrace) {
      Logger.error('Failed to get overdue invoices', e, stackTrace);
      return [];
    }
  }

  Future<List<InvoiceModel>> getInvoicesByDateRange(
      DateTime start, DateTime end) async {
    try {
      return await _invoiceRepository.getByDateRange(start, end);
    } catch (e, stackTrace) {
      Logger.error('Failed to get invoices by date range', e, stackTrace);
      return [];
    }
  }

  Future<List<InvoiceModel>> searchInvoices(String query) async {
    try {
      if (query.trim().isEmpty) {
        return await getAllInvoices();
      }
      return await _invoiceRepository.search(query);
    } catch (e, stackTrace) {
      Logger.error('Failed to search invoices', e, stackTrace);
      return [];
    }
  }
}
