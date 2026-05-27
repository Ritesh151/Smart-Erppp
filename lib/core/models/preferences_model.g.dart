// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preferences_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PreferencesModelAdapter extends TypeAdapter<PreferencesModel> {
  @override
  final int typeId = 36;

  @override
  PreferencesModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PreferencesModel(
      id: fields[0] as String,
      userId: fields[1] as String,
      themeName: fields[2] as String,
      sidebarCollapsed: fields[3] as bool,
      dateFormat: fields[4] as String,
      timeFormat: fields[5] as String,
      language: fields[6] as String,
      itemsPerPage: fields[7] as int,
      notificationsEnabled: fields[8] as bool,
      lowStockAlertsEnabled: fields[9] as bool,
      salaryRemindersEnabled: fields[10] as bool,
      lowStockThreshold: fields[11] as int,
      favoriteModules: (fields[12] as List).cast<String>(),
      lastUsedModule: fields[13] as String?,
      modulePreferences: (fields[14] as Map).cast<String, dynamic>(),
      createdAt: fields[15] as DateTime,
      updatedAt: fields[16] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, PreferencesModel obj) {
    writer
      ..writeByte(17)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.themeName)
      ..writeByte(3)
      ..write(obj.sidebarCollapsed)
      ..writeByte(4)
      ..write(obj.dateFormat)
      ..writeByte(5)
      ..write(obj.timeFormat)
      ..writeByte(6)
      ..write(obj.language)
      ..writeByte(7)
      ..write(obj.itemsPerPage)
      ..writeByte(8)
      ..write(obj.notificationsEnabled)
      ..writeByte(9)
      ..write(obj.lowStockAlertsEnabled)
      ..writeByte(10)
      ..write(obj.salaryRemindersEnabled)
      ..writeByte(11)
      ..write(obj.lowStockThreshold)
      ..writeByte(12)
      ..write(obj.favoriteModules)
      ..writeByte(13)
      ..write(obj.lastUsedModule)
      ..writeByte(14)
      ..write(obj.modulePreferences)
      ..writeByte(15)
      ..write(obj.createdAt)
      ..writeByte(16)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PreferencesModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
