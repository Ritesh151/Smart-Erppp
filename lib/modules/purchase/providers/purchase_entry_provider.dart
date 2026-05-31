import 'package:flutter/foundation.dart';
import 'package:siddhivinayak_enterprise/core/exceptions/app_exception.dart';
import 'package:siddhivinayak_enterprise/core/utils/logger.dart';
import 'package:siddhivinayak_enterprise/modules/purchase/services/purchase_entry_service.dart';
import 'package:uuid/uuid.dart';

class PurchaseItemModel {
  String productId;
  String productName;
  String? hsnCode;
  double quantity;
  double purchasePrice;
  double gstRate;
  double discountPercent;
  double total;

  PurchaseItemModel({
    required this.productId,
    required this.productName,
    this.hsnCode,
    required this.quantity,
    required this.purchasePrice,
    this.gstRate = 0,
    this.discountPercent = 0,
    this.total = 0,
  });

  Map<String, dynamic> toMap() => {
    'productId': productId,
    'productName': productName,
    'hsnCode': hsnCode,
    'quantity': quantity,
    'purchasePrice': purchasePrice,
    'gstRate': gstRate,
    'discountPercent': discountPercent,
    'total': total,
  };

  factory PurchaseItemModel.fromMap(Map<String, dynamic> m) => PurchaseItemModel(
    productId: m['productId'] as String? ?? '',
    productName: m['productName'] as String? ?? '',
    hsnCode: m['hsnCode'] as String?,
    quantity: (m['quantity'] as num?)?.toDouble() ?? 0,
    purchasePrice: (m['purchasePrice'] as num?)?.toDouble() ?? 0,
    gstRate: (m['gstRate'] as num?)?.toDouble() ?? 0,
    discountPercent: (m['discountPercent'] as num?)?.toDouble() ?? 0,
    total: (m['total'] as num?)?.toDouble() ?? 0,
  );

  void recalculate() {
    final lineSubtotal = quantity * purchasePrice;
    final discountAmt = lineSubtotal * (discountPercent / 100);
    final taxableAmt = lineSubtotal - discountAmt;
    total = taxableAmt + (taxableAmt * (gstRate / 100));
  }
}

enum PurchaseStatus { draft, ordered, received, cancelled }

class PurchaseEntryProvider extends ChangeNotifier {
  final PurchaseEntryService _service;
  VoidCallback? onDataChanged;

  PurchaseEntryProvider({required PurchaseEntryService service})
      : _service = service;

  List<Map<String, dynamic>> _purchases = [];
  Map<String, dynamic>? _selectedPurchase;
  bool _isLoading = false;
  String? _errorMessage;

  String _purchaseNumber = '';
  DateTime _purchaseDate = DateTime.now();
  String _supplierName = '';
  String _supplierMobile = '';
  String _supplierGst = '';
  String _invoiceNumber = '';
  DateTime _invoiceDate = DateTime.now();
  PurchaseStatus _status = PurchaseStatus.draft;
  List<PurchaseItemModel> _items = [];
  String _notes = '';

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Map<String, dynamic>> get purchases => _purchases;
  Map<String, dynamic>? get selectedPurchase => _selectedPurchase;

  String get purchaseNumber => _purchaseNumber;
  DateTime get purchaseDate => _purchaseDate;
  String get supplierName => _supplierName;
  String get supplierMobile => _supplierMobile;
  String get supplierGst => _supplierGst;
  String get invoiceNumberValue => _invoiceNumber;
  DateTime get invoiceDate => _invoiceDate;
  PurchaseStatus get status => _status;
  List<PurchaseItemModel> get items => _items;
  String get notes => _notes;

  double get subtotal =>
      _items.fold(0.0, (sum, item) => sum + (item.quantity * item.purchasePrice));

  double get discountAmount =>
      _items.fold(0.0, (sum, item) {
        final lineSubtotal = item.quantity * item.purchasePrice;
        return sum + (lineSubtotal * (item.discountPercent / 100));
      });

  double get gstAmount =>
      _items.fold(0.0, (sum, item) {
        final lineSubtotal = item.quantity * item.purchasePrice;
        final discountAmt = lineSubtotal * (item.discountPercent / 100);
        final taxableAmt = lineSubtotal - discountAmt;
        return sum + (taxableAmt * (item.gstRate / 100));
      });

  double get grandTotal =>
      _items.fold(0.0, (sum, item) => sum + item.total);

  int get itemCount => _items.length;

  bool get isFormValid =>
      _supplierName.trim().isNotEmpty && _items.isNotEmpty && _items.any((i) => i.quantity > 0 && i.purchasePrice > 0);

  void setPurchaseDate(DateTime v) { _purchaseDate = v; notifyListeners(); }
  void setSupplierName(String v) { _supplierName = v; notifyListeners(); }
  void setSupplierMobile(String v) { _supplierMobile = v; notifyListeners(); }
  void setSupplierGst(String v) { _supplierGst = v; notifyListeners(); }
  void setInvoiceNumber(String v) { _invoiceNumber = v; notifyListeners(); }
  void setInvoiceDate(DateTime v) { _invoiceDate = v; notifyListeners(); }
  void setStatus(PurchaseStatus v) { _status = v; notifyListeners(); }
  void setNotes(String v) { _notes = v; notifyListeners(); }

  void setPurchaseNumber(String v) { _purchaseNumber = v; }

  Future<void> generatePurchaseNumber() async {
    _purchaseNumber = await _service.getNextPurchaseNumber();
    notifyListeners();
  }

  void addItem({
    required String productId,
    required String productName,
    String? hsnCode,
    double quantity = 1,
    double purchasePrice = 0,
    double gstRate = 0,
    double discountPercent = 0,
  }) {
    final existingIndex = _items.indexWhere((i) =>
        i.productId == productId && productId.isNotEmpty);
    if (existingIndex != -1) {
      final existing = _items[existingIndex];
      existing.quantity += quantity;
      existing.recalculate();
    } else {
      final item = PurchaseItemModel(
        productId: productId,
        productName: productName,
        hsnCode: hsnCode,
        quantity: quantity,
        purchasePrice: purchasePrice,
        gstRate: gstRate,
        discountPercent: discountPercent,
      );
      item.recalculate();
      _items.add(item);
    }
    notifyListeners();
  }

  void removeItem(int index) {
    if (index >= 0 && index < _items.length) {
      _items.removeAt(index);
      notifyListeners();
    }
  }

  void updateItemQuantity(int index, double qty) {
    if (index >= 0 && index < _items.length) {
      _items[index].quantity = qty;
      _items[index].recalculate();
      notifyListeners();
    }
  }

  void updateItemPrice(int index, double price) {
    if (index >= 0 && index < _items.length) {
      _items[index].purchasePrice = price;
      _items[index].recalculate();
      notifyListeners();
    }
  }

  void updateItemGst(int index, double gst) {
    if (index >= 0 && index < _items.length) {
      _items[index].gstRate = gst;
      _items[index].recalculate();
      notifyListeners();
    }
  }

  void updateItemDiscount(int index, double discount) {
    if (index >= 0 && index < _items.length) {
      _items[index].discountPercent = discount;
      _items[index].recalculate();
      notifyListeners();
    }
  }

  void resetEditingState() {
    _purchaseNumber = '';
    _purchaseDate = DateTime.now();
    _supplierName = '';
    _supplierMobile = '';
    _supplierGst = '';
    _invoiceNumber = '';
    _invoiceDate = DateTime.now();
    _status = PurchaseStatus.draft;
    _items = [];
    _notes = '';
    _selectedPurchase = null;
    _errorMessage = null;
    notifyListeners();
  }

  void populateForEdit(Map<String, dynamic> purchase) {
    _purchaseNumber = purchase['purchaseNumber'] as String? ?? '';
    _purchaseDate = DateTime.tryParse(purchase['purchaseDate'] as String? ?? '') ?? DateTime.now();
    _supplierName = purchase['supplierName'] as String? ?? '';
    _supplierMobile = purchase['supplierMobile'] as String? ?? '';
    _supplierGst = purchase['supplierGst'] as String? ?? '';
    _invoiceNumber = purchase['invoiceNumber'] as String? ?? '';
    _invoiceDate = DateTime.tryParse(purchase['invoiceDate'] as String? ?? '') ?? DateTime.now();
    final statusStr = purchase['status'] as String? ?? 'draft';
    _status = PurchaseStatus.values.firstWhere(
      (s) => s.name == statusStr,
      orElse: () => PurchaseStatus.draft,
    );
    _notes = purchase['notes'] as String? ?? '';
    final rawItems = purchase['items'] as List<dynamic>? ?? [];
    _items = rawItems.map((e) => PurchaseItemModel.fromMap(Map<String, dynamic>.from(e as Map))).toList();
    _selectedPurchase = purchase;
    notifyListeners();
  }

  Future<void> loadPurchases() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
      _purchases = await _service.getAll();
      _isLoading = false;
      notifyListeners();
      onDataChanged?.call();
    } catch (e, stackTrace) {
      _isLoading = false;
      _errorMessage = 'Failed to load purchases';
      notifyListeners();
      Logger.error('Failed to load purchases', e, stackTrace);
    }
  }

  Future<void> loadPurchaseById(String id) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
      final purchase = _service.getById(id);
      if (purchase != null) {
        populateForEdit(purchase);
      }
      _isLoading = false;
      notifyListeners();
    } catch (e, stackTrace) {
      _isLoading = false;
      _errorMessage = 'Failed to load purchase details';
      notifyListeners();
      Logger.error('Failed to load purchase details', e, stackTrace);
    }
  }

  Future<Map<String, dynamic>> _buildPurchaseMap({bool updateStock = true}) async {
    if (_purchaseNumber.isEmpty) {
      await generatePurchaseNumber();
    }
    final id = _selectedPurchase?['id'] as String? ?? const Uuid().v4();
    return {
      'id': id,
      'purchaseNumber': _purchaseNumber,
      'purchaseDate': _purchaseDate.toIso8601String(),
      'supplierName': _supplierName.trim(),
      'supplierMobile': _supplierMobile.trim(),
      'supplierGst': _supplierGst.trim(),
      'invoiceNumber': _invoiceNumber.trim(),
      'invoiceDate': _invoiceDate.toIso8601String(),
      'status': _status.name,
      'notes': _notes.trim(),
      'subtotal': subtotal,
      'gstAmount': gstAmount,
      'discountAmount': discountAmount,
      'totalAmount': grandTotal,
      'items': _items.map((i) => i.toMap()).toList(),
      'itemCount': _items.length,
      'updateStock': updateStock,
    };
  }

  Future<void> savePurchase({bool updateStock = true}) async {
    if (!isFormValid) {
      throw ValidationException('Please fill all required fields');
    }
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
      final map = await _buildPurchaseMap(updateStock: updateStock);
      await _service.savePurchase(map);
      resetEditingState();
      _isLoading = false;
      notifyListeners();
      onDataChanged?.call();
      Logger.success('Purchase saved successfully');
    } on ValidationException catch (e) {
      _isLoading = false;
      _errorMessage = e.message;
      notifyListeners();
      rethrow;
    } catch (e, stackTrace) {
      _isLoading = false;
      _errorMessage = 'Failed to save purchase';
      notifyListeners();
      Logger.error('Failed to save purchase', e, stackTrace);
      rethrow;
    }
  }

  Future<void> updatePurchase({bool updateStock = true}) async {
    if (!isFormValid) {
      throw ValidationException('Please fill all required fields');
    }
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
      final map = await _buildPurchaseMap(updateStock: updateStock);
      map['createdAt'] = _selectedPurchase?['createdAt'];
      await _service.updatePurchase(map);
      resetEditingState();
      _isLoading = false;
      notifyListeners();
      onDataChanged?.call();
      Logger.success('Purchase updated successfully');
    } on ValidationException catch (e) {
      _isLoading = false;
      _errorMessage = e.message;
      notifyListeners();
      rethrow;
    } catch (e, stackTrace) {
      _isLoading = false;
      _errorMessage = 'Failed to update purchase';
      notifyListeners();
      Logger.error('Failed to update purchase', e, stackTrace);
      rethrow;
    }
  }

  Future<void> deletePurchase(String id) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
      await _service.deletePurchase(id);
      _purchases.removeWhere((p) => p['id'] == id);
      if (_selectedPurchase?['id'] == id) {
        _selectedPurchase = null;
      }
      _isLoading = false;
      notifyListeners();
      onDataChanged?.call();
      Logger.success('Purchase deleted successfully');
    } catch (e, stackTrace) {
      _isLoading = false;
      _errorMessage = 'Failed to delete purchase';
      notifyListeners();
      Logger.error('Failed to delete purchase', e, stackTrace);
      rethrow;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
