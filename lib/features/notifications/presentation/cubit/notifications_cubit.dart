import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import 'package:field_link/features/notifications/domain/repositories/notification_repository.dart';

import 'package:field_link/features/notifications/presentation/cubit/notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  final NotificationRepository repository;
  Timer? _pollingTimer;

  NotificationsCubit({required this.repository})
      : super(NotificationsInitial());

  /// Load notifications with optional pagination parameters.
  Future<void> loadNotifications({
    int page = 0,
    int size = 20,
    bool unreadOnly = false,
  }) async {
    emit(NotificationsLoading());

    try {
      final result = await repository.getNotifications(
        page: page,
        size: size,
        unreadOnly: unreadOnly,
      );
      final countResult = await repository.getUnreadCount();

      emit(NotificationsLoaded(
        notifications: result.data,
        unreadCount: countResult.data,
      ));
    } catch (e) {
      emit(NotificationsError(message: e.toString()));
    }
  }

  /// Fetch only the unread count (for badges/polling).
  Future<int> fetchUnreadCount() async {
    try {
      final result = await repository.getUnreadCount();
      final currentState = state;
      if (currentState is NotificationsLoaded) {
        emit(NotificationsLoaded(
          notifications: currentState.notifications,
          unreadCount: result.data,
        ));
      }
      return result.data;
    } catch (e) {
      return 0;
    }
  }

  /// Mark a specific notification as read.
  Future<void> markAsRead(String id) async {
    try {
      await repository.markAsRead(id);
      // Reload to update UI
      await loadNotifications();
    } catch (e) {
      // Optimistic update failed, just reload
    }
  }

  /// Mark all notifications as read.
  Future<void> markAllAsRead() async {
    try {
      await repository.markAllAsRead();
      await loadNotifications();
    } catch (e) {
      // Ignore
    }
  }

  /// Delete a notification.
  Future<void> deleteNotification(String id) async {
    try {
      await repository.deleteNotification(id);
      await loadNotifications();
    } catch (e) {
      // Ignore
    }
  }

  /// Start polling for unread count every [seconds].
  void startPolling({int seconds = 30}) {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(
      Duration(seconds: seconds),
      (_) => fetchUnreadCount(),
    );
  }

  /// Stop polling.
  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  @override
  Future<void> close() {
    _pollingTimer?.cancel();
    return super.close();
  }
}
