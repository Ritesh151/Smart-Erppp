import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:SmartERP/core/routes/app_routes.dart';
import 'package:SmartERP/core/widgets/app_shell.dart';
import 'package:SmartERP/modules/auth/providers/auth_provider.dart';
import 'package:SmartERP/modules/auth/screens/login_screen.dart';
import 'package:SmartERP/modules/dashboard/screens/dashboard_screen.dart';
import 'package:SmartERP/modules/products/screens/products_screen.dart';
import 'package:SmartERP/modules/products/screens/product_form_screen.dart';
import 'package:SmartERP/modules/products/screens/product_detail_screen.dart';
import 'package:SmartERP/modules/finance/finance_screen.dart';
import 'package:SmartERP/modules/finance/create_sale_screen.dart';
import 'package:SmartERP/modules/invoice/screens/invoices_screen.dart';
import 'package:SmartERP/modules/invoice/screens/invoice_form_screen.dart';
import 'package:SmartERP/modules/invoice/screens/invoice_detail_screen.dart';
import 'package:SmartERP/modules/invoice/screens/payment_history_screen.dart';
import 'package:SmartERP/modules/invoice/screens/customers_screen.dart';
import 'package:SmartERP/modules/invoice/screens/customer_form_screen.dart';
import 'package:SmartERP/modules/invoice/screens/customer_detail_screen.dart';
import 'package:SmartERP/modules/expenses/screens/expenses_screen.dart';
import 'package:SmartERP/modules/expenses/screens/add_expense_screen.dart';
import 'package:SmartERP/modules/expenses/screens/expense_summary_screen.dart';
import 'package:SmartERP/modules/payroll/screens/payroll_screen.dart';
import 'package:SmartERP/modules/payroll/payroll_dashboard_screen.dart';
import 'package:SmartERP/modules/payroll/add_employee_screen.dart';
import 'package:SmartERP/modules/payroll/edit_employee_screen.dart';
import 'package:SmartERP/modules/payroll/salary_history_screen.dart';
import 'package:SmartERP/modules/payroll/attendance_screen.dart';
import 'package:SmartERP/modules/reports/reports_home_screen.dart';
import 'package:SmartERP/modules/reports/sales_register_screen.dart';
import 'package:SmartERP/modules/reports/purchase_register_screen.dart';
import 'package:SmartERP/modules/reports/expense_statement_screen.dart';
import 'package:SmartERP/modules/reports/gst_summary_screen.dart';
import 'package:SmartERP/modules/reports/stock_statement_screen.dart';
import 'package:SmartERP/modules/reports/profit_loss_screen.dart';
import 'package:SmartERP/modules/reports/payroll_report_screen.dart';
import 'package:SmartERP/modules/settings/screens/settings_screen.dart';

class AppRouter {
  final AuthProvider _authProvider;

  AppRouter(this._authProvider);

  late final GoRouter router = GoRouter(
    initialLocation: AppRoutes.root,
    redirect: _handleRedirect,
    refreshListenable: _authProvider,
    routes: [
      GoRoute(
        path: AppRoutes.root,
        name: 'root',
        pageBuilder: (context, state) => _buildPageWithTransition(
          context: context,
          state: state,
          child: const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        pageBuilder: (context, state) => _buildPageWithTransition(
          context: context,
          state: state,
          child: const LoginScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.dashboard,
        name: 'dashboard',
        pageBuilder: (context, state) => _buildShellPage(
          context: context,
          state: state,
          child: const DashboardScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.products,
        name: 'products',
        pageBuilder: (context, state) => _buildShellPage(
          context: context,
          state: state,
          child: const ProductsScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.productCreate,
        name: 'product-create',
        pageBuilder: (context, state) => _buildShellPage(
          context: context,
          state: state,
          child: const ProductFormScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.productDetails,
        name: 'product-detail',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return _buildShellPage(
            context: context,
            state: state,
            child: ProductDetailScreen(productId: id),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.productEdit,
        name: 'product-edit',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return _buildShellPage(
            context: context,
            state: state,
            child: ProductFormScreen(productId: id),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.finance,
        name: 'finance',
        pageBuilder: (context, state) => _buildShellPage(
          context: context,
          state: state,
          child: const FinanceScreen(),
        ),
        routes: [
          GoRoute(
            path: 'create-sale',
            name: 'finance-create-sale',
            pageBuilder: (context, state) => _buildShellPage(
              context: context,
              state: state,
              child: CreateSaleScreen(),
            ),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.invoices,
        name: 'invoices',
        pageBuilder: (context, state) => _buildShellPage(
          context: context,
          state: state,
          child: const InvoicesScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.invoiceCreate,
        name: 'invoice-create',
        pageBuilder: (context, state) => _buildShellPage(
          context: context,
          state: state,
          child: const InvoiceFormScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.invoiceDetails,
        name: 'invoice-detail',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return _buildShellPage(
            context: context,
            state: state,
            child: InvoiceDetailScreen(invoiceId: id),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.invoiceEdit,
        name: 'invoice-edit',
        pageBuilder: (context, state) {
          return _buildShellPage(
            context: context,
            state: state,
            child: const InvoiceFormScreen(),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.invoicePayments,
        name: 'invoice-payments',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return _buildShellPage(
            context: context,
            state: state,
            child: PaymentHistoryScreen(invoiceId: id),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.customers,
        name: 'customers',
        pageBuilder: (context, state) => _buildShellPage(
          context: context,
          state: state,
          child: const CustomersScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.customerCreate,
        name: 'customer-create',
        pageBuilder: (context, state) => _buildShellPage(
          context: context,
          state: state,
          child: const CustomerFormScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.customerDetails,
        name: 'customer-detail',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return _buildShellPage(
            context: context,
            state: state,
            child: CustomerDetailScreen(customerId: id),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.customerEdit,
        name: 'customer-edit',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return _buildShellPage(
            context: context,
            state: state,
            child: CustomerFormScreen(customerId: id),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.expenses,
        name: 'expenses',
        pageBuilder: (context, state) => _buildShellPage(
          context: context,
          state: state,
          child: const ExpensesScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.expenseAdd,
        name: 'expense-add',
        pageBuilder: (context, state) => _buildShellPage(
          context: context,
          state: state,
          child: const AddExpenseScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.expenseSummary,
        name: 'expense-summary',
        pageBuilder: (context, state) => _buildShellPage(
          context: context,
          state: state,
          child: const ExpenseSummaryScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.payroll,
        name: 'payroll',
        pageBuilder: (context, state) => _buildShellPage(
          context: context,
          state: state,
          child: const PayrollScreen(),
        ),
        routes: [
          GoRoute(
            path: 'add',
            name: 'payroll-add',
            pageBuilder: (context, state) => _buildShellPage(
              context: context,
              state: state,
              child: const AddEmployeeScreen(),
            ),
          ),
          GoRoute(
            path: ':id/edit',
            name: 'payroll-edit',
            pageBuilder: (context, state) {
              final id = state.pathParameters['id']!;
              return _buildShellPage(
                context: context,
                state: state,
                child: EditEmployeeScreen(employeeId: id),
              );
            },
          ),
          GoRoute(
            path: ':id/history',
            name: 'payroll-history',
            pageBuilder: (context, state) {
              final id = state.pathParameters['id']!;
              return _buildShellPage(
                context: context,
                state: state,
                child: SalaryHistoryScreen(employeeId: id),
              );
            },
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.reports,
        name: 'reports',
        pageBuilder: (context, state) => _buildShellPage(
          context: context,
          state: state,
          child: const ReportsHomeScreen(),
        ),
        routes: [
          GoRoute(
            path: 'sales',
            name: 'reports-sales',
            pageBuilder: (context, state) => _buildShellPage(
              context: context,
              state: state,
              child: SalesRegisterScreen(),
            ),
          ),
          GoRoute(
            path: 'purchases',
            name: 'reports-purchases',
            pageBuilder: (context, state) => _buildShellPage(
              context: context,
              state: state,
              child: PurchaseRegisterScreen(),
            ),
          ),
          GoRoute(
            path: 'expenses',
            name: 'reports-expenses',
            pageBuilder: (context, state) => _buildShellPage(
              context: context,
              state: state,
              child: const ExpenseStatementScreen(),
            ),
          ),
          GoRoute(
            path: 'gst',
            name: 'reports-gst',
            pageBuilder: (context, state) => _buildShellPage(
              context: context,
              state: state,
              child: GstSummaryScreen(),
            ),
          ),
          GoRoute(
            path: 'stock',
            name: 'reports-stock',
            pageBuilder: (context, state) => _buildShellPage(
              context: context,
              state: state,
              child: const StockStatementScreen(),
            ),
          ),
          GoRoute(
            path: 'profit',
            name: 'reports-profit',
            pageBuilder: (context, state) => _buildShellPage(
              context: context,
              state: state,
              child: const ProfitLossScreen(),
            ),
          ),
          GoRoute(
            path: 'payroll',
            name: 'reports-payroll',
            pageBuilder: (context, state) => _buildShellPage(
              context: context,
              state: state,
              child: const PayrollReportScreen(),
            ),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.settings,
        name: 'settings',
        pageBuilder: (context, state) => _buildShellPage(
          context: context,
          state: state,
          child: const SettingsScreen(),
        ),
      ),
      GoRoute(
        path: '/purchases/add',
        name: 'purchases-add',
        pageBuilder: (context, state) => _buildShellPage(
          context: context,
          state: state,
          child: const Scaffold(
            body: Center(child: Text('Coming Soon')),
          ),
        ),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.uri.path}'),
      ),
    ),
  );

  String? _handleRedirect(BuildContext context, GoRouterState state) {
    final isLoggedIn = _authProvider.isAuthenticated;
    final location = state.matchedLocation;
    final isLoginRoute = location == AppRoutes.login;
    final isRootRoute = location == AppRoutes.root;
    final isProtected = AppRoutes.isProtectedRoute(location);

    // During a browser refresh / cold start on web, GoRouter evaluates redirects
    // before async auth restoration finishes. Hold the user on the splash route
    // until auth initialization completes to prevent "false logout" redirects.
    if (!_authProvider.isInitialized) {
      return isRootRoute ? null : AppRoutes.root;
    }

    if (!isLoggedIn && (isProtected || isRootRoute) && !isLoginRoute) {
      return AppRoutes.login;
    }

    if (isLoggedIn && (isLoginRoute || isRootRoute)) {
      return AppRoutes.dashboard;
    }

    return null;
  }

  Page<dynamic> _buildShellPage({
    required BuildContext context,
    required GoRouterState state,
    required Widget child,
  }) {
    return _buildPageWithTransition(
      context: context,
      state: state,
      child: AppShell(child: child),
    );
  }

  Page<dynamic> _buildPageWithTransition({
    required BuildContext context,
    required GoRouterState state,
    required Widget child,
  }) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        final tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        final offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
    );
  }
}
