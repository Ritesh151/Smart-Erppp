import 'package:flutter/material.dart';

class AttendanceSummaryWidget extends StatelessWidget {
  final int presentCount;
  final int absentCount;
  final int halfDayCount;
  final int leaveCount;
  final int holidayCount;
  final int totalRecords;

  const AttendanceSummaryWidget({
    super.key,
    required this.presentCount,
    required this.absentCount,
    required this.halfDayCount,
    required this.leaveCount,
    required this.holidayCount,
    required this.totalRecords,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Monthly Summary', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildSummaryItem('Present', '$presentCount', Colors.green, 0.25),
            const SizedBox(width: 8),
            _buildSummaryItem('Absent', '$absentCount', Colors.red, 0.25),
            const SizedBox(width: 8),
            _buildSummaryItem('Half Day', '$halfDayCount', Colors.orange, 0.25),
            const SizedBox(width: 8),
            _buildSummaryItem('Leave', '$leaveCount', Colors.blue, 0.25),
            if (holidayCount > 0) ...[
              const SizedBox(width: 8),
              _buildSummaryItem('Holiday', '$holidayCount', Colors.purple, 0.25),
            ],
          ],
        ),
        if (totalRecords > 0) ...[
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              height: 8,
              child: Row(
                children: [
                  Flexible(
                    flex: presentCount,
                    child: Container(color: Colors.green),
                  ),
                  Flexible(
                    flex: absentCount,
                    child: Container(color: Colors.red),
                  ),
                  Flexible(
                    flex: halfDayCount,
                    child: Container(color: Colors.orange),
                  ),
                  Flexible(
                    flex: leaveCount,
                    child: Container(color: Colors.blue),
                  ),
                  if (holidayCount > 0)
                    Flexible(
                      flex: holidayCount,
                      child: Container(color: Colors.purple),
                    ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color, double flex) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
