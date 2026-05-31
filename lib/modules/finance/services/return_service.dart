import 'package:siddhivinayak_enterprise/core/constants/storage_keys.dart';
import 'package:siddhivinayak_enterprise/core/storage/storage_service.dart';
import 'package:siddhivinayak_enterprise/core/utils/logger.dart';
import 'package:siddhivinayak_enterprise/modules/invoice/repositories/invoice_repository.dart';
import 'package:siddhivinayak_enterprise/modules/products/repositories/product_repository.dart';
import 'package:uuid/uuid.dart';

class ReturnService {
  final InvoiceRepository _invoiceRepository;
  final ProductRepository _productRepository;
  final StorageService<Map<dynamic, dynamic>> _returnStorage;

  ReturnService({
    required InvoiceRepository invoiceRepository,
    required ProductRepository productRepository,
  })  : _invoiceRepository = invoiceRepository,
        _productRepository = productRepository,
        _returnStorage =
            StorageService<Map<dynamic, dynamic>>(StorageKeys.returnsBox);

  Future<Map<String, dynamic>> createReturn({
    required String invoiceId,
    required List<Map<String, dynamic>> returnedItems,
    required String reason,
  }) async {
    try {
      final invoice = await _invoiceRepository.getById(invoiceId);
      if (invoice == null) {
        throw Exception('Invoice not found');
      }

      double refundAmount = 0;
      for (final item in returnedItems) {
        final productId = item['productId'] as String;
        final quantity = (item['quantity'] as num).toDouble();
        final product = await _productRepository.getById(productId);
        if (product != null) {
          final restoredQuantity =
              product.stockQuantity + quantity.toInt();
          final updatedProduct = product.copyWith(
            stockQuantity: restoredQuantity,
            updatedAt: DateTime.now(),
          );
          await _productRepository.update(updatedProduct);
        }
        refundAmount +=
            (item['unitPrice'] as num).toDouble() * quantity;
      }

      final returnId = const Uuid().v4();
      final now = DateTime.now();
      final returnMap = {
        'id': returnId,
        'invoiceId': invoiceId,
        'invoiceNumber': invoice.invoiceNumber,
        'customerName': invoice.customerName,
        'items': returnedItems,
        'reason': reason,
        'refundAmount': refundAmount,
        'returnDate': now.toIso8601String(),
        'createdAt': now.toIso8601String(),
      };

      await _returnStorage.save(returnId, returnMap);

      Logger.success('Return created: $returnId for invoice $invoiceId');
      return returnMap;
    } catch (e, stackTrace) {
      Logger.error('Failed to create return', e, stackTrace);
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getAllReturns() async {
    try {
      return _returnStorage.getAll()
          .map((e) => Map<String, dynamic>.from(e))
          .toList()
        ..sort((a, b) {
          final ad = DateTime.tryParse(a['createdAt'] as String? ?? '');
          final bd = DateTime.tryParse(b['createdAt'] as String? ?? '');
          return bd?.compareTo(ad ?? DateTime(2000)) ?? 0;
        });
    } catch (e, stackTrace) {
      Logger.error('Failed to get all returns', e, stackTrace);
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getReturnsByInvoice(
      String invoiceId) async {
    try {
      final all = await getAllReturns();
      return all.where((r) => r['invoiceId'] == invoiceId).toList();
    } catch (e, stackTrace) {
      Logger.error('Failed to get returns by invoice', e, stackTrace);
      return [];
    }
  }

  Future<double> getTotalReturns() async {
    final returns = await getAllReturns();
    return returns.fold<double>(
      0,
      (sum, r) => sum + ((r['refundAmount'] as num?)?.toDouble() ?? 0),
    );
  }

  Future<List<Map<String, dynamic>>> getReturnsByDateRange(
      DateTime start, DateTime end) async {
    final all = await getAllReturns();
    return all.where((r) {
      final date = DateTime.tryParse(r['returnDate'] as String? ?? '');
      if (date == null) return false;
      return !date.isBefore(start) && !date.isAfter(end);
    }).toList();
  }
}
