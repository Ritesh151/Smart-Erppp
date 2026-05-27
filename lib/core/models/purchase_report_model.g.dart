// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'purchase_report_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PurchaseReportModelAdapter extends TypeAdapter<PurchaseReportModel> {
  @override
  final int typeId = 25;

  @override
  PurchaseReportModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PurchaseReportModel(
      id: fields[0] as String,
      reportId: fields[1] as String,
      totalPurchases: fields[2] as double,
      purchaseCount: fields[3] as int,
      averageOrderValue: fields[4] as double,
      topSuppliers: (fields[5] as List)
          .map((dynamic e) => (e as Map).cast<String, dynamic>())
          .toList(),
      topProducts: (fields[6] as List)
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
  void write(BinaryWriter writer, PurchaseReportModel obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.reportId)
      ..writeByte(2)
      ..write(obj.totalPurchases)
      ..writeByte(3)
      ..write(obj.purchaseCount)
      ..writeByte(4)
      ..write(obj.averageOrderValue)
      ..writeByte(5)
      ..write(obj.topSuppliers)
      ..writeByte(6)
      ..write(obj.topProducts)
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
      other is PurchaseReportModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
