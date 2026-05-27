// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'salary_history_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SalaryHistoryModelAdapter extends TypeAdapter<SalaryHistoryModel> {
  @override
  final int typeId = 16;

  @override
  SalaryHistoryModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SalaryHistoryModel(
      id: fields[0] as String,
      salaryId: fields[1] as String,
      employeeId: fields[2] as String,
      employeeName: fields[3] as String,
      amount: fields[4] as double,
      paymentMethod: fields[5] as PaymentMethod,
      paymentDate: fields[6] as DateTime,
      notes: fields[7] as String?,
      referenceNumber: fields[8] as String?,
      paymentType: fields[9] as PaymentType,
      createdAt: fields[10] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, SalaryHistoryModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.salaryId)
      ..writeByte(2)
      ..write(obj.employeeId)
      ..writeByte(3)
      ..write(obj.employeeName)
      ..writeByte(4)
      ..write(obj.amount)
      ..writeByte(5)
      ..write(obj.paymentMethod)
      ..writeByte(6)
      ..write(obj.paymentDate)
      ..writeByte(7)
      ..write(obj.notes)
      ..writeByte(8)
      ..write(obj.referenceNumber)
      ..writeByte(9)
      ..write(obj.paymentType)
      ..writeByte(10)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SalaryHistoryModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PaymentMethodAdapter extends TypeAdapter<PaymentMethod> {
  @override
  final int typeId = 21;

  @override
  PaymentMethod read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return PaymentMethod.cash;
      case 1:
        return PaymentMethod.upi;
      case 2:
        return PaymentMethod.bankTransfer;
      case 3:
        return PaymentMethod.cheque;
      default:
        return PaymentMethod.cash;
    }
  }

  @override
  void write(BinaryWriter writer, PaymentMethod obj) {
    switch (obj) {
      case PaymentMethod.cash:
        writer.writeByte(0);
        break;
      case PaymentMethod.upi:
        writer.writeByte(1);
        break;
      case PaymentMethod.bankTransfer:
        writer.writeByte(2);
        break;
      case PaymentMethod.cheque:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaymentMethodAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PaymentTypeAdapter extends TypeAdapter<PaymentType> {
  @override
  final int typeId = 22;

  @override
  PaymentType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return PaymentType.full;
      case 1:
        return PaymentType.partial;
      default:
        return PaymentType.full;
    }
  }

  @override
  void write(BinaryWriter writer, PaymentType obj) {
    switch (obj) {
      case PaymentType.full:
        writer.writeByte(0);
        break;
      case PaymentType.partial:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaymentTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
