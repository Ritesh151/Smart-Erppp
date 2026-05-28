import 'package:flutter/foundation.dart';
import 'package:SmartERP/modules/reports/services/report_service.dart';

class ReportProvider extends ChangeNotifier {
  final ReportService _service;

  ReportProvider(this._service);
}
