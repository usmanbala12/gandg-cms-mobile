import 'dart:io';

import 'package:drift/drift.dart';
import 'package:logger/logger.dart';

import '../app_database.dart';
import '../daos/media_dao.dart';
import '../daos/sync_queue_dao.dart';
import '../db_utils.dart';
import '../../network/api_client.dart';

/// Repository for media operations with atomic insert + enqueue.
class MediaRepository {
  final AppDatabase db;
  final MediaDao mediaDao;
  final SyncQueueDao syncQueueDao;
  final ApiClient apiClient;
  final Logger logger;

  MediaRepository({
    required this.db,
    required this.mediaDao,
    required this.syncQueueDao,
    required this.apiClient,
    Logger? logger,
  }) : logger = logger ?? Logger();

  /// Save local media file and enqueue for upload.
  /// Atomically inserts media record and enqueues upload sync item.
  Future<String> saveLocalMediaAndEnqueue(
    String projectId,
    String filePath,
    String parentType,
    String parentId, {
    String? mimeType,
  }) async {
    try {
      final mediaId = uuid();
      final nowMs = now();

      // Get file size
      final file = File(filePath);
      final size = await file.length();

      await db.transaction(() async {
        // Insert media record
        await mediaDao.insertMedia(
          MediaFilesCompanion.insert(
            id: mediaId,
            localPath: filePath,
            projectId: projectId,
            parentType: parentType,
            parentId: parentId,
            uploadStatus: const Value(MediaUploadStatus.pending),
            mime: Value(mimeType),
            size: size,
            createdAt: nowMs,
          ),
        );

        // Enqueue upload sync item
        await syncQueueDao.enqueue(
          SyncQueueCompanion.insert(
            id: uuid(),
            projectId: projectId,
            entityType: 'media',
            entityId: mediaId,
            action: SyncQueueAction.create,
            payload: Value(filePath), // Store file path as payload
            priority: const Value(0), // Lower priority than reports
            status: const Value(SyncQueueStatus.pending),
            attempts: const Value(0),
            lastAttemptAt: const Value(null),
            errorMessage: const Value(null),
            createdAt: nowMs,
          ),
        );
      });

      logger.i('Saved media $mediaId for $parentType:$parentId and enqueued');
      return mediaId;
    } catch (e) {
      logger.e('Error saving media for $parentType:$parentId: $e');
      rethrow;
    }
  }

  /// Process a sync queue item for media upload.
  /// Uploads the file and updates media record with server ID.
  Future<void> uploadMediaQueueHandler(String mediaId) async {
    try {
      final mediaRecord = await mediaDao.getMediaById(mediaId);
      if (mediaRecord == null) {
        throw Exception('Media record not found: $mediaId');
      }

      // Update status to SYNCING
      await mediaDao.updateMediaStatus(mediaId, MediaUploadStatus.syncing);

      // Upload to server
      final response = await apiClient.uploadMedia(
        mediaRecord.projectId,
        mediaRecord.localPath,
        mediaRecord.parentType,
        mediaRecord.parentId,
        mimeType: mediaRecord.mime,
      );

      // Update media record with server ID and mark as SYNCED
      final serverId = response['id'] ?? response['serverId'];
      if (serverId != null) {
        await mediaDao.updateAfterUpload(mediaId, serverId);
        logger.i('Uploaded media $mediaId to server: $serverId');
      } else {
        throw Exception('No server ID returned for media upload');
      }
    } catch (e) {
      logger.e('Error uploading media $mediaId: $e');
      // Update status to ERROR
      await mediaDao.updateMediaStatus(mediaId, MediaUploadStatus.error);
      rethrow;
    }
  }

  /// Get pending media for upload in a project.
  Future<List<Map<String, dynamic>>> getPendingMediaForUpload(
    String projectId, {
    int limit = 10,
  }) async {
    try {
      final media = await mediaDao.getPendingMediaForUpload(
        projectId,
        limit: limit,
      );
      return media
          .map(
            (m) => {
              'id': m.id,
              'localPath': m.localPath,
              'projectId': m.projectId,
              'parentType': m.parentType,
              'parentId': m.parentId,
              'uploadStatus': m.uploadStatus,
              'mime': m.mime,
              'size': m.size,
              'createdAt': m.createdAt,
              'serverId': m.serverId,
              'thumbnailPath': m.thumbnailPath,
            },
          )
          .toList();
    } catch (e) {
      logger.e('Error fetching pending media for project $projectId: $e');
      rethrow;
    }
  }

  /// Get total media size for a project.
  Future<int> totalMediaSizeForProject(String projectId) async {
    try {
      return await mediaDao.totalMediaSizeForProject(projectId);
    } catch (e) {
      logger.e('Error calculating total media size for project $projectId: $e');
      rethrow;
    }
  }

  /// Get media for a specific parent entity.
  Future<List<Map<String, dynamic>>> getMediaForParent(
    String parentType,
    String parentId,
  ) async {
    try {
      final media = await mediaDao.getMediaForParent(parentType, parentId);
      return media
          .map(
            (m) => {
              'id': m.id,
              'localPath': m.localPath,
              'projectId': m.projectId,
              'parentType': m.parentType,
              'parentId': m.parentId,
              'uploadStatus': m.uploadStatus,
              'mime': m.mime,
              'size': m.size,
              'createdAt': m.createdAt,
              'serverId': m.serverId,
              'thumbnailPath': m.thumbnailPath,
            },
          )
          .toList();
    } catch (e) {
      logger.e('Error fetching media for $parentType:$parentId: $e');
      rethrow;
    }
  }

  /// Delete media record.
  Future<void> deleteMedia(String mediaId) async {
    try {
      await mediaDao.deleteMedia(mediaId);
      logger.i('Deleted media $mediaId');
    } catch (e) {
      logger.e('Error deleting media $mediaId: $e');
      rethrow;
    }
  }

  Future<MediaFile?> getMediaById(String mediaId) {
    return mediaDao.getMediaById(mediaId);
  }
}
