import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:siddhivinayak_enterprise/core/models/invoice_item_model.dart';
import 'package:siddhivinayak_enterprise/core/models/invoice_model.dart';
import 'package:siddhivinayak_enterprise/modules/invoice/providers/whatsapp_provider.dart';
import 'package:siddhivinayak_enterprise/modules/invoice/utils/whatsapp_helper.dart';

class WhatsAppSendButton extends StatefulWidget {
  final InvoiceModel invoice;
  final List<InvoiceItemModel> items;
  final String? customerPhone;
  final bool showIcon;
  final bool showText;
  final bool useAndroidIntent;
  final VoidCallback? onSent;
  final VoidCallback? onError;

  const WhatsAppSendButton({
    super.key,
    required this.invoice,
    required this.items,
    this.customerPhone,
    this.showIcon = true,
    this.showText = true,
    this.useAndroidIntent = true,
    this.onSent,
    this.onError,
  });

  @override
  State<WhatsAppSendButton> createState() => _WhatsAppSendButtonState();
}

class _WhatsAppSendButtonState extends State<WhatsAppSendButton> {
  bool _isSending = false;

  static const _whatsappGreen = Color(0xFF25D366);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ElevatedButton.icon(
        onPressed: _isSending ? null : _handleSend,
        icon: _isSending
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : (widget.showIcon
                ? Icon(Icons.chat_bubble_rounded, size: 20)
                : const SizedBox.shrink()),
        label: Text(
          _isSending ? 'Sending...' : (widget.showText ? 'WhatsApp' : ''),
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: _whatsappGreen,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey.shade400,
          disabledForegroundColor: Colors.white70,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Future<void> _handleSend() async {
    if (_isSending) return;

    final customerPhone = widget.customerPhone ?? widget.invoice.customerPhone;

    if (customerPhone == null || customerPhone.trim().isEmpty) {
      _showError('Customer phone number is not available');
      widget.onError?.call();
      return;
    }

    final normalizedPhone = WhatsAppHelper.normalizePhoneNumber(customerPhone);
    if (!WhatsAppHelper.isValidPhoneNumber(normalizedPhone)) {
      _showError('Invalid phone number: $customerPhone');
      widget.onError?.call();
      return;
    }

    setState(() => _isSending = true);

    try {
      final whatsappProvider = context.read<WhatsAppProvider>();
      final success = await whatsappProvider.sendInvoiceWithAutoMessage(
        customerPhone: normalizedPhone,
        invoice: widget.invoice,
        items: widget.items,
        useShortFormat: false,
        useAndroidIntent:
            widget.useAndroidIntent && WhatsAppHelper.isAndroid(),
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Invoice sent successfully via WhatsApp'),
            backgroundColor: _whatsappGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );
        widget.onSent?.call();
      } else {
        _showError('Failed to send invoice via WhatsApp');
        widget.onError?.call();
      }
    } catch (e) {
      if (!mounted) return;
      _showError(e.toString());
      widget.onError?.call();
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
