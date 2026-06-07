import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:siddhivinayak_enterprise/core/models/invoice_model.dart';
import 'package:siddhivinayak_enterprise/core/widgets/app_button.dart';
import 'package:siddhivinayak_enterprise/core/widgets/app_card.dart';
import 'package:siddhivinayak_enterprise/core/widgets/empty_state_widget.dart';
import 'package:siddhivinayak_enterprise/core/widgets/loading_widget.dart';
import 'package:siddhivinayak_enterprise/modules/invoice/models/whatsapp_invoice_model.dart';
import 'package:siddhivinayak_enterprise/modules/invoice/providers/whatsapp_provider.dart';
import 'package:siddhivinayak_enterprise/modules/invoice/utils/whatsapp_helper.dart';
import 'package:siddhivinayak_enterprise/modules/invoice/widgets/whatsapp_send_button.dart';

class WhatsAppHistoryScreen extends StatefulWidget {
  const WhatsAppHistoryScreen({super.key});

  @override
  State<WhatsAppHistoryScreen> createState() => _WhatsAppHistoryScreenState();
}

class _WhatsAppHistoryScreenState extends State<WhatsAppHistoryScreen> {
  final _searchController = TextEditingController();
  bool _isSearching = false;

  static const _primaryColor = Color(0xFF4F6EF7);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        'WhatsApp History',
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface,
            ),
      ),
      leading: IconButton(
        icon: Icon(Icons.arrow_back,
            color: Theme.of(context).colorScheme.onSurface),
        onPressed: () => context.pop(),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.search,
              color: Theme.of(context).colorScheme.onSurface),
          onPressed: _showSearchDialog,
        ),
        IconButton(
          icon: Icon(Icons.filter_list,
              color: Theme.of(context).colorScheme.onSurface),
          onPressed: _showFilterMenu,
        ),
      ],
    );
  }

  Widget _buildBody() {
    return Consumer<WhatsAppProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const LoadingWidget();
        }

        final history = provider.sendHistory;

        if (history.isEmpty) {
          return EmptyStateWidget(
            icon: Icons.chat_bubble_outline_rounded,
            title: 'No WhatsApp Messages',
            message:
                'Invoices will appear here after being sent via WhatsApp',
            actionLabel: provider.totalCount == 0 ? 'Send Test Invoice' : null,
            onAction: provider.totalCount == 0 ? () {} : null,
          );
        }

        return RefreshIndicator(
          onRefresh: () => provider.loadHistory(),
          color: _primaryColor,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: history.length,
            itemBuilder: (context, index) {
              final item = history[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildHistoryItem(context, item),
              );
            },
          ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.04, end: 0),
        );
      },
    );
  }

  Widget _buildHistoryItem(BuildContext context, WhatsAppInvoiceModel item) {
    final successColor = item.success ? Colors.green : Colors.red;

    return AppCard(
      onTap: () => _showMessageDetails(context, item),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF25D366).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.chat_bubble_rounded,
                  color: const Color(0xFF25D366),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.customerName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          item.invoiceNumber,
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.7),
                              ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: successColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                item.success
                                    ? Icons.check_circle_rounded
                                    : Icons.error_outline_rounded,
                                color: successColor,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                item.success ? 'Sent' : 'Failed',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: successColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _formatDate(item.sentAt),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.7),
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(context).dividerColor.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    _truncateMessage(item.formattedMessage),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () => _resendMessage(context, item),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.refresh_rounded,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('d MMM, h:mm a').format(date);
  }

  String _truncateMessage(String message) {
    if (message.length <= 100) return message;
    return '${message.substring(0, 100)}...';
  }

  void _showSearchDialog() {
    showSearch(
      context: context,
      delegate: WhatsAppHistorySearchDelegate(),
    );
  }

  void _showFilterMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Filter by Status',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 20),
              _buildFilterOption(
                context,
                label: 'All Messages',
                isActive:
                    context.read<WhatsAppProvider>().filterSuccessStatus == null,
                onTap: () {
                  context.read<WhatsAppProvider>().filterByStatus(null);
                  context.pop();
                },
              ),
              const SizedBox(height: 12),
              _buildFilterOption(
                context,
                label: 'Sent Successfully',
                isActive:
                    context.read<WhatsAppProvider>().filterSuccessStatus == true,
                color: Colors.green,
                onTap: () {
                  context.read<WhatsAppProvider>().filterByStatus(true);
                  context.pop();
                },
              ),
              const SizedBox(height: 12),
              _buildFilterOption(
                context,
                label: 'Failed to Send',
                isActive:
                    context.read<WhatsAppProvider>().filterSuccessStatus == false,
                color: Colors.red,
                onTap: () {
                  context.read<WhatsAppProvider>().filterByStatus(false);
                  context.pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterOption(
    BuildContext context, {
    required String label,
    required bool isActive,
    Color? color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isActive
              ? (color ?? Theme.of(context).colorScheme.primary).withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive
                ? (color ?? Theme.of(context).colorScheme.primary)
                : Theme.of(context).dividerColor,
          ),
        ),
        child: Row(
          children: [
            if (isActive) ...[
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: color ?? Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 14,
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                    ),
              ),
            ),
            if (!isActive) ...[
              Icon(
                Icons.chevron_right_rounded,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withOpacity(0.3),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showMessageDetails(BuildContext context, WhatsAppInvoiceModel item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: ListView(
                controller: scrollController,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.chat_bubble_rounded,
                        color: const Color(0xFF25D366),
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.customerName,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                            Text(
                              item.invoiceNumber,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.7),
                                  ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: item.success
                              ? Colors.green.withOpacity(0.1)
                              : Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          item.success ? 'Sent' : 'Failed',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: item.success ? Colors.green : Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Message',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context)
                            .dividerColor
                            .withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      item.formattedMessage,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontFamily: 'monospace',
                            fontSize: 13,
                          ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDetailRow(
                          context,
                          'Customer Phone',
                          WhatsAppHelper.formatPhoneNumberForDisplay(
                              item.customerPhone),
                          Icons.phone_rounded,
                        ),
                      ),
                      Expanded(
                        child: _buildDetailRow(
                          context,
                          'Sent At',
                          _formatDate(item.sentAt),
                          Icons.access_time_rounded,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (item.errorMessage != null && !item.success) ...[
                    Text(
                      'Error',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.withOpacity(0.2)),
                      ),
                      child: Text(
                        item.errorMessage!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.red,
                            ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          text: 'Resend',
                          onPressed: () {
                            context.pop();
                            _resendMessage(context, item);
                          },
                          icon: Icons.refresh_rounded,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
            color: Theme.of(context).dividerColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon,
              size: 18,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withOpacity(0.5)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.7),
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _resendMessage(
      BuildContext context, WhatsAppInvoiceModel item) async {
    context.pop();

    final whatsappProvider = context.read<WhatsAppProvider>();
    final customerPhone = item.customerPhone;

    if (customerPhone != null) {
      final success = await whatsappProvider.sendInvoice(
        customerPhone: customerPhone,
        invoice: InvoiceModel(
          id: item.invoiceId,
          invoiceNumber: item.invoiceNumber,
          customerId: item.customerId,
          customerName: item.customerName,
          customerPhone: item.customerPhone,
          invoiceDate: item.sentAt,
          dueDate: item.sentAt.add(const Duration(days: 7)),
          itemIds: [],
          subtotal: 0,
          taxAmount: 0,
          totalAmount: 0,
          discountAmount: 0,
          paidAmount: 0,
          status: InvoiceStatus.draft,
          createdAt: item.sentAt,
          updatedAt: item.sentAt,
        ),
        items: [],
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invoice resent successfully'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}

class WhatsAppHistorySearchDelegate extends SearchDelegate {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
          showSuggestions(context);
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return const Center(
      child: Text('Search functionality to be implemented'),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return const Center(
      child: Text('Start typing to search'),
    );
  }
}
