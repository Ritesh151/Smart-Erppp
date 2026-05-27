import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:smarterp/core/constants/app_constants.dart';
import 'package:smarterp/core/extensions/context_extensions.dart';
import 'package:smarterp/core/extensions/date_extensions.dart';
import 'package:smarterp/core/theme/theme_extensions.dart';
import 'package:smarterp/core/widgets/app_shell.dart';
import 'package:smarterp/core/widgets/app_card.dart';
import 'package:smarterp/core/models/transport_model.dart';
import 'package:smarterp/core/models/transport_status_model.dart';
import 'package:smarterp/modules/transport/providers/transport_provider.dart';
import 'package:smarterp/modules/transport/widgets/transport_timeline_widget.dart';

class TransportDetailScreen extends StatefulWidget {
  final String transportId;

  const TransportDetailScreen({super.key, required this.transportId});

  @override
  State<TransportDetailScreen> createState() => _TransportDetailScreenState();
}

class _TransportDetailScreenState extends State<TransportDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransportProvider>().loadTransportDetails(widget.transportId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final theme = context.theme;

    return AppShell(
      child: Consumer<TransportProvider>(
        builder: (context, provider, _) {
          final transport = provider.selectedTransport;

          if (provider.isLoading || transport == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, transport, provider),
                const SizedBox(height: 24),
                _buildRouteInfo(context, transport),
                const SizedBox(height: 16),
                _buildDateInfo(context, transport),
                const SizedBox(height: 16),
                _buildVehicleInfo(context, transport),
                const SizedBox(height: 16),
                _buildTimelineSection(context, transport),
                const SizedBox(height: 16),
                _buildItemsTable(context, provider),
                const SizedBox(height: 16),
                _buildNotes(context, transport),
                const SizedBox(height: 24),
                _buildActions(context, transport, provider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, TransportModel transport, TransportProvider provider) {
    final statusColor = _getStatusColor(transport.status);

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                transport.transportNumber,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
                      border: Border.all(color: statusColor.withOpacity(0.25), width: 0.5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_getStatusIcon(transport.status), size: 14, color: statusColor),
                        const SizedBox(width: 4),
                        Text(
                          transport.status.displayName,
                          style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Created: ${transport.createdAt.toFormattedDate()}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRouteInfo(BuildContext context, TransportModel transport) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Route Details', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _infoRow(Icons.trip_origin, transport.origin, 'Origin')),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Icon(Icons.arrow_forward, color: Theme.of(context).colorScheme.primary),
              ),
              Expanded(child: _infoRow(Icons.location_on, transport.destination, 'Destination')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateInfo(BuildContext context, TransportModel transport) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Dates', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _infoRow(Icons.flight_takeoff, transport.departureDate.toFormattedDate(), 'Departure')),
              const SizedBox(width: 24),
              if (transport.estimatedArrival != null)
                Expanded(child: _infoRow(Icons.event, transport.estimatedArrival!.toFormattedDate(), 'Estimated Arrival')),
              if (transport.actualArrival != null) ...[
                const SizedBox(width: 24),
                Expanded(child: _infoRow(Icons.check_circle, transport.actualArrival!.toFormattedDate(), 'Actual Arrival')),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleInfo(BuildContext context, TransportModel transport) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Vehicle & Driver', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          _infoRow(Icons.local_shipping, transport.vehicleNumber, 'Vehicle'),
          if (transport.driverName != null && transport.driverName!.isNotEmpty)
            _infoRow(Icons.person, transport.driverName!, 'Driver'),
          if (transport.driverPhone != null && transport.driverPhone!.isNotEmpty)
            _infoRow(Icons.phone, transport.driverPhone!, 'Phone'),
        ],
      ),
    );
  }

  Widget _buildTimelineSection(BuildContext context, TransportModel transport) {
    return AppCard(
      child: TransportTimelineWidget(transport: transport),
    );
  }

  Widget _buildItemsTable(BuildContext context, TransportProvider provider) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Items', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          if (provider.selectedTransportItems.isEmpty)
            const Text('No items found')
          else
            Table(
              columnWidths: const {
                0: FlexColumnWidth(3),
                1: FlexColumnWidth(1),
                2: FlexColumnWidth(1),
                3: FlexColumnWidth(1.5),
              },
              children: [
                TableRow(
                  decoration: BoxDecoration(
                    border: Border(bottom: Border.all(color: Theme.of(context).dividerColor)),
                  ),
                  children: const [
                    _TableHeader('Item'),
                    _TableHeader('Qty'),
                    _TableHeader('Unit'),
                    _TableHeader('Delivered'),
                  ],
                ),
                ...provider.selectedTransportItems.map((item) {
                  final remaining = item.remainingToDeliver;
                  return TableRow(
                    children: [
                      _TableCell(item.productName),
                      _TableCell(item.quantity.toString()),
                      _TableCell(item.unit),
                      _TableCell(remaining > 0 ? '${remaining} pending' : 'All delivered'),
                    ],
                  );
                }),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildNotes(BuildContext context, TransportModel transport) {
    if (transport.notes == null || transport.notes!.isEmpty) {
      return const SizedBox.shrink();
    }

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Notes', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(transport.notes!, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context, TransportModel transport, TransportProvider provider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (transport.isPlanned || transport.isOnTheWay)
          FilledButton.icon(
            onPressed: transport.isPlanned
                ? () => _advanceStatus(context, transport, provider)
                : null,
            icon: Icon(
              transport.isPlanned ? Icons.flight_takeoff : Icons.check_circle,
              size: 18,
            ),
            label: Text(transport.isPlanned ? 'Mark On The Way' : 'Mark Delivered'),
          ),
        if (transport.isPlanned) ...[
          const SizedBox(width: 12),
          FilledButton.tonalIcon(
            onPressed: () => _cancelTransport(context, transport, provider),
            icon: const Icon(Icons.cancel, size: 18),
            label: const Text('Cancel Transport'),
          ),
        ],
        if (transport.isOnTheWay) ...[
          const SizedBox(width: 12),
          FilledButton.icon(
            onPressed: () => _advanceDelivery(context, transport, provider),
            icon: const Icon(Icons.check_circle, size: 18),
            label: const Text('Mark Delivered'),
          ),
          const SizedBox(width: 12),
          OutlinedButton.icon(
            onPressed: () => _cancelTransport(context, transport, provider),
            icon: const Icon(Icons.cancel, size: 18),
            label: const Text('Cancel'),
          ),
        ],
        if (transport.isDelivered || transport.isCancelled) ...[
          const SizedBox(width: 12),
          OutlinedButton.icon(
            onPressed: () => _confirmDelete(context, transport, provider),
            icon: const Icon(Icons.delete_outline, size: 18),
            label: const Text('Delete'),
          ),
        ],
      ],
    );
  }

  Color _getStatusColor(TransportStatus status) {
    switch (status) {
      case TransportStatus.planned: return Colors.orange;
      case TransportStatus.onTheWay: return Colors.blue;
      case TransportStatus.delivered: return Colors.green;
      case TransportStatus.cancelled: return Colors.red;
    }
  }

  IconData _getStatusIcon(TransportStatus status) {
    switch (status) {
      case TransportStatus.planned: return Icons.schedule;
      case TransportStatus.onTheWay: return Icons.flight_takeoff;
      case TransportStatus.delivered: return Icons.check_circle;
      case TransportStatus.cancelled: return Icons.cancel;
    }
  }

  Widget _infoRow(IconData icon, String text, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 11, color: Colors.grey)),
              Text(text, style: const TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }

  void _advanceStatus(BuildContext context, TransportModel transport, TransportProvider provider) async {
    try {
      await provider.advanceStatus(transport.id);
      if (context.mounted) {
        context.showSnackBar('Status updated to ${transport.status.displayName}');
      }
    } catch (e) {
      if (context.mounted) {
        context.showSnackBar('Failed to update status: $e', isError: true);
      }
    }
  }

  void _advanceDelivery(BuildContext context, TransportModel transport, TransportProvider provider) async {
    try {
      await provider.advanceStatus(transport.id);
      if (context.mounted) {
        context.showSnackBar('Transport marked as delivered');
      }
    } catch (e) {
      if (context.mounted) {
        context.showSnackBar('Failed to mark delivery: $e', isError: true);
      }
    }
  }

  void _cancelTransport(BuildContext context, TransportModel transport, TransportProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Transport?'),
        content: const Text('This will cancel the transport and restore product stock. This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Go Back')),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: context.colorScheme.error),
            onPressed: () async {
              try {
                await provider.cancelTransport(transport.id);
                if (ctx.mounted) Navigator.pop(ctx);
                if (context.mounted) {
                  context.showSnackBar('Transport cancelled');
                }
              } catch (e) {
                if (ctx.mounted) Navigator.pop(ctx);
                if (context.mounted) {
                  context.showSnackBar('Failed to cancel: $e', isError: true);
                }
              }
            },
            child: const Text('Cancel Transport'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, TransportModel transport, TransportProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Transport?'),
        content: const Text('Are you sure you want to permanently delete this transport record?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: context.colorScheme.error),
            onPressed: () async {
              try {
                await provider.deleteTransport(transport.id);
                if (ctx.mounted) Navigator.pop(ctx);
                if (context.mounted) {
                  context.showSnackBar('Transport deleted');
                  GoRouter.of(context).pop();
                }
              } catch (e) {
                if (ctx.mounted) Navigator.pop(ctx);
                if (context.mounted) {
                  context.showSnackBar('Failed to delete: $e', isError: true);
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

class _TableHeader extends StatelessWidget {
  final String text;
  const _TableHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(text, style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurfaceVariant)),
    );
  }
}

class _TableCell extends StatelessWidget {
  final String text;
  const _TableCell(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
    );
  }
}
