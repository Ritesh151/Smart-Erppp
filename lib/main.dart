import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' hide Provider, ChangeNotifierProvider, Consumer;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:SmartERP/core/constants/storage_keys.dart';
import 'package:SmartERP/core/routes/app_router.dart';
import 'package:SmartERP/core/services/auth_service.dart';
import 'package:SmartERP/core/storage/storage_service.dart';
import 'package:SmartERP/core/storage/preferences_service.dart';
import 'package:SmartERP/core/utils/logger.dart';
import 'package:SmartERP/modules/auth/providers/auth_provider.dart';
import 'package:SmartERP/modules/settings/providers/theme_provider.dart';
import 'package:SmartERP/modules/products/repositories/product_repository.dart';
import 'package:SmartERP/modules/products/services/product_service.dart';
import 'package:SmartERP/modules/dashboard/providers/dashboard_provider.dart';
import 'package:SmartERP/modules/products/providers/product_provider.dart';
import 'package:SmartERP/modules/finance/repositories/finance_repository.dart';
import 'package:SmartERP/modules/finance/services/finance_service.dart';
import 'package:SmartERP/modules/finance/services/return_service.dart';
import 'package:SmartERP/modules/finance/providers/finance_provider.dart';
import 'package:SmartERP/modules/expenses/repositories/expense_repository.dart';
import 'package:SmartERP/modules/expenses/services/expense_service.dart';
import 'package:SmartERP/modules/expenses/providers/expense_provider.dart';
import 'package:SmartERP/modules/invoice/repositories/customer_repository.dart';
import 'package:SmartERP/modules/invoice/repositories/invoice_repository.dart';
import 'package:SmartERP/modules/invoice/repositories/payment_repository.dart';
import 'package:SmartERP/modules/invoice/services/customer_service.dart';
import 'package:SmartERP/modules/invoice/services/invoice_service.dart';
import 'package:SmartERP/modules/invoice/services/payment_service.dart';
import 'package:SmartERP/modules/invoice/services/pdf_service.dart';
import 'package:SmartERP/modules/invoice/providers/customer_provider.dart';
import 'package:SmartERP/modules/invoice/providers/invoice_provider.dart';
import 'package:SmartERP/modules/invoice/providers/payment_provider.dart';
import 'package:SmartERP/modules/payroll/repositories/employee_repository.dart';
import 'package:SmartERP/modules/payroll/repositories/attendance_repository.dart';
import 'package:SmartERP/modules/payroll/repositories/salary_repository.dart';
import 'package:SmartERP/modules/payroll/services/employee_service.dart';
import 'package:SmartERP/modules/payroll/services/attendance_service.dart';
import 'package:SmartERP/modules/payroll/services/salary_service.dart';
import 'package:SmartERP/modules/payroll/services/payroll_service.dart';
import 'package:SmartERP/modules/payroll/services/employee_search_service.dart';
import 'package:SmartERP/modules/payroll/services/employee_filter_service.dart';
import 'package:SmartERP/modules/payroll/services/salary_calculation_service.dart';
import 'package:SmartERP/modules/payroll/services/salary_payment_service.dart';
import 'package:SmartERP/modules/payroll/providers/employee_provider.dart';
import 'package:SmartERP/modules/payroll/providers/attendance_provider.dart';
import 'package:SmartERP/modules/payroll/providers/salary_provider.dart';
import 'package:SmartERP/modules/payroll/providers/payroll_provider.dart';
import 'package:SmartERP/modules/reports/repositories/report_repository.dart';
import 'package:SmartERP/modules/reports/repositories/sales_report_repository.dart';
import 'package:SmartERP/modules/reports/repositories/expense_report_repository.dart';
import 'package:SmartERP/modules/reports/repositories/payroll_report_repository.dart';
import 'package:SmartERP/modules/reports/services/report_service.dart';
import 'package:SmartERP/modules/reports/services/analytics_service.dart';
import 'package:SmartERP/modules/reports/services/business_intelligence_service.dart';
import 'package:SmartERP/modules/reports/services/report_export_service.dart';
import 'package:SmartERP/modules/reports/providers/report_provider.dart';
import 'package:SmartERP/modules/reports/providers/analytics_provider.dart';
import 'package:SmartERP/modules/reports/providers/business_intelligence_provider.dart';
import 'package:SmartERP/modules/settings/repositories/settings_repository.dart';
import 'package:SmartERP/modules/settings/repositories/notification_repository.dart';
import 'package:SmartERP/modules/settings/repositories/backup_repository.dart';
import 'package:SmartERP/modules/settings/services/settings_service.dart';
import 'package:SmartERP/modules/settings/services/theme_service.dart';
import 'package:SmartERP/modules/settings/services/notification_service.dart';
import 'package:SmartERP/modules/settings/services/preferences_service.dart' as settings_pref;
import 'package:SmartERP/modules/settings/services/date_format_service.dart';
import 'package:SmartERP/modules/settings/services/low_stock_service.dart';
import 'package:SmartERP/modules/settings/services/stock_alert_service.dart';
import 'package:SmartERP/modules/settings/services/salary_reminder_service.dart';
import 'package:SmartERP/modules/settings/services/backup_service.dart';
import 'package:SmartERP/modules/settings/services/restore_service.dart';
import 'package:SmartERP/modules/settings/services/data_export_service.dart';
import 'package:SmartERP/modules/settings/services/data_import_service.dart';
import 'package:SmartERP/modules/settings/services/app_intelligence_service.dart';
import 'package:SmartERP/modules/settings/services/business_alert_service.dart';
import 'package:SmartERP/modules/settings/services/settings_search_service.dart';
import 'package:SmartERP/modules/settings/services/settings_filter_service.dart';
import 'package:SmartERP/modules/settings/providers/settings_provider.dart';
import 'package:SmartERP/modules/settings/providers/notification_provider.dart';
import 'package:SmartERP/modules/settings/providers/preferences_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await _initializeApp();
    runApp(const SmartERPApp());
  } catch (e, stackTrace) {
    Logger.error('Failed to initialize app', e, stackTrace);
    runApp(const ErrorApp());
  }
}

Future<void> _initializeApp() async {
  Logger.info('Initializing SmartERP...');

  await Hive.initFlutter();
  Logger.success('Hive initialized');

  await _initializeHiveBoxes();
  Logger.success('Hive boxes initialized');

  await _cleanupLegacySeedData();

  final preferencesService = await PreferencesService.getInstance();
  Logger.success('Preferences service initialized');
}

Future<void> _cleanupLegacySeedData() async {
  try {
    final productsBox = Hive.box(StorageKeys.productsBox);
    final keysToRemove = <dynamic>[];

    for (final key in productsBox.keys) {
      final data = productsBox.get(key);
      if (data is Map) {
        final name = data['productName'] as String?;
        final id = data['id'] as String?;
        if (name == 'Default Product' || id == 'default-product') {
          keysToRemove.add(key);
        }
      }
    }

    for (final key in keysToRemove) {
      await productsBox.delete(key);
      Logger.info('Removed legacy seed product: $key');
    }

    if (keysToRemove.isNotEmpty) {
      Logger.success('Cleaned up ${keysToRemove.length} legacy seed product(s)');
    }
  } catch (e, stackTrace) {
    Logger.warning('Failed to clean up legacy seed data', e);
  }
}

Future<void> _initializeHiveBoxes() async {
  final boxes = [
    StorageKeys.productsBox,
    StorageKeys.invoicesBox,
    StorageKeys.employeesBox,
    StorageKeys.expensesBox,
    StorageKeys.settingsBox,
    StorageKeys.salesBox,
    StorageKeys.purchaseBox,
    StorageKeys.sessionBox,
    StorageKeys.customersBox,
    StorageKeys.paymentsBox,
    StorageKeys.invoiceItemsBox,
    StorageKeys.returnsBox,
  ];

  for (final boxName in boxes) {
    try {
      if (!Hive.isBoxOpen(boxName)) {
        await Hive.openBox(boxName);
        Logger.debug('Opened box: $boxName');
      } else {
        Logger.debug('Box already open: $boxName');
      }
    } catch (e) {
      Logger.warning('Failed to open box: $boxName', e);
    }
  }

  final extraBoxes = [
    StorageKeys.attendanceBox,
    StorageKeys.salaryBox,
    StorageKeys.salaryHistoryBox,
  ];

  for (final boxName in extraBoxes) {
    try {
      if (!Hive.isBoxOpen(boxName)) {
        await Hive.openBox(boxName);
        Logger.debug('Opened box: $boxName');
      } else {
        Logger.debug('Box already open: $boxName');
      }
    } catch (e) {
      Logger.warning('Failed to open box: $boxName', e);
    }
  }

  final reportBoxes = [
    StorageKeys.reportsBox,
    StorageKeys.salesReportsBox,
    StorageKeys.purchaseReportsBox,
    StorageKeys.expenseReportsBox,
    StorageKeys.stockReportsBox,
    StorageKeys.profitLossReportsBox,
    StorageKeys.payrollReportsBox,
  ];

  for (final boxName in reportBoxes) {
    try {
      if (!Hive.isBoxOpen(boxName)) {
        await Hive.openBox(boxName);
        Logger.debug('Opened report box: $boxName');
      } else {
        Logger.debug('Report box already open: $boxName');
      }
    } catch (e) {
      Logger.warning('Failed to open report box: $boxName', e);
    }
  }

  final settingsBoxes = [
    StorageKeys.settingsConfigBox,
    StorageKeys.preferencesBox,
    StorageKeys.notificationBox,
    StorageKeys.backupBox,
  ];

  for (final boxName in settingsBoxes) {
    try {
      if (!Hive.isBoxOpen(boxName)) {
        await Hive.openBox(boxName);
        Logger.debug('Opened settings box: $boxName');
      } else {
        Logger.debug('Settings box already open: $boxName');
      }
    } catch (e) {
      Logger.warning('Failed to open settings box: $boxName', e);
    }
  }
}

class SmartERPApp extends StatefulWidget {
  const SmartERPApp({super.key});

  @override
  State<SmartERPApp> createState() => _SmartERPAppState();
}

class _SmartERPAppState extends State<SmartERPApp> {
  AppRouter? _appRouter;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PreferencesService>(
      future: PreferencesService.getInstance(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              body: Center(
                child: Text('Error: ${snapshot.error}'),
              ),
            ),
          );
        }


        final preferencesService = snapshot.data!;

        return MultiProvider(
          providers: [
            Provider<PreferencesService>.value(value: preferencesService),
            Provider<AuthService>(
              create: (_) => AuthService(preferencesService),
            ),
            ChangeNotifierProvider<AuthProvider>(
              create: (context) => AuthProvider(
                context.read<AuthService>(),
              )..initialize(),
            ),
              ChangeNotifierProvider<ThemeProvider>(
              create: (context) => ThemeProvider(preferencesService)
                ..initialize(),
            ),
            
            // Product Module Services & State
            Provider<ProductRepository>(
              create: (_) {
                final storage = StorageService<Map<dynamic, dynamic>>(StorageKeys.productsBox);
                storage.init();
                return ProductRepository(storage);
              },
            ),
            Provider<ProductService>(
              create: (context) => ProductService(context.read<ProductRepository>()),
            ),
            
            ChangeNotifierProvider<ProductProvider>(
              create: (context) {
                final provider = ProductProvider(
                  context.read<ProductService>(),
                );
                provider.onDataChanged = () {
                  try {
                    context.read<DashboardProvider>().refresh();
                  } catch (_) {}
                };
                provider.loadProducts();
                return provider;
              },
            ),

            // Finance Module Services & State
            Provider<FinanceRepository>(
              create: (_) {
                final sales = StorageService<Map<dynamic, dynamic>>(StorageKeys.salesBox)..init();
                final purchases = StorageService<Map<dynamic, dynamic>>(StorageKeys.purchaseBox)..init();
                final expenses = StorageService<Map<dynamic, dynamic>>(StorageKeys.expensesBox)..init();
                return FinanceRepository(
                  salesStorage: sales,
                  purchaseStorage: purchases,
                  expensesStorage: expenses,
                );
              },
            ),

            // Expense Module Services & State
            Provider<ExpenseRepository>(
              create: (_) {
                final storage = StorageService<Map<dynamic, dynamic>>(StorageKeys.expensesBox)..init();
                return ExpenseRepository(storage);
              },
            ),
            Provider<ExpenseService>(
              create: (context) => ExpenseService(context.read<ExpenseRepository>()),
            ),
            ChangeNotifierProvider<ExpenseProvider>(
              create: (context) {
                final provider = ExpenseProvider(context.read<ExpenseService>());
                provider.onDataChanged = () {
                  try {
                    context.read<DashboardProvider>().refresh();
                  } catch (_) {}
                };
                return provider;
              },
            ),


            // Invoice Module Services & State
            Provider<CustomerRepository>(
              create: (_) {
                final storage = StorageService<Map<dynamic, dynamic>>(StorageKeys.customersBox);
                // Initialize storage asynchronously
                storage.init().catchError((e) => Logger.error('Failed to init customers storage', e));
                return CustomerRepository(storage);
              },
            ),
            Provider<InvoiceRepository>(
              create: (_) {
                final storage = StorageService<Map<dynamic, dynamic>>(StorageKeys.invoicesBox);
                final itemStorage = StorageService<Map<dynamic, dynamic>>(StorageKeys.invoiceItemsBox);
                // Initialize storage asynchronously
                storage.init().catchError((e) => Logger.error('Failed to init invoices storage', e));
                itemStorage.init().catchError((e) => Logger.error('Failed to init invoice items storage', e));
                return InvoiceRepository(invoiceStorage: storage, itemStorage: itemStorage);
              },
            ),
            Provider<PaymentRepository>(
              create: (_) {
                final storage = StorageService<Map<dynamic, dynamic>>(StorageKeys.paymentsBox);
                // Initialize storage asynchronously
                storage.init().catchError((e) => Logger.error('Failed to init payments storage', e));
                return PaymentRepository(storage);
              },
            ),
            Provider<CustomerService>(
              create: (context) => CustomerService(context.read<CustomerRepository>()),
            ),
            Provider<InvoiceService>(
              create: (context) => InvoiceService(
                invoiceRepository: context.read<InvoiceRepository>(),
                productRepository: context.read<ProductRepository>(),
                financeRepository: context.read<FinanceRepository>(),
              ),
            ),
            Provider<PaymentService>(
              create: (context) => PaymentService(
                context.read<PaymentRepository>(),
                context.read<InvoiceRepository>(),
              ),
            ),
            ChangeNotifierProvider<CustomerProvider>(
              create: (context) {
                final provider = CustomerProvider(context.read<CustomerService>());
                // Initialize customers after a short delay to allow storage to initialize
                Future.delayed(const Duration(milliseconds: 100), () {
                  provider.loadCustomers();
                });
                return provider;
              },
            ),
            ChangeNotifierProvider<InvoiceProvider>(
              create: (context) {
                final provider = InvoiceProvider(service: context.read<InvoiceService>());
                provider.onDataChanged = () {
                  try {
                    context.read<DashboardProvider>().refresh();
                  } catch (_) {}
                };
                provider.attachProductProvider(context.read<ProductProvider>());
                return provider;
              },
            ),
            ChangeNotifierProvider<PaymentProvider>(
              create: (context) {
                final provider = PaymentProvider(context.read<PaymentService>());
                provider.onDataChanged = () {
                  try {
                    context.read<DashboardProvider>().refresh();
                  } catch (_) {}
                };
                return provider;
              },
            ),

            // Payroll Module Services & State
            Provider<EmployeeRepository>(
              create: (_) {
                final storage = StorageService<Map<dynamic, dynamic>>(StorageKeys.employeesBox)..init();
                return EmployeeRepository(storage);
              },
            ),
            Provider<AttendanceRepository>(
              create: (_) {
                final storage = StorageService<Map<dynamic, dynamic>>(StorageKeys.attendanceBox)..init();
                return AttendanceRepository(storage);
              },
            ),
            Provider<SalaryRepository>(
              create: (_) {
                final salaryStorage = StorageService<Map<dynamic, dynamic>>(StorageKeys.salaryBox)..init();
                final historyStorage = StorageService<Map<dynamic, dynamic>>(StorageKeys.salaryHistoryBox)..init();
                return SalaryRepository(salaryStorage: salaryStorage, historyStorage: historyStorage);
              },
            ),
            Provider<EmployeeService>(
              create: (context) => EmployeeService(context.read<EmployeeRepository>()),
            ),

            // Finance Module Services & State
            Provider<ReturnService>(
              create: (context) => ReturnService(
                invoiceRepository: context.read<InvoiceRepository>(),
                productRepository: context.read<ProductRepository>(),
                financeRepository: context.read<FinanceRepository>(),
              ),
            ),
            Provider<FinanceService>(
              create: (context) => FinanceService(
                financeRepository: context.read<FinanceRepository>(),
                invoiceService: context.read<InvoiceService>(),
                productService: context.read<ProductService>(),
                employeeService: context.read<EmployeeService>(),
                expenseRepository: context.read<ExpenseRepository>(),
                returnService: context.read<ReturnService>(),
              ),
            ),
            ChangeNotifierProvider<FinanceProvider>(
              create: (context) {
                final provider = FinanceProvider(context.read<FinanceService>());
                provider.onDataChanged = () {
                  try {
                    context.read<DashboardProvider>().refresh();
                  } catch (_) {}
                };
                provider.loadTransactions();
                return provider;
              },
            ),
            ChangeNotifierProvider<DashboardProvider>(
              create: (context) => DashboardProvider(
                invoiceService: context.read<InvoiceService>(),
                productService: context.read<ProductService>(),
                financeService: context.read<FinanceService>(),
              )..refresh(),
            ),

            Provider<AttendanceService>(
              create: (context) => AttendanceService(context.read<AttendanceRepository>()),
            ),
            Provider<SalaryService>(
              create: (context) => SalaryService(context.read<SalaryRepository>()),
            ),
            Provider<PayrollService>(
              create: (context) => PayrollService(
                employeeRepository: context.read<EmployeeRepository>(),
                attendanceRepository: context.read<AttendanceRepository>(),
                salaryRepository: context.read<SalaryRepository>(),
              ),
            ),
            Provider<EmployeeSearchService>(
              create: (context) => EmployeeSearchService(context.read<EmployeeRepository>()),
            ),
            Provider<EmployeeFilterService>(
              create: (context) => EmployeeFilterService(context.read<EmployeeRepository>()),
            ),
            Provider<SalaryCalculationService>(
              create: (_) => SalaryCalculationService(),
            ),
            Provider<SalaryPaymentService>(
              create: (context) => SalaryPaymentService(context.read<SalaryRepository>()),
            ),
            ChangeNotifierProvider<EmployeeProvider>(
              create: (context) => EmployeeProvider(
                context.read<EmployeeService>(),
              )..loadEmployees(),
            ),
            ChangeNotifierProvider<AttendanceProvider>(
              create: (context) => AttendanceProvider(
                context.read<AttendanceService>(),
              ),
            ),
            ChangeNotifierProvider<SalaryProvider>(
              create: (context) => SalaryProvider(
                context.read<SalaryService>(),
              ),
            ),
            ChangeNotifierProvider<PayrollProvider>(
              create: (context) => PayrollProvider(
                context.read<PayrollService>(),
              ),
            ),

            // Reports Module Services & State
            Provider<ReportRepository>(
              create: (_) {
                final storage = StorageService<Map<dynamic, dynamic>>(StorageKeys.reportsBox)..init();
                return ReportRepository(storage: storage);
              },
            ),
            Provider<SalesReportRepository>(
              create: (_) {
                final sales = StorageService<Map<dynamic, dynamic>>(StorageKeys.salesReportsBox)..init();
                final purchase = StorageService<Map<dynamic, dynamic>>(StorageKeys.purchaseReportsBox)..init();
                return SalesReportRepository(salesStorage: sales, purchaseStorage: purchase);
              },
            ),
            Provider<ExpenseReportRepository>(
              create: (_) {
                final expense = StorageService<Map<dynamic, dynamic>>(StorageKeys.expenseReportsBox)..init();
                final stock = StorageService<Map<dynamic, dynamic>>(StorageKeys.stockReportsBox)..init();
                return ExpenseReportRepository(expenseStorage: expense, stockStorage: stock);
              },
            ),
            Provider<PayrollReportRepository>(
              create: (_) {
                final profitLoss = StorageService<Map<dynamic, dynamic>>(StorageKeys.profitLossReportsBox)..init();
                final payroll = StorageService<Map<dynamic, dynamic>>(StorageKeys.payrollReportsBox)..init();
                return PayrollReportRepository(profitLossStorage: profitLoss, payrollStorage: payroll);
              },
            ),
            Provider<ReportService>(
              create: (context) => ReportService(
                reportRepository: context.read<ReportRepository>(),
                salesReportRepository: context.read<SalesReportRepository>(),
                expenseReportRepository: context.read<ExpenseReportRepository>(),
                payrollReportRepository: context.read<PayrollReportRepository>(),
                financeService: context.read<FinanceService>(),
                invoiceService: context.read<InvoiceService>(),
                productService: context.read<ProductService>(),
                payrollService: context.read<PayrollService>(),
              ),
            ),
            Provider<AnalyticsService>(
              create: (context) => AnalyticsService(
                financeService: context.read<FinanceService>(),
                payrollService: context.read<PayrollService>(),
                productService: context.read<ProductService>(),
              ),
            ),
            Provider<BusinessIntelligenceService>(
              create: (context) => BusinessIntelligenceService(
                financeService: context.read<FinanceService>(),
                invoiceService: context.read<InvoiceService>(),
                productService: context.read<ProductService>(),
                payrollService: context.read<PayrollService>(),
              ),
            ),
            Provider<ReportExportService>(
              create: (_) => ReportExportService(),
            ),
            ChangeNotifierProvider<ReportProvider>(
              create: (context) => ReportProvider(context.read<ReportService>()),
            ),
            ChangeNotifierProvider<AnalyticsProvider>(
              create: (context) => AnalyticsProvider(context.read<AnalyticsService>()),
            ),
            ChangeNotifierProvider<BusinessIntelligenceProvider>(
              create: (context) => BusinessIntelligenceProvider(context.read<BusinessIntelligenceService>()),
            ),

            // Settings Module Repositories
            Provider<SettingsRepository>(
              create: (_) {
                final storage = StorageService<Map<dynamic, dynamic>>(StorageKeys.settingsConfigBox)..init();
                return SettingsRepository(storage: storage);
              },
            ),
            Provider<NotificationRepository>(
              create: (_) {
                final storage = StorageService<Map<dynamic, dynamic>>(StorageKeys.notificationBox)..init();
                return NotificationRepository(storage: storage);
              },
            ),
            Provider<BackupRepository>(
              create: (_) {
                final storage = StorageService<Map<dynamic, dynamic>>(StorageKeys.backupBox)..init();
                return BackupRepository(storage: storage);
              },
            ),

            // Settings Module Services
            Provider<SettingsService>(
              create: (context) => SettingsService(
                repository: context.read<SettingsRepository>(),
                preferencesService: context.read<PreferencesService>(),
              ),
            ),
            Provider<ThemeService>(
              create: (context) => ThemeService(
                preferencesService: context.read<PreferencesService>(),
              ),
            ),
            Provider<NotificationService>(
              create: (context) => NotificationService(
                repository: context.read<NotificationRepository>(),
              ),
            ),
            Provider<settings_pref.PreferencesService>(
              create: (context) => settings_pref.PreferencesService(
                preferencesService: context.read<PreferencesService>(),
              ),
            ),
            Provider<DateFormatService>(
              create: (context) => DateFormatService(
                settingsService: context.read<SettingsService>(),
              ),
            ),
            Provider<LowStockService>(
              create: (context) => LowStockService(
                productService: context.read<ProductService>(),
                settingsService: context.read<SettingsService>(),
              ),
            ),
            Provider<StockAlertService>(
              create: (context) => StockAlertService(
                lowStockService: context.read<LowStockService>(),
                notificationService: context.read<NotificationService>(),
                settingsService: context.read<SettingsService>(),
              ),
            ),
            Provider<SalaryReminderService>(
              create: (context) => SalaryReminderService(
                payrollService: context.read<PayrollService>(),
                settingsService: context.read<SettingsService>(),
                notificationService: context.read<NotificationService>(),
              ),
            ),
            Provider<BackupService>(
              create: (context) => BackupService(
                productService: context.read<ProductService>(),
                financeService: context.read<FinanceService>(),
                invoiceService: context.read<InvoiceService>(),
                customerService: context.read<CustomerService>(),
                employeeService: context.read<EmployeeService>(),
                attendanceService: context.read<AttendanceService>(),
                salaryService: context.read<SalaryService>(),
                notificationService: context.read<NotificationService>(),
                settingsService: context.read<SettingsService>(),
                backupRepository: context.read<BackupRepository>(),
              ),
            ),
            Provider<RestoreService>(
              create: (context) => RestoreService(
                backupRepository: context.read<BackupRepository>(),
                notificationService: context.read<NotificationService>(),
                productsStorage: StorageService<Map<dynamic, dynamic>>(StorageKeys.productsBox)..init(),
                transactionsStorage: StorageService<Map<dynamic, dynamic>>(StorageKeys.salesBox)..init(),
                invoicesStorage: StorageService<Map<dynamic, dynamic>>(StorageKeys.invoicesBox)..init(),
                customersStorage: StorageService<Map<dynamic, dynamic>>(StorageKeys.customersBox)..init(),
                employeesStorage: StorageService<Map<dynamic, dynamic>>(StorageKeys.employeesBox)..init(),
                attendanceStorage: StorageService<Map<dynamic, dynamic>>(StorageKeys.attendanceBox)..init(),
                salariesStorage: StorageService<Map<dynamic, dynamic>>(StorageKeys.salaryBox)..init(),
              ),
            ),
            Provider<DataExportService>(
              create: (context) => DataExportService(
                productService: context.read<ProductService>(),
                financeService: context.read<FinanceService>(),
                invoiceService: context.read<InvoiceService>(),
                customerService: context.read<CustomerService>(),
                employeeService: context.read<EmployeeService>(),
                attendanceService: context.read<AttendanceService>(),
                salaryService: context.read<SalaryService>(),
              ),
            ),
            Provider<DataImportService>(
              create: (context) => DataImportService(
                productsStorage: StorageService<Map<dynamic, dynamic>>(StorageKeys.productsBox)..init(),
                transactionsStorage: StorageService<Map<dynamic, dynamic>>(StorageKeys.salesBox)..init(),
                invoicesStorage: StorageService<Map<dynamic, dynamic>>(StorageKeys.invoicesBox)..init(),
                customersStorage: StorageService<Map<dynamic, dynamic>>(StorageKeys.customersBox)..init(),
                employeesStorage: StorageService<Map<dynamic, dynamic>>(StorageKeys.employeesBox)..init(),
                attendanceStorage: StorageService<Map<dynamic, dynamic>>(StorageKeys.attendanceBox)..init(),
                salariesStorage: StorageService<Map<dynamic, dynamic>>(StorageKeys.salaryBox)..init(),
              ),
            ),
            Provider<AppIntelligenceService>(
              create: (context) => AppIntelligenceService(
                productService: context.read<ProductService>(),
                financeService: context.read<FinanceService>(),
                invoiceService: context.read<InvoiceService>(),
                employeeService: context.read<EmployeeService>(),
                attendanceService: context.read<AttendanceService>(),
              ),
            ),
            Provider<BusinessAlertService>(
              create: (context) => BusinessAlertService(
                intelligenceService: context.read<AppIntelligenceService>(),
                notificationService: context.read<NotificationService>(),
              ),
            ),
            Provider<SettingsSearchService>(
              create: (context) => SettingsSearchService(
                notificationRepository: context.read<NotificationRepository>(),
                backupRepository: context.read<BackupRepository>(),
                preferencesService: context.read<settings_pref.PreferencesService>(),
              ),
            ),
            Provider<SettingsFilterService>(
              create: (context) => SettingsFilterService(
                notificationRepository: context.read<NotificationRepository>(),
                backupRepository: context.read<BackupRepository>(),
              ),
            ),

            // Settings Module Providers
            ChangeNotifierProvider<SettingsProvider>(
              create: (context) => SettingsProvider(
                context.read<SettingsService>(),
              ),
            ),
            ChangeNotifierProvider<NotificationProvider>(
              create: (context) => NotificationProvider(
                context.read<NotificationService>(),
              ),
            ),
            ChangeNotifierProvider<PreferencesProvider>(
              create: (context) => PreferencesProvider(
                context.read<settings_pref.PreferencesService>(),
              ),
            ),
          ],
          child: Consumer<ThemeProvider>(
            builder: (context, themeProvider, _) {
              final authProvider = context.read<AuthProvider>();
              _appRouter ??= AppRouter(authProvider);

              return ProviderScope(
                child: MaterialApp.router(
                  title: 'SmartERP',
                  debugShowCheckedModeBanner: false,
                  theme: themeProvider.themeData,
                  routerConfig: _appRouter!.router,
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class ErrorApp extends StatelessWidget {
  const ErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              const Text(
                'Failed to initialize application',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Please restart the application',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  main();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
