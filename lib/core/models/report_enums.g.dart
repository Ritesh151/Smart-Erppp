// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_enums.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ReportTypeAdapter extends TypeAdapter<ReportType> {
  @override
  final int typeId = 30;

  @override
  ReportType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ReportType.sales;
      case 1:
        return ReportType.purchase;
      case 2:
        return ReportType.expense;
      case 3:
        return ReportType.stock;
      case 4:
        return ReportType.profitLoss;
      case 5:
        return ReportType.payroll;
      default:
        return ReportType.sales;
    }
  }

  @override
  void write(BinaryWriter writer, ReportType obj) {
    switch (obj) {
      case ReportType.sales:
        writer.writeByte(0);
        break;
      case ReportType.purchase:
        writer.writeByte(1);
        break;
      case ReportType.expense:
        writer.writeByte(2);
        break;
      case ReportType.stock:
        writer.writeByte(3);
        break;
      case ReportType.profitLoss:
        writer.writeByte(4);
        break;
      case ReportType.payroll:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReportTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ReportPeriodAdapter extends TypeAdapter<ReportPeriod> {
  @override
  final int typeId = 31;

  @override
  ReportPeriod read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ReportPeriod.daily;
      case 1:
        return ReportPeriod.weekly;
      case 2:
        return ReportPeriod.monthly;
      case 3:
        return ReportPeriod.quarterly;
      case 4:
        return ReportPeriod.yearly;
      case 5:
        return ReportPeriod.custom;
      default:
        return ReportPeriod.daily;
    }
  }

  @override
  void write(BinaryWriter writer, ReportPeriod obj) {
    switch (obj) {
      case ReportPeriod.daily:
        writer.writeByte(0);
        break;
      case ReportPeriod.weekly:
        writer.writeByte(1);
        break;
      case ReportPeriod.monthly:
        writer.writeByte(2);
        break;
      case ReportPeriod.quarterly:
        writer.writeByte(3);
        break;
      case ReportPeriod.yearly:
        writer.writeByte(4);
        break;
      case ReportPeriod.custom:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReportPeriodAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
