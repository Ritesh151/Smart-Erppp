import 'package:flutter/material.dart';
import 'package:smarterp/core/widgets/app_shell.dart';
import 'package:smarterp/core/widgets/empty_state_widget.dart';

class PayrollScreen extends StatelessWidget {
  const PayrollScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: EmptyStateWidget(
          icon: Icons.people,
          title: 'Payroll Management',
          message: 'Manage employee salaries and payroll',
          actionLabel: 'Add Employee',
          onAction: () {},
        ),
      ),
    );
  }
}
