import 'package:flutter/foundation.dart';
import 'package:smarterp/core/exceptions/app_exception.dart';
import 'package:smarterp/core/models/payment_model.dart';
import 'package:smarterp/core/utils/logger.dart';
import 'package:smarterp/modules/invoice/services/payment_service.dart';

class PaymentProvider extends ChangeNotifier {
  final PaymentService _service;

  PaymentProvider(this._service);

  List<PaymentModel> _payments = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<PaymentModel> get payments => _payments;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadPaymentsForInvoice(String invoiceId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _payments = await _service.getPaymentsForInvoice(invoiceId);

      _isLoading = false;
      notifyListeners();
    } catch (e, stackTrace) {
      _isLoading = false;
      _errorMessage = 'Failed to load payments';
      notifyListeners();
      Logger.error('Failed to load payments', e, stackTrace);
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

      await _service.recordPayment(
        invoiceId: invoiceId,
        amount: amount,
        paymentDate: paymentDate,
        mode: mode,
        reference: reference,
        notes: notes,
      );

      _payments = await _service.getPaymentsForInvoice(invoiceId);

      _isLoading = false;
      notifyListeners();
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

  Future<void> deletePayment(String id, String invoiceId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _service.deletePayment(id);
      _payments = await _service.getPaymentsForInvoice(invoiceId);

      _isLoading = false;
      notifyListeners();
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

  void clear() {
    _payments = [];
    _errorMessage = null;
    notifyListeners();
  }
}
