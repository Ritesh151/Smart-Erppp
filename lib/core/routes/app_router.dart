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
import 'package:SmartERP/core/models/expense_model.dart';

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
import 'package:SmartERP/modules/expenses/screens/expense_detail_screen.dart';
import 'package:SmartERP/modules/payroll/screens/payroll_screen.dart';
import 'package:SmartERP/modules/payroll/payroll_dashboard_screen.dart';
import 'package:SmartERP/modules/payroll/add_employee_screen.dart';
import 'package:SmartERP/modules/payroll/edit_employee_screen.dart';
import 'package:SmartERP/modules/payroll/salary_payment_screen.dart';
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
import 'package:SmartERP/modules/purchase/screens/purchase_list_screen.dart';
import 'package:SmartERP/modules/purchase/screens/purchase_entry_screen.dart';
import 'package:SmartERP/modules/purchase/screens/purchase_detail_screen.dart';

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
      ),
      GoRoute(
        path: AppRoutes.invoices,
        name: 'invoices',
        pageBuilder: (context, state) => _buildShellPage(
          context: context,
          state: state,
          child: const InvoicesScreen(),
        ),
        routes: [
          GoRoute(
            path: 'create',
            name: 'invoice-create',
            pageBuilder: (context, state) => _buildShellPage(
              context: context,
              state: state,
              child: const InvoiceFormScreen(),
            ),
          ),
          GoRoute(
            path: ':id',
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
            path: ':id/edit',
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
            path: ':id/payments',
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
        ],
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
        routes: [
          GoRoute(
            path: 'add',
            name: 'expense-add',
            pageBuilder: (context, state) => _buildShellPage(
              context: context,
              state: state,
              child: const AddExpenseScreen(),
            ),
          ),
          GoRoute(
            path: ':id',
            name: 'expense-detail',
            pageBuilder: (context, state) {
              final id = state.pathParameters['id']!;
              return _buildShellPage(
                context: context,
                state: state,
                child: ExpenseDetailScreen(expenseId: id),
              );
            },
          ),
          GoRoute(
            path: ':id/edit',
            name: 'expense-edit',
            pageBuilder: (context, state) {
              final expense = state.extra as ExpenseModel?;
              return _buildShellPage(
                context: context,
                state: state,
                child: AddExpenseScreen(expense: expense),
              );
            },
          ),
          GoRoute(
            path: 'summary',
            name: 'expense-summary',
            pageBuilder: (context, state) => _buildShellPage(
              context: context,
              state: state,
              child: const ExpenseSummaryScreen(),
            ),
          ),
        ],
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
            path: ':id/salary',
            name: 'payroll-salary',
            pageBuilder: (context, state) {
              final id = state.pathParameters['id']!;
              return _buildShellPage(
                context: context,
                state: state,
                child: SalaryPaymentScreen(employeeId: id),
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
        path: AppRoutes.purchases,
        name: 'purchases',
        pageBuilder: (context, state) => _buildShellPage(
          context: context,
          state: state,
          child: const PurchaseListScreen(),
        ),
        routes: [
          GoRoute(
            path: 'create',
            name: 'purchase-create',
            pageBuilder: (context, state) => _buildShellPage(
              context: context,
              state: state,
              child: const PurchaseEntryScreen(),
            ),
          ),
          GoRoute(
            path: ':id',
            name: 'purchase-detail',
            pageBuilder: (context, state) {
              final id = state.pathParameters['id']!;
              return _buildShellPage(
                context: context,
                state: state,
                child: PurchaseDetailScreen(purchaseId: id),
              );
            },
          ),
          GoRoute(
            path: ':id/edit',
            name: 'purchase-edit',
            pageBuilder: (context, state) {
              return _buildShellPage(
                context: context,
                state: state,
                child: const PurchaseEntryScreen(),
              );
            },
          ),
        ],
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
      transitionDuration: const Duration(milliseconds: 250),
      reverseTransitionDuration: const Duration(milliseconds: 200),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final slideTween = Tween<Offset>(
          begin: const Offset(0.0, 0.06),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeOutCubic));

        final fadeTween = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeOut));

        return SlideTransition(
          position: animation.drive(slideTween),
          child: FadeTransition(
            opacity: animation.drive(fadeTween),
            child: child,
          ),
        );
      },
    );
  }

  Widget _buildPlaceholderPage(String title, IconData icon) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: const Color(0xFF94A3B8)),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'This feature is being developed and will be available soon.',
              style: TextStyle(fontSize: 14, color: Color(0xFF94A3B8)),
            ),
          ],
        ),
      ),
    );
  }
}
