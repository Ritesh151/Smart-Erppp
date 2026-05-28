// lib/Pages/Reports/stock_statement_screen.dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:SmartERP/core/constants/storage_keys.dart';
import 'package:SmartERP/core/models/product_model.dart';
import 'package:SmartERP/core/utils/currency_formatter.dart';
import 'package:SmartERP/core/widgets/app_scaffold.dart';
import 'package:SmartERP/core/widgets/empty_state_widget.dart';
import 'package:SmartERP/core/widgets/low_stock_badge.dart';

class _StockItem {
  final String name;
  final String? hsnCode;
  final int stock;
  final double price;

  _StockItem({
    required this.name,
    this.hsnCode,
    required this.stock,
    required this.price,
  });
}

class StockStatementScreen extends StatefulWidget {
  const StockStatementScreen({super.key});

  @override
  State<StockStatementScreen> createState() => _StockStatementScreenState();
}

class _StockStatementScreenState extends State<StockStatementScreen> {
  List<_StockItem> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  void _loadProducts() {
    try {
      final data = <_StockItem>[];
      if (Hive.isBoxOpen(StorageKeys.productsBox)) {
        final box = Hive.box(StorageKeys.productsBox);
        for (final key in box.keys) {
          final value = box.get(key);
          if (value is ProductModel) {
            data.add(_StockItem(
              name: value.productName,
              hsnCode: value.hsnCode,
              stock: value.stockQuantity,
              price: value.price,
            ));
          } else if (value is Map) {
            final map = Map<String, dynamic>.from(value as Map);
            data.add(_StockItem(
              name: (map['productName'] ?? map['name'] ?? '') as String,
              hsnCode: (map['hsnCode'] as String?) ?? (map['hsnCode'] as String?),
              stock: ((map['stockQuantity'] as num?) ?? (map['stock'] as num?) ?? 0).toInt(),
              price: ((map['price'] as num?) ?? 0).toDouble(),
            ));
          }
        }
      }
      setState(() {
        _products = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Stock Statement',
      backRoute: '/reports',
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _products.isEmpty
              ? const EmptyStateWidget(
                  icon: Icons.inventory_2_outlined,
                  title: 'No Products',
                  message: 'Add products to view stock statement.',
                )
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    final totalStockValue = _products.fold<double>(
        0, (s, p) => s + (p.stock * p.price));
    final lowStockCount = _products.where((p) => p.stock <= 5).length;

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.teal.shade50,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total Products: ${_products.length}',
                      style: const TextStyle(fontWeight: FontWeight.w500)),
                  Text('Low Stock: $lowStockCount',
                      style: const TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.w500)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Stock Value',
                      style: TextStyle(color: Colors.grey)),
                  Text(CurrencyFormatter.format(totalStockValue),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            itemCount: _products.length,
            separatorBuilder: (_, __) => const SizedBox(height: 4),
            itemBuilder: (ctx, i) {
              final p = _products[i];
              return Card(
                margin: EdgeInsets.zero,
                child: ListTile(
                  title: Text(p.name,
                      style: const TextStyle(fontWeight: FontWeight.w500)),
                  subtitle: Text('HSN: ${p.hsnCode ?? ''}'),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('${p.stock}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold)),
                      if (p.stock <= 5)
                        LowStockBadge(
                            stock: p.stock, isOutOfStock: p.stock == 0)
                      else
                        Text(CurrencyFormatter.format(p.stock * p.price),
                            style: const TextStyle(
                                fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
