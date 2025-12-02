import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/issues.dart';

part 'issue_dao.g.dart';

@DriftAccessor(tables: [Issues])
class IssueDao extends DatabaseAccessor<AppDatabase> with _$IssueDaoMixin {
  IssueDao(super.db);

  Future<void> insertIssue(IssuesCompanion entity) async {
    await into(issues).insert(entity);
  }

  Future<void> updateIssue(IssuesCompanion entity) async {
    await update(issues).replace(entity);
  }

  Future<void> updateIssueServerFields(
    String localId,
    String serverId,
    int serverUpdatedAt,
  ) async {
    await (update(issues)..where((t) => t.id.equals(localId))).write(
      IssuesCompanion(
        serverId: Value(serverId),
        serverUpdatedAt: Value(serverUpdatedAt),
      ),
    );
  }

  Future<List<Issue>> getIssuesForProject(
    String projectId, {
    int limit = 50,
    int offset = 0,
  }) async {
    return (select(issues)
          ..where((t) => t.projectId.equals(projectId))
          ..orderBy([
            (t) =>
                OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
          ])
          ..limit(limit, offset: offset))
        .get();
  }

  Future<List<Issue>> getOpenIssuesForProject(String projectId) async {
    return (select(issues)..where(
          (t) => t.projectId.equals(projectId) & t.status.equals('OPEN'),
        ))
        .get();
  }

  Stream<List<Issue>> watchIssuesForProject(String projectId) {
    return (select(issues)
          ..where((t) => t.projectId.equals(projectId))
          ..orderBy([
            (t) =>
                OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
          ]))
        .watch();
  }

  Future<int> deleteIssue(String id) async {
    // Soft delete
    return (update(issues)..where((t) => t.id.equals(id))).write(
      IssuesCompanion(
        deletedAt: Value(DateTime.now().millisecondsSinceEpoch),
        syncStatus: const Value('PENDING'),
      ),
    );
  }

  Future<void> updateSyncStatus(String id, String status) async {
    await (update(issues)..where((t) => t.id.equals(id))).write(
      IssuesCompanion(syncStatus: Value(status)),
    );
  }

  Future<Issue?> getIssueById(String id) async {
    return (select(issues)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<Issue?> getIssueByServerId(String serverId) async {
    return (select(
      issues,
    )..where((t) => t.serverId.equals(serverId))).getSingleOrNull();
  }

  Future<void> updateIssueStatus(String localId, String newStatus) async {
    await (update(issues)..where((t) => t.id.equals(localId))).write(
      IssuesCompanion(
        status: Value(newStatus),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  }

  Future<List<Issue>> getIssuesByStatus(
    String projectId,
    String status, {
    int limit = 50,
    int offset = 0,
  }) async {
    return (select(issues)
          ..where(
            (t) => t.projectId.equals(projectId) & t.status.equals(status),
          )
          ..orderBy([
            (t) =>
                OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
          ])
          ..limit(limit, offset: offset))
        .get();
  }

  Future<List<Issue>> getIssuesByPriority(
    String projectId,
    String priority, {
    int limit = 50,
    int offset = 0,
  }) async {
    return (select(issues)
          ..where(
            (t) => t.projectId.equals(projectId) & t.priority.equals(priority),
          )
          ..orderBy([
            (t) =>
                OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
          ])
          ..limit(limit, offset: offset))
        .get();
  }

  Future<List<Issue>> searchIssues(
    String projectId,
    String query, {
    int limit = 50,
    int offset = 0,
  }) async {
    final searchPattern = '%$query%';
    return (select(issues)
          ..where(
            (t) =>
                t.projectId.equals(projectId) &
                (t.title.like(searchPattern) |
                    t.description.like(searchPattern)),
          )
          ..orderBy([
            (t) =>
                OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
          ])
          ..limit(limit, offset: offset))
        .get();
  }

  Stream<Issue?> watchIssueById(String id) {
    return (select(issues)..where((t) => t.id.equals(id))).watchSingleOrNull();
  }
}
