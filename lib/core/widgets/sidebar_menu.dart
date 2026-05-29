// import 'package:flutter/material.dart';
// import 'package:flutter_animate/flutter_animate.dart';
// import 'package:go_router/go_router.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:SmartERP/core/constants/app_constants.dart';
// import 'package:SmartERP/core/routes/app_routes.dart';
// import 'package:SmartERP/core/theme/theme_extensions.dart';

// class SidebarMenu extends StatefulWidget {
//   final bool isCollapsed;
//   final VoidCallback onToggleCollapse;

//   const SidebarMenu({
//     super.key,
//     required this.isCollapsed,
//     required this.onToggleCollapse,
//   });

//   @override
//   State<SidebarMenu> createState() => _SidebarMenuState();
// }

// class _SidebarMenuState extends State<SidebarMenu> {
//   // ── Brand colours ───────────────────────────────────────────────────────────
//   static const Color _gradientStart = Color(0xFF4F6EF7);
//   static const Color _gradientEnd   = Color(0xFF7C3AED);
//   static const Color _bgColor       = Color(0xFFF5F7FA);
//   static const Color _white         = Colors.white;
//   static const Color _textDark      = Color(0xFF111827);
//   static const Color _textMid       = Color(0xFF374151);
//   static const Color _textMuted     = Color(0xFF6B7280);
//   static const Color _textLight     = Color(0xFF9CA3AF);
//   static const Color _dividerColor  = Color(0xFFF0F1F5);
//   static const Color _sectionLabel  = Color(0xFFBBC0CC);

//   @override
//   Widget build(BuildContext context) {
//     final appTheme     = context.appTheme;
//     final currentRoute = GoRouterState.of(context).matchedLocation;

//     bool isRouteActive(String route) {
//       if (currentRoute == route) return true;
//       if (route == AppRoutes.products  && currentRoute.startsWith('/products'))  return true;
//       if (route == AppRoutes.customers && currentRoute.startsWith('/customers')) return true;
//       if (route == AppRoutes.invoices  && currentRoute.startsWith('/invoices'))  return true;
//       if (route == AppRoutes.payroll   && currentRoute.startsWith('/payroll'))   return true;
//       return false;
//     }

//     return AnimatedContainer(
//       duration: AppConstants.animationDuration,
//       curve: Curves.easeInOut,
//       width: widget.isCollapsed
//           ? (appTheme.sidebarCollapsedWidth ?? 70)
//           : (appTheme.sidebarWidth ?? 260),
//       decoration: BoxDecoration(
//         color: _white,
//         borderRadius: const BorderRadius.only(
//           topRight:    Radius.circular(20),
//           bottomRight: Radius.circular(20),
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: const Color(0xFF1E2A6E).withOpacity(0.09),
//             blurRadius: 40,
//             spreadRadius: 0,
//             offset: const Offset(4, 0),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           _buildHeader(context, appTheme),
//           Expanded(
//             child: ListView(
//               padding: const EdgeInsets.symmetric(vertical: 10),
//               children: [
//                 if (!widget.isCollapsed) _buildSectionLabel('MAIN'),
//                 _buildMenuItem(
//                   context: context,
//                   icon: Icons.dashboard_rounded,
//                   label: 'Dashboard',
//                   route: AppRoutes.dashboard,
//                   isActive: isRouteActive(AppRoutes.dashboard),
//                   delay: 80,
//                 ),
//                 _buildMenuItem(
//                   context: context,
//                   icon: Icons.inventory_2_rounded,
//                   label: 'Products',
//                   route: AppRoutes.products,
//                   isActive: isRouteActive(AppRoutes.products),
//                   delay: 120,
//                 ),
//                 _buildMenuItem(
//                   context: context,
//                   icon: Icons.account_balance_rounded,
//                   label: 'Finance',
//                   route: AppRoutes.finance,
//                   isActive: isRouteActive(AppRoutes.finance),
//                   delay: 160,
//                 ),
//                 _buildMenuItem(
//                   context: context,
//                   icon: Icons.local_shipping_rounded,
//                   label: 'Transport',
//                   route: AppRoutes.transport,
//                   isActive: isRouteActive(AppRoutes.transport),
//                   delay: 200,
//                 ),
//                 _buildMenuItem(
//                   context: context,
//                   icon: Icons.people_outline_rounded,
//                   label: 'Customers',
//                   route: AppRoutes.customers,
//                   isActive: isRouteActive(AppRoutes.customers),
//                   delay: 240,
//                 ),

//                 if (!widget.isCollapsed) _buildSectionLabel('BILLING'),
//                 if (widget.isCollapsed) const SizedBox(height: 4),

//                 _buildMenuItem(
//                   context: context,
//                   icon: Icons.receipt_long_rounded,
//                   label: 'Bills & Invoices',
//                   route: AppRoutes.invoices,
//                   isActive: isRouteActive(AppRoutes.invoices),
//                   delay: 280,
//                 ),
//                 _buildMenuItem(
//                   context: context,
//                   icon: Icons.payments_rounded,
//                   label: 'Expenses',
//                   route: AppRoutes.expenses,
//                   isActive: isRouteActive(AppRoutes.expenses),
//                   delay: 320,
//                 ),
//                 _buildMenuItem(
//                   context: context,
//                   icon: Icons.people_rounded,
//                   label: 'Payroll',
//                   route: AppRoutes.payroll,
//                   isActive: isRouteActive(AppRoutes.payroll),
//                   delay: 360,
//                 ),

//                 if (!widget.isCollapsed) _buildSectionLabel('ANALYTICS'),
//                 if (widget.isCollapsed) const SizedBox(height: 4),

//                 _buildMenuItem(
//                   context: context,
//                   icon: Icons.bar_chart_rounded,
//                   label: 'Reports',
//                   route: AppRoutes.reports,
//                   isActive: isRouteActive(AppRoutes.reports),
//                   delay: 400,
//                 ),

//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
//                   child: Divider(color: _dividerColor, thickness: 1, height: 1),
//                 ),

//                 _buildMenuItem(
//                   context: context,
//                   icon: Icons.settings_rounded,
//                   label: 'Settings',
//                   route: AppRoutes.settings,
//                   isActive: isRouteActive(AppRoutes.settings),
//                   delay: 440,
//                 ),
//               ],
//             ),
//           ),
//           _buildFooter(context),
//         ],
//       ),
//     );
//   }

//   // ── Header ──────────────────────────────────────────────────────────────────
//   Widget _buildHeader(BuildContext context, AppThemeExtension appTheme) {
//     return Container(
//       height: 70,
//       padding: const EdgeInsets.symmetric(horizontal: 14),
//       decoration: const BoxDecoration(
//         border: Border(bottom: BorderSide(color: _dividerColor, width: 1)),
//       ),
//       child: Row(
//         children: [
//           // Gradient logo
//           Container(
//             width: 38,
//             height: 38,
//             decoration: BoxDecoration(
//               gradient: const LinearGradient(
//                 colors: [_gradientStart, _gradientEnd],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//               borderRadius: BorderRadius.circular(11),
//               boxShadow: [
//                 BoxShadow(
//                   color: _gradientStart.withOpacity(0.32),
//                   blurRadius: 12,
//                   offset: const Offset(0, 4),
//                 ),
//               ],
//             ),
//             child: const Icon(Icons.business_rounded, color: _white, size: 19),
//           )
//               .animate()
//               .fadeIn(duration: 450.ms)
//               .scale(delay: 80.ms, duration: 380.ms, curve: Curves.easeOutBack),

//           if (!widget.isCollapsed) ...[
//             const SizedBox(width: 12),
//             Expanded(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     AppConstants.appName,
//                     style: GoogleFonts.dmSans(
//                       fontSize: 15,
//                       fontWeight: FontWeight.w700,
//                       color: _textDark,
//                       letterSpacing: -0.3,
//                     ),
//                   ),
//                   Text(
//                     'ERP PLATFORM',
//                     style: GoogleFonts.dmSans(
//                       fontSize: 9.5,
//                       fontWeight: FontWeight.w600,
//                       color: _textLight,
//                       letterSpacing: 1.2,
//                     ),
//                   ),
//                 ],
//               )
//                   .animate()
//                   .fadeIn(delay: 180.ms, duration: 350.ms)
//                   .slideX(begin: -0.15, end: 0, curve: Curves.easeOut),
//             ),
//           ],

//           // Collapse toggle
//           GestureDetector(
//             onTap: widget.onToggleCollapse,
//             child: AnimatedContainer(
//               duration: AppConstants.shortAnimationDuration,
//               width: 28,
//               height: 28,
//               decoration: BoxDecoration(
//                 color: _bgColor,
//                 borderRadius: BorderRadius.circular(8),
//                 border: Border.all(color: _dividerColor),
//               ),
//               child: AnimatedRotation(
//                 turns: widget.isCollapsed ? 0.5 : 0,
//                 duration: AppConstants.animationDuration,
//                 child: const Icon(
//                   Icons.keyboard_arrow_left_rounded,
//                   color: _textMuted,
//                   size: 17,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ── Section label ───────────────────────────────────────────────────────────
//   Widget _buildSectionLabel(String label) {
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(18, 14, 16, 4),
//       child: Text(
//         label,
//         style: GoogleFonts.dmSans(
//           fontSize: 9.5,
//           fontWeight: FontWeight.w700,
//           color: _sectionLabel,
//           letterSpacing: 1.4,
//         ),
//       ),
//     );
//   }

//   // ── Menu item ───────────────────────────────────────────────────────────────
//   Widget _buildMenuItem({
//     required BuildContext context,
//     required IconData icon,
//     required String label,
//     required String route,
//     required bool isActive,
//     int delay = 0,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
//       child: Material(
//         color: Colors.transparent,
//         borderRadius: BorderRadius.circular(11),
//         child: InkWell(
//           onTap: () => context.go(route),
//           borderRadius: BorderRadius.circular(11),
//           splashColor: _gradientStart.withOpacity(0.07),
//           highlightColor: _gradientStart.withOpacity(0.04),
//           child: AnimatedContainer(
//             duration: AppConstants.shortAnimationDuration,
//             curve: Curves.easeInOut,
//             padding: EdgeInsets.symmetric(
//               horizontal: widget.isCollapsed ? 0 : 12,
//               vertical: 10,
//             ),
//             decoration: BoxDecoration(
//               gradient: isActive
//                   ? const LinearGradient(
//                       colors: [_gradientStart, _gradientEnd],
//                       begin: Alignment.centerLeft,
//                       end: Alignment.centerRight,
//                     )
//                   : null,
//               borderRadius: BorderRadius.circular(11),
//               boxShadow: isActive
//                   ? [
//                       BoxShadow(
//                         color: _gradientStart.withOpacity(0.26),
//                         blurRadius: 14,
//                         offset: const Offset(0, 4),
//                       ),
//                     ]
//                   : [],
//             ),
//             child: Row(
//               mainAxisAlignment: widget.isCollapsed
//                   ? MainAxisAlignment.center
//                   : MainAxisAlignment.start,
//               children: [
//                 AnimatedContainer(
//                   duration: AppConstants.shortAnimationDuration,
//                   width: 30,
//                   height: 30,
//                   decoration: BoxDecoration(
//                     color: isActive
//                         ? _white.withOpacity(0.16)
//                         : _bgColor,
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Icon(
//                     icon,
//                     color: isActive ? _white : _textMuted,
//                     size: 16,
//                   ),
//                 ),
//                 if (!widget.isCollapsed) ...[
//                   const SizedBox(width: 10),
//                   Expanded(
//                     child: Text(
//                       label,
//                       style: GoogleFonts.dmSans(
//                         fontSize: 13,
//                         fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
//                         color: isActive ? _white : _textMid,
//                         letterSpacing: 0.1,
//                       ),
//                     ),
//                   ),
//                   if (isActive)
//                     Container(
//                       width: 5,
//                       height: 5,
//                       decoration: const BoxDecoration(
//                         color: _white,
//                         shape: BoxShape.circle,
//                       ),
//                     ),
//                 ],
//               ],
//             ),
//           ),
//         ),
//       ),
//     )
//         .animate()
//         .fadeIn(delay: Duration(milliseconds: delay), duration: 380.ms)
//         .slideX(begin: -0.12, end: 0, curve: Curves.easeOut);
//   }

//   // ── Footer ──────────────────────────────────────────────────────────────────
//   Widget _buildFooter(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(13),
//       decoration: const BoxDecoration(
//         border: Border(top: BorderSide(color: _dividerColor, width: 1)),
//       ),
//       child: widget.isCollapsed
//           ? Center(
//               child: Container(
//                 width: 30,
//                 height: 30,
//                 decoration: BoxDecoration(
//                   gradient: const LinearGradient(
//                     colors: [_gradientStart, _gradientEnd],
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                   ),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: const Icon(Icons.verified_rounded, color: _white, size: 15),
//               ),
//             )
//           : Row(
//               children: [
//                 Container(
//                   width: 32,
//                   height: 32,
//                   decoration: BoxDecoration(
//                     gradient: const LinearGradient(
//                       colors: [_gradientStart, _gradientEnd],
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                     ),
//                     borderRadius: BorderRadius.circular(8),
//                     boxShadow: [
//                       BoxShadow(
//                         color: _gradientStart.withOpacity(0.25),
//                         blurRadius: 8,
//                         offset: const Offset(0, 3),
//                       ),
//                     ],
//                   ),
//                   child: const Icon(Icons.verified_rounded, color: _white, size: 15),
//                 ),
//                 const SizedBox(width: 10),
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Secure Session',
//                       style: GoogleFonts.dmSans(
//                         fontSize: 11,
//                         fontWeight: FontWeight.w600,
//                         color: _textDark,
//                       ),
//                     ),
//                     Text(
//                       'v${AppConstants.appVersion}',
//                       style: GoogleFonts.dmSans(
//                         fontSize: 10,
//                         color: _textLight,
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//     )
//         .animate()
//         .fadeIn(delay: 550.ms, duration: 450.ms);
//   }
// }

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:SmartERP/core/constants/app_constants.dart';
import 'package:SmartERP/core/routes/app_routes.dart';
import 'package:SmartERP/core/theme/theme_extensions.dart';

// ═══════════════════════════════════════════════════════════════
//  SidebarMenu — "Crystalline" design system
//  • Light theme, fully responsive (mobile / desktop / web)
//  • Mouse-hover micro-interactions
//  • Left gradient pill active indicator
//  • Search bar with ⌘K shortcut badge
//  • Notification badges per item
//  • Tooltip overlay in collapsed mode
//  • Spring-curve entrance animations
//  • Online-status user profile footer
// ═══════════════════════════════════════════════════════════════

class SidebarMenu extends StatefulWidget {
  final bool isCollapsed;
  final VoidCallback onToggleCollapse;

  const SidebarMenu({
    super.key,
    required this.isCollapsed,
    required this.onToggleCollapse,
  });

  @override
  State<SidebarMenu> createState() => _SidebarMenuState();
}

class _SidebarMenuState extends State<SidebarMenu> {

  // ── Palette ─────────────────────────────────────────────────
  static const Color _indigo500   = Color(0xFF4F46E5);
  static const Color _violet600   = Color(0xFF7C3AED);
  static const Color _indigo50    = Color(0xFFEEF2FF);
  static const Color _surface     = Color(0xFFFFFFFF);
  static const Color _surfaceAlt  = Color(0xFFF8F9FF);
  static const Color _slate900    = Color(0xFF0F172A);
  static const Color _slate600    = Color(0xFF475569);
  static const Color _slate400    = Color(0xFF94A3B8);
  static const Color _slate200    = Color(0xFFE2E8F0);
  static const Color _slate100    = Color(0xFFF1F5F9);
  static const Color _slate300    = Color(0xFFCBD5E1);
  static const Color _emerald500  = Color(0xFF10B981);
  static const Color _rose500     = Color(0xFFEF4444);
  static const Color _amber500    = Color(0xFFF59E0B);

  String? _hoveredRoute;

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
          label: 'Payroll',
          route: AppRoutes.payroll,
          badge: null,
        ),
      ],
    ),
    _SidebarSection(
      label: 'ANALYTICS',
      items: [
        _SidebarItem(
          icon: Icons.bar_chart_rounded,
          label: 'Reports',
          route: AppRoutes.reports,
          badge: null,
        ),
      ],
    ),
  ];

  // ── Route active check ─────────────────────────────────────────
  bool _isActive(String route, String currentRoute) {
    if (currentRoute == route) return true;
    if (route == AppRoutes.products  && currentRoute.startsWith('/products'))  return true;
    if (route == AppRoutes.customers && currentRoute.startsWith('/customers')) return true;
    if (route == AppRoutes.invoices  && currentRoute.startsWith('/invoices'))  return true;
    if (route == AppRoutes.payroll   && currentRoute.startsWith('/payroll'))   return true;
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
        ? (appTheme.sidebarCollapsedWidth ?? 72.0)
        : (appTheme.sidebarWidth ?? 268.0);

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Header ─────────────────────────────────────────
          _Header(
            isCollapsed: widget.isCollapsed,
            onToggle: widget.onToggleCollapse,
          ),

          // ── Search bar (expanded only) ─────────────────────
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 220),
            crossFadeState: widget.isCollapsed
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: _SearchBar(),
            secondChild: const SizedBox.shrink(),
          ),

          // ── Scrollable nav ─────────────────────────────────
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 6),
              physics: const BouncingScrollPhysics(),
              children: [
                for (final section in sections) ...[
                  widget.isCollapsed
                      ? _CollapsedSectionDivider()
                      : _SectionLabel(label: section.label),
                  for (int i = 0; i < section.items.length; i++)
                    _NavItem(
                      item: section.items[i],
                      isActive: _isActive(section.items[i].route, currentRoute),
                      isHovered: _hoveredRoute == section.items[i].route,
                      isCollapsed: widget.isCollapsed,
                      delay: 50 + i * 55,
                      onHoverEnter: () =>
                          setState(() => _hoveredRoute = section.items[i].route),
                      onHoverExit: () =>
                          setState(() => _hoveredRoute = null),
                      onTap: () => context.go(section.items[i].route),
                    ),
                ],

                // ── Thin rule before Settings ──────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
                  child: Container(height: 1, color: _slate200),
                ),

                _NavItem(
                  item: _SidebarItem(
                    icon: Icons.settings_rounded,
                    label: 'Settings',
                    route: AppRoutes.settings,
                    badge: null,
                  ),
                  isActive: _isActive(AppRoutes.settings, currentRoute),
                  isHovered: _hoveredRoute == AppRoutes.settings,
                  isCollapsed: widget.isCollapsed,
                  delay: 0,
                  onHoverEnter: () =>
                      setState(() => _hoveredRoute = AppRoutes.settings),
                  onHoverExit: () => setState(() => _hoveredRoute = null),
                  onTap: () => context.go(AppRoutes.settings),
                ),
              ],
            ),
          ),

          // ── Footer ─────────────────────────────────────────
          _Footer(isCollapsed: widget.isCollapsed),
        ],
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
  static const Color _slate100  = Color(0xFFF1F5F9);
  static const Color _slate400  = Color(0xFF94A3B8);
  static const Color _slate900  = Color(0xFF0F172A);
  static const Color _surfaceAlt = Color(0xFFF8F9FF);

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
          // ── Gradient logo mark ────────────────────────────
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

          // ── App name & subtitle (expanded) ────────────────
          if (!isCollapsed) ...[
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShaderMask(
                    shaderCallback: (r) => const LinearGradient(
                      colors: [_indigo500, _violet600],
                    ).createShader(r),
                    child: Text(
                      AppConstants.appName,
                      style: GoogleFonts.sora(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    'Siddhivinayak Enterprise',
                    style: GoogleFonts.sora(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w500,
                      color: _slate400,
                      letterSpacing: 0.1,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // // ── Collapse toggle ───────────────────────────────
          // _CollapseButton(isCollapsed: isCollapsed, onTap: onToggle),
        ],
      ),
    );
  }
}

// ── Collapse button ─────────────────────────────────────────────

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
            child: Icon(
              Icons.chevron_left_rounded,
              size: 16,
              color: _hovered
                  ? const Color(0xFF4F46E5)
                  : const Color(0xFF94A3B8),
            ),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  _SearchBar
// ══════════════════════════════════════════════════════════════

class _SearchBar extends StatefulWidget {
  @override
  State<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () {/* open search overlay */},
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          margin: const EdgeInsets.fromLTRB(12, 10, 12, 2),
          height: 36,
          decoration: BoxDecoration(
            color: _hovered
                ? const Color(0xFFEEF2FF)
                : const Color(0xFFF8F9FF),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: _hovered
                  ? const Color(0xFFC7D2FE)
                  : const Color(0xFFE2E8F0),
            ),
          ),
          child: Row(
            children: [
              const SizedBox(width: 10),
              Icon(
                Icons.search_rounded,
                size: 14,
                color: _hovered
                    ? const Color(0xFF4F46E5)
                    : const Color(0xFF94A3B8),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  'Quick search…',
                  style: GoogleFonts.sora(
                    fontSize: 11.5,
                    color: const Color(0xFF94A3B8),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(right: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 5, vertical: 2.5),
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  '⌘K',
                  style: GoogleFonts.sora(
                    fontSize: 9,
                    color: const Color(0xFF94A3B8),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
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
              fontSize: 8.5,
              fontWeight: FontWeight.w700,
              color: const Color(0xFFCBD5E1),
              letterSpacing: 1.1,
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
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
      child: Container(height: 1, color: const Color(0xFFE2E8F0)),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  _NavItem  — the heart of the sidebar
// ══════════════════════════════════════════════════════════════

class _NavItem extends StatelessWidget {
  final _SidebarItem item;
  final bool isActive;
  final bool isHovered;
  final bool isCollapsed;
  final int delay;
  final VoidCallback onHoverEnter;
  final VoidCallback onHoverExit;
  final VoidCallback onTap;

  const _NavItem({
    required this.item,
    required this.isActive,
    required this.isHovered,
    required this.isCollapsed,
    required this.delay,
    required this.onHoverEnter,
    required this.onHoverExit,
    required this.onTap,
  });

  static const Color _indigo500  = Color(0xFF4F46E5);
  static const Color _violet600  = Color(0xFF7C3AED);
  static const Color _indigo50   = Color(0xFFEEF2FF);
  static const Color _slate900   = Color(0xFF0F172A);
  static const Color _slate600   = Color(0xFF475569);
  static const Color _slate400   = Color(0xFF94A3B8);
  static const Color _surfaceAlt = Color(0xFFF8F9FF);

  Widget _buildCore() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 170),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 1.5),
      padding: EdgeInsets.symmetric(
        horizontal: isCollapsed ? 0 : 10,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        color: isActive
            ? _indigo50
            : isHovered
                ? _surfaceAlt
                : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // ── Left pill indicator (active only) ──────────────
          if (isActive && !isCollapsed)
            Positioned(
              left: 0,
              top: 5,
              bottom: 5,
              child: Container(
                width: 3,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_indigo500, _violet600],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),

          // ── Content row ────────────────────────────────────
          Padding(
            padding: EdgeInsets.only(
              left: isActive && !isCollapsed ? 12 : 0,
            ),
            child: Row(
              mainAxisAlignment: isCollapsed
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.start,
              children: [
                // Icon
                AnimatedContainer(
                  duration: const Duration(milliseconds: 170),
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: isActive
                        ? _indigo500.withOpacity(0.11)
                        : isHovered
                            ? _indigo500.withOpacity(0.06)
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: isActive
                      ? ShaderMask(
                          shaderCallback: (b) => const LinearGradient(
                            colors: [_indigo500, _violet600],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ).createShader(b),
                          child: Icon(item.icon, color: Colors.white, size: 15),
                        )
                      : Icon(
                          item.icon,
                          size: 15,
                          color: isHovered ? _indigo500 : _slate400,
                        ),
                ),

                if (!isCollapsed) ...[
                  const SizedBox(width: 10),

                  // Label
                  Expanded(
                    child: Text(
                      item.label,
                      style: GoogleFonts.sora(
                        fontSize: 12.5,
                        fontWeight:
                            isActive ? FontWeight.w700 : FontWeight.w500,
                        color: isActive
                            ? _indigo500
                            : isHovered
                                ? _slate900
                                : _slate600,
                        letterSpacing: -0.1,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  // Badge
                  if (item.badge != null) ...[
                    const SizedBox(width: 4),
                    _Badge(
                      count: item.badge!,
                      color: item.badgeColor ?? _indigo500,
                    ),
                  ],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget tile = MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => onHoverEnter(),
      onExit: (_) => onHoverExit(),
      child: GestureDetector(
        onTap: onTap,
        child: _buildCore(),
      ),
    );

    // Collapsed: wrap with tooltip
    if (isCollapsed) {
      tile = Tooltip(
        message: item.label,
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
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        child: tile,
      );
    }

    return tile;
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
          fontSize: 9.5,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  _Footer
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
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _hovered
              ? const Color(0xFFF8F9FF)
              : const Color(0xFFFFFFFF),
          border: const Border(
            top: BorderSide(color: Color(0xFFE2E8F0), width: 1),
          ),
        ),
        child: widget.isCollapsed
            ? Center(child: _AvatarMark())
            : Row(
                children: [
                  Stack(
                    children: [
                      _AvatarMark(),
                      // Online dot
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 9,
                          height: 9,
                          decoration: BoxDecoration(
                            color: const Color(0xFF22C55E),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Siddhivinayak Enterprise',
                          style: GoogleFonts.sora(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                  ),
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
    );
  }
}

// ── Avatar mark ────────────────────────────────────────────────

class _AvatarMark extends StatelessWidget {
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
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withOpacity(0.22),
            blurRadius: 8,
            offset: const Offset(0, 3),
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
          ),
        ),
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
