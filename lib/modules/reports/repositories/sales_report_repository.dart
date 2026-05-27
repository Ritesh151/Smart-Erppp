import 'package:smarterp/core/exceptions/app_exception.dart';
import 'package:smarterp/core/models/sales_report_model.dart';
import 'package:smarterp/core/models/purchase_report_model.dart';
import 'package:smarterp/core/storage/storage_service.dart';
import 'package:smarterp/core/utils/logger.dart';

class SalesReportRepository {
  final StorageService<Map<dynamic, dynamic>> _salesStorage;
  final StorageService<Map<dynamic, dynamic>> _purchaseStorage;

  SalesReportRepository({
    required StorageService<Map<dynamic, dynamic>> salesStorage,
    required StorageService<Map<dynamic, dynamic>> purchaseStorage,
  })  : _salesStorage = salesStorage,
        _purchaseStorage = purchaseStorage;

  Future<List<SalesReportModel>> getAllSalesReports() async {
    try {
      final data = _salesStorage.getAll();
      return data
          .map((item) => SalesReportModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } catch (e, stackTrace) {
      Logger.error('Failed to get all sales reports', e, stackTrace);
      throw StorageException('Failed to retrieve sales reports');
    }
  }

  Future<SalesReportModel?> getSalesReportById(String id) async {
    try {
      final data = _salesStorage.get(id);
      if (data == null) return null;
      return SalesReportModel.fromJson(Map<String, dynamic>.from(data));
    } catch (e, stackTrace) {
      Logger.error('Failed to get sales report by id: $id', e, stackTrace);
      return null;
    }
  }

  Future<SalesReportModel?> getSalesReportByMonth(int month, int year) async {
    try {
      final all = await getAllSalesReports();
      return all.cast<SalesReportModel?>().firstWhere(
        (r) => r!.month == month && r.year == year,
        orElse: () => null,
      );
    } catch (e, stackTrace) {
      Logger.error('Failed to get sales report by month', e, stackTrace);
      return null;
    }
  }

  Future<void> saveSalesReport(SalesReportModel report) async {
    try {
      await _salesStorage.save(report.id, report.toJson());
      Logger.success('Sales report saved: ${report.month}/${report.year}');
    } catch (e, stackTrace) {
      Logger.error('Failed to save sales report', e, stackTrace);
      throw StorageException('Failed to save sales report');
    }
  }

  Future<void> updateSalesReport(SalesReportModel report) async {
    try {
      await _salesStorage.save(report.id, report.toJson());
      Logger.success('Sales report updated: ${report.month}/${report.year}');
    } catch (e, stackTrace) {
      Logger.error('Failed to update sales report', e, stackTrace);
      throw StorageException('Failed to update sales report');
    }
  }

  Future<void> deleteSalesReport(String id) async {
    try {
      await _salesStorage.delete(id);
      Logger.success('Sales report deleted: $id');
    } catch (e, stackTrace) {
      Logger.error('Failed to delete sales report', e, stackTrace);
      throw StorageException('Failed to delete sales report');
    }
  }

  Future<List<PurchaseReportModel>> getAllPurchaseReports() async {
    try {
      final data = _purchaseStorage.getAll();
      return data
          .map((item) => PurchaseReportModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } catch (e, stackTrace) {
      Logger.error('Failed to get all purchase reports', e, stackTrace);
      throw StorageException('Failed to retrieve purchase reports');
    }
  }

  Future<PurchaseReportModel?> getPurchaseReportById(String id) async {
    try {
      final data = _purchaseStorage.get(id);
      if (data == null) return null;
      return PurchaseReportModel.fromJson(Map<String, dynamic>.from(data));
    } catch (e, stackTrace) {
      Logger.error('Failed to get purchase report by id: $id', e, stackTrace);
      return null;
    }
  }

  Future<PurchaseReportModel?> getPurchaseReportByMonth(int month, int year) async {
    try {
      final all = await getAllPurchaseReports();
      return all.cast<PurchaseReportModel?>().firstWhere(
        (r) => r!.month == month && r.year == year,
        orElse: () => null,
      );
    } catch (e, stackTrace) {
      Logger.error('Failed to get purchase report by month', e, stackTrace);
      return null;
    }
  }

  Future<void> savePurchaseReport(PurchaseReportModel report) async {
    try {
      await _purchaseStorage.save(report.id, report.toJson());
      Logger.success('Purchase report saved: ${report.month}/${report.year}');
    } catch (e, stackTrace) {
      Logger.error('Failed to save purchase report', e, stackTrace);
      throw StorageException('Failed to save purchase report');
    }
  }

  Future<void> updatePurchaseReport(PurchaseReportModel report) async {
    try {
      await _purchaseStorage.save(report.id, report.toJson());
      Logger.success('Purchase report updated: ${report.month}/${report.year}');
    } catch (e, stackTrace) {
      Logger.error('Failed to update purchase report', e, stackTrace);
      throw StorageException('Failed to update purchase report');
    }
  }

  Future<void> deletePurchaseReport(String id) async {
    try {
      await _purchaseStorage.delete(id);
      Logger.success('Purchase report deleted: $id');
    } catch (e, stackTrace) {
      Logger.error('Failed to delete purchase report', e, stackTrace);
      throw StorageException('Failed to delete purchase report');
    }
  }

  Future<List<SalesReportModel>> getSalesReportsByYear(int year) async {
    try {
      final all = await getAllSalesReports();
      return all.where((r) => r.year == year).toList();
    } catch (e, stackTrace) {
      Logger.error('Failed to get sales reports by year', e, stackTrace);
      return [];
    }
  }

  Future<List<PurchaseReportModel>> getPurchaseReportsByYear(int year) async {
    try {
      final all = await getAllPurchaseReports();
      return all.where((r) => r.year == year).toList();
    } catch (e, stackTrace) {
      Logger.error('Failed to get purchase reports by year', e, stackTrace);
      return [];
    }
  }
}
