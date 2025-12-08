import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

import '../../../../core/db/daos/notification_dao.dart';
import '../../../../core/domain/repository_result.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_remote_datasource.dart';
import '../models/notification_model.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationDao notificationDao;
  final NotificationRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;
  final Logger logger;

  NotificationRepositoryImpl({
    required this.notificationDao,
    required this.remoteDataSource,
    required this.networkInfo,
    Logger? logger,
  }) : logger = logger ?? Logger();

  @override
  Stream<List<NotificationEntity>> watchNotifications(String userId) {
    return notificationDao.watchNotificationsForUser(userId).map((rows) {
      return rows.map((row) => NotificationModel.fromDb(row)).toList();
    });
  }

  @override
  Future<RepositoryResult<List<NotificationEntity>>> getNotifications(
    String userId, {
    int limit = 50,
    int offset = 0,
  }) async {
    // Get cached notifications
    final rows = await notificationDao.getNotificationsForUser(
      userId,
      limit: limit,
      offset: offset,
    );
    final cached = rows.map((row) => NotificationModel.fromDb(row)).toList();

    // Check connectivity
    final isOnline = await networkInfo.isOnline();

    if (!isOnline) {
      return RepositoryResult.local(
        cached,
        message: 'Offline mode. Showing cached notifications.',
      );
    }

    // Online - fetch from remote
    try {
      final remoteData = await remoteDataSource.fetchNotifications(
        userId,
        limit: limit,
        offset: offset,
      );

      // Upsert to local DB
      for (final data in remoteData) {
        final model = NotificationModel.fromJson(data);
        await notificationDao.insertNotification(model.toCompanion());
      }

      // Return fresh local data
      final updatedRows = await notificationDao.getNotificationsForUser(
        userId,
        limit: limit,
        offset: offset,
      );
      final notifications =
          updatedRows.map((row) => NotificationModel.fromDb(row)).toList();

      return RepositoryResult.remote(notifications);
    } on DioException catch (e) {
      logger.e('Dio error fetching notifications: $e');
      return RepositoryResult.local(
        cached,
        message: 'Network error. Showing cached notifications.',
      );
    } catch (e) {
      logger.e('Error fetching notifications: $e');
      return RepositoryResult.local(
        cached,
        message: 'Error loading notifications. Showing cached data.',
      );
    }
  }

  @override
  Future<void> markAsRead(String id) async {
    await notificationDao.markAsRead(id);
    // TODO: Sync with server
    // try {
    //   if (await networkInfo.isOnline()) {
    //     await remoteDataSource.markAsRead(id);
    //   }
    // } catch (e) {
    //   logger.e('Error marking notification as read on server: $e');
    // }
  }

  @override
  Future<void> markAllAsRead(String userId) async {
    await notificationDao.markAllAsRead(userId);
    // TODO: Sync with server
  }

  @override
  Future<void> addNotification(NotificationEntity notification) async {
    final model = NotificationModel.fromEntity(notification);
    await notificationDao.insertNotification(model.toCompanion());
  }
}
