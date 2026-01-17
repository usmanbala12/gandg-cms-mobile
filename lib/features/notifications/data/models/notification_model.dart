import '../../domain/entities/notification_entity.dart';

/// NotificationModel - data layer representation with JSON parsing.
class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.id,
    required super.userId,
    required super.title,
    required super.message,
    super.url,
    required super.read,
    super.readAt,
    required super.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      // API uses 'message' but may fallback to 'content' in some views
      message: json['message']?.toString() ?? json['content']?.toString() ?? '',
      url: json['url']?.toString(),
      read: json['read'] == true,
      readAt: json['readAt'] != null
          ? DateTime.tryParse(json['readAt'].toString())
          : null,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  factory NotificationModel.fromEntity(NotificationEntity entity) {
    return NotificationModel(
      id: entity.id,
      userId: entity.userId,
      title: entity.title,
      message: entity.message,
      url: entity.url,
      read: entity.read,
      readAt: entity.readAt,
      createdAt: entity.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'message': message,
      'url': url,
      'read': read,
      'readAt': readAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
