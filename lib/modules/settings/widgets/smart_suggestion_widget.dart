import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:SmartERP/modules/settings/services/app_intelligence_service.dart';

class SmartSuggestionWidget extends StatefulWidget {
  final int maxSuggestions;
  final VoidCallback? onNavigate;

  const SmartSuggestionWidget({
    super.key,
    this.maxSuggestions = 3,
    this.onNavigate,
  });

  @override
  State<SmartSuggestionWidget> createState() => _SmartSuggestionWidgetState();
}

class _SmartSuggestionWidgetState extends State<SmartSuggestionWidget> {
  List<BusinessInsight> _insights = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final service = context.read<AppIntelligenceService>();
    final insights = await service.getInsights();
    if (mounted) {
      setState(() {
        _insights = insights.where((i) => !i.isPositive).take(widget.maxSuggestions).toList();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const SizedBox(
        height: 80,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    if (_insights.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 24, bottom: 8),
          child: Row(
            children: [
              Icon(Icons.lightbulb_outline, size: 16, color: theme.colorScheme.primary),
              const SizedBox(width: 6),
              Text('Smart Suggestions',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
        ...List.generate(_insights.length, (i) {
          final insight = _insights[i];
          return _SuggestionTile(insight: insight, index: i, onNavigate: widget.onNavigate);
        }),
      ],
    );
  }
}

class _SuggestionTile extends StatelessWidget {
  final BusinessInsight insight;
  final int index;
  final VoidCallback? onNavigate;

  const _SuggestionTile({
    required this.insight,
    required this.index,
    this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        left: 24, right: 24, bottom: index < 2 ? 8 : 0,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: _bgColor(theme).withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _bgColor(theme).withOpacity(0.15)),
        ),
        child: ListTile(
          dense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          leading: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: _bgColor(theme).withOpacity(0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(_icon, size: 16, color: _bgColor(theme)),
          ),
          title: Text(insight.title, style: TextStyle(
            fontSize: 12, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface,
          )),
          subtitle: Text(insight.description, style: TextStyle(
            fontSize: 11, color: theme.colorScheme.onSurface.withOpacity(0.6),
          )),
          trailing: onNavigate != null
              ? Icon(Icons.chevron_right, size: 16, color: theme.colorScheme.onSurface.withOpacity(0.3))
              : null,
          onTap: onNavigate,
        ),
      ),
    ).animate().fadeIn(
      delay: (index * 80).ms,
      duration: 300.ms,
    ).slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic);
  }

  IconData get _icon {
    switch (insight.category) {
      case InsightCategory.inventory:
        return Icons.inventory_2;
      case InsightCategory.revenue:
        return Icons.trending_up;
      case InsightCategory.customers:
        return Icons.people;
      case InsightCategory.transport:
        return Icons.local_shipping;
      case InsightCategory.employees:
        return Icons.badge;
      case InsightCategory.general:
        return Icons.info_outline;
    }
  }

  Color _bgColor(ThemeData theme) {
    return insight.isPositive ? Colors.green : Colors.orange;
  }
}
