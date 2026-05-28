import 'package:SmartERP/core/exceptions/app_exception.dart';
import 'package:SmartERP/core/models/invoice_model.dart';
import 'package:SmartERP/core/models/payment_model.dart';
import 'package:SmartERP/core/utils/logger.dart';
import 'package:SmartERP/modules/invoice/repositories/invoice_repository.dart';
import 'package:SmartERP/modules/invoice/repositories/payment_repository.dart';
import 'package:uuid/uuid.dart';

class PaymentService {
  final PaymentRepository _repository;
  final InvoiceRepository _invoiceRepository;

  PaymentService(PaymentRepository repository, InvoiceRepository invoiceRepository)
      : _repository = repository,
        _invoiceRepository = invoiceRepository;

  Future<List<PaymentModel>> getAllPayments() async {
    try {
      return await _repository.getAll();
    } catch (e, stackTrace) {
      Logger.error('Failed to get all payments', e, stackTrace);
      rethrow;
    }
  }

  Future<PaymentModel?> getPaymentById(String id) async {
    try {
      return await _repository.getById(id);
    } catch (e, stackTrace) {
      Logger.error('Failed to get payment by id', e, stackTrace);
      return null;
    }
  }

  Future<List<PaymentModel>> getPaymentsByInvoiceId(String invoiceId) async {
    try {
      return await _repository.getByInvoiceId(invoiceId);
    } catch (e, stackTrace) {
      Logger.error('Failed to get payments by invoice id', e, stackTrace);
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

      final invoice = await _invoiceRepository.getById(invoiceId);
      if (invoice == null) {
        throw NotFoundException('Invoice not found');
      }

      if (invoice.status == InvoiceStatus.cancelled) {
        throw ValidationException('Cannot record payment for cancelled invoice');
      }

      if (invoice.status == InvoiceStatus.paid) {
        throw ValidationException('Invoice is already fully paid');
      }

      final payment = PaymentModel.create(
        invoiceId: invoiceId,
        amount: amount,
        paymentDate: paymentDate,
        mode: mode,
        reference: reference?.trim(),
        notes: notes?.trim(),
      );

      await _repository.save(payment);

      final totalPaid = await _repository.getTotalPaidForInvoice(invoiceId);
      final newStatus = totalPaid >= invoice.totalAmount
          ? InvoiceStatus.paid
          : InvoiceStatus.partiallyPaid;

      final updatedInvoice = invoice.copyWith(
        paidAmount: totalPaid,
        status: newStatus,
        updatedAt: DateTime.now(),
      );

      await _invoiceRepository.update(updatedInvoice);
      Logger.success(
          'Payment recorded: ${payment.id} for invoice: $invoiceId');
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

      final totalPaid =
          await _repository.getTotalPaidForInvoice(payment.invoiceId);
      final invoice = await _invoiceRepository.getById(payment.invoiceId);

      if (invoice != null) {
        InvoiceStatus newStatus;
        if (totalPaid <= 0) {
          newStatus = invoice.status == InvoiceStatus.cancelled
              ? InvoiceStatus.cancelled
              : InvoiceStatus.sent;
        } else if (totalPaid >= invoice.totalAmount) {
          newStatus = InvoiceStatus.paid;
        } else {
          newStatus = InvoiceStatus.partiallyPaid;
        }

        final updatedInvoice = invoice.copyWith(
          paidAmount: totalPaid,
          status: newStatus,
          updatedAt: DateTime.now(),
        );

        await _invoiceRepository.update(updatedInvoice);
      }

      Logger.success('Payment deleted: $id');
    } catch (e, stackTrace) {
      Logger.error('Failed to delete payment', e, stackTrace);
      rethrow;
    }
  }
}
