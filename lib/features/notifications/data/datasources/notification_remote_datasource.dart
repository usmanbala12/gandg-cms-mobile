import '../../../../core/network/api_client.dart';

/// Remote data source for notifications - delegates to ApiClient.
class NotificationRemoteDataSource {
  final ApiClient apiClient;

  NotificationRemoteDataSource(this.apiClient);

  /// Fetch paginated notifications.
  Future<List<Map<String, dynamic>>> fetchNotifications({
    int page = 0,
    int size = 20,
    bool unreadOnly = false,
    String sortBy = 'createdAt',
    String sortDir = 'desc',
  }) async {
    return await apiClient.fetchNotifications(
      page: page,
      size: size,
      unreadOnly: unreadOnly,
      sortBy: sortBy,
      sortDir: sortDir,
    );
  }

  /// Get unread notification count.
  Future<int> fetchUnreadCount() async {
    return await apiClient.fetchNotificationUnreadCount();
  }

  /// Mark a notification as read.
  Future<void> markAsRead(String notificationId) async {
    await apiClient.markNotificationAsRead(notificationId);
  }

  /// Mark all notifications as read.
  Future<void> markAllAsRead() async {
    await apiClient.markAllNotificationsAsRead();
  }

  /// Delete a notification.
  Future<void> deleteNotification(String notificationId) async {
    await apiClient.deleteNotification(notificationId);
  }
}
