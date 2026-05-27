import 'package:smarterp/core/exceptions/app_exception.dart';
import 'package:smarterp/core/models/invoice_model.dart';
import 'package:smarterp/core/models/invoice_item_model.dart';
import 'package:smarterp/core/utils/logger.dart';
import 'package:smarterp/modules/invoice/repositories/invoice_repository.dart';
import 'package:smarterp/modules/products/repositories/product_repository.dart';
import 'package:uuid/uuid.dart';

class InvoiceService {
  final InvoiceRepository _invoiceRepository;
  final ProductRepository _productRepository;

  InvoiceService({
    required InvoiceRepository invoiceRepository,
    required ProductRepository productRepository,
  })  : _invoiceRepository = invoiceRepository,
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

  Future<List<InvoiceItemModel>> getInvoiceItems(InvoiceModel invoice) async {
    try {
      return await _invoiceRepository.getItemsByIds(invoice.itemIds);
    } catch (e, stackTrace) {
      Logger.error('Failed to get items for invoice: ${invoice.id}', e, stackTrace);
      return [];
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
    double discountAmount = 0,
    String? notes,
    String? termsAndConditions,
  }) async {
    try {
      if (items.isEmpty) {
        throw ValidationException('Invoice must have at least one item');
      }

      _validateInvoiceItems(items);

      final itemIds = <String>[];
      for (final item in items) {
        await _invoiceRepository.saveItem(item);
        itemIds.add(item.id);
        await _updateProductStock(item);
      }

      final subtotal = items.fold(0.0, (sum, item) => sum + item.subtotal);
      final taxAmount = items.fold(0.0, (sum, item) => sum + item.taxAmount);
      final totalAmount = subtotal + taxAmount - discountAmount;

      final invoiceNumber = await _invoiceRepository.getNextInvoiceNumber();

      final invoice = InvoiceModel(
        id: const Uuid().v4(),
        invoiceNumber: invoiceNumber,
        customerId: customerId,
        customerName: customerName,
        customerEmail: customerEmail,
        customerPhone: customerPhone,
        customerAddress: customerAddress,
        customerGst: customerGst,
        invoiceDate: invoiceDate,
        dueDate: dueDate,
        itemIds: itemIds,
        subtotal: subtotal,
        taxAmount: taxAmount,
        discountAmount: discountAmount,
        totalAmount: totalAmount,
        paidAmount: 0,
        status: InvoiceStatus.draft,
        notes: notes,
        termsAndConditions: termsAndConditions,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _invoiceRepository.save(invoice);
      Logger.success('Invoice created: ${invoice.invoiceNumber}');
      return invoice;
    } catch (e, stackTrace) {
      Logger.error('Failed to create invoice', e, stackTrace);
      rethrow;
    }
  }

  Future<InvoiceModel> updateInvoiceStatus(String id, InvoiceStatus status) async {
    try {
      final invoice = await _invoiceRepository.getById(id);
      if (invoice == null) {
        throw NotFoundException('Invoice not found');
      }

      final updated = invoice.copyWith(
        status: status,
        updatedAt: DateTime.now(),
      );

      await _invoiceRepository.update(updated);
      Logger.success('Invoice status updated: ${invoice.invoiceNumber} -> $status');
      return updated;
    } catch (e, stackTrace) {
      Logger.error('Failed to update invoice status', e, stackTrace);
      rethrow;
    }
  }

  Future<void> deleteInvoice(String id) async {
    try {
      final invoice = await _invoiceRepository.getById(id);
      if (invoice == null) {
        throw NotFoundException('Invoice not found');
      }

      final items = await _invoiceRepository.getItemsByIds(invoice.itemIds);
      for (final item in items) {
        await _restoreProductStock(item);
      }

      await _invoiceRepository.delete(id);
      Logger.success('Invoice deleted: ${invoice.invoiceNumber}');
    } catch (e, stackTrace) {
      Logger.error('Failed to delete invoice', e, stackTrace);
      rethrow;
    }
  }

  Future<void> markAsSent(String id) async {
    await updateInvoiceStatus(id, InvoiceStatus.sent);
  }

  Future<void> markAsPaid(String id, double paidAmount) async {
    try {
      final invoice = await _invoiceRepository.getById(id);
      if (invoice == null) {
        throw NotFoundException('Invoice not found');
      }

      final totalPaid = invoice.paidAmount + paidAmount;
      final newStatus = totalPaid >= invoice.totalAmount
          ? InvoiceStatus.paid
          : InvoiceStatus.partiallyPaid;

      final updated = invoice.copyWith(
        paidAmount: totalPaid,
        status: newStatus,
        updatedAt: DateTime.now(),
      );

      await _invoiceRepository.update(updated);
      Logger.success('Invoice payment recorded: ${invoice.invoiceNumber}');
    } catch (e, stackTrace) {
      Logger.error('Failed to mark invoice as paid', e, stackTrace);
      rethrow;
    }
  }

  Future<void> _updateProductStock(InvoiceItemModel item) async {
    try {
      final product = await _productRepository.getById(item.productId);
      if (product != null) {
        final newStock = product.stockQuantity - item.quantity.toInt();
        if (newStock < 0) {
          throw ValidationException(
            'Insufficient stock for ${item.productName}. Available: ${product.stockQuantity}, Required: ${item.quantity.toInt()}',
          );
        }
        final updated = product.copyWith(
          stockQuantity: newStock,
          updatedAt: DateTime.now(),
        );
        await _productRepository.update(updated);
      }
    } catch (e) {
      if (e is ValidationException) rethrow;
      Logger.warning('Failed to update stock for product: ${item.productId}', e);
    }
  }

  Future<void> _restoreProductStock(InvoiceItemModel item) async {
    try {
      final product = await _productRepository.getById(item.productId);
      if (product != null) {
        final updated = product.copyWith(
          stockQuantity: product.stockQuantity + item.quantity.toInt(),
          updatedAt: DateTime.now(),
        );
        await _productRepository.update(updated);
      }
    } catch (e) {
      Logger.warning('Failed to restore stock for product: ${item.productId}', e);
    }
  }

  void _validateInvoiceItems(List<InvoiceItemModel> items) {
    for (final item in items) {
      if (item.quantity <= 0) {
        throw ValidationException('Quantity must be greater than 0 for ${item.productName}');
      }
      if (item.unitPrice < 0) {
        throw ValidationException('Unit price cannot be negative for ${item.productName}');
      }
    }
  }
}
