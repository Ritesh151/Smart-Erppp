// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense_report_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExpenseReportModelAdapter extends TypeAdapter<ExpenseReportModel> {
  @override
  final int typeId = 26;

  @override
  ExpenseReportModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExpenseReportModel(
      id: fields[0] as String,
      reportId: fields[1] as String,
      totalExpenses: fields[2] as double,
      expenseCount: fields[3] as int,
      highestCategoryAmount: fields[4] as double,
      highestCategory: fields[5] as String,
      categoryBreakdown: (fields[6] as Map).cast<String, double>(),
      monthlyTrend: (fields[7] as List).cast<double>(),
      monthlyLabels: (fields[8] as List).cast<String>(),
      topExpenses: (fields[9] as List)
          .map((dynamic e) => (e as Map).cast<String, dynamic>())
          .toList(),
      month: fields[10] as int,
      year: fields[11] as int,
      createdAt: fields[12] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, ExpenseReportModel obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.reportId)
      ..writeByte(2)
      ..write(obj.totalExpenses)
      ..writeByte(3)
      ..write(obj.expenseCount)
      ..writeByte(4)
      ..write(obj.highestCategoryAmount)
      ..writeByte(5)
      ..write(obj.highestCategory)
      ..writeByte(6)
      ..write(obj.categoryBreakdown)
      ..writeByte(7)
      ..write(obj.monthlyTrend)
      ..writeByte(8)
      ..write(obj.monthlyLabels)
      ..writeByte(9)
      ..write(obj.topExpenses)
      ..writeByte(10)
      ..write(obj.month)
      ..writeByte(11)
      ..write(obj.year)
      ..writeByte(12)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExpenseReportModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
