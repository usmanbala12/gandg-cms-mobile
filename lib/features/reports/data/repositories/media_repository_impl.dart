import 'dart:io';

import 'package:drift/drift.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/db/app_database.dart';
import '../../../../core/db/daos/media_dao.dart';
import '../../../../core/db/daos/sync_queue_dao.dart';
import '../../../../core/db/repositories/media_repository.dart';
import '../../../../core/network/api_client.dart';

class MediaRepositoryImpl implements MediaRepository {
  final AppDatabase db;
  final MediaDao mediaDao;
  final SyncQueueDao syncQueueDao;
  final ApiClient apiClient;
  final Logger logger;

  MediaRepositoryImpl({
    required this.db,
    required this.mediaDao,
    required this.syncQueueDao,
    required this.apiClient,
    Logger? logger,
  }) : logger = logger ?? Logger();

  @override
  Future<void> uploadMediaQueueHandler(String mediaId) async {
    try {
      final mediaRecord = await mediaDao.getMediaById(mediaId);
      if (mediaRecord == null) {
        throw Exception('Media record not found: $mediaId');
      }

      // Update status to SYNCING
      await mediaDao.updateMediaStatus(mediaId, 'SYNCING');

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
      await mediaDao.updateMediaStatus(mediaId, 'ERROR');
      rethrow;
    }
  }

  @override
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

  @override
  Future<int> totalMediaSizeForProject(String projectId) async {
    try {
      return await mediaDao.totalMediaSizeForProject(projectId);
    } catch (e) {
      logger.e('Error calculating total media size for project $projectId: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteMedia(String mediaId) async {
    try {
      await mediaDao.deleteMedia(mediaId);
      logger.i('Deleted media $mediaId');
    } catch (e) {
      logger.e('Error deleting media $mediaId: $e');
      rethrow;
    }
  }
}
