import 'package:equatable/equatable.dart';

/// Notification entity matching backend API response.
/// See: GET /api/v1/notifications
class NotificationEntity extends Equatable {
  final String id;
  final String userId;
  final String title;
  final String message;
  final String? url; // Internal link for deep navigation, e.g., /projects/123
  final bool read;
  final DateTime? readAt;
  final DateTime createdAt;

  const NotificationEntity({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    this.url,
    required this.read,
    this.readAt,
    required this.createdAt,
  });

  NotificationEntity copyWith({
    String? id,
    String? userId,
    String? title,
    String? message,
    String? url,
    bool? read,
    DateTime? readAt,
    DateTime? createdAt,
  }) {
    return NotificationEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      message: message ?? this.message,
      url: url ?? this.url,
      read: read ?? this.read,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        title,
        message,
        url,
        read,
        readAt,
        createdAt,
      ];
}
