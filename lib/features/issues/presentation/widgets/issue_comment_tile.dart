import 'package:field_link/core/utils/theme/design_system.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

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
    final isDark = theme.brightness == Brightness.dark;
    final isActivity = comment.type != 'COMMENT' && comment.type != null;

    if (isActivity) {
      return _buildActivityTile(context);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isCurrentUser) _buildAvatar(context),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (!isCurrentUser)
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 4),
                    child: Text(
                      _getAuthorName(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: DesignSystem.primary,
                      ),
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isCurrentUser
                        ? DesignSystem.primary
                        : (isDark ? DesignSystem.surfaceDark : DesignSystem.surfaceLight),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isCurrentUser ? 16 : 4),
                      bottomRight: Radius.circular(isCurrentUser ? 4 : 16),
                    ),
                    boxShadow: DesignSystem.shadowSm,
                    border: isCurrentUser 
                        ? null 
                        : Border.all(color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05)),
                  ),
                  child: Text(
                    comment.content,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isCurrentUser 
                          ? Colors.white 
                          : (isDark ? DesignSystem.textPrimaryDark : DesignSystem.textPrimaryLight),
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (comment.isPending)
                      const Padding(
                        padding: EdgeInsets.only(right: 4),
                        child: Icon(Icons.sync_rounded, size: 10, color: DesignSystem.textSecondaryLight),
                      ),
                    Text(
                      timeago.format(DateTime.fromMillisecondsSinceEpoch(comment.createdAt)),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: DesignSystem.textSecondaryLight,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (isCurrentUser) ...[
            const SizedBox(width: 8),
            _buildAvatar(context),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatar(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: DesignSystem.primary.withValues(alpha: 0.2),
          width: 2,
        ),
      ),
      child: CircleAvatar(
        radius: 16,
        backgroundColor: isCurrentUser 
            ? DesignSystem.primary.withValues(alpha: 0.1) 
            : (isDark ? DesignSystem.surfaceSelectedDark : DesignSystem.surfaceSelectedLight),
        child: Text(
          _getInitials(),
          style: TextStyle(
            color: DesignSystem.primary,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildActivityTile(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 32),
      child: Row(
        children: [
          const Expanded(child: Divider(endIndent: 16)),
          Text(
            comment.content,
            style: theme.textTheme.labelSmall?.copyWith(
              color: DesignSystem.textSecondaryLight,
              fontStyle: FontStyle.italic,
            ),
          ),
          const Expanded(child: Divider(indent: 16)),
        ],
      ),
    );
  }

  String _getAuthorName() {
    return comment.author?['fullName']?.toString() ??
        (comment.author?['firstName'] != null
            ? '${comment.author!['firstName']} ${comment.author!['lastName'] ?? ''}'.trim()
            : comment.authorId);
  }

  String _getInitials() {
    final name = _getAuthorName().trim();
    if (name.isEmpty) return '?';
    final parts = name.split(RegExp(r'\s+'));
    if (parts.length > 1 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return name[0].toUpperCase();
  }
}
