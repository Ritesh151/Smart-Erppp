import 'package:hive/hive.dart';

part 'notification_model.g.dart';

@HiveType(typeId: 37)
enum NotificationCategory {
  @HiveField(0)
  lowStock,
  @HiveField(1)
  salaryReminder,
  @HiveField(2)
  paymentDue,
  @HiveField(3)
  transportAlert,
  @HiveField(4)
  invoiceReminder,
  @HiveField(5)
  system,
  @HiveField(6)
  backup,
  @HiveField(7)
  businessAlert,
}

@HiveType(typeId: 38)
enum NotificationPriority {
  @HiveField(0)
  low,
  @HiveField(1)
  medium,
  @HiveField(2)
  high,
  @HiveField(3)
  critical,
}

@HiveType(typeId: 34)
class NotificationModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String message;

  @HiveField(3)
  final NotificationCategory category;

  @HiveField(4)
  final NotificationPriority priority;

  @HiveField(5)
  final bool isRead;

  @HiveField(6)
  final String? referenceId;

  @HiveField(7)
  final String? referenceType;

  @HiveField(8)
  final String? actionRoute;

  @HiveField(9)
  final DateTime createdAt;

  @HiveField(10)
  final DateTime? readAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.category,
    this.priority = NotificationPriority.medium,
    this.isRead = false,
    this.referenceId,
    this.referenceType,
    this.actionRoute,
    required this.createdAt,
    this.readAt,
  });

  factory NotificationModel.create({
    required String title,
    required String message,
    required NotificationCategory category,
    NotificationPriority priority = NotificationPriority.medium,
    String? referenceId,
    String? referenceType,
    String? actionRoute,
  }) {
    return NotificationModel(
      id: _generateId(),
      title: title,
      message: message,
      category: category,
      priority: priority,
      referenceId: referenceId,
      referenceType: referenceType,
      actionRoute: actionRoute,
      createdAt: DateTime.now(),
    );
  }

  static String _generateId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp % 10000).toString().padLeft(4, '0');
    return 'NOT-$timestamp-$random';
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      category: NotificationCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => NotificationCategory.system,
      ),
      priority: NotificationPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => NotificationPriority.medium,
      ),
      isRead: json['isRead'] as bool? ?? false,
      referenceId: json['referenceId'] as String?,
      referenceType: json['referenceType'] as String?,
      actionRoute: json['actionRoute'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      readAt: json['readAt'] != null ? DateTime.parse(json['readAt'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'category': category.name,
      'priority': priority.name,
      'isRead': isRead,
      'referenceId': referenceId,
      'referenceType': referenceType,
      'actionRoute': actionRoute,
      'createdAt': createdAt.toIso8601String(),
      'readAt': readAt?.toIso8601String(),
    };
  }

  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    NotificationCategory? category,
    NotificationPriority? priority,
    bool? isRead,
    String? referenceId,
    String? referenceType,
    String? actionRoute,
    DateTime? createdAt,
    DateTime? readAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      isRead: isRead ?? this.isRead,
      referenceId: referenceId ?? this.referenceId,
      referenceType: referenceType ?? this.referenceType,
      actionRoute: actionRoute ?? this.actionRoute,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
    );
  }

  NotificationModel markAsRead() => copyWith(isRead: true, readAt: DateTime.now());

  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }

  bool get isHighPriority => priority == NotificationPriority.high || priority == NotificationPriority.critical;
  bool get isRecent => DateTime.now().difference(createdAt).inHours < 24;
}
