import 'package:flutter/material.dart';
import 'package:smarterp/core/models/salary_model.dart';
import 'package:smarterp/core/models/salary_history_model.dart';

class SalaryTimelineWidget extends StatelessWidget {
  final SalaryStatus currentStatus;
  final double paidAmount;
  final double netSalary;
  final List<SalaryHistoryModel>? paymentHistory;
  final DateTime? paymentDate;

  const SalaryTimelineWidget({
    super.key,
    required this.currentStatus,
    required this.paidAmount,
    required this.netSalary,
    this.paymentHistory,
    this.paymentDate,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final steps = _buildSteps();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Status Timeline', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 16),
        ...steps.asMap().entries.map((entry) {
          final index = entry.key;
          final step = entry.value;
          final isLast = index == steps.length - 1;

          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 32,
                  child: Column(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: step.isActive
                              ? colorScheme.primary
                              : step.isCompleted
                                  ? Colors.green
                                  : Colors.grey.shade200,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: step.isCompleted
                              ? const Icon(Icons.check, size: 14, color: Colors.white)
                              : step.isActive
                                  ? Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                    )
                                  : Text(
                                      '${index + 1}',
                                      style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                                    ),
                        ),
                      ),
                      if (!isLast)
                        Expanded(
                          child: Container(
                            width: 2,
                            color: (step.isCompleted || step.isActive)
                                ? (step.isCompleted ? Colors.green : colorScheme.primary)
                                : Colors.grey.shade200,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: isLast ? 0 : 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          step.label,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: step.isActive ? FontWeight.bold : FontWeight.w500,
                            color: step.isCompleted
                                ? Colors.green
                                : step.isActive
                                    ? colorScheme.primary
                                    : Colors.grey,
                          ),
                        ),
                        if (step.subtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            step.subtitle!,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                if (step.trailing != null) step.trailing!,
              ],
            ),
          );
        }),
      ],
    );
  }

  List<_TimelineStep> _buildSteps() {
    final isPaid = currentStatus == SalaryStatus.paid || currentStatus == SalaryStatus.overdue;
    final isPartiallyPaid = currentStatus == SalaryStatus.partiallyPaid;
    final isPending = currentStatus == SalaryStatus.pending || currentStatus == SalaryStatus.overdue;

    return [
      _TimelineStep(
        label: 'Salary Generated',
        isCompleted: true,
      ),
      _TimelineStep(
        label: 'Payment Initiated',
        isCompleted: isPaid || isPartiallyPaid,
        isActive: isPartiallyPaid,
        subtitle: isPartiallyPaid
            ? 'Partially paid — ₹${paidAmount.toStringAsFixed(0)} of ₹${netSalary.toStringAsFixed(0)}'
            : isPaid
                ? 'Fully paid — ₹${paidAmount.toStringAsFixed(0)}'
                : null,
      ),
      _TimelineStep(
        label: isPaid ? 'Salary Paid' : 'Pending Payment',
        isCompleted: isPaid,
        isActive: isPending,
        subtitle: paymentDate != null
            ? 'Paid on ${paymentDate!.day}/${paymentDate!.month}/${paymentDate!.year}'
            : null,
        trailing: isPaid
            ? const Icon(Icons.check_circle, color: Colors.green, size: 20)
            : null,
      ),
    ];
  }
}

class _TimelineStep {
  final String label;
  final String? subtitle;
  final bool isCompleted;
  final bool isActive;
  final Widget? trailing;

  _TimelineStep({
    required this.label,
    this.subtitle,
    this.isCompleted = false,
    this.isActive = false,
    this.trailing,
  });
}
