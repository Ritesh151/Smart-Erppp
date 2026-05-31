import 'package:flutter/material.dart';
import 'package:siddhivinayak_enterprise/core/responsive/breakpoints.dart';

extension ContextExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);
  
  TextTheme get textTheme => theme.textTheme;
  
  ColorScheme get colorScheme => theme.colorScheme;
  
  Size get screenSize => MediaQuery.of(this).size;
  
  double get screenWidth => screenSize.width;
  
  double get screenHeight => screenSize.height;
  
  EdgeInsets get padding => MediaQuery.of(this).padding;
  
  EdgeInsets get viewInsets => MediaQuery.of(this).viewInsets;
  
  bool get isDarkMode => theme.brightness == Brightness.dark;
  
  bool get isLightMode => !isDarkMode;
  
  DeviceType get deviceType {
    if (screenWidth >= Breakpoints.largeDesktop) {
      return DeviceType.largeDesktop;
    } else if (screenWidth >= Breakpoints.desktop) {
      return DeviceType.desktop;
    } else if (screenWidth >= Breakpoints.tablet) {
      return DeviceType.tablet;
    } else {
      return DeviceType.mobile;
    }
  }
  
  bool get isMobile => deviceType == DeviceType.mobile;
  
  bool get isTablet => deviceType == DeviceType.tablet;
  
  bool get isDesktop => deviceType == DeviceType.desktop || deviceType == DeviceType.largeDesktop;
  
  bool get isLargeDesktop => deviceType == DeviceType.largeDesktop;
  
  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? colorScheme.error : null,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  void hideKeyboard() {
    FocusScope.of(this).unfocus();
  }
  
  Future<T?> showAppDialog<T>(Widget dialog) {
    return showDialog<T>(
      context: this,
      builder: (context) => dialog,
    );
  }
  
  Future<T?> pushNamed<T>(String routeName, {Object? arguments}) {
    return Navigator.of(this).pushNamed<T>(routeName, arguments: arguments);
  }
}
