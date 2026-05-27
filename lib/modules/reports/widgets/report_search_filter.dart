import 'package:flutter/material.dart';
import 'package:smarterp/core/models/report_enums.dart';
import 'package:smarterp/core/widgets/app_card.dart';

class ReportSearchFilter extends StatefulWidget {
  final ReportType? selectedType;
  final int selectedMonth;
  final int selectedYear;
  final ValueChanged<ReportType?> onTypeChanged;
  final ValueChanged<int> onMonthChanged;
  final ValueChanged<int> onYearChanged;
  final String? searchQuery;
  final ValueChanged<String>? onSearchChanged;
  final VoidCallback? onApply;

  const ReportSearchFilter({
    super.key,
    this.selectedType,
    required this.selectedMonth,
    required this.selectedYear,
    required this.onTypeChanged,
    required this.onMonthChanged,
    required this.onYearChanged,
    this.searchQuery,
    this.onSearchChanged,
    this.onApply,
  });

  @override
  State<ReportSearchFilter> createState() => _ReportSearchFilterState();
}

class _ReportSearchFilterState extends State<ReportSearchFilter> {
  bool _expanded = false;
  late TextEditingController _searchCtrl;

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController(text: widget.searchQuery ?? '');
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  const Icon(Icons.filter_list, size: 18),
                  const SizedBox(width: 8),
                  Text('Filters & Search',
                    style: TextStyle(fontWeight: FontWeight.w600, color: theme.colorScheme.primary)),
                  const Spacer(),
                  Icon(_expanded ? Icons.expand_less : Icons.expand_more, size: 18),
                ],
              ),
            ),
          ),
          if (_expanded) ...[
            const Divider(height: 1),
            const SizedBox(height: 12),
            if (widget.onSearchChanged != null)
              TextField(
                controller: _searchCtrl,
                decoration: InputDecoration(
                  hintText: 'Search reports...',
                  prefixIcon: const Icon(Icons.search, size: 18),
                  suffixIcon: _searchCtrl.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 16),
                          onPressed: () {
                            _searchCtrl.clear();
                            widget.onSearchChanged?.call('');
                          },
                        )
                      : null,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onChanged: widget.onSearchChanged,
              ),
            if (widget.onSearchChanged != null) const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<ReportType>(
                    value: widget.selectedType,
                    decoration: const InputDecoration(
                      labelText: 'Report Type',
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('All Types')),
                      ...ReportType.values.map((t) =>
                        DropdownMenuItem(value: t, child: Text(t.name)),
                      ),
                    ],
                    onChanged: (v) => widget.onTypeChanged(v),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 80,
                  child: TextFormField(
                    initialValue: '${widget.selectedMonth}',
                    decoration: const InputDecoration(
                      labelText: 'Month',
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (v) {
                      final m = int.tryParse(v);
                      if (m != null && m >= 1 && m <= 12) widget.onMonthChanged(m);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 90,
                  child: TextFormField(
                    initialValue: '${widget.selectedYear}',
                    decoration: const InputDecoration(
                      labelText: 'Year',
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (v) {
                      final y = int.tryParse(v);
                      if (y != null && y >= 2020) widget.onYearChanged(y);
                    },
                  ),
                ),
              ],
            ),
            if (widget.onApply != null) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton(onPressed: widget.onApply, child: const Text('Apply')),
              ),
            ],
          ],
        ],
      ),
    );
  }
}
