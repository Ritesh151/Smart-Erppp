import 'package:flutter/foundation.dart';
import 'package:smarterp/core/utils/logger.dart';
import 'package:smarterp/modules/reports/services/business_intelligence_service.dart';

class BusinessIntelligenceProvider extends ChangeNotifier {
  final BusinessIntelligenceService _service;

  BusinessIntelligenceProvider(this._service);

  BusinessIntelligenceData? _data;

  bool _isLoading = false;
  String? _errorMessage;

  BusinessIntelligenceData? get data => _data;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  double get revenueGrowth => _data?.revenueGrowth ?? 0;
  double get expenseGrowth => _data?.expenseGrowth ?? 0;
  List<double> get salesTrend => _data?.salesTrend ?? [];
  List<double> get profitTrend => _data?.profitTrend ?? [];
  List<String> get trendLabels => _data?.trendLabels ?? [];
  List<TopProduct> get topProducts => _data?.topProducts ?? [];
  List<TopCustomer> get topCustomers => _data?.topCustomers ?? [];
  List<RecentActivity> get recentActivities => _data?.recentActivities ?? [];
  List<BusinessInsight> get insights => _data?.insights ?? [];

  Future<void> loadData() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _data = await _service.loadIntelligenceData();

      _isLoading = false;
      notifyListeners();
      Logger.success('Business intelligence data loaded');
    } catch (e, stackTrace) {
      _isLoading = false;
      _errorMessage = 'Failed to load business intelligence data';
      notifyListeners();
      Logger.error('Failed to load BI data', e, stackTrace);
    }
  }

  Future<void> refresh() async {
    await loadData();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
