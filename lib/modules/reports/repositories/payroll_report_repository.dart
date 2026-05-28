import 'package:SmartERP/core/storage/storage_service.dart';

class PayrollReportRepository {
  final StorageService<Map<dynamic, dynamic>> profitLossStorage;
  final StorageService<Map<dynamic, dynamic>> payrollStorage;

  PayrollReportRepository({required this.profitLossStorage, required this.payrollStorage});
}
