import 'package:hive/hive.dart';

part 'stock_report_model.g.dart';

@HiveType(typeId: 27)
class StockReportModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String reportId;

  @HiveField(2)
  final double totalInventoryValue;

  @HiveField(3)
  final int totalProducts;

  @HiveField(4)
  final int lowStockCount;

  @HiveField(5)
  final int outOfStockCount;

  @HiveField(6)
  final int inStockCount;

  @HiveField(7)
  final List<Map<String, dynamic>> lowStockProducts;

  @HiveField(8)
  final List<Map<String, dynamic>> topMovingProducts;

  @HiveField(9)
  final List<Map<String, dynamic>> categoryDistribution;

  @HiveField(10)
  final List<double> inventoryTrend;

  @HiveField(11)
  final List<String> trendLabels;

  @HiveField(12)
  final int month;

  @HiveField(13)
  final int year;

  @HiveField(14)
  final DateTime createdAt;

  StockReportModel({
    required this.id,
    required this.reportId,
    required this.totalInventoryValue,
    required this.totalProducts,
    this.lowStockCount = 0,
    this.outOfStockCount = 0,
    this.inStockCount = 0,
    this.lowStockProducts = const [],
    this.topMovingProducts = const [],
    this.categoryDistribution = const [],
    this.inventoryTrend = const [],
    this.trendLabels = const [],
    required this.month,
    required this.year,
    required this.createdAt,
  });

  factory StockReportModel.create({
    required String reportId,
    required double totalInventoryValue,
    required int totalProducts,
    int lowStockCount = 0,
    int outOfStockCount = 0,
    int inStockCount = 0,
    List<Map<String, dynamic>> lowStockProducts = const [],
    List<Map<String, dynamic>> topMovingProducts = const [],
    List<Map<String, dynamic>> categoryDistribution = const [],
    List<double> inventoryTrend = const [],
    List<String> trendLabels = const [],
    required int month,
    required int year,
  }) {
    return StockReportModel(
      id: _generateId(),
      reportId: reportId,
      totalInventoryValue: totalInventoryValue,
      totalProducts: totalProducts,
      lowStockCount: lowStockCount,
      outOfStockCount: outOfStockCount,
      inStockCount: inStockCount,
      lowStockProducts: lowStockProducts,
      topMovingProducts: topMovingProducts,
      categoryDistribution: categoryDistribution,
      inventoryTrend: inventoryTrend,
      trendLabels: trendLabels,
      month: month,
      year: year,
      createdAt: DateTime.now(),
    );
  }

  static String _generateId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp % 10000).toString().padLeft(4, '0');
    return 'SKR-$timestamp-$random';
  }

  factory StockReportModel.fromJson(Map<String, dynamic> json) {
    return StockReportModel(
      id: json['id'] as String,
      reportId: json['reportId'] as String,
      totalInventoryValue: (json['totalInventoryValue'] as num).toDouble(),
      totalProducts: json['totalProducts'] as int,
      lowStockCount: json['lowStockCount'] as int? ?? 0,
      outOfStockCount: json['outOfStockCount'] as int? ?? 0,
      inStockCount: json['inStockCount'] as int? ?? 0,
      lowStockProducts: (json['lowStockProducts'] as List<dynamic>?)
              ?.map((e) => Map<String, dynamic>.from(e as Map))
              .toList() ??
          [],
      topMovingProducts: (json['topMovingProducts'] as List<dynamic>?)
              ?.map((e) => Map<String, dynamic>.from(e as Map))
              .toList() ??
          [],
      categoryDistribution: (json['categoryDistribution'] as List<dynamic>?)
              ?.map((e) => Map<String, dynamic>.from(e as Map))
              .toList() ??
          [],
      inventoryTrend: (json['inventoryTrend'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          [],
      trendLabels: (json['trendLabels'] as List<dynamic>?)
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
      'totalInventoryValue': totalInventoryValue,
      'totalProducts': totalProducts,
      'lowStockCount': lowStockCount,
      'outOfStockCount': outOfStockCount,
      'inStockCount': inStockCount,
      'lowStockProducts': lowStockProducts,
      'topMovingProducts': topMovingProducts,
      'categoryDistribution': categoryDistribution,
      'inventoryTrend': inventoryTrend,
      'trendLabels': trendLabels,
      'month': month,
      'year': year,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  StockReportModel copyWith({
    String? id,
    String? reportId,
    double? totalInventoryValue,
    int? totalProducts,
    int? lowStockCount,
    int? outOfStockCount,
    int? inStockCount,
    List<Map<String, dynamic>>? lowStockProducts,
    List<Map<String, dynamic>>? topMovingProducts,
    List<Map<String, dynamic>>? categoryDistribution,
    List<double>? inventoryTrend,
    List<String>? trendLabels,
    int? month,
    int? year,
    DateTime? createdAt,
  }) {
    return StockReportModel(
      id: id ?? this.id,
      reportId: reportId ?? this.reportId,
      totalInventoryValue: totalInventoryValue ?? this.totalInventoryValue,
      totalProducts: totalProducts ?? this.totalProducts,
      lowStockCount: lowStockCount ?? this.lowStockCount,
      outOfStockCount: outOfStockCount ?? this.outOfStockCount,
      inStockCount: inStockCount ?? this.inStockCount,
      lowStockProducts: lowStockProducts ?? this.lowStockProducts,
      topMovingProducts: topMovingProducts ?? this.topMovingProducts,
      categoryDistribution: categoryDistribution ?? this.categoryDistribution,
      inventoryTrend: inventoryTrend ?? this.inventoryTrend,
      trendLabels: trendLabels ?? this.trendLabels,
      month: month ?? this.month,
      year: year ?? this.year,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  double get stockHealthPercentage =>
      totalProducts > 0 ? (inStockCount / totalProducts) * 100 : 0;

  double get averageProductValue =>
      totalProducts > 0 ? totalInventoryValue / totalProducts : 0;

  int get totalStockIssues => lowStockCount + outOfStockCount;
  bool get hasStockIssues => totalStockIssues > 0;
  bool get hasData => totalProducts > 0;
}
