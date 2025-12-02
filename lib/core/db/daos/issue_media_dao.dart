import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/issue_media.dart';

part 'issue_media_dao.g.dart';

@DriftAccessor(tables: [IssueMedia])
class IssueMediaDao extends DatabaseAccessor<AppDatabase>
    with _$IssueMediaDaoMixin {
  IssueMediaDao(super.db);

  Future<void> insertMedia(IssueMediaCompanion entity) async {
    await into(issueMedia).insert(entity);
  }

  Future<void> updateMediaStatus(String id, String status) async {
    await (update(issueMedia)..where((t) => t.id.equals(id))).write(
      IssueMediaCompanion(uploadStatus: Value(status)),
    );
  }

  Future<void> updateMediaServerFields(
    String localId,
    String serverId,
    String serverUrl,
  ) async {
    await (update(issueMedia)..where((t) => t.id.equals(localId))).write(
      IssueMediaCompanion(
        serverId: Value(serverId),
        serverUrl: Value(serverUrl),
        uploadStatus: const Value('DONE'),
      ),
    );
  }

  Future<List<IssueMediaData>> getMediaForIssue(String issueId) async {
    return (select(issueMedia)..where((t) => t.issueId.equals(issueId))).get();
  }

  Stream<List<IssueMediaData>> watchMediaForIssue(String issueId) {
    return (select(
      issueMedia,
    )..where((t) => t.issueId.equals(issueId))).watch();
  }

  Future<IssueMediaData?> getMediaById(String id) async {
    return (select(
      issueMedia,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }
}
