import 'package:hive/hive.dart';

part 'purchase_report_model.g.dart';

@HiveType(typeId: 25)
class PurchaseReportModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String reportId;

  @HiveField(2)
  final double totalPurchases;

  @HiveField(3)
  final int purchaseCount;

  @HiveField(4)
  final double averageOrderValue;

  @HiveField(5)
  final List<Map<String, dynamic>> topSuppliers;

  @HiveField(6)
  final List<Map<String, dynamic>> topProducts;

  @HiveField(7)
  final List<double> monthlyTrend;

  @HiveField(8)
  final List<String> monthlyLabels;

  @HiveField(9)
  final int month;

  @HiveField(10)
  final int year;

  @HiveField(11)
  final DateTime createdAt;

  PurchaseReportModel({
    required this.id,
    required this.reportId,
    required this.totalPurchases,
    required this.purchaseCount,
    required this.averageOrderValue,
    this.topSuppliers = const [],
    this.topProducts = const [],
    this.monthlyTrend = const [],
    this.monthlyLabels = const [],
    required this.month,
    required this.year,
    required this.createdAt,
  });

  factory PurchaseReportModel.create({
    required String reportId,
    required double totalPurchases,
    required int purchaseCount,
    required double averageOrderValue,
    List<Map<String, dynamic>> topSuppliers = const [],
    List<Map<String, dynamic>> topProducts = const [],
    List<double> monthlyTrend = const [],
    List<String> monthlyLabels = const [],
    required int month,
    required int year,
  }) {
    return PurchaseReportModel(
      id: _generateId(),
      reportId: reportId,
      totalPurchases: totalPurchases,
      purchaseCount: purchaseCount,
      averageOrderValue: averageOrderValue,
      topSuppliers: topSuppliers,
      topProducts: topProducts,
      monthlyTrend: monthlyTrend,
      monthlyLabels: monthlyLabels,
      month: month,
      year: year,
      createdAt: DateTime.now(),
    );
  }

  static String _generateId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp % 10000).toString().padLeft(4, '0');
    return 'PR-$timestamp-$random';
  }

  factory PurchaseReportModel.fromJson(Map<String, dynamic> json) {
    return PurchaseReportModel(
      id: json['id'] as String,
      reportId: json['reportId'] as String,
      totalPurchases: (json['totalPurchases'] as num).toDouble(),
      purchaseCount: json['purchaseCount'] as int,
      averageOrderValue: (json['averageOrderValue'] as num).toDouble(),
      topSuppliers: (json['topSuppliers'] as List<dynamic>?)
              ?.map((e) => Map<String, dynamic>.from(e as Map))
              .toList() ??
          [],
      topProducts: (json['topProducts'] as List<dynamic>?)
              ?.map((e) => Map<String, dynamic>.from(e as Map))
              .toList() ??
          [],
      monthlyTrend: (json['monthlyTrend'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          [],
      monthlyLabels: (json['monthlyLabels'] as List<dynamic>?)
              ?.cast<String>()
              .toList() ??
          [],
      month: json['month'] as int,
      year: json['year'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reportId': reportId,
      'totalPurchases': totalPurchases,
      'purchaseCount': purchaseCount,
      'averageOrderValue': averageOrderValue,
      'topSuppliers': topSuppliers,
      'topProducts': topProducts,
      'monthlyTrend': monthlyTrend,
      'monthlyLabels': monthlyLabels,
      'month': month,
      'year': year,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  PurchaseReportModel copyWith({
    String? id,
    String? reportId,
    double? totalPurchases,
    int? purchaseCount,
    double? averageOrderValue,
    List<Map<String, dynamic>>? topSuppliers,
    List<Map<String, dynamic>>? topProducts,
    List<double>? monthlyTrend,
    List<String>? monthlyLabels,
    int? month,
    int? year,
    DateTime? createdAt,
  }) {
    return PurchaseReportModel(
      id: id ?? this.id,
      reportId: reportId ?? this.reportId,
      totalPurchases: totalPurchases ?? this.totalPurchases,
      purchaseCount: purchaseCount ?? this.purchaseCount,
      averageOrderValue: averageOrderValue ?? this.averageOrderValue,
      topSuppliers: topSuppliers ?? this.topSuppliers,
      topProducts: topProducts ?? this.topProducts,
      monthlyTrend: monthlyTrend ?? this.monthlyTrend,
      monthlyLabels: monthlyLabels ?? this.monthlyLabels,
      month: month ?? this.month,
      year: year ?? this.year,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  bool get hasData => totalPurchases > 0 || purchaseCount > 0;
}
