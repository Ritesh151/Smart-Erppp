import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:siddhivinayak_enterprise/core/extensions/context_extensions.dart';
import 'package:siddhivinayak_enterprise/core/utils/currency_formatter.dart';
import 'package:siddhivinayak_enterprise/core/utils/date_helper.dart';
import 'package:siddhivinayak_enterprise/modules/finance/providers/purchase_entry_provider.dart';

class _T {
  static const gradientStart = Color(0xFF4F6EF7);
  static const gradientEnd   = Color(0xFF7C3AED);
  static const bg            = Color(0xFFF5F7FA);
  static const white         = Colors.white;
  static const textDark      = Color(0xFF111827);
  static const textMid       = Color(0xFF374151);
  static const textMuted     = Color(0xFF6B7280);
  static const textLight     = Color(0xFF9CA3AF);
  static const divider       = Color(0xFFE5E7EB);
  static const success       = Color(0xFF10B981);
  static const warning       = Color(0xFFF59E0B);
  static const danger        = Color(0xFFEF4444);
  static const info          = Color(0xFF3B82F6);

  static const Gradient brandGradient = LinearGradient(
    colors: [gradientStart, gradientEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class PurchaseTab extends StatefulWidget {
  const PurchaseTab({super.key});

  @override
  State<PurchaseTab> createState() => _PurchaseTabState();
}

class _PurchaseTabState extends State<PurchaseTab> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String? _statusFilter;
  String? _dateFilter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PurchaseEntryProvider>().loadPurchases();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _filteredPurchases(List<Map<String, dynamic>> purchases) {
    var filtered = purchases;

    if (_searchQuery.isNotEmpty) {
      final lower = _searchQuery.toLowerCase();
      filtered = filtered.where((p) {
        final number = (p['purchaseNumber'] as String? ?? '').toLowerCase();
        final supplier = (p['supplierName'] as String? ?? '').toLowerCase();
        return number.contains(lower) || supplier.contains(lower);
      }).toList();
    }

    if (_statusFilter != null) {
      filtered = filtered.where((p) => (p['status'] as String?) == _statusFilter).toList();
    }

    if (_dateFilter != null) {
      final now = DateTime.now();
      filtered = filtered.where((p) {
        final date = DateTime.tryParse(p['purchaseDate'] as String? ?? '');
        if (date == null) return false;
        switch (_dateFilter) {
          case 'today':
            return date.day == now.day && date.month == now.month && date.year == now.year;
          case 'week':
            final weekStart = now.subtract(Duration(days: now.weekday - 1));
            return !date.isBefore(weekStart) && !date.isAfter(now);
          case 'month':
            return date.month == now.month && date.year == now.year;
          default:
            return true;
        }
      }).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final pad = context.isMobile ? 16.0 : 24.0;
    final gap = context.isMobile ? 16.0 : 20.0;

    return Container(
      color: _T.bg,
      child: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(pad),
            _buildSearchFilterBar(pad),
            Expanded(child: _buildPurchaseList(gap)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(double pad) {
    return Padding(
      padding: EdgeInsets.fromLTRB(pad, 12, pad, 0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Purchases',
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width < 600 ? 20 : 22,
                    fontWeight: FontWeight.w800,
                    color: _T.textDark,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'View and manage all purchase orders',
                  style: const TextStyle(fontSize: 12, color: _T.textMuted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _GradientButton(
            label: 'New Purchase',
            icon: Icons.add_rounded,
            onTap: () => context.push('/finance/purchases/create'),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchFilterBar(double pad) {
    return Padding(
      padding: EdgeInsets.fromLTRB(pad, 12, pad, 0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: _T.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _T.divider),
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by purchase number, supplier...',
                      hintStyle: const TextStyle(fontSize: 13, color: _T.textLight),
                      prefixIcon: const Icon(Icons.search_rounded, size: 20, color: _T.textMuted),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    onChanged: (v) => setState(() => _searchQuery = v),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _FilterChip(
                label: _statusFilter ?? 'Status',
                icon: Icons.filter_list_rounded,
                onTap: () => _showStatusFilter(),
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: _dateFilter ?? 'Date',
                icon: Icons.date_range_rounded,
                onTap: () => _showDateFilter(),
              ),
              if (_statusFilter != null || _dateFilter != null || _searchQuery.isNotEmpty) ...[
                const SizedBox(width: 8),
                InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => setState(() {
                    _statusFilter = null;
                    _dateFilter = null;
                    _searchQuery = '';
                    _searchController.clear();
                  }),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _T.danger.withOpacity(0.07),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.clear_all_rounded, size: 18, color: _T.danger),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  void _showStatusFilter() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const Text('Filter by Status',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: _T.textDark)),
                  const Spacer(),
                  InkWell(
                    onTap: () => Navigator.pop(ctx),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: _T.divider.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.close_rounded, size: 18, color: _T.textMuted),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: _T.divider),
            ...[
              null,
              'draft',
              'ordered',
              'received',
              'cancelled',
            ].map((status) => ListTile(
              title: Text(
                status == null ? 'All' : status[0].toUpperCase() + status.substring(1),
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              trailing: _statusFilter == status
                  ? const Icon(Icons.check_circle_rounded, color: _T.success, size: 20)
                  : null,
              onTap: () {
                setState(() => _statusFilter = status);
                Navigator.pop(ctx);
              },
            )),
          ],
        ),
      ),
    );
  }

  void _showDateFilter() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const Text('Filter by Date',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: _T.textDark)),
                  const Spacer(),
                  InkWell(
                    onTap: () => Navigator.pop(ctx),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: _T.divider.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.close_rounded, size: 18, color: _T.textMuted),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: _T.divider),
            ...[
              null,
              'today',
              'week',
              'month',
            ].map((filter) => ListTile(
              title: Text(
                filter == null ? 'All' : filter == 'today' ? 'Today' : filter == 'week' ? 'This Week' : 'This Month',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              trailing: _dateFilter == filter
                  ? const Icon(Icons.check_circle_rounded, color: _T.success, size: 20)
                  : null,
              onTap: () {
                setState(() => _dateFilter = filter);
                Navigator.pop(ctx);
              },
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildPurchaseList(double gap) {
    return Consumer<PurchaseEntryProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final purchases = _filteredPurchases(provider.purchases);

        if (purchases.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.shopping_cart_outlined, size: 64, color: _T.textLight.withOpacity(0.4)),
                const SizedBox(height: 16),
                const Text('No purchases found',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _T.textMuted)),
                const SizedBox(height: 8),
                const Text('Create a new purchase to get started',
                    style: TextStyle(fontSize: 13, color: _T.textLight)),
                const SizedBox(height: 20),
                _GradientButton(
                  label: 'Create Purchase',
                  icon: Icons.add_rounded,
                  onTap: () => context.push('/finance/purchases/create'),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(gap / 2),
          itemCount: purchases.length,
          itemBuilder: (context, index) {
            final purchase = purchases[index];
            return _PurchaseCard(
              purchase: purchase,
              onTap: () => context.push('/finance/purchases/${purchase['id']}'),
              onEdit: () => context.push('/finance/purchases/${purchase['id']}/edit'),
              onDelete: () => _confirmDelete(context, purchase),
            ).animate().fadeIn(duration: 250.ms).slideY(begin: 0.04, end: 0);
          },
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, Map<String, dynamic> purchase) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Purchase', style: TextStyle(fontWeight: FontWeight.w800)),
        content: Text('Are you sure you want to delete purchase ${purchase['purchaseNumber']}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<PurchaseEntryProvider>().deletePurchase(purchase['id'] as String);
            },
            style: TextButton.styleFrom(foregroundColor: _T.danger),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _PurchaseCard extends StatelessWidget {
  final Map<String, dynamic> purchase;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _PurchaseCard({
    required this.purchase,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  Color _statusColor(String? status) {
    switch (status) {
      case 'draft': return _T.warning;
      case 'ordered': return _T.info;
      case 'received': return _T.success;
      case 'cancelled': return _T.danger;
      default: return _T.textMuted;
    }
  }

  String _statusLabel(String? status) {
    switch (status) {
      case 'draft': return 'Draft';
      case 'ordered': return 'Ordered';
      case 'received': return 'Received';
      case 'cancelled': return 'Cancelled';
      default: return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    final date = DateTime.tryParse(purchase['purchaseDate'] as String? ?? '');
    final items = purchase['items'] as List<dynamic>? ?? [];
    final totalAmount = (purchase['totalAmount'] as num?)?.toDouble() ?? 0;
    final status = purchase['status'] as String?;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      color: _T.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: _T.brandGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.shopping_cart_rounded, color: _T.white, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          purchase['purchaseNumber'] as String? ?? '',
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: _T.textDark),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          purchase['supplierName'] as String? ?? '',
                          style: const TextStyle(fontSize: 13, color: _T.textMuted),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: _statusColor(status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _statusLabel(status),
                      style: TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w700,
                        color: _statusColor(status),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Icon(Icons.calendar_today_rounded, size: 14, color: _T.textLight),
                  const SizedBox(width: 6),
                  Text(
                    date != null ? DateHelper.display(date) : '-',
                    style: const TextStyle(fontSize: 12, color: _T.textMuted),
                  ),
                  const SizedBox(width: 20),
                  Icon(Icons.inventory_2_rounded, size: 14, color: _T.textLight),
                  const SizedBox(width: 6),
                  Text(
                    '${items.length} items',
                    style: const TextStyle(fontSize: 12, color: _T.textMuted),
                  ),
                  const Spacer(),
                  Text(
                    CurrencyFormatter.format(totalAmount),
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: _T.textDark),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _ActionChip(
                    icon: Icons.edit_outlined,
                    label: 'Edit',
                    color: _T.info,
                    onTap: onEdit,
                  ),
                  const SizedBox(width: 8),
                  _ActionChip(
                    icon: Icons.delete_outline_rounded,
                    label: 'Delete',
                    color: _T.danger,
                    onTap: onDelete,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.07),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.15)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
          ],
        ),
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _GradientButton({required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: _T.brandGradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: _T.gradientStart.withOpacity(0.25),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: _T.white, size: 17),
                const SizedBox(width: 6),
                Text(label, style: const TextStyle(color: _T.white, fontWeight: FontWeight.w700, fontSize: 12)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: _T.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _T.divider),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: _T.textMuted),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _T.textDark)),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_down_rounded, size: 16, color: _T.textMuted),
          ],
        ),
      ),
    );
  }
}
