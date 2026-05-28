import 'package:flutter/material.dart';

class GstBreakdownTile extends StatelessWidget {
  final double subtotal;
  final double cgst;
  final double sgst;
  final double igst;
  final double roundOff;
  final double totalAmount;

  const GstBreakdownTile({
    super.key,
    required this.subtotal,
    required this.cgst,
    required this.sgst,
    required this.igst,
    required this.roundOff,
    required this.totalAmount,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('GST Breakdown',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const Divider(),
            _Row('Subtotal', '₹${subtotal.toStringAsFixed(2)}'),
            _Row('CGST', '₹${cgst.toStringAsFixed(2)}'),
            _Row('SGST', '₹${sgst.toStringAsFixed(2)}'),
            if (igst > 0) _Row('IGST', '₹${igst.toStringAsFixed(2)}'),
            if (roundOff != 0)
              _Row('Round Off', '₹${roundOff.toStringAsFixed(2)}'),
            const Divider(),
            _Row('Total', '₹${totalAmount.toStringAsFixed(2)}',
                isBold: true),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  const _Row(this.label, this.value, {this.isBold = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(value,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}
