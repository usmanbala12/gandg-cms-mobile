import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../../core/db/app_database.dart';
import '../../domain/entities/notification_entity.dart';

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
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      projectId: json['project_id'],
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      type: json['type'],
      isRead: json['is_read'] == 1 || json['is_read'] == true,
      createdAt: json['created_at'] is int
          ? json['created_at']
          : DateTime.tryParse(json['created_at'] ?? '')
                  ?.millisecondsSinceEpoch ??
              DateTime.now().millisecondsSinceEpoch,
      serverId: json['id'],
      meta: json['metadata'] != null && json['metadata'] is String
          ? jsonDecode(json['metadata'])
          : (json['metadata'] is Map ? json['metadata'] : null),
    );
  }

  factory NotificationModel.fromDb(Notification row) {
    return NotificationModel(
      id: row.id,
      userId: row.userId,
      projectId: row.projectId,
      title: row.title,
      body: row.body,
      type: row.type,
      isRead: row.isRead == 1,
      createdAt: row.createdAt,
      serverId: row.serverId,
      meta: row.meta != null ? jsonDecode(row.meta!) : null,
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

  NotificationsCompanion toCompanion() {
    return NotificationsCompanion(
      id: Value(id),
      userId: Value(userId),
      projectId: Value(projectId),
      title: Value(title),
      body: Value(body),
      type: Value(type),
      isRead: Value(isRead ? 1 : 0),
      createdAt: Value(createdAt),
      serverId: Value(serverId),
      meta: Value(meta != null ? jsonEncode(meta) : null),
    );
  }
}
