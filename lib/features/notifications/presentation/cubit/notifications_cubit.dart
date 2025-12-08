import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/domain/repository_result.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../domain/entities/notification_entity.dart';

part 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  final NotificationRepository repository;

  NotificationsCubit({required this.repository})
      : super(NotificationsInitial());

  Future<void> loadNotifications(String userId) async {
    emit(NotificationsLoading());

    try {
      final result = await repository.getNotifications(userId);
      emit(NotificationsLoaded(
        notifications: result.data,
        source: result.source,
      ));
    } catch (e) {
      emit(NotificationsError(message: e.toString()));
    }
  }

  Future<void> markAsRead(String id, String userId) async {
    try {
      await repository.markAsRead(id);
      // Reload to update UI
      await loadNotifications(userId);
    } catch (e) {
      // Optimistic update failed?
      // For now just reload or ignore
    }
  }

  Future<void> markAllAsRead(String userId) async {
    try {
      await repository.markAllAsRead(userId);
      await loadNotifications(userId);
    } catch (e) {
      // Ignore
    }
  }
}
