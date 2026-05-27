import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smarterp/core/constants/storage_keys.dart';
import 'package:smarterp/core/extensions/context_extensions.dart';
import 'package:smarterp/core/storage/preferences_service.dart';
import 'package:smarterp/core/theme/app_theme.dart';
import 'package:smarterp/core/widgets/app_shell.dart';
import 'package:smarterp/modules/settings/providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Appearance',
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildThemeSelector(context),
            const SizedBox(height: 32),
            Text(
              'About',
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildAboutSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeSelector(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Theme',
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _buildThemeOption(
              context,
              'Light Theme',
              AppThemeMode.light,
              themeProvider.currentTheme == AppThemeMode.light,
              () => themeProvider.setTheme(AppThemeMode.light),
            ),
            _buildThemeOption(
              context,
              'Dark Theme',
              AppThemeMode.dark,
              themeProvider.currentTheme == AppThemeMode.dark,
              () => themeProvider.setTheme(AppThemeMode.dark),
            ),
            _buildThemeOption(
              context,
              'Business Blue',
              AppThemeMode.businessBlue,
              themeProvider.currentTheme == AppThemeMode.businessBlue,
              () => themeProvider.setTheme(AppThemeMode.businessBlue),
            ),
            _buildThemeOption(
              context,
              'Professional Green',
              AppThemeMode.professionalGreen,
              themeProvider.currentTheme == AppThemeMode.professionalGreen,
              () => themeProvider.setTheme(AppThemeMode.professionalGreen),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    String title,
    AppThemeMode mode,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return RadioListTile<AppThemeMode>(
      title: Text(title),
      value: mode,
      groupValue: isSelected ? mode : null,
      onChanged: (_) => onTap(),
      activeColor: context.colorScheme.primary,
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: const Icon(Icons.business),
              title: const Text('SmartERP'),
              subtitle: const Text('Version 1.0.0'),
              contentPadding: EdgeInsets.zero,
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('About'),
              subtitle: const Text('Enterprise Resource Planning System'),
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }
}
