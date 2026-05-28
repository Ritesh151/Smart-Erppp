// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProductModelAdapter extends TypeAdapter<ProductModel> {
  @override
  final int typeId = 0;

  @override
  ProductModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProductModel(
      id: fields[0] as String,
      productName: fields[1] as String,
      hsnCode: fields[2] as String?,
      price: fields[3] as double,
      stockQuantity: fields[4] as int,
      description: fields[5] as String?,
      imagePath: fields[6] as String?,
      category: fields[7] as String?,
      minStockLevel: fields[8] as int,
      unit: fields[9] as String,
      isActive: fields[10] as bool,
      createdAt: fields[11] as DateTime,
      updatedAt: fields[12] as DateTime,
      isFixed: fields[13] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, ProductModel obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.productName)
      ..writeByte(2)
      ..write(obj.hsnCode)
      ..writeByte(3)
      ..write(obj.price)
      ..writeByte(4)
      ..write(obj.stockQuantity)
      ..writeByte(5)
      ..write(obj.description)
      ..writeByte(6)
      ..write(obj.imagePath)
      ..writeByte(7)
      ..write(obj.category)
      ..writeByte(8)
      ..write(obj.minStockLevel)
      ..writeByte(9)
      ..write(obj.unit)
      ..writeByte(10)
      ..write(obj.isActive)
      ..writeByte(11)
      ..write(obj.createdAt)
      ..writeByte(12)
      ..write(obj.updatedAt)
      ..writeByte(13)
      ..write(obj.isFixed);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
