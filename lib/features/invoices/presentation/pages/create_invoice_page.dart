import 'package:flutter/material.dart';

class CreateInvoicePage extends StatelessWidget {
  const CreateInvoicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Invoice')),
      body: const Center(
        child: Text('Invoice creation form'),
      ),
    );
  }
}
