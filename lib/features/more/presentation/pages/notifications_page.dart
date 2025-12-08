import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../notifications/presentation/cubit/notifications_cubit.dart';
import '../widgets/notification_list_item.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<NotificationsCubit>(),
      child: const _NotificationsView(),
    );
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
  }

  void _loadNotifications() {
    context.read<NotificationsCubit>().loadNotifications(
          'current_user_id', // TODO: Get from AuthBloc
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
            onPressed: () {
              context.read<NotificationsCubit>().markAllAsRead(
                    'current_user_id', // TODO: Get from AuthBloc
                  );
            },
          ),
        ],
      ),
      body: BlocBuilder<NotificationsCubit, NotificationsState>(
        builder: (context, state) {
          if (state is NotificationsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is NotificationsError) {
            return Center(child: Text('Error: ${state.message}'));
          } else if (state is NotificationsLoaded) {
            if (state.notifications.isEmpty) {
              return const Center(child: Text('No notifications.'));
            }
            return RefreshIndicator(
              onRefresh: () async {
                await context.read<NotificationsCubit>().loadNotifications(
                      'current_user_id', // TODO: Get from AuthBloc
                    );
              },
              child: ListView.builder(
                itemCount: state.notifications.length,
                itemBuilder: (context, index) {
                  final notification = state.notifications[index];
                  return NotificationListItem(
                    notification: notification,
                    onTap: () {
                      context.read<NotificationsCubit>().markAsRead(
                            notification.id,
                            'current_user_id', // TODO: Get from AuthBloc
                          );
                      // TODO: Navigate based on notification type/meta
                    },
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
