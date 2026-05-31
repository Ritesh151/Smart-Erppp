// lib/Pages/Payroll/attendance_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:siddhivinayak_enterprise/core/models/attendance_model.dart';
import 'package:siddhivinayak_enterprise/core/models/employee_model.dart';
import 'package:siddhivinayak_enterprise/Providers/attendance_provider.dart';
import 'package:siddhivinayak_enterprise/Providers/payroll_provider.dart';
import 'package:siddhivinayak_enterprise/core/widgets/app_scaffold.dart';
import 'package:siddhivinayak_enterprise/core/widgets/empty_state_widget.dart';
import 'package:siddhivinayak_enterprise/core/widgets/loading_widget.dart';

class AttendanceScreen extends ConsumerStatefulWidget {
  const AttendanceScreen({super.key});

  @override
  ConsumerState<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends ConsumerState<AttendanceScreen> {
  DateTime _selectedDate = DateTime.now();

  /// Map of attendanceId -> AttendanceModel for selected date
  Map<String, AttendanceModel> _attendanceMap = {};
  bool _isLoadingMap = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadForDate());
  }

  Future<void> _loadForDate() async {
    setState(() => _isLoadingMap = true);
    try {
      final map = await ref
          .read(attendanceServiceProvider)
          .fetchAttendanceForDate('', _selectedDate);
      if (!mounted) return;
      setState(() {
        _attendanceMap = map;
        _isLoadingMap = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingMap = false);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      if (!mounted) return;
      setState(() {
        _selectedDate = picked;
        _attendanceMap = {};
      });
      await _loadForDate();
    }
  }

  Future<void> _mark(EmployeeModel emp, AttendanceStatus status) async {
    final now = DateTime.now();
    final record = AttendanceModel(
      id: '${emp.id}_${_selectedDate.year}${_selectedDate.month}${_selectedDate.day}',
      employeeId: emp.id,
      employeeName: emp.fullName,
      date: DateTime(
          _selectedDate.year, _selectedDate.month, _selectedDate.day),
      status: status,
      createdAt: now,
      updatedAt: now,
    );
    try {
      await ref.read(attendanceControllerProvider).markAttendance(record);
      if (!mounted) return;
      setState(() => _attendanceMap[emp.id] = record);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '${emp.fullName} marked as ${status.displayLabel}'),
          duration: const Duration(seconds: 2),
          backgroundColor: status.color,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to mark attendance: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final employeesAsync = ref.watch(employeesStreamProvider);

    return AppScaffold(
      title: 'Attendance',
      showBackButton: true,
      body: Column(
        children: [
          // ── Date Selector Header ─────────────────────────────────────
          _DateHeader(
            selectedDate: _selectedDate,
            onTap: _pickDate,
          ),
          // ── Quick Stats ──────────────────────────────────────────────
          if (_attendanceMap.isNotEmpty)
            _AttendanceStats(attendanceMap: _attendanceMap),

          // ── Employee List ────────────────────────────────────────────
          Expanded(
            child: employeesAsync.when(
              loading: () => const LoadingWidget(),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (employees) {
                if (employees.isEmpty) {
                  return const EmptyStateWidget(
                    icon: Icons.people_outline,
                    title: 'No Employees',
                    message: 'Add employees first to track attendance.',
                  );
                }
                if (_isLoadingMap) return const LoadingWidget();
                return ListView.separated(
                  padding: const EdgeInsets.all(10),
                  itemCount: employees.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 6),
                  itemBuilder: (ctx, i) {
                    final emp = employees[i];
                    final existing = _attendanceMap[emp.id];
                    return _EmployeeAttendanceCard(
                      employee: emp,
                      currentStatus: existing?.status,
                      onMark: (status) => _mark(emp, status),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Date Header ──────────────────────────────────────────────────────────────
class _DateHeader extends StatelessWidget {
  final DateTime selectedDate;
  final VoidCallback onTap;

  const _DateHeader({required this.selectedDate, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isToday = _isSameDay(selectedDate, DateTime.now());
    return InkWell(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: Theme.of(context).colorScheme.surface,
        child: Row(
          children: [
            Icon(Icons.calendar_today_outlined,
                color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatDate(selectedDate),
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                if (isToday)
                  Text(
                    'Today',
                    style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.primary),
                  ),
              ],
            ),
            const Spacer(),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _formatDate(DateTime d) {
    const months = [
      '',
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${days[d.weekday - 1]}, ${d.day} ${months[d.month]} ${d.year}';
  }
}

// ── Attendance Stats Bar ─────────────────────────────────────────────────────
class _AttendanceStats extends StatelessWidget {
  final Map<String, AttendanceModel> attendanceMap;

  const _AttendanceStats({required this.attendanceMap});

  @override
  Widget build(BuildContext context) {
    final records = attendanceMap.values.toList();
    final present =
        records.where((r) => r.status == AttendanceStatus.present).length;
    final absent =
        records.where((r) => r.status == AttendanceStatus.absent).length;
    final leave =
        records.where((r) => r.status == AttendanceStatus.leave).length;
    final halfDay =
        records.where((r) => r.status == AttendanceStatus.halfDay).length;

    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
      child: Row(
        children: [
          _MiniStat(label: 'Present', value: '$present', color: Colors.green),
          _MiniStat(label: 'Absent', value: '$absent', color: Colors.red),
          _MiniStat(
              label: 'Leave', value: '$leave', color: Colors.blue),
          if (halfDay > 0)
            _MiniStat(
                label: 'Half Day',
                value: '$halfDay',
                color: Colors.orange),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MiniStat(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 3),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: [
              Text(value,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: color)),
              Text(label,
                  style:
                      const TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Employee Attendance Card ─────────────────────────────────────────────────
class _EmployeeAttendanceCard extends StatelessWidget {
  final EmployeeModel employee;
  final AttendanceStatus? currentStatus;
  final Function(AttendanceStatus) onMark;

  const _EmployeeAttendanceCard({
    required this.employee,
    required this.currentStatus,
    required this.onMark,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: currentStatus?.color.withOpacity(0.2) ??
                  Colors.grey.shade200,
              foregroundColor:
                  currentStatus?.color ?? Colors.grey.shade600,
              child: Text(employee.fullName[0].toUpperCase()),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(employee.fullName,
                      style:
                          const TextStyle(fontWeight: FontWeight.w600)),
                  Text(employee.designation,
                      style: const TextStyle(
                          fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
            // Status chips
            Wrap(
              spacing: 4,
              children: AttendanceStatus.values.map((status) {
                final isSelected = currentStatus == status;
                return GestureDetector(
                  onTap: () => onMark(status),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 5),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? status.color
                          : status.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isSelected
                            ? status.color
                            : status.color.withOpacity(0.3),
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Text(
                      status.shortLabel,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : status.color,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Extensions ───────────────────────────────────────────────────────────────
extension AttendanceStatusExt on AttendanceStatus {
  Color get color {
    switch (this) {
      case AttendanceStatus.present:
        return Colors.green;
      case AttendanceStatus.absent:
        return Colors.red;
      case AttendanceStatus.leave:
        return Colors.blue;
      case AttendanceStatus.halfDay:
        return Colors.orange;
      case AttendanceStatus.holiday:
        return Colors.teal;
    }
  }

  String get shortLabel {
    switch (this) {
      case AttendanceStatus.present:
        return 'P';
      case AttendanceStatus.absent:
        return 'A';
      case AttendanceStatus.leave:
        return 'L';
      case AttendanceStatus.halfDay:
        return 'H';
      case AttendanceStatus.holiday:
        return 'HD';
    }
  }

  String get displayLabel {
    switch (this) {
      case AttendanceStatus.present:
        return 'Present';
      case AttendanceStatus.absent:
        return 'Absent';
      case AttendanceStatus.leave:
        return 'Leave';
      case AttendanceStatus.halfDay:
        return 'Half Day';
      case AttendanceStatus.holiday:
        return 'Holiday';
    }
  }
}
