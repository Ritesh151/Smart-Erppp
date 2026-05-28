import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:SmartERP/core/extensions/context_extensions.dart';
import 'package:SmartERP/core/models/notification_model.dart';
import 'package:SmartERP/core/widgets/app_shell.dart';
import 'package:SmartERP/core/widgets/empty_state_widget.dart';
import 'package:SmartERP/modules/settings/providers/notification_provider.dart';
import 'package:SmartERP/modules/settings/widgets/notification_card_widget.dart';
import 'package:SmartERP/modules/settings/widgets/settings_page_transition.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final _searchController = TextEditingController();
  bool _showSearch = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().loadNotifications();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppShell(
      child: SettingsPageTransition(
        child: Column(
          children: [
            _buildHeader(context),
            if (_showSearch) _buildSearchBar(context),
            _buildFilterChips(context),
            Expanded(
              child: Consumer<NotificationProvider>(
                builder: (context, provider, _) {
                  if (provider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final notifications = provider.filteredNotifications;

                  if (notifications.isEmpty) {
                    return EmptyStateWidget(
                      icon: Icons.notifications_none,
                      title: 'No Notifications',
                      message: provider.searchQuery.isNotEmpty
                          ? 'No notifications match your search'
                          : 'You\'re all caught up!',
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: provider.refresh,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: notifications.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Text('${notifications.length} notification${notifications.length != 1 ? 's' : ''}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: theme.colorScheme.onSurface.withOpacity(0.4),
                                  ),
                                ),
                                const Spacer(),
                                if (provider.unreadCount > 0)
                                  TextButton.icon(
                                    onPressed: () => provider.markAllAsRead(),
                                    icon: const Icon(Icons.done_all, size: 14),
                                    label: const Text('Mark all read', style: TextStyle(fontSize: 12)),
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                      minimumSize: Size.zero,
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                  ),
                              ],
                            ),
                          );
                        }

                        final notification = notifications[index - 1];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: NotificationCardWidget(
                            notification: notification,
                            onTap: () => provider.markAsRead(notification.id),
                            onDelete: () => _confirmDelete(context, provider, notification),
                          ).animate().fadeIn(
                            delay: ((index - 1) * 40).ms,
                            duration: 250.ms,
                          ).slideX(begin: 0.05, end: 0),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('Notifications',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              Consumer<NotificationProvider>(
                builder: (context, provider, _) => Row(
                  children: [
                    if (provider.unreadCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text('${provider.unreadCount} unread',
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                      ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: Icon(_showSearch ? Icons.close : Icons.search, size: 20),
                      onPressed: () => setState(() {
                        _showSearch = !_showSearch;
                        if (!_showSearch) {
                          _searchController.clear();
                          context.read<NotificationProvider>().search('');
                        }
                      }),
                    ),
                    if (provider.notifications.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.delete_sweep, size: 20),
                        onPressed: () => _confirmDeleteAll(context, provider),
                        color: theme.colorScheme.error,
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text('Stay updated with system alerts and reminders.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
      child: TextField(
        controller: _searchController,
        autofocus: true,
        decoration: InputDecoration(
          hintText: 'Search notifications...',
          prefixIcon: const Icon(Icons.search, size: 18),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 16),
                  onPressed: () {
                    _searchController.clear();
                    context.read<NotificationProvider>().search('');
                  },
                )
              : null,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onChanged: (v) => context.read<NotificationProvider>().search(v),
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (context, provider, _) {
        final categories = NotificationCategory.values;
        return Padding(
          padding: const EdgeInsets.fromLTRB(0, 12, 0, 8),
          child: AnimatedFilterChipRow(
            chips: [
              _filterChip(context, 'All', null,
                  provider.selectedCategory == null, provider),
              ...categories.map((cat) => _filterChip(
                    context,
                    cat.name,
                    cat,
                    provider.selectedCategory == cat,
                    provider,
                  )),
            ],
          ),
        );
      },
    );
  }

  Widget _filterChip(
    BuildContext context,
    String label,
    NotificationCategory? category,
    bool isSelected,
    NotificationProvider provider,
  ) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label, style: TextStyle(fontSize: 11, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal)),
        selected: isSelected,
        onSelected: (_) => provider.filterByCategory(category),
        visualDensity: VisualDensity.compact,
        padding: const EdgeInsets.symmetric(horizontal: 4),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, NotificationProvider provider, NotificationModel notification) async {
    final confirmed = await context.showAppDialog<bool>(
      AlertDialog(
        title: const Text('Delete Notification'),
        content: Text('Delete "${notification.title}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete'), style: TextButton.styleFrom(foregroundColor: Colors.red)),
        ],
      ),
    );
    if (confirmed == true) {
      provider.deleteNotification(notification.id);
    }
  }

  Future<void> _confirmDeleteAll(BuildContext context, NotificationProvider provider) async {
    final confirmed = await context.showAppDialog<bool>(
      AlertDialog(
        title: const Text('Delete All'),
        content: const Text('Delete all notifications?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete All'), style: TextButton.styleFrom(foregroundColor: Colors.red)),
        ],
      ),
    );
    if (confirmed == true) {
      provider.deleteAll();
    }
  }
}
