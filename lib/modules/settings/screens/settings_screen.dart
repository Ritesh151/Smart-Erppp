import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:SmartERP/core/routes/app_routes.dart';
import 'package:SmartERP/modules/auth/providers/auth_provider.dart';
import 'package:SmartERP/modules/settings/providers/settings_provider.dart';
import 'package:SmartERP/modules/settings/services/date_format_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  PackageInfo? _packageInfo;
  final _thresholdController = TextEditingController();

  static const Color _textMuted   = Color(0xFF6B7280);
  static const Color _textLight   = Color(0xFF9CA3AF);
  static const Color _danger      = Color(0xFFEF4444);
  static const Color _surface     = Color(0xFFFFFFFF);
  static const Color _divider     = Color(0xFFE5E7EB);

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  @override
  void dispose() {
    _thresholdController.dispose();
    super.dispose();
  }

  Future<void> _loadPackageInfo() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() => _packageInfo = info);
      }
    } catch (_) {
      // Will use fallback values
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.select<SettingsProvider, SettingsProvider>((p) => p);
    final dateFormatService = context.select<DateFormatService, DateFormatService>((p) => p);
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date Format Section
          _sectionHeader(theme, Icons.calendar_today, 'Date Format'),
          const SizedBox(height: 8),
          _buildDateFormatCard(context, dateFormatService),
          const SizedBox(height: 24),

          // Inventory Settings Section
          _sectionHeader(theme, Icons.inventory, 'Inventory Settings'),
          const SizedBox(height: 8),
          _buildInventorySettingsCard(context, settingsProvider),
          const SizedBox(height: 24),

          // Low Stock Alerts Section
          _sectionHeader(theme, Icons.warning_amber, 'Low Stock Alerts'),
          const SizedBox(height: 8),
          _buildLowStockAlertsCard(context, settingsProvider),
          const SizedBox(height: 24),

          // Labour Settings Section
          _sectionHeader(theme, Icons.people, 'Labour Settings'),
          const SizedBox(height: 8),
          _buildLabourSettingsCard(context, settingsProvider),
          const SizedBox(height: 24),

          // Salary Reminders Section
          _sectionHeader(theme, Icons.notifications_active, 'Salary Reminders'),
          const SizedBox(height: 8),
          _buildSalaryRemindersCard(context, settingsProvider),
          const SizedBox(height: 24),

          // System Information Section
          _sectionHeader(theme, Icons.info_outline, 'System'),
          const SizedBox(height: 8),
          _buildSystemInfoCard(context),
          const SizedBox(height: 24),

          // Account Section
          _sectionHeader(theme, Icons.account_circle, 'Account'),
          const SizedBox(height: 8),
          _buildSignOutCard(context),
        ],
      ),
    );
  }

  Widget _sectionHeader(ThemeData theme, IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildDateFormatCard(BuildContext context, DateFormatService service) {
    final availableFormats = service.getAvailableFormats();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              value: service.currentFormat,
              decoration: const InputDecoration(
                labelText: 'Date Format',
                prefixIcon: Icon(Icons.date_range),
              ),
              items: availableFormats.map((format) {
                return DropdownMenuItem(
                  value: format,
                  child: Text('${service.getFormatDescription(format)} ($format)'),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  service.setFormat(value);
                }
              },
            ),
            const SizedBox(height: 8),
            Text(
              'Preview: ${service.format(DateTime.now())}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: _textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInventorySettingsCard(BuildContext context, SettingsProvider provider) {
    _thresholdController.text = provider.lowStockThreshold.toString();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _thresholdController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Low Stock Threshold',
                prefixIcon: const Icon(Icons.trending_down),
                helperText: 'Products with stock at or below this value are considered low stock',
              ),
              onFieldSubmitted: (value) {
                final threshold = int.tryParse(value);
                if (threshold != null && threshold >= 1 && threshold <= 999999) {
                  provider.updateLowStockThreshold(threshold);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLowStockAlertsCard(BuildContext context, SettingsProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Show Low Stock Alerts'),
                      Text(
                        provider.lowStockAlertsEnabled
                            ? 'Alerts are visible throughout the system'
                            : 'Low stock alerts are suppressed',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: _textLight,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: provider.lowStockAlertsEnabled,
                  onChanged: (value) => provider.toggleLowStockAlerts(value),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabourSettingsCard(BuildContext context, SettingsProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              value: provider.defaultSalaryPaymentMode,
              decoration: const InputDecoration(
                labelText: 'Default Salary Payment Mode',
                prefixIcon: Icon(Icons.payments),
              ),
              items: const [
                DropdownMenuItem(value: 'Cash', child: Text('Cash')),
                DropdownMenuItem(value: 'Bank', child: Text('Bank')),
              ],
              onChanged: (value) {
                if (value != null) {
                  provider.updateDefaultSalaryPaymentMode(value);
                }
              },
            ),
            const SizedBox(height: 8),
            Text(
              'Default mode used when making salary payments',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: _textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSalaryRemindersCard(BuildContext context, SettingsProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Enable Salary Reminders'),
                      Text(
                        provider.salaryReminderEnabled
                            ? 'Salary due reminders are enabled'
                            : 'Salary reminders are disabled',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: _textLight,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: provider.salaryReminderEnabled,
                  onChanged: (value) => provider.toggleSalaryReminder(value),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemInfoCard(BuildContext context) {
    final appName = _packageInfo?.appName ?? 'SmartERP';
    final version = _packageInfo != null
        ? '${_packageInfo!.version}+${_packageInfo!.buildNumber}'
        : '1.0.0+1';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoRow(Icons.business, 'Application Name', appName),
            const Divider(height: 16),
            _infoRow(Icons.info_outline, 'Version', version),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: _textLight),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: _textLight,
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignOutCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _showSignOutDialog(context),
            icon: const Icon(Icons.logout, color: _danger),
            label: const Text(
              'Sign Out',
              style: TextStyle(color: _danger),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: _danger),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showSignOutDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: _danger),
            child: const Text('Sign Out'),
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
}
