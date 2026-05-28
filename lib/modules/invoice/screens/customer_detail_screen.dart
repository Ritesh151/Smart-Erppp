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

  static BoxDecoration card({double radius = 20}) {
    return BoxDecoration(
      color: white,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: divider.withOpacity(0.8)),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF1E2A6E).withOpacity(0.06),
          blurRadius: 20,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }
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
              child: CircularProgressIndicator(color: _T.gradientStart),
            ),
          );
        }

        final customerInvoices = invoiceProvider.invoices
            .where((inv) => inv.customerId == widget.customerId)
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

        return Container(
          color: _T.bg,
          child: SafeArea(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(context.isMobile ? 16 : 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, customer)
                      .animate()
                      .fadeIn(duration: 280.ms)
                      .slideX(begin: -0.04, end: 0),
                  SizedBox(height: context.isMobile ? 18 : 26),
                  if (context.isDesktop)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 4,
                          child: _buildCustomerInfoCard(customer),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          flex: 6,
                          child: Column(
                            children: [
                              _buildInvoicesSection(context, customerInvoices, invoiceProvider),
                            ],
                          ),
                        ),
                      ],
                    )
                  else
                    Column(
                      children: [
                        _buildCustomerInfoCard(customer),
                        const SizedBox(height: 18),
                        _buildInvoicesSection(context, customerInvoices, invoiceProvider),
                      ],
                    ),
                  const SizedBox(height: 28),
                  _buildActionPanel(context, customer, customerProvider),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, CustomerModel customer) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final vertical = constraints.maxWidth < 700;
        if (vertical) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => context.go('/customers'),
                    child: Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: _T.divider),
                      ),
                      child: const Icon(Icons.arrow_back_rounded, color: _T.textDark),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          customer.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: context.isMobile ? 24 : 30,
                            fontWeight: FontWeight.w800,
                            color: _T.textDark,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 10,
                          runSpacing: 8,
                          children: [
                            _topPill(icon: Icons.email_outlined, value: customer.email ?? 'No email'),
                            if (customer.phone != null)
                              _topPill(icon: Icons.phone_rounded, value: customer.phone!),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _buildActiveBadge(customer.isActive),
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Row(
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => context.go('/customers'),
                    child: Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: _T.divider),
                      ),
                      child: const Icon(Icons.arrow_back_rounded, color: _T.textDark),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          customer.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: context.isMobile ? 24 : 30,
                            fontWeight: FontWeight.w800,
                            color: _T.textDark,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 10,
                          runSpacing: 8,
                          children: [
                            _topPill(icon: Icons.email_outlined, value: customer.email ?? 'No email'),
                            if (customer.phone != null)
                              _topPill(icon: Icons.phone_rounded, value: customer.phone!),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 18),
            _buildActiveBadge(customer.isActive),
          ],
        );
      },
    );
  }

  Widget _topPill({required IconData icon, required String value}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _T.gradientStart.withOpacity(0.06),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: _T.gradientStart),
          const SizedBox(width: 6),
          Text(
            value,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _T.textDark),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerInfoCard(CustomerModel customer) {
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
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
                _buildInfoRow('Status', customer.isActive ? 'Active' : 'Inactive'),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: _T.divider)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Created On', customer.createdAt.toFormattedDateTime()),
                const SizedBox(height: 8),
                _buildInfoRow('Last Updated', customer.updatedAt.toFormattedDateTime()),
              ],
            ),
          ),
        ],
      ),
    );
  }

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
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    gradient: _T.brandGradient,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.receipt_long_rounded, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Invoice History',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: _T.textDark),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${invoices.length} invoice(s) for this customer',
                        style: const TextStyle(fontSize: 11, color: _T.textMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (invoices.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20),
              child: EmptyStateWidget(
                icon: Icons.receipt_long_outlined,
                title: 'No Invoices',
                message: 'This customer has no invoices yet.',
              ),
            )
          else
            ...invoices.map((inv) => _buildInvoiceCard(inv)),
        ],
      ),
    );
  }

  Widget _buildInvoiceCard(InvoiceModel invoice) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => context.push('/invoices/${invoice.id}'),
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _T.divider.withOpacity(0.6)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    invoice.invoiceNumber,
                    style: const TextStyle(fontWeight: FontWeight.w700, color: _T.textDark),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    invoice.invoiceDate.toFormattedDate(),
                    style: const TextStyle(fontSize: 12, color: _T.textMuted),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            _buildInvoiceStatusChip(invoice.status),
            const SizedBox(width: 16),
            Text(
              '₹${invoice.totalAmount.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.w800, color: _T.textDark),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded, color: _T.textLight),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceStatusChip(InvoiceStatus status) {
    late Color color;
    late String label;
    switch (status) {
      case InvoiceStatus.draft:
        color = _T.textMuted;
        label = 'DRAFT';
      case InvoiceStatus.sent:
        color = _T.gradientStart;
        label = 'SENT';
      case InvoiceStatus.paid:
        color = _T.success;
        label = 'PAID';
      case InvoiceStatus.partiallyPaid:
        color = _T.warning;
        label = 'PARTIAL';
      case InvoiceStatus.overdue:
        color = _T.danger;
        label = 'OVERDUE';
      case InvoiceStatus.cancelled:
        color = _T.danger;
        label = 'CANCELLED';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.3),
      ),
    );
  }

  Widget _buildActionPanel(BuildContext context, CustomerModel customer, CustomerProvider provider) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final vertical = constraints.maxWidth < 560;
        if (vertical) {
          return Column(
            children: [
              SizedBox(
                height: 54,
                child: AppButton(
                  text: 'Delete Customer',
                  variant: AppButtonVariant.outline,
                  onPressed: () => _confirmDelete(context, customer, provider),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  gradient: _T.brandGradient,
                  borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                  boxShadow: [
                    BoxShadow(
                      color: _T.gradientStart.withOpacity(0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: SizedBox(
                  height: 54,
                  child: AppButton(
                    text: 'Edit Customer Details',
                    variant: AppButtonVariant.primary,
                    onPressed: () => context.push('/customers/${customer.id}/edit'),
                  ),
                ),
              ),
            ],
          );
        }
        return Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 54,
                child: AppButton(
                  text: 'Delete Customer',
                  variant: AppButtonVariant.outline,
                  onPressed: () => _confirmDelete(context, customer, provider),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  gradient: _T.brandGradient,
                  borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                  boxShadow: [
                    BoxShadow(
                      color: _T.gradientStart.withOpacity(0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: SizedBox(
                  height: 54,
                  child: AppButton(
                    text: 'Edit Customer Details',
                    variant: AppButtonVariant.primary,
                    onPressed: () => context.push('/customers/${customer.id}/edit'),
                  ),
                ),
              ),
            ),
          ],
        );
      },
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
        border: Border.all(color: color.withOpacity(0.18)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.3),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: _T.divider)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: const TextStyle(color: _T.textMuted, fontSize: 13)),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w700, color: _T.textDark, fontSize: 13),
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
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            gradient: _T.brandGradient,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: _T.textDark)),
              const SizedBox(height: 2),
              Text(subtitle, style: const TextStyle(fontSize: 11, color: _T.textMuted)),
            ],
          ),
        ),
      ],
    );
  }

  void _confirmDelete(BuildContext context, CustomerModel customer, CustomerProvider provider) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          title: const Text('Delete Customer?', style: TextStyle(fontWeight: FontWeight.w800)),
          content: Text(
            'Are you sure you want to permanently delete "${customer.name}"? This action cannot be undone.',
            style: const TextStyle(height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            Container(
              decoration: BoxDecoration(
                color: _T.danger,
                borderRadius: BorderRadius.circular(12),
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
                      context.showSnackBar('Customer deleted successfully');
                    }
                  } catch (e) {
                    if (dialogContext.mounted) {
                      Navigator.pop(dialogContext);
                    }
                    if (context.mounted) {
                      context.showSnackBar('Failed to delete customer: $e', isError: true);
                    }
                  }
                },
                child: const Text('Delete', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        );
      },
    );
  }
}
