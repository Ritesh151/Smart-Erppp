// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'salary_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SalaryModelAdapter extends TypeAdapter<SalaryModel> {
  @override
  final int typeId = 15;

  @override
  SalaryModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SalaryModel(
      id: fields[0] as String,
      employeeId: fields[1] as String,
      employeeName: fields[2] as String,
      month: fields[3] as int,
      year: fields[4] as int,
      basicSalary: fields[5] as double,
      bonus: fields[6] as double,
      overtime: fields[7] as double,
      deductions: fields[8] as double,
      netSalary: fields[9] as double,
      paidAmount: fields[10] as double,
      status: fields[11] as SalaryStatus,
      paymentDate: fields[12] as DateTime?,
      notes: fields[13] as String?,
      createdAt: fields[14] as DateTime,
      updatedAt: fields[15] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, SalaryModel obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.employeeId)
      ..writeByte(2)
      ..write(obj.employeeName)
      ..writeByte(3)
      ..write(obj.month)
      ..writeByte(4)
      ..write(obj.year)
      ..writeByte(5)
      ..write(obj.basicSalary)
      ..writeByte(6)
      ..write(obj.bonus)
      ..writeByte(7)
      ..write(obj.overtime)
      ..writeByte(8)
      ..write(obj.deductions)
      ..writeByte(9)
      ..write(obj.netSalary)
      ..writeByte(10)
      ..write(obj.paidAmount)
      ..writeByte(11)
      ..write(obj.status)
      ..writeByte(12)
      ..write(obj.paymentDate)
      ..writeByte(13)
      ..write(obj.notes)
      ..writeByte(14)
      ..write(obj.createdAt)
      ..writeByte(15)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SalaryModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SalaryStatusAdapter extends TypeAdapter<SalaryStatus> {
  @override
  final int typeId = 20;

  @override
  SalaryStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SalaryStatus.paid;
      case 1:
        return SalaryStatus.pending;
      case 2:
        return SalaryStatus.partiallyPaid;
      case 3:
        return SalaryStatus.overdue;
      default:
        return SalaryStatus.paid;
    }
  }

  @override
  void write(BinaryWriter writer, SalaryStatus obj) {
    switch (obj) {
      case SalaryStatus.paid:
        writer.writeByte(0);
        break;
      case SalaryStatus.pending:
        writer.writeByte(1);
        break;
      case SalaryStatus.partiallyPaid:
        writer.writeByte(2);
        break;
      case SalaryStatus.overdue:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SalaryStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
