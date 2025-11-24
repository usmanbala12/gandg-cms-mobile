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
    return (delete(issues)..where((t) => t.id.equals(id))).go();
  }

  Future<Issue?> getIssueById(String id) async {
    return (select(issues)..where((t) => t.id.equals(id))).getSingleOrNull();
  }
}
