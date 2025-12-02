import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/issue_comments.dart';

part 'issue_comment_dao.g.dart';

@DriftAccessor(tables: [IssueComments])
class IssueCommentDao extends DatabaseAccessor<AppDatabase>
    with _$IssueCommentDaoMixin {
  IssueCommentDao(super.db);

  Future<void> insertComment(IssueCommentsCompanion entity) async {
    await into(issueComments).insert(entity);
  }

  Future<void> updateComment(IssueCommentsCompanion entity) async {
    await update(issueComments).replace(entity);
  }

  Future<void> updateCommentServerFields(
    String localId,
    String serverId,
    int serverCreatedAt,
  ) async {
    await (update(issueComments)..where((t) => t.id.equals(localId))).write(
      IssueCommentsCompanion(
        serverId: Value(serverId),
        serverCreatedAt: Value(serverCreatedAt),
        status: const Value('SYNCED'),
      ),
    );
  }

  Future<List<IssueComment>> getCommentsForIssue(
    String issueLocalId, {
    int limit = 100,
    int offset = 0,
  }) async {
    return (select(issueComments)
          ..where((t) => t.issueLocalId.equals(issueLocalId))
          ..orderBy([
            (t) =>
                OrderingTerm(expression: t.createdAt, mode: OrderingMode.asc),
          ])
          ..limit(limit, offset: offset))
        .get();
  }

  Stream<List<IssueComment>> watchCommentsForIssue(String issueLocalId) {
    return (select(issueComments)
          ..where((t) => t.issueLocalId.equals(issueLocalId))
          ..orderBy([
            (t) =>
                OrderingTerm(expression: t.createdAt, mode: OrderingMode.asc),
          ]))
        .watch();
  }

  Future<int> deleteComment(String id) async {
    // Soft delete
    return (update(issueComments)..where((t) => t.id.equals(id))).write(
      IssueCommentsCompanion(
        deletedAt: Value(DateTime.now().millisecondsSinceEpoch),
        status: const Value('PENDING'),
      ),
    );
  }

  Future<void> updateSyncStatus(String id, String status) async {
    await (update(issueComments)..where((t) => t.id.equals(id))).write(
      IssueCommentsCompanion(status: Value(status)),
    );
  }

  Future<IssueComment?> getCommentById(String id) async {
    return (select(
      issueComments,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }
}
