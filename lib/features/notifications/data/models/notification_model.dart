import 'dart:convert';

import '../../domain/entities/notification_entity.dart';

/// Simplified NotificationModel - remote only, no local DB dependencies.
class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.id,
    required super.userId,
    super.projectId,
    required super.title,
    required super.body,
    super.type,
    super.isRead,
    required super.createdAt,
    super.serverId,
    super.meta,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      projectId: json['project_id']?.toString(),
      title: json['title'] ?? '',
      body: json['body'] ?? json['message'] ?? '',
      type: json['type'],
      isRead: json['is_read'] == 1 || json['is_read'] == true,
      createdAt: json['created_at'] is int
          ? json['created_at']
          : DateTime.tryParse(json['created_at'] ?? '')
                  ?.millisecondsSinceEpoch ??
              DateTime.now().millisecondsSinceEpoch,
      serverId: json['id']?.toString(),
      meta: json['metadata'] != null && json['metadata'] is String
          ? jsonDecode(json['metadata'])
          : (json['metadata'] is Map ? json['metadata'] : null),
    );
  }

  factory NotificationModel.fromEntity(NotificationEntity entity) {
    return NotificationModel(
      id: entity.id,
      userId: entity.userId,
      projectId: entity.projectId,
      title: entity.title,
      body: entity.body,
      type: entity.type,
      isRead: entity.isRead,
      createdAt: entity.createdAt,
      serverId: entity.serverId,
      meta: entity.meta,
    );
  }
}
