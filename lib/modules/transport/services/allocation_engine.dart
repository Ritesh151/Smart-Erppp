import 'package:SmartERP/modules/products/repositories/product_repository.dart';
import 'package:SmartERP/modules/transport/repositories/transport_repository.dart';

class AllocationEngine {
  final ProductRepository productRepository;
  final TransportRepository transportRepository;

  AllocationEngine({
    required this.productRepository,
    required this.transportRepository,
  });

  Future<Map<String, double>> calculateProductAllocation(String transportId) async {
    final transport = await transportRepository.getById(transportId);
    if (transport == null) return {};

    final allocation = <String, double>{};
    for (final product in transport.products) {
      allocation[product.productId] = product.quantity;
    }
    return allocation;
  }
}
