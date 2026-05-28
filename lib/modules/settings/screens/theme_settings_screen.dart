import 'package:flutter/material.dart';
import 'package:SmartERP/core/widgets/app_shell.dart';
import 'package:SmartERP/modules/settings/widgets/settings_page_transition.dart';
import 'package:SmartERP/modules/settings/widgets/theme_selector_widget.dart';

class ThemeSettingsScreen extends StatelessWidget {
  const ThemeSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppShell(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: SettingsPageTransition(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Theme Settings',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text('Choose a theme to customize the look and feel of the application.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 24),
              const AnimatedSection(
                title: 'Theme Selection',
                subtitle: '4 available themes',
                icon: Icons.palette_outlined,
                child: ThemeSelectorWidget(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
