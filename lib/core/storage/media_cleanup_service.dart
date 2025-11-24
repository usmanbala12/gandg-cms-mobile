import 'dart:io';

import 'package:logger/logger.dart';

import '../db/app_database.dart';
import '../db/daos/media_dao.dart';
import '../db/db_utils.dart';

/// Service for managing media storage and enforcing storage caps.
class MediaCleanupService {
  final MediaDao mediaDao;
  final Logger logger;

  MediaCleanupService({required this.mediaDao, Logger? logger})
    : logger = logger ?? Logger();

  /// Check and enforce media storage cap for a project.
  /// Removes oldest non-referenced files until under cap.
  /// Returns true if cleanup was performed, false otherwise.
  Future<bool> enforceStorageCap(String projectId, {int? capBytes}) async {
    try {
      final cap = capBytes ?? MediaStorage.defaultMediaCapBytes;
      final totalSize = await mediaDao.totalMediaSizeForProject(projectId);

      logger.i('Media storage for project $projectId: $totalSize / $cap bytes');

      if (totalSize <= cap) {
        logger.i('Media storage is within cap');
        return false;
      }

      logger.w('Media storage exceeds cap, starting cleanup');
      return await _performCleanup(projectId, cap);
    } catch (e) {
      logger.e('Error enforcing storage cap for project $projectId: $e');
      rethrow;
    }
  }

  /// Perform cleanup by removing oldest files until under cap.
  Future<bool> _performCleanup(String projectId, int cap) async {
    try {
      var totalSize = await mediaDao.totalMediaSizeForProject(projectId);
      var filesRemoved = 0;

      final orderedMedia = await mediaDao.getMediaForProjectOrdered(projectId);
      if (orderedMedia.isEmpty) {
        logger.i('No media records found for project $projectId');
        return false;
      }

      logger.i('Starting cleanup: need to free ${totalSize - cap} bytes');

      final seen = <String>{};
      final purgeQueue = <MediaFile>[];

      void enqueue(Iterable<MediaFile> items) {
        for (final media in items) {
          if (seen.add(media.id)) {
            purgeQueue.add(media);
          }
        }
      }

      enqueue(
        orderedMedia.where(
          (media) =>
              media.parentId.trim().isEmpty ||
              media.uploadStatus == MediaUploadStatus.error,
        ),
      );

      enqueue(
        orderedMedia.where(
          (media) => media.uploadStatus == MediaUploadStatus.synced,
        ),
      );

      enqueue(
        orderedMedia.where(
          (media) =>
              media.uploadStatus != MediaUploadStatus.error &&
              media.uploadStatus != MediaUploadStatus.synced,
        ),
      );

      for (final media in purgeQueue) {
        if (totalSize <= cap) {
          break;
        }

        final file = File(media.localPath);
        try {
          if (await file.exists()) {
            await file.delete();
            logger.i('Deleted media file ${media.localPath}');
          }
        } catch (e) {
          logger.w('Failed to delete file ${media.localPath}: $e');
        }

        await deleteThumbnail(media.thumbnailPath);

        await mediaDao.deleteMedia(media.id);
        filesRemoved += 1;
        totalSize -= media.size;

        logger.w(
          'Removed media ${media.id} (${media.size} bytes). Remaining usage: $totalSize / $cap',
        );
      }

      logger.i('Cleanup completed: removed $filesRemoved files');
      return filesRemoved > 0;
    } catch (e) {
      logger.e('Error during cleanup: $e');
      rethrow;
    }
  }

  /// Get total media size for a project.
  Future<int> getTotalMediaSize(String projectId) async {
    try {
      return await mediaDao.totalMediaSizeForProject(projectId);
    } catch (e) {
      logger.e('Error getting total media size for project $projectId: $e');
      rethrow;
    }
  }

  /// Delete a media file from disk and database.
  Future<void> deleteMediaFile(String mediaId, String localPath) async {
    try {
      // Delete from filesystem
      final file = File(localPath);
      if (await file.exists()) {
        await file.delete();
        logger.i('Deleted media file from disk: $localPath');
      }

      // Delete from database
      await mediaDao.deleteMedia(mediaId);
      logger.i('Deleted media record from database: $mediaId');
    } catch (e) {
      logger.e('Error deleting media file $mediaId: $e');
      rethrow;
    }
  }

  /// Delete thumbnail file if it exists.
  Future<void> deleteThumbnail(String? thumbnailPath) async {
    if (thumbnailPath == null) return;

    try {
      final file = File(thumbnailPath);
      if (await file.exists()) {
        await file.delete();
        logger.i('Deleted thumbnail file: $thumbnailPath');
      }
    } catch (e) {
      logger.e('Error deleting thumbnail $thumbnailPath: $e');
      // Don't rethrow; thumbnail deletion is non-critical
    }
  }

  /// Get storage usage statistics for a project.
  Future<StorageStats> getStorageStats(String projectId) async {
    try {
      final totalSize = await mediaDao.totalMediaSizeForProject(projectId);
      final cap = MediaStorage.defaultMediaCapBytes;
      final percentUsed = (totalSize / cap * 100).toStringAsFixed(1);

      return StorageStats(
        totalBytes: totalSize,
        capBytes: cap,
        percentUsed: double.parse(percentUsed),
        isOverCap: totalSize > cap,
      );
    } catch (e) {
      logger.e('Error getting storage stats for project $projectId: $e');
      rethrow;
    }
  }
}

/// Storage statistics for a project.
class StorageStats {
  final int totalBytes;
  final int capBytes;
  final double percentUsed;
  final bool isOverCap;

  StorageStats({
    required this.totalBytes,
    required this.capBytes,
    required this.percentUsed,
    required this.isOverCap,
  });

  String get totalMB => (totalBytes / (1024 * 1024)).toStringAsFixed(2);
  String get capMB => (capBytes / (1024 * 1024)).toStringAsFixed(2);

  @override
  String toString() =>
      'StorageStats(${totalMB}MB / ${capMB}MB, $percentUsed% used, overCap: $isOverCap)';
}
