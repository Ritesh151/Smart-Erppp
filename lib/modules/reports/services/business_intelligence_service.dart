import 'package:SmartERP/modules/finance/services/finance_service.dart';
import 'package:SmartERP/modules/invoice/services/invoice_service.dart';
import 'package:SmartERP/modules/products/services/product_service.dart';
import 'package:SmartERP/modules/payroll/services/payroll_service.dart';

class BusinessIntelligenceService {
  final FinanceService financeService;
  final InvoiceService invoiceService;
  final ProductService productService;
  final PayrollService payrollService;

  BusinessIntelligenceService({
    required this.financeService,
    required this.invoiceService,
    required this.productService,
    required this.payrollService,
  });
}
