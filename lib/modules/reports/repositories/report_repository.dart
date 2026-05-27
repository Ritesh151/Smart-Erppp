import 'package:smarterp/core/exceptions/app_exception.dart';
import 'package:smarterp/core/models/report_model.dart';
import 'package:smarterp/core/models/report_enums.dart';
import 'package:smarterp/core/storage/storage_service.dart';
import 'package:smarterp/core/utils/logger.dart';

class ReportRepository {
  final StorageService<Map<dynamic, dynamic>> _storage;

  ReportRepository({
    required StorageService<Map<dynamic, dynamic>> storage,
  }) : _storage = storage;

  Future<List<ReportModel>> getAll() async {
    try {
      final data = _storage.getAll();
      return data
          .map((item) => ReportModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } catch (e, stackTrace) {
      Logger.error('Failed to get all reports', e, stackTrace);
      throw StorageException('Failed to retrieve reports');
    }
  }

  Future<ReportModel?> getById(String id) async {
    try {
      final data = _storage.get(id);
      if (data == null) return null;
      return ReportModel.fromJson(Map<String, dynamic>.from(data));
    } catch (e, stackTrace) {
      Logger.error('Failed to get report by id: $id', e, stackTrace);
      return null;
    }
  }

  Future<void> save(ReportModel report) async {
    try {
      await _storage.save(report.id, report.toJson());
      Logger.success('Report saved: ${report.title}');
    } catch (e, stackTrace) {
      Logger.error('Failed to save report', e, stackTrace);
      throw StorageException('Failed to save report');
    }
  }

  Future<void> update(ReportModel report) async {
    try {
      await _storage.save(report.id, report.toJson());
      Logger.success('Report updated: ${report.title}');
    } catch (e, stackTrace) {
      Logger.error('Failed to update report', e, stackTrace);
      throw StorageException('Failed to update report');
    }
  }

  Future<void> delete(String id) async {
    try {
      await _storage.delete(id);
      Logger.success('Report deleted: $id');
    } catch (e, stackTrace) {
      Logger.error('Failed to delete report', e, stackTrace);
      throw StorageException('Failed to delete report');
    }
  }

  Future<List<ReportModel>> getByType(ReportType type) async {
    try {
      final all = await getAll();
      return all.where((r) => r.type == type).toList();
    } catch (e, stackTrace) {
      Logger.error('Failed to get reports by type', e, stackTrace);
      return [];
    }
  }

  Future<List<ReportModel>> getByDateRange(DateTime from, DateTime to) async {
    try {
      final all = await getAll();
      return all.where((r) =>
          !r.fromDate.isAfter(to) && !r.toDate.isBefore(from)).toList();
    } catch (e, stackTrace) {
      Logger.error('Failed to get reports by date range', e, stackTrace);
      return [];
    }
  }

  Future<List<ReportModel>> getRecent(int limit) async {
    try {
      final all = await getAll();
      all.sort((a, b) => b.generatedAt.compareTo(a.generatedAt));
      return all.take(limit).toList();
    } catch (e, stackTrace) {
      Logger.error('Failed to get recent reports', e, stackTrace);
      return [];
    }
  }
}
