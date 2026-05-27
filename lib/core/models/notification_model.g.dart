// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NotificationModelAdapter extends TypeAdapter<NotificationModel> {
  @override
  final int typeId = 34;

  @override
  NotificationModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NotificationModel(
      id: fields[0] as String,
      title: fields[1] as String,
      message: fields[2] as String,
      category: fields[3] as NotificationCategory,
      priority: fields[4] as NotificationPriority,
      isRead: fields[5] as bool,
      referenceId: fields[6] as String?,
      referenceType: fields[7] as String?,
      actionRoute: fields[8] as String?,
      createdAt: fields[9] as DateTime,
      readAt: fields[10] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, NotificationModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.message)
      ..writeByte(3)
      ..write(obj.category)
      ..writeByte(4)
      ..write(obj.priority)
      ..writeByte(5)
      ..write(obj.isRead)
      ..writeByte(6)
      ..write(obj.referenceId)
      ..writeByte(7)
      ..write(obj.referenceType)
      ..writeByte(8)
      ..write(obj.actionRoute)
      ..writeByte(9)
      ..write(obj.createdAt)
      ..writeByte(10)
      ..write(obj.readAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class NotificationCategoryAdapter extends TypeAdapter<NotificationCategory> {
  @override
  final int typeId = 37;

  @override
  NotificationCategory read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return NotificationCategory.lowStock;
      case 1:
        return NotificationCategory.salaryReminder;
      case 2:
        return NotificationCategory.paymentDue;
      case 3:
        return NotificationCategory.transportAlert;
      case 4:
        return NotificationCategory.invoiceReminder;
      case 5:
        return NotificationCategory.system;
      case 6:
        return NotificationCategory.backup;
      case 7:
        return NotificationCategory.businessAlert;
      default:
        return NotificationCategory.lowStock;
    }
  }

  @override
  void write(BinaryWriter writer, NotificationCategory obj) {
    switch (obj) {
      case NotificationCategory.lowStock:
        writer.writeByte(0);
        break;
      case NotificationCategory.salaryReminder:
        writer.writeByte(1);
        break;
      case NotificationCategory.paymentDue:
        writer.writeByte(2);
        break;
      case NotificationCategory.transportAlert:
        writer.writeByte(3);
        break;
      case NotificationCategory.invoiceReminder:
        writer.writeByte(4);
        break;
      case NotificationCategory.system:
        writer.writeByte(5);
        break;
      case NotificationCategory.backup:
        writer.writeByte(6);
        break;
      case NotificationCategory.businessAlert:
        writer.writeByte(7);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class NotificationPriorityAdapter extends TypeAdapter<NotificationPriority> {
  @override
  final int typeId = 38;

  @override
  NotificationPriority read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return NotificationPriority.low;
      case 1:
        return NotificationPriority.medium;
      case 2:
        return NotificationPriority.high;
      case 3:
        return NotificationPriority.critical;
      default:
        return NotificationPriority.low;
    }
  }

  @override
  void write(BinaryWriter writer, NotificationPriority obj) {
    switch (obj) {
      case NotificationPriority.low:
        writer.writeByte(0);
        break;
      case NotificationPriority.medium:
        writer.writeByte(1);
        break;
      case NotificationPriority.high:
        writer.writeByte(2);
        break;
      case NotificationPriority.critical:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationPriorityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
