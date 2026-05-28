import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:SmartERP/core/theme/theme_extensions.dart';

enum AppThemeMode {
  light,
  dark,
  businessBlue,
  professionalGreen,
}

class AppTheme {
  AppTheme._();

  static ThemeData getTheme(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return _lightTheme;
      case AppThemeMode.dark:
        return _darkTheme;
      case AppThemeMode.businessBlue:
        return _businessBlueTheme;
      case AppThemeMode.professionalGreen:
        return _professionalGreenTheme;
    }
  }

  static final _lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: const Color(0xFF1976D2),
      secondary: const Color(0xFF424242),
      tertiary: const Color(0xFF00897B),
      error: const Color(0xFFD32F2F),
      surface: const Color(0xFFFFFFFF),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: const Color(0xFF212121),
      onError: Colors.white,
      surfaceContainerHighest: const Color(0xFFF5F5F5),
    ),
    textTheme: _buildTextTheme(Brightness.light),
    cardTheme: _buildCardTheme(Brightness.light),
    appBarTheme: _buildAppBarTheme(Brightness.light),
    inputDecorationTheme: _buildInputDecorationTheme(Brightness.light),
    elevatedButtonTheme: _buildElevatedButtonTheme(Brightness.light),
    outlinedButtonTheme: _buildOutlinedButtonTheme(Brightness.light),
    textButtonTheme: _buildTextButtonTheme(Brightness.light),
    extensions: [
      AppThemeExtension.light(),
    ],
  );

  static final _darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: const Color(0xFF42A5F5),
      secondary: const Color(0xFF78909C),
      tertiary: const Color(0xFF26A69A),
      error: const Color(0xFFEF5350),
      surface: const Color(0xFF1E1E1E),
      onPrimary: Colors.black,
      onSecondary: Colors.white,
      onSurface: const Color(0xFFE0E0E0),
      onError: Colors.black,
      surfaceContainerHighest: const Color(0xFF2C2C2C),
    ),
    textTheme: _buildTextTheme(Brightness.dark),
    cardTheme: _buildCardTheme(Brightness.dark),
    appBarTheme: _buildAppBarTheme(Brightness.dark),
    inputDecorationTheme: _buildInputDecorationTheme(Brightness.dark),
    elevatedButtonTheme: _buildElevatedButtonTheme(Brightness.dark),
    outlinedButtonTheme: _buildOutlinedButtonTheme(Brightness.dark),
    textButtonTheme: _buildTextButtonTheme(Brightness.dark),
    extensions: [
      AppThemeExtension.dark(),
    ],
  );

  static final _businessBlueTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: const Color(0xFF0D47A1),
      secondary: const Color(0xFF1565C0),
      tertiary: const Color(0xFF0277BD),
      error: const Color(0xFFD32F2F),
      surface: const Color(0xFFFAFAFA),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: const Color(0xFF263238),
      onError: Colors.white,
      surfaceContainerHighest: const Color(0xFFE3F2FD),
    ),
    textTheme: _buildTextTheme(Brightness.light),
    cardTheme: _buildCardTheme(Brightness.light),
    appBarTheme: _buildAppBarTheme(Brightness.light),
    inputDecorationTheme: _buildInputDecorationTheme(Brightness.light),
    elevatedButtonTheme: _buildElevatedButtonTheme(Brightness.light),
    outlinedButtonTheme: _buildOutlinedButtonTheme(Brightness.light),
    textButtonTheme: _buildTextButtonTheme(Brightness.light),
    extensions: [
      AppThemeExtension.businessBlue(),
    ],
  );

  static final _professionalGreenTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: const Color(0xFF2E7D32),
      secondary: const Color(0xFF388E3C),
      tertiary: const Color(0xFF00695C),
      error: const Color(0xFFD32F2F),
      surface: const Color(0xFFFAFAFA),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: const Color(0xFF1B5E20),
      onError: Colors.white,
      surfaceContainerHighest: const Color(0xFFE8F5E9),
    ),
    textTheme: _buildTextTheme(Brightness.light),
    cardTheme: _buildCardTheme(Brightness.light),
    appBarTheme: _buildAppBarTheme(Brightness.light),
    inputDecorationTheme: _buildInputDecorationTheme(Brightness.light),
    elevatedButtonTheme: _buildElevatedButtonTheme(Brightness.light),
    outlinedButtonTheme: _buildOutlinedButtonTheme(Brightness.light),
    textButtonTheme: _buildTextButtonTheme(Brightness.light),
    extensions: [
      AppThemeExtension.professionalGreen(),
    ],
  );

  static TextTheme _buildTextTheme(Brightness brightness) {
    final baseTextTheme = GoogleFonts.robotoTextTheme();
    final color = brightness == Brightness.light
        ? const Color(0xFF212121)
        : const Color(0xFFE0E0E0);

    return baseTextTheme.copyWith(
      displayLarge: baseTextTheme.displayLarge?.copyWith(
        color: color,
        fontWeight: FontWeight.bold,
      ),
      displayMedium: baseTextTheme.displayMedium?.copyWith(
        color: color,
        fontWeight: FontWeight.bold,
      ),
      displaySmall: baseTextTheme.displaySmall?.copyWith(
        color: color,
        fontWeight: FontWeight.bold,
      ),
      headlineLarge: baseTextTheme.headlineLarge?.copyWith(
        color: color,
        fontWeight: FontWeight.w600,
      ),
      headlineMedium: baseTextTheme.headlineMedium?.copyWith(
        color: color,
        fontWeight: FontWeight.w600,
      ),
      headlineSmall: baseTextTheme.headlineSmall?.copyWith(
        color: color,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: baseTextTheme.titleLarge?.copyWith(
        color: color,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: baseTextTheme.titleMedium?.copyWith(
        color: color,
        fontWeight: FontWeight.w500,
      ),
      titleSmall: baseTextTheme.titleSmall?.copyWith(
        color: color,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: baseTextTheme.bodyLarge?.copyWith(color: color),
      bodyMedium: baseTextTheme.bodyMedium?.copyWith(color: color),
      bodySmall: baseTextTheme.bodySmall?.copyWith(color: color),
      labelLarge: baseTextTheme.labelLarge?.copyWith(
        color: color,
        fontWeight: FontWeight.w500,
      ),
      labelMedium: baseTextTheme.labelMedium?.copyWith(color: color),
      labelSmall: baseTextTheme.labelSmall?.copyWith(color: color),
    );
  }

  static CardThemeData _buildCardTheme(Brightness brightness) {
    return CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      margin: const EdgeInsets.all(8),
    );
  }

  static AppBarTheme _buildAppBarTheme(Brightness brightness) {
    return AppBarTheme(
      elevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.roboto(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: brightness == Brightness.light ? Colors.white : Colors.black,
      ),
    );
  }

  static InputDecorationTheme _buildInputDecorationTheme(Brightness brightness) {
    return InputDecorationTheme(
      filled: true,
      fillColor: brightness == Brightness.light
          ? const Color(0xFFF5F5F5)
          : const Color(0xFF2C2C2C),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: brightness == Brightness.light
              ? const Color(0xFF1976D2)
              : const Color(0xFF42A5F5),
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: Color(0xFFD32F2F),
          width: 2,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: Color(0xFFD32F2F),
          width: 2,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  static ElevatedButtonThemeData _buildElevatedButtonTheme(Brightness brightness) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: GoogleFonts.roboto(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  static OutlinedButtonThemeData _buildOutlinedButtonTheme(Brightness brightness) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: GoogleFonts.roboto(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  static TextButtonThemeData _buildTextButtonTheme(Brightness brightness) {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: GoogleFonts.roboto(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
