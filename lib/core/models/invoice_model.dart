import 'dart:convert';

import 'package:hive/hive.dart';

part 'invoice_model.g.dart';

class InternalCharge {
  final String chargeName;
  final double chargeAmount;
  final String? chargeDescription;

  const InternalCharge({
    required this.chargeName,
    required this.chargeAmount,
    this.chargeDescription,
  });

  factory InternalCharge.fromJson(Map<String, dynamic> json) {
    return InternalCharge(
      chargeName: json['chargeName'] as String? ?? '',
      chargeAmount: (json['chargeAmount'] as num?)?.toDouble() ?? 0,
      chargeDescription: json['chargeDescription'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chargeName': chargeName,
      'chargeAmount': chargeAmount,
      'chargeDescription': chargeDescription,
    };
  }

  InternalCharge copyWith({
    String? chargeName,
    double? chargeAmount,
    String? chargeDescription,
  }) {
    return InternalCharge(
      chargeName: chargeName ?? this.chargeName,
      chargeAmount: chargeAmount ?? this.chargeAmount,
      chargeDescription: chargeDescription ?? this.chargeDescription,
    );
  }
}

@HiveType(typeId: 3)
class InvoiceModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String invoiceNumber;

  @HiveField(2)
  final String customerId;

  @HiveField(3)
  final String customerName;

  @HiveField(4)
  final String? customerEmail;

  @HiveField(5)
  final String? customerPhone;

  @HiveField(6)
  final String? customerAddress;

  @HiveField(7)
  final String? customerGst;

  @HiveField(8)
  final DateTime invoiceDate;

  @HiveField(9)
  final DateTime dueDate;

  @HiveField(10)
  final List<String> itemIds;

  @HiveField(11)
  final double subtotal;

  @HiveField(12)
  final double taxAmount;

  @HiveField(13)
  final double discountAmount;

  @HiveField(14)
  final double totalAmount;

  @HiveField(15)
  final double paidAmount;

  @HiveField(16)
  final InvoiceStatus status;

  @HiveField(17)
  final String? notes;

  @HiveField(18)
  final String? termsAndConditions;

  @HiveField(19)
  final DateTime createdAt;

  @HiveField(20)
  final DateTime updatedAt;

  @HiveField(21)
  final String? bankName;

  @HiveField(22)
  final String? branchName;

  @HiveField(23)
  final String? ifscCode;

  @HiveField(24)
  final String? accountNumber;

  @HiveField(25)
  final int paymentDays;

  @HiveField(26)
  final int paymentMonths;

  @HiveField(27)
  final String? paymentTermDescription;

  @HiveField(28)
  final String? customPaymentNotes;

  @HiveField(29)
  final String? internalChargesJson;

  InvoiceModel({
    required this.id,
    required this.invoiceNumber,
    required this.customerId,
    required this.customerName,
    this.customerEmail,
    this.customerPhone,
    this.customerAddress,
    this.customerGst,
    required this.invoiceDate,
    required this.dueDate,
    required this.itemIds,
    required this.subtotal,
    required this.taxAmount,
    required this.discountAmount,
    required this.totalAmount,
    required this.paidAmount,
    required this.status,
    this.notes,
    this.termsAndConditions,
    required this.createdAt,
    required this.updatedAt,
    this.bankName,
    this.branchName,
    this.ifscCode,
    this.accountNumber,
    this.paymentDays = 0,
    this.paymentMonths = 0,
    this.paymentTermDescription,
    this.customPaymentNotes,
    this.internalChargesJson,
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    return InvoiceModel(
      id: json['id'] as String,
      invoiceNumber: json['invoiceNumber'] as String,
      customerId: json['customerId'] as String,
      customerName: json['customerName'] as String,
      customerEmail: json['customerEmail'] as String?,
      customerPhone: json['customerPhone'] as String?,
      customerAddress: json['customerAddress'] as String?,
      customerGst: json['customerGst'] as String?,
      invoiceDate: DateTime.parse(json['invoiceDate'] as String),
      dueDate: DateTime.parse(json['dueDate'] as String),
      itemIds: (json['itemIds'] as List).map((e) => e as String).toList(),
      subtotal: (json['subtotal'] as num).toDouble(),
      taxAmount: (json['taxAmount'] as num).toDouble(),
      discountAmount: (json['discountAmount'] as num).toDouble(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      paidAmount: (json['paidAmount'] as num).toDouble(),
      status: InvoiceStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => InvoiceStatus.draft,
      ),
      notes: json['notes'] as String?,
      termsAndConditions: json['termsAndConditions'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      bankName: json['bankName'] as String?,
      branchName: json['branchName'] as String?,
      ifscCode: json['ifscCode'] as String?,
      accountNumber: json['accountNumber'] as String?,
      paymentDays: (json['paymentDays'] as num?)?.toInt() ?? 0,
      paymentMonths: (json['paymentMonths'] as num?)?.toInt() ?? 0,
      paymentTermDescription: json['paymentTermDescription'] as String?,
      customPaymentNotes: json['customPaymentNotes'] as String?,
      internalChargesJson: json['internalChargesJson'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'invoiceNumber': invoiceNumber,
      'customerId': customerId,
      'customerName': customerName,
      'customerEmail': customerEmail,
      'customerPhone': customerPhone,
      'customerAddress': customerAddress,
      'customerGst': customerGst,
      'invoiceDate': invoiceDate.toIso8601String(),
      'dueDate': dueDate.toIso8601String(),
      'itemIds': itemIds,
      'subtotal': subtotal,
      'taxAmount': taxAmount,
      'discountAmount': discountAmount,
      'totalAmount': totalAmount,
      'paidAmount': paidAmount,
      'status': status.name,
      'notes': notes,
      'termsAndConditions': termsAndConditions,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'bankName': bankName,
      'branchName': branchName,
      'ifscCode': ifscCode,
      'accountNumber': accountNumber,
      'paymentDays': paymentDays,
      'paymentMonths': paymentMonths,
      'paymentTermDescription': paymentTermDescription,
      'customPaymentNotes': customPaymentNotes,
      'internalChargesJson': internalChargesJson,
    };
  }

  InvoiceModel copyWith({
    String? id,
    String? invoiceNumber,
    String? customerId,
    String? customerName,
    String? customerEmail,
    String? customerPhone,
    String? customerAddress,
    String? customerGst,
    DateTime? invoiceDate,
    DateTime? dueDate,
    List<String>? itemIds,
    double? subtotal,
    double? taxAmount,
    double? discountAmount,
    double? totalAmount,
    double? paidAmount,
    InvoiceStatus? status,
    String? notes,
    String? termsAndConditions,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? bankName,
    String? branchName,
    String? ifscCode,
    String? accountNumber,
    int? paymentDays,
    int? paymentMonths,
    String? paymentTermDescription,
    String? customPaymentNotes,
    String? internalChargesJson,
  }) {
    return InvoiceModel(
      id: id ?? this.id,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerEmail: customerEmail ?? this.customerEmail,
      customerPhone: customerPhone ?? this.customerPhone,
      customerAddress: customerAddress ?? this.customerAddress,
      customerGst: customerGst ?? this.customerGst,
      invoiceDate: invoiceDate ?? this.invoiceDate,
      dueDate: dueDate ?? this.dueDate,
      itemIds: itemIds ?? this.itemIds,
      subtotal: subtotal ?? this.subtotal,
      taxAmount: taxAmount ?? this.taxAmount,
      discountAmount: discountAmount ?? this.discountAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      paidAmount: paidAmount ?? this.paidAmount,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      termsAndConditions: termsAndConditions ?? this.termsAndConditions,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      bankName: bankName ?? this.bankName,
      branchName: branchName ?? this.branchName,
      ifscCode: ifscCode ?? this.ifscCode,
      accountNumber: accountNumber ?? this.accountNumber,
      paymentDays: paymentDays ?? this.paymentDays,
      paymentMonths: paymentMonths ?? this.paymentMonths,
      paymentTermDescription: paymentTermDescription ?? this.paymentTermDescription,
      customPaymentNotes: customPaymentNotes ?? this.customPaymentNotes,
      internalChargesJson: internalChargesJson ?? this.internalChargesJson,
    );
  }

  double get balanceAmount => totalAmount - paidAmount;
  double get remainingAmount => totalAmount - paidAmount;
  bool get isOverdue => status != InvoiceStatus.paid && status != InvoiceStatus.cancelled && DateTime.now().isAfter(dueDate);
  bool get isPaid => status == InvoiceStatus.paid;
  bool get isPartiallyPaid => paidAmount > 0 && paidAmount < totalAmount;
  bool get isDraft => status == InvoiceStatus.draft;
  bool get isCancelled => status == InvoiceStatus.cancelled;

  double get cgstAmount => taxAmount / 2;
  double get sgstAmount => taxAmount / 2;
  double get igstAmount => 0.0;

  double get roundOff {
    final rounded = totalAmount.roundToDouble();
    return rounded - totalAmount;
  }

  double get grandTotalRounded => totalAmount + roundOff;

  List<InternalCharge> get internalCharges {
    if (internalChargesJson == null || internalChargesJson!.isEmpty) return [];
    try {
      final list = jsonDecode(internalChargesJson!) as List;
      return list.map((e) => InternalCharge.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  double get internalChargesTotal =>
      internalCharges.fold(0.0, (sum, c) => sum + c.chargeAmount);
}

@HiveType(typeId: 7)
enum InvoiceStatus {
  @HiveField(0)
  draft,
  @HiveField(1)
  sent,
  @HiveField(2)
  paid,
  @HiveField(3)
  partiallyPaid,
  @HiveField(4)
  overdue,
  @HiveField(5)
  cancelled,
}
