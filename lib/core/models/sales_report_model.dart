import 'package:hive/hive.dart';

part 'sales_report_model.g.dart';

@HiveType(typeId: 24)
class SalesReportModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String reportId;

  @HiveField(2)
  final double totalSales;

  @HiveField(3)
  final int salesCount;

  @HiveField(4)
  final double averageOrderValue;

  @HiveField(5)
  final List<Map<String, dynamic>> topProducts;

  @HiveField(6)
  final List<Map<String, dynamic>> topCustomers;

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

  SalesReportModel({
    required this.id,
    required this.reportId,
    required this.totalSales,
    required this.salesCount,
    required this.averageOrderValue,
    this.topProducts = const [],
    this.topCustomers = const [],
    this.monthlyTrend = const [],
    this.monthlyLabels = const [],
    required this.month,
    required this.year,
    required this.createdAt,
  });

  factory SalesReportModel.create({
    required String reportId,
    required double totalSales,
    required int salesCount,
    required double averageOrderValue,
    List<Map<String, dynamic>> topProducts = const [],
    List<Map<String, dynamic>> topCustomers = const [],
    List<double> monthlyTrend = const [],
    List<String> monthlyLabels = const [],
    required int month,
    required int year,
  }) {
    return SalesReportModel(
      id: _generateId(),
      reportId: reportId,
      totalSales: totalSales,
      salesCount: salesCount,
      averageOrderValue: averageOrderValue,
      topProducts: topProducts,
      topCustomers: topCustomers,
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
    return 'SR-$timestamp-$random';
  }

  factory SalesReportModel.fromJson(Map<String, dynamic> json) {
    return SalesReportModel(
      id: json['id'] as String,
      reportId: json['reportId'] as String,
      totalSales: (json['totalSales'] as num).toDouble(),
      salesCount: json['salesCount'] as int,
      averageOrderValue: (json['averageOrderValue'] as num).toDouble(),
      topProducts: (json['topProducts'] as List<dynamic>?)
              ?.map((e) => Map<String, dynamic>.from(e as Map))
              .toList() ??
          [],
      topCustomers: (json['topCustomers'] as List<dynamic>?)
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
      'totalSales': totalSales,
      'salesCount': salesCount,
      'averageOrderValue': averageOrderValue,
      'topProducts': topProducts,
      'topCustomers': topCustomers,
      'monthlyTrend': monthlyTrend,
      'monthlyLabels': monthlyLabels,
      'month': month,
      'year': year,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  SalesReportModel copyWith({
    String? id,
    String? reportId,
    double? totalSales,
    int? salesCount,
    double? averageOrderValue,
    List<Map<String, dynamic>>? topProducts,
    List<Map<String, dynamic>>? topCustomers,
    List<double>? monthlyTrend,
    List<String>? monthlyLabels,
    int? month,
    int? year,
    DateTime? createdAt,
  }) {
    return SalesReportModel(
      id: id ?? this.id,
      reportId: reportId ?? this.reportId,
      totalSales: totalSales ?? this.totalSales,
      salesCount: salesCount ?? this.salesCount,
      averageOrderValue: averageOrderValue ?? this.averageOrderValue,
      topProducts: topProducts ?? this.topProducts,
      topCustomers: topCustomers ?? this.topCustomers,
      monthlyTrend: monthlyTrend ?? this.monthlyTrend,
      monthlyLabels: monthlyLabels ?? this.monthlyLabels,
      month: month ?? this.month,
      year: year ?? this.year,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  bool get hasData => totalSales > 0 || salesCount > 0;
  double get salesPerDay => daysInMonth > 0 ? totalSales / daysInMonth : 0;
  int get daysInMonth => DateTime(year, month + 1, 0).day;
}
