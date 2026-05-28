import 'package:SmartERP/core/storage/storage_service.dart';

class SalesReportRepository {
  final StorageService<Map<dynamic, dynamic>> salesStorage;
  final StorageService<Map<dynamic, dynamic>> purchaseStorage;

  SalesReportRepository({required this.salesStorage, required this.purchaseStorage});
}
