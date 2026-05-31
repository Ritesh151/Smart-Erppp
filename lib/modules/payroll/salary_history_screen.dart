// lib/Pages/Payroll/salary_history_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:SmartERP/Providers/payroll_provider.dart';
import 'package:SmartERP/core/models/salary_history_model.dart';
import 'package:SmartERP/core/utils/currency_formatter.dart';
import 'package:SmartERP/core/utils/date_helper.dart';
import 'package:SmartERP/core/widgets/app_scaffold.dart';
import 'package:SmartERP/core/widgets/empty_state_widget.dart';
import 'package:SmartERP/core/widgets/loading_widget.dart';

class SalaryHistoryScreen extends ConsumerWidget {
  final String employeeId;
  const SalaryHistoryScreen({super.key, required this.employeeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentsAsync = ref.watch(salaryHistoryStreamProvider);
    final employees = ref.watch(employeesStreamProvider).asData?.value ?? [];
    final employee =
        employees.where((e) => e.employeeId == employeeId).firstOrNull;

    return AppScaffold(
      title: employee != null ? '${employee.fullName} — History' : 'Salary History',
      showBackButton: true,
      body: paymentsAsync.when(
        loading: () => Center(child: LoadingWidget()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (payments) {
          final filtered =
              payments.where((p) => p.employeeId == employeeId).toList();
          if (filtered.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.history,
              title: 'No Payments',
              message: 'No salary payments recorded yet.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: filtered.length,
            separatorBuilder: (_, __) => const SizedBox(height: 4),
            itemBuilder: (ctx, i) {
              final p = filtered[i];
              return Card(
                margin: EdgeInsets.zero,
                child: ListTile(
                  title: Text(
                      p.employeeName,
                      style: const TextStyle(fontWeight: FontWeight.w500)),
                  subtitle: Text(
                    '${p.paymentMethod.displayName} · ${DateHelper.display(p.paymentDate)}\n'
                    'Paid · ${p.id}',
                  ),
                  isThreeLine: true,
                  trailing: Text(
                    CurrencyFormatter.format(p.amount),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
