import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

@HiveType(typeId: 19)
class AadhaarImageModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String employeeId;

  @HiveField(2)
  final String imageFilePath;

  @HiveField(3)
  final DateTime uploadedAt;

  @HiveField(4)
  final String? originalFileName;

  @HiveField(5)
  final int fileSize;

  @HiveField(6)
  final String imageType;

  @HiveField(7)
  final bool isVerified;

  AadhaarImageModel({
    required this.id,
    required this.employeeId,
    required this.imageFilePath,
    required this.uploadedAt,
    this.originalFileName,
    required this.fileSize,
    required this.imageType,
    this.isVerified = false,
  });

  factory AadhaarImageModel.create({
    required String employeeId,
    required String imageFilePath,
    String? originalFileName,
    required int fileSize,
    required String imageType,
  }) {
    return AadhaarImageModel(
      id: const Uuid().v4(),
      employeeId: employeeId,
      imageFilePath: imageFilePath,
      uploadedAt: DateTime.now(),
      originalFileName: originalFileName,
      fileSize: fileSize,
      imageType: imageType,
    );
  }

  factory AadhaarImageModel.fromJson(Map<String, dynamic> json) {
    return AadhaarImageModel(
      id: json['id'] as String,
      employeeId: json['employeeId'] as String,
      imageFilePath: json['imageFilePath'] as String,
      uploadedAt: DateTime.parse(json['uploadedAt'] as String),
      originalFileName: json['originalFileName'] as String?,
      fileSize: json['fileSize'] as int,
      imageType: json['imageType'] as String,
      isVerified: json['isVerified'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employeeId': employeeId,
      'imageFilePath': imageFilePath,
      'uploadedAt': uploadedAt.toIso8601String(),
      'originalFileName': originalFileName,
      'fileSize': fileSize,
      'imageType': imageType,
      'isVerified': isVerified,
    };
  }

  AadhaarImageModel copyWith({
    String? id,
    String? employeeId,
    String? imageFilePath,
    DateTime? uploadedAt,
    String? originalFileName,
    int? fileSize,
    String? imageType,
    bool? isVerified,
  }) {
    return AadhaarImageModel(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      imageFilePath: imageFilePath ?? this.imageFilePath,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      originalFileName: originalFileName ?? this.originalFileName,
      fileSize: fileSize ?? this.fileSize,
      imageType: imageType ?? this.imageType,
      isVerified: isVerified ?? this.isVerified,
    );
  }
}
