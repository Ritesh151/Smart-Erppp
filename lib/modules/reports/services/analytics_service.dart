import 'package:SmartERP/modules/finance/services/finance_service.dart';
import 'package:SmartERP/modules/payroll/services/payroll_service.dart';
import 'package:SmartERP/modules/products/services/product_service.dart';

class AnalyticsService {
  final FinanceService financeService;
  final PayrollService payrollService;
  final ProductService productService;

  AnalyticsService({
    required this.financeService,
    required this.payrollService,
    required this.productService,
  });
}
