import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:url_launcher/url_launcher.dart';

/// WhatsApp Helper handles platform-specific WhatsApp operations
class WhatsAppHelper {
  /// Check if running on Android
  static bool isAndroid() {
    return Platform.isAndroid;
  }

  /// Check if running on iOS
  static bool isIOS() {
    return Platform.isIOS;
  }

  /// Check if running on Web
  static bool isWeb() {
    return kIsWeb;
  }

  /// Check if running on Windows
  static bool isWindows() {
    return Platform.isWindows;
  }

  /// Check if running on macOS
  static bool isMacOS() {
    return Platform.isMacOS;
  }

  /// Check if running on Linux
  static bool isLinux() {
    return Platform.isLinux;
  }

  /// Check if WhatsApp is available on the device
  Future<bool> checkWhatsAppAvailability() async {
    try {
      // For mobile platforms, try to launch WhatsApp directly
      if (isAndroid()) {
        final whatsappUri = Uri.parse('https://wa.me/?text=test');
        return await canLaunchUrl(whatsappUri);
      } else if (isIOS()) {
        final whatsappUri = Uri.parse('https://wa.me/?text=test');
        return await canLaunchUrl(whatsappUri);
      } else {
        // For web/desktop, check if URL launcher is available
        return true;
      }
    } catch (e) {
      return false;
    }
  }

  /// Validate phone number format
  static bool isValidPhoneNumber(String phoneNumber) {
    // Remove all non-digit characters
    final cleaned = phoneNumber.replaceAll(RegExp(r'\D'), '');
    
    // Check minimum length (10 digits for most countries)
    if (cleaned.length < 10) return false;
    
    // Check maximum length (15 digits - E.164 standard)
    if (cleaned.length > 15) return false;
    
    return true;
  }

  /// Normalize phone number to international format
  /// Handles various formats:
  /// - +919876543210
  /// - 919876543210
  /// - 9876543210
  /// - +91 98765 43210
  static String normalizePhoneNumber(String phoneNumber) {
    // Remove all non-digit characters
    var cleaned = phoneNumber.replaceAll(RegExp(r'\D'), '');
    
    // Add country code if missing (default to +91 for India)
    if (!cleaned.startsWith('91')) {
      if (cleaned.length == 10) {
        cleaned = '91$cleaned';
      }
    }
    
    // Ensure + prefix
    if (!cleaned.startsWith('+')) {
      cleaned = '+$cleaned';
    }
    
    return cleaned;
  }

  /// Build WhatsApp URL with message
  /// Format: https://wa.me/PHONE_NUMBER?text=ENCODED_MESSAGE
  static String buildWhatsAppUrl({
    required String phoneNumber,
    required String message,
  }) {
    final encodedMessage = Uri.encodeComponent(message);
    return 'https://wa.me/$phoneNumber?text=$encodedMessage';
  }

  /// Build WhatsApp URL with phone number only
  static String buildWhatsAppUrlWithPhone(String phoneNumber) {
    return 'https://wa.me/$phoneNumber';
  }

  /// Extract phone number from WhatsApp URL
  static String? extractPhoneNumberFromUrl(String url) {
    final pattern = RegExp(r'https://wa\.me/(\+?\d+)');
    final match = pattern.firstMatch(url);
    return match?.group(1);
  }

  /// Format phone number for display
  static String formatPhoneNumberForDisplay(String phoneNumber) {
    final cleaned = phoneNumber.replaceAll(RegExp(r'\D'), '');
    
    if (cleaned.startsWith('91') && cleaned.length == 12) {
      final nationalNumber = cleaned.substring(2);
      return '+91 ${nationalNumber.substring(0, 5)} ${nationalNumber.substring(5)}';
    }
    
    if (cleaned.length == 10) {
      return '$cleaned';
    }
    
    return phoneNumber;
  }

  /// Format date for WhatsApp message
  static String formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final invoiceDate = DateTime(date.year, date.month, date.day);
    
    final diff = today.difference(invoiceDate);
    
    if (diff.inDays == 0) {
      return 'Today';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  /// Get WhatsApp app name based on platform
  static String getWhatsAppAppName() {
    if (isAndroid()) return 'WhatsApp';
    if (isIOS()) return 'WhatsApp';
    if (isWindows() || isMacOS() || isLinux()) return 'WhatsApp Web';
    return 'WhatsApp';
  }

  /// Get supported platforms for WhatsApp
  static List<String> getSupportedPlatforms() {
    final platforms = <String>[];
    
    if (isAndroid()) platforms.add('Android');
    if (isIOS()) platforms.add('iOS');
    if (isWindows()) platforms.add('Windows');
    if (isMacOS()) platforms.add('macOS');
    if (isLinux()) platforms.add('Linux');
    if (isWeb()) platforms.add('Web');
    
    return platforms;
  }

  /// Get WhatsApp support status for current platform
  static bool isWhatsAppSupported() {
    return isAndroid() || isIOS() || isWindows() || isMacOS() || isLinux() || isWeb();
  }

  /// Check if running on mobile device
  static bool isMobile() {
    return isAndroid() || isIOS();
  }

  /// Check if running on desktop
  static bool isDesktop() {
    return isWindows() || isMacOS() || isLinux();
  }

  /// Show error message for WhatsApp not available
  static String getWhatsAppNotAvailableMessage() {
    if (isWeb()) {
      return 'WhatsApp Web is not available. Please open WhatsApp Web manually.';
    }
    if (isDesktop()) {
      return 'WhatsApp is not installed. Please install WhatsApp Desktop.';
    }
    return 'WhatsApp is not installed on your device.';
  }

  /// Get message length limit for WhatsApp
  /// WhatsApp has a 65,536 character limit per message
  static int get WhatsAppMaxMessageLength => 65536;

  /// Check if message is within length limit
  static bool isMessageWithinLimit(String message) {
    return message.length <= WhatsAppMaxMessageLength;
  }

  /// Truncate message to fit within limit
  static String truncateMessage(String message, {int maxLength = 65536}) {
    if (message.length <= maxLength) return message;
    return '${message.substring(0, maxLength)}...';
  }

  /// Validate message before sending
  static bool validateMessage(String message) {
    if (message.isEmpty) return false;
    if (message.length > WhatsAppMaxMessageLength) return false;
    return true;
  }

  /// Get WhatsApp customer profile information (placeholder for future API implementation)
  static Future<Map<String, dynamic>?> getWhatsAppProfile(String phone) async {
    // This is a placeholder for future WhatsApp Business API integration
    // In production, this would call the WhatsApp Business API
    try {
      // For now, return null as this requires API implementation
      return null;
    } catch (e) {
      return null;
    }
  }
}
