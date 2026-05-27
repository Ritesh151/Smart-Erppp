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
      gstRate: fields[5] as double,
      description: fields[6] as String?,
      imagePath: fields[7] as String?,
      category: fields[8] as String,
      costPrice: fields[9] as double,
      minStockLevel: fields[10] as int,
      unit: fields[11] as String,
      sku: fields[12] as String?,
      barcode: fields[13] as String?,
      isActive: fields[14] as bool,
      createdAt: fields[15] as DateTime,
      updatedAt: fields[16] as DateTime,
      isFixed: fields[17] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, ProductModel obj) {
    writer
      ..writeByte(18)
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
      ..write(obj.gstRate)
      ..writeByte(6)
      ..write(obj.description)
      ..writeByte(7)
      ..write(obj.imagePath)
      ..writeByte(8)
      ..write(obj.category)
      ..writeByte(9)
      ..write(obj.costPrice)
      ..writeByte(10)
      ..write(obj.minStockLevel)
      ..writeByte(11)
      ..write(obj.unit)
      ..writeByte(12)
      ..write(obj.sku)
      ..writeByte(13)
      ..write(obj.barcode)
      ..writeByte(14)
      ..write(obj.isActive)
      ..writeByte(15)
      ..write(obj.createdAt)
      ..writeByte(16)
      ..write(obj.updatedAt)
      ..writeByte(17)
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
