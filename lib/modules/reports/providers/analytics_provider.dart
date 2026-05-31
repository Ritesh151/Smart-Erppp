import 'package:flutter/foundation.dart';
import 'package:siddhivinayak_enterprise/modules/reports/services/analytics_service.dart';

class AnalyticsProvider extends ChangeNotifier {
  final AnalyticsService _service;

  AnalyticsProvider(this._service);
}
