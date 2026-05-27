import 'package:hive/hive.dart';

part 'expense_report_model.g.dart';

@HiveType(typeId: 26)
class ExpenseReportModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String reportId;

  @HiveField(2)
  final double totalExpenses;

  @HiveField(3)
  final int expenseCount;

  @HiveField(4)
  final double highestCategoryAmount;

  @HiveField(5)
  final String highestCategory;

  @HiveField(6)
  final Map<String, double> categoryBreakdown;

  @HiveField(7)
  final List<double> monthlyTrend;

  @HiveField(8)
  final List<String> monthlyLabels;

  @HiveField(9)
  final List<Map<String, dynamic>> topExpenses;

  @HiveField(10)
  final int month;

  @HiveField(11)
  final int year;

  @HiveField(12)
  final DateTime createdAt;

  ExpenseReportModel({
    required this.id,
    required this.reportId,
    required this.totalExpenses,
    required this.expenseCount,
    this.highestCategoryAmount = 0,
    this.highestCategory = '',
    this.categoryBreakdown = const {},
    this.monthlyTrend = const [],
    this.monthlyLabels = const [],
    this.topExpenses = const [],
    required this.month,
    required this.year,
    required this.createdAt,
  });

  factory ExpenseReportModel.create({
    required String reportId,
    required double totalExpenses,
    required int expenseCount,
    double highestCategoryAmount = 0,
    String highestCategory = '',
    Map<String, double> categoryBreakdown = const {},
    List<double> monthlyTrend = const [],
    List<String> monthlyLabels = const [],
    List<Map<String, dynamic>> topExpenses = const [],
    required int month,
    required int year,
  }) {
    return ExpenseReportModel(
      id: _generateId(),
      reportId: reportId,
      totalExpenses: totalExpenses,
      expenseCount: expenseCount,
      highestCategoryAmount: highestCategoryAmount,
      highestCategory: highestCategory,
      categoryBreakdown: categoryBreakdown,
      monthlyTrend: monthlyTrend,
      monthlyLabels: monthlyLabels,
      topExpenses: topExpenses,
      month: month,
      year: year,
      createdAt: DateTime.now(),
    );
  }

  static String _generateId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp % 10000).toString().padLeft(4, '0');
    return 'ER-$timestamp-$random';
  }

  factory ExpenseReportModel.fromJson(Map<String, dynamic> json) {
    return ExpenseReportModel(
      id: json['id'] as String,
      reportId: json['reportId'] as String,
      totalExpenses: (json['totalExpenses'] as num).toDouble(),
      expenseCount: json['expenseCount'] as int,
      highestCategoryAmount: (json['highestCategoryAmount'] as num?)?.toDouble() ?? 0,
      highestCategory: json['highestCategory'] as String? ?? '',
      categoryBreakdown: json['categoryBreakdown'] != null
          ? Map<String, double>.from((json['categoryBreakdown'] as Map).map(
              (k, v) => MapEntry(k as String, (v as num).toDouble()),
            ))
          : {},
      monthlyTrend: (json['monthlyTrend'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          [],
      monthlyLabels: (json['monthlyLabels'] as List<dynamic>?)
              ?.cast<String>()
              .toList() ??
          [],
      topExpenses: (json['topExpenses'] as List<dynamic>?)
              ?.map((e) => Map<String, dynamic>.from(e as Map))
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
      'totalExpenses': totalExpenses,
      'expenseCount': expenseCount,
      'highestCategoryAmount': highestCategoryAmount,
      'highestCategory': highestCategory,
      'categoryBreakdown': categoryBreakdown,
      'monthlyTrend': monthlyTrend,
      'monthlyLabels': monthlyLabels,
      'topExpenses': topExpenses,
      'month': month,
      'year': year,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  ExpenseReportModel copyWith({
    String? id,
    String? reportId,
    double? totalExpenses,
    int? expenseCount,
    double? highestCategoryAmount,
    String? highestCategory,
    Map<String, double>? categoryBreakdown,
    List<double>? monthlyTrend,
    List<String>? monthlyLabels,
    List<Map<String, dynamic>>? topExpenses,
    int? month,
    int? year,
    DateTime? createdAt,
  }) {
    return ExpenseReportModel(
      id: id ?? this.id,
      reportId: reportId ?? this.reportId,
      totalExpenses: totalExpenses ?? this.totalExpenses,
      expenseCount: expenseCount ?? this.expenseCount,
      highestCategoryAmount: highestCategoryAmount ?? this.highestCategoryAmount,
      highestCategory: highestCategory ?? this.highestCategory,
      categoryBreakdown: categoryBreakdown ?? this.categoryBreakdown,
      monthlyTrend: monthlyTrend ?? this.monthlyTrend,
      monthlyLabels: monthlyLabels ?? this.monthlyLabels,
      topExpenses: topExpenses ?? this.topExpenses,
      month: month ?? this.month,
      year: year ?? this.year,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  int get categoryCount => categoryBreakdown.length;
  bool get hasData => totalExpenses > 0 || expenseCount > 0;
  double get averageExpense => expenseCount > 0 ? totalExpenses / expenseCount : 0;
}
