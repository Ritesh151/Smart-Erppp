import 'package:flutter/material.dart';
import 'package:smarterp/core/widgets/app_shell.dart';
import 'package:smarterp/core/widgets/empty_state_widget.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: EmptyStateWidget(
          icon: Icons.assessment,
          title: 'Reports & Analytics',
          message: 'View detailed business reports and analytics',
          actionLabel: 'Generate Report',
          onAction: () {},
        ),
      ),
    );
  }
}
