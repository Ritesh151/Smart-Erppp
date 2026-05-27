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
import 'package:smarterp/core/models/customer_model.dart';
import 'package:smarterp/modules/invoice/providers/customer_provider.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CustomerProvider>().loadCustomers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final theme = context.theme;

    return AppShell(
      child: Consumer<CustomerProvider>(
        builder: (context, provider, _) {
          final customers = provider.customers;

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, provider),
                const SizedBox(height: 20),
                SearchFilterBar(
                  hintText: 'Search customers...',
                  searchQuery: provider.searchQuery,
                  onSearchChanged: (query) => provider.searchCustomers(query),
                  onClearAll: provider.clearSearch,
                ),
                const SizedBox(height: 20),
                if (provider.isLoading)
                  const Expanded(
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (customers.isEmpty)
                  Expanded(
                    child: EmptyStateWidget(
                      icon: Icons.people_outline,
                      title: 'No Customers',
                      message: 'Add your first customer to start creating invoices',
                      actionLabel: 'Add Customer',
                      onAction: () => context.push('/customers/create'),
                    ),
                  )
                else
                  Expanded(child: _buildCustomersList(context, provider, customers)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, CustomerProvider provider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Customer Management',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${provider.totalCustomers} total customers',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        FilledButton.icon(
          onPressed: () => context.push('/customers/create'),
          icon: const Icon(Icons.add),
          label: const Text('Add Customer'),
        ),
      ],
    );
  }

  Widget _buildCustomersList(
    BuildContext context,
    CustomerProvider provider,
    List<CustomerModel> customers,
  ) {
    final appTheme = context.appTheme;

    return ListView.builder(
      itemCount: customers.length,
      itemBuilder: (context, index) {
        final customer = customers[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Slidable(
            endActionPane: ActionPane(
              motion: const ScrollMotion(),
              children: [
                SlidableAction(
                  onPressed: (_) => context.push('/customers/${customer.id}/edit'),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  icon: Icons.edit,
                  label: 'Edit',
                ),
                SlidableAction(
                  onPressed: (_) => _confirmDelete(context, provider, customer),
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Theme.of(context).colorScheme.onError,
                  icon: Icons.delete,
                  label: 'Delete',
                ),
              ],
            ),
            child: AppCard(
              onTap: () => context.push('/customers/${customer.id}'),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  child: Text(
                    customer.name.isNotEmpty ? customer.name[0].toUpperCase() : '?',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  customer.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  [customer.phone, customer.email].where((e) => e != null && e.isNotEmpty).join(' | '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (customer.gstNumber != null && customer.gstNumber!.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'GST',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    if (customer.city != null && customer.city!.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Icon(Icons.location_on_outlined, size: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ],
                    const SizedBox(width: 8),
                    Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, CustomerProvider provider, CustomerModel customer) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Customer'),
        content: Text('Are you sure you want to delete "${customer.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              provider.deleteCustomer(customer.id);
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
