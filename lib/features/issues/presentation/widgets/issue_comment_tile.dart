import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/issue_comment_entity.dart';

class IssueCommentTile extends StatelessWidget {
  final IssueCommentEntity comment;
  final bool isCurrentUser;

  const IssueCommentTile({
    super.key,
    required this.comment,
    this.isCurrentUser = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat.yMMMd().add_jm();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isCurrentUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!isCurrentUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Text(
                comment.authorId.substring(0, 1).toUpperCase(),
                style: TextStyle(color: theme.colorScheme.onPrimaryContainer),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isCurrentUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isCurrentUser
                        ? theme.colorScheme.primaryContainer
                        : theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12).copyWith(
                      topLeft: isCurrentUser
                          ? const Radius.circular(12)
                          : const Radius.circular(0),
                      topRight: isCurrentUser
                          ? const Radius.circular(0)
                          : const Radius.circular(12),
                    ),
                  ),
                  child: Text(
                    comment.body,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isCurrentUser
                          ? theme.colorScheme.onPrimaryContainer
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (comment.isPending)
                      Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: Icon(
                          Icons.sync,
                          size: 12,
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    Text(
                      dateFormat.format(
                        DateTime.fromMillisecondsSinceEpoch(comment.createdAt),
                      ),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (isCurrentUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: theme.colorScheme.primary,
              child: Text(
                comment.authorId.substring(0, 1).toUpperCase(),
                style: TextStyle(color: theme.colorScheme.onPrimary),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
