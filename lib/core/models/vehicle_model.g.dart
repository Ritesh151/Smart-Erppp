// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicle_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VehicleModelAdapter extends TypeAdapter<VehicleModel> {
  @override
  final int typeId = 11;

  @override
  VehicleModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return VehicleModel(
      id: fields[0] as String,
      vehicleNumber: fields[1] as String,
      vehicleType: fields[2] as String,
      capacity: fields[3] as double,
      capacityUnit: fields[4] as String,
      driverName: fields[5] as String?,
      driverPhone: fields[6] as String?,
      isActive: fields[7] as bool,
      createdAt: fields[8] as DateTime,
      updatedAt: fields[9] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, VehicleModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.vehicleNumber)
      ..writeByte(2)
      ..write(obj.vehicleType)
      ..writeByte(3)
      ..write(obj.capacity)
      ..writeByte(4)
      ..write(obj.capacityUnit)
      ..writeByte(5)
      ..write(obj.driverName)
      ..writeByte(6)
      ..write(obj.driverPhone)
      ..writeByte(7)
      ..write(obj.isActive)
      ..writeByte(8)
      ..write(obj.createdAt)
      ..writeByte(9)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VehicleModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
