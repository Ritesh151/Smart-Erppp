import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:smarterp/core/extensions/context_extensions.dart';
import 'package:smarterp/core/widgets/app_card.dart';
import 'package:smarterp/core/theme/theme_extensions.dart';
import 'package:smarterp/core/models/product_model.dart';

class InventoryChart extends StatelessWidget {
  final List<ProductModel> products;

  const InventoryChart({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final appTheme = context.appTheme;

    final Map<String, double> categoryValues = {};
    double totalVal = 0.0;
    for (final p in products) {
      final val = p.price * p.stockQuantity;
      categoryValues[p.category] =
          (categoryValues[p.category] ?? 0.0) + val;
      totalVal += val;
    }

    final pieSections = categoryValues.entries.map((entry) {
      final idx = categoryValues.keys.toList().indexOf(entry.key);
      final colors = [
        colorScheme.primary,
        colorScheme.secondary,
        colorScheme.tertiary,
        appTheme.warningColor ?? Colors.orange,
        Colors.purple,
        Colors.teal,
      ];
      final color = colors[idx % colors.length];
      final percent =
          totalVal > 0 ? (entry.value / totalVal) * 100 : 0.0;

      return PieChartSectionData(
        color: color,
        value: entry.value,
        title: '${percent.toStringAsFixed(0)}%',
        radius: 40,
        titleStyle: const TextStyle(
            fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Inventory Distribution (Asset Value)',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Asset share percentage per material type',
            style: TextStyle(
              fontSize: 11,
              color: colorScheme.onSurface.withOpacity(0.4),
            ),
          ),
          const SizedBox(height: 24),
          if (categoryValues.isEmpty)
            SizedBox(
              height: 150,
              child: Center(
                  child: Text('No product assets in inventory.',
                      style: TextStyle(
                          color: colorScheme.onSurface.withOpacity(0.5)))),
            )
          else ...[
            SizedBox(
              height: 150,
              child: PieChart(
                PieChartData(
                  sections: pieSections,
                  centerSpaceRadius: 30,
                  sectionsSpace: 2,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: categoryValues.keys.map((cat) {
                final idx = categoryValues.keys.toList().indexOf(cat);
                final colors = [
                  colorScheme.primary,
                  colorScheme.secondary,
                  colorScheme.tertiary,
                  appTheme.warningColor ?? Colors.orange,
                  Colors.purple,
                  Colors.teal,
                ];
                final color = colors[idx % colors.length];
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 8, height: 8, color: color),
                    const SizedBox(width: 4),
                    Text(cat, style: const TextStyle(fontSize: 10)),
                  ],
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}
