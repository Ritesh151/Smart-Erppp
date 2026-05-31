import 'package:flutter/foundation.dart';
import 'package:siddhivinayak_enterprise/core/exceptions/app_exception.dart';
import 'package:siddhivinayak_enterprise/core/models/payment_model.dart';
import 'package:siddhivinayak_enterprise/core/utils/logger.dart';
import 'package:siddhivinayak_enterprise/modules/invoice/services/payment_service.dart';

class PaymentProvider extends ChangeNotifier {
  final PaymentService _service;
  VoidCallback? onDataChanged;

  PaymentProvider(this._service, {VoidCallback? onDataChanged})
      : onDataChanged = onDataChanged;

  List<PaymentModel> _payments = [];

  bool _isLoading = false;
  String? _errorMessage;

  List<PaymentModel> get payments => _payments;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadPayments() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _payments = await _service.getAllPayments();

      _isLoading = false;
      notifyListeners();
      onDataChanged?.call();
      Logger.success('Payments loaded: ${_payments.length}');
    } catch (e, stackTrace) {
      _isLoading = false;
      _errorMessage = 'Failed to load payments';
      notifyListeners();
      Logger.error('Failed to load payments', e, stackTrace);
    }
  }

  Future<void> loadPaymentsForInvoice(String invoiceId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _payments = await _service.getPaymentsByInvoiceId(invoiceId);

      _isLoading = false;
      notifyListeners();
    } catch (e, stackTrace) {
      _isLoading = false;
      _errorMessage = 'Failed to load payments for invoice';
      notifyListeners();
      Logger.error('Failed to load payments for invoice', e, stackTrace);
    }
  }

  Future<void> recordPayment({
    required String invoiceId,
    required double amount,
    required DateTime paymentDate,
    PaymentMode mode = PaymentMode.cash,
    String? reference,
    String? notes,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final payment = await _service.recordPayment(
        invoiceId: invoiceId,
        amount: amount,
        paymentDate: paymentDate,
        mode: mode,
        reference: reference,
        notes: notes,
      );

      _payments.add(payment);

      _isLoading = false;
      notifyListeners();
      onDataChanged?.call();
      Logger.success('Payment recorded successfully');
    } on ValidationException catch (e) {
      _isLoading = false;
      _errorMessage = e.message;
      notifyListeners();
      rethrow;
    } catch (e, stackTrace) {
      _isLoading = false;
      _errorMessage = 'Failed to record payment';
      notifyListeners();
      Logger.error('Failed to record payment', e, stackTrace);
      rethrow;
    }
  }

  Future<void> deletePayment(String id) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _service.deletePayment(id);
      _payments.removeWhere((p) => p.id == id);

      _isLoading = false;
      notifyListeners();
      onDataChanged?.call();
      Logger.success('Payment deleted successfully');
    } catch (e, stackTrace) {
      _isLoading = false;
      _errorMessage = 'Failed to delete payment';
      notifyListeners();
      Logger.error('Failed to delete payment', e, stackTrace);
      rethrow;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
