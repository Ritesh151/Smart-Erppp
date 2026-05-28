import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:SmartERP/Models/sale_item_model.dart';
import 'package:SmartERP/Models/sale_model.dart';
import 'package:SmartERP/Providers/product_provider.dart';
import 'package:SmartERP/Providers/sale_provider.dart';
import 'package:SmartERP/core/utils/currency_formatter.dart';
import 'package:SmartERP/core/widgets/app_scaffold.dart';

class CreateSaleScreen extends ConsumerStatefulWidget {
  const CreateSaleScreen({super.key});

  @override
  ConsumerState<CreateSaleScreen> createState() => _CreateSaleScreenState();
}

class _CreateSaleScreenState extends ConsumerState<CreateSaleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _customerNameController = TextEditingController();
  final _customerPhoneController = TextEditingController();
  final _customerAddressController = TextEditingController();

  List<SaleItemModel> _items = [];
  int _selectedPaymentTermsDays = 30;
  final List<int> _paymentTermOptions = [7, 15, 30, 45];

  void _addItem() {
    setState(() {
      _items.add(SaleItemModel(
        productId: '',
        productName: '',
        quantity: 1,
        price: 0,
        amount: 0,
        gstAmount: 0,
        totalAmount: 0,
      ));
    });
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  void _updateItem(int index, SaleItemModel item) {
    setState(() {
      _items[index] = item;
    });
  }

  double get _subtotal => _items.fold(0, (sum, item) => sum + item.amount);
  double get _gstAmount => _items.fold(0, (sum, item) => sum + item.gstAmount);
  double get _total => _subtotal + _gstAmount;

  Future<void> _saveSale() async {
    if (!_formKey.currentState!.validate() || _items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one item')),
      );
      return;
    }

    // Check stock for each item
    final products = ref.read(productsStreamProvider).asData?.value ?? [];
    for (final item in _items) {
      final product = products.firstWhere((p) => p.productId == item.productId);
      if (item.quantity > product.stock) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Insufficient stock for ${item.productName}')),
        );
        return;
      }
    }

    final sale = SaleModel(
      saleId: '',
      customerName: _customerNameController.text,
      customerPhone: _customerPhoneController.text,
      customerAddress: _customerAddressController.text,
      items: _items,
      createdAt: DateTime.now(),
    );

    try {
      await ref.read(saleServiceProvider).saveSaleWithStockUpdate(sale: sale);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sale recorded successfully')),
        );
        context.go('/finance');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _customerPhoneController.dispose();
    _customerAddressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsStreamProvider);

    return AppScaffold(
      title: 'Create Sale',
      showBackButton: true,
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Customer Details
            const Text('Customer Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextFormField(
              controller: _customerNameController,
              decoration: const InputDecoration(labelText: 'Customer Name'),
              validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
            ),
            TextFormField(
              controller: _customerPhoneController,
              decoration: const InputDecoration(labelText: 'Phone'),
            ),
            TextFormField(
              controller: _customerAddressController,
              decoration: const InputDecoration(labelText: 'Address'),
            ),
            const SizedBox(height: 24),

            // Items
            const Text('Items', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ..._items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: productsAsync.when(
                              loading: () => const CircularProgressIndicator(),
                              error: (e, _) => Text('Error: $e'),
                              data: (products) => DropdownButtonFormField<String>(
                                value: item.productId.isEmpty ? null : item.productId,
                                decoration: const InputDecoration(labelText: 'Product'),
                                items: products.map((product) => DropdownMenuItem<String>(
                                  value: product.productId,
                                  child: Text('${product.name} (Stock: ${product.stock})'),
                                )).toList(),
                                onChanged: (productId) {
                                  if (productId != null) {
                                    final product = products.firstWhere((p) => p.productId == productId);
                                    _updateItem(index, SaleItemModel(
                                      productId: productId,
                                      productName: product.name,
                                      hsnCode: product.hsnCode ?? '',
                                      quantity: item.quantity,
                                      price: product.price,
                                      amount: item.quantity * product.price,
                                      gstAmount: (item.quantity * product.price) * (item.gstRate / 100),
                                      totalAmount: (item.quantity * product.price) * (1 + item.gstRate / 100),
                                    ));
                                  }
                                },
                                validator: (value) => value == null ? 'Select product' : null,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _removeItem(index),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              initialValue: item.quantity.toString(),
                              decoration: const InputDecoration(labelText: 'Quantity'),
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                final qty = double.tryParse(value) ?? 0;
                                _updateItem(index, item.copyWith(
                                  quantity: qty,
                                  amount: qty * item.price,
                                  gstAmount: (qty * item.price) * (item.gstRate / 100),
                                  totalAmount: (qty * item.price) * (1 + item.gstRate / 100),
                                ));
                              },
                              validator: (value) => double.tryParse(value ?? '') == null || double.parse(value!) <= 0 ? 'Invalid quantity' : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              initialValue: item.price.toString(),
                              decoration: const InputDecoration(labelText: 'Price'),
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                final price = double.tryParse(value) ?? 0;
                                _updateItem(index, item.copyWith(
                                  price: price,
                                  amount: item.quantity * price,
                                  gstAmount: (item.quantity * price) * (item.gstRate / 100),
                                  totalAmount: (item.quantity * price) * (1 + item.gstRate / 100),
                                ));
                              },
                              validator: (value) => double.tryParse(value ?? '') == null || double.parse(value!) < 0 ? 'Invalid price' : null,
                            ),
                          ),
                        ],
                      ),
                      TextFormField(
                        initialValue: item.gstRate.toString(),
                        decoration: const InputDecoration(labelText: 'GST Rate (%)'),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          final gstRate = double.tryParse(value) ?? 0;
                          _updateItem(index, item.copyWith(
                            gstRate: gstRate,
                            gstAmount: item.amount * (gstRate / 100),
                            totalAmount: item.amount * (1 + gstRate / 100),
                          ));
                        },
                        validator: (value) => double.tryParse(value ?? '') == null || double.parse(value!) < 0 ? 'Invalid GST rate' : null,
                      ),
                    ],
                  ),
                ),
              );
            }),
            ElevatedButton.icon(
              onPressed: _addItem,
              icon: const Icon(Icons.add),
              label: const Text('Add Item'),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _selectedPaymentTermsDays,
                    decoration: const InputDecoration(
                      labelText: 'Payment Terms',
                      border: OutlineInputBorder(),
                    ),
                    items: _paymentTermOptions
                        .map((days) => DropdownMenuItem(
                              value: days,
                              child: Text('$days Days'),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedPaymentTermsDays = value;
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Due Date',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(
                          DateTime.now().add(Duration(days: _selectedPaymentTermsDays)),
                        ),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Totals
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Subtotal'),
                      Text(CurrencyFormatter.format(_subtotal)),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('GST Amount'),
                      Text(CurrencyFormatter.format(_gstAmount)),
                    ],
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(CurrencyFormatter.format(_total), style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: _saveSale,
              child: const Text('Save Sale'),
            ),
          ],
        ),
      ),
    );
  }
}
