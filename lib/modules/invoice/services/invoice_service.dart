import 'package:siddhivinayak_enterprise/core/exceptions/app_exception.dart';
import 'package:siddhivinayak_enterprise/core/models/invoice_item_model.dart';
import 'package:siddhivinayak_enterprise/core/models/invoice_model.dart';
import 'package:siddhivinayak_enterprise/core/utils/logger.dart';
import 'package:siddhivinayak_enterprise/modules/invoice/repositories/invoice_repository.dart';
import 'package:siddhivinayak_enterprise/modules/products/repositories/product_repository.dart';
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
    String? bankName,
    String? branchName,
    String? ifscCode,
    String? accountNumber,
    int paymentDays = 0,
    int paymentMonths = 0,
    String? paymentTermDescription,
    String? customPaymentNotes,
    String? internalChargesJson,
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

      await _applyStockDelta(_stockDelta(const [], items), items);

      for (final item in items) {
        final itemId = const Uuid().v4();
        itemIds.add(itemId);
        final savedItem = item.copyWith(id: itemId);
        await _invoiceRepository.saveItem(savedItem);
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
        bankName: bankName?.trim(),
        branchName: branchName?.trim(),
        ifscCode: ifscCode?.trim(),
        accountNumber: accountNumber?.trim(),
        paymentDays: paymentDays,
        paymentMonths: paymentMonths,
        paymentTermDescription: paymentTermDescription?.trim(),
        customPaymentNotes: customPaymentNotes?.trim(),
        internalChargesJson: internalChargesJson,
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
    String? bankName,
    String? branchName,
    String? ifscCode,
    String? accountNumber,
    int paymentDays = 0,
    int paymentMonths = 0,
    String? paymentTermDescription,
    String? customPaymentNotes,
    String? internalChargesJson,
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

      final oldItems = await _getItemsForInvoice(existingInvoice);
      await _applyStockDelta(_stockDelta(oldItems, items), [
        ...oldItems,
        ...items,
      ]);

      for (final oldItemId in existingInvoice.itemIds) {
        await _invoiceRepository.deleteItem(oldItemId);
      }

      final itemIds = <String>[];
      for (final item in items) {
        final itemId = const Uuid().v4();
        itemIds.add(itemId);
        final savedItem = item.copyWith(id: itemId);
        await _invoiceRepository.saveItem(savedItem);
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
        bankName: bankName?.trim(),
        branchName: branchName?.trim(),
        ifscCode: ifscCode?.trim(),
        accountNumber: accountNumber?.trim(),
        paymentDays: paymentDays,
        paymentMonths: paymentMonths,
        paymentTermDescription: paymentTermDescription?.trim(),
        customPaymentNotes: customPaymentNotes?.trim(),
        internalChargesJson: internalChargesJson,
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

      final oldItems = await _getItemsForInvoice(invoice);
      await _applyStockDelta(_stockDelta(oldItems, const []), oldItems);

      for (final itemId in invoice.itemIds) {
        await _invoiceRepository.deleteItem(itemId);
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

  Future<List<InvoiceItemModel>> _getItemsForInvoice(InvoiceModel invoice) async {
    final items = <InvoiceItemModel>[];
    for (final itemId in invoice.itemIds) {
      final item = await _invoiceRepository.getItemById(itemId);
      if (item != null) items.add(item);
    }
    return items;
  }

  Map<String, int> _stockDelta(
    List<InvoiceItemModel> oldItems,
    List<InvoiceItemModel> newItems,
  ) {
    final delta = <String, int>{};
    for (final item in oldItems) {
      if (item.productId.isEmpty) continue;
      delta[item.productId] =
          (delta[item.productId] ?? 0) - item.quantity.toInt();
    }
    for (final item in newItems) {
      if (item.productId.isEmpty) continue;
      delta[item.productId] =
          (delta[item.productId] ?? 0) + item.quantity.toInt();
    }
    delta.removeWhere((_, quantity) => quantity == 0);
    return delta;
  }

  Future<void> _applyStockDelta(
    Map<String, int> deltaByProduct,
    List<InvoiceItemModel> contextItems,
  ) async {
    final productNames = {
      for (final item in contextItems) item.productId: item.productName,
    };

    for (final entry in deltaByProduct.entries) {
      if (entry.value <= 0) continue;
      final product = await _productRepository.getById(entry.key);
      if (product == null) continue;
      if (product.stockQuantity - entry.value < 0) {
        throw ValidationException(
          'Insufficient stock for ${productNames[entry.key] ?? product.productName}',
        );
      }
    }

    for (final entry in deltaByProduct.entries) {
      final product = await _productRepository.getById(entry.key);
      if (product == null) continue;
      final updatedProduct = product.copyWith(
        stockQuantity: product.stockQuantity - entry.value,
        updatedAt: DateTime.now(),
      );
      await _productRepository.update(updatedProduct);
    }
  }

  Future<void> cancelInvoice(String id) async {
    try {
      final invoice = await _invoiceRepository.getById(id);
      if (invoice == null) {
        throw NotFoundException('Invoice not found');
      }

      if (invoice.status != InvoiceStatus.cancelled) {
        final oldItems = await _getItemsForInvoice(invoice);
        await _applyStockDelta(_stockDelta(oldItems, const []), oldItems);
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

  // ???????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????
  // WhatsApp Integration Methods
  // ???????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????

  /// Send invoice via WhatsApp with automatic message generation
  /// This method generates a WhatsApp message and returns the formatted message
  Future<String> generateWhatsAppMessage({
    required InvoiceModel invoice,
    required List<InvoiceItemModel> items,
    bool useShortFormat = false,
  }) async {
    try {
      if (invoice.customerName.trim().isEmpty) {
        throw ValidationException('Customer name is required');
      }

      final sb = StringBuffer();

      sb.writeln('Hello ${invoice.customerName},');
      sb.writeln('');
      sb.writeln('Thank you for your purchase from Siddhivinayak Enterprise.');
      sb.writeln('');
      sb.writeln('Invoice Details:');
      sb.writeln('---------------------------');
      sb.writeln('Invoice No: ${invoice.invoiceNumber}');
      sb.writeln('');

      if (useShortFormat) {
        // Short format - show first 3 items only
        sb.writeln('Items:');
        for (final item in items.take(3)) {
          sb.writeln('* ${item.productName} x ${item.quantity.toInt()}');
        }
        if (items.length > 3) {
          sb.writeln('... and ${items.length - 3} more items');
        }
      } else {
        // Detailed format - show all items with prices
        for (final item in items) {
          final lineTotal = item.unitPrice * item.quantity;
          sb.writeln('* ${item.productName} x ${item.quantity.toInt()} = Rs.${lineTotal.toStringAsFixed(0)}');
        }
      }

      sb.writeln('');
      sb.writeln('---------------------------');
      sb.writeln('Subtotal: Rs.${invoice.subtotal.toStringAsFixed(0)}');
      sb.writeln('Tax: Rs.${invoice.taxAmount.toStringAsFixed(0)}');
      sb.writeln('');
      sb.writeln('Total Amount: Rs.${invoice.totalAmount.toStringAsFixed(0)}');
      sb.writeln('');
      sb.writeln('We appreciate your business.');
      sb.writeln('');
      sb.writeln('Thank You,');
      sb.writeln('Siddhivinayak Enterprise');

      if (invoice.customerPhone != null && invoice.customerPhone!.isNotEmpty) {
        sb.writeln('');
        sb.writeln('Contact: ${invoice.customerPhone}');
      }

      return sb.toString();
    } catch (e, stackTrace) {
      Logger.error('Failed to generate WhatsApp message', e, stackTrace);
      rethrow;
    }
  }

  /// Get WhatsApp send history for an invoice
  Future<List<InvoiceModel>> getSentInvoicesViaWhatsApp() async {
    try {
      // This would be implemented using WhatsApp repository
      // For now, return empty list as placeholder
      return [];
    } catch (e, stackTrace) {
      Logger.error('Failed to get WhatsApp sent invoices', e, stackTrace);
      return [];
    }
  }

  /// Check if invoice was sent via WhatsApp
  Future<bool> wasInvoiceSentViaWhatsApp(String invoiceId) async {
    try {
      // This would be implemented using WhatsApp repository
      return false;
    } catch (e, stackTrace) {
      Logger.error('Failed to check WhatsApp sent status', e, stackTrace);
      return false;
    }
  }

  /// Format phone number for WhatsApp
  String formatPhoneNumberForWhatsApp(String phoneNumber) {
    // Remove all non-digit characters
    var cleaned = phoneNumber.replaceAll(RegExp(r'\D'), '');
    
    // Add country code if missing (default to +91 for India)
    if (!cleaned.startsWith('91')) {
      if (cleaned.length == 10) {
        cleaned = '91$cleaned';
      }
    }
    
    // Ensure + prefix
    if (!cleaned.startsWith('+')) {
      cleaned = '+$cleaned';
    }
    
    return cleaned;
  }

  /// Validate phone number for WhatsApp
  bool isValidPhoneNumberForWhatsApp(String phoneNumber) {
    // Remove all non-digit characters
    final cleaned = phoneNumber.replaceAll(RegExp(r'\D'), '');
    
    // Check minimum length (10 digits for most countries)
    if (cleaned.length < 10) return false;
    
    // Check maximum length (15 digits - E.164 standard)
    if (cleaned.length > 15) return false;
    
    return true;
  }
}
