import 'package:hive/hive.dart';

part 'profit_loss_model.g.dart';

@HiveType(typeId: 28)
class ProfitLossModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String reportId;

  @HiveField(2)
  final double totalRevenue;

  @HiveField(3)
  final double totalCostOfGoodsSold;

  @HiveField(4)
  final double totalExpenses;

  @HiveField(5)
  final double totalPayrollCost;

  @HiveField(6)
  final double grossProfit;

  @HiveField(7)
  final double netProfit;

  @HiveField(8)
  final double profitMargin;

  @HiveField(9)
  final double previousNetProfit;

  @HiveField(10)
  final List<double> revenueTrend;

  @HiveField(11)
  final List<double> expenseTrend;

  @HiveField(12)
  final List<String> trendLabels;

  @HiveField(13)
  final int month;

  @HiveField(14)
  final int year;

  @HiveField(15)
  final DateTime createdAt;

  ProfitLossModel({
    required this.id,
    required this.reportId,
    required this.totalRevenue,
    this.totalCostOfGoodsSold = 0,
    required this.totalExpenses,
    this.totalPayrollCost = 0,
    required this.grossProfit,
    required this.netProfit,
    required this.profitMargin,
    this.previousNetProfit = 0,
    this.revenueTrend = const [],
    this.expenseTrend = const [],
    this.trendLabels = const [],
    required this.month,
    required this.year,
    required this.createdAt,
  });

  factory ProfitLossModel.create({
    required String reportId,
    required double totalRevenue,
    double totalCostOfGoodsSold = 0,
    required double totalExpenses,
    double totalPayrollCost = 0,
    required double grossProfit,
    required double netProfit,
    required double profitMargin,
    double previousNetProfit = 0,
    List<double> revenueTrend = const [],
    List<double> expenseTrend = const [],
    List<String> trendLabels = const [],
    required int month,
    required int year,
  }) {
    return ProfitLossModel(
      id: _generateId(),
      reportId: reportId,
      totalRevenue: totalRevenue,
      totalCostOfGoodsSold: totalCostOfGoodsSold,
      totalExpenses: totalExpenses,
      totalPayrollCost: totalPayrollCost,
      grossProfit: grossProfit,
      netProfit: netProfit,
      profitMargin: profitMargin,
      previousNetProfit: previousNetProfit,
      revenueTrend: revenueTrend,
      expenseTrend: expenseTrend,
      trendLabels: trendLabels,
      month: month,
      year: year,
      createdAt: DateTime.now(),
    );
  }

  static String _generateId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp % 10000).toString().padLeft(4, '0');
    return 'PLR-$timestamp-$random';
  }

  factory ProfitLossModel.fromJson(Map<String, dynamic> json) {
    return ProfitLossModel(
      id: json['id'] as String,
      reportId: json['reportId'] as String,
      totalRevenue: (json['totalRevenue'] as num).toDouble(),
      totalCostOfGoodsSold: (json['totalCostOfGoodsSold'] as num?)?.toDouble() ?? 0,
      totalExpenses: (json['totalExpenses'] as num).toDouble(),
      totalPayrollCost: (json['totalPayrollCost'] as num?)?.toDouble() ?? 0,
      grossProfit: (json['grossProfit'] as num).toDouble(),
      netProfit: (json['netProfit'] as num).toDouble(),
      profitMargin: (json['profitMargin'] as num).toDouble(),
      previousNetProfit: (json['previousNetProfit'] as num?)?.toDouble() ?? 0,
      revenueTrend: (json['revenueTrend'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          [],
      expenseTrend: (json['expenseTrend'] as List<dynamic>?)
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
      'totalRevenue': totalRevenue,
      'totalCostOfGoodsSold': totalCostOfGoodsSold,
      'totalExpenses': totalExpenses,
      'totalPayrollCost': totalPayrollCost,
      'grossProfit': grossProfit,
      'netProfit': netProfit,
      'profitMargin': profitMargin,
      'previousNetProfit': previousNetProfit,
      'revenueTrend': revenueTrend,
      'expenseTrend': expenseTrend,
      'trendLabels': trendLabels,
      'month': month,
      'year': year,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  ProfitLossModel copyWith({
    String? id,
    String? reportId,
    double? totalRevenue,
    double? totalCostOfGoodsSold,
    double? totalExpenses,
    double? totalPayrollCost,
    double? grossProfit,
    double? netProfit,
    double? profitMargin,
    double? previousNetProfit,
    List<double>? revenueTrend,
    List<double>? expenseTrend,
    List<String>? trendLabels,
    int? month,
    int? year,
    DateTime? createdAt,
  }) {
    return ProfitLossModel(
      id: id ?? this.id,
      reportId: reportId ?? this.reportId,
      totalRevenue: totalRevenue ?? this.totalRevenue,
      totalCostOfGoodsSold: totalCostOfGoodsSold ?? this.totalCostOfGoodsSold,
      totalExpenses: totalExpenses ?? this.totalExpenses,
      totalPayrollCost: totalPayrollCost ?? this.totalPayrollCost,
      grossProfit: grossProfit ?? this.grossProfit,
      netProfit: netProfit ?? this.netProfit,
      profitMargin: profitMargin ?? this.profitMargin,
      previousNetProfit: previousNetProfit ?? this.previousNetProfit,
      revenueTrend: revenueTrend ?? this.revenueTrend,
      expenseTrend: expenseTrend ?? this.expenseTrend,
      trendLabels: trendLabels ?? this.trendLabels,
      month: month ?? this.month,
      year: year ?? this.year,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  bool get isProfitable => netProfit > 0;
  bool get isLoss => netProfit < 0;
  bool get hasData => totalRevenue > 0 || totalExpenses > 0;
  double get totalCosts => totalCostOfGoodsSold + totalExpenses + totalPayrollCost;
  double get profitGrowth => previousNetProfit > 0
      ? ((netProfit - previousNetProfit) / previousNetProfit) * 100
      : 0;
}
