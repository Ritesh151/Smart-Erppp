import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:SmartERP/core/constants/app_constants.dart';
import 'package:SmartERP/core/extensions/context_extensions.dart';
import 'package:SmartERP/core/extensions/date_extensions.dart';
import 'package:SmartERP/core/models/customer_model.dart';
import 'package:SmartERP/core/models/invoice_model.dart';
import 'package:SmartERP/core/theme/theme_extensions.dart';
import 'package:SmartERP/core/widgets/app_button.dart';
import 'package:SmartERP/core/widgets/empty_state_widget.dart';
import 'package:SmartERP/modules/invoice/providers/customer_provider.dart';
import 'package:SmartERP/modules/invoice/providers/invoice_provider.dart';

class _T {
  static const gradientStart = Color(0xFF4F6EF7);
  static const gradientEnd = Color(0xFF7C3AED);
  static const bg = Color(0xFFF5F7FA);
  static const white = Colors.white;
  static const textDark = Color(0xFF111827);
  static const textMid = Color(0xFF374151);
  static const textMuted = Color(0xFF6B7280);
  static const textLight = Color(0xFF9CA3AF);
  static const divider = Color(0xFFE5E7EB);
  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFF59E0B);
  static const danger = Color(0xFFEF4444);

  static const Gradient brandGradient = LinearGradient(
    colors: [gradientStart, gradientEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static BoxDecoration card({double radius = 16}) => BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E2A6E).withOpacity(0.06),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
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
      final customerProvider = context.read<CustomerProvider>();
      final invoiceProvider = context.read<InvoiceProvider>();
      if (customerProvider.customers.isEmpty) {
        customerProvider.loadCustomers();
      }
      if (invoiceProvider.invoices.isEmpty) {
        invoiceProvider.loadInvoices();
      }
    });
  }

  CustomerModel? _findCustomer(CustomerProvider provider) {
    try {
      return provider.customers.firstWhere((c) => c.id == widget.customerId);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<CustomerProvider, InvoiceProvider>(
      builder: (context, customerProvider, invoiceProvider, _) {
        final customer = _findCustomer(customerProvider);

        if (customer == null) {
          return Container(
            color: _T.bg,
            child: const Center(
              child: CircularProgressIndicator(
                color: _T.gradientStart,
                strokeWidth: 2.5,
              ),
            ),
          );
        }

        final customerInvoices = invoiceProvider.invoices
            .where((inv) => inv.customerId == widget.customerId)
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

        final totalBilled = customerInvoices.fold<double>(
            0, (sum, inv) => sum + inv.totalAmount);
        final paidCount =
            customerInvoices.where((i) => i.status == InvoiceStatus.paid).length;
        final overdueCount = customerInvoices
            .where((i) => i.status == InvoiceStatus.overdue)
            .length;

        return Container(
          color: _T.bg,
          child: SafeArea(
            child: RefreshIndicator(
              color: _T.gradientStart,
              onRefresh: () async {
                await Future.wait([
                  customerProvider.loadCustomers(),
                  invoiceProvider.loadInvoices(),
                ]);
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(context.isMobile ? 16 : 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context, customer)
                        .animate()
                        .fadeIn(duration: 300.ms)
                        .slideX(begin: -0.04, end: 0),
                    SizedBox(height: context.isMobile ? 18 : 24),
                    _buildStatsRow(context, customerInvoices.length, totalBilled,
                            paidCount, overdueCount)
                        .animate()
                        .fadeIn(delay: 80.ms, duration: 300.ms)
                        .slideY(begin: 0.08, end: 0),
                    SizedBox(height: context.isMobile ? 18 : 24),
                    if (context.isDesktop)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 4,
                            child: _buildCustomerInfoCard(context, customer)
                                .animate()
                                .fadeIn(delay: 120.ms, duration: 300.ms)
                                .slideY(begin: 0.08, end: 0),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            flex: 6,
                            child: _buildInvoicesSection(
                                    context, customerInvoices, invoiceProvider)
                                .animate()
                                .fadeIn(delay: 160.ms, duration: 300.ms)
                                .slideY(begin: 0.08, end: 0),
                          ),
                        ],
                      )
                    else
                      Column(
                        children: [
                          _buildCustomerInfoCard(context, customer)
                              .animate()
                              .fadeIn(delay: 120.ms, duration: 300.ms)
                              .slideY(begin: 0.08, end: 0),
                          const SizedBox(height: 18),
                          _buildInvoicesSection(
                                  context, customerInvoices, invoiceProvider)
                              .animate()
                              .fadeIn(delay: 160.ms, duration: 300.ms)
                              .slideY(begin: 0.08, end: 0),
                        ],
                      ),
                    SizedBox(height: context.isMobile ? 24 : 28),
                    _buildActionPanel(context, customer, customerProvider)
                        .animate()
                        .fadeIn(delay: 200.ms, duration: 300.ms)
                        .slideY(begin: 0.08, end: 0),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context, CustomerModel customer) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 600;

        final backBtn = _IconBtn(
          icon: Icons.arrow_back_rounded,
          onTap: () => context.go('/customers'),
        );

        final nameBlock = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              customer.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: context.isMobile ? 22 : 28,
                fontWeight: FontWeight.w800,
                color: _T.textDark,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                _topPill(
                    icon: Icons.email_outlined,
                    value: customer.email ?? 'No email'),
                if (customer.phone != null)
                  _topPill(
                      icon: Icons.phone_rounded, value: customer.phone!),
              ],
            ),
          ],
        );

        final badge = _buildActiveBadge(customer.isActive);

        if (isNarrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  backBtn,
                  const SizedBox(width: 14),
                  Expanded(child: nameBlock),
                ],
              ),
              const SizedBox(height: 14),
              badge,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            backBtn,
            const SizedBox(width: 16),
            Expanded(child: nameBlock),
            const SizedBox(width: 16),
            badge,
          ],
        );
      },
    );
  }

  Widget _topPill({required IconData icon, required String value}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: _T.gradientStart.withOpacity(0.07),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: _T.gradientStart.withOpacity(0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: _T.gradientStart),
          const SizedBox(width: 6),
          Text(
            value,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _T.textDark),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveBadge(bool isActive) {
    final color = isActive ? _T.success : _T.textMuted;
    final label = isActive ? 'ACTIVE' : 'INACTIVE';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5),
          ),
        ],
      ),
    );
  }

  // ── Stats row ─────────────────────────────────────────────────────────────
  Widget _buildStatsRow(BuildContext context, int totalInvoices,
      double totalBilled, int paidCount, int overdueCount) {
    String formatAmount(double v) {
      if (v >= 10000000) return '₹${(v / 10000000).toStringAsFixed(1)}Cr';
      if (v >= 100000) return '₹${(v / 100000).toStringAsFixed(1)}L';
      if (v >= 1000) return '₹${(v / 1000).toStringAsFixed(1)}K';
      return '₹${v.toStringAsFixed(0)}';
    }

    final stats = [
      {
        'label': 'Total Invoices',
        'value': '$totalInvoices',
        'icon': Icons.receipt_long_rounded,
        'color': _T.gradientStart,
        'bg': const Color(0xFFEEF2FF),
      },
      {
        'label': 'Total Billed',
        'value': formatAmount(totalBilled),
        'icon': Icons.currency_rupee_rounded,
        'color': const Color(0xFF10B981),
        'bg': const Color(0xFFECFDF5),
      },
      {
        'label': 'Paid',
        'value': '$paidCount',
        'icon': Icons.check_circle_outline_rounded,
        'color': const Color(0xFF10B981),
        'bg': const Color(0xFFECFDF5),
      },
      {
        'label': 'Overdue',
        'value': '$overdueCount',
        'icon': Icons.error_outline_rounded,
        'color': _T.danger,
        'bg': const Color(0xFFFEF2F2),
      },
    ];

    return LayoutBuilder(builder: (context, constraints) {
      final crossCount = context.isMobile ? 2 : 4;
      final spacing = context.isMobile ? 12.0 : 16.0;

      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: stats.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossCount,
          crossAxisSpacing: spacing,
          mainAxisSpacing: spacing,
          childAspectRatio: context.isMobile ? 1.6 : 2.2,
        ),
        itemBuilder: (context, i) {
          final s = stats[i];
          final color = s['color'] as Color;
          final bg = s['bg'] as Color;
          return Container(
            padding: EdgeInsets.all(context.isMobile ? 14 : 16),
            decoration: BoxDecoration(
              color: _T.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _T.divider, width: 1),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1E2A6E).withOpacity(0.05),
                  blurRadius: 14,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: context.isMobile ? 38 : 44,
                  height: context.isMobile ? 38 : 44,
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(s['icon'] as IconData,
                      color: color, size: context.isMobile ? 18 : 20),
                ),
                SizedBox(width: context.isMobile ? 10 : 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        s['value'] as String,
                        style: TextStyle(
                          fontSize: context.isMobile ? 17 : 20,
                          fontWeight: FontWeight.w800,
                          color: _T.textDark,
                          letterSpacing: -0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        s['label'] as String,
                        style: TextStyle(
                          fontSize: context.isMobile ? 10 : 11,
                          color: _T.textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
              .animate()
              .fadeIn(delay: (i * 60).ms, duration: 280.ms)
              .slideY(begin: 0.1, end: 0);
        },
      );
    });
  }

  // ── Customer info card ────────────────────────────────────────────────────
  Widget _buildCustomerInfoCard(BuildContext context, CustomerModel customer) {
    return Container(
      width: double.infinity,
      decoration: _T.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: _sectionHeader(
              title: 'Customer Details',
              subtitle: 'Contact and address information',
              icon: Icons.person_rounded,
            ),
          ),
          Container(height: 1, color: _T.divider),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Column(
              children: [
                _buildInfoRow('Name', customer.name),
                _buildInfoRow('Email', customer.email ?? 'N/A'),
                _buildInfoRow('Phone', customer.phone ?? 'N/A'),
                _buildInfoRow('Address', customer.address ?? 'N/A'),
                _buildInfoRow('GST Number', customer.gstNumber ?? 'N/A'),
                _buildInfoRow('City', customer.city ?? 'N/A'),
                _buildInfoRow('State', customer.state ?? 'N/A'),
                _buildInfoRow('Pincode', customer.pincode ?? 'N/A'),
                _buildInfoRow(
                    'Status', customer.isActive ? 'Active' : 'Inactive',
                    valueColor:
                        customer.isActive ? _T.success : _T.textMuted),
              ],
            ),
          ),
          Container(height: 1, color: _T.divider),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
            child: Column(
              children: [
                _buildInfoRow(
                    'Created On', customer.createdAt.toFormattedDateTime()),
                _buildInfoRow(
                    'Last Updated', customer.updatedAt.toFormattedDateTime()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 11),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: _T.divider, width: 0.8)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: const TextStyle(
                  color: _T.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            flex: 6,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: valueColor ?? _T.textDark,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
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
          child: Icon(icon, color: Colors.white, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: _T.textDark)),
              const SizedBox(height: 2),
              Text(subtitle,
                  style:
                      const TextStyle(fontSize: 11, color: _T.textMuted)),
            ],
          ),
        ),
      ],
    );
  }

  // ── Invoices section ──────────────────────────────────────────────────────
  Widget _buildInvoicesSection(
    BuildContext context,
    List<InvoiceModel> invoices,
    InvoiceProvider provider,
  ) {
    return Container(
      width: double.infinity,
      decoration: _T.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
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
                  child: const Icon(Icons.receipt_long_rounded,
                      color: Colors.white, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Invoice History',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: _T.textDark),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${invoices.length} invoice(s) for this customer',
                        style: const TextStyle(
                            fontSize: 11, color: _T.textMuted),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _T.gradientStart.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${invoices.length}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _T.gradientStart,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(height: 1, color: _T.divider),
          if (invoices.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: EmptyStateWidget(
                icon: Icons.receipt_long_outlined,
                title: 'No Invoices',
                message: 'This customer has no invoices yet.',
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                children: invoices
                    .asMap()
                    .entries
                    .map((e) => Padding(
                          padding: EdgeInsets.only(
                              bottom: e.key < invoices.length - 1 ? 10 : 8),
                          child: _buildInvoiceCard(e.value),
                        ))
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInvoiceCard(InvoiceModel invoice) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => context.push('/invoices/${invoice.id}'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _T.divider.withOpacity(0.7)),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _T.gradientStart.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.receipt_outlined,
                  size: 16, color: _T.gradientStart),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    invoice.invoiceNumber,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: _T.textDark,
                        fontSize: 13),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    invoice.invoiceDate.toFormattedDate(),
                    style: const TextStyle(
                        fontSize: 11, color: _T.textMuted),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _buildInvoiceStatusChip(invoice.status),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₹${invoice.totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: _T.textDark,
                      fontSize: 13),
                ),
              ],
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right_rounded,
                color: _T.textLight, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceStatusChip(InvoiceStatus status) {
    late Color color;
    late String label;
    late IconData icon;

    switch (status) {
      case InvoiceStatus.draft:
        color = _T.textMuted;
        label = 'DRAFT';
        icon = Icons.edit_outlined;
      case InvoiceStatus.sent:
        color = _T.gradientStart;
        label = 'SENT';
        icon = Icons.send_outlined;
      case InvoiceStatus.paid:
        color = _T.success;
        label = 'PAID';
        icon = Icons.check_circle_outline_rounded;
      case InvoiceStatus.partiallyPaid:
        color = _T.warning;
        label = 'PARTIAL';
        icon = Icons.timelapse_rounded;
      case InvoiceStatus.overdue:
        color = _T.danger;
        label = 'OVERDUE';
        icon = Icons.error_outline_rounded;
      case InvoiceStatus.cancelled:
        color = _T.danger;
        label = 'CANCELLED';
        icon = Icons.cancel_outlined;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        label,
        style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3),
      ),
    );
  }

  // ── Action panel ──────────────────────────────────────────────────────────
  Widget _buildActionPanel(BuildContext context, CustomerModel customer,
      CustomerProvider provider) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 560;

        final deleteBtn = SizedBox(
          height: 52,
          child: AppButton(
            text: 'Delete Customer',
            variant: AppButtonVariant.outline,
            onPressed: () => _confirmDelete(context, customer, provider),
          ),
        );

        final editBtn = Container(
          decoration: BoxDecoration(
            gradient: _T.brandGradient,
            borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
            boxShadow: [
              BoxShadow(
                color: _T.gradientStart.withOpacity(0.28),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: SizedBox(
            height: 52,
            child: AppButton(
              text: 'Edit Customer Details',
              variant: AppButtonVariant.primary,
              onPressed: () =>
                  context.push('/customers/${customer.id}/edit'),
            ),
          ),
        );

        if (isNarrow) {
          return Column(
            children: [
              editBtn,
              const SizedBox(height: 12),
              deleteBtn,
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: deleteBtn),
            const SizedBox(width: 16),
            Expanded(child: editBtn),
          ],
        );
      },
    );
  }

  // ── Delete dialog ─────────────────────────────────────────────────────────
  void _confirmDelete(BuildContext context, CustomerModel customer,
      CustomerProvider provider) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: _T.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22)),
          title: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _T.danger.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.delete_outline_rounded,
                    color: _T.danger, size: 18),
              ),
              const SizedBox(width: 12),
              const Text('Delete Customer?',
                  style: TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 17)),
            ],
          ),
          content: Text(
            'Are you sure you want to permanently delete "${customer.name}"? This action cannot be undone.',
            style: const TextStyle(
                color: _T.textMuted, fontSize: 14, height: 1.6),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel',
                  style: TextStyle(color: _T.textMuted)),
            ),
            Container(
              decoration: BoxDecoration(
                color: _T.danger,
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextButton(
                onPressed: () async {
                  try {
                    await provider.deleteCustomer(customer.id);
                    if (dialogContext.mounted) {
                      Navigator.pop(dialogContext);
                    }
                    if (context.mounted) {
                      context.go('/customers');
                      context.showSnackBar(
                          'Customer deleted successfully');
                    }
                  } catch (e) {
                    if (dialogContext.mounted) {
                      Navigator.pop(dialogContext);
                    }
                    if (context.mounted) {
                      context.showSnackBar(
                          'Failed to delete customer: $e',
                          isError: true);
                    }
                  }
                },
                child: const Text('Delete',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ── Reusable icon button ───────────────────────────────────────────────────
class _IconBtn extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _IconBtn({required this.icon, required this.onTap});

  @override
  State<_IconBtn> createState() => _IconBtnState();
}

class _IconBtnState extends State<_IconBtn> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: _hovered
                ? _T.gradientStart.withOpacity(0.06)
                : _T.white,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(
              color: _hovered
                  ? _T.gradientStart.withOpacity(0.3)
                  : _T.divider,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1E2A6E).withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(widget.icon,
              color: _hovered ? _T.gradientStart : _T.textDark,
              size: 20),
        ),
      ),
    );
  }
}
