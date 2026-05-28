import 'dart:async';
import 'package:flutter/material.dart';
import 'package:SmartERP/core/constants/app_constants.dart';
import 'package:SmartERP/core/extensions/context_extensions.dart';

class SearchFilterBar extends StatefulWidget {
  final String hintText;
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearAll;
  
  final List<Map<String, dynamic>>? statusOptions;
  final String? selectedStatus;
  final ValueChanged<String?>? onStatusChanged;
  
  final List<Map<String, dynamic>>? sortOptions;
  final Map<String, dynamic>? selectedSort;
  final Function(Map<String, dynamic>)? onSortChanged;

  const SearchFilterBar({
    super.key,
    required this.hintText,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.onClearAll,
    this.statusOptions,
    this.selectedStatus,
    this.onStatusChanged,
    this.sortOptions,
    this.selectedSort,
    this.onSortChanged,
  });

  @override
  State<SearchFilterBar> createState() => _SearchFilterBarState();
}

class _SearchFilterBarState extends State<SearchFilterBar> {
  late TextEditingController _controller;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.searchQuery);
  }

  @override
  void didUpdateWidget(covariant SearchFilterBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.searchQuery != _controller.text) {
      _controller.text = widget.searchQuery;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onTextChanged(String text) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      widget.onSearchChanged(text);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final theme = context.theme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
        border: Border.all(color: colorScheme.outlineVariant, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  onChanged: _onTextChanged,
                  decoration: InputDecoration(
                    hintText: widget.hintText,
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: _controller.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _controller.clear();
                              widget.onSearchChanged('');
                            },
                          )
                        : null,
                     border: OutlineInputBorder(
                       borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                       borderSide: BorderSide(color: colorScheme.outlineVariant),
                     ),
                     enabledBorder: OutlineInputBorder(
                       borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                       borderSide: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.5)),
                     ),
                     focusedBorder: OutlineInputBorder(
                       borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                       borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
                     ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
              if (widget.sortOptions != null && widget.onSortChanged != null && widget.selectedSort != null) ...[
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                    border: Border.all(color: colorScheme.outlineVariant),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<Map<String, dynamic>>(
                      value: widget.selectedSort,
                      icon: const Icon(Icons.sort, size: 20),
                      onChanged: (val) {
                        if (val != null) widget.onSortChanged!(val);
                      },
                      items: widget.sortOptions!.map((opt) {
                        return DropdownMenuItem<Map<String, dynamic>>(
                          value: opt,
                          child: Text(
                            opt['label'] as String,
                            style: const TextStyle(fontSize: 14),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ],
          ),
          if (widget.statusOptions != null) ...[
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  if (widget.statusOptions != null && widget.onStatusChanged != null)
                    ...widget.statusOptions!.map((opt) {
                      final isSelected = widget.selectedStatus == opt['value'];
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: FilterChip(
                          label: Text(
                            opt['label'] as String,
                            style: TextStyle(
                              fontSize: 11,
                              color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          selected: isSelected,
                          onSelected: (selected) {
                            widget.onStatusChanged!(selected ? (opt['value'] as String) : null);
                          },
                          selectedColor: colorScheme.primary,
                          backgroundColor: colorScheme.surface,
                          checkmarkColor: colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
                            side: BorderSide(
                              color: isSelected ? colorScheme.primary : colorScheme.outlineVariant,
                              width: 0.5,
                            ),
                          ),
                        ),
                      );
                    }),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: widget.onClearAll,
                    icon: const Icon(Icons.filter_alt_off, size: 14),
                    label: const Text('Clear Filters', style: TextStyle(fontSize: 11)),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  )
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
