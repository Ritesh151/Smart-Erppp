import 'package:smarterp/core/exceptions/app_exception.dart';
import 'package:smarterp/core/models/profit_loss_model.dart';
import 'package:smarterp/core/models/payroll_report_model.dart';
import 'package:smarterp/core/storage/storage_service.dart';
import 'package:smarterp/core/utils/logger.dart';

class PayrollReportRepository {
  final StorageService<Map<dynamic, dynamic>> _profitLossStorage;
  final StorageService<Map<dynamic, dynamic>> _payrollStorage;

  PayrollReportRepository({
    required StorageService<Map<dynamic, dynamic>> profitLossStorage,
    required StorageService<Map<dynamic, dynamic>> payrollStorage,
  })  : _profitLossStorage = profitLossStorage,
        _payrollStorage = payrollStorage;

  Future<List<ProfitLossModel>> getAllProfitLossReports() async {
    try {
      final data = _profitLossStorage.getAll();
      return data
          .map((item) => ProfitLossModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } catch (e, stackTrace) {
      Logger.error('Failed to get all profit/loss reports', e, stackTrace);
      throw StorageException('Failed to retrieve profit/loss reports');
    }
  }

  Future<ProfitLossModel?> getProfitLossById(String id) async {
    try {
      final data = _profitLossStorage.get(id);
      if (data == null) return null;
      return ProfitLossModel.fromJson(Map<String, dynamic>.from(data));
    } catch (e, stackTrace) {
      Logger.error('Failed to get profit/loss by id: $id', e, stackTrace);
      return null;
    }
  }

  Future<ProfitLossModel?> getProfitLossByMonth(int month, int year) async {
    try {
      final all = await getAllProfitLossReports();
      return all.cast<ProfitLossModel?>().firstWhere(
        (r) => r!.month == month && r.year == year,
        orElse: () => null,
      );
    } catch (e, stackTrace) {
      Logger.error('Failed to get profit/loss by month', e, stackTrace);
      return null;
    }
  }

  Future<void> saveProfitLoss(ProfitLossModel report) async {
    try {
      await _profitLossStorage.save(report.id, report.toJson());
      Logger.success('Profit/loss report saved: ${report.month}/${report.year}');
    } catch (e, stackTrace) {
      Logger.error('Failed to save profit/loss report', e, stackTrace);
      throw StorageException('Failed to save profit/loss report');
    }
  }

  Future<void> updateProfitLoss(ProfitLossModel report) async {
    try {
      await _profitLossStorage.save(report.id, report.toJson());
      Logger.success('Profit/loss report updated: ${report.month}/${report.year}');
    } catch (e, stackTrace) {
      Logger.error('Failed to update profit/loss report', e, stackTrace);
      throw StorageException('Failed to update profit/loss report');
    }
  }

  Future<void> deleteProfitLoss(String id) async {
    try {
      await _profitLossStorage.delete(id);
      Logger.success('Profit/loss report deleted: $id');
    } catch (e, stackTrace) {
      Logger.error('Failed to delete profit/loss report', e, stackTrace);
      throw StorageException('Failed to delete profit/loss report');
    }
  }

  Future<List<PayrollReportModel>> getAllPayrollReports() async {
    try {
      final data = _payrollStorage.getAll();
      return data
          .map((item) => PayrollReportModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } catch (e, stackTrace) {
      Logger.error('Failed to get all payroll reports', e, stackTrace);
      throw StorageException('Failed to retrieve payroll reports');
    }
  }

  Future<PayrollReportModel?> getPayrollReportById(String id) async {
    try {
      final data = _payrollStorage.get(id);
      if (data == null) return null;
      return PayrollReportModel.fromJson(Map<String, dynamic>.from(data));
    } catch (e, stackTrace) {
      Logger.error('Failed to get payroll report by id: $id', e, stackTrace);
      return null;
    }
  }

  Future<PayrollReportModel?> getPayrollReportByMonth(int month, int year) async {
    try {
      final all = await getAllPayrollReports();
      return all.cast<PayrollReportModel?>().firstWhere(
        (r) => r!.month == month && r.year == year,
        orElse: () => null,
      );
    } catch (e, stackTrace) {
      Logger.error('Failed to get payroll report by month', e, stackTrace);
      return null;
    }
  }

  Future<void> savePayrollReport(PayrollReportModel report) async {
    try {
      await _payrollStorage.save(report.id, report.toJson());
      Logger.success('Payroll report saved: ${report.month}/${report.year}');
    } catch (e, stackTrace) {
      Logger.error('Failed to save payroll report', e, stackTrace);
      throw StorageException('Failed to save payroll report');
    }
  }

  Future<void> updatePayrollReport(PayrollReportModel report) async {
    try {
      await _payrollStorage.save(report.id, report.toJson());
      Logger.success('Payroll report updated: ${report.month}/${report.year}');
    } catch (e, stackTrace) {
      Logger.error('Failed to update payroll report', e, stackTrace);
      throw StorageException('Failed to update payroll report');
    }
  }

  Future<void> deletePayrollReport(String id) async {
    try {
      await _payrollStorage.delete(id);
      Logger.success('Payroll report deleted: $id');
    } catch (e, stackTrace) {
      Logger.error('Failed to delete payroll report', e, stackTrace);
      throw StorageException('Failed to delete payroll report');
    }
  }

  Future<List<ProfitLossModel>> getProfitLossByYear(int year) async {
    try {
      final all = await getAllProfitLossReports();
      return all.where((r) => r.year == year).toList();
    } catch (e, stackTrace) {
      Logger.error('Failed to get profit/loss by year', e, stackTrace);
      return [];
    }
  }

  Future<List<PayrollReportModel>> getPayrollByYear(int year) async {
    try {
      final all = await getAllPayrollReports();
      return all.where((r) => r.year == year).toList();
    } catch (e, stackTrace) {
      Logger.error('Failed to get payroll reports by year', e, stackTrace);
      return [];
    }
  }
}
