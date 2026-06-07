import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:siddhivinayak_enterprise/core/widgets/app_scaffold.dart';
import 'package:siddhivinayak_enterprise/modules/finance/providers/finance_provider.dart';
import 'package:siddhivinayak_enterprise/modules/finance/widgets/purchase_tab.dart';
import 'finance_sales_tab.dart';

class FinanceScreen extends StatefulWidget {
  const FinanceScreen({super.key});

  @override
  State<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends State<FinanceScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!mounted) return;
      // Rebuild to update FAB when switching tabs.
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Finance',
      showBackButton: false,
      floatingActionButton: _getFloatingActionButton(),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Sales'),
              Tab(text: 'Purchases'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                FinanceSalesTab(),
                PurchaseTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _getFloatingActionButton() {
    if (_tabController.index == 1) {
      return FloatingActionButton(
        onPressed: () => context.go('/finance/purchases/create'),
        child: const Icon(Icons.add),
      );
    }
    return const SizedBox.shrink();
  }
}
