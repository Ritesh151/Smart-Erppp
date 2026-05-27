import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smarterp/core/constants/app_constants.dart';
import 'package:smarterp/core/extensions/context_extensions.dart';
import 'package:smarterp/core/widgets/app_shell.dart';
import 'package:smarterp/core/widgets/app_card.dart';
import 'package:smarterp/core/widgets/empty_state_widget.dart';
import 'package:smarterp/core/models/attendance_model.dart';
import 'package:smarterp/modules/payroll/providers/attendance_provider.dart';
import 'package:smarterp/modules/payroll/providers/employee_provider.dart';
import 'package:smarterp/modules/payroll/widgets/attendance_calendar_widget.dart';
import 'package:smarterp/modules/payroll/widgets/attendance_summary_widget.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AttendanceProvider>().loadRecords();
      final empProvider = context.read<EmployeeProvider>();
      if (empProvider.employees.isEmpty) {
        empProvider.loadEmployees();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final theme = context.theme;

    return AppShell(
      child: Consumer2<AttendanceProvider, EmployeeProvider>(
        builder: (context, attProvider, empProvider, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, attProvider),
                const SizedBox(height: 20),
                _buildCalendarSection(context, attProvider),
                const SizedBox(height: 20),
                _buildSummarySection(context, attProvider),
                const SizedBox(height: 20),
                _buildDayDetailSection(context, attProvider, empProvider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AttendanceProvider provider) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Attendance', style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold, color: colorScheme.onSurface,
            )),
            const SizedBox(height: 4),
            Text('Track employee attendance and manage records.',
              style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface.withOpacity(0.6)),
            ),
          ],
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () {
                final prev = DateTime(provider.selectedYear, provider.selectedMonth - 1, 1);
                provider.loadRecordsForMonth(prev.month, prev.year);
              },
            ),
            Text(
              '${_monthName(provider.selectedMonth)} ${provider.selectedYear}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () {
                final next = DateTime(provider.selectedYear, provider.selectedMonth + 1, 1);
                provider.loadRecordsForMonth(next.month, next.year);
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCalendarSection(BuildContext context, AttendanceProvider provider) {
    final colorScheme = Theme.of(context).colorScheme;

    if (provider.isLoading && provider.records.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final dayColors = <int, Color>{};
    final dayLabels = <int, String>{};
    final lastDay = DateTime(provider.selectedYear, provider.selectedMonth + 1, 0).day;

    for (var day = 1; day <= lastDay; day++) {
      final dayRecords = provider.records.where((r) => r.date.day == day).toList();
      if (dayRecords.isNotEmpty) {
        final statuses = dayRecords.map((r) => r.status).toSet();
        if (statuses.length == 1) {
          final color = _statusColor(statuses.first);
          if (color != null) dayColors[day] = color;
        } else {
          dayColors[day] = colorScheme.primary.withOpacity(0.3);
        }
        dayLabels[day] = '${dayRecords.length}';
      }
    }

    return AppCard(
      child: AttendanceCalendarWidget(
        month: provider.selectedMonth,
        year: provider.selectedYear,
        dayColors: dayColors,
        dayLabels: dayLabels,
        selectedDate: provider.selectedDate,
        onDaySelected: (date) => provider.setSelectedDate(date),
      ),
    );
  }

  Widget _buildSummarySection(BuildContext context, AttendanceProvider provider) {
    return AppCard(
      child: AttendanceSummaryWidget(
        presentCount: provider.presentCount,
        absentCount: provider.absentCount,
        halfDayCount: provider.halfDayCount,
        leaveCount: provider.leaveCount,
        holidayCount: provider.holidayCount,
        totalRecords: provider.totalRecords,
      ),
    );
  }

  Widget _buildDayDetailSection(
    BuildContext context,
    AttendanceProvider attProvider,
    EmployeeProvider empProvider,
  ) {
    final date = attProvider.selectedDate;
    final dayRecords = attProvider.recordsForSelectedDate;
    final employees = empProvider.employees;
    final existingEmployeeIds = dayRecords.map((r) => r.employeeId).toSet();

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${date.day} ${_monthName(date.month)} ${date.year}',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              if (employees.isNotEmpty)
                PopupMenuButton<AttendanceStatus>(
                  tooltip: 'Mark all as',
                  child: const Chip(
                    label: Text('Bulk Mark', style: TextStyle(fontSize: 11)),
                    avatar: Icon(Icons.edit, size: 14),
                    visualDensity: VisualDensity.compact,
                  ),
                  onSelected: (status) async {
                    try {
                      await attProvider.markBulkAttendance(
                        employeeIds: employees.map((e) => e.id).toList(),
                        employeeNames: employees.map((e) => e.fullName).toList(),
                        date: date,
                        status: status,
                      );
                      if (context.mounted) {
                        context.showSnackBar('Attendance marked for ${employees.length} employees');
                      }
                    } catch (e) {
                      if (context.mounted) {
                        context.showSnackBar('Failed to mark attendance: $e', isError: true);
                      }
                    }
                  },
                  itemBuilder: (context) => AttendanceStatus.values.map((status) {
                    return PopupMenuItem(
                      value: status,
                      child: Row(
                        children: [
                          Icon(Icons.circle, size: 12, color: _statusColor(status)),
                          const SizedBox(width: 8),
                          Text(status.displayName),
                        ],
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (employees.isEmpty)
            const EmptyStateWidget(
              icon: Icons.people_outline,
              title: 'No Employees',
              message: 'Add employees to start tracking attendance.',
            )
          else
            ...employees.map((emp) {
              final record = dayRecords.where((r) => r.employeeId == emp.id).firstOrNull;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: _statusColor(record?.status)?.withOpacity(0.1) ?? Colors.grey.shade100,
                      child: Text(
                        emp.fullName.isNotEmpty ? emp.fullName[0].toUpperCase() : '?',
                        style: TextStyle(fontSize: 12, color: _statusColor(record?.status) ?? Colors.grey),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(emp.fullName, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                          Text(emp.designation, style: TextStyle(fontSize: 11, color: Colors.grey)),
                        ],
                      ),
                    ),
                    _buildStatusSelector(
                      context,
                      attProvider,
                      emp.id,
                      emp.fullName,
                      date,
                      record?.status,
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildStatusSelector(
    BuildContext context,
    AttendanceProvider attProvider,
    String employeeId,
    String employeeName,
    DateTime date,
    AttendanceStatus? currentStatus,
  ) {
    return PopupMenuButton<AttendanceStatus>(
      initialValue: currentStatus,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: _statusColor(currentStatus)?.withOpacity(0.08) ?? Colors.grey.shade50,
          borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
          border: Border.all(
            color: _statusColor(currentStatus)?.withOpacity(0.25) ?? Colors.grey.shade200,
          ),
        ),
        child: Text(
          currentStatus?.displayName ?? 'Mark',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: _statusColor(currentStatus) ?? Colors.grey,
          ),
        ),
      ),
      onSelected: (status) async {
        try {
          await attProvider.markAttendance(
            employeeId: employeeId,
            employeeName: employeeName,
            date: date,
            status: status,
          );
        } catch (e) {
          if (context.mounted) {
            context.showSnackBar('Failed to update attendance: $e', isError: true);
          }
        }
      },
      itemBuilder: (context) => AttendanceStatus.values.map((status) {
        return PopupMenuItem(
          value: status,
          child: Row(
            children: [
              Icon(Icons.circle, size: 12, color: _statusColor(status)),
              const SizedBox(width: 8),
              Text(status.displayName),
            ],
          ),
        );
      }).toList(),
    );
  }

  Color? _statusColor(AttendanceStatus? status) {
    if (status == null) return null;
    switch (status) {
      case AttendanceStatus.present: return Colors.green;
      case AttendanceStatus.absent: return Colors.red;
      case AttendanceStatus.halfDay: return Colors.orange;
      case AttendanceStatus.leave: return Colors.blue;
      case AttendanceStatus.holiday: return Colors.purple;
    }
  }

  String _monthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }
}
