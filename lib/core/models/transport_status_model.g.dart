// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transport_status_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TransportStatusAdapter extends TypeAdapter<TransportStatus> {
  @override
  final int typeId = 12;

  @override
  TransportStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TransportStatus.planned;
      case 1:
        return TransportStatus.onTheWay;
      case 2:
        return TransportStatus.delivered;
      case 3:
        return TransportStatus.cancelled;
      default:
        return TransportStatus.planned;
    }
  }

  @override
  void write(BinaryWriter writer, TransportStatus obj) {
    switch (obj) {
      case TransportStatus.planned:
        writer.writeByte(0);
        break;
      case TransportStatus.onTheWay:
        writer.writeByte(1);
        break;
      case TransportStatus.delivered:
        writer.writeByte(2);
        break;
      case TransportStatus.cancelled:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransportStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
