import 'package:equatable/equatable.dart';

class NotificationEntity extends Equatable {
  final String id;
  final String userId;
  final String? projectId;
  final String title;
  final String body;
  final String type; // INFO, WARNING, ERROR, SUCCESS
  final bool isRead;
  final int createdAt;
  final String? serverId;
  final Map<String, dynamic>? meta;

  const NotificationEntity({
    required this.id,
    required this.userId,
    this.projectId,
    required this.title,
    required this.body,
    this.type = 'INFO',
    this.isRead = false,
    required this.createdAt,
    this.serverId,
    this.meta,
  });

  NotificationEntity copyWith({
    String? id,
    String? userId,
    String? projectId,
    String? title,
    String? body,
    String? type,
    bool? isRead,
    int? createdAt,
    String? serverId,
    Map<String, dynamic>? meta,
  }) {
    return NotificationEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      projectId: projectId ?? this.projectId,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      serverId: serverId ?? this.serverId,
      meta: meta ?? this.meta,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        projectId,
        title,
        body,
        type,
        isRead,
        createdAt,
        serverId,
        meta,
      ];
}
