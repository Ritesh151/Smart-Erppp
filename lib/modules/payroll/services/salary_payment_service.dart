import 'package:smarterp/core/exceptions/app_exception.dart';
import 'package:smarterp/core/models/salary_model.dart';
import 'package:smarterp/core/models/salary_history_model.dart';
import 'package:smarterp/core/utils/logger.dart';
import 'package:smarterp/modules/payroll/repositories/salary_repository.dart';

class BatchPaymentResult {
  final int successCount;
  final int failureCount;
  final List<String> errors;

  BatchPaymentResult({
    required this.successCount,
    required this.failureCount,
    required this.errors,
  });

  bool get allSucceeded => failureCount == 0;
  bool get allFailed => successCount == 0;

  String get summary {
    if (allSucceeded) return 'All $successCount payments processed successfully';
    if (allFailed) return 'All $failureCount payments failed';
    return '$successCount succeeded, $failureCount failed';
  }
}

class PaymentReport {
  final int totalPayments;
  final double totalAmount;
  final Map<PaymentMethod, double> methodBreakdown;
  final int fullPayments;
  final int partialPayments;
  final DateTime generatedAt;

  PaymentReport({
    required this.totalPayments,
    required this.totalAmount,
    required this.methodBreakdown,
    required this.fullPayments,
    required this.partialPayments,
    required this.generatedAt,
  });
}

class SalaryPaymentService {
  final SalaryRepository _repository;

  SalaryPaymentService(this._repository);

  Future<BatchPaymentResult> processBatchPayment({
    required List<String> salaryIds,
    required PaymentMethod paymentMethod,
    String? referenceNumber,
    String? notes,
  }) async {
    int successCount = 0;
    int failureCount = 0;
    final errors = <String>[];

    for (final salaryId in salaryIds) {
      try {
        final salary = await _repository.getById(salaryId);
        if (salary == null) {
          failureCount++;
          errors.add('Salary $salaryId not found');
          continue;
        }

        if (salary.isFullyPaid) {
          failureCount++;
          errors.add('${salary.employeeName}: already fully paid');
          continue;
        }

        final amount = salary.pendingAmount;
        final history = SalaryHistoryModel.create(
          salaryId: salaryId,
          employeeId: salary.employeeId,
          employeeName: salary.employeeName,
          amount: amount,
          paymentMethod: paymentMethod,
          referenceNumber: referenceNumber,
          notes: notes,
          paymentType: PaymentType.full,
        );

        final updated = salary.copyWith(
          paidAmount: salary.netSalary,
          status: SalaryStatus.paid,
          paymentDate: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await _repository.saveHistory(history);
        await _repository.update(updated);
        successCount++;
      } catch (e) {
        failureCount++;
        errors.add('$salaryId: $e');
      }
    }

    Logger.success('Batch payment: ${successCount}s, ${failureCount}f');
    return BatchPaymentResult(
      successCount: successCount,
      failureCount: failureCount,
      errors: errors,
    );
  }

  Future<PaymentReport> generatePaymentReport({
    required int month,
    required int year,
  }) async {
    final salaries = await _repository.getByMonth(month, year);
    final historyAll = <SalaryHistoryModel>[];

    for (final salary in salaries) {
      final history = await _repository.getHistoryBySalaryId(salary.id);
      historyAll.addAll(history);
    }

    final totalAmount = historyAll.fold(0.0, (sum, h) => sum + h.amount);
    final methodBreakdown = <PaymentMethod, double>{};
    int fullPayments = 0;
    int partialPayments = 0;

    for (final h in historyAll) {
      methodBreakdown.update(h.paymentMethod, (v) => v + h.amount, ifAbsent: () => h.amount);
      if (h.paymentType == PaymentType.full) fullPayments++;
      else partialPayments++;
    }

    return PaymentReport(
      totalPayments: historyAll.length,
      totalAmount: totalAmount,
      methodBreakdown: methodBreakdown,
      fullPayments: fullPayments,
      partialPayments: partialPayments,
      generatedAt: DateTime.now(),
    );
  }

  Future<void> voidPayment(String historyId) async {
    final history = await _repository.getHistoryBySalaryId(historyId);
    Logger.warning('Void payment not yet implemented: $historyId');
    throw UnsupportedError('Void payment functionality not available');
  }

  Future<double> getMonthlyPaymentTotal(int month, int year) async {
    return await _repository.getTotalPaidForMonth(month, year);
  }

  Future<double> getMonthlyPendingTotal(int month, int year) async {
    return await _repository.getTotalPendingForMonth(month, year);
  }
}
