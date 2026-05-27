import 'package:hive/hive.dart';

part 'settings_model.g.dart';

@HiveType(typeId: 32)
class SettingsModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String companyName;

  @HiveField(2)
  final String? companyAddress;

  @HiveField(3)
  final String? companyPhone;

  @HiveField(4)
  final String? companyEmail;

  @HiveField(5)
  final String? taxId;

  @HiveField(6)
  final String? currencySymbol;

  @HiveField(7)
  final String dateFormat;

  @HiveField(8)
  final String timeFormat;

  @HiveField(9)
  final int lowStockThreshold;

  @HiveField(10)
  final bool salaryReminderEnabled;

  @HiveField(11)
  final bool autoBackupEnabled;

  @HiveField(12)
  final int autoBackupIntervalDays;

  @HiveField(13)
  final int maxBackupCount;

  @HiveField(14)
  final bool notificationsEnabled;

  @HiveField(15)
  final int defaultItemsPerPage;

  @HiveField(16)
  final bool sidebarCollapsed;

  @HiveField(17)
  final String language;

  @HiveField(18)
  final Map<String, dynamic> moduleSettings;

  @HiveField(19)
  final DateTime createdAt;

  @HiveField(20)
  final DateTime updatedAt;

  SettingsModel({
    required this.id,
    required this.companyName,
    this.companyAddress,
    this.companyPhone,
    this.companyEmail,
    this.taxId,
    this.currencySymbol = '₹',
    this.dateFormat = 'dd/MM/yyyy',
    this.timeFormat = 'HH:mm',
    this.lowStockThreshold = 10,
    this.salaryReminderEnabled = true,
    this.autoBackupEnabled = false,
    this.autoBackupIntervalDays = 7,
    this.maxBackupCount = 10,
    this.notificationsEnabled = true,
    this.defaultItemsPerPage = 20,
    this.sidebarCollapsed = false,
    this.language = 'en',
    this.moduleSettings = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  factory SettingsModel.create({
    required String companyName,
    String? companyAddress,
    String? companyPhone,
    String? companyEmail,
    String? taxId,
    String currencySymbol = '₹',
    String dateFormat = 'dd/MM/yyyy',
    String timeFormat = 'HH:mm',
    int lowStockThreshold = 10,
    bool salaryReminderEnabled = true,
    bool autoBackupEnabled = false,
    int autoBackupIntervalDays = 7,
    int maxBackupCount = 10,
    bool notificationsEnabled = true,
    int defaultItemsPerPage = 20,
    bool sidebarCollapsed = false,
    String language = 'en',
    Map<String, dynamic> moduleSettings = const {},
  }) {
    final now = DateTime.now();
    return SettingsModel(
      id: _generateId(),
      companyName: companyName,
      companyAddress: companyAddress,
      companyPhone: companyPhone,
      companyEmail: companyEmail,
      taxId: taxId,
      currencySymbol: currencySymbol,
      dateFormat: dateFormat,
      timeFormat: timeFormat,
      lowStockThreshold: lowStockThreshold,
      salaryReminderEnabled: salaryReminderEnabled,
      autoBackupEnabled: autoBackupEnabled,
      autoBackupIntervalDays: autoBackupIntervalDays,
      maxBackupCount: maxBackupCount,
      notificationsEnabled: notificationsEnabled,
      defaultItemsPerPage: defaultItemsPerPage,
      sidebarCollapsed: sidebarCollapsed,
      language: language,
      moduleSettings: moduleSettings,
      createdAt: now,
      updatedAt: now,
    );
  }

  static String _generateId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp % 10000).toString().padLeft(4, '0');
    return 'SET-$timestamp-$random';
  }

  factory SettingsModel.fromJson(Map<String, dynamic> json) {
    return SettingsModel(
      id: json['id'] as String,
      companyName: json['companyName'] as String,
      companyAddress: json['companyAddress'] as String?,
      companyPhone: json['companyPhone'] as String?,
      companyEmail: json['companyEmail'] as String?,
      taxId: json['taxId'] as String?,
      currencySymbol: (json['currencySymbol'] as String?) ?? '₹',
      dateFormat: (json['dateFormat'] as String?) ?? 'dd/MM/yyyy',
      timeFormat: (json['timeFormat'] as String?) ?? 'HH:mm',
      lowStockThreshold: (json['lowStockThreshold'] as num?)?.toInt() ?? 10,
      salaryReminderEnabled: (json['salaryReminderEnabled'] as bool?) ?? true,
      autoBackupEnabled: (json['autoBackupEnabled'] as bool?) ?? false,
      autoBackupIntervalDays: (json['autoBackupIntervalDays'] as num?)?.toInt() ?? 7,
      maxBackupCount: (json['maxBackupCount'] as num?)?.toInt() ?? 10,
      notificationsEnabled: (json['notificationsEnabled'] as bool?) ?? true,
      defaultItemsPerPage: (json['defaultItemsPerPage'] as num?)?.toInt() ?? 20,
      sidebarCollapsed: (json['sidebarCollapsed'] as bool?) ?? false,
      language: (json['language'] as String?) ?? 'en',
      moduleSettings: json['moduleSettings'] != null
          ? Map<String, dynamic>.from(json['moduleSettings'] as Map)
          : {},
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'companyName': companyName,
      'companyAddress': companyAddress,
      'companyPhone': companyPhone,
      'companyEmail': companyEmail,
      'taxId': taxId,
      'currencySymbol': currencySymbol,
      'dateFormat': dateFormat,
      'timeFormat': timeFormat,
      'lowStockThreshold': lowStockThreshold,
      'salaryReminderEnabled': salaryReminderEnabled,
      'autoBackupEnabled': autoBackupEnabled,
      'autoBackupIntervalDays': autoBackupIntervalDays,
      'maxBackupCount': maxBackupCount,
      'notificationsEnabled': notificationsEnabled,
      'defaultItemsPerPage': defaultItemsPerPage,
      'sidebarCollapsed': sidebarCollapsed,
      'language': language,
      'moduleSettings': moduleSettings,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  SettingsModel copyWith({
    String? id,
    String? companyName,
    String? companyAddress,
    String? companyPhone,
    String? companyEmail,
    String? taxId,
    String? currencySymbol,
    String? dateFormat,
    String? timeFormat,
    int? lowStockThreshold,
    bool? salaryReminderEnabled,
    bool? autoBackupEnabled,
    int? autoBackupIntervalDays,
    int? maxBackupCount,
    bool? notificationsEnabled,
    int? defaultItemsPerPage,
    bool? sidebarCollapsed,
    String? language,
    Map<String, dynamic>? moduleSettings,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SettingsModel(
      id: id ?? this.id,
      companyName: companyName ?? this.companyName,
      companyAddress: companyAddress ?? this.companyAddress,
      companyPhone: companyPhone ?? this.companyPhone,
      companyEmail: companyEmail ?? this.companyEmail,
      taxId: taxId ?? this.taxId,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      dateFormat: dateFormat ?? this.dateFormat,
      timeFormat: timeFormat ?? this.timeFormat,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
      salaryReminderEnabled: salaryReminderEnabled ?? this.salaryReminderEnabled,
      autoBackupEnabled: autoBackupEnabled ?? this.autoBackupEnabled,
      autoBackupIntervalDays: autoBackupIntervalDays ?? this.autoBackupIntervalDays,
      maxBackupCount: maxBackupCount ?? this.maxBackupCount,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      defaultItemsPerPage: defaultItemsPerPage ?? this.defaultItemsPerPage,
      sidebarCollapsed: sidebarCollapsed ?? this.sidebarCollapsed,
      language: language ?? this.language,
      moduleSettings: moduleSettings ?? this.moduleSettings,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get moduleSettingValue {
    final count = moduleSettings.length;
    return '$count custom settings';
  }

  bool get hasCompanyInfo =>
      companyName.isNotEmpty &&
      (companyAddress != null || companyPhone != null || companyEmail != null);

  bool get dateFormatValid => dateFormat.isNotEmpty && dateFormat.length >= 5;
}
