import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:smarterp/core/constants/app_constants.dart';
import 'package:smarterp/core/extensions/context_extensions.dart';
import 'package:smarterp/core/extensions/date_extensions.dart';
import 'package:smarterp/core/theme/theme_extensions.dart';
import 'package:smarterp/core/widgets/app_shell.dart';
import 'package:smarterp/core/widgets/app_card.dart';
import 'package:smarterp/core/widgets/app_button.dart';
import 'package:smarterp/core/models/customer_model.dart';
import 'package:smarterp/modules/invoice/providers/customer_provider.dart';

class CustomerDetailScreen extends StatefulWidget {
  final String customerId;

  const CustomerDetailScreen({super.key, required this.customerId});

  @override
  State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<CustomerProvider>();
      final customer = provider.customers.where((c) => c.id == widget.customerId).firstOrNull;
      if (customer != null) {
        provider.selectCustomer(customer);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final theme = context.theme;
    final appTheme = context.appTheme;

    return AppShell(
      child: Consumer<CustomerProvider>(
        builder: (context, provider, _) {
          final customer = provider.selectedCustomer;

          if (customer == null || customer.id.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, customer, provider),
                const SizedBox(height: 24),
                _buildInfoSection(context, customer),
                const SizedBox(height: 16),
                _buildContactSection(context, customer),
                const SizedBox(height: 16),
                _buildAddressSection(context, customer),
                const SizedBox(height: 16),
                _buildTaxSection(context, customer),
                const SizedBox(height: 16),
                _buildMetaSection(context, customer),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, CustomerModel customer, CustomerProvider provider) {
    return Row(
      children: [
        CircleAvatar(
          radius: 32,
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Text(
            customer.name.isNotEmpty ? customer.name[0].toUpperCase() : '?',
            style: TextStyle(
              fontSize: 28,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                customer.name,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: customer.isActive ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  customer.isActive ? 'Active' : 'Inactive',
                  style: TextStyle(
                    fontSize: 11,
                    color: customer.isActive ? Colors.green.shade700 : Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        FilledButton.tonalIcon(
          onPressed: () => context.push('/customers/${customer.id}/edit'),
          icon: const Icon(Icons.edit),
          label: const Text('Edit'),
        ),
      ],
    );
  }

  Widget _buildInfoSection(BuildContext context, CustomerModel customer) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Contact Information', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          if (customer.phone != null && customer.phone!.isNotEmpty)
            _infoRow(Icons.phone_outlined, customer.phone!),
          if (customer.email != null && customer.email!.isNotEmpty)
            _infoRow(Icons.email_outlined, customer.email!),
        ],
      ),
    );
  }

  Widget _buildContactSection(BuildContext context, CustomerModel customer) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Address', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          if (customer.address != null && customer.address!.isNotEmpty)
            _infoRow(Icons.location_on_outlined, customer.address!),
          if (customer.city != null && customer.city!.isNotEmpty || customer.state != null && customer.state!.isNotEmpty)
            _infoRow(Icons.business, [
              if (customer.city != null && customer.city!.isNotEmpty) customer.city,
              if (customer.state != null && customer.state!.isNotEmpty) customer.state,
            ].join(', ')),
          if (customer.pincode != null && customer.pincode!.isNotEmpty)
            _infoRow(Icons.markunread_mailbox_outlined, customer.pincode!),
        ],
      ),
    );
  }

  Widget _buildAddressSection(BuildContext context, CustomerModel customer) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tax Information', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          if (customer.gstNumber != null && customer.gstNumber!.isNotEmpty)
            _infoRow(Icons.receipt_outlined, customer.gstNumber!)
          else
            Text('No GST details provided', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }

  Widget _buildTaxSection(BuildContext context, CustomerModel customer) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Additional Details', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _infoRow(Icons.person_pin, 'ID: ${customer.id.substring(0, 8)}...')),
              if (customer.createdAt != null)
                Expanded(child: _infoRow(Icons.calendar_today, 'Created: ${customer.createdAt.toFormattedDate()}')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetaSection(BuildContext context, CustomerModel customer) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Activity', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          if (customer.updatedAt != null)
            _infoRow(Icons.update, 'Last updated: ${customer.updatedAt.toFormattedDate()}'),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Theme.of(context).colorScheme.onSurfaceVariant),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: Theme.of(context).textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
