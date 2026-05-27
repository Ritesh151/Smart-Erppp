import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:smarterp/core/extensions/context_extensions.dart';
import 'package:smarterp/core/widgets/app_shell.dart';
import 'package:smarterp/core/widgets/app_card.dart';
import 'package:smarterp/core/widgets/empty_state_widget.dart';
import 'package:smarterp/core/models/transport_item_model.dart';
import 'package:smarterp/modules/transport/providers/transport_provider.dart';
import 'package:smarterp/modules/products/providers/product_provider.dart';

class TransportFormScreen extends StatefulWidget {
  const TransportFormScreen({super.key});

  @override
  State<TransportFormScreen> createState() => _TransportFormScreenState();
}

class _TransportFormScreenState extends State<TransportFormScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<TransportProvider>();
      provider.resetEditingState();

      final productProvider = context.read<ProductProvider>();
      if (productProvider.products.isEmpty) {
        productProvider.loadProducts();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return AppShell(
      child: Consumer<TransportProvider>(
        builder: (context, provider, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'New Transport',
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Fill in the transport details below',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildRouteSection(context, provider),
                  const SizedBox(height: 16),
                  _buildDateSection(context, provider),
                  const SizedBox(height: 16),
                  _buildVehicleSection(context, provider),
                  const SizedBox(height: 16),
                  _buildItemsSection(context, provider),
                  const SizedBox(height: 16),
                  _buildNotesSection(context, provider),
                  const SizedBox(height: 24),
                  _buildActions(context, provider),
                  if (provider.errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              provider.errorMessage!,
                              style: TextStyle(color: Theme.of(context).colorScheme.error),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRouteSection(BuildContext context, TransportProvider provider) {
    final colorScheme = context.colorScheme;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.route, size: 18, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text('Route Details', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Origin *',
              hintText: 'Enter departure location',
              prefixIcon: Icon(Icons.trip_origin),
              border: OutlineInputBorder(),
            ),
            initialValue: provider.editingOrigin,
            onChanged: (v) => provider.setEditingOrigin(v),
            validator: (v) => v == null || v.trim().isEmpty ? 'Origin is required' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Destination *',
              hintText: 'Enter arrival location',
              prefixIcon: Icon(Icons.location_on),
              border: OutlineInputBorder(),
            ),
            initialValue: provider.editingDestination,
            onChanged: (v) => provider.setEditingDestination(v),
            validator: (v) => v == null || v.trim().isEmpty ? 'Destination is required' : null,
          ),
        ],
      ),
    );
  }

  Widget _buildDateSection(BuildContext context, TransportProvider provider) {
    final colorScheme = context.colorScheme;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_today, size: 18, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text('Dates', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _datePickerField(
                context: context,
                label: 'Departure Date *',
                value: provider.editingDepartureDate,
                onPicked: (d) => provider.setEditingDepartureDate(d),
              )),
              const SizedBox(width: 16),
              Expanded(child: _datePickerField(
                context: context,
                label: 'Estimated Arrival',
                value: provider.editingEstimatedArrival ?? provider.editingDepartureDate.add(const Duration(days: 1)),
                onPicked: (d) => provider.setEditingEstimatedArrival(d),
              )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _datePickerField({
    required BuildContext context,
    required String label,
    required DateTime value,
    required ValueChanged<DateTime> onPicked,
  }) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: value,
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
        );
        if (picked != null) onPicked(picked);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.calendar_today),
          border: const OutlineInputBorder(),
        ),
        child: Text(
          '${value.day}/${value.month}/${value.year}',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }

  Widget _buildVehicleSection(BuildContext context, TransportProvider provider) {
    final colorScheme = context.colorScheme;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.local_shipping, size: 18, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text('Vehicle & Driver', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Vehicle Number *',
                    hintText: 'e.g. MH-12-AB-1234',
                    prefixIcon: Icon(Icons.local_shipping),
                    border: OutlineInputBorder(),
                  ),
                  initialValue: provider.editingVehicleNumber,
                  onChanged: (v) => provider.setEditingVehicleNumber(v),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Vehicle number is required' : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Vehicle ID',
                    hintText: 'Internal vehicle ID',
                    border: OutlineInputBorder(),
                  ),
                  initialValue: provider.editingVehicleId,
                  onChanged: (v) => provider.setEditingVehicleId(v),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Driver Name',
                    hintText: 'Enter driver name',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                  initialValue: provider.editingDriverName,
                  onChanged: (v) => provider.setEditingDriverName(v),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Driver Phone',
                    hintText: 'Enter phone number',
                    prefixIcon: Icon(Icons.phone),
                    border: OutlineInputBorder(),
                  ),
                  initialValue: provider.editingDriverPhone,
                  onChanged: (v) => provider.setEditingDriverPhone(v),
                  keyboardType: TextInputType.phone,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItemsSection(BuildContext context, TransportProvider provider) {
    final colorScheme = context.colorScheme;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.inventory_2, size: 18, color: colorScheme.primary),
                  const SizedBox(width: 8),
                  Text('Items', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                ],
              ),
              FilledButton.tonalIcon(
                onPressed: () => _showAddItemDialog(context, provider),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Item'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (provider.editingItems.isEmpty)
            const EmptyStateWidget(
              icon: Icons.inventory_2_outlined,
              title: 'No Items',
              message: 'Add products to this transport',
            )
          else
            ...provider.editingItems.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return _buildItemRow(context, provider, index, item);
            }),
        ],
      ),
    );
  }

  Widget _buildItemRow(BuildContext context, TransportProvider provider, int index, TransportItemModel item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(item.productName, style: const TextStyle(fontWeight: FontWeight.w600)),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () => provider.removeItem(index),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: item.quantity.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Quantity *',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (v) {
                      final qty = double.tryParse(v) ?? 0;
                      provider.editingItems[index] = item.copyWith(quantity: qty);
                      provider.notifyListeners();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 100,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Unit',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    child: Text(
                      item.unit,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 100,
                  child: TextFormField(
                    initialValue: item.notes ?? '',
                    decoration: const InputDecoration(
                      labelText: 'Notes',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: (v) {
                      provider.editingItems[index] = item.copyWith(notes: v.isEmpty ? null : v);
                      provider.notifyListeners();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddItemDialog(BuildContext context, TransportProvider provider) {
    final productProvider = context.read<ProductProvider>();
    showDialog(
      context: context,
      builder: (ctx) => Consumer<ProductProvider>(
        builder: (context, productProvider, _) {
          return AlertDialog(
            title: const Text('Add Product'),
            content: SizedBox(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration: const InputDecoration(
                      hintText: 'Search products...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (v) => productProvider.searchProducts(v),
                  ),
                  const SizedBox(height: 12),
                  if (productProvider.isSearching)
                    const CircularProgressIndicator()
                  else
                    Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: productProvider.products.length,
                        itemBuilder: (context, i) {
                          final product = productProvider.products[i];
                          return ListTile(
                            dense: true,
                            leading: CircleAvatar(
                              radius: 16,
                              child: Text(
                                product.productName.isNotEmpty
                                    ? product.productName[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                            title: Text(product.productName, style: const TextStyle(fontSize: 14)),
                            subtitle: Text(
                              'Stock: ${product.stockQuantity} ${product.unit}',
                              style: const TextStyle(fontSize: 11),
                            ),
                            onTap: () {
                              provider.addItem(TransportItemModel.create(
                                transportId: '',
                                productId: product.id,
                                productName: product.productName,
                                quantity: 1,
                                unit: product.unit,
                              ));
                              Navigator.pop(ctx);
                            },
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNotesSection(BuildContext context, TransportProvider provider) {
    final colorScheme = context.colorScheme;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.notes, size: 18, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text('Additional Notes', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            decoration: const InputDecoration(
              hintText: 'Enter any additional notes or instructions...',
              border: OutlineInputBorder(),
            ),
            initialValue: provider.editingNotes,
            onChanged: (v) => provider.setEditingNotes(v),
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context, TransportProvider provider) {
    return Row(
      children: [
        OutlinedButton(
          onPressed: () => GoRouter.of(context).pop(),
          child: const Text('Cancel'),
        ),
        const SizedBox(width: 12),
        FilledButton(
          onPressed: provider.isLoading
              ? null
              : () async {
                  if (!_formKey.currentState!.validate()) return;
                  try {
                    await provider.createTransport();
                    if (context.mounted) {
                      context.showSnackBar('Transport created successfully');
                      GoRouter.of(context).pop();
                    }
                  } catch (_) {}
                },
          child: provider.isLoading
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Create Transport'),
        ),
      ],
    );
  }
}
