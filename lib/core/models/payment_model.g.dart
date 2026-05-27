// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PaymentModelAdapter extends TypeAdapter<PaymentModel> {
  @override
  final int typeId = 6;

  @override
  PaymentModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PaymentModel(
      id: fields[0] as String,
      invoiceId: fields[1] as String,
      amount: fields[2] as double,
      paymentDate: fields[3] as DateTime,
      mode: fields[4] as PaymentMode,
      reference: fields[5] as String?,
      notes: fields[6] as String?,
      createdAt: fields[7] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, PaymentModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.invoiceId)
      ..writeByte(2)
      ..write(obj.amount)
      ..writeByte(3)
      ..write(obj.paymentDate)
      ..writeByte(4)
      ..write(obj.mode)
      ..writeByte(5)
      ..write(obj.reference)
      ..writeByte(6)
      ..write(obj.notes)
      ..writeByte(7)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaymentModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PaymentModeAdapter extends TypeAdapter<PaymentMode> {
  @override
  final int typeId = 8;

  @override
  PaymentMode read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return PaymentMode.cash;
      case 1:
        return PaymentMode.bankTransfer;
      case 2:
        return PaymentMode.cheque;
      case 3:
        return PaymentMode.card;
      case 4:
        return PaymentMode.upi;
      case 5:
        return PaymentMode.online;
      default:
        return PaymentMode.cash;
    }
  }

  @override
  void write(BinaryWriter writer, PaymentMode obj) {
    switch (obj) {
      case PaymentMode.cash:
        writer.writeByte(0);
        break;
      case PaymentMode.bankTransfer:
        writer.writeByte(1);
        break;
      case PaymentMode.cheque:
        writer.writeByte(2);
        break;
      case PaymentMode.card:
        writer.writeByte(3);
        break;
      case PaymentMode.upi:
        writer.writeByte(4);
        break;
      case PaymentMode.online:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaymentModeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
