import 'dart:io';
import 'package:field_link/features/media/domain/entities/media_entity.dart';
import 'package:field_link/features/media/domain/repositories/media_repository.dart';
import 'package:field_link/features/media/data/datasources/media_remote_datasource.dart';

class MediaRepositoryImpl implements MediaRepository {
  final MediaRemoteDataSource remoteDataSource;

  MediaRepositoryImpl({required this.remoteDataSource});

  @override
  Future<MediaEntity> uploadMedia({
    required File file,
    required String parentType,
    required String parentId,
    Map<String, dynamic>? metadata,
  }) async {
    final json = await remoteDataSource.uploadMedia(
      file: file,
      parentType: parentType,
      parentId: parentId,
      metadata: metadata,
    );
    return MediaEntity.fromJson(json);
  }

  @override
  Future<void> associateMedia({
    required String parentId,
    required String parentType,
    required List<String> mediaIds,
  }) async {
    await remoteDataSource.associateMedia(
      parentId: parentId,
      parentType: parentType,
      mediaIds: mediaIds,
    );
  }

  @override
  Future<List<MediaEntity>> listMedia({
    required String parentType,
    required String parentId,
  }) async {
    final list = await remoteDataSource.listMedia(
      parentType: parentType,
      parentId: parentId,
    );
    return list.map((json) => MediaEntity.fromJson(json)).toList();
  }

  @override
  Future<String> getDownloadUrl(String mediaId) {
    return remoteDataSource.getDownloadUrl(mediaId);
  }

  @override
  Future<String> getThumbnailUrl(String mediaId) {
    return remoteDataSource.getThumbnailUrl(mediaId);
  }
}
