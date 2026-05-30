import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:SmartERP/core/utils/date_formatter_config.dart';
import 'package:SmartERP/core/utils/logger.dart';
import 'package:SmartERP/modules/settings/services/settings_service.dart';

class DateFormatService extends ChangeNotifier {
  final SettingsService _settingsService;
  String _currentFormat = 'dd/MM/yyyy';
  bool _initialized = false;

  DateFormatService({required SettingsService settingsService})
      : _settingsService = settingsService;

  String get currentFormat => _currentFormat;
  bool get isInitialized => _initialized;

  Future<void> initialize() async {
    try {
      _currentFormat = await _settingsService.getDateFormat();
      DateFormatterConfig.setFormat(_currentFormat);
      _initialized = true;
      Logger.info('DateFormatService initialized: $_currentFormat');
    } catch (e, stackTrace) {
      _initialized = true;
      Logger.error('Failed to initialize DateFormatService', e, stackTrace);
    }
  }

  Future<void> setFormat(String format) async {
    if (!_isValidFormat(format)) {
      Logger.warning('Invalid date format: $format');
      return;
    }
    _currentFormat = format;
    DateFormatterConfig.setFormat(format);
    await _settingsService.updateDateFormat(format);
    Logger.info('Date format changed to: $format');
    notifyListeners();
  }

  String format(DateTime date) {
    try {
      final formatter = DateFormat(_toDateFormatPattern(_currentFormat));
      return formatter.format(date);
    } catch (e) {
      return _fallbackFormat(date);
    }
  }

  String formatWithTime(DateTime date) {
    try {
      final formatter = DateFormat('${_toDateFormatPattern(_currentFormat)} HH:mm');
      return formatter.format(date);
    } catch (e) {
      return _fallbackFormat(date);
    }
  }

  String formatMonthYear(int month, int year) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${months[month - 1]} $year';
  }

  String formatShort(DateTime date) {
    try {
      final formatter = DateFormat(_toDateFormatPattern(_currentFormat));
      return formatter.format(date);
    } catch (e) {
      return _fallbackFormat(date);
    }
  }

  String formatForDisplay(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return format(date);
  }

  String formatInvoiceDate(DateTime date) => format(date);
  String formatTransportDate(DateTime date) => format(date);
  String formatReportDate(DateTime date) => format(date);
  String formatPayrollDate(DateTime date) => format(date);
  String formatExpenseDate(DateTime date) => format(date);
  String formatDashboardDate(DateTime date) => format(date);

  DateTime? parse(String dateString) {
    try {
      final formatter = DateFormat(_toDateFormatPattern(_currentFormat));
      return formatter.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  String getDateFormatPattern() => _currentFormat;

  List<String> getAvailableFormats() => [
    'dd/MM/yyyy',
    'MM/dd/yyyy',
    'yyyy-MM-dd',
  ];

  List<String> getFormatExamples() => [
    format(DateTime.now()),
    '25 Dec 2024',
    'December 25, 2024',
  ];

  String getFormatDescription(String format) {
    switch (format) {
      case 'dd/MM/yyyy':
        return 'Day/Month/Year';
      case 'MM/dd/yyyy':
        return 'Month/Day/Year';
      case 'yyyy-MM-dd':
        return 'Year-Month-Day';
      default:
        return format;
    }
  }

  String _toDateFormatPattern(String format) {
    switch (format) {
      case 'dd/MM/yyyy':
        return 'dd/MM/yyyy';
      case 'MM/dd/yyyy':
        return 'MM/dd/yyyy';
      case 'yyyy-MM-dd':
        return 'yyyy-MM-dd';
      default:
        return 'dd/MM/yyyy';
    }
  }

  bool _isValidFormat(String format) {
    return getAvailableFormats().contains(format);
  }

  String _fallbackFormat(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}
