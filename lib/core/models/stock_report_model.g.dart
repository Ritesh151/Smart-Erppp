// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stock_report_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StockReportModelAdapter extends TypeAdapter<StockReportModel> {
  @override
  final int typeId = 27;

  @override
  StockReportModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StockReportModel(
      id: fields[0] as String,
      reportId: fields[1] as String,
      totalInventoryValue: fields[2] as double,
      totalProducts: fields[3] as int,
      lowStockCount: fields[4] as int,
      outOfStockCount: fields[5] as int,
      inStockCount: fields[6] as int,
      lowStockProducts: (fields[7] as List)
          .map((dynamic e) => (e as Map).cast<String, dynamic>())
          .toList(),
      topMovingProducts: (fields[8] as List)
          .map((dynamic e) => (e as Map).cast<String, dynamic>())
          .toList(),
      categoryDistribution: (fields[9] as List)
          .map((dynamic e) => (e as Map).cast<String, dynamic>())
          .toList(),
      inventoryTrend: (fields[10] as List).cast<double>(),
      trendLabels: (fields[11] as List).cast<String>(),
      month: fields[12] as int,
      year: fields[13] as int,
      createdAt: fields[14] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, StockReportModel obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.reportId)
      ..writeByte(2)
      ..write(obj.totalInventoryValue)
      ..writeByte(3)
      ..write(obj.totalProducts)
      ..writeByte(4)
      ..write(obj.lowStockCount)
      ..writeByte(5)
      ..write(obj.outOfStockCount)
      ..writeByte(6)
      ..write(obj.inStockCount)
      ..writeByte(7)
      ..write(obj.lowStockProducts)
      ..writeByte(8)
      ..write(obj.topMovingProducts)
      ..writeByte(9)
      ..write(obj.categoryDistribution)
      ..writeByte(10)
      ..write(obj.inventoryTrend)
      ..writeByte(11)
      ..write(obj.trendLabels)
      ..writeByte(12)
      ..write(obj.month)
      ..writeByte(13)
      ..write(obj.year)
      ..writeByte(14)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StockReportModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
