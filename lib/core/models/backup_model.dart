import 'package:hive/hive.dart';

part 'backup_model.g.dart';

@HiveType(typeId: 39)
enum BackupStatus {
  @HiveField(0)
  completed,
  @HiveField(1)
  failed,
  @HiveField(2)
  inProgress,
  @HiveField(3)
  restoring,
}

@HiveType(typeId: 40)
enum BackupType {
  @HiveField(0)
  automatic,
  @HiveField(1)
  manual,
  @HiveField(2)
  import,
  @HiveField(3)
  export,
}

@HiveType(typeId: 35)
class BackupModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final BackupType type;

  @HiveField(4)
  final BackupStatus status;

  @HiveField(5)
  final double fileSizeBytes;

  @HiveField(6)
  final String filePath;

  @HiveField(7)
  final String fileFormat;

  @HiveField(8)
  final List<String> includedModules;

  @HiveField(9)
  final int recordCount;

  @HiveField(10)
  final String version;

  @HiveField(11)
  final bool isEncrypted;

  @HiveField(12)
  final String? checksum;

  @HiveField(13)
  final DateTime createdAt;

  @HiveField(14)
  final DateTime? restoredAt;

  BackupModel({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.status,
    this.fileSizeBytes = 0,
    required this.filePath,
    this.fileFormat = 'json',
    this.includedModules = const [],
    this.recordCount = 0,
    required this.version,
    this.isEncrypted = false,
    this.checksum,
    required this.createdAt,
    this.restoredAt,
  });

  factory BackupModel.create({
    required String name,
    String description = '',
    required BackupType type,
    BackupStatus status = BackupStatus.completed,
    double fileSizeBytes = 0,
    required String filePath,
    String fileFormat = 'json',
    List<String> includedModules = const [],
    int recordCount = 0,
    required String version,
    bool isEncrypted = false,
    String? checksum,
  }) {
    return BackupModel(
      id: _generateId(),
      name: name,
      description: description,
      type: type,
      status: status,
      fileSizeBytes: fileSizeBytes,
      filePath: filePath,
      fileFormat: fileFormat,
      includedModules: includedModules,
      recordCount: recordCount,
      version: version,
      isEncrypted: isEncrypted,
      checksum: checksum,
      createdAt: DateTime.now(),
    );
  }

  static String _generateId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp % 10000).toString().padLeft(4, '0');
    return 'BAK-$timestamp-$random';
  }

  factory BackupModel.fromJson(Map<String, dynamic> json) {
    return BackupModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      type: BackupType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => BackupType.manual,
      ),
      status: BackupStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => BackupStatus.completed,
      ),
      fileSizeBytes: (json['fileSizeBytes'] as num?)?.toDouble() ?? 0,
      filePath: json['filePath'] as String,
      fileFormat: (json['fileFormat'] as String?) ?? 'json',
      includedModules: (json['includedModules'] as List<dynamic>?)
              ?.cast<String>()
              .toList() ??
          [],
      recordCount: (json['recordCount'] as num?)?.toInt() ?? 0,
      version: json['version'] as String,
      isEncrypted: json['isEncrypted'] as bool? ?? false,
      checksum: json['checksum'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      restoredAt: json['restoredAt'] != null
          ? DateTime.parse(json['restoredAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type.name,
      'status': status.name,
      'fileSizeBytes': fileSizeBytes,
      'filePath': filePath,
      'fileFormat': fileFormat,
      'includedModules': includedModules,
      'recordCount': recordCount,
      'version': version,
      'isEncrypted': isEncrypted,
      'checksum': checksum,
      'createdAt': createdAt.toIso8601String(),
      'restoredAt': restoredAt?.toIso8601String(),
    };
  }

  BackupModel copyWith({
    String? id,
    String? name,
    String? description,
    BackupType? type,
    BackupStatus? status,
    double? fileSizeBytes,
    String? filePath,
    String? fileFormat,
    List<String>? includedModules,
    int? recordCount,
    String? version,
    bool? isEncrypted,
    String? checksum,
    DateTime? createdAt,
    DateTime? restoredAt,
  }) {
    return BackupModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      status: status ?? this.status,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      filePath: filePath ?? this.filePath,
      fileFormat: fileFormat ?? this.fileFormat,
      includedModules: includedModules ?? this.includedModules,
      recordCount: recordCount ?? this.recordCount,
      version: version ?? this.version,
      isEncrypted: isEncrypted ?? this.isEncrypted,
      checksum: checksum ?? this.checksum,
      createdAt: createdAt ?? this.createdAt,
      restoredAt: restoredAt ?? this.restoredAt,
    );
  }

  String get formattedSize {
    if (fileSizeBytes < 1024) return '${fileSizeBytes.toStringAsFixed(0)} B';
    if (fileSizeBytes < 1024 * 1024) {
      return '${(fileSizeBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(fileSizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  int get moduleCount => includedModules.length;

  bool get isAutomatic => type == BackupType.automatic;
  bool get isManual => type == BackupType.manual;
  bool get isSuccessful => status == BackupStatus.completed;
  bool get hasFailed => status == BackupStatus.failed;

  String get statusLabel {
    switch (status) {
      case BackupStatus.completed:
        return 'Completed';
      case BackupStatus.failed:
        return 'Failed';
      case BackupStatus.inProgress:
        return 'In Progress';
      case BackupStatus.restoring:
        return 'Restoring';
    }
  }
}
