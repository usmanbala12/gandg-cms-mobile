import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/db/app_database.dart';
import '../../../../core/db/daos/issue_comment_dao.dart';
import '../../../../core/db/daos/issue_dao.dart';
import '../../../../core/db/daos/meta_dao.dart';
import '../../../../core/db/daos/sync_queue_dao.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/sync/sync_manager.dart';
import '../../domain/entities/issue_comment_entity.dart';
import '../../domain/entities/issue_entity.dart';
import '../../domain/entities/data_source.dart';
import '../../domain/repositories/issue_repository.dart';
import '../datasources/issue_remote_datasource.dart';
import '../models/issue_comment_model.dart';
import '../models/issue_model.dart';

import '../../../../core/db/daos/issue_history_dao.dart';
import '../../../../core/db/daos/issue_media_dao.dart';

/// Implementation of IssueRepository with offline-first logic.
class IssueRepositoryImpl implements IssueRepository {
  final AppDatabase db;
  final IssueDao issueDao;
  final IssueCommentDao issueCommentDao;
  final IssueHistoryDao issueHistoryDao;
  final IssueMediaDao issueMediaDao;
  final SyncQueueDao syncQueueDao;
  final MetaDao metaDao;
  final IssueRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;
  final Logger logger;

  IssueRepositoryImpl({
    required this.db,
    required this.issueDao,
    required this.issueCommentDao,
    required this.issueHistoryDao,
    required this.issueMediaDao,
    required this.syncQueueDao,
    required this.metaDao,
    required this.remoteDataSource,
    required this.networkInfo,
    Logger? logger,
  }) : logger = logger ?? Logger();

  @override
  Stream<List<IssueEntity>> watchIssues({
    String? projectId,
    Map<String, dynamic>? filters,
  }) {
    // If no projectId provided, try to get active project
    if (projectId == null) {
      // For streams, we can't await, so we'll just return empty stream
      // In practice, UI should always provide projectId or get it before calling
      logger.w('watchIssues called without projectId');
      return Stream.value([]);
    }

    return issueDao.watchIssuesForProject(projectId).map((rows) {
      return rows.map((row) => IssueModel.fromDb(row).toEntity()).toList();
    });
  }

  @override
  Future<IssueListResult> getIssues({
    String? projectId,
    bool forceRemote = false,
    Map<String, dynamic>? filters,
    int limit = 50,
    int offset = 0,
  }) async {
    // Get active project if not provided
    final pid = projectId ?? await metaDao.getValue('active_project_id');
    if (pid == null) {
      logger.w('No project ID available for getIssues');
      return IssueListResult.error(
        'No active project selected. Please select a project from the dashboard.',
      );
    }

    // Check connectivity
    final isOnline = await networkInfo.isOnline();
    logger.d(
      'getIssues: projectId=$pid, online=$isOnline, forceRemote=$forceRemote',
    );

    // Get last sync timestamp for this project
    final lastSyncKey = 'issues_last_synced_$pid';
    final lastSyncedAt = await metaDao.getValue(lastSyncKey);
    final lastSyncTimestamp = lastSyncedAt != null
        ? int.tryParse(lastSyncedAt)
        : null;

    // If online, fetch from remote first
    if (isOnline) {
      try {
        logger.i('Fetching issues from remote API...');
        final remoteData = await remoteDataSource.fetchProjectIssues(
          pid,
          limit: limit,
          offset: offset,
          filters: filters,
        );

        logger.i('Received ${remoteData.length} issues from remote');

        // Update local DB in transaction
        await db.transaction(() async {
          for (final data in remoteData) {
            final model = IssueModel.fromJson(data);
            await _smartUpsertIssue(model);
          }

          // Update last synced timestamp
          final now = DateTime.now().millisecondsSinceEpoch;
          await metaDao.setValue(lastSyncKey, now.toString());
        });

        // Return fresh remote data
        final rows = await issueDao.getIssuesForProject(
          pid,
          limit: limit,
          offset: offset,
        );
        final entities = rows
            .map((row) => IssueModel.fromDb(row).toEntity())
            .toList();

        logger.i('✅ Returned ${entities.length} issues from remote');
        return IssueListResult.remote(
          entities,
          lastSyncedAt: DateTime.now().millisecondsSinceEpoch,
        );
      } on DioException catch (e) {
        // Handle different error types
        if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
          logger.e(
            'Authentication error fetching issues: ${e.response?.statusCode}',
          );
          return IssueListResult.error(
            'Authentication failed. Please log in again.',
          );
        } else if (e.response?.statusCode != null &&
            e.response!.statusCode! >= 400) {
          logger.e('Server error fetching issues: ${e.response?.statusCode}');
          // Fallback to local for server errors
          return await _getLocalIssues(
            pid,
            limit,
            offset,
            'Server error. Showing cached data.',
            lastSyncTimestamp,
          );
        } else {
          // Network error - fallback to local
          logger.w('Network error fetching issues: $e');
          return await _getLocalIssues(
            pid,
            limit,
            offset,
            'No internet connection. Showing cached data.',
            lastSyncTimestamp,
          );
        }
      } catch (e) {
        logger.e('Unexpected error fetching remote issues: $e');
        // Fallback to local
        return await _getLocalIssues(
          pid,
          limit,
          offset,
          'Error loading data. Showing cached data.',
          lastSyncTimestamp,
        );
      }
    } else {
      // Offline - read from local DB
      logger.i('Device offline, reading from local DB');
      return await _getLocalIssues(
        pid,
        limit,
        offset,
        'Offline mode. Showing cached data.',
        lastSyncTimestamp,
      );
    }
  }

  /// Smart upsert that preserves local pending changes.
  Future<void> _smartUpsertIssue(IssueModel remoteIssue) async {
    // Check if issue exists locally
    final localIssue = remoteIssue.serverId != null
        ? await issueDao.getIssueByServerId(remoteIssue.serverId!)
        : await issueDao.getIssueById(remoteIssue.id);

    if (localIssue != null && localIssue.syncStatus == 'PENDING') {
      // Local has pending changes - only update server fields
      logger.d('Preserving local pending changes for issue ${localIssue.id}');
      if (remoteIssue.serverId != null) {
        await issueDao.updateIssueServerFields(
          localIssue.id,
          remoteIssue.serverId!,
          remoteIssue.serverUpdatedAt ?? DateTime.now().millisecondsSinceEpoch,
        );
      }
    } else {
      // No local pending changes - full upsert
      final companion = remoteIssue.toCompanion();
      await issueDao.insertIssue(companion);
    }
  }

  /// Helper to get issues from local DB.
  Future<IssueListResult> _getLocalIssues(
    String projectId,
    int limit,
    int offset,
    String? message,
    int? lastSyncedAt,
  ) async {
    final rows = await issueDao.getIssuesForProject(
      projectId,
      limit: limit,
      offset: offset,
    );
    final entities = rows
        .map((row) => IssueModel.fromDb(row).toEntity())
        .toList();

    logger.i('Returned ${entities.length} issues from local DB');
    return IssueListResult.local(
      entities,
      message: message,
      lastSyncedAt: lastSyncedAt,
    );
  }

  @override
  Future<IssueEntity?> getIssue(String localId) async {
    final row = await issueDao.getIssueById(localId);
    if (row == null) return null;
    return IssueModel.fromDb(row).toEntity();
  }

  @override
  Stream<IssueEntity?> watchIssue(String localId) {
    return issueDao.watchIssueById(localId).map((row) {
      if (row == null) return null;
      return IssueModel.fromDb(row).toEntity();
    });
  }

  @override
  Future<String> createIssue({
    required String projectId,
    required String title,
    String? description,
    String? priority,
    String? assigneeId,
    String? category,
    String? location,
    int? dueDate,
    String? meta,
  }) async {
    final issueId = const Uuid().v4();
    final now = DateTime.now().millisecondsSinceEpoch;

    logger.i('Creating issue: $issueId');

    // Atomic transaction: insert issue + enqueue sync
    await db.transaction(() async {
      // Insert issue
      await issueDao.insertIssue(
        IssuesCompanion.insert(
          id: issueId,
          projectId: projectId,
          title: title,
          description: Value(description),
          priority: Value(priority ?? 'MEDIUM'),
          assigneeId: Value(assigneeId),
          status: Value('OPEN'),
          category: Value(category),
          location: Value(location),
          dueDate: Value(dueDate),
          createdAt: now,
          updatedAt: now,
          meta: Value(meta),
        ),
      );

      // Enqueue sync item
      await syncQueueDao.enqueue(
        SyncQueueCompanion.insert(
          id: const Uuid().v4(),
          projectId: projectId,
          entityType: 'issue',
          entityId: issueId,
          action: 'create',
          createdAt: now,
          payload: Value(
            jsonEncode({
              'title': title,
              if (description != null) 'description': description,
              if (priority != null) 'priority': priority,
              if (assigneeId != null) 'assignee_id': assigneeId,
              if (category != null) 'category': category,
              if (location != null) 'location': location,
              if (dueDate != null) 'due_date': dueDate,
              if (meta != null) 'meta': meta,
            }),
          ),
        ),
      );
    });

    logger.i('✅ Issue created and enqueued: $issueId');
    return issueId;
  }

  @override
  Future<void> updateIssue({
    required String localId,
    String? title,
    String? description,
    String? priority,
    String? assigneeId,
    String? category,
    String? location,
    int? dueDate,
    String? meta,
  }) async {
    final issue = await issueDao.getIssueById(localId);
    if (issue == null) {
      throw Exception('Issue not found: $localId');
    }

    final now = DateTime.now().millisecondsSinceEpoch;

    await db.transaction(() async {
      // Update issue
      await issueDao.updateIssue(
        IssuesCompanion(
          id: Value(localId),
          title: Value(title ?? issue.title),
          description: Value(description ?? issue.description),
          priority: Value(priority ?? issue.priority),
          assigneeId: Value(assigneeId ?? issue.assigneeId),
          category: Value(category ?? issue.category),
          location: Value(location ?? issue.location),
          dueDate: Value(dueDate ?? issue.dueDate),
          updatedAt: Value(now),
          meta: Value(meta ?? issue.meta),
        ),
      );

      // Enqueue sync item
      await syncQueueDao.enqueue(
        SyncQueueCompanion.insert(
          id: const Uuid().v4(),
          projectId: issue.projectId,
          entityType: 'issue',
          entityId: localId,
          action: 'update',
          createdAt: now,
          payload: Value(
            jsonEncode({
              'title': title ?? issue.title,
              if (description != null) 'description': description,
              if (priority != null) 'priority': priority,
              if (assigneeId != null) 'assignee_id': assigneeId,
              if (category != null) 'category': category,
              if (location != null) 'location': location,
              if (dueDate != null) 'due_date': dueDate,
              if (meta != null) 'meta': meta,
            }),
          ),
        ),
      );
    });

    logger.i('✅ Issue updated and enqueued: $localId');
  }

  @override
  Future<void> changeIssueStatus(
    String localId,
    String newStatus, {
    String? comment,
    String? authorId,
  }) async {
    final issue = await issueDao.getIssueById(localId);
    if (issue == null) {
      throw Exception('Issue not found: $localId');
    }

    final now = DateTime.now().millisecondsSinceEpoch;

    await db.transaction(() async {
      // Update local status
      await issueDao.updateIssueStatus(localId, newStatus);

      // If comment provided, add it
      if (comment != null && authorId != null) {
        final commentId = const Uuid().v4();
        await issueCommentDao.insertComment(
          IssueCommentsCompanion.insert(
            id: commentId,
            issueLocalId: localId,
            authorId: authorId,
            body: comment,
            createdAt: now,
            updatedAt: now,
          ),
        );

        // Enqueue comment sync
        await syncQueueDao.enqueue(
          SyncQueueCompanion.insert(
            id: const Uuid().v4(),
            projectId: issue.projectId,
            entityType: 'issue',
            entityId: commentId,
            action: 'comment',
            createdAt: now,
            payload: Value(
              jsonEncode({
                'issue_local_id': localId,
                'body': comment,
                'author_id': authorId,
              }),
            ),
          ),
        );
      }

      // Enqueue status change sync
      await syncQueueDao.enqueue(
        SyncQueueCompanion.insert(
          id: const Uuid().v4(),
          projectId: issue.projectId,
          entityType: 'issue',
          entityId: localId,
          action: 'status',
          createdAt: now,
          payload: Value(
            jsonEncode({
              'status': newStatus,
              if (comment != null) 'comment': comment,
            }),
          ),
        ),
      );
    });

    logger.i('✅ Issue status changed and enqueued: $localId -> $newStatus');
  }

  @override
  Future<void> addComment(
    String localIssueId,
    String text,
    String authorId,
  ) async {
    final issue = await issueDao.getIssueById(localIssueId);
    if (issue == null) {
      throw Exception('Issue not found: $localIssueId');
    }

    final commentId = const Uuid().v4();
    final now = DateTime.now().millisecondsSinceEpoch;

    await db.transaction(() async {
      // Insert comment
      await issueCommentDao.insertComment(
        IssueCommentsCompanion.insert(
          id: commentId,
          issueLocalId: localIssueId,
          authorId: authorId,
          body: text,
          createdAt: now,
          updatedAt: now,
        ),
      );

      // Enqueue sync item
      await syncQueueDao.enqueue(
        SyncQueueCompanion.insert(
          id: const Uuid().v4(),
          projectId: issue.projectId,
          entityType: 'issue',
          entityId: commentId,
          action: 'comment',
          createdAt: now,
          payload: Value(
            jsonEncode({
              'issue_local_id': localIssueId,
              'body': text,
              'author_id': authorId,
            }),
          ),
        ),
      );
    });

    logger.i('✅ Comment added and enqueued: $commentId');
  }

  @override
  Future<List<IssueCommentEntity>> getComments(String issueLocalId) async {
    final rows = await issueCommentDao.getCommentsForIssue(issueLocalId);
    return rows.map((row) => IssueCommentModel.fromDb(row).toEntity()).toList();
  }

  @override
  Stream<List<IssueCommentEntity>> watchComments(String issueLocalId) {
    return issueCommentDao.watchCommentsForIssue(issueLocalId).map((rows) {
      return rows
          .map((row) => IssueCommentModel.fromDb(row).toEntity())
          .toList();
    });
  }

  @override
  Future<void> deleteIssue(String localId) async {
    final issue = await issueDao.getIssueById(localId);
    if (issue == null) throw Exception('Issue not found: $localId');

    final now = DateTime.now().millisecondsSinceEpoch;

    await db.transaction(() async {
      // Soft delete locally
      await issueDao.deleteIssue(localId);

      // Enqueue sync item
      await syncQueueDao.enqueue(
        SyncQueueCompanion.insert(
          id: const Uuid().v4(),
          projectId: issue.projectId,
          entityType: 'issue',
          entityId: localId,
          action: 'delete',
          createdAt: now,
        ),
      );
    });

    logger.i('✅ Issue deleted and enqueued: $localId');
  }

  @override
  Future<void> assignIssue(String localId, String assigneeId) async {
    final issue = await issueDao.getIssueById(localId);
    if (issue == null) throw Exception('Issue not found: $localId');

    final now = DateTime.now().millisecondsSinceEpoch;

    await db.transaction(() async {
      // Update local issue
      await issueDao.updateIssue(
        IssuesCompanion(
          id: Value(localId),
          assigneeId: Value(assigneeId),
          updatedAt: Value(now),
          syncStatus: const Value('PENDING'),
        ),
      );

      // Add history record
      await issueHistoryDao.insertHistory(
        IssueHistoryCompanion.insert(
          id: const Uuid().v4(),
          issueId: localId,
          action: 'assign',
          field: Value('assignee_id'),
          oldValue: Value(issue.assigneeId),
          newValue: Value(assigneeId),
          authorId: 'CURRENT_USER', // TODO: Get actual user ID
          timestamp: now,
        ),
      );

      // Enqueue sync item
      await syncQueueDao.enqueue(
        SyncQueueCompanion.insert(
          id: const Uuid().v4(),
          projectId: issue.projectId,
          entityType: 'issue',
          entityId: localId,
          action: 'assign',
          createdAt: now,
          payload: Value(jsonEncode({'assignee_id': assigneeId})),
        ),
      );
    });

    logger.i('✅ Issue assigned and enqueued: $localId -> $assigneeId');
  }

  @override
  Future<void> attachMedia(String localIssueId, String filePath) async {
    final issue = await issueDao.getIssueById(localIssueId);
    if (issue == null) throw Exception('Issue not found: $localIssueId');

    final mediaId = const Uuid().v4();
    // TODO: Calculate file size and mime type
    final sizeBytes = 0;
    final mimeType = 'application/octet-stream';

    await db.transaction(() async {
      // Insert media record
      await issueMediaDao.insertMedia(
        IssueMediaCompanion.insert(
          id: mediaId,
          issueId: localIssueId,
          localPath: filePath,
          mimeType: mimeType,
          sizeBytes: sizeBytes,
          uploadStatus: const Value('PENDING'),
        ),
      );

      // Enqueue sync item
      await syncQueueDao.enqueue(
        SyncQueueCompanion.insert(
          id: const Uuid().v4(),
          projectId: issue.projectId,
          entityType: 'media', // Special type for media upload
          entityId: mediaId,
          action: 'upload',
          createdAt: DateTime.now().millisecondsSinceEpoch,
          payload: Value(
            jsonEncode({'parent_type': 'issue', 'parent_id': localIssueId}),
          ),
        ),
      );
    });

    logger.i('✅ Media attached and enqueued: $mediaId');
  }

  @override
  Future<List<Map<String, dynamic>>> loadHistory(String localIssueId) async {
    // Load local history
    final localHistory = await issueHistoryDao.getHistoryForIssue(localIssueId);

    // Convert to map list
    final historyList = localHistory
        .map(
          (h) => {
            'id': h.id,
            'action': h.action,
            'field': h.field,
            'old_value': h.oldValue,
            'new_value': h.newValue,
            'author_id': h.authorId,
            'created_at': h.timestamp,
            'source': 'local',
          },
        )
        .toList();

    // Try to fetch remote history if online
    try {
      final issue = await issueDao.getIssueById(localIssueId);
      if (issue?.serverId != null) {
        final remoteHistory = await remoteDataSource.fetchIssueHistory(
          issue!.serverId!,
        );
        // Merge logic: prefer remote, but keep local pending actions
        // For simplicity, just append remote ones that aren't in local (by ID or timestamp?)
        // Or just return combined list sorted by date
        for (final item in remoteHistory) {
          item['source'] = 'remote';
          historyList.add(item);
        }
      }
    } catch (e) {
      logger.w('Failed to fetch remote history: $e');
    }

    // Sort by date descending
    historyList.sort((a, b) {
      final tA = (a['created_at'] as num?)?.toInt() ?? 0;
      final tB = (b['created_at'] as num?)?.toInt() ?? 0;
      return tB.compareTo(tA);
    });

    return historyList;
  }

  @override
  Future<void> processSyncQueueItem(
    String projectId,
    String entityId,
    String action,
    String? payload,
  ) async {
    logger.i('Processing issue sync item: $action for $entityId');

    if (action == 'create') {
      if (payload == null) throw Exception('Payload missing for create');
      final map = jsonDecode(payload);

      try {
        final response = await remoteDataSource.createIssue(projectId, map);
        final serverId = response['id'] ?? response['data']?['id'];
        final serverUpdatedAt =
            response['updated_at'] ??
            response['data']?['updated_at'] ??
            DateTime.now().millisecondsSinceEpoch;

        if (serverId != null) {
          await issueDao.updateIssueServerFields(
            entityId,
            serverId.toString(),
            serverUpdatedAt is int
                ? serverUpdatedAt
                : DateTime.now().millisecondsSinceEpoch,
          );
        }
      } on Exception catch (e) {
        // Check for 409 conflict
        if (e.toString().contains('409')) {
          throw ConflictException(
            message: 'Issue creation conflict',
            serverPayload: jsonEncode({'error': 'Conflict detected'}),
          );
        }
        rethrow;
      }
    } else if (action == 'update') {
      if (payload == null) throw Exception('Payload missing for update');
      final map = jsonDecode(payload);
      final issue = await issueDao.getIssueById(entityId);
      final serverId = issue?.serverId;

      if (serverId != null) {
        await remoteDataSource.updateIssue(projectId, serverId, map);
      } else {
        throw Exception('Cannot update issue without serverId');
      }
    } else if (action == 'status') {
      if (payload == null) throw Exception('Payload missing for status');
      final map = jsonDecode(payload);
      final issue = await issueDao.getIssueById(entityId);
      final serverId = issue?.serverId;

      if (serverId != null) {
        await remoteDataSource.patchIssueStatus(serverId, map);
      } else {
        logger.w('Cannot patch status for issue without serverId: $entityId');
      }
    } else if (action == 'delete') {
      final issue = await issueDao.getIssueById(entityId);
      final serverId = issue?.serverId;

      if (serverId != null) {
        await remoteDataSource.deleteIssue(projectId, serverId);
        // Fully delete from local DB if needed, or keep soft deleted
      } else {
        // If no serverId, it was never synced, so just delete locally
        // But we already soft deleted it. Maybe hard delete now?
        // Or just ignore.
        logger.i('Issue deleted locally before sync: $entityId');
      }
    } else if (action == 'assign') {
      if (payload == null) throw Exception('Payload missing for assign');
      final map = jsonDecode(payload);
      final issue = await issueDao.getIssueById(entityId);
      final serverId = issue?.serverId;

      if (serverId != null) {
        await remoteDataSource.assignIssue(serverId, map);
      } else {
        logger.w('Cannot assign issue without serverId: $entityId');
      }
    } else if (action == 'comment') {
      if (payload == null) throw Exception('Payload missing for comment');
      final map = jsonDecode(payload);
      final issueLocalId = map['issue_local_id'];

      if (issueLocalId == null) {
        throw Exception('issue_local_id missing in comment payload');
      }

      final issue = await issueDao.getIssueById(issueLocalId);
      final issueServerId = issue?.serverId;

      if (issueServerId != null) {
        final response = await remoteDataSource.createComment(issueServerId, {
          'body': map['body'],
          'author_id': map['author_id'],
        });

        final commentServerId = response['id'] ?? response['data']?['id'];
        final serverCreatedAt =
            response['created_at'] ??
            response['data']?['created_at'] ??
            DateTime.now().millisecondsSinceEpoch;

        if (commentServerId != null) {
          await issueCommentDao.updateCommentServerFields(
            entityId,
            commentServerId.toString(),
            serverCreatedAt is int
                ? serverCreatedAt
                : DateTime.now().millisecondsSinceEpoch,
          );
        }
      } else {
        logger.w(
          'Cannot create comment for issue without serverId: $issueLocalId',
        );
      }
    }

    logger.i('✅ Processed issue sync item: $action for $entityId');
  }
}
