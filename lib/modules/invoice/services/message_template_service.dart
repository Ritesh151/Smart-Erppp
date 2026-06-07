import 'package:siddhivinayak_enterprise/core/models/invoice_item_model.dart';
import 'package:siddhivinayak_enterprise/core/models/invoice_model.dart';
import 'package:siddhivinayak_enterprise/modules/invoice/models/whatsapp_message_template.dart';
import 'package:siddhivinayak_enterprise/modules/invoice/utils/whatsapp_helper.dart';

/// Message Template Service handles all message formatting for WhatsApp
class MessageTemplateService {
  static const String companyName = 'Siddhivinayak Enterprise';
  static const String companyAddress = 'Shop No. 123, Main Road, City';

  /// Generate professional invoice message for WhatsApp
  static String generateInvoiceMessage({
    required String customerName,
    required String invoiceNumber,
    required List<InvoiceItemModel> items,
    required double subtotal,
    required double taxAmount,
    required double totalAmount,
    String? companyName,
    String? companyAddress,
    String? phone,
    String? email,
    bool useShortFormat = false,
  }) {
    if (useShortFormat) {
      return _generateShortMessage(
        customerName: customerName,
        invoiceNumber: invoiceNumber,
        items: items,
        totalAmount: totalAmount,
        companyName: companyName ?? MessageTemplateService.companyName,
      );
    }

    return _generateDetailedMessage(
      customerName: customerName,
      invoiceNumber: invoiceNumber,
      items: items,
      subtotal: subtotal,
      taxAmount: taxAmount,
      totalAmount: totalAmount,
      companyName: companyName ?? MessageTemplateService.companyName,
      companyAddress: companyAddress ?? MessageTemplateService.companyAddress,
      phone: phone,
      email: email,
    );
  }

  /// Generate detailed invoice message
  static String _generateDetailedMessage({
    required String customerName,
    required String invoiceNumber,
    required List<InvoiceItemModel> items,
    required double subtotal,
    required double taxAmount,
    required double totalAmount,
    required String companyName,
    required String companyAddress,
    String? phone,
    String? email,
  }) {
    final sb = StringBuffer();

    sb.writeln('Hello $customerName,');
    sb.writeln('');
    sb.writeln('Thank you for your purchase from $companyName.');
    sb.writeln('');
    sb.writeln('Invoice Details:');
    sb.writeln('━━━━━━━━━━━━━━━');
    sb.writeln('Invoice No: $invoiceNumber');
    sb.writeln('');

    for (final item in items) {
      final lineTotal = item.unitPrice * item.quantity;
      sb.writeln('• ${item.productName} × ${item.quantity.toInt()} = ₹${lineTotal.toStringAsFixed(0)}');
    }

    sb.writeln('');
    sb.writeln('━━━━━━━━━━━━━━━');
    sb.writeln('Subtotal: ₹${subtotal.toStringAsFixed(0)}');
    sb.writeln('Tax: ₹${taxAmount.toStringAsFixed(0)}');
    sb.writeln('');
    sb.writeln('Total Amount: ₹${totalAmount.toStringAsFixed(0)}');
    sb.writeln('');
    sb.writeln('We appreciate your business.');
    sb.writeln('');
    sb.writeln('Thank You,');
    sb.writeln(companyName);

    if (phone != null || email != null) {
      sb.writeln('');
      sb.writeln('Contact:');
      if (phone != null) {
        sb.writeln('Phone: $phone');
      }
      if (email != null) {
        sb.writeln('Email: $email');
      }
    }

    return sb.toString();
  }

  /// Generate short invoice message (for character-limited scenarios)
  static String _generateShortMessage({
    required String customerName,
    required String invoiceNumber,
    required List<InvoiceItemModel> items,
    required double totalAmount,
    required String companyName,
  }) {
    final sb = StringBuffer();

    sb.writeln('Hello $customerName,');
    sb.writeln('');
    sb.writeln('Thank you for your purchase!');
    sb.writeln('');
    sb.writeln('Invoice: $invoiceNumber');
    sb.writeln('Amount: ₹${totalAmount.toStringAsFixed(0)}');
    sb.writeln('');
    sb.writeln('Items:');
    
    for (final item in items.take(3)) {
      sb.writeln('• ${item.productName} × ${item.quantity.toInt()}');
    }
    
    if (items.length > 3) {
      sb.writeln('... and ${items.length - 3} more items');
    }
    
    sb.writeln('');
    sb.writeln('Thank You,');
    sb.writeln(companyName);

    return sb.toString();
  }

  /// Generate invoice message from InvoiceModel
  static String generateFromInvoiceModel({
    required InvoiceModel invoice,
    required List<InvoiceItemModel> items,
    bool useShortFormat = false,
  }) {
    return generateInvoiceMessage(
      customerName: invoice.customerName,
      invoiceNumber: invoice.invoiceNumber,
      items: items,
      subtotal: invoice.subtotal,
      taxAmount: invoice.taxAmount,
      totalAmount: invoice.totalAmount,
      companyName: companyName,
      companyAddress: companyAddress,
      phone: invoice.customerPhone,
      email: invoice.customerEmail,
      useShortFormat: useShortFormat,
    );
  }

  /// Generate payment reminder message
  static String generatePaymentReminder({
    required String customerName,
    required String invoiceNumber,
    required double pendingAmount,
    required DateTime dueDate,
    String? phone,
    String? email,
  }) {
    final sb = StringBuffer();

    sb.writeln('Hello $customerName,');
    sb.writeln('');
    sb.writeln('This is a friendly reminder about your pending payment.');
    sb.writeln('');
    sb.writeln('Invoice Details:');
    sb.writeln('━━━━━━━━━━━━━━━');
    sb.writeln('Invoice No: $invoiceNumber');
    sb.writeln('Pending Amount: ₹${pendingAmount.toStringAsFixed(0)}');
    sb.writeln('Due Date: ${WhatsAppHelper.formatDate(dueDate)}');
    sb.writeln('');
    sb.writeln('Please complete your payment at your earliest convenience.');
    sb.writeln('');
    sb.writeln('Thank You,');
    sb.writeln(companyName);

    if (phone != null || email != null) {
      sb.writeln('');
      sb.writeln('Contact:');
      if (phone != null) {
        sb.writeln('Phone: $phone');
      }
      if (email != null) {
        sb.writeln('Email: $email');
      }
    }

    return sb.toString();
  }

  /// Generate invoice cancellation message
  static String generateInvoiceCancellation({
    required String customerName,
    required String invoiceNumber,
    required String reason,
  }) {
    final sb = StringBuffer();

    sb.writeln('Hello $customerName,');
    sb.writeln('');
    sb.writeln('We regret to inform you that your invoice has been cancelled.');
    sb.writeln('');
    sb.writeln('Invoice Details:');
    sb.writeln('━━━━━━━━━━━━━━━');
    sb.writeln('Invoice No: $invoiceNumber');
    sb.writeln('Reason: $reason');
    sb.writeln('');
    sb.writeln('If you have any questions, please contact us.');
    sb.writeln('');
    sb.writeln('Thank You,');
    sb.writeln(companyName);

    return sb.toString();
  }

  /// Generate thank you message (for post-payment)
  static String generateThankYouMessage({
    required String customerName,
    required String invoiceNumber,
    required double paidAmount,
    required DateTime paymentDate,
  }) {
    final sb = StringBuffer();

    sb.writeln('Hello $customerName,');
    sb.writeln('');
    sb.writeln('Thank you for your payment!');
    sb.writeln('');
    sb.writeln('Payment Details:');
    sb.writeln('━━━━━━━━━━━━━━━');
    sb.writeln('Invoice No: $invoiceNumber');
    sb.writeln('Amount Paid: ₹${paidAmount.toStringAsFixed(0)}');
    sb.writeln('Payment Date: ${WhatsAppHelper.formatDate(paymentDate)}');
    sb.writeln('');
    sb.writeln('We appreciate your prompt payment.');
    sb.writeln('');
    sb.writeln('Thank You,');
    sb.writeln(companyName);

    return sb.toString();
  }
}
