import 'dart:async';

import 'package:logger/logger.dart';

import '../db/app_database.dart';
import '../db/daos/sync_queue_dao.dart';
import '../db/daos/meta_dao.dart';
import '../db/db_utils.dart';
import '../network/api_client.dart';
import '../../features/requests/domain/repositories/request_repository.dart';

/// SyncManager orchestrates the offline sync workflow.
/// Simplified to only handle request payload syncing.
class SyncManager {
  final AppDatabase db;
  final SyncQueueDao syncQueueDao;
  final MetaDao metaDao;
  final ApiClient apiClient;
  final RequestRepository requestRepository;
  final Logger logger;

  SyncManager({
    required this.db,
    required this.syncQueueDao,
    required this.metaDao,
    required this.apiClient,
    required this.requestRepository,
    Logger? logger,
  }) : logger = logger ?? Logger();

  /// Run a sync cycle: process pending queue items.
  Future<void> runSyncCycle({
    String? projectId,
    int batchSize = SyncConstants.defaultBatchSize,
  }) async {
    try {
      logger.i(
        'Starting sync cycle (projectId: $projectId, batchSize: $batchSize)',
      );

      await _processOutgoing(batchSize: batchSize);

      logger.i('Sync cycle completed successfully');
    } catch (e) {
      logger.e('Error during sync cycle: $e');
      rethrow;
    }
  }

  /// Process outgoing queue items: claim, process, and mark done/failed.
  Future<void> _processOutgoing({
    int batchSize = SyncConstants.defaultBatchSize,
  }) async {
    try {
      logger.i('Processing outgoing queue (batch size: $batchSize)');

      final claimed = await syncQueueDao.claimBatch(batchSize);
      logger.i('Claimed ${claimed.length} queue items');

      for (final item in claimed) {
        try {
          await _processQueueItem(item);
          await syncQueueDao.markDone(item.id);
          logger.i('Marked queue item ${item.id} as DONE');
        } catch (e) {
          logger.e('Error processing queue item ${item.id}: $e');
          final attempts = item.attempts + 1;
          if (attempts >= SyncConstants.maxRetries) {
            await syncQueueDao.markFailed(item.id, e.toString());
            logger.e(
              'Marked queue item ${item.id} as FAILED (max retries exceeded)',
            );
          } else {
            await syncQueueDao.reenqueue(item.id);
            logger.i(
              'Requeued item ${item.id} (attempt $attempts/${SyncConstants.maxRetries})',
            );
          }
        }
      }

      logger.i('Finished processing outgoing queue');
    } catch (e) {
      logger.e('Error in _processOutgoing: $e');
      rethrow;
    }
  }

  /// Process a single queue item based on entity type.
  Future<void> _processQueueItem(SyncQueueData item) async {
    try {
      logger.i(
        'Processing queue item: ${item.entityType}/${item.entityId} (${item.action})',
      );

      switch (item.entityType) {
        case 'request':
          await requestRepository.processSyncQueueItem(
            item.projectId,
            item.entityId,
            item.action,
            item.payload,
          );
          break;

        default:
          logger.w('Unknown entity type: ${item.entityType}');
      }

      logger.i(
        'Successfully processed queue item: ${item.entityType}/${item.entityId}',
      );
    } catch (e) {
      logger.e('Error processing queue item ${item.id}: $e');
      rethrow;
    }
  }

  /// Get pending queue count.
  Future<int> getPendingQueueCount() async {
    return await syncQueueDao.pendingCount();
  }

  /// Get pending queue items for display.
  Future<List<SyncQueueData>> getPendingItems() async {
    return await syncQueueDao.getPending(100);
  }

  Future<void> processOutgoingForTesting({
    int batchSize = SyncConstants.defaultBatchSize,
  }) {
    return _processOutgoing(batchSize: batchSize);
  }
}
