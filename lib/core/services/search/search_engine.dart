import 'dart:async';

typedef SearchPredicate<T> = bool Function(T item, String query);

class SearchEngine<T> {
  final List<T> _allItems = [];
  List<T> _filteredItems = [];
  String _currentQuery = '';
  Timer? _debounceTimer;
  final Duration debounceDuration;

  final SearchPredicate<T> defaultPredicate;

  List<T> get results =>
      _currentQuery.isEmpty ? List.unmodifiable(_allItems) : List.unmodifiable(_filteredItems);
  String get currentQuery => _currentQuery;
  int get totalCount => _allItems.length;
  int get resultCount => results.length;
  bool get isSearching => _currentQuery.isNotEmpty;

  SearchEngine({
    this.debounceDuration = const Duration(milliseconds: 300),
    required this.defaultPredicate,
  });

  void setItems(List<T> items) {
    _allItems
      ..clear()
      ..addAll(items);
    _applyFilter();
  }

  void addItem(T item) {
    _allItems.add(item);
    _applyFilter();
  }

  void removeItem(T item) {
    _allItems.remove(item);
    _applyFilter();
  }

  void updateItem(T oldItem, T newItem) {
    final index = _allItems.indexOf(oldItem);
    if (index != -1) {
      _allItems[index] = newItem;
      _applyFilter();
    }
  }

  void search(String query) {
    _currentQuery = query.trim();
    _applyFilter();
  }

  void searchDebounced(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(debounceDuration, () {
      search(query);
    });
  }

  void clear() {
    _currentQuery = '';
    _filteredItems = List.from(_allItems);
  }

  void _applyFilter() {
    if (_currentQuery.isEmpty) {
      _filteredItems = List.from(_allItems);
    } else {
      _filteredItems = _allItems
          .where((item) => defaultPredicate(item, _currentQuery.toLowerCase()))
          .toList();
    }
  }

  void dispose() {
    _debounceTimer?.cancel();
  }
}
