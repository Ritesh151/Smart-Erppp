import '../../finance/repositories/finance_repository.dart';
import '../../products/repositories/product_repository.dart';
import '../models/transport_screen_model.dart';
import '../repositories/transport_repository.dart';

class TransportStatusService {
  TransportStatusService({
    required this.transportRepository,
    required this.productRepository,
    required this.financeRepository,
  });

  final TransportRepository transportRepository;
  final ProductRepository productRepository;
  final FinanceRepository financeRepository;

  Future<bool> updateStatus(String transportId, ExportStatus newStatus) async {
    final transport = await transportRepository.getById(transportId);
    if (transport == null) {
      return false;
    }

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
