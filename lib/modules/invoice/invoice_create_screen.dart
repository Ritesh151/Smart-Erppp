// lib/Pages/Bill_Invoice/invoice_create_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:siddhivinayak_enterprise/features/invoices/presentation/pages/create_invoice_page.dart';

class InvoiceCreateScreen extends ConsumerWidget {
  const InvoiceCreateScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const CreateInvoicePage();
  }
}
