import 'package:SmartERP/core/models/notification_model.dart';
import 'package:SmartERP/core/utils/logger.dart';
import 'package:SmartERP/modules/payroll/services/payroll_service.dart';
import 'package:SmartERP/modules/settings/services/notification_service.dart';
import 'package:SmartERP/modules/settings/services/settings_service.dart';

class SalaryReminderResult {
  final int pendingCount;
  final double totalPendingAmount;
  final List<SalaryReminderItem> reminders;

  SalaryReminderResult({
    required this.pendingCount,
    required this.totalPendingAmount,
    required this.reminders,
  });

  bool get hasReminders => pendingCount > 0;
}

class SalaryReminderItem {
  final String employeeId;
  final String employeeName;
  final double amount;
  final int month;
  final int year;
  final bool isOverdue;

  SalaryReminderItem({
    required this.employeeId,
    required this.employeeName,
    required this.amount,
    required this.month,
    required this.year,
    required this.isOverdue,
  });

  String get label {
    final months = ['Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'];
    return '$employeeName - ${months[month - 1]} $year';
  }
}

class SalaryReminderService {
  final PayrollService _payrollService;
  final NotificationService _notificationService;
  final SettingsService _settingsService;
  DateTime? _lastCheckDate;

  SalaryReminderService({
    required PayrollService payrollService,
    required NotificationService notificationService,
    required SettingsService settingsService,
  })  : _payrollService = payrollService,
        _notificationService = notificationService,
        _settingsService = settingsService;

  Future<bool> isEnabled() async {
    return await _settingsService.isSalaryReminderEnabled();
  }

  Future<void> setEnabled(bool enabled) async {
    await _settingsService.toggleSalaryReminder(enabled);
  }

  Future<SalaryReminderResult> checkPendingSalaries() async {
    try {
      if (!await isEnabled()) {
        return SalaryReminderResult(
          pendingCount: 0, totalPendingAmount: 0, reminders: [],
        );
      }

      final now = DateTime.now();
      final monthSalaries = await _payrollService.getMonthlySalaries(now.month, now.year);

      final reminders = <SalaryReminderItem>[];
      for (final salary in monthSalaries) {
        if (salary.status.name == 'pending' || salary.status.name == 'overdue') {
          reminders.add(SalaryReminderItem(
            employeeId: salary.employeeId,
            employeeName: salary.employeeName,
            amount: salary.pendingAmount,
            month: salary.month,
            year: salary.year,
            isOverdue: salary.status.name == 'overdue',
          ));
        }
      }

      _lastCheckDate = now;
      return SalaryReminderResult(
        pendingCount: reminders.length,
        totalPendingAmount:
            reminders.fold(0.0, (sum, r) => sum + r.amount),
        reminders: reminders,
      );
    } catch (e, stackTrace) {
      Logger.error('Failed to check pending salaries', e, stackTrace);
      return SalaryReminderResult(
        pendingCount: 0, totalPendingAmount: 0, reminders: [],
      );
    }
  }

  Future<void> sendReminders() async {
    try {
      if (!await isEnabled()) {
        Logger.info('Salary reminders are disabled');
        return;
      }

      final result = await checkPendingSalaries();
      if (!result.hasReminders) {
        Logger.info('No pending salaries to remind about');
        return;
      }

      for (final item in result.reminders) {
        await _notificationService.createNotification(
          title: item.isOverdue ? 'Overdue Salary' : 'Salary Reminder',
          message: '${item.employeeName} has ₹${item.amount.toStringAsFixed(0)} pending for ${item.month}/${item.year}',
          category: NotificationCategory.salaryReminder,
          priority: item.isOverdue
              ? NotificationPriority.high
              : NotificationPriority.medium,
          referenceId: item.employeeId,
          referenceType: 'salary',
        );
      }

      Logger.info('Sent ${result.pendingCount} salary reminders');
    } catch (e, stackTrace) {
      Logger.error('Failed to send salary reminders', e, stackTrace);
    }
  }

  Future<SalaryReminderResult> getMonthlySummary(int month, int year) async {
    try {
      final salaries = await _payrollService.getMonthlySalaries(month, year);
      final reminders = <SalaryReminderItem>[];

      for (final salary in salaries) {
        if (salary.pendingAmount > 0) {
          reminders.add(SalaryReminderItem(
            employeeId: salary.employeeId,
            employeeName: salary.employeeName,
            amount: salary.pendingAmount,
            month: salary.month,
            year: salary.year,
            isOverdue: salary.month < DateTime.now().month - 1,
          ));
        }
      }

      return SalaryReminderResult(
        pendingCount: reminders.length,
        totalPendingAmount:
            reminders.fold(0.0, (sum, r) => sum + r.amount),
        reminders: reminders,
      );
    } catch (e, stackTrace) {
      Logger.error('Failed to get monthly salary summary', e, stackTrace);
      return SalaryReminderResult(
        pendingCount: 0, totalPendingAmount: 0, reminders: [],
      );
    }
  }

  Future<int> getPendingCount() async {
    try {
      if (!await isEnabled()) return 0;
      final dashboard = await _payrollService.getDashboardData();
      return dashboard.pendingCount;
    } catch (e) {
      return 0;
    }
  }

  Future<double> getPendingTotal() async {
    try {
      if (!await isEnabled()) return 0;
      final dashboard = await _payrollService.getDashboardData();
      return dashboard.totalPending;
    } catch (e) {
      return 0;
    }
  }

  DateTime? get lastCheckDate => _lastCheckDate;
}
