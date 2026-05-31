import 'package:flutter/foundation.dart';
import 'package:SmartERP/core/exceptions/app_exception.dart';
import 'package:SmartERP/core/models/invoice_item_model.dart';
import 'package:SmartERP/core/models/invoice_model.dart';
import 'package:SmartERP/core/models/product_model.dart';
import 'package:SmartERP/core/utils/logger.dart';
import 'package:SmartERP/modules/invoice/services/invoice_service.dart';
import 'package:SmartERP/modules/products/providers/product_provider.dart';
import 'package:uuid/uuid.dart';

class InvoiceProvider extends ChangeNotifier {
  final InvoiceService _service;
  VoidCallback? onDataChanged;
  ProductProvider? _productProvider;

  InvoiceProvider({required InvoiceService service, VoidCallback? onDataChanged})
      : _service = service,
        onDataChanged = onDataChanged;

  void attachProductProvider(ProductProvider productProvider) {
    _productProvider = productProvider;
  }

  List<InvoiceModel> _invoices = [];
  InvoiceModel? _selectedInvoice;
  List<InvoiceItemModel> _selectedInvoiceItems = [];
  List<InvoiceModel> _filteredInvoices = [];

  String _editingCustomerId = '';
  String _editingCustomerName = '';
  String _editingCustomerEmail = '';
  String _editingCustomerPhone = '';
  String _editingCustomerAddress = '';
  String _editingCustomerGst = '';
  DateTime _editingInvoiceDate = DateTime.now();
  DateTime _editingDueDate = DateTime.now().add(const Duration(days: 30));
  List<InvoiceItemModel> _editingItems = [];
  double _editingDiscount = 0;
  String _editingNotes = '';
  String _editingTerms = '';

  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  InvoiceStatus? _filterStatus;

  double get editingSubtotal =>
      _editingItems.fold(0.0, (sum, item) => sum + item.unitPrice * item.quantity);

  double get editingTaxAmount =>
      _editingItems.fold(0.0, (sum, item) => sum + item.taxAmount);

  double get editingTotalAmount =>
      editingSubtotal + editingTaxAmount - _editingDiscount;

  double get editingCgstAmount => editingTaxAmount / 2;
  double get editingSgstAmount => editingTaxAmount / 2;
  double get editingIgstAmount => 0.0;

  double get editingRoundOff {
    final rounded = editingTotalAmount.roundToDouble();
    return rounded - editingTotalAmount;
  }

  double get editingGrandTotal => editingTotalAmount + editingRoundOff;

  String? validateStockForItems() {
    if (_productProvider == null) return null;
    for (final item in _editingItems) {
      if (item.productId.isNotEmpty) {
        final product = _productProvider!.products
            .where((p) => p.id == item.productId)
            .toList();
        if (product.isNotEmpty) {
          final available = product.first.stockQuantity;
          if (item.quantity.toInt() > available) {
            return 'Insufficient stock for ${item.productName}. Available: $available, Requested: ${item.quantity.toInt()}';
          }
        }
      }
    }
    return null;
  }

  List<InvoiceModel> get invoices {
    if (_filterStatus != null) {
      return _filteredInvoices;
    }
    if (_searchQuery.isNotEmpty) {
      return _filteredInvoices;
    }
    return _invoices;
  }

  InvoiceModel? get selectedInvoice => _selectedInvoice;
  List<InvoiceItemModel> get selectedInvoiceItems => _selectedInvoiceItems;

  String get editingCustomerId => _editingCustomerId;
  String get editingCustomerName => _editingCustomerName;
  String get editingCustomerEmail => _editingCustomerEmail;
  String get editingCustomerPhone => _editingCustomerPhone;
  String get editingCustomerAddress => _editingCustomerAddress;
  String get editingCustomerGst => _editingCustomerGst;
  DateTime get editingInvoiceDate => _editingInvoiceDate;
  DateTime get editingDueDate => _editingDueDate;
  List<InvoiceItemModel> get editingItems => _editingItems;
  double get editingDiscount => _editingDiscount;
  String get editingNotes => _editingNotes;
  String get editingTerms => _editingTerms;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  InvoiceStatus? get filterStatus => _filterStatus;

  bool get isFormValid =>
      _editingCustomerName.trim().isNotEmpty &&
      _editingItems.isNotEmpty;

  int get totalInvoices => _invoices.length;
  int get draftCount =>
      _invoices.where((i) => i.status == InvoiceStatus.draft).length;
  int get sentCount =>
      _invoices.where((i) => i.status == InvoiceStatus.sent).length;
  int get paidCount =>
      _invoices.where((i) => i.status == InvoiceStatus.paid).length;
  int get overdueCount =>
      _invoices.where((i) => i.isOverdue).length;
  int get cancelledCount =>
      _invoices.where((i) => i.status == InvoiceStatus.cancelled).length;
  double get totalOutstanding =>
      _invoices.fold(0.0, (sum, i) => sum + i.balanceAmount);

  Future<void> loadInvoices() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _invoices = await _service.getAllInvoices();

      _isLoading = false;
      notifyListeners();
      onDataChanged?.call();
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
        _selectedInvoiceItems = [];
        for (final itemId in _selectedInvoice!.itemIds) {
          final item = await _service.getInvoiceItemById(itemId);
          if (item != null) {
            _selectedInvoiceItems.add(item);
          }
        }
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

  Future<void> createInvoice() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final invoice = await _service.createInvoice(
        customerId: _editingCustomerId,
        customerName: _editingCustomerName,
        customerEmail: _editingCustomerEmail.isNotEmpty
            ? _editingCustomerEmail
            : null,
        customerPhone: _editingCustomerPhone.isNotEmpty
            ? _editingCustomerPhone
            : null,
        customerAddress: _editingCustomerAddress.isNotEmpty
            ? _editingCustomerAddress
            : null,
        customerGst:
            _editingCustomerGst.isNotEmpty ? _editingCustomerGst : null,
        invoiceDate: _editingInvoiceDate,
        dueDate: _editingDueDate,
        items: _editingItems,
        subtotal: editingSubtotal,
        taxAmount: editingTaxAmount,
        discountAmount: _editingDiscount,
        totalAmount: editingTotalAmount,
        notes: _editingNotes.isNotEmpty ? _editingNotes : null,
        termsAndConditions:
            _editingTerms.isNotEmpty ? _editingTerms : null,
      );

      _invoices.add(invoice);
      await _productProvider?.loadProducts();
      resetEditingState();

      _isLoading = false;
      notifyListeners();
      onDataChanged?.call();
      Logger.success('Invoice created: ${invoice.invoiceNumber}');
    } on ValidationException catch (e) {
      _isLoading = false;
      _errorMessage = e.message;
      notifyListeners();
      rethrow;
    } catch (e, stackTrace) {
      _isLoading = false;
      _errorMessage = 'Failed to create invoice';
      notifyListeners();
      Logger.error('Failed to create invoice', e, stackTrace);
      rethrow;
    }
  }

  Future<void> saveDraft() async {
    _editingInvoiceDate = DateTime.now();
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final invoice = await _service.createInvoice(
        customerId: _editingCustomerId,
        customerName: _editingCustomerName,
        customerEmail: _editingCustomerEmail.isNotEmpty
            ? _editingCustomerEmail
            : null,
        customerPhone: _editingCustomerPhone.isNotEmpty
            ? _editingCustomerPhone
            : null,
        customerAddress: _editingCustomerAddress.isNotEmpty
            ? _editingCustomerAddress
            : null,
        customerGst:
            _editingCustomerGst.isNotEmpty ? _editingCustomerGst : null,
        invoiceDate: _editingInvoiceDate,
        dueDate: _editingDueDate,
        items: _editingItems,
        subtotal: editingSubtotal,
        taxAmount: editingTaxAmount,
        discountAmount: _editingDiscount,
        totalAmount: editingTotalAmount,
        notes: _editingNotes.isNotEmpty ? _editingNotes : null,
        termsAndConditions:
            _editingTerms.isNotEmpty ? _editingTerms : null,
      );

      _invoices.add(invoice);
      await _productProvider?.loadProducts();
      resetEditingState();

      _isLoading = false;
      notifyListeners();
      onDataChanged?.call();
      Logger.success('Draft saved: ${invoice.invoiceNumber}');
    } on ValidationException catch (e) {
      _isLoading = false;
      _errorMessage = e.message;
      notifyListeners();
      rethrow;
    } catch (e, stackTrace) {
      _isLoading = false;
      _errorMessage = 'Failed to save draft';
      notifyListeners();
      Logger.error('Failed to save draft', e, stackTrace);
      rethrow;
    }
  }

  Future<void> updateInvoice(String id) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final updatedInvoice = await _service.updateInvoice(
        id: id,
        customerId: _editingCustomerId,
        customerName: _editingCustomerName,
        customerEmail: _editingCustomerEmail.isNotEmpty
            ? _editingCustomerEmail
            : null,
        customerPhone: _editingCustomerPhone.isNotEmpty
            ? _editingCustomerPhone
            : null,
        customerAddress: _editingCustomerAddress.isNotEmpty
            ? _editingCustomerAddress
            : null,
        customerGst:
            _editingCustomerGst.isNotEmpty ? _editingCustomerGst : null,
        invoiceDate: _editingInvoiceDate,
        dueDate: _editingDueDate,
        items: _editingItems,
        subtotal: editingSubtotal,
        taxAmount: editingTaxAmount,
        discountAmount: _editingDiscount,
        totalAmount: editingTotalAmount,
        notes: _editingNotes.isNotEmpty ? _editingNotes : null,
        termsAndConditions:
            _editingTerms.isNotEmpty ? _editingTerms : null,
      );

      final index = _invoices.indexWhere((i) => i.id == id);
      if (index != -1) {
        _invoices[index] = updatedInvoice;
      }

      if (_selectedInvoice?.id == id) {
        _selectedInvoice = updatedInvoice;
      }

      await _productProvider?.loadProducts();
      resetEditingState();

      _isLoading = false;
      notifyListeners();
      onDataChanged?.call();
      Logger.success('Invoice updated successfully');
    } on ValidationException catch (e) {
      _isLoading = false;
      _errorMessage = e.message;
      notifyListeners();
      rethrow;
    } catch (e, stackTrace) {
      _isLoading = false;
      _errorMessage = 'Failed to update invoice';
      notifyListeners();
      Logger.error('Failed to update invoice', e, stackTrace);
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

      await _productProvider?.loadProducts();
      _isLoading = false;
      notifyListeners();
      onDataChanged?.call();
      Logger.success('Invoice deleted successfully');
    } catch (e, stackTrace) {
      _isLoading = false;
      _errorMessage = 'Failed to delete invoice';
      notifyListeners();
      Logger.error('Failed to delete invoice', e, stackTrace);
      rethrow;
    }
  }

  Future<void> markAsSent(String id) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _service.markAsSent(id);

      final index = _invoices.indexWhere((i) => i.id == id);
      if (index != -1) {
        _invoices[index] = _invoices[index].copyWith(
          status: InvoiceStatus.sent,
          updatedAt: DateTime.now(),
        );
      }

      if (_selectedInvoice?.id == id) {
        _selectedInvoice = _selectedInvoice!.copyWith(
          status: InvoiceStatus.sent,
          updatedAt: DateTime.now(),
        );
      }

      _isLoading = false;
      notifyListeners();
      onDataChanged?.call();
      Logger.success('Invoice marked as sent');
    } catch (e, stackTrace) {
      _isLoading = false;
      _errorMessage = 'Failed to mark invoice as sent';
      notifyListeners();
      Logger.error('Failed to mark invoice as sent', e, stackTrace);
      rethrow;
    }
  }

  Future<void> markAsPaid(String id, double amount) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _service.markAsPaid(id, amount);

      final invoice = await _service.getInvoiceById(id);
      if (invoice != null) {
        final index = _invoices.indexWhere((i) => i.id == id);
        if (index != -1) {
          _invoices[index] = invoice;
        }
        if (_selectedInvoice?.id == id) {
          _selectedInvoice = invoice;
        }
      }

      _isLoading = false;
      notifyListeners();
      onDataChanged?.call();
      Logger.success('Invoice marked as paid');
    } catch (e, stackTrace) {
      _isLoading = false;
      _errorMessage = 'Failed to mark invoice as paid';
      notifyListeners();
      Logger.error('Failed to mark invoice as paid', e, stackTrace);
      rethrow;
    }
  }

  Future<void> cancelInvoice(String id) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _service.cancelInvoice(id);

      final index = _invoices.indexWhere((i) => i.id == id);
      if (index != -1) {
        _invoices[index] = _invoices[index].copyWith(
          status: InvoiceStatus.cancelled,
          updatedAt: DateTime.now(),
        );
      }

      if (_selectedInvoice?.id == id) {
        _selectedInvoice = _selectedInvoice!.copyWith(
          status: InvoiceStatus.cancelled,
          updatedAt: DateTime.now(),
        );
      }

      await _productProvider?.loadProducts();
      _isLoading = false;
      notifyListeners();
      onDataChanged?.call();
      Logger.success('Invoice cancelled');
    } catch (e, stackTrace) {
      _isLoading = false;
      _errorMessage = 'Failed to cancel invoice';
      notifyListeners();
      Logger.error('Failed to cancel invoice', e, stackTrace);
      rethrow;
    }
  }

  Future<void> searchInvoices(String query) async {
    try {
      _isLoading = true;
      _searchQuery = query;
      notifyListeners();

      if (query.trim().isEmpty) {
        _filteredInvoices = [];
      } else {
        _filteredInvoices = await _service.searchInvoices(query);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e, stackTrace) {
      _isLoading = false;
      notifyListeners();
      Logger.error('Failed to search invoices', e, stackTrace);
    }
  }

  Future<void> filterByStatus(InvoiceStatus? status) async {
    try {
      _isLoading = true;
      _filterStatus = status;
      notifyListeners();

      if (status == null) {
        _filteredInvoices = [];
      } else {
        _filteredInvoices = await _service.getInvoicesByStatus(status);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e, stackTrace) {
      _isLoading = false;
      notifyListeners();
      Logger.error('Failed to filter invoices', e, stackTrace);
    }
  }

  void resetEditingState() {
    _editingCustomerId = '';
    _editingCustomerName = '';
    _editingCustomerEmail = '';
    _editingCustomerPhone = '';
    _editingCustomerAddress = '';
    _editingCustomerGst = '';
    _editingInvoiceDate = DateTime.now();
    _editingDueDate = DateTime.now().add(const Duration(days: 30));
    _editingItems = [];
    _editingDiscount = 0;
    _editingNotes = '';
    _editingTerms = '';
    notifyListeners();
  }

  void setEditingCustomerId(String value) {
    _editingCustomerId = value;
    notifyListeners();
  }

  void setEditingCustomerName(String value) {
    _editingCustomerName = value;
    notifyListeners();
  }

  void setEditingCustomerEmail(String value) {
    _editingCustomerEmail = value;
    notifyListeners();
  }

  void setEditingCustomerPhone(String value) {
    _editingCustomerPhone = value;
    notifyListeners();
  }

  void setEditingCustomerAddress(String value) {
    _editingCustomerAddress = value;
    notifyListeners();
  }

  void setEditingCustomerGst(String value) {
    _editingCustomerGst = value;
    notifyListeners();
  }

  void setEditingInvoiceDate(DateTime value) {
    _editingInvoiceDate = value;
    notifyListeners();
  }

  void setEditingDueDate(DateTime value) {
    _editingDueDate = value;
    notifyListeners();
  }

  void addItem({
    required String productId,
    required String productName,
    String? hsnCode,
    String? description,
    required double quantity,
    required String unit,
    required double unitPrice,
    double taxRate = 0,
    double discountRate = 0,
  }) {
    final existingIndex = _editingItems.indexWhere(
      (i) => i.productId == productId && productId.isNotEmpty,
    );

    if (existingIndex != -1) {
      final existing = _editingItems[existingIndex];
      final newQty = existing.quantity + quantity;
      final subtotal = existing.unitPrice * newQty;
      final discountAmt = subtotal * (existing.discountRate / 100);
      final taxableAmt = subtotal - discountAmt;
      final amount = taxableAmt + (taxableAmt * existing.taxRate / 100);
      _editingItems[existingIndex] = existing.copyWith(
        quantity: newQty,
        amount: amount,
      );
    } else {
      final item = InvoiceItemModel.create(
        productId: productId,
        productName: productName,
        hsnCode: hsnCode,
        description: description,
        quantity: quantity,
        unit: unit,
        unitPrice: unitPrice,
        taxRate: taxRate,
        discountRate: discountRate,
      );
      _editingItems.add(item);
    }
    notifyListeners();
  }

  void removeItem(int index) {
    if (index >= 0 && index < _editingItems.length) {
      _editingItems.removeAt(index);
      notifyListeners();
    }
  }

  void updateItemQuantity(int index, double qty) {
    if (index >= 0 && index < _editingItems.length) {
      final item = _editingItems[index];
      final subtotal = item.unitPrice * qty;
      final discountAmount = subtotal * (item.discountRate / 100);
      final taxableAmount = subtotal - discountAmount;
      final amount = taxableAmount + (taxableAmount * item.taxRate / 100);
      _editingItems[index] = item.copyWith(quantity: qty, amount: amount);
      notifyListeners();
    }
  }

  void updateItemPrice(int index, double price) {
    if (index >= 0 && index < _editingItems.length) {
      final item = _editingItems[index];
      final subtotal = price * item.quantity;
      final discountAmount = subtotal * (item.discountRate / 100);
      final taxableAmount = subtotal - discountAmount;
      final amount = taxableAmount + (taxableAmount * item.taxRate / 100);
      _editingItems[index] = item.copyWith(unitPrice: price, amount: amount);
      notifyListeners();
    }
  }

  void setEditingDiscount(double value) {
    _editingDiscount = value;
    notifyListeners();
  }

  void setEditingNotes(String value) {
    _editingNotes = value;
    notifyListeners();
  }

  void setEditingTerms(String value) {
    _editingTerms = value;
    notifyListeners();
  }

  void populateEditingFromInvoice(InvoiceModel invoice,
      {List<InvoiceItemModel>? items}) {
    _editingCustomerId = invoice.customerId;
    _editingCustomerName = invoice.customerName;
    _editingCustomerEmail = invoice.customerEmail ?? '';
    _editingCustomerPhone = invoice.customerPhone ?? '';
    _editingCustomerAddress = invoice.customerAddress ?? '';
    _editingCustomerGst = invoice.customerGst ?? '';
    _editingInvoiceDate = invoice.invoiceDate;
    _editingDueDate = invoice.dueDate;
    _editingItems = items ?? [];
    _editingDiscount = invoice.discountAmount;
    _editingNotes = invoice.notes ?? '';
    _editingTerms = invoice.termsAndConditions ?? '';
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    _filteredInvoices = [];
    _filterStatus = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
