import 'dart:io';
import '../entities/media_entity.dart';

abstract class MediaRepository {
  Future<MediaEntity> uploadMedia({
    required File file,
    required String parentType,
    required String parentId,
    Map<String, dynamic>? metadata,
  });

  Future<void> associateMedia({
    required String parentId,
    required String parentType,
    required List<String> mediaIds,
  });

  Future<List<MediaEntity>> listMedia({
    required String parentType,
    required String parentId,
  });

  Future<String> getDownloadUrl(String mediaId);

  Future<String> getThumbnailUrl(String mediaId);
}
