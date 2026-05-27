import 'package:flutter/material.dart';
import 'package:smarterp/core/models/salary_history_model.dart';

class PaymentHistoryWidget extends StatelessWidget {
  final List<SalaryHistoryModel> history;
  final double netSalary;
  final double paidAmount;

  const PaymentHistoryWidget({
    super.key,
    required this.history,
    required this.netSalary,
    required this.paidAmount,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Payment History', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
            Text(
              '₹${paidAmount.toStringAsFixed(0)} / ₹${netSalary.toStringAsFixed(0)}',
              style: TextStyle(fontSize: 12, color: colorScheme.onSurface.withOpacity(0.6)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (netSalary > 0)
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              height: 6,
              child: LinearProgressIndicator(
                value: (paidAmount / netSalary).clamp(0.0, 1.0),
                backgroundColor: colorScheme.surfaceContainerHighest,
                color: paidAmount >= netSalary ? Colors.green : Colors.blue,
              ),
            ),
          ),
        const SizedBox(height: 12),
        if (history.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.payment_outlined, size: 32, color: Colors.grey.shade300),
                  const SizedBox(height: 8),
                  Text('No payments recorded yet', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                ],
              ),
            ),
          )
        else
          ...history.asMap().entries.map((entry) {
            final index = entry.key;
            final h = entry.value;
            final isLast = index == history.length - 1;

            return Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: _methodColor(h.paymentMethod).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(_methodIcon(h.paymentMethod), size: 16, color: _methodColor(h.paymentMethod)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          h.paymentMethod.displayName,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatDate(h.paymentDate),
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                  if (h.referenceNumber != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Text(h.referenceNumber!, style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
                    ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: h.paymentType == PaymentType.full
                          ? Colors.green.withOpacity(0.08)
                          : Colors.orange.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      h.paymentType.displayName,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: h.paymentType == PaymentType.full ? Colors.green : Colors.orange,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '₹${h.amount.toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  IconData _methodIcon(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash: return Icons.money;
      case PaymentMethod.upi: return Icons.phone_android;
      case PaymentMethod.bankTransfer: return Icons.account_balance;
      case PaymentMethod.cheque: return Icons.receipt_long;
    }
  }

  Color _methodColor(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash: return Colors.green;
      case PaymentMethod.upi: return Colors.blue;
      case PaymentMethod.bankTransfer: return Colors.purple;
      case PaymentMethod.cheque: return Colors.orange;
    }
  }
}
