import 'package:flutter/foundation.dart';
import 'package:SmartERP/modules/reports/services/business_intelligence_service.dart';

class BusinessIntelligenceProvider extends ChangeNotifier {
  final BusinessIntelligenceService _service;

  BusinessIntelligenceProvider(this._service);
}
