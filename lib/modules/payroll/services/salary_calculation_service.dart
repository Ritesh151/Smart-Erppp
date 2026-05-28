class SalaryCalculationService {
  double calculateNetSalary({
    required double basicSalary,
    double bonus = 0,
    double overtime = 0,
    double deductions = 0,
  }) {
    return (basicSalary + bonus + overtime - deductions).clamp(0, double.infinity);
  }

  double calculateProRatedSalary({
    required double monthlySalary,
    required int daysPresent,
    required int totalDaysInMonth,
  }) {
    if (totalDaysInMonth <= 0) return 0;
    return (monthlySalary / totalDaysInMonth) * daysPresent;
  }

  double calculateOvertime({
    required double hourlyRate,
    required double overtimeHours,
    double multiplier = 1.5,
  }) {
    return hourlyRate * overtimeHours * multiplier;
  }
}
