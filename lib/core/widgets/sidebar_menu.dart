import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:siddhivinayak_enterprise/core/constants/app_constants.dart';
import 'package:siddhivinayak_enterprise/core/routes/app_routes.dart';
import 'package:siddhivinayak_enterprise/core/theme/theme_extensions.dart';

class SidebarMenu extends StatefulWidget {
  const SidebarMenu({
    super.key,
    required this.isCollapsed,
    required this.onToggleCollapse,
  });

  final bool isCollapsed;
  final VoidCallback onToggleCollapse;

  @override
  State<SidebarMenu> createState() => _SidebarMenuState();
}

class _SidebarMenuState extends State<SidebarMenu> {
  static const Color _surface    = Color(0xFFFFFFFF);
  static const Color _slate200   = Color(0xFFE2E8F0);

  String? _hoveredRoute;

  static const double _collapsedWidth = 72.0;
  static const double _expandedWidth = 240.0;
  static const double _modeSwitchThreshold = 140.0;

  List<_SidebarSection> _buildMenuData() => [
    _SidebarSection(
      label: 'WORKSPACE',
      items: [
        _SidebarItem(
          icon: Icons.grid_view_rounded,
          label: 'Dashboard',
          route: AppRoutes.dashboard,
        ),
        _SidebarItem(
          icon: Icons.inventory_2_rounded,
          label: 'Products',
          route: AppRoutes.products,
        ),
        _SidebarItem(
          icon: Icons.account_balance_rounded,
          label: 'Finance',
          route: AppRoutes.finance,
        ),
        _SidebarItem(
          icon: Icons.people_outline_rounded,
          label: 'Customers',
          route: AppRoutes.customers,
        ),
      ],
    ),
    _SidebarSection(
      label: 'BILLING',
      items: [
        _SidebarItem(
          icon: Icons.receipt_long_rounded,
          label: 'Bills & Invoices',
          route: AppRoutes.invoices,
        ),
        _SidebarItem(
          icon: Icons.payments_rounded,
          label: 'Expenses',
          route: AppRoutes.expenses,
        ),
        _SidebarItem(
          icon: Icons.people_rounded,
          label: 'Labour Details',
          route: AppRoutes.payroll,
        ),
      ],
    ),
  ];

  bool _isActive(String route, String currentRoute) {
    if (currentRoute == route) return true;
    if (route == AppRoutes.products   && currentRoute.startsWith('/products'))  return true;
    if (route == AppRoutes.customers  && currentRoute.startsWith('/customers')) return true;
    if (route == AppRoutes.invoices   && currentRoute.startsWith('/invoices'))  return true;
    if (route == AppRoutes.payroll    && currentRoute.startsWith('/payroll'))   return true;
    if (route == AppRoutes.finance    && currentRoute.startsWith('/finance'))   return true;
    if (route == AppRoutes.expenses   && currentRoute.startsWith('/expenses'))  return true;
    if (route == AppRoutes.reports    && currentRoute.startsWith('/reports'))   return true;
    if (route == AppRoutes.settings   && currentRoute.startsWith('/settings'))  return true;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final appTheme     = context.appTheme;
    final currentRoute = GoRouterState.of(context).matchedLocation;
    final sections     = _buildMenuData();

    final double sidebarWidth = widget.isCollapsed
        ? (appTheme.sidebarCollapsedWidth ?? _collapsedWidth)
        : (appTheme.sidebarWidth ?? _expandedWidth);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: sidebarWidth,
      decoration: const BoxDecoration(
        color: _surface,
        border: Border(
          right: BorderSide(color: _slate200, width: 1),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final collapsed = w < _modeSwitchThreshold;

          return SafeArea(
            bottom: true,
            top: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Header(
                  isCollapsed: collapsed,
                  onToggle: widget.onToggleCollapse,
                ),

                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.only(top: 4, bottom: 4),
                    physics: const ClampingScrollPhysics(),
                    children: [
                      for (final section in sections) ...[
                        if (collapsed)
                          const _CollapsedSectionDivider()
                        else
                          _SectionLabel(label: section.label),
                        for (final item in section.items)
                          _NavItem(
                            item: item,
                            isActive: _isActive(item.route, currentRoute),
                            isHovered: _hoveredRoute == item.route,
                            isCollapsed: collapsed,
                            onHoverEnter: () =>
                                setState(() => _hoveredRoute = item.route),
                            onHoverExit: () =>
                                setState(() => _hoveredRoute = null),
                            onTap: () => context.go(item.route),
                          ),
                      ],

                      if (!collapsed)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 6, 12, 2),
                          child: Container(height: 1, color: _slate200),
                        ),

                      _NavItem(
                        item: const _SidebarItem(
                          icon: Icons.settings_rounded,
                          label: 'Settings',
                          route: AppRoutes.settings,
                        ),
                        isActive: _isActive(AppRoutes.settings, currentRoute),
                        isHovered: _hoveredRoute == AppRoutes.settings,
                        isCollapsed: collapsed,
                        onHoverEnter: () =>
                            setState(() => _hoveredRoute = AppRoutes.settings),
                        onHoverExit: () => setState(() => _hoveredRoute = null),
                        onTap: () => context.go(AppRoutes.settings),
                      ),

                      if (collapsed) const SizedBox(height: 4),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  _Header
// ══════════════════════════════════════════════════════════════

class _Header extends StatelessWidget {
  final bool isCollapsed;
  final VoidCallback onToggle;

  const _Header({required this.isCollapsed, required this.onToggle});

  static const Color _indigo500 = Color(0xFF4F46E5);
  static const Color _violet600 = Color(0xFF7C3AED);
  static const Color _slate200  = Color(0xFFE2E8F0);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: EdgeInsets.symmetric(
        horizontal: isCollapsed ? 14 : 16,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFFFFFFF),
        border: Border(bottom: BorderSide(color: _slate200, width: 1)),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_indigo500, _violet600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Icon(Icons.bolt_rounded, color: Colors.white, size: 18),
            ),
          ),

          if (!isCollapsed) ...[
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                AppConstants.appName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ],

          _CollapseButton(isCollapsed: isCollapsed, onTap: onToggle),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  _CollapseButton
// ══════════════════════════════════════════════════════════════

class _CollapseButton extends StatefulWidget {
  final bool isCollapsed;
  final VoidCallback onTap;
  const _CollapseButton({required this.isCollapsed, required this.onTap});

  @override
  State<_CollapseButton> createState() => _CollapseButtonState();
}

class _CollapseButtonState extends State<_CollapseButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: _hovered
                ? const Color(0xFFEEF2FF)
                : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _hovered
                  ? const Color(0xFFC7D2FE)
                  : const Color(0xFFE2E8F0),
            ),
          ),
          child: AnimatedRotation(
            turns: widget.isCollapsed ? 0.5 : 0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: const Icon(
              Icons.chevron_left_rounded,
              size: 16,
              color: Color(0xFF94A3B8),
            ),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  _SectionLabel & _CollapsedSectionDivider
// ══════════════════════════════════════════════════════════════

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 14, 4),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF94A3B8),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(height: 1, color: const Color(0xFFF1F5F9)),
          ),
        ],
      ),
    );
  }
}

class _CollapsedSectionDivider extends StatelessWidget {
  const _CollapsedSectionDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
      child: Container(height: 1, color: const Color(0xFFE2E8F0)),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  _NavItem — unified typography, no text scaling hacks
// ══════════════════════════════════════════════════════════════

class _NavItem extends StatefulWidget {
  final _SidebarItem item;
  final bool isActive;
  final bool isHovered;
  final bool isCollapsed;
  final VoidCallback onHoverEnter;
  final VoidCallback onHoverExit;
  final VoidCallback onTap;

  const _NavItem({
    required this.item,
    required this.isActive,
    required this.isHovered,
    required this.isCollapsed,
    required this.onHoverEnter,
    required this.onHoverExit,
    required this.onTap,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _localHover = false;

  static const Color _indigo500  = Color(0xFF4F46E5);
  static const Color _indigo50   = Color(0xFFEEF2FF);
  static const Color _slate900   = Color(0xFF0F172A);
  static const Color _slate600   = Color(0xFF475569);
  static const Color _slate400   = Color(0xFF94A3B8);
  static const Color _surfaceAlt = Color(0xFFF8F9FF);

  @override
  Widget build(BuildContext context) {
    final hovered = widget.isHovered || _localHover;
    final active = widget.isActive;
    final collapsed = widget.isCollapsed;

    final textStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
      fontSize: 14,
      height: 1.2,
      fontWeight: active ? FontWeight.w600 : FontWeight.w500,
      color: active
          ? _indigo500
          : hovered
              ? _slate900
              : _slate600,
      letterSpacing: 0,
    );

    Widget tile = MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        _localHover = true;
        widget.onHoverEnter();
      },
      onExit: (_) {
        _localHover = false;
        widget.onHoverExit();
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          height: 48,
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
          padding: EdgeInsets.only(
            left: collapsed ? 0 : 16,
            right: collapsed ? 0 : 16,
          ),
          decoration: BoxDecoration(
            color: active
                ? _indigo50
                : hovered
                    ? _surfaceAlt
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: active && !collapsed
                ? const Border(
                    left: BorderSide(color: _indigo500, width: 3),
                  )
                : null,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: collapsed
                ? MainAxisAlignment.center
                : MainAxisAlignment.start,
            children: [
              Icon(
                widget.item.icon,
                size: 20,
                color: active
                    ? _indigo500
                    : hovered
                        ? _indigo500
                        : _slate400,
              ),

              if (!collapsed) ...[
                const SizedBox(width: 12),

                Expanded(
                  child: Text(
                    widget.item.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textStyle,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );

    if (collapsed) {
      tile = Tooltip(
        message: widget.item.label,
        preferBelow: false,
        margin: const EdgeInsets.only(left: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.14),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        textStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        child: tile,
      );
    }

    return tile;
  }
}

// ══════════════════════════════════════════════════════════════
//  Data models (private)
// ══════════════════════════════════════════════════════════════

class _SidebarSection {
  final String label;
  final List<_SidebarItem> items;
  const _SidebarSection({required this.label, required this.items});
}

class _SidebarItem {
  final IconData icon;
  final String label;
  final String route;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.route,
  });
}
