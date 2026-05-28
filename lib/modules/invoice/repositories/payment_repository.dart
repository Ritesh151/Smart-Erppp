import 'package:SmartERP/core/exceptions/app_exception.dart';
import 'package:SmartERP/core/models/payment_model.dart';
import 'package:SmartERP/core/storage/storage_service.dart';
import 'package:SmartERP/core/utils/logger.dart';

class PaymentRepository {
  final StorageService<Map<dynamic, dynamic>> _storage;

  PaymentRepository(this._storage);

  Future<List<PaymentModel>> getAll() async {
    try {
      final data = _storage.getAll();
      return data
          .map((item) => PaymentModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } catch (e, stackTrace) {
      Logger.error('Failed to get all payments', e, stackTrace);
      throw StorageException('Failed to retrieve payments');
    }
  }

  Future<PaymentModel?> getById(String id) async {
    try {
      final data = _storage.get(id);
      if (data == null) return null;
      return PaymentModel.fromJson(Map<String, dynamic>.from(data));
    } catch (e, stackTrace) {
      Logger.error('Failed to get payment by id: $id', e, stackTrace);
      return null;
    }
  }

  Future<void> save(PaymentModel payment) async {
    try {
      await _storage.save(payment.id, payment.toJson());
      Logger.success('Payment saved: ${payment.id}');
    } catch (e, stackTrace) {
      Logger.error('Failed to save payment', e, stackTrace);
      throw StorageException('Failed to save payment');
    }
  }

  Future<void> update(PaymentModel payment) async {
    try {
      await _storage.update(payment.id, payment.toJson());
      Logger.success('Payment updated: ${payment.id}');
    } catch (e, stackTrace) {
      Logger.error('Failed to update payment', e, stackTrace);
      throw StorageException('Failed to update payment');
    }
  }

  Future<void> delete(String id) async {
    try {
      await _storage.delete(id);
      Logger.success('Payment deleted: $id');
    } catch (e, stackTrace) {
      Logger.error('Failed to delete payment', e, stackTrace);
      throw StorageException('Failed to delete payment');
    }
  }

  Future<List<PaymentModel>> getByInvoiceId(String invoiceId) async {
    try {
      final payments = await getAll();
      return payments.where((p) => p.invoiceId == invoiceId).toList();
    } catch (e, stackTrace) {
      Logger.error('Failed to get payments by invoice id', e, stackTrace);
      return [];
    }
  }

  Future<double> getTotalPaidForInvoice(String invoiceId) async {
    try {
      final payments = await getByInvoiceId(invoiceId);
      return payments.fold<double>(0.0, (sum, p) => sum + p.amount);
    } catch (e, stackTrace) {
      Logger.error('Failed to get total paid for invoice', e, stackTrace);
      return 0.0;
    }
  }

  Future<bool> exists(String id) async {
    try {
      return _storage.containsKey(id);
    } catch (e, stackTrace) {
      Logger.error('Failed to check payment existence', e, stackTrace);
      return false;
    }
  }
}
