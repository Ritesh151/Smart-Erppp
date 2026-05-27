// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ReportModelAdapter extends TypeAdapter<ReportModel> {
  @override
  final int typeId = 23;

  @override
  ReportModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ReportModel(
      id: fields[0] as String,
      type: fields[1] as ReportType,
      title: fields[2] as String,
      fromDate: fields[3] as DateTime,
      toDate: fields[4] as DateTime,
      period: fields[5] as ReportPeriod,
      generatedAt: fields[6] as DateTime,
      filters: (fields[7] as Map?)?.cast<String, dynamic>(),
      notes: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ReportModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.fromDate)
      ..writeByte(4)
      ..write(obj.toDate)
      ..writeByte(5)
      ..write(obj.period)
      ..writeByte(6)
      ..write(obj.generatedAt)
      ..writeByte(7)
      ..write(obj.filters)
      ..writeByte(8)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReportModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
