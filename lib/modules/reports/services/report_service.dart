import 'package:SmartERP/modules/reports/repositories/report_repository.dart';
import 'package:SmartERP/modules/reports/repositories/sales_report_repository.dart';
import 'package:SmartERP/modules/reports/repositories/expense_report_repository.dart';
import 'package:SmartERP/modules/reports/repositories/payroll_report_repository.dart';
import 'package:SmartERP/modules/finance/services/finance_service.dart';
import 'package:SmartERP/modules/invoice/services/invoice_service.dart';
import 'package:SmartERP/modules/products/services/product_service.dart';
import 'package:SmartERP/modules/payroll/services/payroll_service.dart';

class ReportService {
  final ReportRepository reportRepository;
  final SalesReportRepository salesReportRepository;
  final ExpenseReportRepository expenseReportRepository;
  final PayrollReportRepository payrollReportRepository;
  final FinanceService financeService;
  final InvoiceService invoiceService;
  final ProductService productService;
  final PayrollService payrollService;

  ReportService({
    required this.reportRepository,
    required this.salesReportRepository,
    required this.expenseReportRepository,
    required this.payrollReportRepository,
    required this.financeService,
    required this.invoiceService,
    required this.productService,
    required this.payrollService,
  });
}
