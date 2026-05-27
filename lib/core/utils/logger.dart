import 'package:flutter/foundation.dart';

class Logger {
  Logger._();

  static void debug(String message, [dynamic data]) {
    if (kDebugMode) {
      print('🔵 DEBUG: $message ${data != null ? '\nData: $data' : ''}');
    }
  }

  static void info(String message, [dynamic data]) {
    if (kDebugMode) {
      print('ℹ️ INFO: $message ${data != null ? '\nData: $data' : ''}');
    }
  }

  static void warning(String message, [dynamic data]) {
    if (kDebugMode) {
      print('⚠️ WARNING: $message ${data != null ? '\nData: $data' : ''}');
    }
  }

  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      print('❌ ERROR: $message');
      if (error != null) {
        print('Error: $error');
      }
      if (stackTrace != null) {
        print('StackTrace: $stackTrace');
      }
    }
  }

  static void success(String message, [dynamic data]) {
    if (kDebugMode) {
      print('✅ SUCCESS: $message ${data != null ? '\nData: $data' : ''}');
    }
  }
}
