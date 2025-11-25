import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

import '../../../../core/db/app_database.dart';
import '../../../../core/sync/sync_manager.dart';

class ConflictResolverPage extends StatefulWidget {
  const ConflictResolverPage({super.key});

  @override
  State<ConflictResolverPage> createState() => _ConflictResolverPageState();
}

class _ConflictResolverPageState extends State<ConflictResolverPage> {
  late final SyncManager _syncManager;
  List<SyncConflict> _conflicts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _syncManager = GetIt.instance<SyncManager>();
    _loadConflicts();
  }

  Future<void> _loadConflicts() async {
    setState(() => _isLoading = true);
    try {
      final conflicts = await _syncManager.getConflicts();
      setState(() {
        _conflicts = conflicts;
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _resolve(String conflictId, String strategy) async {
    try {
      await _syncManager.resolveConflict(conflictId, strategy);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Conflict resolved')));
      }
      _loadConflicts();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error resolving conflict: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sync Conflicts')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _conflicts.isEmpty
          ? const Center(child: Text('No conflicts found'))
          : ListView.builder(
              itemCount: _conflicts.length,
              itemBuilder: (context, index) {
                final conflict = _conflicts[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Entity: ${conflict.entityType} (${conflict.entityId})',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        // Error field not available in SyncConflict
                        // Text('Error: ${conflict.error}'),
                        Text(
                          'Date: ${DateFormat.yMMMd().add_jm().format(DateTime.fromMillisecondsSinceEpoch(conflict.createdAt))}',
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () =>
                                  _resolve(conflict.id, 'server_wins'),
                              child: const Text('Use Server Version'),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () =>
                                  _resolve(conflict.id, 'client_wins'),
                              child: const Text('Keep Local Version'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
