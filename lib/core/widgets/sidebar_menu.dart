import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:SmartERP/core/constants/app_constants.dart';
import 'package:SmartERP/core/routes/app_routes.dart';
import 'package:SmartERP/core/theme/theme_extensions.dart';

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
  // ── Brand colours ───────────────────────────────────────────────────────────
  static const Color _gradientStart = Color(0xFF4F6EF7);
  static const Color _gradientEnd   = Color(0xFF7C3AED);
  static const Color _bgColor       = Color(0xFFF5F7FA);
  static const Color _white         = Colors.white;
  static const Color _textDark      = Color(0xFF111827);
  static const Color _textMid       = Color(0xFF374151);
  static const Color _textMuted     = Color(0xFF6B7280);
  static const Color _textLight     = Color(0xFF9CA3AF);
  static const Color _dividerColor  = Color(0xFFF0F1F5);
  static const Color _sectionLabel  = Color(0xFFBBC0CC);

  @override
  Widget build(BuildContext context) {
    final appTheme     = context.appTheme;
    final currentRoute = GoRouterState.of(context).matchedLocation;

    bool isRouteActive(String route) {
      if (currentRoute == route) return true;
      if (route == AppRoutes.products  && currentRoute.startsWith('/products'))  return true;
      if (route == AppRoutes.customers && currentRoute.startsWith('/customers')) return true;
      if (route == AppRoutes.invoices  && currentRoute.startsWith('/invoices'))  return true;
      if (route == AppRoutes.payroll   && currentRoute.startsWith('/payroll'))   return true;
      return false;
    }

    return AnimatedContainer(
      duration: AppConstants.animationDuration,
      curve: Curves.easeInOut,
      width: widget.isCollapsed
          ? (appTheme.sidebarCollapsedWidth ?? 70)
          : (appTheme.sidebarWidth ?? 260),
      decoration: BoxDecoration(
        color: _white,
        borderRadius: const BorderRadius.only(
          topRight:    Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E2A6E).withOpacity(0.09),
            blurRadius: 40,
            spreadRadius: 0,
            offset: const Offset(4, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(context, appTheme),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 10),
              children: [
                if (!widget.isCollapsed) _buildSectionLabel('MAIN'),
                _buildMenuItem(
                  context: context,
                  icon: Icons.dashboard_rounded,
                  label: 'Dashboard',
                  route: AppRoutes.dashboard,
                  isActive: isRouteActive(AppRoutes.dashboard),
                  delay: 80,
                ),
                _buildMenuItem(
                  context: context,
                  icon: Icons.inventory_2_rounded,
                  label: 'Products',
                  route: AppRoutes.products,
                  isActive: isRouteActive(AppRoutes.products),
                  delay: 120,
                ),
                _buildMenuItem(
                  context: context,
                  icon: Icons.account_balance_rounded,
                  label: 'Finance',
                  route: AppRoutes.finance,
                  isActive: isRouteActive(AppRoutes.finance),
                  delay: 160,
                ),
                _buildMenuItem(
                  context: context,
                  icon: Icons.local_shipping_rounded,
                  label: 'Transport',
                  route: AppRoutes.transport,
                  isActive: isRouteActive(AppRoutes.transport),
                  delay: 200,
                ),
                _buildMenuItem(
                  context: context,
                  icon: Icons.people_outline_rounded,
                  label: 'Customers',
                  route: AppRoutes.customers,
                  isActive: isRouteActive(AppRoutes.customers),
                  delay: 240,
                ),

                if (!widget.isCollapsed) _buildSectionLabel('BILLING'),
                if (widget.isCollapsed) const SizedBox(height: 4),

                _buildMenuItem(
                  context: context,
                  icon: Icons.receipt_long_rounded,
                  label: 'Bills & Invoices',
                  route: AppRoutes.invoices,
                  isActive: isRouteActive(AppRoutes.invoices),
                  delay: 280,
                ),
                _buildMenuItem(
                  context: context,
                  icon: Icons.payments_rounded,
                  label: 'Expenses',
                  route: AppRoutes.expenses,
                  isActive: isRouteActive(AppRoutes.expenses),
                  delay: 320,
                ),
                _buildMenuItem(
                  context: context,
                  icon: Icons.people_rounded,
                  label: 'Payroll',
                  route: AppRoutes.payroll,
                  isActive: isRouteActive(AppRoutes.payroll),
                  delay: 360,
                ),

                if (!widget.isCollapsed) _buildSectionLabel('ANALYTICS'),
                if (widget.isCollapsed) const SizedBox(height: 4),

                _buildMenuItem(
                  context: context,
                  icon: Icons.bar_chart_rounded,
                  label: 'Reports',
                  route: AppRoutes.reports,
                  isActive: isRouteActive(AppRoutes.reports),
                  delay: 400,
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  child: Divider(color: _dividerColor, thickness: 1, height: 1),
                ),

                _buildMenuItem(
                  context: context,
                  icon: Icons.settings_rounded,
                  label: 'Settings',
                  route: AppRoutes.settings,
                  isActive: isRouteActive(AppRoutes.settings),
                  delay: 440,
                ),
              ],
            ),
          ),
          _buildFooter(context),
        ],
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context, AppThemeExtension appTheme) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: _dividerColor, width: 1)),
      ),
      child: Row(
        children: [
          // Gradient logo
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_gradientStart, _gradientEnd],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(11),
              boxShadow: [
                BoxShadow(
                  color: _gradientStart.withOpacity(0.32),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.business_rounded, color: _white, size: 19),
          )
              .animate()
              .fadeIn(duration: 450.ms)
              .scale(delay: 80.ms, duration: 380.ms, curve: Curves.easeOutBack),

          if (!widget.isCollapsed) ...[
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppConstants.appName,
                    style: GoogleFonts.dmSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: _textDark,
                      letterSpacing: -0.3,
                    ),
                  ),
                  Text(
                    'ERP PLATFORM',
                    style: GoogleFonts.dmSans(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w600,
                      color: _textLight,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              )
                  .animate()
                  .fadeIn(delay: 180.ms, duration: 350.ms)
                  .slideX(begin: -0.15, end: 0, curve: Curves.easeOut),
            ),
          ],

          // Collapse toggle
          GestureDetector(
            onTap: widget.onToggleCollapse,
            child: AnimatedContainer(
              duration: AppConstants.shortAnimationDuration,
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: _bgColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _dividerColor),
              ),
              child: AnimatedRotation(
                turns: widget.isCollapsed ? 0.5 : 0,
                duration: AppConstants.animationDuration,
                child: const Icon(
                  Icons.keyboard_arrow_left_rounded,
                  color: _textMuted,
                  size: 17,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Section label ───────────────────────────────────────────────────────────
  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 16, 4),
      child: Text(
        label,
        style: GoogleFonts.dmSans(
          fontSize: 9.5,
          fontWeight: FontWeight.w700,
          color: _sectionLabel,
          letterSpacing: 1.4,
        ),
      ),
    );
  }

  // ── Menu item ───────────────────────────────────────────────────────────────
  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String route,
    required bool isActive,
    int delay = 0,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(11),
        child: InkWell(
          onTap: () => context.go(route),
          borderRadius: BorderRadius.circular(11),
          splashColor: _gradientStart.withOpacity(0.07),
          highlightColor: _gradientStart.withOpacity(0.04),
          child: AnimatedContainer(
            duration: AppConstants.shortAnimationDuration,
            curve: Curves.easeInOut,
            padding: EdgeInsets.symmetric(
              horizontal: widget.isCollapsed ? 0 : 12,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              gradient: isActive
                  ? const LinearGradient(
                      colors: [_gradientStart, _gradientEnd],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    )
                  : null,
              borderRadius: BorderRadius.circular(11),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: _gradientStart.withOpacity(0.26),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: Row(
              mainAxisAlignment: widget.isCollapsed
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.start,
              children: [
                AnimatedContainer(
                  duration: AppConstants.shortAnimationDuration,
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: isActive
                        ? _white.withOpacity(0.16)
                        : _bgColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: isActive ? _white : _textMuted,
                    size: 16,
                  ),
                ),
                if (!widget.isCollapsed) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      label,
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                        color: isActive ? _white : _textMid,
                        letterSpacing: 0.1,
                      ),
                    ),
                  ),
                  if (isActive)
                    Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        color: _white,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: delay), duration: 380.ms)
        .slideX(begin: -0.12, end: 0, curve: Curves.easeOut);
  }

  // ── Footer ──────────────────────────────────────────────────────────────────
  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: _dividerColor, width: 1)),
      ),
      child: widget.isCollapsed
          ? Center(
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_gradientStart, _gradientEnd],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.verified_rounded, color: _white, size: 15),
              ),
            )
          : Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [_gradientStart, _gradientEnd],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: _gradientStart.withOpacity(0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.verified_rounded, color: _white, size: 15),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Secure Session',
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _textDark,
                      ),
                    ),
                    Text(
                      'v${AppConstants.appVersion}',
                      style: GoogleFonts.dmSans(
                        fontSize: 10,
                        color: _textLight,
                      ),
                    ),
                  ],
                ),
              ],
            ),
    )
        .animate()
        .fadeIn(delay: 550.ms, duration: 450.ms);
  }
}
