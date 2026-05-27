extension StringExtensions on String {
  bool get isValidEmail {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(this);
  }

  bool get isNotNullOrEmpty => isNotEmpty;

  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  String get capitalizeWords {
    if (isEmpty) return this;
    return split(' ').map((word) => word.capitalize).join(' ');
  }

  String truncate(int maxLength, {String suffix = '...'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}$suffix';
  }

  bool containsIgnoreCase(String other) {
    return toLowerCase().contains(other.toLowerCase());
  }

  String removeWhitespace() {
    return replaceAll(RegExp(r'\s+'), '');
  }
}

extension NullableStringExtensions on String? {
  bool get isNullOrEmpty => this == null || this!.isEmpty;

  bool get isNotNullOrEmpty => !isNullOrEmpty;

  String get orEmpty => this ?? '';
}
