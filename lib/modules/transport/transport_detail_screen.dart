// lib/Pages/Transport/transport_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/utils/date_helper.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../core/widgets/empty_state_widget.dart';
import '../../core/widgets/loading_widget.dart';
import 'models/transport_screen_model.dart';
import 'providers/transport_screen_provider.dart';

class TransportDetailScreen extends ConsumerStatefulWidget {
  const TransportDetailScreen({
    super.key,
    required this.transportId,
  });

  final String transportId;

  @override
  ConsumerState<TransportDetailScreen> createState() =>
      _TransportDetailScreenState();
}

class _TransportDetailScreenState extends ConsumerState<TransportDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final transportsAsync = ref.watch(transportsStreamProvider);

    return AppScaffold(
      title: 'Shipment Details',
      body: transportsAsync.when(
        loading: () => const LoadingWidget(),
        error: (error, stack) => Center(
          child: Text('Error: $error'),
        ),
        data: (transports) {
          TransportModel? transport;
          for (final t in transports) {
            if (t.transportId == widget.transportId) {
              transport = t;
              break;
            }
          }

          if (transport == null) {
            return const EmptyStateWidget(
              icon: Icons.local_shipping_outlined,
              title: 'Not Found',
              message: 'This shipment record could not be found.',
            );
          }

          return _buildDetailView(context, transport);
        },
      ),
    );
  }

  Widget _buildDetailView(BuildContext context, TransportModel transport) =>
      SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header Card ─────────────────────────────────────────────
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Products',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(color: Colors.grey[600]),
                              ),
                              Text(
                                '${transport.products.length} Product(s)',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                transport.products
                                    .map((p) => p.productName)
                                    .toList()
                                    .join(', '),
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: transport.status.statusColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            transport.status.displayName,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: transport.status.statusColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Quantity: ${transport.totalQuantity.toStringAsFixed(2)} units',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Products Details Section ───────────────────────────────
            _buildSection(
              context,
              'Product Details',
              [
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: transport.products.length,
                  itemBuilder: (ctx, idx) {
                    final product = transport.products[idx];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product.productName,
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelLarge
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      Text(
                                        'HSN: ${product.hsnCode}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelSmall
                                            ?.copyWith(
                                              color: Colors.grey[600],
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '${product.quantity} ${product.unit}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Route Section ────────────────────────────────────────────
            _buildSection(
              context,
              'Shipment Route',
              [
                _buildInfoRow(
                  context,
                  'From',
                  transport.sourceLocation,
                  Icons.location_on_rounded,
                  Colors.blue,
                ),
                const SizedBox(height: 12),
                Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.arrow_downward,
                        color: Colors.grey[400],
                        size: 24,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'In Transit',
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  context,
                  'To',
                  transport.destinationLocation,
                  Icons.location_on_outlined,
                  Colors.green,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Transport Details ────────────────────────────────────────
            _buildSection(
              context,
              'Transport Details',
              [
                _buildInfoRow(
                  context,
                  'Transport Type',
                  transport.transportType.displayName,
                  Icons.local_shipping,
                  Colors.orange,
                ),
                if (transport.vehicleNumber != null) ...[
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    context,
                    'Vehicle Number',
                    transport.vehicleNumber!,
                    Icons.directions_car,
                    Colors.purple,
                  ),
                ],
                if (transport.transportCompany != null) ...[
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    context,
                    'Transport Company',
                    transport.transportCompany!,
                    Icons.business,
                    Colors.indigo,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),

            // ── Timeline Section ────────────────────────────────────────
            _buildSection(
              context,
              'Timeline',
              [
                _buildInfoRow(
                  context,
                  'Transport Date',
                  DateHelper.display(transport.transportDate),
                  Icons.calendar_today,
                  Colors.red,
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  context,
                  'Created',
                  DateHelper.displayDateTime(transport.createdAt),
                  Icons.add_circle_outline,
                  Colors.blue,
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  context,
                  'Last Updated',
                  DateHelper.displayDateTime(transport.updatedAt),
                  Icons.edit,
                  Colors.grey,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Notes Section ───────────────────────────────────────────
            if (transport.notes != null && transport.notes!.isNotEmpty)
              _buildSection(
                context,
                'Notes',
                [
                  Text(
                    transport.notes!,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            if (transport.notes != null && transport.notes!.isNotEmpty)
              const SizedBox(height: 16),

            // ── Status Update Buttons ────────────────────────────────────
            if (transport.status != ExportStatus.delivered &&
                transport.status != ExportStatus.cancelled)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Update Status',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ExportStatus.values
                        .where((s) => s != transport.status)
                        .map((status) =>
                            ElevatedButton(
                              onPressed: () =>
                                  _updateStatus(context, transport.transportId, status),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    status.statusColor.withOpacity(0.2),
                                foregroundColor: status.statusColor,
                              ),
                              child: Text(status.displayName),
                            )).toList(),
                  ),
                  const SizedBox(height: 16),
                ],
              ),

            // ── Action Buttons ──────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Back'),
                  ),
                ),
                const SizedBox(width: 12),
                if (transport.isEditable)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          context.push('/transports/${transport.transportId}/edit'),
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit'),
                    ),
                  ),
                if (transport.isEditable) const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _deleteTransport(context, transport),
                    icon: const Icon(Icons.delete),
                    label: const Text('Delete'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade50,
                      foregroundColor: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );

  Widget _buildSection(
    BuildContext context,
    String title,
    List<Widget> children,
  ) =>
      Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              ...children,
            ],
          ),
        ),
      );

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color iconColor,
  ) =>
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(color: Colors.grey[600]),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      );

  Future<void> _updateStatus(
    BuildContext context,
    String transportId,
    ExportStatus newStatus,
  ) async {
    final result = await ref
        .read(transportNotifierProvider.notifier)
        .updateStatus(transportId, newStatus);

    if (result && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Status updated to ${newStatus.displayName}'),
        ),
      );
    }
  }

  Future<void> _deleteTransport(
    BuildContext context,
    TransportModel transport,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Shipment'),
        content: const Text(
          'Are you sure you want to delete this shipment record? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Color(0xFFEF4444))),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final result = await ref
          .read(transportNotifierProvider.notifier)
          .deleteTransport(transport.transportId);

      if (result && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Shipment record deleted')),
        );
        context.pop();
      }
    }
  }
}
