import 'package:flutter/material.dart';
import 'package:smarterp/core/extensions/context_extensions.dart';

class AttendanceCalendarWidget extends StatelessWidget {
  final int month;
  final int year;
  final Map<int, Color> dayColors;
  final Map<int, String> dayLabels;
  final ValueChanged<DateTime>? onDaySelected;
  final DateTime? selectedDate;

  const AttendanceCalendarWidget({
    super.key,
    required this.month,
    required this.year,
    required this.dayColors,
    this.dayLabels = const {},
    this.onDaySelected,
    this.selectedDate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final firstDay = DateTime(year, month, 1);
    final lastDay = DateTime(year, month + 1, 0);
    final daysInMonth = lastDay.day;
    final startWeekday = firstDay.weekday;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return Column(
      children: [
        _buildWeekdayHeaders(context),
        const SizedBox(height: 4),
        _buildDayGrid(context, daysInMonth, startWeekday, today, colorScheme),
      ],
    );
  }

  Widget _buildWeekdayHeaders(BuildContext context) {
    final theme = Theme.of(context);
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Row(
      children: weekdays.map((day) {
        final isWeekend = day == 'Sat' || day == 'Sun';
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              day,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isWeekend ? Colors.grey : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDayGrid(
    BuildContext context,
    int daysInMonth,
    int startWeekday,
    DateTime today,
    ColorScheme colorScheme,
  ) {
    final rows = <Widget>[];
    var day = 1;
    var col = startWeekday - 1;

    while (day <= daysInMonth) {
      final weekCells = <Widget>[];
      for (var c = 0; c < 7; c++) {
        if ((c < col && day == 1) || day > daysInMonth) {
          weekCells.add(const Expanded(child: SizedBox()));
        } else {
          final currentDate = DateTime(year, month, day);
          final isToday = currentDate == today;
          final bgColor = dayColors[day];
          final label = dayLabels[day];
          final isSelected = selectedDate != null &&
              selectedDate!.day == day &&
              selectedDate!.month == month &&
              selectedDate!.year == year;

          weekCells.add(_buildDayCell(
            day: day,
            isToday: isToday,
            isSelected: isSelected,
            bgColor: bgColor,
            label: label,
            currentDate: currentDate,
            colorScheme: colorScheme,
          ));
          day++;
          col++;
        }
      }
      rows.add(Row(children: weekCells));
      col = 0;
    }

    return Column(children: rows);
  }

  Widget _buildDayCell({
    required int day,
    required bool isToday,
    required bool isSelected,
    required Color? bgColor,
    required String? label,
    required DateTime currentDate,
    required ColorScheme colorScheme,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () => onDaySelected?.call(currentDate),
        child: Container(
          height: 44,
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: isSelected
                ? colorScheme.primary.withOpacity(0.2)
                : bgColor ?? Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: isToday
                ? Border.all(color: colorScheme.primary, width: 1.5)
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$day',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                  color: bgColor != null ? Colors.white : null,
                ),
              ),
              if (label != null)
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 7,
                    color: bgColor != null ? Colors.white70 : Colors.grey,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
