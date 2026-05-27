import 'package:flutter/material.dart';

class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  final Color? sidebarBackground;
  final Color? sidebarItemActive;
  final Color? sidebarItemHover;
  final Color? sidebarItemText;
  final Color? sidebarItemActiveText;
  final Color? cardBackground;
  final Color? cardBorder;
  final Color? tableHeaderBackground;
  final Color? tableRowEven;
  final Color? tableRowOdd;
  final Color? successColor;
  final Color? warningColor;
  final Color? infoColor;
  final Color? errorColor;
  final double? sidebarWidth;
  final double? sidebarCollapsedWidth;
  final double? cardElevation;
  final double? cardBorderRadius;
  final EdgeInsets? cardPadding;
  final EdgeInsets? contentPadding;

  const AppThemeExtension({
    this.sidebarBackground,
    this.sidebarItemActive,
    this.sidebarItemHover,
    this.sidebarItemText,
    this.sidebarItemActiveText,
    this.cardBackground,
    this.cardBorder,
    this.tableHeaderBackground,
    this.tableRowEven,
    this.tableRowOdd,
    this.successColor,
    this.warningColor,
    this.infoColor,
    this.errorColor,
    this.sidebarWidth,
    this.sidebarCollapsedWidth,
    this.cardElevation,
    this.cardBorderRadius,
    this.cardPadding,
    this.contentPadding,
  });

  factory AppThemeExtension.light() {
    return const AppThemeExtension(
      sidebarBackground: Color(0xFFFFFFFF),
      sidebarItemActive: Color(0xFF1976D2),
      sidebarItemHover: Color(0xFFF5F5F5),
      sidebarItemText: Color(0xFF616161),
      sidebarItemActiveText: Color(0xFFFFFFFF),
      cardBackground: Color(0xFFFFFFFF),
      cardBorder: Color(0xFFE0E0E0),
      tableHeaderBackground: Color(0xFFF5F5F5),
      tableRowEven: Color(0xFFFFFFFF),
      tableRowOdd: Color(0xFFFAFAFA),
      successColor: Color(0xFF4CAF50),
      warningColor: Color(0xFFFF9800),
      infoColor: Color(0xFF2196F3),
      errorColor: Color(0xFFD32F2F),
      sidebarWidth: 260.0,
      sidebarCollapsedWidth: 70.0,
      cardElevation: 2.0,
      cardBorderRadius: 8.0,
      cardPadding: EdgeInsets.all(16.0),
      contentPadding: EdgeInsets.all(24.0),
    );
  }

  factory AppThemeExtension.dark() {
    return const AppThemeExtension(
      sidebarBackground: Color(0xFF1E1E1E),
      sidebarItemActive: Color(0xFF42A5F5),
      sidebarItemHover: Color(0xFF2C2C2C),
      sidebarItemText: Color(0xFFB0B0B0),
      sidebarItemActiveText: Color(0xFF000000),
      cardBackground: Color(0xFF2C2C2C),
      cardBorder: Color(0xFF424242),
      tableHeaderBackground: Color(0xFF1E1E1E),
      tableRowEven: Color(0xFF2C2C2C),
      tableRowOdd: Color(0xFF242424),
      successColor: Color(0xFF66BB6A),
      warningColor: Color(0xFFFFA726),
      infoColor: Color(0xFF42A5F5),
      errorColor: Color(0xFFEF5350),
      sidebarWidth: 260.0,
      sidebarCollapsedWidth: 70.0,
      cardElevation: 2.0,
      cardBorderRadius: 8.0,
      cardPadding: EdgeInsets.all(16.0),
      contentPadding: EdgeInsets.all(24.0),
    );
  }

  factory AppThemeExtension.businessBlue() {
    return const AppThemeExtension(
      sidebarBackground: Color(0xFF0D47A1),
      sidebarItemActive: Color(0xFF1565C0),
      sidebarItemHover: Color(0xFF1565C0),
      sidebarItemText: Color(0xFFBBDEFB),
      sidebarItemActiveText: Color(0xFFFFFFFF),
      cardBackground: Color(0xFFFFFFFF),
      cardBorder: Color(0xFFBBDEFB),
      tableHeaderBackground: Color(0xFFE3F2FD),
      tableRowEven: Color(0xFFFFFFFF),
      tableRowOdd: Color(0xFFF5F5F5),
      successColor: Color(0xFF4CAF50),
      warningColor: Color(0xFFFF9800),
      infoColor: Color(0xFF0277BD),
      errorColor: Color(0xFFD32F2F),
      sidebarWidth: 260.0,
      sidebarCollapsedWidth: 70.0,
      cardElevation: 2.0,
      cardBorderRadius: 8.0,
      cardPadding: EdgeInsets.all(16.0),
      contentPadding: EdgeInsets.all(24.0),
    );
  }

  factory AppThemeExtension.professionalGreen() {
    return const AppThemeExtension(
      sidebarBackground: Color(0xFF2E7D32),
      sidebarItemActive: Color(0xFF388E3C),
      sidebarItemHover: Color(0xFF388E3C),
      sidebarItemText: Color(0xFFC8E6C9),
      sidebarItemActiveText: Color(0xFFFFFFFF),
      cardBackground: Color(0xFFFFFFFF),
      cardBorder: Color(0xFFC8E6C9),
      tableHeaderBackground: Color(0xFFE8F5E9),
      tableRowEven: Color(0xFFFFFFFF),
      tableRowOdd: Color(0xFFF5F5F5),
      successColor: Color(0xFF66BB6A),
      warningColor: Color(0xFFFF9800),
      infoColor: Color(0xFF00695C),
      errorColor: Color(0xFFD32F2F),
      sidebarWidth: 260.0,
      sidebarCollapsedWidth: 70.0,
      cardElevation: 2.0,
      cardBorderRadius: 8.0,
      cardPadding: EdgeInsets.all(16.0),
      contentPadding: EdgeInsets.all(24.0),
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
    Color? tableHeaderBackground,
    Color? tableRowEven,
    Color? tableRowOdd,
    Color? successColor,
    Color? warningColor,
    Color? infoColor,
    Color? errorColor,
    double? sidebarWidth,
    double? sidebarCollapsedWidth,
    double? cardElevation,
    double? cardBorderRadius,
    EdgeInsets? cardPadding,
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
      tableHeaderBackground: tableHeaderBackground ?? this.tableHeaderBackground,
      tableRowEven: tableRowEven ?? this.tableRowEven,
      tableRowOdd: tableRowOdd ?? this.tableRowOdd,
      successColor: successColor ?? this.successColor,
      warningColor: warningColor ?? this.warningColor,
      infoColor: infoColor ?? this.infoColor,
      errorColor: errorColor ?? this.errorColor,
      sidebarWidth: sidebarWidth ?? this.sidebarWidth,
      sidebarCollapsedWidth: sidebarCollapsedWidth ?? this.sidebarCollapsedWidth,
      cardElevation: cardElevation ?? this.cardElevation,
      cardBorderRadius: cardBorderRadius ?? this.cardBorderRadius,
      cardPadding: cardPadding ?? this.cardPadding,
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
      tableHeaderBackground: Color.lerp(tableHeaderBackground, other.tableHeaderBackground, t),
      tableRowEven: Color.lerp(tableRowEven, other.tableRowEven, t),
      tableRowOdd: Color.lerp(tableRowOdd, other.tableRowOdd, t),
      successColor: Color.lerp(successColor, other.successColor, t),
      warningColor: Color.lerp(warningColor, other.warningColor, t),
      infoColor: Color.lerp(infoColor, other.infoColor, t),
      errorColor: Color.lerp(errorColor, other.errorColor, t),
    );
  }
}

extension ThemeExtensionGetter on BuildContext {
  AppThemeExtension get appTheme {
    return Theme.of(this).extension<AppThemeExtension>() ?? AppThemeExtension.light();
  }
}
