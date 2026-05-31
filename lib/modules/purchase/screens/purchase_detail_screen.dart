import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:siddhivinayak_enterprise/core/extensions/context_extensions.dart';
import 'package:siddhivinayak_enterprise/core/utils/currency_formatter.dart';
import 'package:siddhivinayak_enterprise/core/utils/date_helper.dart';
import 'package:siddhivinayak_enterprise/modules/purchase/providers/purchase_entry_provider.dart';
import 'package:siddhivinayak_enterprise/modules/purchase/services/purchase_pdf_service.dart';

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

class PurchaseDetailScreen extends StatefulWidget {
  final String purchaseId;
  const PurchaseDetailScreen({super.key, required this.purchaseId});

  @override
  State<PurchaseDetailScreen> createState() => _PurchaseDetailScreenState();
}

class _PurchaseDetailScreenState extends State<PurchaseDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PurchaseEntryProvider>().loadPurchaseById(widget.purchaseId);
    });
  }

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
    final pad = context.isMobile ? 16.0 : 24.0;
    final gap = context.isMobile ? 16.0 : 20.0;

    return Container(
      color: _T.bg,
      child: SafeArea(
        child: Consumer<PurchaseEntryProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final purchase = provider.selectedPurchase;
            if (purchase == null) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline_rounded, size: 48, color: _T.textLight),
                    const SizedBox(height: 16),
                    const Text('Purchase not found',
                        style: TextStyle(fontSize: 16, color: _T.textMuted)),
                    const SizedBox(height: 20),
                    _GradientButton(
                      label: 'Go Back',
                      icon: Icons.arrow_back_rounded,
                      onTap: () => context.pop(),
                    ),
                  ],
                ),
              );
            }

            final items = purchase['items'] as List<dynamic>? ?? [];
            final status = purchase['status'] as String? ?? 'draft';
            final date = DateTime.tryParse(purchase['purchaseDate'] as String? ?? '');
            final invoiceDate = DateTime.tryParse(purchase['invoiceDate'] as String? ?? '');
            final subtotal = (purchase['subtotal'] as num?)?.toDouble() ?? 0;
            final gstAmount = (purchase['gstAmount'] as num?)?.toDouble() ?? 0;
            final discountAmount = (purchase['discountAmount'] as num?)?.toDouble() ?? 0;
            final totalAmount = (purchase['totalAmount'] as num?)?.toDouble() ?? 0;

            return SingleChildScrollView(
              padding: EdgeInsets.all(pad),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, purchase, status),
                  SizedBox(height: gap),
                  if (context.isDesktop)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 5, child: _buildInfoCard(purchase, date, invoiceDate)),
                        const SizedBox(width: 24),
                        Expanded(flex: 7, child: Column(
                          children: [
                            _buildItemsCard(items),
                            SizedBox(height: gap),
                            _buildTotalsCard(subtotal, gstAmount, discountAmount, totalAmount),
                            SizedBox(height: gap),
                            _buildActionsCard(provider, status),
                          ],
                        )),
                      ],
                    )
                  else
                    Column(
                      children: [
                        _buildInfoCard(purchase, date, invoiceDate),
                        SizedBox(height: gap),
                        _buildItemsCard(items),
                        SizedBox(height: gap),
                        _buildTotalsCard(subtotal, gstAmount, discountAmount, totalAmount),
                        SizedBox(height: gap),
                        _buildActionsCard(provider, status),
                      ],
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Map<String, dynamic> purchase, String status) {
    return Row(
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => context.pop(),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _T.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _T.divider),
            ),
            child: const Icon(Icons.arrow_back_rounded, size: 18, color: _T.textDark),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                purchase['purchaseNumber'] as String? ?? '',
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 22, color: _T.textDark, letterSpacing: -0.5),
              ),
              const SizedBox(height: 4),
              Text(
                'Purchase from ${purchase['supplierName'] as String? ?? ''}',
                style: const TextStyle(fontSize: 13, color: _T.textMuted),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: _statusColor(status).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            _statusLabel(status),
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _statusColor(status)),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(Map<String, dynamic> purchase, DateTime? date, DateTime? invoiceDate) {
    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(title: 'Purchase Details', icon: Icons.info_outline_rounded),
          const SizedBox(height: 20),
          _InfoRow(label: 'Purchase Date', value: date != null ? DateHelper.display(date) : '-'),
          const SizedBox(height: 10),
          _InfoRow(label: 'Supplier Name', value: purchase['supplierName'] as String? ?? '-'),
          const SizedBox(height: 10),
          _InfoRow(label: 'Mobile', value: purchase['supplierMobile'] as String? ?? '-'),
          const SizedBox(height: 10),
          _InfoRow(label: 'GST Number', value: purchase['supplierGst'] as String? ?? '-'),
          const SizedBox(height: 10),
          const Divider(height: 1, color: _T.divider),
          const SizedBox(height: 10),
          _InfoRow(label: 'Invoice Number', value: purchase['invoiceNumber'] as String? ?? '-'),
          const SizedBox(height: 10),
          _InfoRow(label: 'Invoice Date', value: invoiceDate != null ? DateHelper.display(invoiceDate) : '-'),
          if ((purchase['notes'] as String? ?? '').isNotEmpty) ...[
            const SizedBox(height: 10),
            const Divider(height: 1, color: _T.divider),
            const SizedBox(height: 10),
            _InfoRow(label: 'Notes', value: purchase['notes'] as String? ?? ''),
          ],
        ],
      ),
    );
  }

  Widget _buildItemsCard(List<dynamic> items) {
    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(title: 'Purchase Items', subtitle: '${items.length} item(s)', icon: Icons.list_alt_rounded),
          const SizedBox(height: 20),
          if (items.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: Text('No items', style: TextStyle(color: _T.textMuted))),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (_, __) => const Divider(height: 1, color: _T.divider),
              itemBuilder: (context, index) {
                final item = Map<String, dynamic>.from(items[index] as Map);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      Container(
                        width: 32, height: 32,
                        decoration: BoxDecoration(
                          color: _T.gradientStart.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: Center(
                          child: Text('${index + 1}',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _T.gradientStart)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item['productName'] as String? ?? '',
                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: _T.textDark)),
                            if (item['hsnCode'] != null)
                              Text('HSN: ${item['hsnCode']}',
                                  style: const TextStyle(fontSize: 11, color: _T.textLight)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('× ${item['quantity']}', style: const TextStyle(fontSize: 12, color: _T.textMuted)),
                          Text(
                            CurrencyFormatter.format((item['purchasePrice'] as num?)?.toDouble() ?? 0),
                            style: const TextStyle(fontSize: 12, color: _T.textMuted),
                          ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      Text(
                        CurrencyFormatter.format((item['total'] as num?)?.toDouble() ?? 0),
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: _T.textDark),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildTotalsCard(double subtotal, double gstAmount, double discountAmount, double totalAmount) {
    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(title: 'Amount Summary', icon: Icons.calculate_rounded),
          const SizedBox(height: 20),
          _TotalRow(label: 'Subtotal', value: CurrencyFormatter.format(subtotal)),
          const SizedBox(height: 8),
          _TotalRow(label: 'GST Amount', value: CurrencyFormatter.format(gstAmount)),
          const SizedBox(height: 8),
          _TotalRow(label: 'Discount', value: '-${CurrencyFormatter.format(discountAmount)}'),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              gradient: _T.brandGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: _T.gradientStart.withOpacity(0.25),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.receipt_long_rounded, color: Colors.white70, size: 20),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text('Grand Total',
                      style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white, fontSize: 15)),
                ),
                Text(
                  CurrencyFormatter.format(totalAmount),
                  style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 22, letterSpacing: -0.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsCard(PurchaseEntryProvider provider, String currentStatus) {
    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(title: 'Actions', subtitle: 'Manage purchase order', icon: Icons.touch_app_rounded),
          const SizedBox(height: 20),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              if (currentStatus == 'draft')
                _ActionButton(
                  label: 'Mark Ordered',
                  icon: Icons.receipt_long_rounded,
                  color: _T.info,
                  onTap: () => _updateStatus(provider, 'ordered'),
                ),
              if (currentStatus == 'ordered')
                _ActionButton(
                  label: 'Mark Received',
                  icon: Icons.check_circle_outline_rounded,
                  color: _T.success,
                  onTap: () => _updateStatus(provider, 'received'),
                ),
              if (currentStatus != 'cancelled')
                _ActionButton(
                  label: 'Edit Purchase',
                  icon: Icons.edit_outlined,
                  color: _T.info,
                  onTap: () => context.push('/purchases/${widget.purchaseId}/edit'),
                ),
              _ActionButton(
                label: 'Export PDF',
                icon: Icons.picture_as_pdf_rounded,
                color: _T.danger,
                onTap: () => _exportPdf(provider),
              ),
              if (currentStatus != 'cancelled')
                _ActionButton(
                  label: 'Cancel Purchase',
                  icon: Icons.cancel_outlined,
                  color: _T.danger,
                  onTap: () => _confirmCancel(provider),
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _updateStatus(PurchaseEntryProvider provider, String newStatus) {
    final purchase = provider.selectedPurchase;
    if (purchase == null) return;
    provider.setStatus(PurchaseStatus.values.firstWhere((s) => s.name == newStatus));
    provider.updatePurchase(updateStock: newStatus == 'received');
    if (mounted) {
      context.showSnackBar('Status updated to ${newStatus[0].toUpperCase()}${newStatus.substring(1)}');
      provider.loadPurchaseById(widget.purchaseId);
    }
  }

  void _confirmCancel(PurchaseEntryProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Cancel Purchase', style: TextStyle(fontWeight: FontWeight.w800)),
        content: const Text('Are you sure you want to cancel this purchase order?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('No')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              provider.setStatus(PurchaseStatus.cancelled);
              provider.updatePurchase(updateStock: false);
              if (mounted) {
                context.showSnackBar('Purchase cancelled');
                provider.loadPurchaseById(widget.purchaseId);
              }
            },
            style: TextButton.styleFrom(foregroundColor: _T.danger),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportPdf(PurchaseEntryProvider provider) async {
    try {
      final purchase = provider.selectedPurchase;
      if (purchase == null) {
        if (mounted) context.showSnackBar('No purchase data', isError: true);
        return;
      }
      final items = (purchase['items'] as List<dynamic>?)
          ?.map((e) => Map<String, dynamic>.from(e as Map))
          .toList() ?? [];
      final html = PurchasePdfService.generatePurchaseHtml(purchase: purchase, items: items);
      final directory = await getDownloadsDirectory() ?? await getApplicationDocumentsDirectory();
      final fileName = 'purchase_${purchase['purchaseNumber']}.html';
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(html);
      if (mounted) {
        context.showSnackBar('PDF saved to Downloads: $fileName');
      }
    } catch (e) {
      if (mounted) {
        context.showSnackBar('Failed to export: $e', isError: true);
      }
    }
  }
}

class _CardShell extends StatelessWidget {
  final Widget child;
  const _CardShell({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _T.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _T.divider, width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E2A6E).withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;

  const _SectionHeader({required this.title, this.subtitle, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            gradient: _T.brandGradient,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: _T.white, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: _T.textDark)),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(subtitle!, style: const TextStyle(fontSize: 11, color: _T.textMuted)),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(label, style: const TextStyle(fontSize: 12, color: _T.textMuted)),
        ),
        Expanded(
          child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _T.textDark)),
        ),
      ],
    );
  }
}

class _TotalRow extends StatelessWidget {
  final String label;
  final String value;
  const _TotalRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: _T.textMuted)),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _T.textDark)),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({required this.label, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
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
