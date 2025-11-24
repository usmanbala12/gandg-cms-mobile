import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../daos/project_dao.dart';
import '../daos/sync_queue_dao.dart';
import '../daos/conflict_dao.dart';

/// Debug page for inspecting database state.
/// Only visible in debug builds (kDebugMode).
class DbInspectorPage extends StatefulWidget {
  const DbInspectorPage({super.key});

  @override
  State<DbInspectorPage> createState() => _DbInspectorPageState();
}

class _DbInspectorPageState extends State<DbInspectorPage> {
  late final ProjectDao _projectDao;
  late final SyncQueueDao _syncQueueDao;
  late final ConflictDao _conflictDao;

  int _projectCount = 0;
  int _pendingQueueCount = 0;
  int _unresolvedConflictCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _projectDao = GetIt.instance<ProjectDao>();
    _syncQueueDao = GetIt.instance<SyncQueueDao>();
    _conflictDao = GetIt.instance<ConflictDao>();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final projects = await _projectDao.getProjects();
      final pending = await _syncQueueDao.pendingCount();
      final conflicts = await _conflictDao.getUnresolvedConflicts();

      setState(() {
        _projectCount = projects.length;
        _pendingQueueCount = pending;
        _unresolvedConflictCount = conflicts.length;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading stats: $e')));
      }
    }
  }

  Future<void> _forceClaimQueue() async {
    try {
      final claimed = await _syncQueueDao.claimBatch(10);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Claimed ${claimed.length} queue items')),
        );
      }
      await _loadStats();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error claiming queue: $e')));
      }
    }
  }

  Future<void> _truncateCache() async {
    try {
      // Show confirmation dialog
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Truncate Cache'),
          content: const Text(
            'Are you sure? This will delete all cached data.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete'),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      // TODO: Implement cache truncation
      // This should clear all tables or specific cache tables
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cache truncation not yet implemented')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error truncating cache: $e')));
      }
    }
  }

  Future<void> _exportDb() async {
    try {
      // TODO: Implement DB export to file
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('DB export not yet implemented')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error exporting DB: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) {
      return Scaffold(
        appBar: AppBar(title: const Text('DB Inspector')),
        body: const Center(
          child: Text('DB Inspector only available in debug mode'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Database Inspector'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadStats),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats Cards
                  _buildStatsCard(
                    title: 'Projects',
                    count: _projectCount,
                    icon: Icons.folder,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 12),
                  _buildStatsCard(
                    title: 'Pending Queue Items',
                    count: _pendingQueueCount,
                    icon: Icons.cloud_upload,
                    color: Colors.orange,
                  ),
                  const SizedBox(height: 12),
                  _buildStatsCard(
                    title: 'Unresolved Conflicts',
                    count: _unresolvedConflictCount,
                    icon: Icons.warning,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 24),

                  // Action Buttons
                  const Text(
                    'Actions',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildActionButton(
                    label: 'Force Claim Queue',
                    icon: Icons.cloud_upload,
                    onPressed: _forceClaimQueue,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 8),
                  _buildActionButton(
                    label: 'Truncate Cache',
                    icon: Icons.delete,
                    onPressed: _truncateCache,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 8),
                  _buildActionButton(
                    label: 'Export Database',
                    icon: Icons.download,
                    onPressed: _exportDb,
                    color: Colors.green,
                  ),
                  const SizedBox(height: 24),

                  // Info Section
                  const Text(
                    'Database Info',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoTile(
                    label: 'Database Path',
                    value: 'app.db (app documents)',
                  ),
                  _buildInfoTile(label: 'Schema Version', value: '1'),
                  _buildInfoTile(
                    label: 'Debug Mode',
                    value: kDebugMode ? 'Enabled' : 'Disabled',
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatsCard({
    required String title,
    required int count,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    count.toString(),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
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

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildInfoTile({required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
