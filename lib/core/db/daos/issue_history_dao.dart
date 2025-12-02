import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/issue_history.dart';

part 'issue_history_dao.g.dart';

@DriftAccessor(tables: [IssueHistory])
class IssueHistoryDao extends DatabaseAccessor<AppDatabase>
    with _$IssueHistoryDaoMixin {
  IssueHistoryDao(super.db);

  Future<void> insertHistory(IssueHistoryCompanion entity) async {
    await into(issueHistory).insert(entity);
  }

  Future<List<IssueHistoryData>> getHistoryForIssue(String issueId) async {
    return (select(issueHistory)
          ..where((t) => t.issueId.equals(issueId))
          ..orderBy([
            (t) =>
                OrderingTerm(expression: t.timestamp, mode: OrderingMode.asc),
          ]))
        .get();
  }

  Stream<List<IssueHistoryData>> watchHistoryForIssue(String issueId) {
    return (select(issueHistory)
          ..where((t) => t.issueId.equals(issueId))
          ..orderBy([
            (t) =>
                OrderingTerm(expression: t.timestamp, mode: OrderingMode.asc),
          ]))
        .watch();
  }
}
