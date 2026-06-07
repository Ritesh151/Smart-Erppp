import 'package:flutter/foundation.dart';
import 'package:siddhivinayak_enterprise/core/exceptions/app_exception.dart';
import 'package:siddhivinayak_enterprise/core/models/invoice_item_model.dart';
import 'package:siddhivinayak_enterprise/core/models/invoice_model.dart';
import 'package:siddhivinayak_enterprise/core/utils/logger.dart';
import 'package:siddhivinayak_enterprise/modules/invoice/models/whatsapp_invoice_model.dart';
import 'package:siddhivinayak_enterprise/modules/invoice/models/whatsapp_message_template.dart';
import 'package:siddhivinayak_enterprise/modules/invoice/repositories/whatsapp_repository.dart';
import 'package:siddhivinayak_enterprise/modules/invoice/services/message_template_service.dart';
import 'package:siddhivinayak_enterprise/modules/invoice/utils/whatsapp_helper.dart';
import 'package:url_launcher/url_launcher.dart';

/// WhatsApp Service handles all WhatsApp-related functionality for invoice notifications
class WhatsAppService {
  final WhatsAppRepository _repository;

  WhatsAppService({required WhatsAppRepository repository})
      : _repository = repository;

  /// Send invoice via WhatsApp using url_launcher
  /// This is the primary method that works across all platforms
  Future<bool> sendInvoiceViaWhatsApp({
    required String customerPhone,
    required InvoiceModel invoice,
    required List<InvoiceItemModel> items,
    String? messageTemplate,
    bool useAutoFormat = true,
    bool showSuccessToast = true,
  }) async {
    try {
      // Validate phone number
      final normalizedPhone = WhatsAppHelper.normalizePhoneNumber(customerPhone);
      if (!WhatsAppHelper.isValidPhoneNumber(normalizedPhone)) {
        throw ValidationException('Invalid phone number');
      }

      // Generate message
      final formattedMessage = messageTemplate ??
          MessageTemplateService.generateInvoiceMessage(
            customerName: invoice.customerName,
            invoiceNumber: invoice.invoiceNumber,
            items: items,
            subtotal: invoice.subtotal,
            taxAmount: invoice.taxAmount,
            totalAmount: invoice.totalAmount,
          );

      // Build WhatsApp URL
      final whatsappUrl = WhatsAppHelper.buildWhatsAppUrl(
        phoneNumber: normalizedPhone,
        message: formattedMessage,
      );

      // Launch WhatsApp
      final result = await _launchWhatsApp(whatsappUrl);
      
      // Save to history
      await _repository.saveSendHistory(
        WhatsAppInvoiceModel.create(
          invoiceId: invoice.id,
          customerId: invoice.customerId,
          customerName: invoice.customerName,
          customerPhone: normalizedPhone,
          invoiceNumber: invoice.invoiceNumber,
          formattedMessage: formattedMessage,
          success: result,
        ),
      );

      if (result) {
        Logger.success('WhatsApp invoice sent to $normalizedPhone');
        return true;
      } else {
        Logger.warning('WhatsApp launch failed for $normalizedPhone');
        return false;
      }
    } on ValidationException catch (e) {
      Logger.error('WhatsApp validation error', e);
      rethrow;
    } catch (e, stackTrace) {
      Logger.error('Failed to send WhatsApp invoice', e, stackTrace);
      throw ServiceException('Failed to send WhatsApp invoice: ${e.toString()}');
    }
  }

  /// Send invoice via WhatsApp using Android intent (Android-specific optimization)
  /// Falls back to url_launcher on other platforms
  Future<bool> sendInvoiceViaAndroidIntent({
    required String customerPhone,
    required InvoiceModel invoice,
    required List<InvoiceItemModel> items,
    String? messageTemplate,
  }) async {
    try {
      if (!WhatsAppHelper.isAndroid()) {
        return await sendInvoiceViaWhatsApp(
          customerPhone: customerPhone,
          invoice: invoice,
          items: items,
          messageTemplate: messageTemplate,
        );
      }

      final normalizedPhone = WhatsAppHelper.normalizePhoneNumber(customerPhone);
      if (!WhatsAppHelper.isValidPhoneNumber(normalizedPhone)) {
        throw ValidationException('Invalid phone number');
      }

      final formattedMessage = messageTemplate ??
          MessageTemplateService.generateInvoiceMessage(
            customerName: invoice.customerName,
            invoiceNumber: invoice.invoiceNumber,
            items: items,
            subtotal: invoice.subtotal,
            taxAmount: invoice.taxAmount,
            totalAmount: invoice.totalAmount,
          );

      final whatsappUrl = WhatsAppHelper.buildWhatsAppUrl(
        phoneNumber: normalizedPhone,
        message: formattedMessage,
      );

      final result = await _launchWhatsAppAndroid(whatsappUrl);
      
      await _repository.saveSendHistory(
        WhatsAppInvoiceModel.create(
          invoiceId: invoice.id,
          customerId: invoice.customerId,
          customerName: invoice.customerName,
          customerPhone: normalizedPhone,
          invoiceNumber: invoice.invoiceNumber,
          formattedMessage: formattedMessage,
          success: result,
        ),
      );

      if (result) {
        Logger.success('WhatsApp invoice sent via Android intent');
        return true;
      }
      return false;
    } on ValidationException catch (e) {
      Logger.error('WhatsApp validation error', e);
      rethrow;
    } catch (e, stackTrace) {
      Logger.error('Failed to send WhatsApp invoice via Android intent', e, stackTrace);
      return false;
    }
  }

  /// Future-proof method for WhatsApp Business API integration
  /// This method is ready for future implementation
  Future<bool> sendInvoiceViaAPI({
    required String customerPhone,
    required InvoiceModel invoice,
    required List<InvoiceItemModel> items,
    String? messageTemplate,
  }) async {
    // This method is a placeholder for future WhatsApp Business API integration
    // Currently falls back to url_launcher method
    // Future implementations can use:
    // - Meta Cloud API
    // - Twilio WhatsApp
    // - WhatsApp Business API
    
    Logger.info('WhatsApp API method called - using fallback url_launcher');
    return await sendInvoiceViaWhatsApp(
      customerPhone: customerPhone,
      invoice: invoice,
      items: items,
      messageTemplate: messageTemplate,
    );
  }

  /// Send invoice via background notification (future implementation)
  /// For now, this just logs the intent
  Future<bool> sendBackgroundNotification({
    required String customerPhone,
    required InvoiceModel invoice,
    required List<InvoiceItemModel> items,
  }) async {
    // This method is for future background notification implementation
    // May require:
    // - WhatsApp Business API
    // - User consent for background notifications
    // - Scheduled messaging capabilities
    
    Logger.info('Background notification requested for $customerPhone');
    return false;
  }

  /// Get WhatsApp send history for an invoice
  Future<List<WhatsAppInvoiceModel>> getSendHistoryByInvoice(String invoiceId) async {
    try {
      return await _repository.getHistoryByInvoice(invoiceId);
    } catch (e, stackTrace) {
      Logger.error('Failed to get WhatsApp send history', e, stackTrace);
      return [];
    }
  }

  /// Get all WhatsApp send history
  Future<List<WhatsAppInvoiceModel>> getAllSendHistory() async {
    try {
      return await _repository.getAllHistory();
    } catch (e, stackTrace) {
      Logger.error('Failed to get all WhatsApp send history', e, stackTrace);
      return [];
    }
  }

  /// Check if WhatsApp is available on the device
  Future<bool> isWhatsAppAvailable() async {
    try {
      final uri = Uri.parse('https://wa.me/?text=test');
      return await canLaunchUrl(uri);
    } catch (e) {
      return false;
    }
  }

  /// Get WhatsApp customer profile information
  Future<Map<String, dynamic>?> getWhatsAppProfile(String phone) async {
    try {
      return await WhatsAppHelper.getWhatsAppProfile(phone);
    } catch (e) {
      return null;
    }
  }

  /// Extract phone number from WhatsApp URL
  String? extractPhoneNumberFromUrl(String url) {
    return WhatsAppHelper.extractPhoneNumberFromUrl(url);
  }

  /// Format phone number for display
  String formatPhoneNumberForDisplay(String phone) {
    return WhatsAppHelper.formatPhoneNumberForDisplay(phone);
  }

  /// Validate and normalize phone number
  String normalizePhoneNumber(String phone) {
    return WhatsAppHelper.normalizePhoneNumber(phone);
  }

  Future<bool> _launchWhatsApp(String url) async {
    try {
      final uri = Uri.parse(url);
      
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        return true;
      }
      return false;
    } catch (e) {
      Logger.error('Failed to launch WhatsApp URL', e);
      return false;
    }
  }

  Future<bool> _launchWhatsAppAndroid(String url) async {
    try {
      final uri = Uri.parse(url);
      
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        return true;
      }
      return false;
    } catch (e) {
      Logger.error('Failed to launch WhatsApp via Android intent', e);
      return false;
    }
  }
}

class ServiceException implements Exception {
  final String message;
  
  ServiceException(this.message);
  
  @override
  String toString() => 'ServiceException: $message';
}
