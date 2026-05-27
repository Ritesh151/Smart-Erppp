typedef FilterPredicate<T> = bool Function(T item);

class FilterOption<T> {
  final String label;
  final String key;
  final dynamic value;
  final FilterPredicate<T>? predicate;

  const FilterOption({
    required this.label,
    required this.key,
    this.value,
    this.predicate,
  });
}

class FilterEngine<T> {
  final Map<String, FilterOption<T>> _activeFilters = {};
  FilterPredicate<T>? _additionalPredicate;

  Map<String, FilterOption<T>> get activeFilters =>
      Map.unmodifiable(_activeFilters);
  bool get hasActiveFilters => _activeFilters.isNotEmpty;
  int get filterCount => _activeFilters.length;

  void applyFilter(FilterOption<T> option) {
    _activeFilters[option.key] = option;
  }

  void removeFilter(String key) {
    _activeFilters.remove(key);
  }

  void toggleFilter(FilterOption<T> option) {
    if (_activeFilters.containsKey(option.key)) {
      _activeFilters.remove(option.key);
    } else {
      _activeFilters[option.key] = option;
    }
  }

  void setAdditionalPredicate(FilterPredicate<T>? predicate) {
    _additionalPredicate = predicate;
  }

  List<T> apply(List<T> items) {
    if (!hasActiveFilters && _additionalPredicate == null) {
      return List.from(items);
    }

    return items.where((item) {
      for (final filter in _activeFilters.values) {
        if (filter.predicate != null && !filter.predicate!(item)) {
          return false;
        }
      }
      if (_additionalPredicate != null && !_additionalPredicate!(item)) {
        return false;
      }
      return true;
    }).toList();
  }

  void clearAll() {
    _activeFilters.clear();
    _additionalPredicate = null;
  }

  void clearFilter(String key) {
    _activeFilters.remove(key);
  }
}
