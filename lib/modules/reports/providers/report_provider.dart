import 'package:flutter/foundation.dart';
import 'package:siddhivinayak_enterprise/modules/reports/services/report_service.dart';

class ReportProvider extends ChangeNotifier {
  final ReportService _service;

  ReportProvider(this._service);
}
