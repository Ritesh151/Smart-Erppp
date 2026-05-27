import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:smarterp/core/constants/app_constants.dart';
import 'package:smarterp/core/routes/app_routes.dart';
import 'package:smarterp/core/theme/theme_extensions.dart';

class SidebarMenu extends StatelessWidget {
  final bool isCollapsed;
  final VoidCallback onToggleCollapse;

  const SidebarMenu({
    super.key,
    required this.isCollapsed,
    required this.onToggleCollapse,
  });

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final currentRoute = GoRouterState.of(context).matchedLocation;

    bool isRouteActive(String route) {
      if (currentRoute == route) return true;
      if (route == AppRoutes.products && currentRoute.startsWith('/products')) return true;
      if (route == AppRoutes.customers && currentRoute.startsWith('/customers')) return true;
      if (route == AppRoutes.invoices && currentRoute.startsWith('/invoices')) return true;
      if (route == AppRoutes.payroll && currentRoute.startsWith('/payroll')) return true;
      return false;
    }

    return AnimatedContainer(
      duration: AppConstants.animationDuration,
      width: isCollapsed
          ? appTheme.sidebarCollapsedWidth
          : appTheme.sidebarWidth,
      decoration: BoxDecoration(
        color: appTheme.sidebarBackground,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(context, appTheme),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _buildMenuItem(
                  context: context,
                  icon: Icons.dashboard,
                  label: 'Dashboard',
                  route: AppRoutes.dashboard,
                  isActive: isRouteActive(AppRoutes.dashboard),
                  appTheme: appTheme,
                ),
                _buildMenuItem(
                  context: context,
                  icon: Icons.inventory_2,
                  label: 'Products',
                  route: AppRoutes.products,
                  isActive: isRouteActive(AppRoutes.products),
                  appTheme: appTheme,
                ),
                _buildMenuItem(
                  context: context,
                  icon: Icons.account_balance,
                  label: 'Finance',
                  route: AppRoutes.finance,
                  isActive: isRouteActive(AppRoutes.finance),
                  appTheme: appTheme,
                ),
                _buildMenuItem(
                  context: context,
                  icon: Icons.local_shipping,
                  label: 'Transport',
                  route: AppRoutes.transport,
                  isActive: isRouteActive(AppRoutes.transport),
                  appTheme: appTheme,
                ),
                _buildMenuItem(
                  context: context,
                  icon: Icons.people_outline,
                  label: 'Customers',
                  route: AppRoutes.customers,
                  isActive: isRouteActive(AppRoutes.customers),
                  appTheme: appTheme,
                ),
                _buildMenuItem(
                  context: context,
                  icon: Icons.receipt_long,
                  label: 'Bills & Invoices',
                  route: AppRoutes.invoices,
                  isActive: isRouteActive(AppRoutes.invoices),
                  appTheme: appTheme,
                ),
                _buildMenuItem(
                  context: context,
                  icon: Icons.payments,
                  label: 'Expenses',
                  route: AppRoutes.expenses,
                  isActive: isRouteActive(AppRoutes.expenses),
                  appTheme: appTheme,
                ),
                _buildMenuItem(
                  context: context,
                  icon: Icons.people,
                  label: 'Payroll',
                  route: AppRoutes.payroll,
                  isActive: isRouteActive(AppRoutes.payroll),
                  appTheme: appTheme,
                ),
                _buildMenuItem(
                  context: context,
                  icon: Icons.assessment,
                  label: 'Reports',
                  route: AppRoutes.reports,
                  isActive: isRouteActive(AppRoutes.reports),
                  appTheme: appTheme,
                ),
                const Divider(height: 32),
                _buildMenuItem(
                  context: context,
                  icon: Icons.settings,
                  label: 'Settings',
                  route: AppRoutes.settings,
                  isActive: isRouteActive(AppRoutes.settings),
                  appTheme: appTheme,
                ),
              ],
            ),
          ),
          _buildFooter(context, appTheme),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppThemeExtension appTheme) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16),
       decoration: BoxDecoration(
         border: Border(
           bottom: BorderSide(
             color: appTheme.cardBorder ?? Colors.grey.shade300,
           ),
         ),
       ),
      child: Row(
        children: [
          Icon(
            Icons.business,
            color: appTheme.sidebarItemActive,
            size: 32,
          ),
          if (!isCollapsed) ...[
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                AppConstants.appName,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: appTheme.sidebarItemActive,
                    ),
              ),
            ),
          ],
          IconButton(
            icon: Icon(
              isCollapsed ? Icons.menu_open : Icons.menu,
              color: appTheme.sidebarItemText,
            ),
            onPressed: onToggleCollapse,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String route,
    required bool isActive,
    required AppThemeExtension appTheme,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.go(route),
          borderRadius: BorderRadius.circular(8),
          child: AnimatedContainer(
            duration: AppConstants.shortAnimationDuration,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isActive
                  ? appTheme.sidebarItemActive
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isActive
                      ? appTheme.sidebarItemActiveText
                      : appTheme.sidebarItemText,
                  size: 24,
                ),
                if (!isCollapsed) ...[
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      label,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: isActive
                                ? appTheme.sidebarItemActiveText
                                : appTheme.sidebarItemText,
                            fontWeight:
                                isActive ? FontWeight.w600 : FontWeight.normal,
                          ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ).animate(target: isActive ? 1 : 0).scale(
            duration: AppConstants.shortAnimationDuration,
            begin: const Offset(0.98, 0.98),
            end: const Offset(1.0, 1.0),
          ),
    );
  }

  Widget _buildFooter(BuildContext context, AppThemeExtension appTheme) {
    return Container(
      padding: const EdgeInsets.all(16),
       decoration: BoxDecoration(
         border: Border(
           top: BorderSide(
             color: appTheme.cardBorder ?? Colors.grey.shade300,
           ),
         ),
       ),
      child: isCollapsed
          ? Icon(
              Icons.info_outline,
              color: appTheme.sidebarItemText,
            )
          : Text(
              'Version ${AppConstants.appVersion}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: appTheme.sidebarItemText,
                  ),
              textAlign: TextAlign.center,
            ),
    );
  }
}
