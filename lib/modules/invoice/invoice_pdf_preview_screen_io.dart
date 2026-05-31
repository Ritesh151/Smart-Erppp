import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:siddhivinayak_enterprise/core/widgets/app_scaffold.dart';
import 'package:siddhivinayak_enterprise/local_db/hive_boxes.dart';
import 'package:siddhivinayak_enterprise/local_db/models/local_invoice.dart';

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

        final invoice = LocalInvoice.fromMap(Map<String, dynamic>.from(raw));
        if (invoice.pdfPath.isEmpty) {
          return AppScaffold(
            title: invoice.invoiceNumber,
            body: const Center(child: Text('PDF path not found for this invoice.')),
          );
        }

        final file = File(invoice.pdfPath);
        if (!file.existsSync()) {
          return AppScaffold(
            title: invoice.invoiceNumber,
            body: Center(child: Text('PDF file missing: ${invoice.pdfPath}')),
          );
        }

        return AppScaffold(
          title: invoice.invoiceNumber,
          backRoute: '/invoices',
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.picture_as_pdf, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('PDF: ${invoice.pdfPath}'),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              context.push('/transports/add?invoiceId=$invoiceId');
            },
            icon: const Icon(Icons.local_shipping),
            label: const Text('Create Transport'),
          ),
        );
      },
    );
  }
}
