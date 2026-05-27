// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SettingsModelAdapter extends TypeAdapter<SettingsModel> {
  @override
  final int typeId = 32;

  @override
  SettingsModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SettingsModel(
      id: fields[0] as String,
      companyName: fields[1] as String,
      companyAddress: fields[2] as String?,
      companyPhone: fields[3] as String?,
      companyEmail: fields[4] as String?,
      taxId: fields[5] as String?,
      currencySymbol: fields[6] as String?,
      dateFormat: fields[7] as String,
      timeFormat: fields[8] as String,
      lowStockThreshold: fields[9] as int,
      salaryReminderEnabled: fields[10] as bool,
      autoBackupEnabled: fields[11] as bool,
      autoBackupIntervalDays: fields[12] as int,
      maxBackupCount: fields[13] as int,
      notificationsEnabled: fields[14] as bool,
      defaultItemsPerPage: fields[15] as int,
      sidebarCollapsed: fields[16] as bool,
      language: fields[17] as String,
      moduleSettings: (fields[18] as Map).cast<String, dynamic>(),
      createdAt: fields[19] as DateTime,
      updatedAt: fields[20] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, SettingsModel obj) {
    writer
      ..writeByte(21)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.companyName)
      ..writeByte(2)
      ..write(obj.companyAddress)
      ..writeByte(3)
      ..write(obj.companyPhone)
      ..writeByte(4)
      ..write(obj.companyEmail)
      ..writeByte(5)
      ..write(obj.taxId)
      ..writeByte(6)
      ..write(obj.currencySymbol)
      ..writeByte(7)
      ..write(obj.dateFormat)
      ..writeByte(8)
      ..write(obj.timeFormat)
      ..writeByte(9)
      ..write(obj.lowStockThreshold)
      ..writeByte(10)
      ..write(obj.salaryReminderEnabled)
      ..writeByte(11)
      ..write(obj.autoBackupEnabled)
      ..writeByte(12)
      ..write(obj.autoBackupIntervalDays)
      ..writeByte(13)
      ..write(obj.maxBackupCount)
      ..writeByte(14)
      ..write(obj.notificationsEnabled)
      ..writeByte(15)
      ..write(obj.defaultItemsPerPage)
      ..writeByte(16)
      ..write(obj.sidebarCollapsed)
      ..writeByte(17)
      ..write(obj.language)
      ..writeByte(18)
      ..write(obj.moduleSettings)
      ..writeByte(19)
      ..write(obj.createdAt)
      ..writeByte(20)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SettingsModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
