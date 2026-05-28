import 'package:SmartERP/modules/transport/models/transport_screen_model.dart';
import 'package:SmartERP/modules/transport/repositories/transport_repository.dart';
import 'package:SmartERP/modules/products/repositories/product_repository.dart';
import 'package:SmartERP/modules/finance/repositories/finance_repository.dart';

class TransportStatusService {
  final TransportRepository transportRepository;
  final ProductRepository productRepository;
  final FinanceRepository financeRepository;

  TransportStatusService({
    required this.transportRepository,
    required this.productRepository,
    required this.financeRepository,
  });

  Future<bool> updateStatus(String transportId, ExportStatus newStatus) async {
    final transport = await transportRepository.getById(transportId);
    if (transport == null) return false;

    final updated = transport.copyWith(
      status: newStatus,
      updatedAt: DateTime.now(),
    );
    await transportRepository.update(updated);
    return true;
  }

  Future<List<TransportModel>> getTransportsByStatus(ExportStatus status) async {
    final all = await transportRepository.getAll();
    return all.where((t) => t.status == status).toList();
  }
}
