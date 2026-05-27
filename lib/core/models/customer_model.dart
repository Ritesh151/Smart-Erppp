import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'customer_model.g.dart';

@HiveType(typeId: 5)
class CustomerModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String? email;

  @HiveField(3)
  final String? phone;

  @HiveField(4)
  final String? address;

  @HiveField(5)
  final String? gstNumber;

  @HiveField(6)
  final String? city;

  @HiveField(7)
  final String? state;

  @HiveField(8)
  final String? pincode;

  @HiveField(9)
  final bool isActive;

  @HiveField(10)
  final DateTime createdAt;

  @HiveField(11)
  final DateTime updatedAt;

  CustomerModel({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.address,
    this.gstNumber,
    this.city,
    this.state,
    this.pincode,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CustomerModel.create({
    required String name,
    String? email,
    String? phone,
    String? address,
    String? gstNumber,
    String? city,
    String? state,
    String? pincode,
  }) {
    return CustomerModel(
      id: const Uuid().v4(),
      name: name,
      email: email,
      phone: phone,
      address: address,
      gstNumber: gstNumber,
      city: city,
      state: state,
      pincode: pincode,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      gstNumber: json['gstNumber'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      pincode: json['pincode'] as String?,
      isActive: json['isActive'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'gstNumber': gstNumber,
      'city': city,
      'state': state,
      'pincode': pincode,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  CustomerModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? address,
    String? gstNumber,
    String? city,
    String? state,
    String? pincode,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CustomerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      gstNumber: gstNumber ?? this.gstNumber,
      city: city ?? this.city,
      state: state ?? this.state,
      pincode: pincode ?? this.pincode,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
