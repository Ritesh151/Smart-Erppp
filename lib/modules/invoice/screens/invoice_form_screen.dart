import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:smarterp/core/exceptions/app_exception.dart';
import 'package:smarterp/core/extensions/context_extensions.dart';
import 'package:smarterp/core/theme/theme_extensions.dart';
import 'package:smarterp/core/widgets/app_shell.dart';
import 'package:smarterp/core/widgets/app_card.dart';
import 'package:smarterp/core/widgets/app_text_field.dart';
import 'package:smarterp/core/widgets/empty_state_widget.dart';
import 'package:smarterp/core/models/invoice_item_model.dart';
import 'package:smarterp/modules/invoice/providers/invoice_provider.dart';
import 'package:smarterp/modules/invoice/providers/customer_provider.dart';
import 'package:smarterp/modules/products/providers/product_provider.dart';

class InvoiceFormScreen extends StatefulWidget {
  const InvoiceFormScreen({super.key});

  @override
  State<InvoiceFormScreen> createState() => _InvoiceFormScreenState();
}

class _InvoiceFormScreenState extends State<InvoiceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _useExistingCustomer = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final invoiceProvider = context.read<InvoiceProvider>();
      invoiceProvider.resetEditingState();

      final customerProvider = context.read<CustomerProvider>();
      if (customerProvider.customers.isEmpty) {
        customerProvider.loadCustomers();
      }

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
      child: Consumer<InvoiceProvider>(
        builder: (context, provider, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'New Invoice',
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Fill in the invoice details below',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildCustomerSection(context, provider),
                  const SizedBox(height: 16),
                  _buildDateSection(context, provider),
                  const SizedBox(height: 16),
                  _buildItemsSection(context, provider),
                  const SizedBox(height: 16),
                  _buildTotalsSection(context, provider),
                  const SizedBox(height: 16),
                  _buildAdditionalSection(context, provider),
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

  Widget _buildCustomerSection(BuildContext context, InvoiceProvider provider) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Customer', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
              ToggleButtons(
                isSelected: [_useExistingCustomer, !_useExistingCustomer],
                onPressed: (index) {
                  setState(() {
                    _useExistingCustomer = index == 0;
                  });
                },
                constraints: const BoxConstraints(minWidth: 80, minHeight: 28),
                textStyle: const TextStyle(fontSize: 12),
                children: const [Text('Existing'), Text('Manual')],
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_useExistingCustomer)
            _buildExistingCustomerSelector(context, provider)
          else
            _buildManualCustomerEntry(context, provider),
        ],
      ),
    );
  }

  Widget _buildExistingCustomerSelector(BuildContext context, InvoiceProvider provider) {
    return Consumer<CustomerProvider>(
      builder: (context, customerProvider, _) {
        if (customerProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (customerProvider.customers.isEmpty) {
          return Column(
            children: [
              const EmptyStateWidget(
                icon: Icons.people_outline,
                title: 'No Customers',
                message: 'Add customers first or use manual entry',
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () => context.push('/customers/create'),
                child: const Text('Add Customer'),
              ),
            ],
          );
        }

        return Column(
          children: [
            DropdownButtonFormField<String>(
              value: provider.editingCustomerId.isNotEmpty ? provider.editingCustomerId : null,
              decoration: const InputDecoration(
                labelText: 'Select Customer *',
                prefixIcon: Icon(Icons.person_outline),
                border: OutlineInputBorder(),
              ),
              items: customerProvider.customers.map((c) {
                return DropdownMenuItem(
                  value: c.id,
                  child: Text('${c.name}${c.phone != null ? ' (${c.phone})' : ''}'),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  final customer = customerProvider.customers.firstWhere((c) => c.id == value);
                  provider.setEditingCustomerId(value);
                  provider.setEditingCustomerName(customer.name);
                  provider.setEditingCustomerEmail(customer.email ?? '');
                  provider.setEditingCustomerPhone(customer.phone ?? '');
                  provider.setEditingCustomerAddress(customer.address ?? '');
                  provider.setEditingCustomerGst(customer.gstNumber ?? '');
                }
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildManualCustomerEntry(BuildContext context, InvoiceProvider provider) {
    return Column(
      children: [
        AppTextField(
          controller: TextEditingController.fromValue(TextEditingValue(text: provider.editingCustomerName)),
          label: 'Customer Name *',
          hint: 'Enter customer name',
          prefixIcon: const Icon(Icons.person_outline),
          onChanged: (v) => provider.setEditingCustomerName(v),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: AppTextField(
                controller: TextEditingController.fromValue(TextEditingValue(text: provider.editingCustomerPhone)),
                label: 'Phone',
                hint: 'Enter phone',
                prefixIcon: const Icon(Icons.phone_outlined),
                onChanged: (v) => provider.setEditingCustomerPhone(v),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppTextField(
                controller: TextEditingController.fromValue(TextEditingValue(text: provider.editingCustomerEmail)),
                label: 'Email',
                hint: 'Enter email',
                prefixIcon: const Icon(Icons.email_outlined),
                onChanged: (v) => provider.setEditingCustomerEmail(v),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        AppTextField(
          controller: TextEditingController.fromValue(TextEditingValue(text: provider.editingCustomerAddress)),
          label: 'Address',
          hint: 'Enter address',
          prefixIcon: const Icon(Icons.location_on_outlined),
          onChanged: (v) => provider.setEditingCustomerAddress(v),
        ),
        const SizedBox(height: 12),
        AppTextField(
          controller: TextEditingController.fromValue(TextEditingValue(text: provider.editingCustomerGst)),
          label: 'GST Number',
          hint: 'Enter GST number',
          prefixIcon: const Icon(Icons.receipt_outlined),
          onChanged: (v) => provider.setEditingCustomerGst(v),
        ),
      ],
    );
  }

  Widget _buildDateSection(BuildContext context, InvoiceProvider provider) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Dates', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _datePickerField(
                  context: context,
                  label: 'Invoice Date *',
                  value: provider.editingInvoiceDate,
                  onPicked: (d) => provider.setEditingInvoiceDate(d),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _datePickerField(
                  context: context,
                  label: 'Due Date *',
                  value: provider.editingDueDate,
                  onPicked: (d) => provider.setEditingDueDate(d),
                ),
              ),
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

  Widget _buildItemsSection(BuildContext context, InvoiceProvider provider) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Items', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
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
              message: 'Add products to this invoice',
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

  Widget _buildItemRow(BuildContext context, InvoiceProvider provider, int index, InvoiceItemModel item) {
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
                  child: Text(
                    item.productName,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
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
                      labelText: 'Qty',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (v) {
                      final qty = double.tryParse(v) ?? 0;
                      provider.updateItemQuantity(index, qty);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    initialValue: item.unitPrice.toStringAsFixed(2),
                    decoration: const InputDecoration(
                      labelText: 'Price',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (v) {
                      final price = double.tryParse(v) ?? 0;
                      provider.updateItemPrice(index, price);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 80,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'GST',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    child: Text(
                      '${item.taxRate.toStringAsFixed(0)}%',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 90,
                  child: Text(
                    '₹${item.subtotal.toStringAsFixed(2)}',
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddItemDialog(BuildContext context, InvoiceProvider provider) {
    return showDialog(
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
                              '₹${product.price.toStringAsFixed(2)} | GST: ${product.gstRate.toStringAsFixed(0)}% | Stock: ${product.stockQuantity}',
                              style: const TextStyle(fontSize: 11),
                            ),
                            onTap: () {
                              provider.addItem(
                                productId: product.id,
                                productName: product.productName,
                                quantity: 1,
                                unitPrice: product.price,
                                gstRate: product.gstRate,
                                hsnCode: product.hsnCode,
                              );
                              Navigator.pop(ctx);
                            },
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTotalsSection(BuildContext context, InvoiceProvider provider) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Totals', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          _totalRow('Subtotal', provider.editingSubtotal),
          _totalRow('Tax', provider.editingTaxAmount),
          Row(
            children: [
              const Text('Discount', style: TextStyle(fontSize: 14)),
              const Spacer(),
              SizedBox(
                width: 100,
                child: TextFormField(
                  initialValue: provider.editingDiscount.toStringAsFixed(2),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    isDense: true,
                    prefixText: '₹',
                  ),
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.right,
                  onChanged: (v) {
                    provider.setEditingDiscount(double.tryParse(v) ?? 0);
                  },
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            children: [
              const Text(
                'Total Amount',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const Spacer(),
              Text(
                '₹${provider.editingTotalAmount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _totalRow(String label, double amount) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          const Spacer(),
          Text(
            '₹${amount.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalSection(BuildContext context, InvoiceProvider provider) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Additional', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          AppTextField(
            controller: TextEditingController.fromValue(TextEditingValue(text: provider.editingNotes)),
            label: 'Notes',
            hint: 'Additional notes for the customer',
            prefixIcon: const Icon(Icons.notes),
            maxLines: 3,
            onChanged: (v) => provider.setEditingNotes(v),
          ),
          const SizedBox(height: 12),
          AppTextField(
            controller: TextEditingController.fromValue(TextEditingValue(text: provider.editingTerms)),
            label: 'Terms & Conditions',
            hint: 'Payment terms, delivery terms, etc.',
            prefixIcon: const Icon(Icons.description_outlined),
            maxLines: 3,
            onChanged: (v) => provider.setEditingTerms(v),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context, InvoiceProvider provider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        const SizedBox(width: 16),
        OutlinedButton.icon(
          onPressed: provider.isLoading ? null : () => _saveDraft(context, provider),
          icon: const Icon(Icons.save_outlined, size: 18),
          label: const Text('Save Draft'),
        ),
        const SizedBox(width: 16),
        FilledButton.icon(
          onPressed: provider.isLoading ? null : () => _saveDraft(context, provider),
          icon: provider.isLoading
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.check, size: 18),
          label: const Text('Create Invoice'),
        ),
      ],
    );
  }

  Future<void> _saveDraft(BuildContext context, InvoiceProvider provider) async {
    if (!_formKey.currentState!.validate()) return;

    if (provider.editingCustomerName.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a customer name'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    try {
      await provider.saveDraft();
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invoice created successfully')),
        );
      }
    } on ValidationException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } catch (e) {
      // Error handled in provider
    }
  }
}
