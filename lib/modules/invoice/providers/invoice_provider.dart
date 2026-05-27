import 'package:flutter/foundation.dart';
import 'package:smarterp/core/exceptions/app_exception.dart';
import 'package:smarterp/core/models/invoice_model.dart';
import 'package:smarterp/core/models/invoice_item_model.dart';
import 'package:smarterp/core/utils/logger.dart';
import 'package:smarterp/modules/invoice/services/invoice_service.dart';

class InvoiceProvider extends ChangeNotifier {
  final InvoiceService _service;

  InvoiceProvider({
    required InvoiceService service,
  }) : _service = service;

  List<InvoiceModel> _invoices = [];
  List<InvoiceModel> _filteredInvoices = [];
  InvoiceModel? _selectedInvoice;
  List<InvoiceItemModel> _selectedInvoiceItems = [];

  InvoiceModel? _editingInvoice;
  List<InvoiceItemModel> _editingItems = [];
  DateTime _editingInvoiceDate = DateTime.now();
  DateTime _editingDueDate = DateTime.now().add(const Duration(days: 30));
  double _editingDiscount = 0;
  String _editingNotes = '';
  String _editingTerms = '';
  String _editingCustomerId = '';
  String _editingCustomerName = '';
  String _editingCustomerEmail = '';
  String _editingCustomerPhone = '';
  String _editingCustomerAddress = '';
  String _editingCustomerGst = '';

  bool _isLoading = false;
  bool _isSearching = false;
  String? _errorMessage;
  String _searchQuery = '';
  InvoiceStatus? _selectedStatus;

  List<InvoiceModel> get invoices =>
      _filteredInvoices.isEmpty && _searchQuery.isEmpty
          ? _invoices
          : _filteredInvoices;

  InvoiceModel? get selectedInvoice => _selectedInvoice;
  List<InvoiceItemModel> get selectedInvoiceItems => _selectedInvoiceItems;

  InvoiceModel? get editingInvoice => _editingInvoice;
  List<InvoiceItemModel> get editingItems => _editingItems;
  DateTime get editingInvoiceDate => _editingInvoiceDate;
  DateTime get editingDueDate => _editingDueDate;
  double get editingDiscount => _editingDiscount;
  String get editingNotes => _editingNotes;
  String get editingTerms => _editingTerms;
  String get editingCustomerId => _editingCustomerId;
  String get editingCustomerName => _editingCustomerName;
  String get editingCustomerEmail => _editingCustomerEmail;
  String get editingCustomerPhone => _editingCustomerPhone;
  String get editingCustomerAddress => _editingCustomerAddress;
  String get editingCustomerGst => _editingCustomerGst;

  bool get isLoading => _isLoading;
  bool get isSearching => _isSearching;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  InvoiceStatus? get selectedStatus => _selectedStatus;

  int get totalInvoices => _invoices.length;
  int get draftCount =>
      _invoices.where((i) => i.status == InvoiceStatus.draft).length;
  int get sentCount =>
      _invoices.where((i) => i.status == InvoiceStatus.sent).length;
  int get paidCount =>
      _invoices.where((i) => i.status == InvoiceStatus.paid).length;
  int get overdueCount =>
      _invoices.where((i) => i.status == InvoiceStatus.overdue).length;
  int get partiallyPaidCount =>
      _invoices.where((i) => i.status == InvoiceStatus.partiallyPaid).length;
  int get cancelledCount =>
      _invoices.where((i) => i.status == InvoiceStatus.cancelled).length;

  double get editingSubtotal => _editingItems.fold(0.0, (s, i) => s + i.subtotal);
  double get editingTaxAmount => _editingItems.fold(0.0, (s, i) => s + i.taxAmount);
  double get editingTotalAmount => editingSubtotal + editingTaxAmount - _editingDiscount;

  Future<void> loadInvoices() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _invoices = await _service.getAllInvoices();

      _isLoading = false;
      notifyListeners();
      Logger.success('Invoices loaded: ${_invoices.length}');
    } catch (e, stackTrace) {
      _isLoading = false;
      _errorMessage = 'Failed to load invoices';
      notifyListeners();
      Logger.error('Failed to load invoices', e, stackTrace);
    }
  }

  Future<void> loadInvoiceDetails(String id) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _selectedInvoice = await _service.getInvoiceById(id);
      if (_selectedInvoice != null) {
        _selectedInvoiceItems = await _service.getInvoiceItems(_selectedInvoice!);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e, stackTrace) {
      _isLoading = false;
      _errorMessage = 'Failed to load invoice details';
      notifyListeners();
      Logger.error('Failed to load invoice details', e, stackTrace);
    }
  }

  void resetEditingState() {
    _editingInvoice = null;
    _editingItems.clear();
    _editingInvoiceDate = DateTime.now();
    _editingDueDate = DateTime.now().add(const Duration(days: 30));
    _editingDiscount = 0;
    _editingNotes = '';
    _editingTerms = '';
    _editingCustomerId = '';
    _editingCustomerName = '';
    _editingCustomerEmail = '';
    _editingCustomerPhone = '';
    _editingCustomerAddress = '';
    _editingCustomerGst = '';
    notifyListeners();
  }

  void addItem({
    required String productId,
    required String productName,
    required double quantity,
    required double unitPrice,
    required double gstRate,
    String? hsnCode,
  }) {
    final item = InvoiceItemModel.create(
      productId: productId,
      productName: productName,
      quantity: quantity,
      unit: 'Piece',
      unitPrice: unitPrice,
      taxRate: gstRate,
      hsnCode: hsnCode,
    );
    _editingItems.add(item);
    notifyListeners();
  }

  void updateItemQuantity(int index, double quantity) {
    if (index >= 0 && index < _editingItems.length) {
      final old = _editingItems[index];
      _editingItems[index] = InvoiceItemModel.create(
        productId: old.productId,
        productName: old.productName,
        quantity: quantity,
        unit: old.unit,
        unitPrice: old.unitPrice,
        taxRate: old.taxRate,
        discountRate: old.discountRate,
        hsnCode: old.hsnCode,
      );
      notifyListeners();
    }
  }

  void updateItemPrice(int index, double unitPrice) {
    if (index >= 0 && index < _editingItems.length) {
      final old = _editingItems[index];
      _editingItems[index] = InvoiceItemModel.create(
        productId: old.productId,
        productName: old.productName,
        quantity: old.quantity,
        unit: old.unit,
        unitPrice: unitPrice,
        taxRate: old.taxRate,
        discountRate: old.discountRate,
        hsnCode: old.hsnCode,
      );
      notifyListeners();
    }
  }

  void removeItem(int index) {
    if (index >= 0 && index < _editingItems.length) {
      _editingItems.removeAt(index);
      notifyListeners();
    }
  }

  void clearEditingItems() {
    _editingItems.clear();
    notifyListeners();
  }

  Future<void> saveDraft() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final invoice = await _service.createInvoice(
        customerId: _editingCustomerId,
        customerName: _editingCustomerName,
        customerEmail: _editingCustomerEmail.isNotEmpty ? _editingCustomerEmail : null,
        customerPhone: _editingCustomerPhone.isNotEmpty ? _editingCustomerPhone : null,
        customerAddress: _editingCustomerAddress.isNotEmpty ? _editingCustomerAddress : null,
        customerGst: _editingCustomerGst.isNotEmpty ? _editingCustomerGst : null,
        invoiceDate: _editingInvoiceDate,
        dueDate: _editingDueDate,
        items: List.from(_editingItems),
        discountAmount: _editingDiscount,
        notes: _editingNotes.isNotEmpty ? _editingNotes : null,
        termsAndConditions: _editingTerms.isNotEmpty ? _editingTerms : null,
      );

      _invoices.add(invoice);

      _isLoading = false;
      notifyListeners();
      Logger.success('Invoice draft saved: ${invoice.invoiceNumber}');
    } on ValidationException catch (e) {
      _isLoading = false;
      _errorMessage = e.message;
      notifyListeners();
      rethrow;
    } catch (e, stackTrace) {
      _isLoading = false;
      _errorMessage = 'Failed to save invoice';
      notifyListeners();
      Logger.error('Failed to save invoice', e, stackTrace);
      rethrow;
    }
  }

  Future<void> markAsSent(String id) async {
    try {
      await _service.markAsSent(id);
      await _refreshInvoice(id);
      Logger.success('Invoice marked as sent');
    } catch (e, stackTrace) {
      _errorMessage = 'Failed to mark invoice as sent';
      notifyListeners();
      Logger.error('Failed to mark invoice as sent', e, stackTrace);
      rethrow;
    }
  }

  Future<void> markAsPaid(String id, double amount) async {
    try {
      await _service.markAsPaid(id, amount);
      await _refreshInvoice(id);
      Logger.success('Invoice payment recorded');
    } catch (e, stackTrace) {
      _errorMessage = 'Failed to mark invoice as paid';
      notifyListeners();
      Logger.error('Failed to mark invoice as paid', e, stackTrace);
      rethrow;
    }
  }

  Future<void> cancelInvoice(String id) async {
    try {
      await _service.updateInvoiceStatus(id, InvoiceStatus.cancelled);
      await _refreshInvoice(id);
      Logger.success('Invoice cancelled');
    } catch (e, stackTrace) {
      _errorMessage = 'Failed to cancel invoice';
      notifyListeners();
      Logger.error('Failed to cancel invoice', e, stackTrace);
      rethrow;
    }
  }

  Future<void> deleteInvoice(String id) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _service.deleteInvoice(id);
      _invoices.removeWhere((i) => i.id == id);

      if (_selectedInvoice?.id == id) {
        _selectedInvoice = null;
        _selectedInvoiceItems = [];
      }

      _isLoading = false;
      notifyListeners();
      Logger.success('Invoice deleted successfully');
    } catch (e, stackTrace) {
      _isLoading = false;
      _errorMessage = 'Failed to delete invoice';
      notifyListeners();
      Logger.error('Failed to delete invoice', e, stackTrace);
      rethrow;
    }
  }

  Future<void> _refreshInvoice(String id) async {
    final index = _invoices.indexWhere((i) => i.id == id);
    if (index != -1) {
      final refreshed = await _service.getInvoiceById(id);
      if (refreshed != null) {
        _invoices[index] = refreshed;
      }
    }
    if (_selectedInvoice?.id == id) {
      _selectedInvoice = await _service.getInvoiceById(id);
    }
    notifyListeners();
  }

  void setEditingInvoiceDate(DateTime date) {
    _editingInvoiceDate = date;
    notifyListeners();
  }

  void setEditingDueDate(DateTime date) {
    _editingDueDate = date;
    notifyListeners();
  }

  void setEditingDiscount(double discount) {
    _editingDiscount = discount;
    notifyListeners();
  }

  void setEditingNotes(String notes) {
    _editingNotes = notes;
    notifyListeners();
  }

  void setEditingTerms(String terms) {
    _editingTerms = terms;
    notifyListeners();
  }

  void setEditingCustomerId(String id) {
    _editingCustomerId = id;
    notifyListeners();
  }

  void setEditingCustomerName(String name) {
    _editingCustomerName = name;
    notifyListeners();
  }

  void setEditingCustomerEmail(String email) {
    _editingCustomerEmail = email;
    notifyListeners();
  }

  void setEditingCustomerPhone(String phone) {
    _editingCustomerPhone = phone;
    notifyListeners();
  }

  void setEditingCustomerAddress(String address) {
    _editingCustomerAddress = address;
    notifyListeners();
  }

  void setEditingCustomerGst(String gst) {
    _editingCustomerGst = gst;
    notifyListeners();
  }

  void selectInvoice(InvoiceModel? invoice) {
    _selectedInvoice = invoice;
    if (invoice != null) {
      loadInvoiceDetails(invoice.id);
    } else {
      _selectedInvoiceItems = [];
      notifyListeners();
    }
  }

  Future<void> searchInvoices(String query) async {
    try {
      _isSearching = true;
      _searchQuery = query;
      notifyListeners();

      if (query.trim().isEmpty) {
        _filteredInvoices = [];
      } else {
        final q = query.toLowerCase();
        _filteredInvoices = _invoices.where((i) {
          return i.invoiceNumber.toLowerCase().contains(q) ||
              i.customerName.toLowerCase().contains(q) ||
              i.customerPhone?.toLowerCase().contains(q) == true;
        }).toList();
      }

      _isSearching = false;
      notifyListeners();
    } catch (e, stackTrace) {
      _isSearching = false;
      notifyListeners();
      Logger.error('Failed to search invoices', e, stackTrace);
    }
  }

  void filterByStatus(InvoiceStatus? status) {
    _selectedStatus = status;
    _applyFilters();
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    _filteredInvoices = [];
    notifyListeners();
  }

  void clearFilters() {
    _selectedStatus = null;
    _searchQuery = '';
    _filteredInvoices = [];
    notifyListeners();
  }

  void _applyFilters() {
    var filtered = List<InvoiceModel>.from(_invoices);

    if (_selectedStatus != null) {
      filtered = filtered.where((i) => i.status == _selectedStatus).toList();
    }

    _filteredInvoices = filtered;
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
