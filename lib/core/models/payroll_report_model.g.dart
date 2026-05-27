// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payroll_report_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PayrollReportModelAdapter extends TypeAdapter<PayrollReportModel> {
  @override
  final int typeId = 29;

  @override
  PayrollReportModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PayrollReportModel(
      id: fields[0] as String,
      reportId: fields[1] as String,
      totalEmployees: fields[2] as int,
      activeEmployees: fields[3] as int,
      totalSalaryPayable: fields[4] as double,
      totalSalaryPaid: fields[5] as double,
      totalSalaryPending: fields[6] as double,
      paidCount: fields[7] as int,
      pendingCount: fields[8] as int,
      partiallyPaidCount: fields[9] as int,
      attendanceRate: fields[10] as double,
      salaryTrend: (fields[11] as List).cast<double>(),
      trendLabels: (fields[12] as List).cast<String>(),
      departmentDistribution: (fields[13] as Map).cast<String, int>(),
      topEarners: (fields[14] as List)
          .map((dynamic e) => (e as Map).cast<String, dynamic>())
          .toList(),
      month: fields[15] as int,
      year: fields[16] as int,
      createdAt: fields[17] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, PayrollReportModel obj) {
    writer
      ..writeByte(18)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.reportId)
      ..writeByte(2)
      ..write(obj.totalEmployees)
      ..writeByte(3)
      ..write(obj.activeEmployees)
      ..writeByte(4)
      ..write(obj.totalSalaryPayable)
      ..writeByte(5)
      ..write(obj.totalSalaryPaid)
      ..writeByte(6)
      ..write(obj.totalSalaryPending)
      ..writeByte(7)
      ..write(obj.paidCount)
      ..writeByte(8)
      ..write(obj.pendingCount)
      ..writeByte(9)
      ..write(obj.partiallyPaidCount)
      ..writeByte(10)
      ..write(obj.attendanceRate)
      ..writeByte(11)
      ..write(obj.salaryTrend)
      ..writeByte(12)
      ..write(obj.trendLabels)
      ..writeByte(13)
      ..write(obj.departmentDistribution)
      ..writeByte(14)
      ..write(obj.topEarners)
      ..writeByte(15)
      ..write(obj.month)
      ..writeByte(16)
      ..write(obj.year)
      ..writeByte(17)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PayrollReportModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
