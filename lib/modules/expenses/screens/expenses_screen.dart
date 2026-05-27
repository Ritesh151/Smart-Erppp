import 'package:flutter/material.dart';
import 'package:smarterp/core/widgets/app_shell.dart';
import 'package:smarterp/core/widgets/empty_state_widget.dart';

class ExpensesScreen extends StatelessWidget {
  const ExpensesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: EmptyStateWidget(
          icon: Icons.payments,
          title: 'Expense Management',
          message: 'Track and manage business expenses',
          actionLabel: 'Add Expense',
          onAction: () {},
        ),
      ),
    );
  }
}
