import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:siddhivinayak_enterprise/core/extensions/context_extensions.dart';
import 'package:siddhivinayak_enterprise/core/models/customer_model.dart';
import 'package:siddhivinayak_enterprise/core/models/invoice_model.dart';
import 'package:siddhivinayak_enterprise/core/utils/currency_formatter.dart';
import 'package:siddhivinayak_enterprise/core/utils/date_helper.dart';
import 'package:siddhivinayak_enterprise/modules/invoice/providers/customer_provider.dart';
import 'package:siddhivinayak_enterprise/modules/invoice/providers/invoice_provider.dart';

class _T {
  static const primaryStart = Color(0xFF6366F1);
  static const primaryEnd = Color(0xFF7C3AED);
  static const bg = Color(0xFFF8FAFC);
  static const surface = Colors.white;
  static const border = Color(0xFFE2E8F0);
  static const textPrimary = Color(0xFF0F172A);
  static const textSecondary = Color(0xFF475569);
  static const textTertiary = Color(0xFF94A3B8);
  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFF59E0B);
  static const danger = Color(0xFFF43F5E);
  static const successBg = Color(0xFFECFDF5);
  static const warningBg = Color(0xFFFFFBEB);
  static const dangerBg = Color(0xFFFFF1F2);

  static const Gradient brandGradient = LinearGradient(
    colors: [primaryStart, primaryEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static BoxDecoration card({double radius = 16}) => BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: border),
        boxShadow: [BoxShadow(color: Color(0xFF0F172A).withOpacity(0.04), blurRadius: 16, offset: Offset(0, 4))],
      );
}

class CustomerDetailScreen extends StatefulWidget {
  final String customerId;
  const CustomerDetailScreen({super.key, required this.customerId});

  @override
  State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cp = context.read<CustomerProvider>();
      final ip = context.read<InvoiceProvider>();
      if (cp.customers.isEmpty) cp.loadCustomers();
      if (ip.invoices.isEmpty) ip.loadInvoices();
    });
  }

  CustomerModel? _findCustomer(CustomerProvider p) {
    try {
      return p.customers.firstWhere((c) => c.id == widget.customerId);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<CustomerProvider, InvoiceProvider>(
      builder: (context, cp, ip, _) {
        final customer = _findCustomer(cp);
        if (customer == null) {
          return Container(
            color: _T.bg,
            child: const Center(child: CircularProgressIndicator(color: _T.primaryStart, strokeWidth: 2.5)),
          );
        }

        final invoices = ip.invoices.where((inv) => inv.customerId == widget.customerId).toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

        final totalBilled = invoices.fold<double>(0, (s, i) => s + i.totalAmount);
        final paidCount = invoices.where((i) => i.status == InvoiceStatus.paid).length;
        final overdueCount = invoices.where((i) => i.status == InvoiceStatus.overdue).length;
        final lastActivity = invoices.isNotEmpty ? invoices.first.createdAt : null;
        final accountAge = DateTime.now().difference(customer.createdAt).inDays;
        final isMobile = context.isMobile;
        final pad = isMobile ? 16.0 : 24.0;
        final gap = isMobile ? 16.0 : 20.0;

        return Scaffold(
          backgroundColor: _T.bg,
          body: SafeArea(
            child: RefreshIndicator(
              color: _T.primaryStart,
              onRefresh: () async => Future.wait([cp.loadCustomers(), ip.loadInvoices()]),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    _buildPremiumHeader(customer, isMobile).animate().fadeIn(duration: 300.ms).slideY(begin: -0.04, end: 0),
                    Padding(
                      padding: EdgeInsets.all(pad),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildAnalyticsCard(invoices.length, totalBilled, paidCount, overdueCount, lastActivity, accountAge, isMobile)
                              .animate().fadeIn(delay: 80.ms, duration: 300.ms).slideY(begin: 0.08, end: 0),
                          SizedBox(height: gap),
                          if (context.isDesktop)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 4,
                                  child: Column(
                                    children: [
                                      _buildContactInfoCard(customer, isMobile).animate().fadeIn(delay: 120.ms, duration: 300.ms).slideY(begin: 0.08, end: 0),
                                      SizedBox(height: gap),
                                      _buildAddressCard(customer).animate().fadeIn(delay: 140.ms, duration: 300.ms).slideY(begin: 0.08, end: 0),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  flex: 6,
                                  child: _buildInvoicesSection(invoices, isMobile)
                                      .animate().fadeIn(delay: 160.ms, duration: 300.ms).slideY(begin: 0.08, end: 0),
                                ),
                              ],
                            )
                          else
                            Column(
                              children: [
                                _buildContactInfoCard(customer, isMobile).animate().fadeIn(delay: 120.ms, duration: 300.ms).slideY(begin: 0.08, end: 0),
                                SizedBox(height: gap),
                                _buildAddressCard(customer).animate().fadeIn(delay: 140.ms, duration: 300.ms).slideY(begin: 0.08, end: 0),
                                SizedBox(height: gap),
                                _buildInvoicesSection(invoices, isMobile).animate().fadeIn(delay: 160.ms, duration: 300.ms).slideY(begin: 0.08, end: 0),
                              ],
                            ),
                          SizedBox(height: gap),
                          _buildActionsPanel(customer, cp, isMobile).animate().fadeIn(delay: 200.ms, duration: 300.ms).slideY(begin: 0.08, end: 0),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPremiumHeader(CustomerModel customer, bool isMobile) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: _T.brandGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(isMobile ? 16 : 24, isMobile ? 12 : 16, isMobile ? 16 : 24, isMobile ? 20 : 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [_backButton(), const Spacer(), _buildStatusChip(customer.isActive)]),
          SizedBox(height: isMobile ? 16 : 20),
          Row(
            children: [
              CircleAvatar(
                radius: isMobile ? 28 : 34,
                backgroundColor: Colors.white.withOpacity(0.18),
                child: Text(customer.name.isNotEmpty ? customer.name[0].toUpperCase() : '?',
                    style: TextStyle(fontSize: isMobile ? 24 : 30, fontWeight: FontWeight.w700, color: Colors.white)),
              ),
              SizedBox(width: isMobile ? 14 : 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(customer.name, maxLines: 2, overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: isMobile ? 22 : 28, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.5)),
                    const SizedBox(height: 4),
                    Text(customer.id.length > 8 ? '#${customer.id.substring(0, 8).toUpperCase()}' : '#${customer.id}',
                        style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.65), fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 10 : 14),
          Row(children: [
            Icon(Icons.calendar_today_rounded, size: 14, color: Colors.white.withOpacity(0.65)),
            const SizedBox(width: 6),
            Text('Customer since ${DateHelper.display(customer.createdAt)}',
                style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.65), fontWeight: FontWeight.w500)),
          ]),
        ],
      ),
    );
  }

  Widget _backButton() {
    return GestureDetector(
      onTap: () => context.pop(),
      child: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.15)),
        ),
        child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildStatusChip(bool isActive) {
    final color = isActive ? _T.success : _T.textTertiary;
    final bg = isActive ? _T.successBg : _T.border;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg.withOpacity(0.25), borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(isActive ? 'ACTIVE' : 'INACTIVE',
            style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
      ]),
    );
  }

  Widget _buildAnalyticsCard(int invCount, double totalBilled, int paidCount,
      int overdueCount, DateTime? lastActivity, int accountAge, bool isMobile) {
    final stats = [
      ['$invCount', 'Total Invoices', Icons.receipt_long_rounded, _T.primaryStart, _T.primaryStart.withOpacity(0.08)],
      [CurrencyFormatter.compact(totalBilled), 'Total Billed', Icons.currency_rupee_rounded, _T.success, _T.successBg],
      [lastActivity != null ? DateHelper.display(lastActivity) : 'N/A', 'Last Activity', Icons.history_rounded, _T.warning, _T.warningBg],
      ['$accountAge days', 'Account Age', Icons.schedule_rounded, _T.textSecondary, _T.border],
    ];
    return Container(
      width: double.infinity, padding: EdgeInsets.all(isMobile ? 14 : 16), decoration: _T.card(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionHeader(Icons.analytics_rounded, 'Analytics', 'Customer performance overview'),
        SizedBox(height: isMobile ? 14 : 16),
        GridView.builder(
          shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
          itemCount: stats.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isMobile ? 2 : 4, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: isMobile ? 1.4 : 2.0,
          ),
          itemBuilder: (context, i) {
            final s = stats[i];
            return Container(
              padding: EdgeInsets.all(isMobile ? 12 : 14),
              decoration: BoxDecoration(color: s[4] as Color, borderRadius: BorderRadius.circular(12)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(s[2] as IconData, color: s[3] as Color, size: isMobile ? 16 : 18),
                SizedBox(height: isMobile ? 8 : 10),
                Text(s[0] as String,
                    style: TextStyle(fontSize: isMobile ? 16 : 18, fontWeight: FontWeight.w800, color: _T.textPrimary, letterSpacing: -0.3)),
                const SizedBox(height: 2),
                Text(s[1] as String, style: const TextStyle(fontSize: 11, color: _T.textSecondary, fontWeight: FontWeight.w500)),
              ]),
            );
          },
        ),
      ]),
    );
  }

  Widget _buildContactInfoCard(CustomerModel customer, bool isMobile) {
    final items = [
      [Icons.email_outlined, 'Email', customer.email ?? 'Not provided', null],
      [Icons.phone_rounded, 'Phone', customer.phone ?? 'Not provided', null],
      [Icons.assignment_rounded, 'GST Number', customer.gstNumber ?? 'Not provided', 'GST'],
      [Icons.location_city_rounded, 'City', customer.city ?? 'Not provided', null],
      [Icons.map_rounded, 'State', customer.state ?? 'Not provided', null],
      [Icons.pin_drop_rounded, 'Pincode', customer.pincode ?? 'Not provided', null],
    ];
    return Container(
      width: double.infinity, padding: EdgeInsets.all(isMobile ? 16 : 20), decoration: _T.card(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionHeader(Icons.contact_page_rounded, 'Contact Information', 'Email, phone & address details'),
        SizedBox(height: isMobile ? 14 : 16),
        GridView.builder(
          shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isMobile ? 1 : 2, crossAxisSpacing: 12, mainAxisSpacing: 8, childAspectRatio: 5.5,
          ),
          itemBuilder: (context, i) {
            final item = items[i];
            return Row(children: [
              Container(width: 36, height: 36,
                decoration: BoxDecoration(color: _T.primaryStart.withOpacity(0.08), borderRadius: BorderRadius.circular(10)),
                child: Icon(item[0] as IconData, size: 16, color: _T.primaryStart),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                  Row(children: [
                    Text(item[1] as String, style: const TextStyle(fontSize: 10, color: _T.textTertiary, fontWeight: FontWeight.w500)),
                    if (item[3] != null) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: _T.warningBg, borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: _T.warning.withOpacity(0.3)),
                        ),
                        child: Text(item[3] as String, style: const TextStyle(fontSize: 8, color: _T.warning, fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ]),
                  const SizedBox(height: 2),
                  Text(item[2] as String, style: const TextStyle(fontSize: 13, color: _T.textPrimary, fontWeight: FontWeight.w600),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                ]),
              ),
            ]);
          },
        ),
      ]),
    );
  }

  Widget _buildAddressCard(CustomerModel customer) {
    final hasAddress = customer.address != null && customer.address!.isNotEmpty;
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(20), decoration: _T.card(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionHeader(Icons.home_rounded, 'Address', 'Registered business address'),
        const SizedBox(height: 14),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(width: 40, height: 40,
            decoration: BoxDecoration(color: _T.successBg, borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.location_on_rounded, size: 18, color: _T.success),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(hasAddress ? customer.address! : 'No address provided',
                  style: const TextStyle(fontSize: 13, color: _T.textPrimary, fontWeight: FontWeight.w600, height: 1.5)),
              if (hasAddress && (customer.city != null || customer.state != null || customer.pincode != null))
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    [if (customer.city != null) customer.city, if (customer.state != null) customer.state, if (customer.pincode != null) customer.pincode].join(', '),
                    style: const TextStyle(fontSize: 12, color: _T.textSecondary),
                  ),
                ),
            ]),
          ),
        ]),
      ]),
    );
  }

  Widget _buildInvoicesSection(List<InvoiceModel> invoices, bool isMobile) {
    return Container(
      width: double.infinity, padding: EdgeInsets.all(isMobile ? 16 : 20), decoration: _T.card(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: _sectionHeader(Icons.receipt_long_rounded, 'Invoices', '${invoices.length} invoice(s) for this customer')),
          if (invoices.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: _T.primaryStart.withOpacity(0.08), borderRadius: BorderRadius.circular(20)),
              child: Text('${invoices.length}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _T.primaryStart)),
            ),
        ]),
        SizedBox(height: isMobile ? 14 : 16),
        if (invoices.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Center(
              child: Column(children: [
                Icon(Icons.receipt_long_outlined, size: 48, color: _T.textTertiary.withOpacity(0.5)),
                const SizedBox(height: 12),
                const Text('No Invoices', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _T.textSecondary)),
                const SizedBox(height: 4),
                const Text('This customer has no invoices yet.', style: TextStyle(fontSize: 12, color: _T.textTertiary)),
              ]),
            ),
          )
        else
          Column(
            children: invoices.asMap().entries.map((e) => Padding(
              padding: EdgeInsets.only(bottom: e.key < invoices.length - 1 ? 10 : 0),
              child: _buildInvoiceCard(e.value),
            )).toList(),
          ),
      ]),
    );
  }

  Widget _buildInvoiceCard(InvoiceModel invoice) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => context.push('/invoices/${invoice.id}'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12), border: Border.all(color: _T.border),
        ),
        child: Row(children: [
          Container(width: 36, height: 36,
            decoration: BoxDecoration(color: _T.primaryStart.withOpacity(0.08), borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.receipt_outlined, size: 16, color: _T.primaryStart),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(invoice.invoiceNumber, style: const TextStyle(fontWeight: FontWeight.w700, color: _T.textPrimary, fontSize: 13)),
              const SizedBox(height: 3),
              Text(DateHelper.display(invoice.invoiceDate), style: const TextStyle(fontSize: 11, color: _T.textTertiary)),
            ]),
          ),
          _buildInvoiceStatusChip(invoice.status),
          const SizedBox(width: 10),
          Text(CurrencyFormatter.format(invoice.totalAmount), style: const TextStyle(fontWeight: FontWeight.w800, color: _T.textPrimary, fontSize: 13)),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right_rounded, color: _T.textTertiary, size: 18),
        ]),
      ),
    );
  }

  Widget _buildInvoiceStatusChip(InvoiceStatus status) {
    late Color color;
    late String label;
    switch (status) {
      case InvoiceStatus.draft: color = _T.textTertiary; label = 'DRAFT';
      case InvoiceStatus.sent: color = _T.primaryStart; label = 'SENT';
      case InvoiceStatus.paid: color = _T.success; label = 'PAID';
      case InvoiceStatus.partiallyPaid: color = _T.warning; label = 'PARTIAL';
      case InvoiceStatus.overdue: color = _T.danger; label = 'OVERDUE';
      case InvoiceStatus.cancelled: color = _T.danger; label = 'CANCELLED';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(20), border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.3)),
    );
  }

  Widget _buildActionsPanel(CustomerModel customer, CustomerProvider provider, bool isMobile) {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(20), decoration: _T.card(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionHeader(Icons.flash_on_rounded, 'Quick Actions', 'Manage customer account'),
        SizedBox(height: isMobile ? 14 : 16),
        GridView.builder(
          shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
          itemCount: 4,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isMobile ? 2 : 4, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: isMobile ? 1.3 : 2.5,
          ),
          itemBuilder: (context, i) {
            switch (i) {
              case 0: return _buildActionButton('Edit', Icons.edit_rounded, _T.primaryStart, () => context.push('/customers/${customer.id}/edit'));
              case 1: return _buildActionButton('Delete', Icons.delete_outline_rounded, _T.danger, () => _confirmDelete(customer, provider));
              case 2: return _buildActionButton('Call', Icons.phone_rounded, _T.success,
                  customer.phone != null ? () => launchUrl(Uri.parse('tel:${customer.phone}')) : null);
              case 3: return _buildActionButton('WhatsApp', Icons.chat_rounded, const Color(0xFF25D366),
                  customer.phone != null ? () => launchUrl(Uri.parse('https://wa.me/${customer.phone!.replaceAll(RegExp(r'[^\d+]'), '')}')) : null);
              default: return const SizedBox();
            }
          },
        ),
      ]),
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color bgColor, VoidCallback? onTap) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: bgColor.withOpacity(0.08), borderRadius: BorderRadius.circular(12), border: Border.all(color: bgColor.withOpacity(0.15)),
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, color: bgColor, size: 22),
          const SizedBox(height: 6),
          Text(label, style: TextStyle(fontSize: 12, color: bgColor, fontWeight: FontWeight.w700)),
        ]),
      ),
    );
  }

  Widget _sectionHeader(IconData icon, String title, String subtitle) {
    return Row(children: [
      Container(width: 36, height: 36,
        decoration: BoxDecoration(
          gradient: _T.brandGradient, borderRadius: BorderRadius.circular(10),
          boxShadow: [BoxShadow(color: _T.primaryStart.withOpacity(0.2), blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: Icon(icon, color: Colors.white, size: 17),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: _T.textPrimary)),
          Text(subtitle, style: const TextStyle(fontSize: 11, color: _T.textTertiary)),
        ]),
      ),
    ]);
  }

  void _confirmDelete(CustomerModel customer, CustomerProvider provider) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _T.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(children: [
          Container(width: 36, height: 36,
            decoration: BoxDecoration(color: _T.dangerBg, borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.delete_outline_rounded, color: _T.danger, size: 18),
          ),
          const SizedBox(width: 12),
          const Text('Delete Customer?', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
        ]),
        content: Text('Are you sure you want to permanently delete "${customer.name}"? This action cannot be undone.',
            style: const TextStyle(color: _T.textSecondary, fontSize: 14, height: 1.6)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: _T.textSecondary, fontWeight: FontWeight.w600))),
          Container(
            decoration: BoxDecoration(color: _T.danger, borderRadius: BorderRadius.circular(10)),
            child: TextButton(
              onPressed: () async {
                try {
                  await provider.deleteCustomer(customer.id);
                  if (ctx.mounted) Navigator.pop(ctx);
                  if (context.mounted) {
                    context.go('/customers');
                    context.showSnackBar('Customer deleted successfully');
                  }
                } catch (e) {
                  if (ctx.mounted) Navigator.pop(ctx);
                  if (context.mounted) {
                    context.showSnackBar('Failed to delete customer: $e', isError: true);
                  }
                }
              },
              child: const Text('Delete', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}
