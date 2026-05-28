import 'package:hive/hive.dart';

part 'vehicle_model.g.dart';

@HiveType(typeId: 11)
class VehicleModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String vehicleNumber;

  @HiveField(2)
  final String vehicleType;

  @HiveField(3)
  final double capacity;

  @HiveField(4)
  final String capacityUnit;

  @HiveField(5)
  final String? driverName;

  @HiveField(6)
  final String? driverPhone;

  @HiveField(7)
  final bool isActive;

  @HiveField(8)
  final DateTime createdAt;

  @HiveField(9)
  final DateTime updatedAt;

  VehicleModel({
    required this.id,
    required this.vehicleNumber,
    required this.vehicleType,
    required this.capacity,
    this.capacityUnit = 'Ton',
    this.driverName,
    this.driverPhone,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory VehicleModel.create({
    required String vehicleNumber,
    required String vehicleType,
    required double capacity,
    String capacityUnit = 'Ton',
    String? driverName,
    String? driverPhone,
  }) {
    final now = DateTime.now();
    return VehicleModel(
      id: _generateId(),
      vehicleNumber: vehicleNumber,
      vehicleType: vehicleType,
      capacity: capacity,
      capacityUnit: capacityUnit,
      driverName: driverName,
      driverPhone: driverPhone,
      isActive: true,
      createdAt: now,
      updatedAt: now,
    );
  }


  static String _generateId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp % 10000).toString().padLeft(4, '0');
    return 'VEH-$timestamp-$random';
  }

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: json['id'] as String,
      vehicleNumber: json['vehicleNumber'] as String,
      vehicleType: json['vehicleType'] as String,
      capacity: (json['capacity'] as num).toDouble(),
      capacityUnit: json['capacityUnit'] as String? ?? 'Ton',
      driverName: json['driverName'] as String?,
      driverPhone: json['driverPhone'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vehicleNumber': vehicleNumber,
      'vehicleType': vehicleType,
      'capacity': capacity,
      'capacityUnit': capacityUnit,
      'driverName': driverName,
      'driverPhone': driverPhone,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  VehicleModel copyWith({
    String? id,
    String? vehicleNumber,
    String? vehicleType,
    double? capacity,
    String? capacityUnit,
    String? driverName,
    String? driverPhone,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return VehicleModel(
      id: id ?? this.id,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      vehicleType: vehicleType ?? this.vehicleType,
      capacity: capacity ?? this.capacity,
      capacityUnit: capacityUnit ?? this.capacityUnit,
      driverName: driverName ?? this.driverName,
      driverPhone: driverPhone ?? this.driverPhone,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
