import 'package:flutter/material.dart';
import 'package:smarterp/core/constants/app_constants.dart';
import 'package:smarterp/core/models/vehicle_model.dart';

typedef VehicleFormSaveCallback = Future<void> Function(
  String vehicleNumber,
  String vehicleType,
  double capacity,
  String capacityUnit,
  String? driverName,
  String? driverPhone,
);

class VehicleFormWidget extends StatefulWidget {
  final VehicleModel? vehicle;
  final VehicleFormSaveCallback onSave;

  const VehicleFormWidget({
    super.key,
    this.vehicle,
    required this.onSave,
  });

  @override
  State<VehicleFormWidget> createState() => _VehicleFormWidgetState();
}

class _VehicleFormWidgetState extends State<VehicleFormWidget> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _numberController;
  late final TextEditingController _typeController;
  late final TextEditingController _capacityController;
  late final TextEditingController _driverNameController;
  late final TextEditingController _driverPhoneController;
  String _capacityUnit = 'Ton';
  bool _isSaving = false;

  final List<String> _unitOptions = ['Ton', 'Kg', 'Liters', 'Cubic Meter'];

  static const List<String> _vehicleTypeOptions = [
    'Truck',
    'Trailer',
    'Container',
    'Pickup',
    'Van',
    'Tanker',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _numberController = TextEditingController(text: widget.vehicle?.vehicleNumber ?? '');
    _typeController = TextEditingController(text: widget.vehicle?.vehicleType ?? '');
    _capacityController = TextEditingController(
      text: widget.vehicle != null ? widget.vehicle!.capacity.toString() : '',
    );
    _driverNameController = TextEditingController(text: widget.vehicle?.driverName ?? '');
    _driverPhoneController = TextEditingController(text: widget.vehicle?.driverPhone ?? '');
    if (widget.vehicle != null) {
      _capacityUnit = widget.vehicle!.capacityUnit;
    }
  }

  @override
  void dispose() {
    _numberController.dispose();
    _typeController.dispose();
    _capacityController.dispose();
    _driverNameController.dispose();
    _driverPhoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.vehicle == null ? 'Add Vehicle' : 'Edit Vehicle',
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _numberController,
            decoration: const InputDecoration(
              labelText: 'Vehicle Number',
              hintText: 'e.g. MH-12-AB-1234',
              border: OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.characters,
            validator: (v) => v == null || v.trim().isEmpty ? 'Vehicle number is required' : null,
          ),
          const SizedBox(height: 16),
          Autocomplete<String>(
            initialValue: TextEditingValue(text: _typeController.text),
            optionsBuilder: (textEditingValue) {
              if (textEditingValue.text.isEmpty) return _vehicleTypeOptions;
              return _vehicleTypeOptions.where((opt) =>
                  opt.toLowerCase().contains(textEditingValue.text.toLowerCase()));
            },
            onSelected: (selection) {
              _typeController.text = selection;
            },
            fieldViewBuilder: (context, controller, focusNode, onSubmitted) {
              return TextFormField(
                controller: controller,
                focusNode: focusNode,
                decoration: const InputDecoration(
                  labelText: 'Vehicle Type',
                  hintText: 'e.g. Truck, Trailer, Van...',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Vehicle type is required' : null,
                onFieldSubmitted: (_) => onSubmitted(),
              );
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: TextFormField(
                  controller: _capacityController,
                  decoration: const InputDecoration(
                    labelText: 'Capacity',
                    hintText: 'e.g. 10',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Capacity is required';
                    if (double.tryParse(v.trim()) == null) return 'Enter a valid number';
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: DropdownButtonFormField<String>(
                  value: _capacityUnit,
                  decoration: const InputDecoration(
                    labelText: 'Unit',
                    border: OutlineInputBorder(),
                  ),
                  items: _unitOptions.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _capacityUnit = v);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          Text(
            'Driver Information (Optional)',
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _driverNameController,
            decoration: const InputDecoration(
              labelText: 'Driver Name',
              hintText: 'Enter driver full name',
              border: OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _driverPhoneController,
            decoration: const InputDecoration(
              labelText: 'Driver Phone',
              hintText: 'Enter driver phone number',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _isSaving ? null : _handleSave,
              child: _isSaving
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text(widget.vehicle == null ? 'Add Vehicle' : 'Save Changes'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      await widget.onSave(
        _numberController.text.trim().toUpperCase(),
        _typeController.text.trim(),
        double.parse(_capacityController.text.trim()),
        _capacityUnit,
        _driverNameController.text.trim().isEmpty ? null : _driverNameController.text.trim(),
        _driverPhoneController.text.trim().isEmpty ? null : _driverPhoneController.text.trim(),
      );
    } catch (_) {
      setState(() => _isSaving = false);
    }
  }
}
