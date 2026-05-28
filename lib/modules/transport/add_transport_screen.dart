// lib/Pages/Transport/add_transport_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:SmartERP/modules/transport/models/transport_screen_model.dart';
import 'package:SmartERP/modules/transport/providers/transport_screen_provider.dart';
import 'package:SmartERP/core/utils/date_helper.dart';
import 'package:SmartERP/core/utils/currency_formatter.dart';
import 'package:SmartERP/core/widgets/app_scaffold.dart';
import 'package:SmartERP/core/widgets/product_selector_dialog.dart';
import 'package:SmartERP/local_db/hive_boxes.dart';
import 'package:SmartERP/local_db/models/local_invoice.dart';

class AddTransportScreen extends ConsumerStatefulWidget {
  final String? transportId;
  final String? invoiceId;

  const AddTransportScreen({super.key, this.transportId, this.invoiceId});

  @override
  ConsumerState<AddTransportScreen> createState() =>
      _AddTransportScreenState();
}

class _AddTransportScreenState extends ConsumerState<AddTransportScreen> {
  late GlobalKey<FormState> _formKey;
  bool _isSaving = false;

  // Products
  List<ProductLineItem> _selectedProducts = [];

  // Transport form fields
  late TextEditingController _transportNameController;
  late TextEditingController _driverNameController;
  late TextEditingController _destinationController;

  // Transport Details
  TransportType? _selectedTransportType;
  late TextEditingController _vehicleNumberController;

  // Date
  DateTime? _selectedDate;

  // Status
  ExportStatus? _selectedStatus;

  // Notes
  late TextEditingController _notesController;

  late TransportModel? _existingTransport;

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
    _transportNameController = TextEditingController();
    _driverNameController = TextEditingController();
    _destinationController = TextEditingController();
    _vehicleNumberController = TextEditingController();
    _notesController = TextEditingController();
    _selectedDate = DateTime.now();
    _selectedStatus = ExportStatus.planned;
    _selectedTransportType = TransportType.truck;
    _existingTransport = null;
    _selectedProducts = [];

    // Load existing transport if editing
    if (widget.transportId != null) {
      _loadTransport();
    } else if (widget.invoiceId != null) {
      _loadInvoiceData(widget.invoiceId!);
    }
  }

  Future<void> _loadInvoiceData(String invoiceId) async {
    final box = HiveBoxes.invoicesBox();
    final raw = box.get(invoiceId);
    if (raw == null || raw is! Map) return;

    final invoice = LocalInvoice.fromMap(raw);
    if (!mounted) return;

    setState(() {
      // Also default Transport Name to Customer Name if empty
      if (_transportNameController.text.isEmpty) {
        _transportNameController.text = invoice.customerName;
      }

      // Map invoice items to transport product line items
      _selectedProducts = invoice.items.map((item) {
        return ProductLineItem(
          productId: item.productId,
          productName: item.productName,
          hsnCode: '', // HSN not directly tracked in LocalInvoiceItem
          unitPrice: item.price,
          quantity: item.quantity,
          unit: 'PCS', // Default unit since invoice item doesn't explicitly have it
        );
      }).toList();
    });
  }

  Future<void> _loadTransport() async {
    final transportId = widget.transportId;
    if (transportId == null) return;

    final transport =
        await ref.read(transportServiceProvider).getTransport(transportId);
    if (!mounted || transport == null) return;

    setState(() {
      _existingTransport = transport;
      _selectedProducts = List.from(transport.products);
      _transportNameController.text = transport.transportName;
      _driverNameController.text = transport.driverName;
      _destinationController.text = transport.destinationLocation;
      _vehicleNumberController.text = transport.vehicleNumber ?? '';
      _notesController.text = transport.notes ?? '';
      _selectedDate = transport.transportDate;
      _selectedStatus = transport.status;
      _selectedTransportType = transport.transportType;
    });
  }

  @override
  void dispose() {
    _transportNameController.dispose();
    _driverNameController.dispose();
    _destinationController.dispose();
    _vehicleNumberController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _openProductSelector() async {
    final result = await showDialog<List<ProductLineItem>>(
      context: context,
      builder: (ctx) => ProductSelectorDialog(
        initialProducts: _selectedProducts,
        multiSelect: true,
      ),
    );

    if (result != null && mounted) {
      setState(() => _selectedProducts = result);
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedProducts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one product')),
      );
      return;
    }
    
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a transport date')),
      );
      return;
    }
    
    if (_selectedStatus == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a status')),
      );
      return;
    }

    if (_selectedTransportType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a transport type')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final transport = TransportModel(
        transportId: _existingTransport?.transportId ?? '',
        invoiceId: widget.invoiceId ?? _existingTransport?.invoiceId,
        transportNumber: _existingTransport?.transportNumber ?? '',
        transportName: _transportNameController.text.trim(),
        driverName: _driverNameController.text.trim(),
        products: _selectedProducts,
        sourceLocation: _transportNameController.text.trim(),
        destinationLocation: _destinationController.text.trim(),
        status: _selectedStatus!,
        transportDate: _selectedDate!,
        transportType: _selectedTransportType!,
        vehicleNumber: _vehicleNumberController.text.trim().isEmpty
            ? null
            : _vehicleNumberController.text.trim(),
        transportCompany: null,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        createdAt: _existingTransport?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final notifier = ref.read(transportNotifierProvider.notifier);
      final bool ok = _existingTransport != null
          ? await notifier.updateTransport(
              _existingTransport!.transportId,
              transport,
            )
          : await notifier.addTransport(transport);

      if (!mounted) return;

      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_existingTransport != null
                ? 'Transport updated successfully'
                : 'Transport created successfully'),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/transports');
        return;
      }

      final errorState = ref.read(transportNotifierProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorState.error ?? 'Failed to save transport record'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: _existingTransport != null
          ? 'Edit Transport'
          : 'Add Transport',
      showBackButton: true,
      body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                      _buildSectionTitle('Products'),
                      const SizedBox(height: 12),
                      if (widget.invoiceId == null) ...[
                        ElevatedButton.icon(
                          onPressed: _openProductSelector,
                          icon: const Icon(Icons.add_shopping_cart),
                          label: const Text('Select Products'),
                        ),
                        const SizedBox(height: 12),
                      ] else ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.lock, color: Colors.blue.shade700),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Products and quantities are locked to the selected invoice.',
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelMedium
                                      ?.copyWith(color: Colors.blue.shade700),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],

                      // Selected products display
                      if (_selectedProducts.isNotEmpty)
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Selected Products (${_selectedProducts.length})',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: _selectedProducts.length,
                                  itemBuilder: (ctx, idx) {
                                    final product = _selectedProducts[idx];
                                    return Padding(
                                      padding:
                                          const EdgeInsets.symmetric(vertical: 4),
                                      child: Row(
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
                                                      .labelMedium
                                                      ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                ),
                                                Text(
                                                  'HSN: ${product.hsnCode}',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .labelSmall
                                                      ?.copyWith(
                                                        color:
                                                            Colors.grey[600],
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                '${product.quantity} ${product.unit}',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .labelMedium
                                                    ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                              ),
                                              Text(
                                                CurrencyFormatter.format(
                                                    product.totalAmount),
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .labelSmall
                                                    ?.copyWith(
                                                      color: Colors.green,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                                const Divider(),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Total Value',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    Text(
                                      CurrencyFormatter.format(
                                        _selectedProducts.fold<double>(
                                          0,
                                          (sum, p) => sum + p.totalAmount,
                                        ),
                                      ),
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green,
                                          ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.orange.shade200,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info, color: Colors.orange.shade700),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Select at least one product to continue',
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelMedium
                                      ?.copyWith(
                                        color: Colors.orange.shade700,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 16),

                      // ── Transport Details ─────────────────────────────
                      _buildSectionTitle('Transport Details'),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _transportNameController,
                        decoration: InputDecoration(
                          labelText: 'Transport Name *',
                          hintText: 'e.g., TRN for Ahmedabad',
                          prefixIcon: const Icon(Icons.local_shipping_outlined),
                        ),
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Transport name is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _vehicleNumberController,
                        decoration: InputDecoration(
                          labelText: 'Vehicle Number *',
                          hintText: 'e.g., GJ01AB1234',
                          prefixIcon: const Icon(Icons.directions_car),
                        ),
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Vehicle number is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _driverNameController,
                        decoration: InputDecoration(
                          labelText: 'Driver Name *',
                          hintText: 'e.g., Rajesh',
                          prefixIcon: const Icon(Icons.person_outline),
                        ),
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Driver name is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _destinationController,
                        readOnly: widget.invoiceId != null,
                        decoration: InputDecoration(
                          labelText: 'Destination *',
                          hintText: 'e.g., Ahmedabad',
                          prefixIcon: const Icon(Icons.location_on_outlined),
                        ),
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Destination is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),

                      DropdownButtonFormField<TransportType>(
                        value: _selectedTransportType,
                        decoration: InputDecoration(
                          labelText: 'Transport Type *',
                          prefixIcon: const Icon(Icons.local_shipping),
                        ),
                        items: TransportType.values.map((type) {
                          return DropdownMenuItem<TransportType>(
                            value: type,
                            child: Text(type.displayName),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => _selectedTransportType = value);
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Please select a transport type';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // ── Date & Status Section ──────────────────────────
                      _buildSectionTitle('Transport Status'),
                      const SizedBox(height: 12),
                      _buildDatePickerField(context),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<ExportStatus>(
                        value: _selectedStatus,
                        decoration: InputDecoration(
                          labelText: 'Status *',
                          prefixIcon: const Icon(Icons.info_outline),
                        ),
                        items: ExportStatus.values.map((status) {
                          return DropdownMenuItem<ExportStatus>(
                            value: status,
                            child: Text(status.displayName),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => _selectedStatus = value);
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Please select a status';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // ── Notes Section ──────────────────────────────────
                      _buildSectionTitle('Additional Information'),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _notesController,
                        decoration: InputDecoration(
                          labelText: 'Notes / Remarks',
                          hintText:
                              'Add any additional information about this transport',
                          prefixIcon: const Icon(Icons.note),
                          alignLabelWithHint: true,
                        ),
                        maxLines: 4,
                      ),
                      const SizedBox(height: 20),

                      // ── Action Buttons ────────────────────────────────
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => context.pop(),
                              child: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _isSaving ? null : _submitForm,
                              child: _isSaving
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const SizedBox(
                                          height: 16,
                                          width: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(_existingTransport != null
                                            ? 'Updating transport...'
                                            : 'Creating transport...'),
                                      ],
                                    )
                                  : Text(
                                      _existingTransport != null
                                          ? 'Update Record'
                                          : 'Create Record',
                                    ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildDatePickerField(BuildContext context) {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _selectedDate ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (date != null) {
          setState(() => _selectedDate = date);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Transport Date *',
          prefixIcon: const Icon(Icons.calendar_today),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          _selectedDate != null
              ? DateHelper.display(_selectedDate!)
              : 'Select a date',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}
