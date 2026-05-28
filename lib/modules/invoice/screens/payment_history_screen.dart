import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:SmartERP/core/constants/app_constants.dart';
import 'package:SmartERP/core/extensions/context_extensions.dart';
import 'package:SmartERP/core/extensions/date_extensions.dart';
import 'package:SmartERP/core/models/invoice_model.dart';
import 'package:SmartERP/core/models/payment_model.dart';
import 'package:SmartERP/core/theme/theme_extensions.dart';
import 'package:SmartERP/core/widgets/app_button.dart';
import 'package:SmartERP/core/widgets/empty_state_widget.dart';
import 'package:SmartERP/modules/invoice/providers/invoice_provider.dart';
import 'package:SmartERP/modules/invoice/providers/payment_provider.dart';

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

  static BoxDecoration card({double radius = 18, bool hover = false}) {
    return BoxDecoration(
      color: white,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: hover ? gradientStart.withOpacity(0.12) : divider.withOpacity(0.8),
      ),
      boxShadow: [
        BoxShadow(
          color: hover
              ? gradientStart.withOpacity(0.12)
              : const Color(0xFF1E2A6E).withOpacity(0.06),
          blurRadius: hover ? 22 : 16,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }
}

class PaymentHistoryScreen extends StatefulWidget {
  final String invoiceId;

  const PaymentHistoryScreen({super.key, required this.invoiceId});

  @override
  State<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final paymentProvider = context.read<PaymentProvider>();
      final invoiceProvider = context.read<InvoiceProvider>();
      paymentProvider.loadPaymentsForInvoice(widget.invoiceId);
      invoiceProvider.loadInvoiceDetails(widget.invoiceId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _T.bg,
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(context.isMobile ? 16 : 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 20),
              Consumer<InvoiceProvider>(
                builder: (context, invProvider, _) {
                  final invoice = invProvider.selectedInvoice;
                  if (invoice == null) return const SizedBox.shrink();
                  return _buildInvoiceSummary(invoice);
                },
              ),
              const SizedBox(height: 20),
              _buildRecordPaymentButton(),
              const SizedBox(height: 24),
              Consumer<PaymentProvider>(
                builder: (context, provider, _) {
                  if (provider.isLoading) {
                    return _buildShimmerLoading();
                  }
                  if (provider.payments.isEmpty) {
                    return _buildEmptyState();
                  }
                  return context.isDesktop
                      ? _buildDesktopTable(context, provider)
                      : _buildMobileList(context, provider);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final vertical = constraints.maxWidth < 620;
        if (vertical) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => context.pop(),
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
                        const Text(
                          'Payment History',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: _T.textDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'View and manage payments for this invoice',
                          style: TextStyle(fontSize: 13, color: _T.textMuted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
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
                    onTap: () => context.pop(),
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
                        const Text(
                          'Payment History',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: _T.textDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'View and manage payments for this invoice',
                          style: TextStyle(fontSize: 13, color: _T.textMuted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInvoiceSummary(InvoiceModel invoice) {
    final balance = invoice.balanceAmount;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _T.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: _T.brandGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.receipt_long_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      invoice.invoiceNumber,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: _T.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    _buildStatusChip(invoice.status),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final vertical = constraints.maxWidth < 600;
              if (vertical) {
                return Column(
                  children: [
                    _summaryItem('Total Amount', '₹${invoice.totalAmount.toStringAsFixed(2)}', _T.textDark),
                    const SizedBox(height: 12),
                    _summaryItem('Paid Amount', '₹${invoice.paidAmount.toStringAsFixed(2)}', _T.success),
                    const SizedBox(height: 12),
                    _summaryItem('Balance', '₹${balance.toStringAsFixed(2)}', balance > 0 ? _T.danger : _T.success),
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(child: _summaryItem('Total Amount', '₹${invoice.totalAmount.toStringAsFixed(2)}', _T.textDark)),
                  const SizedBox(width: 12),
                  Expanded(child: _summaryItem('Paid Amount', '₹${invoice.paidAmount.toStringAsFixed(2)}', _T.success)),
                  const SizedBox(width: 12),
                  Expanded(child: _summaryItem('Balance', '₹${balance.toStringAsFixed(2)}', balance > 0 ? _T.danger : _T.success)),
                ],
              );
            },
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.08, end: 0);
  }

  Widget _summaryItem(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: _T.textMuted)),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordPaymentButton() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: _T.brandGradient,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: _T.gradientStart.withOpacity(0.25),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: SizedBox(
            height: 54,
            child: AppButton(
              text: 'Record Payment',
              variant: AppButtonVariant.primary,
              icon: Icons.add_rounded,
              onPressed: () => _showRecordPaymentDialog(context),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDesktopTable(BuildContext context, PaymentProvider provider) {
    return Container(
      decoration: _T.card(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: _T.divider),
            child: DataTable(
              horizontalMargin: 20,
              columnSpacing: 26,
              headingRowHeight: 56,
              dataRowMinHeight: 64,
              dataRowMaxHeight: 72,
              headingRowColor: MaterialStateProperty.all(const Color(0xFFF8FAFC)),
              columns: const [
                DataColumn(label: Text('Date')),
                DataColumn(label: Text('Amount')),
                DataColumn(label: Text('Mode')),
                DataColumn(label: Text('Reference')),
                DataColumn(label: Text('Notes')),
                DataColumn(label: Text('Actions')),
              ],
              rows: provider.payments.map((payment) {
                return DataRow(cells: [
                  DataCell(Text(payment.paymentDate.toFormattedDate())),
                  DataCell(Text(
                    '₹${payment.amount.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  )),
                  DataCell(_buildPaymentModeChip(payment.mode)),
                  DataCell(Text(payment.reference ?? 'N/A')),
                  DataCell(SizedBox(
                    width: 140,
                    child: Text(payment.notes ?? '', maxLines: 1, overflow: TextOverflow.ellipsis),
                  )),
                  DataCell(
                    _tableActionButton(
                      icon: Icons.delete_outline_rounded,
                      color: _T.danger,
                      onTap: () => _confirmDeletePayment(context, payment, provider),
                    ),
                  ),
                ]);
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _tableActionButton({required IconData icon, required Color color, required VoidCallback onTap}) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }

  Widget _buildMobileList(BuildContext context, PaymentProvider provider) {
    return SlidableAutoCloseBehavior(
      child: ListView.builder(
        itemCount: provider.payments.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          final payment = provider.payments[index];
          return _HoverCard(
            child: Slidable(
              key: ValueKey(payment.id),
              endActionPane: ActionPane(
                motion: const DrawerMotion(),
                children: [
                  SlidableAction(
                    onPressed: (_) => _confirmDeletePayment(context, payment, provider),
                    backgroundColor: _T.danger,
                    foregroundColor: Colors.white,
                    icon: Icons.delete,
                    label: 'Delete',
                  ),
                ],
              ),
              child: Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(16),
                decoration: _T.card(),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '₹${payment.amount.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: _T.textDark),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            payment.paymentDate.toFormattedDate(),
                            style: const TextStyle(fontSize: 12, color: _T.textMuted),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: [
                              _buildPaymentModeChip(payment.mode),
                              if (payment.reference != null && payment.reference!.isNotEmpty)
                                _infoPill(Icons.tag, payment.reference!),
                            ],
                          ),
                          if (payment.notes != null && payment.notes!.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              payment.notes!,
                              style: const TextStyle(fontSize: 12, color: _T.textMuted),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Icon(Icons.chevron_right_rounded, color: _T.textLight),
                  ],
                ),
              ),
            ),
          ).animate().fadeIn(delay: (index * 40).ms, duration: 240.ms);
        },
      ),
    );
  }

  Widget _buildPaymentModeChip(PaymentMode mode) {
    late Color color;
    late String label;
    late IconData icon;
    switch (mode) {
      case PaymentMode.cash:
        color = _T.success;
        label = 'Cash';
        icon = Icons.money_rounded;
      case PaymentMode.bankTransfer:
        color = _T.gradientStart;
        label = 'Bank Transfer';
        icon = Icons.account_balance_rounded;
      case PaymentMode.cheque:
        color = _T.warning;
        label = 'Cheque';
        icon = Icons.receipt_rounded;
      case PaymentMode.card:
        color = const Color(0xFF8B5CF6);
        label = 'Card';
        icon = Icons.credit_card_rounded;
      case PaymentMode.upi:
        color = const Color(0xFF06B6D4);
        label = 'UPI';
        icon = Icons.phone_android_rounded;
      case PaymentMode.online:
        color = _T.gradientEnd;
        label = 'Online';
        icon = Icons.language_rounded;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(InvoiceStatus status) {
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.3),
      ),
    );
  }

  Widget _infoPill(IconData icon, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _T.gradientStart.withOpacity(0.06),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: _T.gradientStart),
          const SizedBox(width: 5),
          Text(value, style: const TextStyle(fontSize: 11, color: _T.textDark, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return Column(
      children: List.generate(4, (index) => Container(
        height: 80,
        margin: const EdgeInsets.only(bottom: 14),
        decoration: _T.card(),
      )),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: _T.card(),
      child: const EmptyStateWidget(
        icon: Icons.payments_outlined,
        title: 'No Payments Recorded',
        message: 'Record a payment to track payments for this invoice.',
      ),
    );
  }

  void _showRecordPaymentDialog(BuildContext context) {
    final invoiceProvider = context.read<InvoiceProvider>();
    final invoice = invoiceProvider.selectedInvoice;
    if (invoice == null) return;

    final amountController = TextEditingController();
    final referenceController = TextEditingController();
    final notesController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    PaymentMode selectedMode = PaymentMode.cash;
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
              title: const Text('Record Payment', style: TextStyle(fontWeight: FontWeight.w800)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Invoice: ${invoice.invoiceNumber}',
                      style: const TextStyle(fontWeight: FontWeight.w600, color: _T.textMuted),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Balance: ₹${invoice.balanceAmount.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.w700, color: _T.textDark),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Amount *',
                        prefixIcon: const Icon(Icons.currency_rupee_rounded),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (date != null) {
                          setDialogState(() => selectedDate = date);
                        }
                      },
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Payment Date *',
                          prefixIcon: const Icon(Icons.calendar_today_rounded),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Text(selectedDate.toFormattedDate()),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<PaymentMode>(
                      value: selectedMode,
                      borderRadius: BorderRadius.circular(16),
                      decoration: InputDecoration(
                        labelText: 'Payment Mode *',
                        prefixIcon: const Icon(Icons.payment_rounded),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onChanged: (value) {
                        if (value != null) setDialogState(() => selectedMode = value);
                      },
                      items: PaymentMode.values.map((mode) {
                        return DropdownMenuItem(
                          value: mode,
                          child: Text(mode.name.split('.').last.replaceAllMapped(
                            RegExp(r'[A-Z]'), (m) => ' ${m.group(0)}'.toLowerCase(),
                          ).trim()),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: referenceController,
                      decoration: InputDecoration(
                        labelText: 'Reference',
                        prefixIcon: const Icon(Icons.tag_rounded),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: notesController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Notes',
                        prefixIcon: const Icon(Icons.notes_rounded),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isLoading ? null : () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: _T.brandGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextButton(
                    onPressed: isLoading
                        ? null
                        : () async {
                            final amount = double.tryParse(amountController.text);
                            if (amount == null || amount <= 0) {
                              context.showSnackBar('Please enter a valid amount', isError: true);
                              return;
                            }
                            if (amount > invoice.balanceAmount) {
                              context.showSnackBar('Amount exceeds balance', isError: true);
                              return;
                            }
                            setDialogState(() => isLoading = true);
                            try {
                              final paymentProvider = context.read<PaymentProvider>();
                              await paymentProvider.recordPayment(
                                invoiceId: widget.invoiceId,
                                amount: amount,
                                paymentDate: selectedDate,
                                mode: selectedMode,
                                reference: referenceController.text.trim().isEmpty
                                    ? null
                                    : referenceController.text.trim(),
                                notes: notesController.text.trim().isEmpty
                                    ? null
                                    : notesController.text.trim(),
                              );
                              if (dialogContext.mounted) {
                                Navigator.pop(dialogContext);
                                invoiceProvider.loadInvoiceDetails(widget.invoiceId);
                              }
                              if (context.mounted) {
                                context.showSnackBar('Payment recorded successfully');
                              }
                            } catch (e) {
                              if (context.mounted) {
                                context.showSnackBar('Failed to record payment: $e', isError: true);
                              }
                              if (dialogContext.mounted) {
                                setDialogState(() => isLoading = false);
                              }
                            }
                          },
                    child: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Record', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmDeletePayment(BuildContext context, PaymentModel payment, PaymentProvider provider) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          title: const Text('Delete Payment?', style: TextStyle(fontWeight: FontWeight.w800)),
          content: Text(
            'Are you sure you want to delete this payment of ₹${payment.amount.toStringAsFixed(2)}? This action cannot be undone.',
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
                    await provider.deletePayment(payment.id);
                    if (dialogContext.mounted) {
                      Navigator.pop(dialogContext);
                      context.read<InvoiceProvider>().loadInvoiceDetails(widget.invoiceId);
                    }
                    if (context.mounted) {
                      context.showSnackBar('Payment deleted successfully');
                    }
                  } catch (e) {
                    if (dialogContext.mounted) {
                      Navigator.pop(dialogContext);
                    }
                    if (context.mounted) {
                      context.showSnackBar('Failed to delete payment: $e', isError: true);
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

class _HoverCard extends StatefulWidget {
  final Widget child;
  const _HoverCard({required this.child});

  @override
  State<_HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<_HoverCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        transform: Matrix4.identity()..translate(0.0, _hovered ? -2.0 : 0.0),
        child: widget.child,
      ),
    );
  }
}
