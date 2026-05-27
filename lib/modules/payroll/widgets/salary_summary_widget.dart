import 'package:flutter/material.dart';
import 'package:smarterp/modules/payroll/services/salary_calculation_service.dart';

class SalarySummaryWidget extends StatelessWidget {
  final SalaryBreakdown breakdown;
  final bool showChart;

  const SalarySummaryWidget({
    super.key,
    required this.breakdown,
    this.showChart = true,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showChart) _buildChart(context),
        if (showChart) const SizedBox(height: 20),
        _buildComponentRows(context),
        const Divider(height: 24),
        _buildTotalRow(context, 'Gross Salary', breakdown.grossSalary, Colors.black87),
        if (breakdown.deductions > 0)
          _buildTotalRow(context, 'Total Deductions', breakdown.deductions, Colors.red),
        const Divider(height: 24, thickness: 2),
        _buildTotalRow(context, 'Net Salary', breakdown.netSalary, colorScheme.primary, bold: true),
      ],
    );
  }

  Widget _buildChart(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final components = breakdown.components;

    if (components.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            height: 24,
            child: Row(
              children: components.map((c) {
                return Expanded(
                  flex: c.percentage.round().clamp(1, 100),
                  child: Container(
                    color: _componentColor(c.label).withOpacity(c.isPositive ? 0.7 : 0.85),
                    child: c.percentage >= 15
                        ? Center(
                            child: Text(
                              '${c.percentage.toStringAsFixed(0)}%',
                              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
                            ),
                          )
                        : null,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: components.map((c) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: _componentColor(c.label).withOpacity(c.isPositive ? 0.7 : 0.85),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '${c.label} (${c.percentage.toStringAsFixed(1)}%)',
                  style: TextStyle(fontSize: 11, color: colorScheme.onSurface.withOpacity(0.7)),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildComponentRows(BuildContext context) {
    return Column(
      children: breakdown.components.map((c) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Icon(
                c.isPositive ? Icons.add_circle_outline : Icons.remove_circle_outline,
                size: 16,
                color: c.isPositive ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(c.label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
              ),
              Text(
                '${c.isPositive ? '' : '-'} ₹${c.amount.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: c.isPositive ? Colors.black87 : Colors.red,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTotalRow(BuildContext context, String label, double amount, Color color, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: bold ? 15 : 13,
                fontWeight: bold ? FontWeight.bold : FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Text(
            '₹${amount.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: bold ? 16 : 13,
              fontWeight: bold ? FontWeight.bold : FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Color _componentColor(String label) {
    switch (label) {
      case 'Basic':
        return Colors.blue;
      case 'Bonus':
        return Colors.green;
      case 'Overtime':
        return Colors.orange;
      case 'Deductions':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
