import 'package:flutter/material.dart';

class LowStockBadge extends StatelessWidget {
  final int stock;
  final bool isOutOfStock;

  const LowStockBadge({
    super.key,
    required this.stock,
    this.isOutOfStock = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isOutOfStock) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Text(
          'Out of Stock',
          style: TextStyle(
            fontSize: 11,
            color: Colors.red.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }
    if (stock <= 5) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange.shade200),
        ),
        child: Text(
          'Low Stock: $stock',
          style: TextStyle(
            fontSize: 11,
            color: Colors.orange.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
