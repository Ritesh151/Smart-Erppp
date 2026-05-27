import 'package:hive/hive.dart';

part 'employee_model.g.dart';

@HiveType(typeId: 13)
class EmployeeModel extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String employeeCode;
  @HiveField(2)
  final String firstName;
  @HiveField(3)
  final String lastName;
  @HiveField(4)
  final String email;
  @HiveField(5)
  final String phone;
  @HiveField(6)
  final String? address;
  @HiveField(7)
  final String department;
  @HiveField(8)
  final String designation;
  @HiveField(9)
  final DateTime dateOfJoining;
  @HiveField(10)
  final DateTime? dateOfBirth;
  @HiveField(11)
  final double salary;
  @HiveField(12)
  final EmploymentType employmentType;
  @HiveField(13)
  final EmployeeStatus status;
  @HiveField(14)
  final String? bankAccountNumber;
  @HiveField(15)
  final String? bankName;
  @HiveField(16)
  final String? ifscCode;
  @HiveField(17)
  final String? panNumber;
  @HiveField(18)
  final String? aadharNumber;
  @HiveField(19)
  final DateTime createdAt;
  @HiveField(20)
  final DateTime updatedAt;

  EmployeeModel({
    required this.id,
    required this.employeeCode,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    this.address,
    required this.department,
    required this.designation,
    required this.dateOfJoining,
    this.dateOfBirth,
    required this.salary,
    required this.employmentType,
    required this.status,
    this.bankAccountNumber,
    this.bankName,
    this.ifscCode,
    this.panNumber,
    this.aadharNumber,
    required this.createdAt,
    required this.updatedAt,
  });

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    return EmployeeModel(
      id: json['id'] as String,
      employeeCode: json['employeeCode'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      address: json['address'] as String?,
      department: json['department'] as String,
      designation: json['designation'] as String,
      dateOfJoining: DateTime.parse(json['dateOfJoining'] as String),
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.parse(json['dateOfBirth'] as String)
          : null,
      salary: (json['salary'] as num).toDouble(),
      employmentType: EmploymentType.values.firstWhere(
        (e) => e.name == json['employmentType'],
        orElse: () => EmploymentType.fullTime,
      ),
      status: EmployeeStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => EmployeeStatus.active,
      ),
      bankAccountNumber: json['bankAccountNumber'] as String?,
      bankName: json['bankName'] as String?,
      ifscCode: json['ifscCode'] as String?,
      panNumber: json['panNumber'] as String?,
      aadharNumber: json['aadharNumber'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employeeCode': employeeCode,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'address': address,
      'department': department,
      'designation': designation,
      'dateOfJoining': dateOfJoining.toIso8601String(),
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'salary': salary,
      'employmentType': employmentType.name,
      'status': status.name,
      'bankAccountNumber': bankAccountNumber,
      'bankName': bankName,
      'ifscCode': ifscCode,
      'panNumber': panNumber,
      'aadharNumber': aadharNumber,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  String get fullName => '$firstName $lastName';

  int get experienceInYears {
    final now = DateTime.now();
    return now.year - dateOfJoining.year;
  }

  int? get age {
    if (dateOfBirth == null) return null;
    final now = DateTime.now();
    return now.year - dateOfBirth!.year;
  }

  EmployeeModel copyWith({
    String? id,
    String? employeeCode,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? address,
    String? department,
    String? designation,
    DateTime? dateOfJoining,
    DateTime? dateOfBirth,
    double? salary,
    EmploymentType? employmentType,
    EmployeeStatus? status,
    String? bankAccountNumber,
    String? bankName,
    String? ifscCode,
    String? panNumber,
    String? aadharNumber,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EmployeeModel(
      id: id ?? this.id,
      employeeCode: employeeCode ?? this.employeeCode,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      department: department ?? this.department,
      designation: designation ?? this.designation,
      dateOfJoining: dateOfJoining ?? this.dateOfJoining,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      salary: salary ?? this.salary,
      employmentType: employmentType ?? this.employmentType,
      status: status ?? this.status,
      bankAccountNumber: bankAccountNumber ?? this.bankAccountNumber,
      bankName: bankName ?? this.bankName,
      ifscCode: ifscCode ?? this.ifscCode,
      panNumber: panNumber ?? this.panNumber,
      aadharNumber: aadharNumber ?? this.aadharNumber,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

@HiveType(typeId: 17)
enum EmploymentType {
  @HiveField(0)
  fullTime,
  @HiveField(1)
  partTime,
  @HiveField(2)
  contract,
  @HiveField(3)
  intern,
}

@HiveType(typeId: 18)
enum EmployeeStatus {
  @HiveField(0)
  active,
  @HiveField(1)
  inactive,
  @HiveField(2)
  onLeave,
  @HiveField(3)
  terminated,
}
