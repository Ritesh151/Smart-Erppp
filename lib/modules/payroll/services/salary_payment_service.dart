import 'package:siddhivinayak_enterprise/core/models/salary_model.dart';
import 'package:siddhivinayak_enterprise/core/models/salary_history_model.dart';
import 'package:siddhivinayak_enterprise/modules/payroll/repositories/salary_repository.dart';

class SalaryPaymentService {
  final SalaryRepository _repository;

  SalaryPaymentService(this._repository);

  Future<bool> recordPayment({
    required String salaryId,
    required String employeeId,
    required String employeeName,
    required double amount,
    required PaymentMethod paymentMethod,
    String? notes,
    String? referenceNumber,
    PaymentType paymentType = PaymentType.full,
  }) async {
    final salary = await _repository.getSalaryById(salaryId);
    if (salary == null) return false;

    final newPaidAmount = salary.paidAmount + amount;
    final newStatus = newPaidAmount >= salary.netSalary
        ? SalaryStatus.paid
        : SalaryStatus.partiallyPaid;

    final updatedSalary = salary.copyWith(
      paidAmount: newPaidAmount,
      status: newStatus,
      paymentDate: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _repository.updateSalary(updatedSalary);

    final history = SalaryHistoryModel.create(
      salaryId: salaryId,
      employeeId: employeeId,
      employeeName: employeeName,
      amount: amount,
      paymentMethod: paymentMethod,
      notes: notes,
      referenceNumber: referenceNumber,
      paymentType: paymentType,
    );

    await _repository.saveHistory(history);
    return true;
  }
}
