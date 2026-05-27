// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invoice_item_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class InvoiceItemModelAdapter extends TypeAdapter<InvoiceItemModel> {
  @override
  final int typeId = 4;

  @override
  InvoiceItemModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return InvoiceItemModel(
      id: fields[0] as String,
      productId: fields[1] as String,
      productName: fields[2] as String,
      hsnCode: fields[3] as String?,
      description: fields[4] as String?,
      quantity: fields[5] as double,
      unit: fields[6] as String,
      unitPrice: fields[7] as double,
      taxRate: fields[8] as double,
      discountRate: fields[9] as double,
      amount: fields[10] as double,
    );
  }

  @override
  void write(BinaryWriter writer, InvoiceItemModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.productId)
      ..writeByte(2)
      ..write(obj.productName)
      ..writeByte(3)
      ..write(obj.hsnCode)
      ..writeByte(4)
      ..write(obj.description)
      ..writeByte(5)
      ..write(obj.quantity)
      ..writeByte(6)
      ..write(obj.unit)
      ..writeByte(7)
      ..write(obj.unitPrice)
      ..writeByte(8)
      ..write(obj.taxRate)
      ..writeByte(9)
      ..write(obj.discountRate)
      ..writeByte(10)
      ..write(obj.amount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InvoiceItemModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
