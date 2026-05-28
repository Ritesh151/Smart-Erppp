import 'package:SmartERP/modules/transport/models/transport_screen_model.dart';
import 'package:SmartERP/modules/transport/repositories/transport_repository.dart';
import 'package:SmartERP/modules/products/repositories/product_repository.dart';

class TransportService {
  final TransportRepository transportRepository;
  final ProductRepository productRepository;

  TransportService({
    required this.transportRepository,
    required this.productRepository,
  });

  Future<List<TransportModel>> getAllTransports() =>
      transportRepository.getAll();

  Future<TransportModel?> getTransport(String id) =>
      transportRepository.getById(id);

  Future<void> saveTransport(TransportModel transport) =>
      transportRepository.save(transport);

  Future<void> updateTransport(TransportModel transport) =>
      transportRepository.update(transport);

  Future<void> deleteTransport(String id) =>
      transportRepository.delete(id);

  Future<List<TransportModel>> searchTransports(String query) =>
      transportRepository.search(query);
}
