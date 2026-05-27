import 'package:smarterp/core/exceptions/app_exception.dart';
import 'package:smarterp/core/models/payment_model.dart';
import 'package:smarterp/core/utils/logger.dart';
import 'package:smarterp/modules/invoice/repositories/payment_repository.dart';

class PaymentService {
  final PaymentRepository _repository;

  PaymentService(this._repository);

  Future<List<PaymentModel>> getPaymentsForInvoice(String invoiceId) async {
    try {
      return await _repository.getByInvoiceId(invoiceId);
    } catch (e, stackTrace) {
      Logger.error('Failed to get payments for invoice: $invoiceId', e, stackTrace);
      return [];
    }
  }

  Future<PaymentModel> recordPayment({
    required String invoiceId,
    required double amount,
    required DateTime paymentDate,
    PaymentMode mode = PaymentMode.cash,
    String? reference,
    String? notes,
  }) async {
    try {
      if (amount <= 0) {
        throw ValidationException('Payment amount must be greater than 0');
      }

      final payment = PaymentModel.create(
        invoiceId: invoiceId,
        amount: amount,
        paymentDate: paymentDate,
        mode: mode,
        reference: reference,
        notes: notes,
      );

      await _repository.save(payment);
      Logger.success('Payment recorded: ${payment.id} for invoice: $invoiceId');
      return payment;
    } catch (e, stackTrace) {
      Logger.error('Failed to record payment', e, stackTrace);
      rethrow;
    }
  }

  Future<void> deletePayment(String id) async {
    try {
      final payment = await _repository.getById(id);
      if (payment == null) {
        throw NotFoundException('Payment not found');
      }

      await _repository.delete(id);
      Logger.success('Payment deleted: $id');
    } catch (e, stackTrace) {
      Logger.error('Failed to delete payment', e, stackTrace);
      rethrow;
    }
  }

  Future<double> getTotalPaidForInvoice(String invoiceId) async {
    try {
      return await _repository.getTotalPaidByInvoiceId(invoiceId);
    } catch (e, stackTrace) {
      Logger.error('Failed to get total paid for invoice: $invoiceId', e, stackTrace);
      return 0.0;
    }
  }

  Future<int> getPaymentCountForInvoice(String invoiceId) async {
    try {
      return await _repository.getCountByInvoiceId(invoiceId);
    } catch (e, stackTrace) {
      Logger.error('Failed to get payment count for invoice: $invoiceId', e, stackTrace);
      return 0;
    }
  }
}
