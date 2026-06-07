import 'package:uuid/uuid.dart';

class WhatsAppInvoiceModel {
  final String id;
  final String invoiceId;
  final String customerId;
  final String customerName;
  final String customerPhone;
  final String invoiceNumber;
  final String formattedMessage;
  final DateTime sentAt;
  final bool success;
  final String? errorMessage;
  final String? messageId;

  WhatsAppInvoiceModel({
    required this.id,
    required this.invoiceId,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.invoiceNumber,
    required this.formattedMessage,
    required this.sentAt,
    required this.success,
    this.errorMessage,
    this.messageId,
  });

  factory WhatsAppInvoiceModel.create({
    required String invoiceId,
    required String customerId,
    required String customerName,
    required String customerPhone,
    required String invoiceNumber,
    required String formattedMessage,
    required bool success,
    String? errorMessage,
  }) {
    return WhatsAppInvoiceModel(
      id: const Uuid().v4(),
      invoiceId: invoiceId,
      customerId: customerId,
      customerName: customerName,
      customerPhone: customerPhone,
      invoiceNumber: invoiceNumber,
      formattedMessage: formattedMessage,
      sentAt: DateTime.now(),
      success: success,
      errorMessage: errorMessage,
    );
  }

  factory WhatsAppInvoiceModel.fromJson(Map<String, dynamic> json) {
    return WhatsAppInvoiceModel(
      id: json['id'] as String,
      invoiceId: json['invoiceId'] as String,
      customerId: json['customerId'] as String,
      customerName: json['customerName'] as String,
      customerPhone: json['customerPhone'] as String,
      invoiceNumber: json['invoiceNumber'] as String,
      formattedMessage: json['formattedMessage'] as String,
      sentAt: DateTime.parse(json['sentAt'] as String),
      success: json['success'] as bool,
      errorMessage: json['errorMessage'] as String?,
      messageId: json['messageId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'invoiceId': invoiceId,
      'customerId': customerId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'invoiceNumber': invoiceNumber,
      'formattedMessage': formattedMessage,
      'sentAt': sentAt.toIso8601String(),
      'success': success,
      'errorMessage': errorMessage,
      'messageId': messageId,
    };
  }

  WhatsAppInvoiceModel copyWith({
    String? id,
    String? invoiceId,
    String? customerId,
    String? customerName,
    String? customerPhone,
    String? invoiceNumber,
    String? formattedMessage,
    DateTime? sentAt,
    bool? success,
    String? errorMessage,
    String? messageId,
  }) {
    return WhatsAppInvoiceModel(
      id: id ?? this.id,
      invoiceId: invoiceId ?? this.invoiceId,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      formattedMessage: formattedMessage ?? this.formattedMessage,
      sentAt: sentAt ?? this.sentAt,
      success: success ?? this.success,
      errorMessage: errorMessage ?? this.errorMessage,
      messageId: messageId ?? this.messageId,
    );
  }
}
