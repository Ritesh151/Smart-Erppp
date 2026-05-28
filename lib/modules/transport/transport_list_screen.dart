// lib/Pages/Transport/transport_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:SmartERP/modules/transport/models/transport_screen_model.dart';
import 'package:SmartERP/modules/transport/providers/transport_screen_provider.dart';
import 'package:SmartERP/core/utils/date_helper.dart';
import 'package:SmartERP/core/widgets/app_scaffold.dart';
import 'package:SmartERP/core/widgets/loading_widget.dart';
import 'package:SmartERP/core/widgets/empty_state_widget.dart';

class TransportListScreen extends ConsumerStatefulWidget {
  const TransportListScreen({super.key});

  @override
  ConsumerState<TransportListScreen> createState() =>
      _TransportListScreenState();
}

class _TransportListScreenState extends ConsumerState<TransportListScreen> {
  DateTimeRange? _filterRange;
  final _productController = TextEditingController();
  final _destinationController = TextEditingController();
  ExportStatus? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _filterRange = null;
  }

  @override
  void dispose() {
    _productController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    ref.read(transportDateFilterProvider.notifier).state = _filterRange;
    ref.read(transportProductFilterProvider.notifier).state =
        _productController.text;
    ref.read(transportDestinationFilterProvider.notifier).state =
        _destinationController.text;
    ref.read(transportStatusFilterProvider.notifier).state = _selectedStatus;
  }

  void _clearFilters() {
    setState(() {
      _filterRange = null;
      _productController.clear();
      _destinationController.clear();
      _selectedStatus = null;
    });
    ref.read(transportDateFilterProvider.notifier).state = _filterRange;
    ref.read(transportProductFilterProvider.notifier).state = '';
    ref.read(transportDestinationFilterProvider.notifier).state = '';
    ref.read(transportStatusFilterProvider.notifier).state = null;
  }

  @override
  Widget build(BuildContext context) {
    final transportsAsync = ref.watch(transportsStreamProvider);
    final filtered = ref.watch(filteredTransportsProvider);

    if (transportsAsync.isLoading) {
      return const AppScaffold(
        title: 'Transport & Shipment',
        body: LoadingWidget(),
      );
    }

    return AppScaffold(
      title: 'Transport & Shipment',
      showBackButton: false,
      body: Column(
        children: [
          // ── Filter Section ────────────────────────────────────────────
          _buildFilterSection(context),

          // ── Stats Section ────────────────────────────────────────────
          _buildStatsSection(filtered),

          // ── Transport List ───────────────────────────────────────────
          Expanded(
            child: filtered.isEmpty
                ? const EmptyStateWidget(
                    icon: Icons.local_shipping_outlined,
                    title: 'No Shipments',
                    message: 'No transport records found.',
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 4),
                    itemBuilder: (ctx, i) =>
                        _TransportCard(transport: filtered[i]),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/transports/add'),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilterSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filters',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              TextButton.icon(
                onPressed: _clearFilters,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Reset'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Date Range
          _buildDatePickerRow(context),
          const SizedBox(height: 8),
          // Product Search
          TextField(
            controller: _productController,
            decoration: InputDecoration(
              labelText: 'Search by Product',
              prefixIcon: const Icon(Icons.search, size: 20),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
            ),
            onChanged: (_) => _applyFilters(),
          ),
          const SizedBox(height: 8),
          // Destination Search
          TextField(
            controller: _destinationController,
            decoration: InputDecoration(
              labelText: 'Search by Destination',
              prefixIcon: const Icon(Icons.location_on, size: 20),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
            ),
            onChanged: (_) => _applyFilters(),
          ),
          const SizedBox(height: 8),
          // Status Filter
          DropdownButtonFormField<ExportStatus?>(
            value: _selectedStatus,
            decoration: InputDecoration(
              labelText: 'Filter by Status',
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
            ),
            items: [
              const DropdownMenuItem(
                value: null,
                child: Text('All Status'),
              ),
              ...ExportStatus.values.map(
                (status) => DropdownMenuItem(
                  value: status,
                  child: Text(status.displayName),
                ),
              ),
            ],
            onChanged: (value) {
              setState(() => _selectedStatus = value);
              _applyFilters();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDatePickerRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () async {
              final range = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2020),
                lastDate: DateTime.now().add(const Duration(days: 365)),
                initialDateRange: _filterRange ?? DateHelper.currentMonth(),
              );
              if (range != null) {
                setState(() => _filterRange = range);
                _applyFilters();
              }
            },
            icon: const Icon(Icons.date_range, size: 18),
            label: Text(
              _filterRange == null
                  ? 'All dates'
                  : '${_filterRange!.start.day}/${_filterRange!.start.month} - ${_filterRange!.end.day}/${_filterRange!.end.month}',
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ),
        const SizedBox(width: 8),
        OutlinedButton(
          onPressed: _filterRange == null
              ? null
              : () {
                  setState(() => _filterRange = null);
                  _applyFilters();
                },
          child: const Text('Clear', style: TextStyle(fontSize: 12)),
        ),
      ],
    );
  }

  Widget _buildStatsSection(List<TransportModel> transports) {
    final planned =
        transports.where((t) => t.status == ExportStatus.planned).length;
    final inTransit =
        transports.where((t) => t.status == ExportStatus.inTransit).length;
    final delivered =
        transports.where((t) => t.status == ExportStatus.delivered).length;
    final totalQuantity = transports.fold<double>(0, (sum, t) => sum + t.totalQuantity);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          _StatPill(label: 'Planned', value: planned.toString(), color: Colors.orange),
          const SizedBox(width: 8),
          _StatPill(label: 'In Transit', value: inTransit.toString(), color: Colors.blue),
          const SizedBox(width: 8),
          _StatPill(label: 'Delivered', value: delivered.toString(), color: Colors.green),
          const SizedBox(width: 8),
          _StatPill(label: 'Total Qty', value: totalQuantity.toStringAsFixed(0), color: Colors.purple),
        ],
      ),
    );
  }
}

class _TransportCard extends ConsumerWidget {
  final TransportModel transport;

  const _TransportCard({required this.transport});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final productNames = transport.products
        .map((p) => p.productName)
        .toList()
        .join(', ');

    return Card(
      child: InkWell(
        onTap: () => context.push('/transports/${transport.transportId}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Products & Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${transport.products.length} Product(s)',
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          productNames,
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(color: Colors.grey[600]),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Qty: ${transport.totalQuantity.toStringAsFixed(1)} units',
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: transport.status.statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      transport.status.displayName,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: transport.status.statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Route info
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Transport',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                        Text(
                          transport.transportName,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(fontWeight: FontWeight.w500),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_rounded,
                      size: 16, color: Colors.grey[400]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Destination',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                        Text(
                          transport.destinationLocation,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(fontWeight: FontWeight.w500),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Footer: Date & Transport Type
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.calendar_today,
                          size: 14, color: Colors.grey[500]),
                      const SizedBox(width: 4),
                      Text(
                        DateHelper.display(transport.transportDate),
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.local_shipping,
                          size: 14, color: Colors.grey[500]),
                      const SizedBox(width: 4),
                      Text(
                        transport.transportType.displayName,
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(color: Colors.grey[600]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () =>
                        context.push('/transports/${transport.transportId}/edit'),
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Edit', style: TextStyle(fontSize: 12)),
                  ),
                  const SizedBox(width: 4),
                  PopupMenuButton<ExportStatus>(
                    onSelected: (status) async {
                      final result = await ref
                          .read(transportNotifierProvider.notifier)
                          .updateStatus(transport.transportId, status);
                      if (result && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Status updated successfully'),
                          ),
                        );
                      }
                    },
                    itemBuilder: (BuildContext context) {
                      return ExportStatus.values
                          .where((s) => s != transport.status)
                          .map((status) {
                        return PopupMenuItem<ExportStatus>(
                          value: status,
                          child: Text(status.displayName),
                        );
                      }).toList();
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(Icons.more_vert, size: 18),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatPill({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
