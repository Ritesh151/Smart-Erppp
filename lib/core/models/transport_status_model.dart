import 'package:hive/hive.dart';

part 'transport_status_model.g.dart';

@HiveType(typeId: 12)
enum TransportStatus {
  @HiveField(0)
  planned,
  @HiveField(1)
  onTheWay,
  @HiveField(2)
  delivered,
  @HiveField(3)
  cancelled,
}

extension TransportStatusExtension on TransportStatus {
  String get displayName {
    switch (this) {
      case TransportStatus.planned:
        return 'Planned';
      case TransportStatus.onTheWay:
        return 'On The Way';
      case TransportStatus.delivered:
        return 'Delivered';
      case TransportStatus.cancelled:
        return 'Cancelled';
    }
  }

  bool get isPlanned => this == TransportStatus.planned;
  bool get isOnTheWay => this == TransportStatus.onTheWay;
  bool get isDelivered => this == TransportStatus.delivered;
  bool get isCancelled => this == TransportStatus.cancelled;
  bool get isActive => this == TransportStatus.planned || this == TransportStatus.onTheWay;
  bool get isTerminal => this == TransportStatus.delivered || this == TransportStatus.cancelled;

  TransportStatus get nextStatus {
    switch (this) {
      case TransportStatus.planned:
        return TransportStatus.onTheWay;
      case TransportStatus.onTheWay:
        return TransportStatus.delivered;
      case TransportStatus.delivered:
      case TransportStatus.cancelled:
        return this;
    }
  }
}
