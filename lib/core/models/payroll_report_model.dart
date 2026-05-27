import 'package:hive/hive.dart';

part 'payroll_report_model.g.dart';

@HiveType(typeId: 29)
class PayrollReportModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String reportId;

  @HiveField(2)
  final int totalEmployees;

  @HiveField(3)
  final int activeEmployees;

  @HiveField(4)
  final double totalSalaryPayable;

  @HiveField(5)
  final double totalSalaryPaid;

  @HiveField(6)
  final double totalSalaryPending;

  @HiveField(7)
  final int paidCount;

  @HiveField(8)
  final int pendingCount;

  @HiveField(9)
  final int partiallyPaidCount;

  @HiveField(10)
  final double attendanceRate;

  @HiveField(11)
  final List<double> salaryTrend;

  @HiveField(12)
  final List<String> trendLabels;

  @HiveField(13)
  final Map<String, int> departmentDistribution;

  @HiveField(14)
  final List<Map<String, dynamic>> topEarners;

  @HiveField(15)
  final int month;

  @HiveField(16)
  final int year;

  @HiveField(17)
  final DateTime createdAt;

  PayrollReportModel({
    required this.id,
    required this.reportId,
    required this.totalEmployees,
    this.activeEmployees = 0,
    required this.totalSalaryPayable,
    required this.totalSalaryPaid,
    required this.totalSalaryPending,
    this.paidCount = 0,
    this.pendingCount = 0,
    this.partiallyPaidCount = 0,
    this.attendanceRate = 0,
    this.salaryTrend = const [],
    this.trendLabels = const [],
    this.departmentDistribution = const {},
    this.topEarners = const [],
    required this.month,
    required this.year,
    required this.createdAt,
  });

  factory PayrollReportModel.create({
    required String reportId,
    required int totalEmployees,
    int activeEmployees = 0,
    required double totalSalaryPayable,
    required double totalSalaryPaid,
    required double totalSalaryPending,
    int paidCount = 0,
    int pendingCount = 0,
    int partiallyPaidCount = 0,
    double attendanceRate = 0,
    List<double> salaryTrend = const [],
    List<String> trendLabels = const [],
    Map<String, int> departmentDistribution = const {},
    List<Map<String, dynamic>> topEarners = const [],
    required int month,
    required int year,
  }) {
    return PayrollReportModel(
      id: _generateId(),
      reportId: reportId,
      totalEmployees: totalEmployees,
      activeEmployees: activeEmployees,
      totalSalaryPayable: totalSalaryPayable,
      totalSalaryPaid: totalSalaryPaid,
      totalSalaryPending: totalSalaryPending,
      paidCount: paidCount,
      pendingCount: pendingCount,
      partiallyPaidCount: partiallyPaidCount,
      attendanceRate: attendanceRate,
      salaryTrend: salaryTrend,
      trendLabels: trendLabels,
      departmentDistribution: departmentDistribution,
      topEarners: topEarners,
      month: month,
      year: year,
      createdAt: DateTime.now(),
    );
  }

  static String _generateId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp % 10000).toString().padLeft(4, '0');
    return 'PYR-$timestamp-$random';
  }

  factory PayrollReportModel.fromJson(Map<String, dynamic> json) {
    return PayrollReportModel(
      id: json['id'] as String,
      reportId: json['reportId'] as String,
      totalEmployees: json['totalEmployees'] as int,
      activeEmployees: json['activeEmployees'] as int? ?? 0,
      totalSalaryPayable: (json['totalSalaryPayable'] as num).toDouble(),
      totalSalaryPaid: (json['totalSalaryPaid'] as num).toDouble(),
      totalSalaryPending: (json['totalSalaryPending'] as num).toDouble(),
      paidCount: json['paidCount'] as int? ?? 0,
      pendingCount: json['pendingCount'] as int? ?? 0,
      partiallyPaidCount: json['partiallyPaidCount'] as int? ?? 0,
      attendanceRate: (json['attendanceRate'] as num?)?.toDouble() ?? 0,
      salaryTrend: (json['salaryTrend'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          [],
      trendLabels: (json['trendLabels'] as List<dynamic>?)
              ?.cast<String>()
              .toList() ??
          [],
      departmentDistribution: json['departmentDistribution'] != null
          ? Map<String, int>.from(
              (json['departmentDistribution'] as Map).map(
                (k, v) => MapEntry(k as String, (v as num).toInt()),
              ),
            )
          : {},
      topEarners: (json['topEarners'] as List<dynamic>?)
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
      'totalEmployees': totalEmployees,
      'activeEmployees': activeEmployees,
      'totalSalaryPayable': totalSalaryPayable,
      'totalSalaryPaid': totalSalaryPaid,
      'totalSalaryPending': totalSalaryPending,
      'paidCount': paidCount,
      'pendingCount': pendingCount,
      'partiallyPaidCount': partiallyPaidCount,
      'attendanceRate': attendanceRate,
      'salaryTrend': salaryTrend,
      'trendLabels': trendLabels,
      'departmentDistribution': departmentDistribution,
      'topEarners': topEarners,
      'month': month,
      'year': year,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  PayrollReportModel copyWith({
    String? id,
    String? reportId,
    int? totalEmployees,
    int? activeEmployees,
    double? totalSalaryPayable,
    double? totalSalaryPaid,
    double? totalSalaryPending,
    int? paidCount,
    int? pendingCount,
    int? partiallyPaidCount,
    double? attendanceRate,
    List<double>? salaryTrend,
    List<String>? trendLabels,
    Map<String, int>? departmentDistribution,
    List<Map<String, dynamic>>? topEarners,
    int? month,
    int? year,
    DateTime? createdAt,
  }) {
    return PayrollReportModel(
      id: id ?? this.id,
      reportId: reportId ?? this.reportId,
      totalEmployees: totalEmployees ?? this.totalEmployees,
      activeEmployees: activeEmployees ?? this.activeEmployees,
      totalSalaryPayable: totalSalaryPayable ?? this.totalSalaryPayable,
      totalSalaryPaid: totalSalaryPaid ?? this.totalSalaryPaid,
      totalSalaryPending: totalSalaryPending ?? this.totalSalaryPending,
      paidCount: paidCount ?? this.paidCount,
      pendingCount: pendingCount ?? this.pendingCount,
      partiallyPaidCount: partiallyPaidCount ?? this.partiallyPaidCount,
      attendanceRate: attendanceRate ?? this.attendanceRate,
      salaryTrend: salaryTrend ?? this.salaryTrend,
      trendLabels: trendLabels ?? this.trendLabels,
      departmentDistribution: departmentDistribution ?? this.departmentDistribution,
      topEarners: topEarners ?? this.topEarners,
      month: month ?? this.month,
      year: year ?? this.year,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  double get paymentRate =>
      totalSalaryPayable > 0 ? (totalSalaryPaid / totalSalaryPayable) * 100 : 0;

  double get averageSalary =>
      totalEmployees > 0 ? totalSalaryPayable / totalEmployees : 0;

  bool get hasData => totalEmployees > 0;
  bool get isFullyPaid => totalSalaryPending <= 0;
}
