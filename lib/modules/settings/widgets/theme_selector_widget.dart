import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:SmartERP/core/theme/app_theme.dart';
import 'package:SmartERP/modules/settings/providers/theme_provider.dart';

class ThemeSelectorWidget extends StatelessWidget {
  const ThemeSelectorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 600 ? 2 : 1;
        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.6,
          children: [
            _ThemePreviewCard(
              index: 0,
              name: 'Light',
              isSelected: themeProvider.currentTheme == AppThemeMode.light,
              primaryColor: const Color(0xFF1976D2),
              surfaceColor: Colors.white,
              textColor: Colors.black87,
              onTap: () => themeProvider.setTheme(AppThemeMode.light),
            ),
            _ThemePreviewCard(
              index: 1,
              name: 'Dark',
              isSelected: themeProvider.currentTheme == AppThemeMode.dark,
              primaryColor: const Color(0xFF42A5F5),
              surfaceColor: const Color(0xFF1E1E1E),
              textColor: Colors.white70,
              onTap: () => themeProvider.setTheme(AppThemeMode.dark),
            ),
            _ThemePreviewCard(
              index: 2,
              name: 'Business Blue',
              isSelected: themeProvider.currentTheme == AppThemeMode.businessBlue,
              primaryColor: const Color(0xFF1565C0),
              surfaceColor: const Color(0xFFF5F7FA),
              textColor: Colors.black87,
              onTap: () => themeProvider.setTheme(AppThemeMode.businessBlue),
            ),
            _ThemePreviewCard(
              index: 3,
              name: 'Professional Green',
              isSelected: themeProvider.currentTheme == AppThemeMode.professionalGreen,
              primaryColor: const Color(0xFF2E7D32),
              surfaceColor: const Color(0xFFF1F8E9),
              textColor: Colors.black87,
              onTap: () => themeProvider.setTheme(AppThemeMode.professionalGreen),
            ),
          ],
        );
      },
    );
  }
}

class _ThemePreviewCard extends StatelessWidget {
  final int index;
  final String name;
  final bool isSelected;
  final Color primaryColor;
  final Color surfaceColor;
  final Color textColor;
  final VoidCallback onTap;

  const _ThemePreviewCard({
    required this.index,
    required this.name,
    required this.isSelected,
    required this.primaryColor,
    required this.surfaceColor,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: 300.ms,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? primaryColor : Colors.grey.withOpacity(0.3),
              width: isSelected ? 2.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 12, height: 12,
                            decoration: BoxDecoration(color: primaryColor, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 6),
                          Text(name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 13, color: textColor,
                            ),
                          ),
                          const Spacer(),
                          if (isSelected)
                            Icon(Icons.check_circle, color: primaryColor, size: 18),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: List.generate(3, (i) => Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Container(
                            width: 20, height: 8,
                            decoration: BoxDecoration(
                              color: [Colors.red, Colors.blue, Colors.green][i],
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        )),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        height: 4, width: 40,
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                height: 32,
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(isSelected ? 1.0 : 0.7),
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(15)),
                ),
                alignment: Alignment.center,
                child: Text(
                  isSelected ? 'Active' : 'Tap to apply',
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: (index * 80).ms, duration: 300.ms).slideY(begin: 0.1, end: 0);
  }
}
