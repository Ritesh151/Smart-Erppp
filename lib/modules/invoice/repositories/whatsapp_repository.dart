import 'package:siddhivinayak_enterprise/core/exceptions/app_exception.dart';
import 'package:siddhivinayak_enterprise/core/storage/storage_service.dart';
import 'package:siddhivinayak_enterprise/core/utils/logger.dart';
import 'package:siddhivinayak_enterprise/modules/invoice/models/whatsapp_invoice_model.dart';

/// WhatsApp Repository handles all data persistence for WhatsApp invoices
class WhatsAppRepository {
  final StorageService<Map<dynamic, dynamic>> _storage;

  WhatsAppRepository(this._storage);

  /// Save WhatsApp send history
  Future<void> saveSendHistory(WhatsAppInvoiceModel history) async {
    try {
      await _storage.save(history.id, history.toJson());
      Logger.success('WhatsApp send history saved: ${history.id}');
    } catch (e, stackTrace) {
      Logger.error('Failed to save WhatsApp send history', e, stackTrace);
      throw StorageException('Failed to save WhatsApp history');
    }
  }

  /// Get WhatsApp send history by invoice ID
  Future<List<WhatsAppInvoiceModel>> getHistoryByInvoice(String invoiceId) async {
    try {
      final allHistory = await getAllHistory();
      return allHistory.where((h) => h.invoiceId == invoiceId).toList();
    } catch (e, stackTrace) {
      Logger.error('Failed to get WhatsApp history by invoice', e, stackTrace);
      return [];
    }
  }

  /// Get all WhatsApp send history
  Future<List<WhatsAppInvoiceModel>> getAllHistory() async {
    try {
      final data = _storage.getAll();
      return data
          .map((item) => WhatsAppInvoiceModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } catch (e, stackTrace) {
      Logger.error('Failed to get all WhatsApp history', e, stackTrace);
      throw StorageException('Failed to retrieve WhatsApp history');
    }
  }

  /// Get WhatsApp send history by customer ID
  Future<List<WhatsAppInvoiceModel>> getHistoryByCustomer(String customerId) async {
    try {
      final allHistory = await getAllHistory();
      return allHistory.where((h) => h.customerId == customerId).toList();
    } catch (e, stackTrace) {
      Logger.error('Failed to get WhatsApp history by customer', e, stackTrace);
      return [];
    }
  }

  /// Get WhatsApp send history by status
  Future<List<WhatsAppInvoiceModel>> getHistoryByStatus(bool success) async {
    try {
      final allHistory = await getAllHistory();
      return allHistory.where((h) => h.success == success).toList();
    } catch (e, stackTrace) {
      Logger.error('Failed to get WhatsApp history by status', e, stackTrace);
      return [];
    }
  }

  /// Get sent invoices count
  Future<int> getSentCount() async {
    try {
      final history = await getAllHistory();
      return history.where((h) => h.success).length;
    } catch (e, stackTrace) {
      Logger.error('Failed to get WhatsApp sent count', e, stackTrace);
      return 0;
    }
  }

  /// Get failed send count
  Future<int> getFailedCount() async {
    try {
      final history = await getAllHistory();
      return history.where((h) => !h.success).length;
    } catch (e, stackTrace) {
      Logger.error('Failed to get WhatsApp failed count', e, stackTrace);
      return 0;
    }
  }

  /// Check if invoice was already sent via WhatsApp
  Future<bool> isInvoiceSent(String invoiceId) async {
    try {
      final history = await getHistoryByInvoice(invoiceId);
      return history.where((h) => h.success).isNotEmpty;
    } catch (e, stackTrace) {
      Logger.error('Failed to check if invoice was sent', e, stackTrace);
      return false;
    }
  }

  /// Clear WhatsApp history
  Future<void> clearHistory() async {
    try {
      await _storage.clear();
      Logger.info('WhatsApp history cleared');
    } catch (e, stackTrace) {
      Logger.error('Failed to clear WhatsApp history', e, stackTrace);
      throw StorageException('Failed to clear WhatsApp history');
    }
  }

  /// Delete specific history record
  Future<void> deleteHistory(String id) async {
    try {
      await _storage.delete(id);
      Logger.success('WhatsApp history deleted: $id');
    } catch (e, stackTrace) {
      Logger.error('Failed to delete WhatsApp history', e, stackTrace);
      throw StorageException('Failed to delete WhatsApp history');
    }
  }

  /// Get total history count
  Future<int> getTotalCount() async {
    try {
      return _storage.length;
    } catch (e, stackTrace) {
      Logger.error('Failed to get WhatsApp history count', e, stackTrace);
      return 0;
    }
  }

  /// Get last sent invoice
  Future<WhatsAppInvoiceModel?> getLastSentInvoice() async {
    try {
      final history = await getAllHistory();
      if (history.isEmpty) return null;
      
      // Sort by sentAt in descending order and return first
      history.sort((a, b) => b.sentAt.compareTo(a.sentAt));
      try {
        return history.firstWhere((h) => h.success);
      } catch (_) {
        return null;
      }
    } catch (e, stackTrace) {
      Logger.error('Failed to get last sent invoice', e, stackTrace);
      return null;
    }
  }
}
