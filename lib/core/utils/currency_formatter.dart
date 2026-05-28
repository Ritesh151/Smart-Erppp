import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final NumberFormat _formatter =
      NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2);
  static final NumberFormat _compact =
      NumberFormat.compactSimpleCurrency(locale: 'en_IN', name: 'INR');

  static String format(double? amount) {
    if (amount == null || amount == 0) return '₹0.00';
    return _formatter.format(amount);
  }

  static String compact(double? amount) {
    if (amount == null || amount == 0) return '₹0';
    return _compact.format(amount);
  }
}
