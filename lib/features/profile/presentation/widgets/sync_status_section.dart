import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/sync_status_entity.dart';
import 'profile_section_card.dart';

/// Widget for displaying sync status and manual sync trigger.
class SyncStatusSection extends StatelessWidget {
  final SyncStatusEntity syncStatus;
  final VoidCallback onSyncNow;
  final bool isSyncing;

  const SyncStatusSection({
    super.key,
    required this.syncStatus,
    required this.onSyncNow,
    this.isSyncing = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ProfileSectionCard(
      title: 'Sync',
      child: Column(
        children: [
          _buildInfoRow(
            context,
            icon: Icons.sync,
            label: 'Last sync',
            value: _formatLastSync(syncStatus.lastFullSyncAt),
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            context,
            icon: Icons.pending_actions,
            label: 'Pending items',
            value: '${syncStatus.pendingQueueCount}',
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            context,
            icon: Icons.warning_amber,
            label: 'Conflicts',
            value: '${syncStatus.conflictCount}',
            valueColor: syncStatus.conflictCount > 0
                ? Colors.orange
                : theme.colorScheme.onSurface.withOpacity(0.7),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isSyncing ? null : onSyncNow,
              icon: isSyncing
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          theme.colorScheme.onPrimary,
                        ),
                      ),
                    )
                  : const Icon(Icons.sync),
              label: Text(isSyncing ? 'Syncing...' : 'Sync Now'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: theme.colorScheme.onSurface.withOpacity(0.6),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: valueColor ?? theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  String _formatLastSync(DateTime? lastSync) {
    if (lastSync == null) return 'Never';

    final now = DateTime.now();
    final difference = now.difference(lastSync);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d, yyyy').format(lastSync);
    }
  }
}
