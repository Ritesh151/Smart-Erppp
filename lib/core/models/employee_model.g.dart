// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'employee_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EmployeeModelAdapter extends TypeAdapter<EmployeeModel> {
  @override
  final int typeId = 13;

  @override
  EmployeeModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EmployeeModel(
      id: fields[0] as String,
      employeeCode: fields[1] as String,
      firstName: fields[2] as String,
      lastName: fields[3] as String,
      email: fields[4] as String,
      phone: fields[5] as String,
      address: fields[6] as String?,
      department: fields[7] as String,
      designation: fields[8] as String,
      dateOfJoining: fields[9] as DateTime,
      dateOfBirth: fields[10] as DateTime?,
      salary: fields[11] as double,
      employmentType: fields[12] as EmploymentType,
      status: fields[13] as EmployeeStatus,
      bankAccountNumber: fields[14] as String?,
      bankName: fields[15] as String?,
      ifscCode: fields[16] as String?,
      panNumber: fields[17] as String?,
      aadharNumber: fields[18] as String?,
      createdAt: fields[19] as DateTime,
      updatedAt: fields[20] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, EmployeeModel obj) {
    writer
      ..writeByte(21)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.employeeCode)
      ..writeByte(2)
      ..write(obj.firstName)
      ..writeByte(3)
      ..write(obj.lastName)
      ..writeByte(4)
      ..write(obj.email)
      ..writeByte(5)
      ..write(obj.phone)
      ..writeByte(6)
      ..write(obj.address)
      ..writeByte(7)
      ..write(obj.department)
      ..writeByte(8)
      ..write(obj.designation)
      ..writeByte(9)
      ..write(obj.dateOfJoining)
      ..writeByte(10)
      ..write(obj.dateOfBirth)
      ..writeByte(11)
      ..write(obj.salary)
      ..writeByte(12)
      ..write(obj.employmentType)
      ..writeByte(13)
      ..write(obj.status)
      ..writeByte(14)
      ..write(obj.bankAccountNumber)
      ..writeByte(15)
      ..write(obj.bankName)
      ..writeByte(16)
      ..write(obj.ifscCode)
      ..writeByte(17)
      ..write(obj.panNumber)
      ..writeByte(18)
      ..write(obj.aadharNumber)
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
      other is EmployeeModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class EmploymentTypeAdapter extends TypeAdapter<EmploymentType> {
  @override
  final int typeId = 17;

  @override
  EmploymentType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return EmploymentType.fullTime;
      case 1:
        return EmploymentType.partTime;
      case 2:
        return EmploymentType.contract;
      case 3:
        return EmploymentType.intern;
      default:
        return EmploymentType.fullTime;
    }
  }

  @override
  void write(BinaryWriter writer, EmploymentType obj) {
    switch (obj) {
      case EmploymentType.fullTime:
        writer.writeByte(0);
        break;
      case EmploymentType.partTime:
        writer.writeByte(1);
        break;
      case EmploymentType.contract:
        writer.writeByte(2);
        break;
      case EmploymentType.intern:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EmploymentTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class EmployeeStatusAdapter extends TypeAdapter<EmployeeStatus> {
  @override
  final int typeId = 18;

  @override
  EmployeeStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return EmployeeStatus.active;
      case 1:
        return EmployeeStatus.inactive;
      case 2:
        return EmployeeStatus.onLeave;
      case 3:
        return EmployeeStatus.terminated;
      default:
        return EmployeeStatus.active;
    }
  }

  @override
  void write(BinaryWriter writer, EmployeeStatus obj) {
    switch (obj) {
      case EmployeeStatus.active:
        writer.writeByte(0);
        break;
      case EmployeeStatus.inactive:
        writer.writeByte(1);
        break;
      case EmployeeStatus.onLeave:
        writer.writeByte(2);
        break;
      case EmployeeStatus.terminated:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EmployeeStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
