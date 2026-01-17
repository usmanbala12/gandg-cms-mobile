import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

import '../../../../core/domain/repository_result.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_remote_datasource.dart';
import '../models/notification_model.dart';

/// NotificationRepository implementation - remote only, no local caching.
class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;
  final Logger logger;

  NotificationRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
    Logger? logger,
  }) : logger = logger ?? Logger();

  @override
  Future<RepositoryResult<List<NotificationEntity>>> getNotifications({
    int page = 0,
    int size = 20,
    bool unreadOnly = false,
    String sortBy = 'createdAt',
    String sortDir = 'desc',
  }) async {
    final isOnline = await networkInfo.isOnline();

    if (!isOnline) {
      return RepositoryResult.local(
        [],
        message: 'You are offline. Notifications cannot be loaded.',
      );
    }

    try {
      final remoteData = await remoteDataSource.fetchNotifications(
        page: page,
        size: size,
        unreadOnly: unreadOnly,
        sortBy: sortBy,
        sortDir: sortDir,
      );

      final notifications = remoteData
          .map((data) => NotificationModel.fromJson(data))
          .toList();

      return RepositoryResult.remote(notifications);
    } on DioException catch (e) {
      logger.e('Dio error fetching notifications: $e');
      return RepositoryResult.local(
        [],
        message: 'Network error. Cannot load notifications.',
      );
    } catch (e) {
      logger.e('Error fetching notifications: $e');
      return RepositoryResult.local(
        [],
        message: 'Error loading notifications.',
      );
    }
  }

  @override
  Future<RepositoryResult<int>> getUnreadCount() async {
    final isOnline = await networkInfo.isOnline();

    if (!isOnline) {
      return RepositoryResult.local(
        0,
        message: 'You are offline.',
      );
    }

    try {
      final count = await remoteDataSource.fetchUnreadCount();
      return RepositoryResult.remote(count);
    } on DioException catch (e) {
      logger.e('Dio error fetching unread count: $e');
      return RepositoryResult.local(0, message: 'Network error.');
    } catch (e) {
      logger.e('Error fetching unread count: $e');
      return RepositoryResult.local(0, message: 'Error loading count.');
    }
  }

  @override
  Future<void> markAsRead(String id) async {
    final isOnline = await networkInfo.isOnline();
    if (!isOnline) {
      throw Exception('Cannot mark notification as read while offline.');
    }

    try {
      await remoteDataSource.markAsRead(id);
    } catch (e) {
      logger.e('Error marking notification as read: $e');
      rethrow;
    }
  }

  @override
  Future<void> markAllAsRead() async {
    final isOnline = await networkInfo.isOnline();
    if (!isOnline) {
      throw Exception('Cannot mark notifications as read while offline.');
    }

    try {
      await remoteDataSource.markAllAsRead();
    } catch (e) {
      logger.e('Error marking all notifications as read: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteNotification(String id) async {
    final isOnline = await networkInfo.isOnline();
    if (!isOnline) {
      throw Exception('Cannot delete notification while offline.');
    }

    try {
      await remoteDataSource.deleteNotification(id);
    } catch (e) {
      logger.e('Error deleting notification: $e');
      rethrow;
    }
  }
}
