import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../notifications/domain/entities/notification_entity.dart';

class NotificationListItem extends StatelessWidget {
  final NotificationEntity notification;
  final VoidCallback? onTap;

  const NotificationListItem({
    super.key,
    required this.notification,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Container(
        color: notification.read
            ? Colors.transparent
            : theme.colorScheme.primary.withValues(alpha: 0.05),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 4),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: notification.read
                    ? Colors.transparent
                    : theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: TextStyle(
                            fontWeight: notification.read
                                ? FontWeight.normal
                                : FontWeight.bold,
                            fontSize: 14,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                      Text(
                        timeago.format(notification.createdAt),
                        style: TextStyle(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.message,
                    style: TextStyle(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // Show URL indicator if present
                  if (notification.url != null && notification.url!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        children: [
                          Icon(
                            Icons.arrow_forward,
                            size: 12,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Tap to view',
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
