import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import '../../../notifications/presentation/cubit/notifications_cubit.dart';
import '../widgets/notification_list_item.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _NotificationsView();
  }
}

class _NotificationsView extends StatefulWidget {
  const _NotificationsView();

  @override
  State<_NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<_NotificationsView> {
  @override
  void initState() {
    super.initState();
    _loadNotifications();
    // Start polling for unread count while on this page
    context.read<NotificationsCubit>().startPolling(seconds: 30);
  }

  @override
  void dispose() {
    // Stop polling when leaving the page
    // Note: Cubit close handles timer cleanup
    super.dispose();
  }

  void _loadNotifications() {
    context.read<NotificationsCubit>().loadNotifications();
  }

  void _onNotificationTap(notification) {
    // Mark as read
    context.read<NotificationsCubit>().markAsRead(notification.id);

    // Navigate based on URL if present
    if (notification.url != null && notification.url!.isNotEmpty) {
      // Strip /app prefix if present for router compatibility
      String path = notification.url!;
      if (path.startsWith('/app')) {
        path = path.replaceFirst('/app', '');
      }
      
      // Use Get.toNamed to navigate if path starts with /
      if (path.isNotEmpty && path.startsWith('/')) {
        Get.toNamed(path);
      }
    }
  }

  void _onDeleteNotification(String id) {
    context.read<NotificationsCubit>().deleteNotification(id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notification deleted'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            tooltip: 'Mark all as read',
            onPressed: () {
              context.read<NotificationsCubit>().markAllAsRead();
            },
          ),
        ],
      ),
      body: BlocBuilder<NotificationsCubit, NotificationsState>(
        builder: (context, state) {
          if (state is NotificationsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is NotificationsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off_outlined,
                    size: 48,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading notifications',
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: _loadNotifications,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else if (state is NotificationsLoaded) {
            if (state.notifications.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications_none,
                      size: 64,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No notifications',
                      style: TextStyle(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: () async {
                await context.read<NotificationsCubit>().loadNotifications();
              },
              child: ListView.builder(
                itemCount: state.notifications.length,
                itemBuilder: (context, index) {
                  final notification = state.notifications[index];
                  return Dismissible(
                    key: Key(notification.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: theme.colorScheme.error,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 16),
                      child: Icon(
                        Icons.delete,
                        color: theme.colorScheme.onError,
                      ),
                    ),
                    onDismissed: (_) => _onDeleteNotification(notification.id),
                    child: NotificationListItem(
                      notification: notification,
                      onTap: () => _onNotificationTap(notification),
                    ),
                  );
                },
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
