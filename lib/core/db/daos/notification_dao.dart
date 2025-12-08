import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/notifications.dart';

part 'notification_dao.g.dart';

@DriftAccessor(tables: [Notifications])
class NotificationDao extends DatabaseAccessor<AppDatabase>
    with _$NotificationDaoMixin {
  NotificationDao(super.db);

  /// Insert a notification
  Future<void> insertNotification(NotificationsCompanion notification) async {
    await into(notifications).insertOnConflictUpdate(notification);
  }

  /// Update a notification
  Future<void> updateNotification(NotificationsCompanion notification) async {
    await update(notifications).replace(notification);
  }

  /// Get notifications for a user
  Future<List<Notification>> getNotificationsForUser(
    String userId, {
    int limit = 50,
    int offset = 0,
  }) async {
    return (select(notifications)
          ..where((tbl) => tbl.userId.equals(userId))
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)])
          ..limit(limit, offset: offset))
        .get();
  }

  /// Watch notifications for a user
  Stream<List<Notification>> watchNotificationsForUser(String userId) {
    return (select(notifications)
          ..where((tbl) => tbl.userId.equals(userId))
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]))
        .watch();
  }

  /// Mark a notification as read
  Future<void> markAsRead(String id) async {
    await (update(notifications)..where((tbl) => tbl.id.equals(id))).write(
      const NotificationsCompanion(isRead: Value(1)),
    );
  }

  /// Mark all notifications as read for a user
  Future<void> markAllAsRead(String userId) async {
    await (update(notifications)..where((tbl) => tbl.userId.equals(userId)))
        .write(const NotificationsCompanion(isRead: Value(1)));
  }

  /// Clear all notifications for a user
  Future<void> clearAll(String userId) async {
    await (delete(notifications)..where((tbl) => tbl.userId.equals(userId)))
        .go();
  }

  /// Get unread count
  Future<int> getUnreadCount(String userId) async {
    final count = await (select(notifications)
          ..where(
            (tbl) => tbl.userId.equals(userId) & tbl.isRead.equals(0),
          ))
        .get();
    return count.length;
  }
}
