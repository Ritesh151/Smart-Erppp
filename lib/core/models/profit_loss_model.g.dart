// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profit_loss_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProfitLossModelAdapter extends TypeAdapter<ProfitLossModel> {
  @override
  final int typeId = 28;

  @override
  ProfitLossModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProfitLossModel(
      id: fields[0] as String,
      reportId: fields[1] as String,
      totalRevenue: fields[2] as double,
      totalCostOfGoodsSold: fields[3] as double,
      totalExpenses: fields[4] as double,
      totalPayrollCost: fields[5] as double,
      grossProfit: fields[6] as double,
      netProfit: fields[7] as double,
      profitMargin: fields[8] as double,
      previousNetProfit: fields[9] as double,
      revenueTrend: (fields[10] as List).cast<double>(),
      expenseTrend: (fields[11] as List).cast<double>(),
      trendLabels: (fields[12] as List).cast<String>(),
      month: fields[13] as int,
      year: fields[14] as int,
      createdAt: fields[15] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, ProfitLossModel obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.reportId)
      ..writeByte(2)
      ..write(obj.totalRevenue)
      ..writeByte(3)
      ..write(obj.totalCostOfGoodsSold)
      ..writeByte(4)
      ..write(obj.totalExpenses)
      ..writeByte(5)
      ..write(obj.totalPayrollCost)
      ..writeByte(6)
      ..write(obj.grossProfit)
      ..writeByte(7)
      ..write(obj.netProfit)
      ..writeByte(8)
      ..write(obj.profitMargin)
      ..writeByte(9)
      ..write(obj.previousNetProfit)
      ..writeByte(10)
      ..write(obj.revenueTrend)
      ..writeByte(11)
      ..write(obj.expenseTrend)
      ..writeByte(12)
      ..write(obj.trendLabels)
      ..writeByte(13)
      ..write(obj.month)
      ..writeByte(14)
      ..write(obj.year)
      ..writeByte(15)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProfitLossModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
