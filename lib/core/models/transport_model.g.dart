// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transport_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TransportModelAdapter extends TypeAdapter<TransportModel> {
  @override
  final int typeId = 9;

  @override
  TransportModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TransportModel(
      id: fields[0] as String,
      transportNumber: fields[1] as String,
      vehicleId: fields[2] as String,
      vehicleNumber: fields[3] as String,
      driverName: fields[4] as String?,
      driverPhone: fields[5] as String?,
      origin: fields[6] as String,
      destination: fields[7] as String,
      departureDate: fields[8] as DateTime,
      estimatedArrival: fields[9] as DateTime?,
      actualArrival: fields[10] as DateTime?,
      itemIds: (fields[11] as List).cast<String>(),
      status: fields[12] as TransportStatus,
      totalWeight: fields[13] as double,
      totalItems: fields[14] as int,
      notes: fields[15] as String?,
      createdAt: fields[16] as DateTime,
      updatedAt: fields[17] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, TransportModel obj) {
    writer
      ..writeByte(18)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.transportNumber)
      ..writeByte(2)
      ..write(obj.vehicleId)
      ..writeByte(3)
      ..write(obj.vehicleNumber)
      ..writeByte(4)
      ..write(obj.driverName)
      ..writeByte(5)
      ..write(obj.driverPhone)
      ..writeByte(6)
      ..write(obj.origin)
      ..writeByte(7)
      ..write(obj.destination)
      ..writeByte(8)
      ..write(obj.departureDate)
      ..writeByte(9)
      ..write(obj.estimatedArrival)
      ..writeByte(10)
      ..write(obj.actualArrival)
      ..writeByte(11)
      ..write(obj.itemIds)
      ..writeByte(12)
      ..write(obj.status)
      ..writeByte(13)
      ..write(obj.totalWeight)
      ..writeByte(14)
      ..write(obj.totalItems)
      ..writeByte(15)
      ..write(obj.notes)
      ..writeByte(16)
      ..write(obj.createdAt)
      ..writeByte(17)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransportModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
