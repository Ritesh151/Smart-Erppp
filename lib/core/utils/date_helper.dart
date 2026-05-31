import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:siddhivinayak_enterprise/core/utils/date_formatter_config.dart';

class DateHelper {
  static final DateFormat _monthYearFormat = DateFormat('MMMM yyyy');
  static final DateFormat _monthKeyFormat = DateFormat('yyyy-MM');

  static String display(DateTime? date) {
    if (date == null) return '';
    final pattern = DateFormatterConfig.toDateFormatPattern();
    return DateFormat(pattern).format(date);
  }

  static String monthYear(DateTime? date) {
    if (date == null) return '';
    return _monthYearFormat.format(date);
  }

  static DateTimeRange currentMonth() {
    final now = DateTime.now();
    final first = DateTime(now.year, now.month, 1);
    final last = DateTime(now.year, now.month + 1, 0);
    return DateTimeRange(start: first, end: last);
  }

  static bool isInRange(DateTime date, DateTimeRange range) {
    return !date.isBefore(range.start) && !date.isAfter(range.end);
  }

  static String displayDateTime(DateTime? date) {
    if (date == null) return '';
    final pattern = DateFormatterConfig.toDateFormatPattern();
    return DateFormat('$pattern HH:mm').format(date);
  }

  static String firestoreKey(DateTime date) {
    return _monthKeyFormat.format(date);
  }
}
