import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smarterp/core/routes/app_routes.dart';
import 'package:smarterp/modules/auth/screens/login_screen.dart';
import 'package:smarterp/modules/dashboard/screens/dashboard_screen.dart';
import 'package:smarterp/modules/products/screens/products_screen.dart';
import 'package:smarterp/modules/products/screens/product_form_screen.dart';
import 'package:smarterp/modules/products/screens/product_detail_screen.dart';
import 'package:smarterp/modules/finance/screens/finance_screen.dart';
import 'package:smarterp/modules/transport/screens/transport_screen.dart';
import 'package:smarterp/modules/invoice/screens/invoices_screen.dart';
import 'package:smarterp/modules/invoice/screens/invoice_form_screen.dart';
import 'package:smarterp/modules/invoice/screens/invoice_detail_screen.dart';
import 'package:smarterp/modules/invoice/screens/payment_history_screen.dart';
import 'package:smarterp/modules/invoice/screens/customers_screen.dart';
import 'package:smarterp/modules/invoice/screens/customer_form_screen.dart';
import 'package:smarterp/modules/invoice/screens/customer_detail_screen.dart';
import 'package:smarterp/modules/expenses/screens/expenses_screen.dart';
import 'package:smarterp/modules/payroll/screens/payroll_screen.dart';
import 'package:smarterp/modules/reports/screens/reports_screen.dart';
import 'package:smarterp/modules/settings/screens/settings_screen.dart';
import 'package:smarterp/core/services/auth_service.dart';

class AppRouter {
  final AuthService _authService;

  AppRouter(this._authService);

  late final GoRouter router = GoRouter(
    initialLocation: AppRoutes.login,
    redirect: _handleRedirect,
    routes: [
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
        pageBuilder: (context, state) => _buildPageWithTransition(
          context: context,
          state: state,
          child: const DashboardScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.products,
        name: 'products',
        pageBuilder: (context, state) => _buildPageWithTransition(
          context: context,
          state: state,
          child: const ProductsScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.productCreate,
        name: 'product-create',
        pageBuilder: (context, state) => _buildPageWithTransition(
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
          return _buildPageWithTransition(
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
          return _buildPageWithTransition(
            context: context,
            state: state,
            child: ProductFormScreen(productId: id),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.finance,
        name: 'finance',
        pageBuilder: (context, state) => _buildPageWithTransition(
          context: context,
          state: state,
          child: const FinanceScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.transport,
        name: 'transport',
        pageBuilder: (context, state) => _buildPageWithTransition(
          context: context,
          state: state,
          child: const TransportScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.invoices,
        name: 'invoices',
        pageBuilder: (context, state) => _buildPageWithTransition(
          context: context,
          state: state,
          child: const InvoicesScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.invoiceCreate,
        name: 'invoice-create',
        pageBuilder: (context, state) => _buildPageWithTransition(
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
          return _buildPageWithTransition(
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
          final id = state.pathParameters['id']!;
          return _buildPageWithTransition(
            context: context,
            state: state,
            child: InvoiceFormScreen(),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.invoicePayments,
        name: 'invoice-payments',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return _buildPageWithTransition(
            context: context,
            state: state,
            child: PaymentHistoryScreen(invoiceId: id),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.customers,
        name: 'customers',
        pageBuilder: (context, state) => _buildPageWithTransition(
          context: context,
          state: state,
          child: const CustomersScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.customerCreate,
        name: 'customer-create',
        pageBuilder: (context, state) => _buildPageWithTransition(
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
          return _buildPageWithTransition(
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
          return _buildPageWithTransition(
            context: context,
            state: state,
            child: CustomerFormScreen(customerId: id),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.expenses,
        name: 'expenses',
        pageBuilder: (context, state) => _buildPageWithTransition(
          context: context,
          state: state,
          child: const ExpensesScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.payroll,
        name: 'payroll',
        pageBuilder: (context, state) => _buildPageWithTransition(
          context: context,
          state: state,
          child: const PayrollScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.reports,
        name: 'reports',
        pageBuilder: (context, state) => _buildPageWithTransition(
          context: context,
          state: state,
          child: const ReportsScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.settings,
        name: 'settings',
        pageBuilder: (context, state) => _buildPageWithTransition(
          context: context,
          state: state,
          child: const SettingsScreen(),
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
    final isLoggedIn = _authService.isAuthenticated;
    final isLoginRoute = state.matchedLocation == AppRoutes.login;

    if (!isLoggedIn && !isLoginRoute) {
      return AppRoutes.login;
    }

    if (isLoggedIn && isLoginRoute) {
      return AppRoutes.dashboard;
    }

    return null;
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
