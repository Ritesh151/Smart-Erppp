import '../../products/repositories/product_repository.dart';
import '../models/transport_screen_model.dart';
import '../repositories/transport_repository.dart';

class TransportService {
  TransportService({
    required this.transportRepository,
    required this.productRepository,
  });

  final TransportRepository transportRepository;
  final ProductRepository productRepository;

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
