import '../../../../core/domain/repository_result.dart';
import '../entities/notification_entity.dart';

/// Repository interface for notification operations.
/// See API endpoints: /api/v1/notifications/*
abstract class NotificationRepository {
  /// Fetch paginated notifications for the current user.
  /// [page] - Page number (0-indexed)
  /// [size] - Items per page
  /// [unreadOnly] - If true, returns only unread notifications
  /// [sortBy] - Field to sort by (default: "createdAt")
  /// [sortDir] - Sort direction: "asc" or "desc" (default: "desc")
  Future<RepositoryResult<List<NotificationEntity>>> getNotifications({
    int page = 0,
    int size = 20,
    bool unreadOnly = false,
    String sortBy = 'createdAt',
    String sortDir = 'desc',
  });

  /// Get the count of unread notifications (for badges).
  Future<RepositoryResult<int>> getUnreadCount();

  /// Mark a specific notification as read.
  Future<void> markAsRead(String id);

  /// Mark all notifications for the current user as read.
  Future<void> markAllAsRead();

  /// Delete a notification.
  Future<void> deleteNotification(String id);
}
