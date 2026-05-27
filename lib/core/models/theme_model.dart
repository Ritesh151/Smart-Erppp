import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'theme_model.g.dart';

@HiveType(typeId: 33)
class ThemeModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final int primaryColorValue;

  @HiveField(3)
  final int secondaryColorValue;

  @HiveField(4)
  final int surfaceColorValue;

  @HiveField(5)
  final bool isDark;

  @HiveField(6)
  final double borderRadius;

  @HiveField(7)
  final String fontFamily;

  @HiveField(8)
  final DateTime createdAt;

  ThemeModel({
    required this.id,
    required this.name,
    required this.primaryColorValue,
    required this.secondaryColorValue,
    required this.surfaceColorValue,
    required this.isDark,
    this.borderRadius = 8.0,
    this.fontFamily = 'Roboto',
    required this.createdAt,
  });

  factory ThemeModel.create({
    required String name,
    required Color primaryColor,
    required Color secondaryColor,
    required Color surfaceColor,
    bool isDark = false,
    double borderRadius = 8.0,
    String fontFamily = 'Roboto',
  }) {
    return ThemeModel(
      id: _generateId(),
      name: name,
      primaryColorValue: primaryColor.value,
      secondaryColorValue: secondaryColor.value,
      surfaceColorValue: surfaceColor.value,
      isDark: isDark,
      borderRadius: borderRadius,
      fontFamily: fontFamily,
      createdAt: DateTime.now(),
    );
  }

  static String _generateId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp % 10000).toString().padLeft(4, '0');
    return 'THM-$timestamp-$random';
  }

  Color get primaryColor => Color(primaryColorValue);
  Color get secondaryColor => Color(secondaryColorValue);
  Color get surfaceColor => Color(surfaceColorValue);

  Brightness get brightness => isDark ? Brightness.dark : Brightness.light;

  factory ThemeModel.fromJson(Map<String, dynamic> json) {
    return ThemeModel(
      id: json['id'] as String,
      name: json['name'] as String,
      primaryColorValue: (json['primaryColorValue'] as num).toInt(),
      secondaryColorValue: (json['secondaryColorValue'] as num).toInt(),
      surfaceColorValue: (json['surfaceColorValue'] as num).toInt(),
      isDark: json['isDark'] as bool? ?? false,
      borderRadius: (json['borderRadius'] as num?)?.toDouble() ?? 8.0,
      fontFamily: (json['fontFamily'] as String?) ?? 'Roboto',
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'primaryColorValue': primaryColorValue,
      'secondaryColorValue': secondaryColorValue,
      'surfaceColorValue': surfaceColorValue,
      'isDark': isDark,
      'borderRadius': borderRadius,
      'fontFamily': fontFamily,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  ThemeModel copyWith({
    String? id,
    String? name,
    int? primaryColorValue,
    int? secondaryColorValue,
    int? surfaceColorValue,
    bool? isDark,
    double? borderRadius,
    String? fontFamily,
    DateTime? createdAt,
  }) {
    return ThemeModel(
      id: id ?? this.id,
      name: name ?? this.name,
      primaryColorValue: primaryColorValue ?? this.primaryColorValue,
      secondaryColorValue: secondaryColorValue ?? this.secondaryColorValue,
      surfaceColorValue: surfaceColorValue ?? this.surfaceColorValue,
      isDark: isDark ?? this.isDark,
      borderRadius: borderRadius ?? this.borderRadius,
      fontFamily: fontFamily ?? this.fontFamily,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  static final ThemeModel light = ThemeModel.create(
    name: 'Light',
    primaryColor: const Color(0xFF1976D2),
    secondaryColor: const Color(0xFF424242),
    surfaceColor: Colors.white,
  );

  static final ThemeModel dark = ThemeModel.create(
    name: 'Dark',
    primaryColor: const Color(0xFF42A5F5),
    secondaryColor: const Color(0xFF78909C),
    surfaceColor: const Color(0xFF1E1E1E),
    isDark: true,
  );

  static final ThemeModel businessBlue = ThemeModel.create(
    name: 'Business Blue',
    primaryColor: const Color(0xFF1565C0),
    secondaryColor: const Color(0xFF37474F),
    surfaceColor: const Color(0xFFF5F7FA),
  );

  static final ThemeModel professionalGreen = ThemeModel.create(
    name: 'Professional Green',
    primaryColor: const Color(0xFF2E7D32),
    secondaryColor: const Color(0xFF455A64),
    surfaceColor: const Color(0xFFF1F8E9),
  );
}
