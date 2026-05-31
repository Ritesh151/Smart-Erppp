import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:SmartERP/core/constants/app_constants.dart';
import 'package:SmartERP/core/routes/app_routes.dart';
import 'package:SmartERP/core/theme/theme_extensions.dart';

// ═══════════════════════════════════════════════════════════════
//  SidebarMenu — "Crystalline" design system v3
//  • Collapse/expand via LayoutBuilder-derived width (no flicker)
//  • Bottom footer always pinned, never clipped
//  • Premium hover micro-interactions with scale + glow
//  • Left gradient pill active indicator
//  • Tooltip overlay in collapsed mode
//  • Spring-curve entrance animations
// ═══════════════════════════════════════════════════════════════

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
  static const Color _emerald500 = Color(0xFF10B981);
  static const Color _rose500    = Color(0xFFEF4444);

  String? _hoveredRoute;

  static const double _collapsedWidth = 72.0;
  static const double _expandedWidth = 280.0;
  static const double _modeSwitchThreshold = 140.0;

  // ── Menu data ─────────────────────────────────────────────────
  List<_SidebarSection> _buildMenuData() => [
    _SidebarSection(
      label: 'WORKSPACE',
      items: [
        _SidebarItem(
          icon: Icons.grid_view_rounded,
          label: 'Dashboard',
          route: AppRoutes.dashboard,
          badge: null,
        ),
        _SidebarItem(
          icon: Icons.inventory_2_rounded,
          label: 'Products',
          route: AppRoutes.products,
          badge: null,
        ),
        _SidebarItem(
          icon: Icons.account_balance_rounded,
          label: 'Finance',
          route: AppRoutes.finance,
          badge: null,
        ),
        _SidebarItem(
          icon: Icons.shopping_bag_rounded,
          label: 'Purchases',
          route: AppRoutes.purchases,
          badge: null,
        ),
        _SidebarItem(
          icon: Icons.people_outline_rounded,
          label: 'Customers',
          route: AppRoutes.customers,
          badgeColor: _emerald500,
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
          badgeColor: _rose500,
        ),
        _SidebarItem(
          icon: Icons.payments_rounded,
          label: 'Expenses',
          route: AppRoutes.expenses,
          badge: null,
        ),
        _SidebarItem(
          icon: Icons.people_rounded,
          label: 'Labour Details',
          route: AppRoutes.payroll,
          badge: null,
        ),
      ],
    ),
  ];

  bool _isActive(String route, String currentRoute) {
    if (currentRoute == route) return true;
    if (route == AppRoutes.products   && currentRoute.startsWith('/products'))  return true;
    if (route == AppRoutes.customers  && currentRoute.startsWith('/customers')) return true;
    if (route == AppRoutes.invoices   && currentRoute.startsWith('/invoices'))  return true;
    if (route == AppRoutes.purchases  && currentRoute.startsWith('/purchases')) return true;
    if (route == AppRoutes.payroll    && currentRoute.startsWith('/payroll'))   return true;
    if (route == AppRoutes.finance    && currentRoute.startsWith('/finance'))   return true;
    if (route == AppRoutes.expenses   && currentRoute.startsWith('/expenses'))  return true;
    if (route == AppRoutes.reports    && currentRoute.startsWith('/reports'))   return true;
    if (route == AppRoutes.settings   && currentRoute.startsWith('/settings'))  return true;
    return false;
  }

  // ══════════════════════════════════════════════════════════════
  //  BUILD
  // ══════════════════════════════════════════════════════════════

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
            child: RepaintBoundary(
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
                          collapsed
                              ? const _CollapsedSectionDivider()
                              : _SectionLabel(label: section.label),
                          for (int i = 0; i < section.items.length; i++)
                            _NavItem(
                              item: section.items[i],
                              isActive: _isActive(section.items[i].route, currentRoute),
                              isHovered: _hoveredRoute == section.items[i].route,
                              isCollapsed: collapsed,
                              onHoverEnter: () =>
                                  setState(() => _hoveredRoute = section.items[i].route),
                              onHoverExit: () =>
                                  setState(() => _hoveredRoute = null),
                              onTap: () => context.go(section.items[i].route),
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
                            badge: null,
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

                  _Footer(isCollapsed: collapsed),
                ],
              ),
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
      height: 66,
      padding: EdgeInsets.symmetric(
        horizontal: isCollapsed ? 16 : 18,
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
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: _indigo500.withOpacity(0.28),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -3,
                  top: -3,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.14),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                const Center(
                  child: Icon(Icons.bolt_rounded, color: Colors.white, size: 17),
                ),
              ],
            ),
          ),

          if (!isCollapsed) ...[
            const SizedBox(width: 12),
            Expanded(
              child: ShaderMask(
                shaderCallback: (r) => const LinearGradient(
                  colors: [_indigo500, _violet600],
                ).createShader(r),
                child: Text(
                  AppConstants.appName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.sora(
                    fontSize: 15,
                    height: 1.25,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.2,
                  ),
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
      padding: const EdgeInsets.fromLTRB(16, 18, 14, 4),
      child: Row(
        children: [
          Text(
            label,
            style: GoogleFonts.sora(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Color(0xFF94A3B8),
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
//  _NavItem  — premium hover interactions
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
  static const Color _violet600  = Color(0xFF7C3AED);
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
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 1.5),
          padding: EdgeInsets.only(
            left: collapsed ? 6 : (active ? 8 : 12),
            right: collapsed ? 6 : 12,
            top: 10,
            bottom: 10,
          ),
          decoration: BoxDecoration(
            color: active
                ? _indigo50
                : hovered
                    ? _surfaceAlt
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: active && !collapsed
                ? const Border(
                    left: BorderSide(
                      color: _indigo500,
                      width: 3,
                    ),
                  )
                : null,
            boxShadow: hovered && !active
                ? [
                    BoxShadow(
                      color: _indigo500.withOpacity(0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: collapsed
                ? MainAxisAlignment.center
                : MainAxisAlignment.start,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: active
                      ? _indigo500.withOpacity(0.11)
                      : hovered
                          ? _indigo500.withOpacity(0.06)
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: AnimatedScale(
                  scale: hovered && !active ? 1.1 : 1.0,
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  child: active
                      ? ShaderMask(
                          shaderCallback: (b) => const LinearGradient(
                            colors: [_indigo500, _violet600],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ).createShader(b),
                          child: Icon(widget.item.icon, color: Colors.white, size: 17),
                        )
                      : Icon(
                          widget.item.icon,
                          size: 17,
                          color: hovered ? _indigo500 : _slate400,
                        ),
                ),
              ),

              if (!collapsed) ...[
                const SizedBox(width: 12),

                Expanded(
                  child: Text(
                    widget.item.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.sora(
                      fontSize: 14,
                      height: 1.25,
                      fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                      color: active
                          ? _indigo500
                          : hovered
                              ? _slate900
                              : _slate600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),

                if (widget.item.badge != null) ...[
                  const SizedBox(width: 6),
                  _Badge(
                    count: widget.item.badge!,
                    color: widget.item.badgeColor ?? _indigo500,
                  ),
                ],
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
              color: Colors.black.withOpacity(0.14),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        textStyle: GoogleFonts.sora(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          letterSpacing: 0.2,
        ),
        child: tile,
      );
    }

    return RepaintBoundary(child: tile);
  }
}

// ── Badge chip ──────────────────────────────────────────────────

class _Badge extends StatelessWidget {
  final String count;
  final Color color;
  const _Badge({required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        count,
        style: GoogleFonts.sora(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  _Footer — always pinned, never clipped
// ══════════════════════════════════════════════════════════════

class _Footer extends StatefulWidget {
  final bool isCollapsed;
  const _Footer({required this.isCollapsed});

  @override
  State<_Footer> createState() => _FooterState();
}

class _FooterState extends State<_Footer> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
          decoration: BoxDecoration(
            color: _hovered
                ? const Color(0xFFF8F9FF)
                : const Color(0xFFFFFFFF),
            border: const Border(
              top: BorderSide(color: Color(0xFFE2E8F0), width: 1),
            ),
          ),
          child: widget.isCollapsed
              ? const Center(child: _AvatarMark())
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Stack(
                      children: [
                        _AvatarMark(),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: _StatusDot(),
                        ),
                      ],
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Siddhivinayak Enterprise',
                        maxLines: 2,
                        style: GoogleFonts.sora(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0F172A),
                          letterSpacing: 0.2,
                          height: 1.25,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    AnimatedOpacity(
                      opacity: _hovered ? 1 : 0.45,
                      duration: const Duration(milliseconds: 160),
                      child: const Icon(
                        Icons.more_horiz_rounded,
                        size: 16,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

// ── Avatar mark ────────────────────────────────────────────────

class _AvatarMark extends StatelessWidget {
  const _AvatarMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF10B981), Color(0xFF059669)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Color(0x3810B981),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Text(
          'SE',
          style: GoogleFonts.sora(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  const _StatusDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 9,
      height: 9,
      decoration: const BoxDecoration(
        color: Color(0xFF22C55E),
        shape: BoxShape.circle,
        border: Border.fromBorderSide(BorderSide(color: Colors.white, width: 1.5)),
      ),
    );
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
  final String? badge;
  final Color? badgeColor;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.route,
    this.badge,
    this.badgeColor,
  });
}
