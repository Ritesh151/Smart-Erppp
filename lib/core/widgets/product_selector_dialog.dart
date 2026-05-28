import 'package:flutter/material.dart';

class ProductSelectorDialog extends StatefulWidget {
  final List<dynamic> initialProducts;
  final bool multiSelect;

  const ProductSelectorDialog({
    super.key,
    required this.initialProducts,
    this.multiSelect = true,
  });

  @override
  State<ProductSelectorDialog> createState() => _ProductSelectorDialogState();
}

class _ProductSelectorDialogState extends State<ProductSelectorDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Products'),
      content: const Text('No products available.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
