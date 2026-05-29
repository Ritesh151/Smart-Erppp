class LocalInvoiceItem {
  final String productId;
  final String productName;
  final double price;
  final double quantity;
  final dynamic productImage;

  const LocalInvoiceItem({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    this.productImage,
  });

  factory LocalInvoiceItem.fromMap(Map<String, dynamic> map) {
    return LocalInvoiceItem(
      productId: map['productId'] as String? ?? '',
      productName: map['productName'] as String? ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0,
      quantity: (map['quantity'] as num?)?.toDouble() ?? 0,
      productImage: map['productImage'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'price': price,
      'quantity': quantity,
    };
  }
}

class LocalInvoice {
  final String id;
  final String invoiceNumber;
  final String customerName;
  final DateTime invoiceDate;
  final double grandTotal;
  final List<LocalInvoiceItem> items;
  final DateTime createdAt;
  final String pdfPath;
  final String? pdfBytesBase64;

  const LocalInvoice({
    required this.id,
    required this.invoiceNumber,
    required this.customerName,
    required this.invoiceDate,
    required this.grandTotal,
    required this.items,
    required this.createdAt,
    this.pdfPath = '',
    this.pdfBytesBase64,
  });

  factory LocalInvoice.fromMap(Map<String, dynamic> map) {
    final itemsList = (map['items'] as List<dynamic>?)
            ?.map((e) => LocalInvoiceItem.fromMap(
                e is Map<String, dynamic> ? e : Map<String, dynamic>.from(e as Map)))
            .toList() ??
        [];

    return LocalInvoice(
      id: map['id'] as String? ?? map['invoiceId'] as String? ?? '',
      invoiceNumber:
          map['invoiceNumber'] as String? ?? map['invoice_number'] as String? ?? '',
      customerName:
          map['customerName'] as String? ?? map['customer_name'] as String? ?? '',
      invoiceDate: map['invoiceDate'] != null
          ? DateTime.parse(map['invoiceDate'] as String)
          : DateTime.now(),
      grandTotal: (map['grandTotal'] as num?)?.toDouble() ??
          (map['total'] as num?)?.toDouble() ??
          0,
      items: itemsList,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
      pdfPath: map['pdfPath'] as String? ?? '',
      pdfBytesBase64: map['pdfBytesBase64'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'invoiceNumber': invoiceNumber,
      'customerName': customerName,
      'invoiceDate': invoiceDate.toIso8601String(),
      'grandTotal': grandTotal,
      'items': items.map((e) => e.toMap()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'pdfPath': pdfPath,
      'pdfBytesBase64': pdfBytesBase64,
    };
  }
}
