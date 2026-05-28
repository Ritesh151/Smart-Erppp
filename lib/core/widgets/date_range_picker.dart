import 'package:flutter/material.dart';
import 'package:SmartERP/core/utils/date_helper.dart';

class DateRangePickerWidget extends StatelessWidget {
  final DateTimeRange? initialRange;
  final ValueChanged<DateTimeRange?> onChanged;

  const DateRangePickerWidget({
    super.key,
    this.initialRange,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final range = initialRange ?? DateHelper.currentMonth();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: () async {
          final picked = await showDateRangePicker(
            context: context,
            firstDate: DateTime(2020),
            lastDate: DateTime(2030),
            initialDateRange: range,
          );
          if (picked != null) onChanged(picked);
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.date_range, size: 20, color: Colors.grey.shade600),
              const SizedBox(width: 8),
              Text(
                '${DateHelper.display(range.start)} - ${DateHelper.display(range.end)}',
                style: TextStyle(
                  color: Colors.grey.shade800,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.arrow_drop_down, color: Colors.grey.shade600),
            ],
          ),
        ),
      ),
    );
  }
}
