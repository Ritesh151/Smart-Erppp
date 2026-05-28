import 'package:flutter/foundation.dart';
import 'package:SmartERP/modules/reports/services/analytics_service.dart';

class AnalyticsProvider extends ChangeNotifier {
  final AnalyticsService _service;

  AnalyticsProvider(this._service);
}
