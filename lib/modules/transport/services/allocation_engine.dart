import '../../products/repositories/product_repository.dart';
import '../repositories/transport_repository.dart';

class AllocationEngine {
  AllocationEngine({
    required this.productRepository,
    required this.transportRepository,
  });

  final ProductRepository productRepository;
  final TransportRepository transportRepository;

  Future<Map<String, double>> calculateProductAllocation(String transportId) async {
    final transport = await transportRepository.getById(transportId);
    if (transport == null) {
      return {};
    }

    final allocation = <String, double>{};
    for (final product in transport.products) {
      allocation[product.productId] = product.quantity;
    }
    return allocation;
  }
}
