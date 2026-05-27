import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:smarterp/core/constants/app_constants.dart';
import 'package:smarterp/core/extensions/context_extensions.dart';
import 'package:smarterp/core/theme/theme_extensions.dart';
import 'package:smarterp/core/widgets/app_shell.dart';
import 'package:smarterp/core/widgets/app_card.dart';
import 'package:smarterp/core/widgets/empty_state_widget.dart';
import 'package:smarterp/core/widgets/search_filter_bar.dart';
import 'package:smarterp/core/models/transport_model.dart';
import 'package:smarterp/core/models/transport_status_model.dart';
import 'package:smarterp/modules/transport/providers/transport_provider.dart';
import 'package:smarterp/modules/transport/widgets/animated_list_item.dart';

class TransportScreen extends StatefulWidget {
  const TransportScreen({super.key});

  @override
  State<TransportScreen> createState() => _TransportScreenState();
}

class _TransportScreenState extends State<TransportScreen> {
  String? _selectedStatusFilter;

  final List<Map<String, dynamic>> _statusOptions = [
    {'label': 'Planned', 'value': 'planned'},
    {'label': 'On The Way', 'value': 'onTheWay'},
    {'label': 'Delivered', 'value': 'delivered'},
    {'label': 'Cancelled', 'value': 'cancelled'},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransportProvider>().loadTransports();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final theme = context.theme;

    return AppShell(
      child: Consumer<TransportProvider>(
        builder: (context, provider, _) {
          final transports = provider.transports;

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, provider),
                const SizedBox(height: 20),
                _buildFilterBar(context, provider),
                const SizedBox(height: 16),
                _buildStatsRow(context, provider),
                const SizedBox(height: 20),
                Expanded(
                  child: provider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : transports.isEmpty
                          ? _buildEmptyState(provider)
                          : _buildTransportList(context, transports, provider),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, TransportProvider provider) {
    final theme = context.theme;
    final colorScheme = context.colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Transport Management',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Track and manage all transport operations.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: () => context.push('/transports/create'),
          icon: const Icon(Icons.add),
          label: const Text('Add Transport'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(AppConstants.defaultBorderRadius),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterBar(BuildContext context, TransportProvider provider) {
    return SearchFilterBar(
      hintText: 'Search by transport number, origin, destination...',
      searchQuery: provider.searchQuery,
      onSearchChanged: (query) => provider.searchTransports(query),
      statusOptions: _statusOptions,
      selectedStatus: _selectedStatusFilter,
      onStatusChanged: (val) {
        setState(() => _selectedStatusFilter = val);
        TransportStatus? status;
        if (val == 'planned') status = TransportStatus.planned;
        if (val == 'onTheWay') status = TransportStatus.onTheWay;
        if (val == 'delivered') status = TransportStatus.delivered;
        if (val == 'cancelled') status = TransportStatus.cancelled;
        provider.filterByStatus(status);
      },
      onClearAll: () {
        setState(() => _selectedStatusFilter = null);
        provider.clearFilters();
      },
    );
  }

  Widget _buildStatsRow(BuildContext context, TransportProvider provider) {
    final theme = context.theme;
    final colorScheme = context.colorScheme;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildStatCard('Total', '${provider.totalTransports}',
              Icons.local_shipping, colorScheme.primary, theme),
          const SizedBox(width: 12),
          _buildStatCard('Planned', '${provider.plannedCount}', Icons.schedule,
              Colors.orange.shade600, theme),
          const SizedBox(width: 12),
          _buildStatCard('On The Way', '${provider.onTheWayCount}',
              Icons.flight_takeoff, Colors.blue.shade600, theme),
          const SizedBox(width: 12),
          _buildStatCard('Delivered', '${provider.deliveredCount}',
              Icons.check_circle, Colors.green.shade600, theme),
          const SizedBox(width: 12),
          _buildStatCard('Cancelled', '${provider.cancelledCount}',
              Icons.cancel, Colors.red.shade600, theme),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color, ThemeData theme) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style:
                      theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
              Text(value,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(TransportProvider provider) {
    final hasFilters =
        provider.searchQuery.isNotEmpty || provider.selectedStatus != null;

    if (hasFilters) {
      return EmptyStateWidget(
        icon: Icons.search_off,
        title: 'No Transports Found',
        message: 'Try adjusting your search or filters.',
        actionLabel: 'Reset Filters',
        onAction: () => provider.clearFilters(),
      );
    }

    return EmptyStateWidget(
      icon: Icons.local_shipping_outlined,
      title: 'No Transports Yet',
      message: 'Create your first transport trip to start tracking deliveries.',
      actionLabel: 'Create Transport',
      onAction: () => context.push('/transports/create'),
    );
  }

  Widget _buildTransportList(
    BuildContext context,
    List<TransportModel> transports,
    TransportProvider provider,
  ) {
    final colorScheme = context.colorScheme;

    return SlidableAutoCloseBehavior(
      child: ListView.builder(
        itemCount: transports.length,
        itemBuilder: (context, index) {
          final transport = transports[index];
          final statusColor = _getStatusColor(transport.status);
          final statusIcon = _getStatusIcon(transport.status);

          return AnimatedListItem(
              index: index,
              child: Card(
                margin: const EdgeInsets.only(bottom: 10),
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppConstants.defaultBorderRadius),
                  side: BorderSide(
                      color: colorScheme.outlineVariant.withOpacity(0.5)),
                ),
                child: ClipRRect(
                  borderRadius:
                      BorderRadius.circular(AppConstants.defaultBorderRadius),
                  child: Slidable(
                    key: ValueKey(transport.id),
                    endActionPane: ActionPane(
                      motion: const DrawerMotion(),
                      children: [
                        if (transport.isActive)
                          SlidableAction(
                            onPressed: (context) => context
                                .push('/transports/${transport.id}/edit'),
                            backgroundColor: Colors.blue.shade600,
                            foregroundColor: Colors.white,
                            icon: Icons.edit,
                            label: 'Edit',
                          ),
                        SlidableAction(
                          onPressed: (context) =>
                              _confirmDelete(context, transport, provider),
                          backgroundColor: colorScheme.error,
                          foregroundColor: Colors.white,
                          icon: Icons.delete,
                          label: 'Delete',
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      leading: Container(
                        height: 48,
                        width: 48,
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(
                              AppConstants.smallBorderRadius),
                        ),
                        child: Icon(statusIcon, color: statusColor),
                      ),
                      title: Text(
                        transport.transportNumber,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          '${transport.origin} \u2192 ${transport.destination}',
                          style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onSurface.withOpacity(0.6)),
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(
                                  AppConstants.smallBorderRadius),
                              border: Border.all(
                                  color: statusColor.withOpacity(0.25),
                                  width: 0.5),
                            ),
                            child: Text(
                              transport.status.displayName.toUpperCase(),
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.chevron_right, size: 16),
                        ],
                      ),
                      onTap: () => context.push('/transports/${transport.id}'),
                    ),
                  ),
                ),
              ));
        },
      ),
    );
  }

  Color _getStatusColor(TransportStatus status) {
    switch (status) {
      case TransportStatus.planned:
        return Colors.orange;
      case TransportStatus.onTheWay:
        return Colors.blue;
      case TransportStatus.delivered:
        return Colors.green;
      case TransportStatus.cancelled:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(TransportStatus status) {
    switch (status) {
      case TransportStatus.planned:
        return Icons.schedule;
      case TransportStatus.onTheWay:
        return Icons.flight_takeoff;
      case TransportStatus.delivered:
        return Icons.check_circle;
      case TransportStatus.cancelled:
        return Icons.cancel;
    }
  }

  void _confirmDelete(BuildContext context, TransportModel transport,
      TransportProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transport?'),
        content: Text(
            'Are you sure you want to permanently delete "${transport.transportNumber}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(
                foregroundColor: context.colorScheme.error),
            onPressed: () async {
              try {
                await provider.deleteTransport(transport.id);
                if (context.mounted) {
                  Navigator.pop(context);
                  context.showSnackBar('Transport deleted successfully');
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                  context.showSnackBar('Failed to delete transport: $e',
                      isError: true);
                }
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
