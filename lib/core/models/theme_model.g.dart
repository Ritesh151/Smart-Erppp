// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ThemeModelAdapter extends TypeAdapter<ThemeModel> {
  @override
  final int typeId = 33;

  @override
  ThemeModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ThemeModel(
      id: fields[0] as String,
      name: fields[1] as String,
      primaryColorValue: fields[2] as int,
      secondaryColorValue: fields[3] as int,
      surfaceColorValue: fields[4] as int,
      isDark: fields[5] as bool,
      borderRadius: fields[6] as double,
      fontFamily: fields[7] as String,
      createdAt: fields[8] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, ThemeModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.primaryColorValue)
      ..writeByte(3)
      ..write(obj.secondaryColorValue)
      ..writeByte(4)
      ..write(obj.surfaceColorValue)
      ..writeByte(5)
      ..write(obj.isDark)
      ..writeByte(6)
      ..write(obj.borderRadius)
      ..writeByte(7)
      ..write(obj.fontFamily)
      ..writeByte(8)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ThemeModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
