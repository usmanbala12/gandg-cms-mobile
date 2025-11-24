import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/media.dart';

part 'media_dao.g.dart';

@DriftAccessor(tables: [MediaFiles])
class MediaDao extends DatabaseAccessor<AppDatabase> with _$MediaDaoMixin {
  MediaDao(super.db);

  Future<void> insertMedia(MediaFilesCompanion entity) async {
    await into(mediaFiles).insert(entity);
  }

  Future<void> updateMediaStatus(String id, String status) async {
    await (update(mediaFiles)..where((t) => t.id.equals(id))).write(
      MediaFilesCompanion(uploadStatus: Value(status)),
    );
  }

  Future<void> updateAfterUpload(String localId, String serverId) async {
    await (update(mediaFiles)..where((t) => t.id.equals(localId))).write(
      MediaFilesCompanion(
        serverId: Value(serverId),
        uploadStatus: const Value('SYNCED'),
      ),
    );
  }

  Future<List<MediaFile>> getPendingMediaForUpload(
    String projectId, {
    int limit = 10,
  }) async {
    return (select(mediaFiles)
          ..where(
            (t) =>
                t.projectId.equals(projectId) &
                t.uploadStatus.equals('PENDING'),
          )
          ..orderBy([(t) => OrderingTerm(expression: t.createdAt)])
          ..limit(limit))
        .get();
  }

  Future<int> deleteMedia(String id) async {
    return (delete(mediaFiles)..where((t) => t.id.equals(id))).go();
  }

  Future<int> totalMediaSizeForProject(String projectId) async {
    final result = await customSelect(
      'SELECT COALESCE(SUM(size), 0) as total FROM media_files WHERE project_id = ?;',
      variables: [Variable.withString(projectId)],
      readsFrom: {mediaFiles},
    ).map((row) => row.read<int>('total')).getSingle();
    return result;
  }

  Future<MediaFile?> getMediaById(String id) async {
    return (select(
      mediaFiles,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<List<MediaFile>> getMediaForParent(
    String parentType,
    String parentId,
  ) async {
    return (select(mediaFiles)..where(
          (t) => t.parentType.equals(parentType) & t.parentId.equals(parentId),
        ))
        .get();
  }

  Future<List<MediaFile>> getMediaForProjectOrdered(String projectId) async {
    return (select(mediaFiles)
          ..where((t) => t.projectId.equals(projectId))
          ..orderBy([
            (t) => OrderingTerm(expression: t.uploadStatus),
            (t) => OrderingTerm(expression: t.createdAt),
          ]))
        .get();
  }
}
