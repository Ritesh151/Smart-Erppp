import 'package:hive/hive.dart';
import 'transport_status_model.dart';

part 'transport_model.g.dart';

@HiveType(typeId: 9)
class TransportModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String transportNumber;

  @HiveField(2)
  final String vehicleId;

  @HiveField(3)
  final String vehicleNumber;

  @HiveField(4)
  final String? driverName;

  @HiveField(5)
  final String? driverPhone;

  @HiveField(6)
  final String origin;

  @HiveField(7)
  final String destination;

  @HiveField(8)
  final DateTime departureDate;

  @HiveField(9)
  final DateTime? estimatedArrival;

  @HiveField(10)
  final DateTime? actualArrival;

  @HiveField(11)
  final List<String> itemIds;

  @HiveField(12)
  final TransportStatus status;

  @HiveField(13)
  final double totalWeight;

  @HiveField(14)
  final int totalItems;

  @HiveField(15)
  final String? notes;

  @HiveField(16)
  final DateTime createdAt;

  @HiveField(17)
  final DateTime updatedAt;

  TransportModel({
    required this.id,
    required this.transportNumber,
    required this.vehicleId,
    required this.vehicleNumber,
    this.driverName,
    this.driverPhone,
    required this.origin,
    required this.destination,
    required this.departureDate,
    this.estimatedArrival,
    this.actualArrival,
    required this.itemIds,
    this.status = TransportStatus.planned,
    this.totalWeight = 0,
    this.totalItems = 0,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TransportModel.create({
    required String vehicleId,
    required String vehicleNumber,
    String? driverName,
    String? driverPhone,
    required String origin,
    required String destination,
    required DateTime departureDate,
    DateTime? estimatedArrival,
    List<String> itemIds = const [],
    String? notes,
  }) {
    final now = DateTime.now();
    return TransportModel(
      id: _generateId(),
      transportNumber: '',
      vehicleId: vehicleId,
      vehicleNumber: vehicleNumber,
      driverName: driverName,
      driverPhone: driverPhone,
      origin: origin,
      destination: destination,
      departureDate: departureDate,
      estimatedArrival: estimatedArrival,
      itemIds: itemIds,
      status: TransportStatus.planned,
      notes: notes,
      createdAt: now,
      updatedAt: now,
    );
  }

  static String _generateId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp % 10000).toString().padLeft(4, '0');
    return 'TRP-$timestamp-$random';
  }

  factory TransportModel.fromJson(Map<String, dynamic> json) {
    return TransportModel(
      id: json['id'] as String,
      transportNumber: json['transportNumber'] as String,
      vehicleId: json['vehicleId'] as String,
      vehicleNumber: json['vehicleNumber'] as String,
      driverName: json['driverName'] as String?,
      driverPhone: json['driverPhone'] as String?,
      origin: json['origin'] as String,
      destination: json['destination'] as String,
      departureDate: DateTime.parse(json['departureDate'] as String),
      estimatedArrival: json['estimatedArrival'] != null ? DateTime.parse(json['estimatedArrival'] as String) : null,
      actualArrival: json['actualArrival'] != null ? DateTime.parse(json['actualArrival'] as String) : null,
      itemIds: (json['itemIds'] as List<dynamic>?)?.cast<String>() ?? [],
      status: TransportStatus.values[json['status'] as int? ?? 0],
      totalWeight: (json['totalWeight'] as num?)?.toDouble() ?? 0,
      totalItems: json['totalItems'] as int? ?? 0,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'transportNumber': transportNumber,
      'vehicleId': vehicleId,
      'vehicleNumber': vehicleNumber,
      'driverName': driverName,
      'driverPhone': driverPhone,
      'origin': origin,
      'destination': destination,
      'departureDate': departureDate.toIso8601String(),
      'estimatedArrival': estimatedArrival?.toIso8601String(),
      'actualArrival': actualArrival?.toIso8601String(),
      'itemIds': itemIds,
      'status': status.index,
      'totalWeight': totalWeight,
      'totalItems': totalItems,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  TransportModel copyWith({
    String? id,
    String? transportNumber,
    String? vehicleId,
    String? vehicleNumber,
    String? driverName,
    String? driverPhone,
    String? origin,
    String? destination,
    DateTime? departureDate,
    DateTime? estimatedArrival,
    DateTime? actualArrival,
    List<String>? itemIds,
    TransportStatus? status,
    double? totalWeight,
    int? totalItems,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TransportModel(
      id: id ?? this.id,
      transportNumber: transportNumber ?? this.transportNumber,
      vehicleId: vehicleId ?? this.vehicleId,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      driverName: driverName ?? this.driverName,
      driverPhone: driverPhone ?? this.driverPhone,
      origin: origin ?? this.origin,
      destination: destination ?? this.destination,
      departureDate: departureDate ?? this.departureDate,
      estimatedArrival: estimatedArrival ?? this.estimatedArrival,
      actualArrival: actualArrival ?? this.actualArrival,
      itemIds: itemIds ?? this.itemIds,
      status: status ?? this.status,
      totalWeight: totalWeight ?? this.totalWeight,
      totalItems: totalItems ?? this.totalItems,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isPlanned => status == TransportStatus.planned;
  bool get isOnTheWay => status == TransportStatus.onTheWay;
  bool get isDelivered => status == TransportStatus.delivered;
  bool get isCancelled => status == TransportStatus.cancelled;
  bool get isActive => status.isActive;
  bool get isTerminal => status.isTerminal;

  String get duration {
    if (departureDate == null) return '';
    final end = actualArrival ?? estimatedArrival ?? DateTime.now();
    final diff = end.difference(departureDate);
    if (diff.inDays > 0) return '${diff.inDays}d ${diff.inHours.remainder(24)}h';
    return '${diff.inHours}h ${diff.inMinutes.remainder(60)}m';
  }
}
