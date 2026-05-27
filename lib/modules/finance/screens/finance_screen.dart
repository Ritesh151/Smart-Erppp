import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:smarterp/core/constants/app_constants.dart';
import 'package:smarterp/core/extensions/context_extensions.dart';
import 'package:smarterp/core/extensions/date_extensions.dart';
import 'package:smarterp/core/theme/theme_extensions.dart';
import 'package:smarterp/core/widgets/app_shell.dart';
import 'package:smarterp/core/widgets/app_card.dart';
import 'package:smarterp/core/widgets/dashboard_card.dart';
import 'package:smarterp/core/widgets/app_button.dart';
import 'package:smarterp/core/widgets/empty_state_widget.dart';
import 'package:smarterp/core/models/transaction_model.dart';
import 'package:smarterp/modules/finance/providers/finance_provider.dart';

class FinanceScreen extends StatefulWidget {
  const FinanceScreen({super.key});

  @override
  State<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends State<FinanceScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentPage = 1;
  static const int _pageSize = 10;

  // Active filters
  String _dateRangeLabel = 'All Time';
  TransactionType? _selectedTypeFilter;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _currentPage = 1;
          _selectedTypeFilter = _mapTabIndexToType(_tabController.index);
          context.read<FinanceProvider>().filterByType(_selectedTypeFilter);
        });
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FinanceProvider>().loadTransactions();
    });
  }

  TransactionType? _mapTabIndexToType(int index) {
    switch (index) {
      case 1:
        return TransactionType.sale;
      case 2:
        return TransactionType.purchase;
      case 3:
        return TransactionType.expense;
      case 4:
        return TransactionType.income;
      default:
        return null;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final theme = context.theme;
    final appTheme = context.appTheme;

    return AppShell(
      title: 'Finance Ledger',
      child: Consumer<FinanceProvider>(
        builder: (context, provider, _) {
          final ledger = provider.transactions;
          final summary = provider.summary;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, provider),
                const SizedBox(height: 24),
                _buildSummaryCards(context, summary, appTheme),
                const SizedBox(height: 24),
                if (context.isDesktop)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 6,
                        child: _buildLedgerSection(context, ledger, provider, appTheme),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        flex: 4,
                        child: _buildAnalyticsSection(context, ledger, appTheme),
                      ),
                    ],
                  )
                else
                  Column(
                    children: [
                      _buildAnalyticsSection(context, ledger, appTheme),
                      const SizedBox(height: 24),
                      _buildLedgerSection(context, ledger, provider, appTheme),
                    ],
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, FinanceProvider provider) {
    final theme = context.theme;
    final colorScheme = context.colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Financial Transactions',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Ledger and real-time cashflow analytics.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
        Row(
          children: [
            _buildDateFilterMenu(context, provider),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: () => _showRecordTransactionDialog(context, provider),
              icon: const Icon(Icons.add),
              label: const Text('Record Transaction'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateFilterMenu(BuildContext context, FinanceProvider provider) {
    final colorScheme = context.colorScheme;
    return PopupMenuButton<String>(
      onSelected: (value) {
        final now = DateTime.now();
        setState(() {
          _dateRangeLabel = value;
          _currentPage = 1;
        });

        switch (value) {
          case 'Today':
            provider.filterByDateRange(now.startOfDay, now.endOfDay);
            break;
          case 'This Week':
            final startOfWeek = now.subtract(Duration(days: now.weekday - 1)).startOfDay;
            provider.filterByDateRange(startOfWeek, now.endOfDay);
            break;
          case 'This Month':
            final startOfMonth = DateTime(now.year, now.month, 1).startOfDay;
            provider.filterByDateRange(startOfMonth, now.endOfDay);
            break;
          case 'This Year':
            final startOfYear = DateTime(now.year, 1, 1).startOfDay;
            provider.filterByDateRange(startOfYear, now.endOfDay);
            break;
          default:
            provider.filterByDateRange(null, null);
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'All Time', child: Text('All Time')),
        const PopupMenuItem(value: 'Today', child: Text('Today')),
        const PopupMenuItem(value: 'This Week', child: Text('This Week')),
        const PopupMenuItem(value: 'This Month', child: Text('This Month')),
        const PopupMenuItem(value: 'This Year', child: Text('This Year')),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, size: 16),
            const SizedBox(width: 8),
            Text(_dateRangeLabel, style: const TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_down, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards(
    BuildContext context,
    dynamic summary,
    AppThemeExtension appTheme,
  ) {
    final marginVal = summary.profitMargin;
    final marginLabel = '${marginVal >= 0 ? '+' : ''}${marginVal.toStringAsFixed(1)}% margin';

    return GridView.count(
      crossAxisCount: context.isMobile ? 2 : 4,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: context.isMobile ? 1.2 : 1.4,
      children: [
        DashboardCard(
          title: 'Total Sales',
          value: '₹${summary.totalSales.toStringAsFixed(0)}',
          icon: Icons.trending_up,
          iconColor: appTheme.successColor,
          backgroundColor: appTheme.successColor,
          subtitle: 'Generated invoice values',
        ),
        DashboardCard(
          title: 'Total Purchases',
          value: '₹${summary.totalPurchases.toStringAsFixed(0)}',
          icon: Icons.shopping_cart,
          iconColor: appTheme.warningColor,
          backgroundColor: appTheme.warningColor,
          subtitle: 'Procured inventory asset cost',
        ),
        DashboardCard(
          title: 'Net Revenue',
          value: '₹${summary.totalRevenue.toStringAsFixed(0)}',
          icon: Icons.payments,
          iconColor: appTheme.infoColor,
          backgroundColor: appTheme.infoColor,
          subtitle: 'Gross business cashflow',
        ),
        DashboardCard(
          title: 'Net Profit',
          value: '₹${summary.netProfit.toStringAsFixed(0)}',
          icon: Icons.account_balance_wallet,
          iconColor: summary.netProfit >= 0 ? appTheme.successColor : Colors.red,
          backgroundColor: summary.netProfit >= 0 ? appTheme.successColor : Colors.red,
          subtitle: marginLabel,
        ),
      ],
    );
  }

  Widget _buildLedgerSection(
    BuildContext context,
    List<TransactionModel> list,
    FinanceProvider provider,
    AppThemeExtension appTheme,
  ) {
    final colorScheme = context.colorScheme;
    final theme = context.theme;

    // Tab categories
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: const [
              Tab(text: 'All logs'),
              Tab(text: 'Sales'),
              Tab(text: 'Purchases'),
              Tab(text: 'Expenses'),
              Tab(text: 'Other Income'),
            ],
          ),
          const SizedBox(height: 8),
          provider.isLoading
              ? const Padding(
                  padding: EdgeInsets.all(48.0),
                  child: Center(child: CircularProgressIndicator()),
                )
              : list.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(48.0),
                      child: EmptyStateWidget(
                        icon: Icons.receipt_long,
                        title: 'No Transactions Logged',
                        message: 'Log your first income, expense or sale to populate the ledger.',
                        actionLabel: 'Add Record',
                        onAction: () => _showRecordTransactionDialog(context, provider),
                      ),
                    )
                  : _buildTransactionsList(context, list, provider, appTheme),
        ],
      ),
    );
  }

  Widget _buildTransactionsList(
    BuildContext context,
    List<TransactionModel> list,
    FinanceProvider provider,
    AppThemeExtension appTheme,
  ) {
    final totalItems = list.length;
    final totalPages = (totalItems / _pageSize).ceil();
    final startIdx = (_currentPage - 1) * _pageSize;
    final endIdx = startIdx + _pageSize > totalItems ? totalItems : startIdx + _pageSize;
    final pageList = list.sublist(startIdx, endIdx);

    final colorScheme = context.colorScheme;

    return Column(
      children: [
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: pageList.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final tx = pageList[index];
            final isCredit = tx.type == TransactionType.sale || tx.type == TransactionType.income;
            final color = isCredit ? appTheme.successColor : colorScheme.error;

            return ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              leading: CircleAvatar(
                backgroundColor: color?.withOpacity(0.1),
                child: Icon(
                  isCredit ? Icons.arrow_downward : Icons.arrow_upward,
                  color: color,
                  size: 18,
                ),
              ),
              title: Text(tx.description, style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '${tx.date.toFormattedDate()} | Ref: ${tx.referenceId ?? 'N/A'}',
                  style: TextStyle(fontSize: 12, color: colorScheme.onSurface.withOpacity(0.5)),
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${isCredit ? '+' : '-'}₹${tx.amount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: color,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 18),
                    onPressed: () => _confirmDeleteTransaction(context, tx, provider),
                  ),
                ],
              ),
            );
          },
        ),
        if (totalPages > 1) ...[
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: _currentPage > 1 ? () => setState(() => _currentPage--) : null,
                ),
                Text('Page $_currentPage of $totalPages', style: const TextStyle(fontWeight: FontWeight.w500)),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: _currentPage < totalPages ? () => setState(() => _currentPage++) : null,
                ),
              ],
            ),
          )
        ],
      ],
    );
  }

  Widget _buildAnalyticsSection(
    BuildContext context,
    List<TransactionModel> list,
    AppThemeExtension appTheme,
  ) {
    final colorScheme = context.colorScheme;

    // Expenses breakdown
    final Map<String, double> expenses = {};
    double totalExp = 0;
    for (final tx in list) {
      if (tx.type == TransactionType.expense) {
        final cat = tx.category ?? 'Other';
        expenses[cat] = (expenses[cat] ?? 0.0) + tx.amount;
        totalExp += tx.amount;
      }
    }

    final pieSections = expenses.entries.map((entry) {
      final index = expenses.keys.toList().indexOf(entry.key);
      final colors = [
        colorScheme.primary,
        colorScheme.secondary,
        colorScheme.tertiary,
        appTheme.warningColor ?? Colors.orange,
        Colors.purple,
        Colors.teal,
      ];
      final color = colors[index % colors.length];
      final percent = totalExp > 0 ? (entry.value / totalExp) * 100 : 0.0;

      return PieChartSectionData(
        color: color,
        value: entry.value,
        title: '${percent.toStringAsFixed(0)}%',
        radius: 40,
        titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();

    return Column(
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Expense breakdown',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              if (expenses.isEmpty)
                const SizedBox(
                  height: 150,
                  child: Center(child: Text('No expenses logged in this range')),
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
                  spacing: 12,
                  runSpacing: 6,
                  children: expenses.keys.map((cat) {
                    final index = expenses.keys.toList().indexOf(cat);
                    final colors = [
                      colorScheme.primary,
                      colorScheme.secondary,
                      colorScheme.tertiary,
                      appTheme.warningColor ?? Colors.orange,
                      Colors.purple,
                      Colors.teal,
                    ];
                    final color = colors[index % colors.length];
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(width: 8, height: 8, color: color),
                        const SizedBox(width: 4),
                        Text(cat, style: const TextStyle(fontSize: 11)),
                      ],
                    );
                  }).toList(),
                )
              ]
            ],
          ),
        ),
      ],
    );
  }

  void _showRecordTransactionDialog(BuildContext context, FinanceProvider provider) {
    final formKey = GlobalKey<FormState>();
    final amountController = TextEditingController();
    final descController = TextEditingController();
    final refController = TextEditingController();
    final catController = TextEditingController();

    TransactionType selectedType = TransactionType.expense;
    final List<String> categories = ['Utilities', 'Salary', 'Logistics', 'Procurement', 'Rent', 'Other'];
    String? selectedCategory = categories[0];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Record Transaction'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<TransactionType>(
                    decoration: const InputDecoration(labelText: 'Type'),
                    value: selectedType,
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() => selectedType = val);
                      }
                    },
                    items: const [
                      DropdownMenuItem(value: TransactionType.sale, child: Text('Sale Income')),
                      DropdownMenuItem(value: TransactionType.purchase, child: Text('Purchase Outward')),
                      DropdownMenuItem(value: TransactionType.expense, child: Text('Expense Outward')),
                      DropdownMenuItem(value: TransactionType.income, child: Text('Other Income')),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Amount (₹) *'),
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Amount is required';
                      final d = double.tryParse(val);
                      if (d == null || d <= 0) return 'Must be greater than 0';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: descController,
                    decoration: const InputDecoration(labelText: 'Description *'),
                    validator: (val) => val == null || val.trim().isEmpty ? 'Description is required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: refController,
                    decoration: const InputDecoration(labelText: 'Reference ID (e.g. Bill/Invoice no)'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Category'),
                    value: selectedCategory,
                    onChanged: (val) {
                      setDialogState(() => selectedCategory = val);
                    },
                    items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  try {
                    await provider.addTransaction(
                      type: selectedType,
                      amount: double.parse(amountController.text),
                      date: DateTime.now(),
                      description: descController.text.trim(),
                      referenceId: refController.text.trim().isEmpty ? null : refController.text.trim(),
                      category: selectedCategory,
                    );
                    if (context.mounted) {
                      Navigator.pop(context);
                      context.showSnackBar('Transaction recorded successfully');
                    }
                  } catch (e) {
                    context.showSnackBar('Failed to record transaction: $e', isError: true);
                  }
                }
              },
              child: const Text('Record'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteTransaction(BuildContext context, TransactionModel tx, FinanceProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Ledger Entry?'),
        content: const Text('Are you sure you want to permanently remove this transaction from history? Net profit/loss and sales summaries will be recalculated immediately.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: context.colorScheme.error),
            onPressed: () async {
              try {
                await provider.deleteTransaction(tx.id, tx.type);
                if (context.mounted) {
                  Navigator.pop(context);
                  context.showSnackBar('Transaction deleted');
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                  context.showSnackBar('Failed to delete transaction: $e', isError: true);
                }
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
