import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:SmartERP/core/constants/storage_keys.dart';
import 'package:SmartERP/core/extensions/context_extensions.dart';
import 'package:SmartERP/core/routes/app_routes.dart';
import 'package:SmartERP/core/storage/preferences_service.dart';
import 'package:SmartERP/core/widgets/sidebar_menu.dart';
import 'package:SmartERP/modules/auth/providers/auth_provider.dart';

class AppShell extends StatefulWidget {
  final Widget child;
  final String? title;

  const AppShell({
    super.key,
    required this.child,
    this.title,
  });

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  bool _isCollapsed = false;

  @override
  void initState() {
    super.initState();
    _loadSidebarState();
  }

  Future<void> _loadSidebarState() async {
    final prefs = await PreferencesService.getInstance();
    final collapsed = prefs.getBool(
      StorageKeys.sidebarCollapsed,
      defaultValue: false,
    );
    if (mounted) {
      setState(() {
        _isCollapsed = collapsed ?? false;
      });
    }
  }

  Future<void> _toggleSidebar() async {
    setState(() {
      _isCollapsed = !_isCollapsed;
    });
    final prefs = await PreferencesService.getInstance();
    await prefs.setBool(StorageKeys.sidebarCollapsed, _isCollapsed);
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await context.read<AuthProvider>().logout();
      if (mounted) {
        context.go(AppRoutes.login);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (context.isMobile) {
      return _buildMobileLayout();
    } else if (context.isTablet) {
      return _buildTabletLayout();
    } else {
      return _buildDesktopLayout();
    }
  }

  Widget _buildDesktopLayout() {
    return Scaffold(
      body: Row(
        children: [
          SidebarMenu(
            isCollapsed: _isCollapsed,
            onToggleCollapse: _toggleSidebar,
          ),
          Expanded(
            child: Column(
              children: [
                _buildAppBar(),
                Expanded(
                  child: widget.child,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabletLayout() {
    return Scaffold(
      body: Row(
        children: [
          SidebarMenu(
            isCollapsed: _isCollapsed,
            onToggleCollapse: _toggleSidebar,
          ),
          Expanded(
            child: Column(
              children: [
                _buildAppBar(),
                Expanded(
                  child: widget.child,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SmartERP'),
        actions: [
          _buildUserMenu(),
        ],
      ),
      drawer: Drawer(
        child: SidebarMenu(
          isCollapsed: false,
          onToggleCollapse: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: widget.child,
    );
  }

   Widget _buildAppBar() {
     final user = context.watch<AuthProvider>().currentUser;

     return Container(
       height: 64,
       padding: const EdgeInsets.symmetric(horizontal: 24),
       decoration: BoxDecoration(
         color: context.colorScheme.surface,
         boxShadow: [
           BoxShadow(
             color: Colors.black.withOpacity(0.05),
             blurRadius: 4,
             offset: const Offset(0, 2),
           ),
         ],
       ),
       child: Row(
         children: [
           Expanded(
             child: Text(
               widget.title ?? _getPageTitle(context),
               style: context.textTheme.titleLarge?.copyWith(
                 fontWeight: FontWeight.w600,
               ),
             ),
           ),
           _buildUserMenu(),
         ],
       ),
     );
   }

  Widget _buildUserMenu() {
    final user = context.watch<AuthProvider>().currentUser;

    return PopupMenuButton<String>(
      offset: const Offset(0, 50),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            backgroundColor: context.colorScheme.primary,
            child: Text(
              user?.name.substring(0, 1).toUpperCase() ?? 'U',
              style: TextStyle(
                color: context.colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (!context.isMobile) ...[
            const SizedBox(width: 12),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.name ?? 'User',
                  style: context.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  user?.email ?? '',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_drop_down),
          ],
        ],
      ),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'profile',
          child: const Row(
            children: [
              Icon(Icons.person_outline),
              SizedBox(width: 12),
              Text('Profile'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'settings',
          child: const Row(
            children: [
              Icon(Icons.settings_outlined),
              SizedBox(width: 12),
              Text('Settings'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout, color: context.colorScheme.error),
              const SizedBox(width: 12),
              Text(
                'Logout',
                style: TextStyle(color: context.colorScheme.error),
              ),
            ],
          ),
        ),
      ],
      onSelected: (value) {
        switch (value) {
          case 'profile':
            break;
          case 'settings':
            context.go(AppRoutes.settings);
            break;
          case 'logout':
            _handleLogout();
            break;
        }
      },
    );
  }

  String _getPageTitle(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location == AppRoutes.dashboard) return 'Dashboard';
    if (location.startsWith('/products')) return 'Products';
    if (location == AppRoutes.finance) return 'Finance';
    if (location == AppRoutes.transport) return 'Transport';
    if (location.startsWith('/invoices')) return 'Bills & Invoices';
    if (location.startsWith('/customers')) return 'Customers';
    if (location == AppRoutes.expenses) return 'Expenses';
    if (location.startsWith('/payroll')) return 'Payroll';
    if (location == AppRoutes.reports) return 'Reports';
    if (location == AppRoutes.settings) return 'Settings';
    return 'SmartERP';
  }
}
