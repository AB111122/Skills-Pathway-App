enum NotificationType { deadline, application, opportunity }

class NotificationModel {
  final String id;
  final String? opportunityId;
  final String title;
  final String message;
  final DateTime createdAt;
  final NotificationType type;
  final bool isRead;

  const NotificationModel({
    required this.id,
    this.opportunityId,
    required this.title,
    required this.message,
    required this.createdAt,
    required this.type,
    this.isRead = false,
  });

  NotificationModel copyWith({bool? isRead}) => NotificationModel(
        id: id,
        opportunityId: opportunityId,
        title: title,
        message: message,
        createdAt: createdAt,
        type: type,
        isRead: isRead ?? this.isRead,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'opportunityId': opportunityId,
        'title': title,
        'message': message,
        'createdAt': createdAt.toIso8601String(),
        'type': type.name,
        'isRead': isRead,
      };

  factory NotificationModel.fromJson(Map<String, dynamic> json) => NotificationModel(
        id: json['id'] as String,
        opportunityId: json['opportunityId'] as String?,
        title: json['title'] as String,
        message: json['message'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        type: NotificationType.values.firstWhere(
          (type) => type.name == json['type'],
          orElse: () => NotificationType.opportunity,
        ),
        isRead: json['isRead'] as bool? ?? false,
      );
}