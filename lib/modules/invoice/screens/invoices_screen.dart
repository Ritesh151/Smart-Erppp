import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:smarterp/core/constants/app_constants.dart';
import 'package:smarterp/core/extensions/context_extensions.dart';
import 'package:smarterp/core/extensions/date_extensions.dart';
import 'package:smarterp/core/theme/theme_extensions.dart';
import 'package:smarterp/core/widgets/app_shell.dart';
import 'package:smarterp/core/widgets/app_card.dart';
import 'package:smarterp/core/widgets/empty_state_widget.dart';
import 'package:smarterp/core/widgets/search_filter_bar.dart';
import 'package:smarterp/core/widgets/status_badge.dart';
import 'package:smarterp/core/models/invoice_model.dart';
import 'package:smarterp/modules/invoice/providers/invoice_provider.dart';

class InvoicesScreen extends StatefulWidget {
  const InvoicesScreen({super.key});

  @override
  State<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends State<InvoicesScreen> {
  final List<Map<String, dynamic>> _statusOptions = [
    {'label': 'All', 'value': null},
    {'label': 'Draft', 'value': InvoiceStatus.draft},
    {'label': 'Sent', 'value': InvoiceStatus.sent},
    {'label': 'Paid', 'value': InvoiceStatus.paid},
    {'label': 'Partially Paid', 'value': InvoiceStatus.partiallyPaid},
    {'label': 'Overdue', 'value': InvoiceStatus.overdue},
    {'label': 'Cancelled', 'value': InvoiceStatus.cancelled},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InvoiceProvider>().loadInvoices();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      child: Consumer<InvoiceProvider>(
        builder: (context, provider, _) {
          final invoices = provider.invoices;

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, provider),
                const SizedBox(height: 20),
                _buildStatsRow(context, provider),
                const SizedBox(height: 20),
                SearchFilterBar(
                  hintText: 'Search invoices...',
                  searchQuery: provider.searchQuery,
                  onSearchChanged: (query) => provider.searchInvoices(query),
                  onClearAll: () {
                    provider.clearSearch();
                    provider.clearFilters();
                  },
                  statusOptions: _statusOptions,
                  selectedStatus: provider.selectedStatus?.name,
                  onStatusChanged: (value) {
                    final status = _statusOptions.firstWhere(
                      (o) => o['label'] == value,
                      orElse: () => {'value': null},
                    )['value'] as InvoiceStatus?;
                    provider.filterByStatus(status);
                  },
                ),
                const SizedBox(height: 20),
                if (provider.isLoading)
                  const Expanded(
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (invoices.isEmpty)
                  Expanded(
                    child: EmptyStateWidget(
                      icon: Icons.receipt_long,
                      title: provider.selectedStatus != null
                          ? 'No ${provider.selectedStatus!.name} Invoices'
                          : 'No Invoices',
                      message: 'Create your first invoice to get started',
                      actionLabel: 'Create Invoice',
                      onAction: () => context.push('/invoices/create'),
                    ),
                  )
                else
                  Expanded(child: _buildInvoicesList(context, provider, invoices)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, InvoiceProvider provider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Invoice Management',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${provider.totalInvoices} total invoices',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        FilledButton.icon(
          onPressed: () => context.push('/invoices/create'),
          icon: const Icon(Icons.add),
          label: const Text('Create Invoice'),
        ),
      ],
    );
  }

  Widget _buildStatsRow(BuildContext context, InvoiceProvider provider) {
    final colorScheme = context.colorScheme;

    return Row(
      children: [
        _statCard(context, 'Draft', provider.draftCount, Colors.grey),
        const SizedBox(width: 12),
        _statCard(context, 'Sent', provider.sentCount, colorScheme.primary),
        const SizedBox(width: 12),
        _statCard(context, 'Paid', provider.paidCount, Colors.green),
        const SizedBox(width: 12),
        _statCard(context, 'Overdue', provider.overdueCount, Colors.red),
      ],
    );
  }

  Widget _statCard(BuildContext context, String label, int count, Color color) {
    return Expanded(
      child: AppCard(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Column(
          children: [
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoicesList(
    BuildContext context,
    InvoiceProvider provider,
    List<InvoiceModel> invoices,
  ) {
    return ListView.builder(
      itemCount: invoices.length,
      itemBuilder: (context, index) {
        final invoice = invoices[index];
        final statusColor = _getStatusColor(invoice.status);
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Slidable(
            endActionPane: ActionPane(
              motion: const ScrollMotion(),
              children: [
                if (invoice.status == InvoiceStatus.draft)
                  SlidableAction(
                    onPressed: (_) => provider.markAsSent(invoice.id),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    icon: Icons.send,
                    label: 'Send',
                  ),
                SlidableAction(
                  onPressed: (_) => _confirmDelete(context, provider, invoice),
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Theme.of(context).colorScheme.onError,
                  icon: Icons.delete,
                  label: 'Delete',
                ),
              ],
            ),
            child: AppCard(
              onTap: () => context.push('/invoices/${invoice.id}'),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: statusColor.withOpacity(0.1),
                  child: Icon(Icons.receipt, color: statusColor, size: 20),
                ),
                title: Row(
                  children: [
                    Text(
                      invoice.invoiceNumber,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 8),
                    StatusBadge(
                      label: invoice.status.name,
                      color: statusColor,
                    ),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      invoice.customerName,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${invoice.invoiceDate.toFormattedDate()} | Due: ${invoice.dueDate.toFormattedDate()}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹${invoice.totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (invoice.paidAmount > 0)
                      Text(
                        'Paid: ₹${invoice.paidAmount.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.green.shade700,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getStatusColor(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.draft:
        return Colors.grey;
      case InvoiceStatus.sent:
        return Colors.blue;
      case InvoiceStatus.paid:
        return Colors.green;
      case InvoiceStatus.partiallyPaid:
        return Colors.orange;
      case InvoiceStatus.overdue:
        return Colors.red;
      case InvoiceStatus.cancelled:
        return Colors.grey.shade700;
    }
  }

  void _confirmDelete(BuildContext context, InvoiceProvider provider, InvoiceModel invoice) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Invoice'),
        content: Text('Delete invoice ${invoice.invoiceNumber}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              provider.deleteInvoice(invoice.id);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
