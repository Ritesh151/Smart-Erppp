import 'package:smarterp/core/exceptions/app_exception.dart';
import 'package:smarterp/core/models/salary_model.dart';
import 'package:smarterp/core/models/salary_history_model.dart';
import 'package:smarterp/core/utils/logger.dart';
import 'package:smarterp/modules/payroll/repositories/salary_repository.dart';

class SalaryService {
  final SalaryRepository _repository;

  SalaryService(this._repository);

  Future<List<SalaryModel>> getAllSalaries() async {
    try {
      return await _repository.getAll();
    } catch (e, stackTrace) {
      Logger.error('Failed to get all salaries', e, stackTrace);
      rethrow;
    }
  }

  Future<SalaryModel?> getSalaryById(String id) async {
    try {
      return await _repository.getById(id);
    } catch (e, stackTrace) {
      Logger.error('Failed to get salary by id', e, stackTrace);
      return null;
    }
  }

  Future<SalaryModel> generateSalary({
    required String employeeId,
    required String employeeName,
    required int month,
    required int year,
    required double basicSalary,
    double bonus = 0,
    double overtime = 0,
    double deductions = 0,
    String? notes,
  }) async {
    try {
      final existing = await _repository.getByEmployeeAndMonth(employeeId, month, year);
      if (existing != null) {
        throw ValidationException(
          'Salary already exists for $employeeName for ${month}/$year',
        );
      }

      final salary = SalaryModel.create(
        employeeId: employeeId,
        employeeName: employeeName,
        month: month,
        year: year,
        basicSalary: basicSalary,
        bonus: bonus,
        overtime: overtime,
        deductions: deductions,
        notes: notes,
      );

      await _repository.save(salary);
      Logger.success('Salary generated: $employeeName - ${month}/$year');
      return salary;
    } on ValidationException {
      rethrow;
    } catch (e, stackTrace) {
      Logger.error('Failed to generate salary', e, stackTrace);
      rethrow;
    }
  }

  Future<SalaryModel> updateSalary({
    required String id,
    double? bonus,
    double? overtime,
    double? deductions,
    String? notes,
  }) async {
    try {
      final existing = await _repository.getById(id);
      if (existing == null) throw NotFoundException('Salary not found');

      if (existing.isFullyPaid) {
        throw ValidationException('Cannot modify a fully paid salary');
      }

      final effectiveBonus = bonus ?? existing.bonus;
      final effectiveOvertime = overtime ?? existing.overtime;
      final effectiveDeductions = deductions ?? existing.deductions;
      final netSalary = existing.basicSalary + effectiveBonus + effectiveOvertime - effectiveDeductions;

      final updated = existing.copyWith(
        bonus: effectiveBonus,
        overtime: effectiveOvertime,
        deductions: effectiveDeductions,
        netSalary: netSalary < 0 ? 0 : netSalary,
        notes: notes ?? existing.notes,
        updatedAt: DateTime.now(),
      );

      await _repository.update(updated);
      Logger.success('Salary updated: ${existing.employeeName}');
      return updated;
    } on AppException {
      rethrow;
    } catch (e, stackTrace) {
      Logger.error('Failed to update salary', e, stackTrace);
      rethrow;
    }
  }

  Future<SalaryModel> processPayment({
    required String salaryId,
    required double amount,
    required PaymentMethod paymentMethod,
    String? referenceNumber,
    String? notes,
  }) async {
    try {
      final salary = await _repository.getById(salaryId);
      if (salary == null) throw NotFoundException('Salary not found');

      if (salary.isFullyPaid) {
        throw ValidationException('Salary is already fully paid');
      }

      final newPaidAmount = salary.paidAmount + amount;
      if (newPaidAmount > salary.netSalary) {
        throw ValidationException('Payment amount exceeds pending balance');
      }

      SalaryStatus newStatus;
      if (newPaidAmount >= salary.netSalary) {
        newStatus = SalaryStatus.paid;
      } else {
        newStatus = SalaryStatus.partiallyPaid;
      }

      final paymentType = amount >= salary.pendingAmount ? PaymentType.full : PaymentType.partial;

      final history = SalaryHistoryModel.create(
        salaryId: salaryId,
        employeeId: salary.employeeId,
        employeeName: salary.employeeName,
        amount: amount,
        paymentMethod: paymentMethod,
        notes: notes,
        referenceNumber: referenceNumber,
        paymentType: paymentType,
      );

      final updated = salary.copyWith(
        paidAmount: newPaidAmount,
        status: newStatus,
        paymentDate: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _repository.saveHistory(history);
      await _repository.update(updated);

      Logger.success(
        'Payment processed: ${salary.employeeName} - $amount via ${paymentMethod.displayName}',
      );
      return updated;
    } on AppException {
      rethrow;
    } catch (e, stackTrace) {
      Logger.error('Failed to process payment', e, stackTrace);
      rethrow;
    }
  }

  Future<List<SalaryHistoryModel>> getPaymentHistory(String salaryId) async {
    try {
      return await _repository.getHistoryBySalaryId(salaryId);
    } catch (e, stackTrace) {
      Logger.error('Failed to get payment history', e, stackTrace);
      return [];
    }
  }

  Future<List<SalaryHistoryModel>> getPaymentHistoryByEmployee(String employeeId) async {
    try {
      return await _repository.getHistoryByEmployeeId(employeeId);
    } catch (e, stackTrace) {
      Logger.error('Failed to get payment history by employee', e, stackTrace);
      return [];
    }
  }

  Future<List<SalaryModel>> getSalariesByMonth(int month, int year) async {
    try {
      return await _repository.getByMonth(month, year);
    } catch (e, stackTrace) {
      Logger.error('Failed to get salaries by month', e, stackTrace);
      return [];
    }
  }

  Future<List<SalaryModel>> getPendingSalaries() async {
    try {
      return await _repository.getPendingSalaries();
    } catch (e, stackTrace) {
      Logger.error('Failed to get pending salaries', e, stackTrace);
      return [];
    }
  }

  Future<List<SalaryModel>> getSalariesByEmployeeId(String employeeId) async {
    try {
      return await _repository.getByEmployeeId(employeeId);
    } catch (e, stackTrace) {
      Logger.error('Failed to get salaries by employee', e, stackTrace);
      return [];
    }
  }

  Future<void> deleteSalary(String id) async {
    try {
      await _repository.delete(id);
      Logger.success('Salary deleted: $id');
    } catch (e, stackTrace) {
      Logger.error('Failed to delete salary', e, stackTrace);
      rethrow;
    }
  }
}
