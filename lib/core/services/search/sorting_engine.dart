typedef SortComparator<T> = int Function(T a, T b);

class SortOption<T> {
  final String label;
  final String key;
  final SortComparator<T> comparator;
  final bool defaultAscending;

  const SortOption({
    required this.label,
    required this.key,
    required this.comparator,
    this.defaultAscending = true,
  });
}

class SortingEngine<T> {
  SortOption<T>? _currentOption;
  bool _ascending = true;

  SortOption<T>? get currentOption => _currentOption;
  bool get isAscending => _ascending;
  bool get hasActiveSort => _currentOption != null;

  void sortBy(SortOption<T> option) {
    if (_currentOption?.key == option.key) {
      _ascending = !_ascending;
    } else {
      _currentOption = option;
      _ascending = option.defaultAscending;
    }
  }

  void setSort(SortOption<T> option, bool ascending) {
    _currentOption = option;
    _ascending = ascending;
  }

  void toggleDirection() {
    _ascending = !_ascending;
  }

  void clear() {
    _currentOption = null;
    _ascending = true;
  }

  List<T> apply(List<T> items) {
    if (_currentOption == null) return List.from(items);

    final sorted = List<T>.from(items);
    sorted.sort((a, b) {
      final result = _currentOption!.comparator(a, b);
      return _ascending ? result : -result;
    });
    return sorted;
  }
}
