import 'package:flutter/foundation.dart';
import 'package:siddhivinayak_enterprise/core/models/invoice_item_model.dart';
import 'package:siddhivinayak_enterprise/core/models/invoice_model.dart';
import 'package:siddhivinayak_enterprise/core/utils/logger.dart';
import 'package:siddhivinayak_enterprise/modules/invoice/models/whatsapp_invoice_model.dart';
import 'package:siddhivinayak_enterprise/modules/invoice/services/whatsapp_service.dart';
import 'package:siddhivinayak_enterprise/modules/invoice/services/message_template_service.dart';
import 'package:siddhivinayak_enterprise/modules/invoice/utils/whatsapp_helper.dart';

/// WhatsApp Provider manages WhatsApp invoice notification state
class WhatsAppProvider extends ChangeNotifier {
  final WhatsAppService _service;
  VoidCallback? onDataChanged;

  WhatsAppProvider(this._service, {VoidCallback? onDataChanged})
      : onDataChanged = onDataChanged;

  List<WhatsAppInvoiceModel> _sendHistory = [];
  List<WhatsAppInvoiceModel> _filteredHistory = [];

  bool _isLoading = false;
  bool _isSending = false;
  String? _errorMessage;
  String? _successMessage;
  String _searchQuery = '';
  bool? _filterSuccessStatus;
  String? _selectedCustomerId;

  // Current sending state
  String? _currentInvoiceId;
  String? _currentCustomerPhone;
  String? _currentCustomerName;

  bool get isLoading => _isLoading;
  bool get isSending => _isSending;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  String get searchQuery => _searchQuery;
  bool? get filterSuccessStatus => _filterSuccessStatus;
  String? get selectedCustomerId => _selectedCustomerId;

  List<WhatsAppInvoiceModel> get sendHistory {
    if (_searchQuery.isNotEmpty) {
      return _filteredHistory;
    }
    if (_filterSuccessStatus != null) {
      return _filteredHistory;
    }
    if (_selectedCustomerId != null) {
      return _filteredHistory;
    }
    return _sendHistory;
  }

  WhatsAppInvoiceModel? get lastSentInvoice {
    if (_sendHistory.isEmpty) return null;
    
    // Sort by sentAt in descending order and return first
    final sorted = List<WhatsAppInvoiceModel>.from(_sendHistory)
      ..sort((a, b) => b.sentAt.compareTo(a.sentAt));
    return sorted.firstWhereOrNull((h) => h.success);
  }

  int get totalSent => _sendHistory.where((h) => h.success).length;
  int get totalFailed => _sendHistory.where((h) => !h.success).length;
  int get totalCount => _sendHistory.length;

  String? get currentInvoiceId => _currentInvoiceId;
  String? get currentCustomerPhone => _currentCustomerPhone;
  String? get currentCustomerName => _currentCustomerName;

  /// Check if invoice was already sent via WhatsApp
  bool isInvoiceSent(String invoiceId) {
    return _sendHistory.any((h) => h.invoiceId == invoiceId && h.success);
  }

  /// Generate WhatsApp message for invoice
  String generateInvoiceMessage({
    required String customerName,
    required String invoiceNumber,
    required List<InvoiceItemModel> items,
    required double subtotal,
    required double taxAmount,
    required double totalAmount,
    bool useShortFormat = false,
  }) {
    return MessageTemplateService.generateInvoiceMessage(
      customerName: customerName,
      invoiceNumber: invoiceNumber,
      items: items,
      subtotal: subtotal,
      taxAmount: taxAmount,
      totalAmount: totalAmount,
      useShortFormat: useShortFormat,
    );
  }

  /// Generate WhatsApp message from InvoiceModel
  String generateMessageFromInvoice({
    required InvoiceModel invoice,
    required List<InvoiceItemModel> items,
    bool useShortFormat = false,
  }) {
    return MessageTemplateService.generateFromInvoiceModel(
      invoice: invoice,
      items: items,
      useShortFormat: useShortFormat,
    );
  }

  /// Load WhatsApp send history
  Future<void> loadHistory() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _sendHistory = await _service.getAllSendHistory();

      _isLoading = false;
      notifyListeners();
      onDataChanged?.call();
      Logger.success('WhatsApp history loaded: ${_sendHistory.length}');
    } catch (e, stackTrace) {
      _isLoading = false;
      _errorMessage = 'Failed to load WhatsApp history';
      notifyListeners();
      Logger.error('Failed to load WhatsApp history', e, stackTrace);
    }
  }

  /// Send invoice via WhatsApp
  Future<bool> sendInvoice({
    required String customerPhone,
    required InvoiceModel invoice,
    required List<InvoiceItemModel> items,
    String? messageTemplate,
    bool useAndroidIntent = false,
  }) async {
    try {
      _isSending = true;
      _currentInvoiceId = invoice.id;
      _currentCustomerPhone = customerPhone;
      _currentCustomerName = invoice.customerName;
      _errorMessage = null;
      _successMessage = null;
      notifyListeners();

      bool result;
      if (useAndroidIntent && WhatsAppHelper.isAndroid()) {
        result = await _service.sendInvoiceViaAndroidIntent(
          customerPhone: customerPhone,
          invoice: invoice,
          items: items,
          messageTemplate: messageTemplate,
        );
      } else {
        result = await _service.sendInvoiceViaWhatsApp(
          customerPhone: customerPhone,
          invoice: invoice,
          items: items,
          messageTemplate: messageTemplate,
        );
      }

      if (result) {
        _successMessage = 'Invoice sent successfully via WhatsApp';
        await loadHistory();
      }

      _isSending = false;
      _currentInvoiceId = null;
      _currentCustomerPhone = null;
      _currentCustomerName = null;
      notifyListeners();
      onDataChanged?.call();
      
      return result;
    } catch (e, stackTrace) {
      _isSending = false;
      _errorMessage = e.toString();
      _currentInvoiceId = null;
      _currentCustomerPhone = null;
      _currentCustomerName = null;
      notifyListeners();
      Logger.error('Failed to send WhatsApp invoice', e, stackTrace);
      return false;
    }
  }

  /// Send invoice with auto-generated message
  Future<bool> sendInvoiceWithAutoMessage({
    required String customerPhone,
    required InvoiceModel invoice,
    required List<InvoiceItemModel> items,
    bool useShortFormat = false,
    bool useAndroidIntent = false,
  }) async {
    final message = generateMessageFromInvoice(
      invoice: invoice,
      items: items,
      useShortFormat: useShortFormat,
    );
    
    return await sendInvoice(
      customerPhone: customerPhone,
      invoice: invoice,
      items: items,
      messageTemplate: message,
      useAndroidIntent: useAndroidIntent,
    );
  }

  /// Send invoice with custom message
  Future<bool> sendInvoiceWithCustomMessage({
    required String customerPhone,
    required InvoiceModel invoice,
    required List<InvoiceItemModel> items,
    required String customMessage,
    bool useAndroidIntent = false,
  }) async {
    return await sendInvoice(
      customerPhone: customerPhone,
      invoice: invoice,
      items: items,
      messageTemplate: customMessage,
      useAndroidIntent: useAndroidIntent,
    );
  }

  /// Check if WhatsApp is available
  Future<bool> checkWhatsAppAvailability() async {
    try {
      return await _service.isWhatsAppAvailable();
    } catch (e) {
      return false;
    }
  }

  /// Search send history
  Future<void> searchHistory(String query) async {
    try {
      _searchQuery = query;
      _filteredHistory = [];
      notifyListeners();

      if (query.trim().isEmpty) {
        _filteredHistory = [];
      } else {
        final lowerQuery = query.toLowerCase();
        _filteredHistory = _sendHistory.where((history) {
          return history.customerName.toLowerCase().contains(lowerQuery) ||
              history.invoiceNumber.toLowerCase().contains(lowerQuery) ||
              history.customerPhone.toLowerCase().contains(lowerQuery);
        }).toList();
      }

      notifyListeners();
    } catch (e, stackTrace) {
      _searchQuery = '';
      notifyListeners();
      Logger.error('Failed to search WhatsApp history', e, stackTrace);
    }
  }

  /// Filter history by status
  Future<void> filterByStatus(bool? success) async {
    try {
      _filterSuccessStatus = success;
      _filteredHistory = [];
      notifyListeners();

      if (success == null) {
        _filteredHistory = [];
      } else {
        _filteredHistory = _sendHistory.where((h) => h.success == success).toList();
      }

      notifyListeners();
    } catch (e, stackTrace) {
      _filterSuccessStatus = null;
      notifyListeners();
      Logger.error('Failed to filter WhatsApp history', e, stackTrace);
    }
  }

  /// Filter history by customer
  Future<void> filterByCustomer(String? customerId) async {
    try {
      _selectedCustomerId = customerId;
      _filteredHistory = [];
      notifyListeners();

      if (customerId == null) {
        _filteredHistory = [];
      } else {
        _filteredHistory = _sendHistory.where((h) => h.customerId == customerId).toList();
      }

      notifyListeners();
    } catch (e, stackTrace) {
      _selectedCustomerId = null;
      notifyListeners();
      Logger.error('Failed to filter WhatsApp history by customer', e, stackTrace);
    }
  }

  /// Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Clear success message
  void clearSuccess() {
    _successMessage = null;
    notifyListeners();
  }

  /// Clear search
  void clearSearch() {
    _searchQuery = '';
    _filteredHistory = [];
    notifyListeners();
  }

  /// Clear filters
  void clearFilters() {
    _filterSuccessStatus = null;
    _selectedCustomerId = null;
    _filteredHistory = [];
    notifyListeners();
  }

  /// Clear all filters and search
  void clearAll() {
    clearSearch();
    clearFilters();
  }
}

extension FirstWhereOrNull<T> on List<T> {
  T? firstWhereOrNull(bool Function(T element) test) {
    for (final element in this) {
      if (test(element)) {
        return element;
      }
    }
    return null;
  }
}
