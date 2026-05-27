// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sales_report_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SalesReportModelAdapter extends TypeAdapter<SalesReportModel> {
  @override
  final int typeId = 24;

  @override
  SalesReportModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SalesReportModel(
      id: fields[0] as String,
      reportId: fields[1] as String,
      totalSales: fields[2] as double,
      salesCount: fields[3] as int,
      averageOrderValue: fields[4] as double,
      topProducts: (fields[5] as List)
          .map((dynamic e) => (e as Map).cast<String, dynamic>())
          .toList(),
      topCustomers: (fields[6] as List)
          .map((dynamic e) => (e as Map).cast<String, dynamic>())
          .toList(),
      monthlyTrend: (fields[7] as List).cast<double>(),
      monthlyLabels: (fields[8] as List).cast<String>(),
      month: fields[9] as int,
      year: fields[10] as int,
      createdAt: fields[11] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, SalesReportModel obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.reportId)
      ..writeByte(2)
      ..write(obj.totalSales)
      ..writeByte(3)
      ..write(obj.salesCount)
      ..writeByte(4)
      ..write(obj.averageOrderValue)
      ..writeByte(5)
      ..write(obj.topProducts)
      ..writeByte(6)
      ..write(obj.topCustomers)
      ..writeByte(7)
      ..write(obj.monthlyTrend)
      ..writeByte(8)
      ..write(obj.monthlyLabels)
      ..writeByte(9)
      ..write(obj.month)
      ..writeByte(10)
      ..write(obj.year)
      ..writeByte(11)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SalesReportModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
