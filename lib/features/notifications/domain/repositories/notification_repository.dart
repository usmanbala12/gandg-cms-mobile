import '../../../../core/domain/repository_result.dart';
import '../entities/notification_entity.dart';

abstract class NotificationRepository {
  Stream<List<NotificationEntity>> watchNotifications(String userId);
  Future<RepositoryResult<List<NotificationEntity>>> getNotifications(
    String userId, {
    int limit = 50,
    int offset = 0,
  });
  Future<void> markAsRead(String id);
  Future<void> markAllAsRead(String userId);
  Future<void> addNotification(NotificationEntity notification);
}
