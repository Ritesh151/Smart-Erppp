class WhatsAppMessageTemplate {
  final String customerName;
  final String invoiceNumber;
  final List<InvoiceItem> items;
  final double subtotal;
  final double taxAmount;
  final double totalAmount;
  final String companyName;
  final String companyAddress;
  final String? phone;
  final String? email;

  const WhatsAppMessageTemplate({
    required this.customerName,
    required this.invoiceNumber,
    required this.items,
    required this.subtotal,
    required this.taxAmount,
    required this.totalAmount,
    this.companyName = 'Siddhivinayak Enterprise',
    this.companyAddress = 'Shop No. 123, Main Road, City',
    this.phone,
    this.email,
  });

  String generateMessage() {
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

  String generateShortMessage() {
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
}

class InvoiceItem {
  final String productName;
  final double unitPrice;
  final double quantity;

  const InvoiceItem({
    required this.productName,
    required this.unitPrice,
    required this.quantity,
  });

  factory InvoiceItem.fromInvoiceItem(dynamic item) {
    final map = item as Map<String, dynamic>;
    return InvoiceItem(
      productName: (map['productName'] ?? '') as String,
      unitPrice: ((map['unitPrice'] ?? 0) as num).toDouble(),
      quantity: ((map['quantity'] ?? 0) as num).toDouble(),
    );
  }
}
