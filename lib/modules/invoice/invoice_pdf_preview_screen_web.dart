import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:SmartERP/core/widgets/app_scaffold.dart';
import 'package:SmartERP/local_db/hive_boxes.dart';
import 'package:SmartERP/local_db/models/local_invoice.dart';

class InvoicePdfPreviewScreen extends StatelessWidget {
  final String invoiceId;

  const InvoicePdfPreviewScreen({required this.invoiceId, super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box<Map>>(
      valueListenable: HiveBoxes.invoicesBox().listenable(keys: [invoiceId]),
      builder: (context, box, _) {
        final raw = box.get(invoiceId);
        if (raw is! Map) {
          return const AppScaffold(
            title: 'Invoice Preview',
            body: Center(child: Text('Invoice not found.')),
          );
        }

        final invoice = LocalInvoice.fromMap(raw);
        final b64 = invoice.pdfBytesBase64;
        if (b64 == null || b64.isEmpty) {
          return AppScaffold(
            title: invoice.invoiceNumber,
            body: const Center(
              child: Text('PDF bytes not stored for this invoice on Web.'),
            ),
          );
        }

        final bytes = base64Decode(b64);
        return AppScaffold(
          title: invoice.invoiceNumber,
          backRoute: '/invoices',
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.picture_as_pdf, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('PDF loaded (${bytes.length} bytes)'),
              ],
            ),
          ),
        );
      },
    );
  }
}
