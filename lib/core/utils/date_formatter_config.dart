class DateFormatterConfig {
  static String _format = 'dd/MM/yyyy';

  static String get format => _format;

  static void setFormat(String format) {
    _format = format;
  }

  static String toDateFormatPattern() {
    switch (_format) {
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
}
