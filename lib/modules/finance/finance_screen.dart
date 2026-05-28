import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:SmartERP/core/widgets/app_scaffold.dart';
import 'package:SmartERP/modules/finance/providers/finance_provider.dart';
import 'finance_sales_tab.dart';
import 'finance_purchases_tab.dart';

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
                FinancePurchasesTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _getFloatingActionButton() {
    if (_tabController.index == 0) {
      return FloatingActionButton(
        onPressed: () => context.go('/finance/create-sale'),
        child: const Icon(Icons.add),
      );
    } else {
      return FloatingActionButton(
        onPressed: () => context.go('/purchases/add'),
        child: const Icon(Icons.add),
      );
    }
  }
}
