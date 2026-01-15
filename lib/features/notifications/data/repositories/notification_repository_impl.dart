import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

import '../../../../core/domain/repository_result.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_remote_datasource.dart';
import '../models/notification_model.dart';

/// Simplified NotificationRepository - remote only, no local caching.
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
  Stream<List<NotificationEntity>> watchNotifications(String userId) {
    // Remote-only: no local stream
    logger.w('watchNotifications is deprecated in remote-only mode');
    return Stream.value([]);
  }

  @override
  Future<RepositoryResult<List<NotificationEntity>>> getNotifications(
    String userId, {
    int limit = 50,
    int offset = 0,
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
        userId,
        limit: limit,
        offset: offset,
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
  Future<void> markAllAsRead(String userId) async {
    final isOnline = await networkInfo.isOnline();
    if (!isOnline) {
      throw Exception('Cannot mark notifications as read while offline.');
    }

    try {
      await remoteDataSource.markAllAsRead(userId);
    } catch (e) {
      logger.e('Error marking all notifications as read: $e');
      rethrow;
    }
  }

  @override
  Future<void> addNotification(NotificationEntity notification) async {
    // In remote-only mode, this is a no-op for push notifications
    // as they come from the server
    logger.d('addNotification called but notifications are remote-only');
  }
}
