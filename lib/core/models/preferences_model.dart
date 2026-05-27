import 'package:hive/hive.dart';

part 'preferences_model.g.dart';

@HiveType(typeId: 36)
class PreferencesModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final String themeName;

  @HiveField(3)
  final bool sidebarCollapsed;

  @HiveField(4)
  final String dateFormat;

  @HiveField(5)
  final String timeFormat;

  @HiveField(6)
  final String language;

  @HiveField(7)
  final int itemsPerPage;

  @HiveField(8)
  final bool notificationsEnabled;

  @HiveField(9)
  final bool lowStockAlertsEnabled;

  @HiveField(10)
  final bool salaryRemindersEnabled;

  @HiveField(11)
  final int lowStockThreshold;

  @HiveField(12)
  final List<String> favoriteModules;

  @HiveField(13)
  final String? lastUsedModule;

  @HiveField(14)
  final Map<String, dynamic> modulePreferences;

  @HiveField(15)
  final DateTime createdAt;

  @HiveField(16)
  final DateTime updatedAt;

  PreferencesModel({
    required this.id,
    required this.userId,
    this.themeName = 'light',
    this.sidebarCollapsed = false,
    this.dateFormat = 'dd/MM/yyyy',
    this.timeFormat = 'HH:mm',
    this.language = 'en',
    this.itemsPerPage = 20,
    this.notificationsEnabled = true,
    this.lowStockAlertsEnabled = true,
    this.salaryRemindersEnabled = true,
    this.lowStockThreshold = 10,
    this.favoriteModules = const [],
    this.lastUsedModule,
    this.modulePreferences = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  factory PreferencesModel.create({
    required String userId,
    String themeName = 'light',
    bool sidebarCollapsed = false,
    String dateFormat = 'dd/MM/yyyy',
    String timeFormat = 'HH:mm',
    String language = 'en',
    int itemsPerPage = 20,
    bool notificationsEnabled = true,
    bool lowStockAlertsEnabled = true,
    bool salaryRemindersEnabled = true,
    int lowStockThreshold = 10,
    List<String> favoriteModules = const [],
    String? lastUsedModule,
    Map<String, dynamic> modulePreferences = const {},
  }) {
    final now = DateTime.now();
    return PreferencesModel(
      id: _generateId(),
      userId: userId,
      themeName: themeName,
      sidebarCollapsed: sidebarCollapsed,
      dateFormat: dateFormat,
      timeFormat: timeFormat,
      language: language,
      itemsPerPage: itemsPerPage,
      notificationsEnabled: notificationsEnabled,
      lowStockAlertsEnabled: lowStockAlertsEnabled,
      salaryRemindersEnabled: salaryRemindersEnabled,
      lowStockThreshold: lowStockThreshold,
      favoriteModules: favoriteModules,
      lastUsedModule: lastUsedModule,
      modulePreferences: modulePreferences,
      createdAt: now,
      updatedAt: now,
    );
  }

  static String _generateId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp % 10000).toString().padLeft(4, '0');
    return 'PREF-$timestamp-$random';
  }

  factory PreferencesModel.fromJson(Map<String, dynamic> json) {
    return PreferencesModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      themeName: (json['themeName'] as String?) ?? 'light',
      sidebarCollapsed: json['sidebarCollapsed'] as bool? ?? false,
      dateFormat: (json['dateFormat'] as String?) ?? 'dd/MM/yyyy',
      timeFormat: (json['timeFormat'] as String?) ?? 'HH:mm',
      language: (json['language'] as String?) ?? 'en',
      itemsPerPage: (json['itemsPerPage'] as num?)?.toInt() ?? 20,
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      lowStockAlertsEnabled: json['lowStockAlertsEnabled'] as bool? ?? true,
      salaryRemindersEnabled: json['salaryRemindersEnabled'] as bool? ?? true,
      lowStockThreshold: (json['lowStockThreshold'] as num?)?.toInt() ?? 10,
      favoriteModules: (json['favoriteModules'] as List<dynamic>?)
              ?.cast<String>()
              .toList() ??
          [],
      lastUsedModule: json['lastUsedModule'] as String?,
      modulePreferences: json['modulePreferences'] != null
          ? Map<String, dynamic>.from(json['modulePreferences'] as Map)
          : {},
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'themeName': themeName,
      'sidebarCollapsed': sidebarCollapsed,
      'dateFormat': dateFormat,
      'timeFormat': timeFormat,
      'language': language,
      'itemsPerPage': itemsPerPage,
      'notificationsEnabled': notificationsEnabled,
      'lowStockAlertsEnabled': lowStockAlertsEnabled,
      'salaryRemindersEnabled': salaryRemindersEnabled,
      'lowStockThreshold': lowStockThreshold,
      'favoriteModules': favoriteModules,
      'lastUsedModule': lastUsedModule,
      'modulePreferences': modulePreferences,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  PreferencesModel copyWith({
    String? id,
    String? userId,
    String? themeName,
    bool? sidebarCollapsed,
    String? dateFormat,
    String? timeFormat,
    String? language,
    int? itemsPerPage,
    bool? notificationsEnabled,
    bool? lowStockAlertsEnabled,
    bool? salaryRemindersEnabled,
    int? lowStockThreshold,
    List<String>? favoriteModules,
    String? lastUsedModule,
    Map<String, dynamic>? modulePreferences,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PreferencesModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      themeName: themeName ?? this.themeName,
      sidebarCollapsed: sidebarCollapsed ?? this.sidebarCollapsed,
      dateFormat: dateFormat ?? this.dateFormat,
      timeFormat: timeFormat ?? this.timeFormat,
      language: language ?? this.language,
      itemsPerPage: itemsPerPage ?? this.itemsPerPage,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      lowStockAlertsEnabled: lowStockAlertsEnabled ?? this.lowStockAlertsEnabled,
      salaryRemindersEnabled: salaryRemindersEnabled ?? this.salaryRemindersEnabled,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
      favoriteModules: favoriteModules ?? this.favoriteModules,
      lastUsedModule: lastUsedModule ?? this.lastUsedModule,
      modulePreferences: modulePreferences ?? this.modulePreferences,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  int get favoriteCount => favoriteModules.length;

  bool isModuleFavorite(String moduleName) => favoriteModules.contains(moduleName);

  PreferencesModel toggleFavorite(String moduleName) {
    if (isModuleFavorite(moduleName)) {
      return copyWith(
        favoriteModules: favoriteModules.where((m) => m != moduleName).toList(),
        updatedAt: DateTime.now(),
      );
    }
    return copyWith(
      favoriteModules: [...favoriteModules, moduleName],
      updatedAt: DateTime.now(),
    );
  }

  bool get hasValidDateFormat => dateFormat.isNotEmpty;
  bool get hasValidLanguage => language.length >= 2;
}
