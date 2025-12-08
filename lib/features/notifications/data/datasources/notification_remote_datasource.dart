import '../../../../core/network/api_client.dart';

class NotificationRemoteDataSource {
  final ApiClient apiClient;

  NotificationRemoteDataSource(this.apiClient);

  Future<List<Map<String, dynamic>>> fetchNotifications(
    String userId, {
    int limit = 50,
    int offset = 0,
  }) async {
    // TODO: Implement API call when endpoint is available
    // return await apiClient.fetchNotifications(userId, limit: limit, offset: offset);
    return [];
  }

  Future<void> markAsRead(String notificationId) async {
    // TODO: Implement API call
    // await apiClient.markNotificationAsRead(notificationId);
  }

  Future<void> markAllAsRead(String userId) async {
    // TODO: Implement API call
    // await apiClient.markAllNotificationsAsRead(userId);
  }
}
