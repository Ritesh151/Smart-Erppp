// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'backup_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BackupModelAdapter extends TypeAdapter<BackupModel> {
  @override
  final int typeId = 35;

  @override
  BackupModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BackupModel(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String,
      type: fields[3] as BackupType,
      status: fields[4] as BackupStatus,
      fileSizeBytes: fields[5] as double,
      filePath: fields[6] as String,
      fileFormat: fields[7] as String,
      includedModules: (fields[8] as List).cast<String>(),
      recordCount: fields[9] as int,
      version: fields[10] as String,
      isEncrypted: fields[11] as bool,
      checksum: fields[12] as String?,
      createdAt: fields[13] as DateTime,
      restoredAt: fields[14] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, BackupModel obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.status)
      ..writeByte(5)
      ..write(obj.fileSizeBytes)
      ..writeByte(6)
      ..write(obj.filePath)
      ..writeByte(7)
      ..write(obj.fileFormat)
      ..writeByte(8)
      ..write(obj.includedModules)
      ..writeByte(9)
      ..write(obj.recordCount)
      ..writeByte(10)
      ..write(obj.version)
      ..writeByte(11)
      ..write(obj.isEncrypted)
      ..writeByte(12)
      ..write(obj.checksum)
      ..writeByte(13)
      ..write(obj.createdAt)
      ..writeByte(14)
      ..write(obj.restoredAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BackupModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class BackupStatusAdapter extends TypeAdapter<BackupStatus> {
  @override
  final int typeId = 39;

  @override
  BackupStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return BackupStatus.completed;
      case 1:
        return BackupStatus.failed;
      case 2:
        return BackupStatus.inProgress;
      case 3:
        return BackupStatus.restoring;
      default:
        return BackupStatus.completed;
    }
  }

  @override
  void write(BinaryWriter writer, BackupStatus obj) {
    switch (obj) {
      case BackupStatus.completed:
        writer.writeByte(0);
        break;
      case BackupStatus.failed:
        writer.writeByte(1);
        break;
      case BackupStatus.inProgress:
        writer.writeByte(2);
        break;
      case BackupStatus.restoring:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BackupStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class BackupTypeAdapter extends TypeAdapter<BackupType> {
  @override
  final int typeId = 40;

  @override
  BackupType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return BackupType.automatic;
      case 1:
        return BackupType.manual;
      case 2:
        return BackupType.import;
      case 3:
        return BackupType.export;
      default:
        return BackupType.automatic;
    }
  }

  @override
  void write(BinaryWriter writer, BackupType obj) {
    switch (obj) {
      case BackupType.automatic:
        writer.writeByte(0);
        break;
      case BackupType.manual:
        writer.writeByte(1);
        break;
      case BackupType.import:
        writer.writeByte(2);
        break;
      case BackupType.export:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BackupTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
