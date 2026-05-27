class ExpenseModel {
  final String id;
  final String expenseNumber;
  final String category;
  final String description;
  final double amount;
  final DateTime expenseDate;
  final String? vendor;
  final String? paymentMethod;
  final String? referenceNumber;
  final ExpenseStatus status;
  final String? approvedBy;
  final DateTime? approvedAt;
  final String? notes;
  final List<String>? attachments;
  final DateTime createdAt;
  final DateTime updatedAt;

  ExpenseModel({
    required this.id,
    required this.expenseNumber,
    required this.category,
    required this.description,
    required this.amount,
    required this.expenseDate,
    this.vendor,
    this.paymentMethod,
    this.referenceNumber,
    required this.status,
    this.approvedBy,
    this.approvedAt,
    this.notes,
    this.attachments,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id'] as String,
      expenseNumber: json['expenseNumber'] as String,
      category: json['category'] as String,
      description: json['description'] as String,
      amount: (json['amount'] as num).toDouble(),
      expenseDate: DateTime.parse(json['expenseDate'] as String),
      vendor: json['vendor'] as String?,
      paymentMethod: json['paymentMethod'] as String?,
      referenceNumber: json['referenceNumber'] as String?,
      status: ExpenseStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ExpenseStatus.pending,
      ),
      approvedBy: json['approvedBy'] as String?,
      approvedAt: json['approvedAt'] != null
          ? DateTime.parse(json['approvedAt'] as String)
          : null,
      notes: json['notes'] as String?,
      attachments: json['attachments'] != null
          ? List<String>.from(json['attachments'] as List)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'expenseNumber': expenseNumber,
      'category': category,
      'description': description,
      'amount': amount,
      'expenseDate': expenseDate.toIso8601String(),
      'vendor': vendor,
      'paymentMethod': paymentMethod,
      'referenceNumber': referenceNumber,
      'status': status.name,
      'approvedBy': approvedBy,
      'approvedAt': approvedAt?.toIso8601String(),
      'notes': notes,
      'attachments': attachments,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  bool get isApproved => status == ExpenseStatus.approved;

  bool get isPending => status == ExpenseStatus.pending;

  bool get isRejected => status == ExpenseStatus.rejected;
}

enum ExpenseStatus {
  pending,
  approved,
  rejected,
  paid,
}
