import 'package:hive/hive.dart';
import 'report_enums.dart';

part 'report_model.g.dart';

@HiveType(typeId: 23)
class ReportModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final ReportType type;

  @HiveField(2)
  final String title;

  @HiveField(3)
  final DateTime fromDate;

  @HiveField(4)
  final DateTime toDate;

  @HiveField(5)
  final ReportPeriod period;

  @HiveField(6)
  final DateTime generatedAt;

  @HiveField(7)
  final Map<String, dynamic>? filters;

  @HiveField(8)
  final String? notes;

  ReportModel({
    required this.id,
    required this.type,
    required this.title,
    required this.fromDate,
    required this.toDate,
    required this.period,
    required this.generatedAt,
    this.filters,
    this.notes,
  });

  factory ReportModel.create({
    required ReportType type,
    required String title,
    required DateTime fromDate,
    required DateTime toDate,
    required ReportPeriod period,
    Map<String, dynamic>? filters,
    String? notes,
  }) {
    return ReportModel(
      id: _generateId(type),
      type: type,
      title: title,
      fromDate: fromDate,
      toDate: toDate,
      period: period,
      generatedAt: DateTime.now(),
      filters: filters,
      notes: notes,
    );
  }

  static String _generateId(ReportType type) {
    final prefix = type.name.substring(0, 3).toUpperCase();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp % 10000).toString().padLeft(4, '0');
    return 'RPT-$prefix-$timestamp-$random';
  }

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      id: json['id'] as String,
      type: ReportType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ReportType.sales,
      ),
      title: json['title'] as String,
      fromDate: DateTime.parse(json['fromDate'] as String),
      toDate: DateTime.parse(json['toDate'] as String),
      period: ReportPeriod.values.firstWhere(
        (e) => e.name == json['period'],
        orElse: () => ReportPeriod.monthly,
      ),
      generatedAt: DateTime.parse(json['generatedAt'] as String),
      filters: json['filters'] != null
          ? Map<String, dynamic>.from(json['filters'] as Map)
          : null,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'title': title,
      'fromDate': fromDate.toIso8601String(),
      'toDate': toDate.toIso8601String(),
      'period': period.name,
      'generatedAt': generatedAt.toIso8601String(),
      'filters': filters,
      'notes': notes,
    };
  }

  ReportModel copyWith({
    String? id,
    ReportType? type,
    String? title,
    DateTime? fromDate,
    DateTime? toDate,
    ReportPeriod? period,
    DateTime? generatedAt,
    Map<String, dynamic>? filters,
    String? notes,
  }) {
    return ReportModel(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
      period: period ?? this.period,
      generatedAt: generatedAt ?? this.generatedAt,
      filters: filters ?? this.filters,
      notes: notes ?? this.notes,
    );
  }

  Duration get dateRange => toDate.difference(fromDate);
  int get daysInRange => dateRange.inDays;
  bool get isCurrentMonth {
    final now = DateTime.now();
    return fromDate.month == now.month && fromDate.year == now.year;
  }
}
