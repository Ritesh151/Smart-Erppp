import 'package:siddhivinayak_enterprise/core/storage/storage_service.dart';

class ExpenseReportRepository {
  final StorageService<Map<dynamic, dynamic>> expenseStorage;
  final StorageService<Map<dynamic, dynamic>> stockStorage;

  ExpenseReportRepository({required this.expenseStorage, required this.stockStorage});
}
