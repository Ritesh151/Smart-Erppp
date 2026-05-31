import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:SmartERP/Providers/payroll_provider.dart';
import 'package:SmartERP/core/models/employee_model.dart';
import 'package:SmartERP/core/models/salary_history_model.dart';
import 'package:SmartERP/core/utils/currency_formatter.dart';
import 'package:SmartERP/core/utils/date_helper.dart';
import 'package:SmartERP/core/widgets/app_scaffold.dart';
import 'package:SmartERP/core/widgets/loading_widget.dart';

class SalaryPaymentScreen extends ConsumerStatefulWidget {
  final String employeeId;

  const SalaryPaymentScreen({super.key, required this.employeeId});

  @override
  ConsumerState<SalaryPaymentScreen> createState() =>
      _SalaryPaymentScreenState();
}

class _SalaryPaymentScreenState extends ConsumerState<SalaryPaymentScreen> {
  DateTime _paymentDate = DateTime.now();
  PaymentMethod _paymentMethod = PaymentMethod.cash;
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    final employeesAsync = ref.watch(employeesStreamProvider);
    final salariesAsync = ref.watch(salaryPaymentsStreamProvider);

    return AppScaffold(
      title: 'Pay Salary',
      showBackButton: true,
      body: employeesAsync.when(
        loading: () => const LoadingWidget(),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (employees) {
          final employee = employees
              .where((e) => e.employeeId == widget.employeeId)
              .firstOrNull;
          if (employee == null) {
            return const Center(child: Text('Employee not found'));
          }

          final salaries = salariesAsync.asData?.value ?? [];
          final existingSalary = salaries
              .where((s) =>
                  s.employeeId == employee.employeeId &&
                  s.month == _paymentDate.month &&
                  s.year == _paymentDate.year)
              .firstOrNull;
          final alreadyPaid = existingSalary?.paidAmount ?? 0;
          final remaining =
              (employee.salary - alreadyPaid).clamp(0.0, double.infinity);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        child: Text(employee.fullName[0].toUpperCase()),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              employee.fullName,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text(employee.designation),
                            if (employee.department.isNotEmpty)
                              Text(
                                employee.department,
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _AmountRow(
                label: 'Monthly Salary',
                amount: employee.salary,
                color: Colors.blue,
              ),
              _AmountRow(
                label: 'Already Paid',
                amount: alreadyPaid,
                color: Colors.green,
              ),
              _AmountRow(
                label: 'Amount To Pay',
                amount: remaining,
                color: remaining > 0 ? Colors.orange : Colors.green,
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today_outlined),
                title: const Text('Payment Date'),
                subtitle: Text(DateHelper.display(_paymentDate)),
                trailing: const Icon(Icons.chevron_right),
                onTap: _isSaving
                    ? null
                    : () async {
                        final selected = await showDatePicker(
                          context: context,
                          initialDate: _paymentDate,
                          firstDate: DateTime(DateTime.now().year - 5),
                          lastDate: DateTime(DateTime.now().year + 1),
                        );
                        if (selected != null && mounted) {
                          setState(() => _paymentDate = selected);
                        }
                      },
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<PaymentMethod>(
                value: _paymentMethod,
                decoration: const InputDecoration(
                  labelText: 'Payment Mode',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.account_balance_wallet_outlined),
                ),
                items: const [
                  DropdownMenuItem(
                    value: PaymentMethod.cash,
                    child: Text('Cash'),
                  ),
                  DropdownMenuItem(
                    value: PaymentMethod.bankTransfer,
                    child: Text('Bank Transfer'),
                  ),
                ],
                onChanged: _isSaving
                    ? null
                    : (value) {
                        if (value != null) {
                          setState(() => _paymentMethod = value);
                        }
                      },
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: remaining > 0 && !_isSaving
                    ? () => _confirmPayment(employee)
                    : null,
                icon: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check_circle_outline),
                label: Text(_isSaving ? 'Saving...' : 'Confirm Payment'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _confirmPayment(EmployeeModel employee) async {
    setState(() => _isSaving = true);
    try {
      final transaction = await ref.read(payrollControllerProvider).paySalary(
            employee: employee,
            paymentDate: _paymentDate,
            paymentMethod: _paymentMethod,
          );

      ref.invalidate(salaryPaymentsStreamProvider);
      ref.invalidate(salaryHistoryStreamProvider);

      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          icon: const Icon(Icons.check_circle, color: Colors.green, size: 42),
          title: const Text('Salary Paid'),
          content: Text(
            '${employee.fullName}\n'
            '${CurrencyFormatter.format(transaction.amount)}\n'
            'Transaction: ${transaction.id}',
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      if (mounted) context.go('/payroll');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pay salary: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}

class _AmountRow extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;

  const _AmountRow({
    required this.label,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(label),
        trailing: Text(
          CurrencyFormatter.format(amount),
          style: TextStyle(fontWeight: FontWeight.bold, color: color),
        ),
      ),
    );
  }
}
