import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  final Color? sidebarBackground;
  final Color? sidebarItemActive;
  final Color? sidebarItemHover;
  final Color? sidebarItemText;
  final Color? sidebarItemActiveText;
  final Color? cardBackground;
  final Color? cardBorder;
  final double? cardElevation;
  final double? cardBorderRadius;
  final EdgeInsets? cardPadding;
  final Color? tableHeaderBackground;
  final Color? tableRowEven;
  final Color? tableRowOdd;
  final Color? successColor;
  final Color? warningColor;
  final Color? infoColor;
  final Color? errorColor;
  final double? sidebarWidth;
  final double? sidebarCollapsedWidth;
  final EdgeInsets? contentPadding;

  const AppThemeExtension({
    this.sidebarBackground,
    this.sidebarItemActive,
    this.sidebarItemHover,
    this.sidebarItemText,
    this.sidebarItemActiveText,
    this.cardBackground,
    this.cardBorder,
    this.cardElevation,
    this.cardBorderRadius,
    this.cardPadding,
    this.tableHeaderBackground,
    this.tableRowEven,
    this.tableRowOdd,
    this.successColor,
    this.warningColor,
    this.infoColor,
    this.errorColor,
    this.sidebarWidth,
    this.sidebarCollapsedWidth,
    this.contentPadding,
  });

  factory AppThemeExtension.light() {
    return const AppThemeExtension(
      sidebarBackground: Color(0xFF1E293B),
      sidebarItemActive: Color(0xFF1976D2),
      sidebarItemHover: Color(0xFF334155),
      sidebarItemText: Color(0xFF94A3B8),
      sidebarItemActiveText: Colors.white,
      cardBackground: Colors.white,
      cardBorder: Color(0xFFE2E8F0),
      cardElevation: 2.0,
      cardBorderRadius: 12.0,
      cardPadding: EdgeInsets.all(16.0),
      tableHeaderBackground: Color(0xFFF8FAFC),
      tableRowEven: Colors.white,
      tableRowOdd: Color(0xFFF8FAFC),
      successColor: Color(0xFF22C55E),
      warningColor: Color(0xFFF59E0B),
      infoColor: Color(0xFF3B82F6),
      errorColor: Color(0xFFEF4444),
      sidebarWidth: 280.0,
      sidebarCollapsedWidth: 72.0,
      contentPadding: EdgeInsets.all(24.0),
    );
  }

  factory AppThemeExtension.dark() {
    return const AppThemeExtension(
      sidebarBackground: Color(0xFF0F172A),
      sidebarItemActive: Color(0xFF42A5F5),
      sidebarItemHover: Color(0xFF1E293B),
      sidebarItemText: Color(0xFF64748B),
      sidebarItemActiveText: Colors.white,
      cardBackground: Color(0xFF1E1E1E),
      cardBorder: Color(0xFF334155),
      cardElevation: 2.0,
      cardBorderRadius: 12.0,
      cardPadding: EdgeInsets.all(16.0),
      tableHeaderBackground: Color(0xFF1A1A2E),
      tableRowEven: Color(0xFF1E1E1E),
      tableRowOdd: Color(0xFF2C2C2C),
      successColor: Color(0xFF4CAF50),
      warningColor: Color(0xFFFF9800),
      infoColor: Color(0xFF2196F3),
      errorColor: Color(0xFFF44336),
      sidebarWidth: 280.0,
      sidebarCollapsedWidth: 72.0,
      contentPadding: EdgeInsets.all(16.0),
    );
  }

  factory AppThemeExtension.businessBlue() {
    return const AppThemeExtension(
      sidebarBackground: Color(0xFF0D47A1),
      sidebarItemActive: Color(0xFF1565C0),
      sidebarItemHover: Color(0xFF0D47A1),
      sidebarItemText: Color(0xFF90CAF9),
      sidebarItemActiveText: Colors.white,
      cardBackground: Colors.white,
      cardBorder: Color(0xFFBBDEFB),
      cardElevation: 3.0,
      cardBorderRadius: 8.0,
      cardPadding: EdgeInsets.all(16.0),
      tableHeaderBackground: Color(0xFFE3F2FD),
      tableRowEven: Colors.white,
      tableRowOdd: Color(0xFFF5F9FF),
      successColor: Color(0xFF4CAF50),
      warningColor: Color(0xFFFF9800),
      infoColor: Color(0xFF2196F3),
      errorColor: Color(0xFFF44336),
      sidebarWidth: 280.0,
      sidebarCollapsedWidth: 72.0,
      contentPadding: EdgeInsets.all(20.0),
    );
  }

  factory AppThemeExtension.professionalGreen() {
    return const AppThemeExtension(
      sidebarBackground: Color(0xFF1B5E20),
      sidebarItemActive: Color(0xFF2E7D32),
      sidebarItemHover: Color(0xFF1B5E20),
      sidebarItemText: Color(0xFFA5D6A7),
      sidebarItemActiveText: Colors.white,
      cardBackground: Colors.white,
      cardBorder: Color(0xFFC8E6C9),
      cardElevation: 2.0,
      cardBorderRadius: 10.0,
      cardPadding: EdgeInsets.all(16.0),
      tableHeaderBackground: Color(0xFFE8F5E9),
      tableRowEven: Colors.white,
      tableRowOdd: Color(0xFFF1F8E9),
      successColor: Color(0xFF66BB6A),
      warningColor: Color(0xFFFFA726),
      infoColor: Color(0xFF29B6F6),
      errorColor: Color(0xFFEF5350),
      sidebarWidth: 280.0,
      sidebarCollapsedWidth: 72.0,
      contentPadding: EdgeInsets.all(20.0),
    );
  }

  @override
  ThemeExtension<AppThemeExtension> copyWith({
    Color? sidebarBackground,
    Color? sidebarItemActive,
    Color? sidebarItemHover,
    Color? sidebarItemText,
    Color? sidebarItemActiveText,
    Color? cardBackground,
    Color? cardBorder,
    double? cardElevation,
    double? cardBorderRadius,
    EdgeInsets? cardPadding,
    Color? tableHeaderBackground,
    Color? tableRowEven,
    Color? tableRowOdd,
    Color? successColor,
    Color? warningColor,
    Color? infoColor,
    Color? errorColor,
    double? sidebarWidth,
    double? sidebarCollapsedWidth,
    EdgeInsets? contentPadding,
  }) {
    return AppThemeExtension(
      sidebarBackground: sidebarBackground ?? this.sidebarBackground,
      sidebarItemActive: sidebarItemActive ?? this.sidebarItemActive,
      sidebarItemHover: sidebarItemHover ?? this.sidebarItemHover,
      sidebarItemText: sidebarItemText ?? this.sidebarItemText,
      sidebarItemActiveText: sidebarItemActiveText ?? this.sidebarItemActiveText,
      cardBackground: cardBackground ?? this.cardBackground,
      cardBorder: cardBorder ?? this.cardBorder,
      cardElevation: cardElevation ?? this.cardElevation,
      cardBorderRadius: cardBorderRadius ?? this.cardBorderRadius,
      cardPadding: cardPadding ?? this.cardPadding,
      tableHeaderBackground: tableHeaderBackground ?? this.tableHeaderBackground,
      tableRowEven: tableRowEven ?? this.tableRowEven,
      tableRowOdd: tableRowOdd ?? this.tableRowOdd,
      successColor: successColor ?? this.successColor,
      warningColor: warningColor ?? this.warningColor,
      infoColor: infoColor ?? this.infoColor,
      errorColor: errorColor ?? this.errorColor,
      sidebarWidth: sidebarWidth ?? this.sidebarWidth,
      sidebarCollapsedWidth: sidebarCollapsedWidth ?? this.sidebarCollapsedWidth,
      contentPadding: contentPadding ?? this.contentPadding,
    );
  }

  @override
  ThemeExtension<AppThemeExtension> lerp(
    ThemeExtension<AppThemeExtension>? other,
    double t,
  ) {
    if (other is! AppThemeExtension) {
      return this;
    }

    return AppThemeExtension(
      sidebarBackground: Color.lerp(sidebarBackground, other.sidebarBackground, t),
      sidebarItemActive: Color.lerp(sidebarItemActive, other.sidebarItemActive, t),
      sidebarItemHover: Color.lerp(sidebarItemHover, other.sidebarItemHover, t),
      sidebarItemText: Color.lerp(sidebarItemText, other.sidebarItemText, t),
      sidebarItemActiveText: Color.lerp(sidebarItemActiveText, other.sidebarItemActiveText, t),
      cardBackground: Color.lerp(cardBackground, other.cardBackground, t),
      cardBorder: Color.lerp(cardBorder, other.cardBorder, t),
      cardElevation: ui.lerpDouble(cardElevation, other.cardElevation, t),
      cardBorderRadius: ui.lerpDouble(cardBorderRadius, other.cardBorderRadius, t),
      tableHeaderBackground: Color.lerp(tableHeaderBackground, other.tableHeaderBackground, t),
      tableRowEven: Color.lerp(tableRowEven, other.tableRowEven, t),
      tableRowOdd: Color.lerp(tableRowOdd, other.tableRowOdd, t),
      successColor: Color.lerp(successColor, other.successColor, t),
      warningColor: Color.lerp(warningColor, other.warningColor, t),
      infoColor: Color.lerp(infoColor, other.infoColor, t),
      errorColor: Color.lerp(errorColor, other.errorColor, t),
      sidebarWidth: ui.lerpDouble(sidebarWidth, other.sidebarWidth, t),
      sidebarCollapsedWidth: ui.lerpDouble(sidebarCollapsedWidth, other.sidebarCollapsedWidth, t),
    );
  }
}

extension ThemeExtensionGetter on BuildContext {
  AppThemeExtension get appTheme {
    return Theme.of(this).extension<AppThemeExtension>() ?? AppThemeExtension.light();
  }
}
