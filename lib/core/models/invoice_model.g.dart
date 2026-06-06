// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invoice_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class InvoiceModelAdapter extends TypeAdapter<InvoiceModel> {
  @override
  final int typeId = 3;

  @override
  InvoiceModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return InvoiceModel(
      id: fields[0] as String,
      invoiceNumber: fields[1] as String,
      customerId: fields[2] as String,
      customerName: fields[3] as String,
      customerEmail: fields[4] as String?,
      customerPhone: fields[5] as String?,
      customerAddress: fields[6] as String?,
      customerGst: fields[7] as String?,
      invoiceDate: fields[8] as DateTime,
      dueDate: fields[9] as DateTime,
      itemIds: (fields[10] as List).cast<String>(),
      subtotal: fields[11] as double,
      taxAmount: fields[12] as double,
      discountAmount: fields[13] as double,
      totalAmount: fields[14] as double,
      paidAmount: fields[15] as double,
      status: fields[16] as InvoiceStatus,
      notes: fields[17] as String?,
      termsAndConditions: fields[18] as String?,
      createdAt: fields[19] as DateTime,
      updatedAt: fields[20] as DateTime,
      bankName: fields[21] as String?,
      branchName: fields[22] as String?,
      ifscCode: fields[23] as String?,
      accountNumber: fields[24] as String?,
      paymentDays: fields[25] as int? ?? 0,
      paymentMonths: fields[26] as int? ?? 0,
      paymentTermDescription: fields[27] as String?,
      customPaymentNotes: fields[28] as String?,
      internalChargesJson: fields[29] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, InvoiceModel obj) {
    writer
      ..writeByte(30)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.invoiceNumber)
      ..writeByte(2)
      ..write(obj.customerId)
      ..writeByte(3)
      ..write(obj.customerName)
      ..writeByte(4)
      ..write(obj.customerEmail)
      ..writeByte(5)
      ..write(obj.customerPhone)
      ..writeByte(6)
      ..write(obj.customerAddress)
      ..writeByte(7)
      ..write(obj.customerGst)
      ..writeByte(8)
      ..write(obj.invoiceDate)
      ..writeByte(9)
      ..write(obj.dueDate)
      ..writeByte(10)
      ..write(obj.itemIds)
      ..writeByte(11)
      ..write(obj.subtotal)
      ..writeByte(12)
      ..write(obj.taxAmount)
      ..writeByte(13)
      ..write(obj.discountAmount)
      ..writeByte(14)
      ..write(obj.totalAmount)
      ..writeByte(15)
      ..write(obj.paidAmount)
      ..writeByte(16)
      ..write(obj.status)
      ..writeByte(17)
      ..write(obj.notes)
      ..writeByte(18)
      ..write(obj.termsAndConditions)
      ..writeByte(19)
      ..write(obj.createdAt)
      ..writeByte(20)
      ..write(obj.updatedAt)
      ..writeByte(21)
      ..write(obj.bankName)
      ..writeByte(22)
      ..write(obj.branchName)
      ..writeByte(23)
      ..write(obj.ifscCode)
      ..writeByte(24)
      ..write(obj.accountNumber)
      ..writeByte(25)
      ..write(obj.paymentDays)
      ..writeByte(26)
      ..write(obj.paymentMonths)
      ..writeByte(27)
      ..write(obj.paymentTermDescription)
      ..writeByte(28)
      ..write(obj.customPaymentNotes)
      ..writeByte(29)
      ..write(obj.internalChargesJson);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InvoiceModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class InvoiceStatusAdapter extends TypeAdapter<InvoiceStatus> {
  @override
  final int typeId = 7;

  @override
  InvoiceStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return InvoiceStatus.draft;
      case 1:
        return InvoiceStatus.sent;
      case 2:
        return InvoiceStatus.paid;
      case 3:
        return InvoiceStatus.partiallyPaid;
      case 4:
        return InvoiceStatus.overdue;
      case 5:
        return InvoiceStatus.cancelled;
      default:
        return InvoiceStatus.draft;
    }
  }

  @override
  void write(BinaryWriter writer, InvoiceStatus obj) {
    switch (obj) {
      case InvoiceStatus.draft:
        writer.writeByte(0);
        break;
      case InvoiceStatus.sent:
        writer.writeByte(1);
        break;
      case InvoiceStatus.paid:
        writer.writeByte(2);
        break;
      case InvoiceStatus.partiallyPaid:
        writer.writeByte(3);
        break;
      case InvoiceStatus.overdue:
        writer.writeByte(4);
        break;
      case InvoiceStatus.cancelled:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InvoiceStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
