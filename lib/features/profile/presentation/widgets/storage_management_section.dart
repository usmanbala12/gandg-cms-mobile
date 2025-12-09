import 'package:flutter/material.dart';

import '../../domain/entities/storage_stats_entity.dart';
import 'profile_section_card.dart';

/// Widget for displaying storage statistics and cache management.
class StorageManagementSection extends StatelessWidget {
  final StorageStatsEntity storageStats;
  final VoidCallback onClearOldCache;
  final VoidCallback onClearMediaCache;
  final bool isClearing;

  const StorageManagementSection({
    super.key,
    required this.storageStats,
    required this.onClearOldCache,
    required this.onClearMediaCache,
    this.isClearing = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ProfileSectionCard(
      title: 'Storage',
      child: Column(
        children: [
          _buildInfoRow(
            context,
            icon: Icons.storage,
            label: 'Database',
            value: '${storageStats.dbSizeMB.toStringAsFixed(2)} MB',
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            context,
            icon: Icons.photo_library,
            label: 'Media cache',
            value: '${storageStats.mediaSizeMB.toStringAsFixed(2)} MB',
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            context,
            icon: Icons.folder,
            label: 'Total records',
            value:
                '${storageStats.recordsByTable.values.fold<int>(0, (a, b) => a + b)}',
          ),
          const SizedBox(height: 16),
          Divider(color: theme.dividerColor),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: isClearing
                  ? null
                  : () => _showClearCacheConfirmation(context, onClearOldCache),
              icon: const Icon(Icons.delete_sweep),
              label: const Text('Clear Old Cache'),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: isClearing
                  ? null
                  : () =>
                      _showClearMediaConfirmation(context, onClearMediaCache),
              icon: const Icon(Icons.delete_outline),
              label: const Text('Clear Media Cache'),
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
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  void _showClearCacheConfirmation(
    BuildContext context,
    VoidCallback onConfirm,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Old Cache'),
        content: const Text(
          'This will remove cached data older than 30 days. '
          'You can re-sync data from the server later.\n\n'
          'Are you sure you want to continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onConfirm();
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showClearMediaConfirmation(
    BuildContext context,
    VoidCallback onConfirm,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Media Cache'),
        content: const Text(
          'This will remove all downloaded media files. '
          'You will need to download them again when needed.\n\n'
          'Are you sure you want to continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onConfirm();
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}
