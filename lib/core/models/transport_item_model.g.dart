// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transport_item_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TransportItemModelAdapter extends TypeAdapter<TransportItemModel> {
  @override
  final int typeId = 10;

  @override
  TransportItemModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TransportItemModel(
      id: fields[0] as String,
      transportId: fields[1] as String,
      productId: fields[2] as String,
      productName: fields[3] as String,
      hsnCode: fields[4] as String?,
      quantity: fields[5] as double,
      unit: fields[6] as String,
      allocatedQuantity: fields[7] as double,
      deliveredQuantity: fields[8] as double,
      notes: fields[9] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, TransportItemModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.transportId)
      ..writeByte(2)
      ..write(obj.productId)
      ..writeByte(3)
      ..write(obj.productName)
      ..writeByte(4)
      ..write(obj.hsnCode)
      ..writeByte(5)
      ..write(obj.quantity)
      ..writeByte(6)
      ..write(obj.unit)
      ..writeByte(7)
      ..write(obj.allocatedQuantity)
      ..writeByte(8)
      ..write(obj.deliveredQuantity)
      ..writeByte(9)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransportItemModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
